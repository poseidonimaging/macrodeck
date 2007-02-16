class Subscription < ActiveRecord::Base
  def user
      User.find_by_uuid(self.user_uuid)
  end
  
  def service
      SubscriptionSrv.find_by_uuid(self.sub_service_uuid)
  end
  
  def check(user,service)
      find_by_user_uuid_and_sub_service_uuid(user,service)
  end
end
