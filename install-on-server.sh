#!/bin/bash
cd ~/macrodeck.com/public
./copy-dispatch.sh
cd ~/macrodeck.com/config
sed -e "s/^ENV['RAILS_ENV']/#ENV['RAILS_ENV']/" environment.rb > environment.rb
cd ~/macrodeck.com