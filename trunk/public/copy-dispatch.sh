#!/bin/sh
rm -f dispatch.fcgi dispatch.cgi
cp dispatch.cgi.unix dispatch.cgi
cp dispatch.fcgi.unix dispatch.fcgi
cd ..
chmod -R u+rwX,go-w public log
cd public