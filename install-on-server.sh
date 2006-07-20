#!/bin/sh
cd public
sh copy-dispatch.sh
cd ..
cd config
sed -e "s/^ENV['RAILS_ENV']/#ENV['RAILS_ENV']/" environment.rb > environment.rb
cd ..