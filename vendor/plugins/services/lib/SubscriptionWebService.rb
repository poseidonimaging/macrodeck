class SubscriptionServiceAPI < ActionWebService::API::Base
end

class SubscriptionWebService < ActionWebService::Base
	web_service_api SubscriptionServiceAPI
	
end	

