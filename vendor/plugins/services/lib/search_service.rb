
class SearchService < BaseService

  def SearchService.search(items,query,where=['title'])
      case items[0].instance_of?
        when DataItem, ProfileItem
          metadata_method = lambda {|i| DataService.getDataItemMetadata(i.id) }
        when DataGroup, Profile
          metadata_method = lambda {|i| DataService.getDataGroupMetadata(i.id) }
        when Storage
          metadata_method = lambda {|i| StorageService.getFileMetadata(i.id) }
        else
          metadata_method = lambda {|i| i.attributes}
      end
      fields = parse_where(where)
      lfunc, keywords = parse_query(query)
      inv_search_table, search_table = prepare_search_tables
      res = Hash.new
      where.each {|field|
          col = keywords.collect {|word| inv_search_table[word][field]}
          res[field] = Array.new
          lfunc.call(col).each { |i|
              res[field].push(Hash[:item =>fields[i], :relevance=> 50.0,
              :metadata => metadata_method.call(field[i])])
          }
      }
  end
  
  private
  
  def parse_query(query)
      lex = query.split
      terms = Array.new
      ops = Array.new
      lex.each {|word|
          case word
              when "AND"
                  ops.push("&")
              when "OR"
                  ops.push("|")
              else
                  terms.push(word)                  
          end
      }
      [lambda_gen(ops),terms]
  end
  
  def parse_where(where)
      where
  end

  def lambda_gen(ops)
      t = Array.new
      ops.each {|op|
          t.push(lambda {|t1,t2| t1.send(op,t2)})
      }
      lambda {|args|
          arg1 = args.shift
          i = 1
          while !args.empty?
              arg2 = args.shift
              arg3 = t[i-1].call(arg1,arg2)
              i += 1
              arg1 = arg3
          end
          arg1
      }
  end

  def relevent_of(data,keywords)
      data.split
  end

  def prepare_search_tables(items,fields)
      inv_search_table = Hash.new
      search_table = Hash.new
      items.each {|item|
          item.attributes(:only=>fields).each {|attr, value|
              value.to_s.split.each {|keyword|
                  if !inv_search_table.has_key?(keyword)
                      inv_search_table[keyword] = Hash.new
                      inv_search_table[keyword][attr] = Array.new
                  elsif !inv_search_table[keyword].has_key?(attr)
                      inv_search_table[keyword][attr] = Array.new
                  end
                  inv_search_table[keyword][attr].push(items.index(item))
                  search_table[items.index(item)][attr][keyword] = 0
              }
          }
      }
      [inv_search_table, search_table]
  end
  
end