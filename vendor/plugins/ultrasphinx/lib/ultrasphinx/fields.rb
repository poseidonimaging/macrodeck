
module Ultrasphinx

=begin rdoc
This is a special singleton configuration class that stores the index field configurations. Rather than using a magic hash and including relevant behavior in Ultrasphinx::Configure and Ultrasphinx::Search, we unify it here.
=end

  class Fields
    # XXX Class needs a big refactoring; one of the worst parts of Ultrasphinx
    
    include Singleton
    include Associations
    
    TYPE_MAP = {
      'string' => 'text', 
      'text' => 'text', 
      'integer' => 'integer', 
      'date' => 'date', 
      'datetime' => 'date',
      'timestamp' => 'date',
      'float' => 'float',
      'boolean' => 'bool',
      'multi' => 'multi',
      'query' => 'query'
    }
        
    attr_accessor :classes, :types
    
    def initialize
      @types = {}
      @classes = Hash.new([])
      @groups = []
    end
    
    
    def groups
      @groups.compact.sort_by do |string| 
        string[/= (.*)/, 1]
      end
    end
  
  
    def save_and_verify_type(field, new_type, string_sortable, klass, msg = nil)
      # Smoosh fields together based on their name in the Sphinx query schema
      field, new_type = field.to_s, TYPE_MAP[new_type.to_s]

      if types[field]
        # Existing field name; verify its type
        msg ||= "Column type mismatch for #{field.inspect}; was already #{types[field].inspect}, but is now #{new_type.inspect}."
        raise ConfigurationError, msg unless types[field] == new_type
        classes[field] = (classes[field] + [klass]).uniq

      else
        # New field      
        types[field] = new_type
        classes[field] = [klass]

        @groups << case new_type
          when 'integer'
            "sql_attr_uint = #{field}"
          when 'float'
            "sql_attr_float = #{field}"
          when 'bool'
            "sql_attr_bool = #{field}"
          when 'date'
            "sql_attr_timestamp = #{field}"
          when 'text' 
            "sql_attr_str2ordinal = #{field}" if string_sortable
          when 'multi'
            "sql_attr_multi = uint #{field} from field"
        end
      end
    end

    def cast(source_string, field)
      if types[field] == "date"
        "UNIX_TIMESTAMP(#{source_string})"
      elsif types[field] == "integer"
        source_string # "CAST(#{source_string} AS UNSIGNED)"
      else
        source_string              
      end + " AS #{field}"
    end    
      
      
    def null(field)      
      default = case types[field]
        when 'text', 'multi'
          "''"
        when 'integer', 'float', 'bool'
          "0"
        when 'date'
          "18000" # Midnight on 1/1/1970
        when 'query'
          nil
        when nil
          raise "Field #{field} is missing"
        else
          raise "Field #{field} does not have a valid type #{types[field]}."
      end 
      default + " AS #{field}" if default
    end
    
    
    def configure(configuration)

      configuration.each do |model, options|        

        klass = model.constantize        
        save_and_verify_type('class_id', 'integer', nil, klass)
        save_and_verify_type('class', 'string', nil, klass)
                
        begin
        
          # Fields are from the model
          options['fields'] = options['fields'].to_a.map do |entry|
            extract_table_alias!(entry, klass)
            extract_field_alias!(entry, klass)
            
            unless klass.columns_hash[entry['field']]
              # XXX I think this is here for migrations
              Ultrasphinx.say "warning: field #{entry['field']} is not present in #{model}"
            else
              save_and_verify_type(entry['as'], klass.columns_hash[entry['field']].type, nil, klass)
              install_duplicate_fields!(entry, klass)
            end            
          end  
          
          # Joins are whatever they are in the target       
          options['include'].to_a.each do |entry|
            extract_table_alias!(entry, klass)
            extract_field_alias!(entry, klass)
            
            association_model = get_association_model(klass, entry)
            
            save_and_verify_type(entry['as'] || entry['field'], association_model.columns_hash[entry['field']].type, nil, klass)
            install_duplicate_fields!(entry, klass)
          end  
          
          # Regular concats are CHAR, group_concats are BLOB and need to be cast to CHAR
          options['concatenate'].to_a.each do |entry|
            if entry['doc_id']
              # this is a query mva, add type but no group
              save_and_verify_type(entry['as'], 'query', nil, klass) 
            else
              extract_table_alias!(entry, klass)

              if entry['fields']
                type = 'text'
              else
                extract_field_alias!(entry, klass)

                field_column = klass.connection.columns(entry['table_alias']).detect { |c| c.name == entry['field'] }
                type = field_column.type.to_s == 'integer' ? 'multi' : 'text'
              end

              save_and_verify_type(entry['as'], type, nil, klass) 
              install_duplicate_fields!(entry, klass)
            end
          end          
          
        rescue ActiveRecord::StatementInvalid
          Ultrasphinx.say "warning: model #{model} does not exist in the database yet"
        end  
      end
      
      self
    end
    
    
    def install_duplicate_fields!(entry, klass)
      if entry['facet']
        # Source must be a string
        save_and_verify_type(entry['as'], 'text', nil, klass, 
          "#{klass}##{entry['as']}: 'facet' option is only valid for text fields; numeric fields are enabled by default")
        # Install facet column                
        save_and_verify_type("#{entry['as']}_facet", 'integer', nil, klass)
      end

      if entry['sortable']
        # Source must be a string
        save_and_verify_type(entry['as'], 'text', nil, klass, 
          "#{klass}##{entry['as']}: 'sortable' option is only valid for text columns; numeric fields are enabled by default")
        # Install sortable column        
        save_and_verify_type("#{entry['as']}_sortable", 'text', true, klass)      
      end
      entry
    end
    
    
    def extract_field_alias!(entry, klass)
      unless entry['as']    
        entry['as'] = entry['field'] 
      end
    end
    
    
    def extract_table_alias!(entry, klass)
      unless entry['table_alias']
        entry['table_alias'] = if entry['field'] and entry['field'].include? "." and entry['association_sql']
          # This field is referenced by a table alias in association_sql
          table_alias, entry['field'] = entry['field'].split(".")
          table_alias
        elsif get_association(klass, entry)
          # Refers to the association
          get_association(klass, entry).name
        elsif entry['association_sql']
          # Refers to the association_sql class's table
          entry['class_name'].constantize.table_name
        else
          # Refers to this class
          klass.table_name
        end
      end
    end
    
  end
end
    
