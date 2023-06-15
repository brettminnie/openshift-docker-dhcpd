SHELL := /bin/bash
TAG = $(shell date +%Y%m%d)
CONTAINER_RUNTIME ?="podman"
IMAGE_NAME = mlocp/dhcpd
.PHONY: install_test_tools
install_test_tools:
	set -e; \
	GOSS_DST="/usr/bin" curl -fsSL https://goss.rocks/install | sudo sh

.PHONY: build_image
build_image:
	set -e; \
	${CONTAINER_RUNTIME} build -f Dockerfile -t registry.microlise.com/${IMAGE_NAME}:$(TAG) . ;\
	if [[ "${SKIP_GOSS}x" == "truex" ]]; then \
	  	echo "Skipping dgoss tests"; \
	else \
		CONTAINER_RUNTIME=${CONTAINER_RUNTIME} \
		GOSS_SLEEP=15 dgoss run \
		    --privileged \
			--net=host \
			registry.microlise.com/${IMAGE_NAME}:$(TAG); \
	fi

.PHONY: goss_test
goss_test:
	set -e; \
	CONTAINER_RUNTIME=${CONTAINER_RUNTIME} \
	GOSS_SLEEP=15 dgoss run \
		--privileged \
		--net=host \
		registry.microlise.com/${IMAGE_NAME}:$(TAG)

.PHONY: push_image
push_image:
	set -e; \
	${CONTAINER_RUNTIME} push registry.microlise.com/${IMAGE_NAME}:$(TAG); \
	${CONTAINER_RUNTIME} tag registry.microlise.com/${IMAGE_NAME}:$(TAG) registry.microlise.com/${IMAGE_NAME}:latest; \
	${CONTAINER_RUNTIME} push registry.microlise.com/${IMAGE_NAME}:latest

.PHONY: build_and_push
build_and_push: build_image push_image
