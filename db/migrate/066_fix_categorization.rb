class FixCategorization < ActiveRecord::Migration
  def self.up
    say_with_time "Finding all cities and making all children have the same category" do
      City.find(:all).each do |c|
        say "City '#{c.title}', category '#{c.category}', migrating children objects"
        c.children.each do |child|
          say "Migrating '#{child.title}'"
          child.category = c.category
          child.save!
        end
      end
    end
    say_with_time "Finding all places and making all children have the same category" do
      Place.find(:all).each do |p|
        say "Place '#{p.title}', category '#{p.category}', migrating children objects"
        p.children.each do |child|
          say "Migrating '#{child.title}'"
          child.category = p.category
          child.save!
        end
      end
    end
    say_with_time "Finding all calendars and making all children have the same category" do
      Calendar.find(:all).each do |c|
        say "Calendar '#{c.title}', category '#{c.category}', migrating children objects"
        c.children.each do |child|
          say "Migrating '#{child.title}'"
          child.category = c.category
          child.save!
        end
      end
    end
  end

  def self.down
    # nothing to undo
  end
end
