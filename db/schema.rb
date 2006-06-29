# This file is autogenerated. Instead of editing this file, please use the
# migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.

ActiveRecord::Schema.define(:version => 3) do

  create_table "data_groups", :force => true do |t|
    t.column "groupingtype", :string
    t.column "creator", :string
    t.column "groupingid", :string
    t.column "owner", :string
    t.column "tags", :text
    t.column "parent", :string
  end

  create_table "data_items", :force => true do |t|
    t.column "datatype", :string
    t.column "datacreator", :string
    t.column "dataid", :string
    t.column "grouping", :string
    t.column "owner", :string
    t.column "creator", :string
    t.column "creation", :integer
    t.column "tags", :text
    t.column "title", :string
    t.column "description", :text
    t.column "stringdata", :text
    t.column "integerdata", :integer
    t.column "objectdata", :text
    t.column "read_permissions", :string
    t.column "write_permissions", :string
  end

end
