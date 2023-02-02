.PHONY: build-shunit2 shunit2

SHUNIT2_IMG ?= shunit2
SHUNIT2_VERSION ?= 0.1.0

TAG_NAME=$(SHUNIT2_IMG):$(SHUNIT2_VERSION)

build-shunit2:
	cd tests/sh && docker build -t $(TAG_NAME) -f Dockerfile.shunit2 ../..

shunit2: build-shunit2
	docker run -it $(TAG_NAME)
