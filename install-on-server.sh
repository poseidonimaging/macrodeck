#!/bin/bash
cd ~/macrodeck.com/public
./copy-dispatch.sh
cd ~/macrodeck.com/config
sed -e "s/^ENV/#ENV/" environment.rb > environment.rb
cd ~/macrodeck.com