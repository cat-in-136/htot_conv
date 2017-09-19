
module HTOTConv
  module Util
    def pad_array(array, length, pad=nil)
      raise ArgumentError, "array is not an array" unless array.kind_of?(Array)
      raise ArgumentError, "array length #{array.length} is larger than #{length}" if array.length > length

      array.concat(Array.new(length - array.length, pad))
    end
    module_function :pad_array
  end
end
