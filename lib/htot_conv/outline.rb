# frozen_string_literal: true
module HTOTConv
  class Outline
    def initialize
      @item = []
    end

    attr_accessor :key_header
    attr_accessor :value_header
    attr_accessor :item

    def add_item(*args)
      @item << Item.new(*args)
    end

    def validate
      raise ValidationError, "key_header must be an array" unless @key_header.kind_of?(Array)
      raise ValidationError, "key_header elements must be strings." unless @key_header.all? { |v| v.nil? || v.kind_of?(String) }
      raise ValidationError, "value_header must be an array" unless @value_header.kind_of?(Array)
      raise ValidationError, "value_header elements must be strings." unless @value_header.all? { |v| v.nil? || v.kind_of?(String) }
      raise ValidationError, "item must be an array" unless @item.kind_of?(Array)
      @item.each { |item| item.validate }
    end

    def valid?
      begin
        validate
        true
      rescue ValidationError
        false
      end
    end

    def max_level
      [
        @key_header.length,
        *(@item.map { |v| v.level.to_i }),
      ].max
    end

    def max_value_length
      [
        @value_header.length,
        *(@item.map { |v| (v.value)? v.value.length : 0 }),
      ].max
    end

    def ==(v)
      (@key_header == v.key_header) &&
        (@value_header == v.value_header) &&
        (@item == v.item)
    end

    def to_tree
      root = Tree.new
      last_node = root
      @item.each_with_index do |item,i|
        parent_node = root
        if ((item.level > 1) && !(last_node.root?))
          if item.level > last_node.item.level
            parent_node = last_node
          else
            parent_node = last_node.parent
            parent_node = parent_node.parent until (parent_node.root? || parent_node.item.level < item.level)
          end
        end

        parent_node << item
        last_node = parent_node.to_a.last
      end
      root
    end

    class ValidationError < RuntimeError
    end

    Item = Struct.new(:key, :level, :value) do
      def validate
        raise ValidationError, "item level for item \"#{key}\" must be an integer" unless self.level.kind_of?(Numeric)
        raise ValidationError, "item level for item \"#{key}\" must be positive" unless self.level > 0
        raise ValidationError, "item level for item \"#{key}\" must be an integer" unless (self.level.to_i == self.level)
        raise ValidationError, "value for item \"#{key}\" must be an array" unless self.value.kind_of?(Array)
      end

      def valid?
        begin
          validate
          true
        rescue ValidationError
          false
        end
      end
    end

    class Tree
      include Enumerable

      def initialize(item=nil, parent=nil)
        @item = item
        @parent = parent
        @children = []
      end
      attr_accessor :item
      attr_reader :parent

      def root?
        @parent.nil?
      end

      def leaf?
        @children.empty?
      end

      def add(item)
        child = Tree.new(item, self)
        @children << child
        self
      end
      alias :<< :add

      def each # :yield: child
        @children.each do |v|
          yield v if block_given?
        end
        @children.dup
      end

      def root
        node = self
        node = node.parent until node.root?
        node
      end

      def next
        if root?
          nil
        else
          brothers = parent.to_a
          index = brothers.index(self)
          (index + 1 < brothers.length)? brothers[index + 1] : nil
        end
      end

      def prev
        if root?
          nil
        else
          brothers = parent.to_a
          index = brothers.index(self)
          (index - 1 >= 0)? brothers[index - 1] : nil
        end
      end

      def ancestors
        Enumerator.new do |y|
          node = self.parent
          until (node.nil? || node.root?)
            y << node
            node = node.parent
          end 
        end
      end

      def descendants
        Enumerator.new do |y|
          @children.each do |child|
            y << child
            child.descendants.each do |descendant|
              y << descendant
            end
          end
        end
      end
    end
  end
end
