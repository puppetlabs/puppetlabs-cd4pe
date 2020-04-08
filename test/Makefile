REGISTRY ?= artifactory.delivery.puppetlabs.net
TEST_IMAGE := $(REGISTRY)/cd4pe-config-test-vm:latest

.PHONY: build-test-image push-test-image

build-test-image:
	cp $(HOME)/.cdpe-workflow-tests-config.json ..
	docker build \
		--pull \
		--file Dockerfile \
		--tag $(TEST_IMAGE) \
		..
	rm ../.cdpe-workflow-tests-config.json

push-test-image:
	docker login https://$(REGISTRY)
	docker push $(TEST_IMAGE)
