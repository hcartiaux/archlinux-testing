#!/usr/bin/sed -f

/^## Worldwide$/,/^$/ s/^#Server/Server/
/^#/d
/^$/d
/^Server = http:/d
