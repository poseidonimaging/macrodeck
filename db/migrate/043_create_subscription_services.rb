class CreateSubscriptionServices < ActiveRecord::Migration
  def self.up
    create_table :subscription_services do |t|
      t.column :uuid, :string
      t.column :subscription_type, :string
      t.column :provider_uuid, :string    
      t.column :title, :string    
      t.column :description, :text
      t.column :creator, :string
      t.column :creation, :integer
      t.column :updated, :integer
      t.column :amount, :double
      t.column :recurrence, :integer
      t.column :recurrence_day, :integer
      t.column :recurrence_notify, :integer
      t.column :notify_template, :text        
    end
  end

  def self.down
    drop_table :subscription_services
  end
end
