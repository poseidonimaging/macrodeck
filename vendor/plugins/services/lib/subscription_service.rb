require 'payment/authorize_net'
require 'creditcard'
require 'digest/sha2'
require 'openssl'
require 'yaml'

# we will use SHA512 function
include Digest

class SubscriptionService < BaseService   
    
    STATUSPAID              = 10
    STATUSPAYMENTDUE        = 20
    STATUSSUSPEND           = 30
    STATUSCANCELED          = 40
    STATUSPARTIALPAYMENT    = 50

         
    # Create/edit/delete subscriptions
    # Create/edit/delete subscription services (i.e. things that users can subscribe to) 
    def SubscriptionService.createSubscriptionService(recurrence_info,sub_type,metadata,template)
        sub_service = SubscriptionSrv.new(metadata)
        sub_service.uuid = UUIDService.generateUUID
        
        sub_service.creation = Time.now.to_i
        sub_service.creator = metadata[:creator]
        sub_service.creator = NOBODY unless sub_service.creator
        
        sub_service.recurrence_info = Recurrence.new(recurrence_info)
        
        sub_service.notify_template = template if template
        
        sub_service.subscription_type = sub_type
        sub_service.subscription_type = ONETIME_PAYMENT unless sub_service.subscription_type
                
        sub_service.save 
        
    end
    
    def SubscriptionService.createSubscription(user_uuid, sub_service_uuid, billing_data, status)
        raise "User not found" unless User.checkUuid(user_uuid)
        raise "Subscription Service not found" unless SubscriptionSrv.checkUuid(user_uuid)
        sub = Subscription.new do
            self.creation = Time.new.to_i
            self.user_uuid = user_uuid
            self.sub_service_uuid = sub_service_uuid
            self.status = status
            self.updated = self.creation
            self.uuid = UUIDService.generateUUID
        end
        sub.save
        sub.uuid        
    end
    
    def SubscriptionService.deleteSubscriptionService(uuid)
        sub_srv = SubscriptionSrv.find_by_uuid(uuid)
        raise_no_record(uuid)
        if sub_srv.subscriptions.empty?
            sub_srv.destroy
        else
            raise "you must delete all subscription for this service before"
        end
    end
    
    def SubscriptionService.deleteSubscription(uuid)
        sub = Subscription.find_by_uuid(uuid)
        raise_no_record(uuid,1)
        sub.destroy
    end

    def SubscriptionService.editSubscriptionService(uuid,updated_attributes)
        sub_srv = SubscriptionSrv.find_by_uuid(uuid)
        raise_no_record(uuid) 
        sub_srv.update_attributes(updated_attributes)       
    end
    
    def SubscriptionService.editSubscription(uuid,updated_attributes)
        sub = SubscriptionSrv.find_by_uuid(uuid)
        SubscriptionSrv.raise_no_record(uuid,1) 
        sub.update_attributes(updated_attributes)       
    end
    
    def SubscriptionService.makePayment(user_uuid, auth_data, amount, card_number, expiration)
        user = User.find_by_uuid(user_uuid)
        User.raise_no_record(uuid)
        
        # FIXME: test and update this fragment
        transaction = Payment::AuthorizeNet.new(
          :login       => auth_data[:username],
          :password    => auth_data[:password],
          :amount      => amount,
          :card_number => card_number,
          :expiration  => expiration
        )
        begin
          transaction.submit
          
        rescue
          return false
        end
    end
    
#    Is this method really useful?
#
#    def SubscriptionService.encryptCardForSubscription(subscription_uuid,last_four_digits,password)                
#        sub = Subscription.find_by_uuid(subscription_uuid)
#        Subscription.raise_no_record(subscription_uuid)
#        billing_data = YAML::load(sub.billing_data)             
#        random_string_of_characters = (1..20).collect { (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }.join
#        billing_data[:entropy] = random_string_of_characters
#        digest = SHA512.hexdigest(billing_data[:entropy] + ":" + last_four_of_card + ":" + password)
#        cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
#        cipher.encrypt
#        cipher.key = digest
#        cipher.iv = billing_data[:iv] = cipher.random_iv
#        card_number = c.update(billing_data[:plain_card_number])
#        billing_data[:card_number] = card_number << cipher.final
#        sub.billing_data = billing_data.to_yaml
#        sub.save
#        
#    end
 
    def SubscriptionService.decryptCard(subscription_uuid, last_four_digits,password)
        sub = Subscription.find_by_uuid(subscription_uuid)
        Subscription.raise_no_record(subscription_uuid)
        billing_data = YAML::load(sub.billing_data)
        digest = SHA512.hexdigest(billing_data[:entropy] + ":" + last_four_of_card + ":" + password)
        cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
        cipher.decrypt
        cipher.key = digest
        cipher.iv = billing_data[:iv]
        card_number = c.update(billing_data[:card_number])
        card_number << cipher.final
        checkCard(card_number)
    end
    
    # Include a method for seeing if a user is subscribed to a particular subscription service
    def SubscriptionService.isUserSubscribedTo?(user_uuid, service_uuid)   
        sub = Subscription.check(user_uuid, service_uuid)
        !sub.nil?
    end
    
    def SubscriptionService.isUserPaidFor?(user_uuid,service_uuid)
        sub = Subscription.check(user_uuid, service_uuid)
        billing_data = YAML::load(sub.billing_data)
        last_payment = SubscriptionPayment.lastPaymentFor(user_uuid,sub.uuid)
        {
          :status => sub.status,
          :debt =>billing_data[:debt],
          :last_payment_amount => last_payment.amount_paid,
          :last_payment_date => last_payment.human_payment_date
        }
    end
    
    def SubscriptionService.changeSubscriptionPassword(last4,oldpassword,newpassword)
      # testing - in progress 
    end
    
    def SubscriptionService.viewInvoice
      # return PDF Invoice (in progress) or simple hash? 
    end
    
    # use rubygem creditcard
    def SubscriptionService.checkCard(card_number)
        {
          card_number.creditcard?,
          card_number.creditcard_type
        }
    end
        
end