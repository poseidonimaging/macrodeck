#!/bin/sh

cd vendor/plugins/ && ./update-mdplatform.sh && cd macrodeck-platform && rake macrodeck:load_shipped_objects && cd ../../..
