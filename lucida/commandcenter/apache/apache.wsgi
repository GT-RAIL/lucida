python_home = '/usr/local/lucida/tools/python_2_7_12'
activate_this = python_home + '/bin/activate_this.py'
execfile(activate_this, dict(__file__=activate_this))

import sys
import os

import logging
logging.basicConfig(stream=sys.stderr) # to see output in apache logs

current_dir = os.path.abspath(os.path.dirname(__file__))
parent_dir = os.path.abspath(os.path.join(current_dir, "../"))
sys.path.insert(0, parent_dir)

# Load environment variables from a file which was saved by the shell.
with open(current_dir + "/envs.txt") as f:
   for line in f:
       os.environ[line.split("=")[0]] = line.split("=")[1][:-1]

from app import app as application
