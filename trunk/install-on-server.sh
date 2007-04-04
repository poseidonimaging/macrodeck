#!/bin/bash
cd ~/macrodeck.com/public
./copy-dispatch.sh
cd ~/macrodeck.com/config
sed -i -e "s/^ENV/#ENV/" environment.rb
cd ~/macrodeck.com
# next, kill TestController and associated views
rm -rf ~/macrodeck.com/app/views/test
rm -f ~/macrodeck.com/app/controllers/test_controller.rb
rm -f ~/macrodeck.com/app/helpers/test_helper.rb

# create a copy of services_controller.rb
cp ~/macrodeck.com/vendor/plugins/services/lib/services_controller.rb ~/macrodeck.com/app/controllers/services_controller.rb