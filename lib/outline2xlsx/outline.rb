module Outline2xlsx
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

    Item = Struct.new(:key, :level, :value) do
      def valid?
        self.level.kind_of?(Numeric) &&
          (self.level > 0) &&
          (self.level.to_i == self.level) &&
          self.value.kind_of?(Array)
      end
    end
  end
end
