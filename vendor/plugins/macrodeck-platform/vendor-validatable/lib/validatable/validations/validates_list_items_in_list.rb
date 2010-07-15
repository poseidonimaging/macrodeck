module Validatable
  # Validates that the array we're validating's items are specified in +:list+
  class ValidatesListItemsInList < ValidationBase
    required_option :list
    
    def valid?(instance)
      value = instance.send(attribute)
      return true if allow_nil && value.nil?
      return true if allow_blank && value.blank?
      return false if value.nil?

      value.each do |val|
      	return false unless list.include?(val)
      end

      # All of the items are in the +:list+, return true.
      return true
    end
    
    def message(instance)
      super || "is not in the list"
    end
  end
end
