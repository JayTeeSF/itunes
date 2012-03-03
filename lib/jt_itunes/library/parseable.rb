module JtItunes
  module Library::Parseable
    KEY = 'key' # parse
    module ClassMethods
      def itunes_names_to_symbols
        Hash[_attr_names.zip(_attr_symbols)]
      end

      def new_key? node, name_match=KEY
        name_match == node.name
      end

      def expected_node_text? node, matching_texts=_attr_names
        matching_texts.include?(node.text)
      end

      def found_key_node? node, matching_texts=_attr_names, name_match=KEY
        new_key?(node, name_match) && expected_node_text?(node, matching_texts)
      end

      def collect_track_ids_from(node, xpath, id_attr)
        collect_node_text_after_each_match(
          node.xpath(xpath).children,
          [id_attr]
        )
      end

      def xpath
        raise NotImplementedError, "xpath must be defined"
      end

      def sub_ids_key
        nil
      end
      alias :sub_id_xpath :sub_ids_key
      alias :sub_id_attr :sub_ids_key

      def key_node_attrs(node)
        [node]
      end

      def parse(itunes_library_parser)
        itunes_library_parser.xml.xpath(xpath).map do |object_entry|
          key = false
          object_attributes = object_entry.children.reduce({}) do |memo, node|
            if found_key_node?(*key_node_attrs(node))
              key = node.text
            elsif key
              if sub_ids_key && key == sub_ids_key
                memo[sub_ids_key] ||= []
                memo[sub_ids_key] |=
                  collect_track_ids_from(node, sub_id_xpath, sub_id_attr)
                # not sure if we should clear key, at this point, i.e. key = nil
              else
                memo[key] = node.text
                key = false
              end
            end
            memo
          end
          create extract_params(
            object_attributes, {
            :for_keys => object_attributes.keys,
            :as => itunes_names_to_symbols.merge(symbol_overrides)
          })
        end.compact
      end

      def next_node_in(node_list, patterns=[], pattern_detector=:found_key_node?)
        key = false
        node_list.detect do |node|
          key ? key : ((key = send(pattern_detector, node, patterns)) && false)
        end
      end

      def symbol_overrides
        {}
      end

      def collect_node_text_after_each_match(nodes, matching_texts=[])
        key = false
        nodes.reduce([]) do |memo, node|
          if found_key_node?(node, matching_texts)
            key = true
          elsif key
            memo << node.text
            key = false
          end
          memo
        end
      end
    end

    def self.included(base)
      base.class_eval do
        extend ClassMethods
      end
    end
  end # Parseable
end
