#!/bin/sh

# Source the lucida python virtualenv
source $LUCIDA_PYTHON_ENV/bin/activate || . $LUCIDA_PYTHON_ENV/bin/activate
exec "$@"
