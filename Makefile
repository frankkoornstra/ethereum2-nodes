# set all to phony
SHELL=bash

.PHONY: *

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(abspath $(patsubst %/,%,$(dir $(mkfile_path))))
user		:= $(shell id -u)

createGrpcTlsKeys:
	@echo "Detected your ip as $(ip)"
	@echo "Creating the private key"
	openssl genrsa -out $(current_dir)/secrets/tls/server.key 2048
	@echo "Creating the X509 certificate"
	openssl req -new -x509 -sha256 \
		-subj "/C=''/ST=''/L=''/O=''/CN=beacon" \
		-key $(current_dir)/secrets/tls/server.key \
		-out $(current_dir)/secrets/tls/server.crt -days 3650
	@echo "Creating the signing request"
	openssl req -new -sha256 \
		-subj "/C=''/ST=''/L=''/O=''/CN=beacon" \
		-key $(current_dir)/secrets/tls/server.key \
		-out $(current_dir)/secrets/tls/server.csr
	@echo "Signing the request"
	openssl x509 -req -sha256 \
		-in $(current_dir)/secrets/tls/server.csr \
		-signkey $(current_dir)/secrets/tls/server.key \
		-out $(current_dir)/secrets/tls/server.crt -days 3650

VALIDATOR_INSTANCE=1
VALIDATOR_PASSWORD=secret
createValidatorKey:
	@if ls ${current_dir}/secrets/keystore-${VALIDATOR_INSTANCE}/validatorprivatekey* 1> /dev/null 2>&1; \
		then echo "Keys already exist for instance ${VALIDATOR_INSTANCE}" && exit 1; \
		else echo "Keys don't exist yet, creating them"; fi
	docker-compose run validator-${VALIDATOR_INSTANCE} accounts create --keystore-path /secrets/keystore-${VALIDATOR_INSTANCE} --password ${VALIDATOR_PASSWORD} accounts create
	@if ls ${current_dir}/secrets/keystore-${VALIDATOR_INSTANCE}/validatorprivatekey* 1> /dev/null 2>&1; \
		then echo "Keys exist at ${current_dir}/secrets/keystore-${VALIDATOR_INSTANCE}/"; \
		else echo "KEYS ARE NOT CREATED OUTSIDE THE CONTAINER, DO NOT DEPOSIT!" && exit 1; fi

