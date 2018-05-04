#!/bin/sh

# Source the lucida python virtualenv
source $LUCIDA_PYTHON_ENV/bin/activate 2> /dev/null || . $LUCIDA_PYTHON_ENV/bin/activate
exec "$@"
