module Utils
    def assign_when_undef(var,value)
        var = value unless defined? var
    end
end