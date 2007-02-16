class CreateSubscriptionPayments < ActiveRecord::Migration
  def self.up
    create_table :subscription_payments do |t|
      t.column :uuid, :string
      t.column :user_uuid, :string
      t.column :subscription_uuid, :string
      t.column :amount_paid, :double
      t.column :date_paid, :integer
    end
  end

  def self.down
    drop_table :subscription_payments
  end
end
