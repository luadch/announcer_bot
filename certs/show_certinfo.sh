#!/bin/sh
#
# show_certinfo.sh
#
#   - shows informations about the servercert.pem

openssl x509 -noout -in servercert.pem -issuer -subject -dates