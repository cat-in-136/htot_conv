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

    def valid?
      @key_header.kind_of?(Array) &&
        @key_header.all? { |v| v.nil? || v.kind_of?(String) } &&
        @value_header.kind_of?(Array) &&
        @value_header.all? { |v| v.nil? || v.kind_of?(String) } &&
        @item.kind_of?(Array) &&
        @item.all? { |item| item.valid? }
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

    Item = Struct.new(:key, :level, :value) do
      def valid?
        self.level.kind_of?(Numeric) &&
          (self.level > 0) &&
          (self.level.to_i == self.level) &&
          self.value.kind_of?(Array)
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

      def ancestors # :yield: ancestor
        ancestors = []
        node = self.parent
        until (node.nil? || node.root?)
          ancestors << node
          yield node if block_given?
          node = node.parent
        end
        ancestors
      end

      def descendants # :yield: descendant
        descendants = []
        @children.each do |child|
          descendants << child
          yield child if block_given?
          child.descendants do |descendant|
            descendants << descendant
            yield descendant if block_given?
          end
        end
        descendants
      end
    end
  end
end
