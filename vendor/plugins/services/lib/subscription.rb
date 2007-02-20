class Subscription < ActiveRecord::Base
  def user
      User.find_by_uuid(self.user_uuid)
  end
  
  def service
      SubscriptionSrv.find_by_uuid(self.sub_service_uuid)
  end
  
  def Subscription.check(user,service)
      find_by_user_uuid_and_sub_service_uuid(user,service)
  end
  
  def Subscription.by_user(user)
      find_all_by_user_uuid(user)
  end
  
  def Subscription.update_billing_data(sub_uuid, updated_values)
      sub = find(sub_uuid)
      billing_data = YAML::load(sub.billing_data)
      billing_data.update(updated_values)
      sub.billing_data = billing_data.to_yaml
      sub.save
  end
end
