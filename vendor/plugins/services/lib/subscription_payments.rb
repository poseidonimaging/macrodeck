class SubscriptionPayment < ActiveRecord::Base
  def human_payment_date
      Time.at(self.payment_date)
  end
end
