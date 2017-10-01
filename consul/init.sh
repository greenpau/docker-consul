#!/bin/sh

#
# Script options (exit script on command fail).
#
set -e

#
# Check configuration
#
consul validate /consul/config

#
# Start services.
#
COMMAND="/bin/consul agent -server -bootstrap-expect=1 -config-dir=/consul/config -data-dir=/consul/data"
echo "Starting consul ... "
exec ${COMMAND}
