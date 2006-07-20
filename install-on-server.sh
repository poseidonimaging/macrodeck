#!/bin/bash
cd ~/macrodeck.com/public
./copy-dispatch.sh
cd ~/macrodeck.com/config
sed -i -e "s/^ENV/#ENV/" environment.rb
cd ~/macrodeck.com