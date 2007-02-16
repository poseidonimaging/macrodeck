class CreateSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :subscriptions do |t|
      t.column :uuid, :string
      t.column :user_uuid, :string
      t.column :sub_service_uuid, :string
      t.column :billing_data, :string
      t.column :creation, :integer
      t.column :updated, :integer
      t.column :status, :integer
    end
  end

  def self.down
    drop_table :subscriptions
  end
end
