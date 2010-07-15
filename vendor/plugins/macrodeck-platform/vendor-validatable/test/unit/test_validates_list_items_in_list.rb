require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

Expectations do
  expect true do
    validation = Validatable::ValidatesListItemsInList.new stub_everything, :state, :list => %w(one two three)
    validation.valid?(stub(:state => ["one"] ))
  end

  expect true do
    validation = Validatable::ValidatesListItemsInList.new stub_everything, :state, :list => %w(one two three)
    validation.valid?(stub(:state => ["one", "two", "three"] ))
  end
  
  expect false do
    validation = Validatable::ValidatesListItemsInList.new stub_everything, :state, :list => %w(one two three)
    validation.valid?(stub(:state => ["foo"]))
  end
  
  expect true do
    validation = Validatable::ValidatesListItemsInList.new stub_everything, :state, :list => %w(one two three), :allow_blank => true
    validation.valid?(stub(:state => ''))
  end

  expect true do
    validation = Validatable::ValidatesListItemsInList.new stub_everything, :state, :list => %w(one two three), :allow_blank => true
    validation.valid?(stub(:state => []))
  end

  expect true do
    validation = Validatable::ValidatesListItemsInList.new stub_everything, :state, :list => %w(one two three), :allow_nil => true
    validation.valid?(stub(:state => nil))
  end
end
