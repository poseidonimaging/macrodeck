
class SearchService < BaseService

  def SearchService.search(items,query,where=['title'])
      fields = parse_where(where)
      lfunc, keywords = parse_query(query)
      itbl = Hash.new
      inv_search_table = Hash.new
      search_table = Hash.new
      inv_search_table, search_table = prepare_search_tables
       
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