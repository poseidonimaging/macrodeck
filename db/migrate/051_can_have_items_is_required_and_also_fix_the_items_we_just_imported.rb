class CanHaveItemsIsRequiredAndAlsoFixTheItemsWeJustImported < ActiveRecord::Migration
  def self.up
	  # This migration's name is REALLY REALLY long. Enjoy.
	  change_column :categories, :can_have_items, :boolean, :default => false, :null => false

	  # Fix the states.
	  categories = Category.find(:all, :conditions => ["parent = ?", "537dfeba-1fbd-474f-beb2-737ac6e34fc4"])
	  categories.each do |cat|
		  cat.can_have_items = true
		  cat.save!
	  end
  end

  def self.down
  end
end
