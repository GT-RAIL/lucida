"""
Weather API configuration details
"""

import os
import sys
import ConfigParser

class FakeSecHead(object):
    def __init__(self, fp):
        self.fp = fp
        self.sechead = '[asection]\n'

    def readline(self):
        if self.sechead:
            try:
                return self.sechead
            finally:
                self.sechead = None
        else:
            return self.fp.readline()

cp = ConfigParser.SafeConfigParser()
cp.readfp(FakeSecHead(open(os.getenv("LUCIDA_ROOT") + "/config.properties")))
port_dic = dict(cp.items('asection'))
PORT = int(port_dic['we_port'])

# Weather Underground API key
# https://www.wunderground.com/weather/api/
WU_API_URL_BASE = 'http://api.wunderground.com/api/'
WU_API_KEY = os.getenv('WU_API_KEY') # add your API key here

# Open Weather Map API key
# https://openweathermap.org/api
OWM_API_URL_BASE = 'http://api.openweathermap.org/data/2.5/weather?'
OWM_API_KEY = os.getenv('OWM_API_KEY') # add your API key here
