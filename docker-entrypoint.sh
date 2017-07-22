#!/bin/bash

set -e -o pipefail

source docker-utils.sh

# Make /var/mail writable by all 'users'
# Note this cannot be done at build time,
# because the volume is created at runtime
install -d -m 1777 /var/mail

# Copied from Postgres Docker Entry Script
# https://github.com/docker-library/postgres/blob/master/docker-entrypoint.sh
#
# Make this image extensible
echo "Running extension configuration/scripts"
for f in /docker-entry.d/*; do
    case "$f" in
        *.sh)
                echo "$0: executing shell script - $f";
                . "$f" ;;
        local.conf)
                echo "$0: local.conf file provided. Copying to /etc/dovecot/";
                cp $f /etc/dovecot/ ;;
        *.conf)
                echo "$0: copying conf file '$f' to /etc/dovecot/conf.d/"
                cp $f /etc/dovecot/conf.d/ ;;
        /docker-entry.d/*) ;;
        *)      echo "$0: ignoring $f -- don't know how to process it" ;;
    esac
done
echo "Complete"
echo

if [ "$1" = "dovecot" ]; then
    echo "##################################"
    echo "Start of Non-Default Configuration"
    echo "##################################"
    doveconf -n
    echo "################################"
    echo "End of Non-Default Configuration"
    echo "################################"
    echo
else
    echo "Executing custom command, so skipping Doveconf configuration dump"
    echo
fi

# Replace this entry point script process with the desired program
echo "End of Entrypoint script. Executing $@"
echo
exec "$@"
