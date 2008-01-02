# String Extension
# Adds capitalize_each method.
# From: http://donttrustthisguy.com/2005/12/31/ruby-extending-classes-and-method-chaining/
class String  
	def capitalize_each  
		self.split(" ").each{|word| word.capitalize!}.join(" ")  
	end  
	def capitalize_each!  
		replace capitalize_each  
	end  
end  
