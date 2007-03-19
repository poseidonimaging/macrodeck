
class Metadata
  attr_reader :type, :creator, :owner, :tags, :title, :creation, :description, :datacreator
  
  def initialize(type=nil,creator=nil,owner=nil,tags=nil,title=nil,creation=nil,description=nil,datacreator=nil)
    set_instance_variables(binding, *local_variables)
  end

  def loadFromHash(hash)
    hash.each{|key,val| instance_variable_set("@#{key}", eval(val, binding))} 
  end  
  
  def fetch(obj)
    begin
      instance_variables.each do |var|
        var.sub!(/^@/,'')
        instance_variable_set("@#{var}",obj.send(var)) if obj.respond_to?(var)
      end  
    end
  end
end