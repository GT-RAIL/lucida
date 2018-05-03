SHELL:=/bin/bash

all:
	./install_kaldi.sh

start_master_server:
	gnome-terminal -x bash -c "source ${LUCIDA_PYTHON_ENV}/bin/activate && python kaldigstserver/master_server.py --port=8081; read -n1"

start_server:
	./simple_start.sh

start_test:
	gnome-terminal -x bash -c "source ${LUCIDA_PYTHON_ENV}/bin/activate && python kaldigstserver/client.py -r 8192 test/data/bill_gates-TED.mp3; read -n1"

.PHONY:	all start_server start_test
