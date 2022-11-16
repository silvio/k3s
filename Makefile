TARGETS := $(shell ls scripts | grep -v \\.sh)

.dapper:
	@echo Downloading dapper
	@curl -sL https://releases.rancher.com/dapper/v0.5.7/dapper-$$(uname -s)-$$(uname -m) > .dapper.tmp
	@@chmod +x .dapper.tmp
	@./.dapper.tmp -v
	@mv .dapper.tmp .dapper

$(TARGETS): .dapper
	./.dapper $@

.PHONY: deps
deps:
	go mod vendor
	go mod tidy

release:
	./scripts/release.sh

.DEFAULT_GOAL := ci

.PHONY: $(TARGETS)

build/data:
	mkdir -p $@

.PHONY: binary-size-check
binary-size-check:
	scripts/binary_size_check.sh

.PHONY: image-scan
image-scan:
	scripts/image_scan.sh $(IMAGE)

build-android: check-androidndk-setup
build-android: check-golang-setup
build-android: CGO_ENABLED=1
build-android: CC=$(shell ls -1 $(ANDROID_NDK_HOME)/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android*-clang | tail -n 1)
build-android: CXX=$(shell ls -1 $(ANDROID_NDK_HOME)/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android*-clang++ | tail -n 1)
build-android: STRIP=$(shell ls -1 $(ANDROID_NDK_HOME)/toolchains/llvm/prebuilt/linux-x86_64/bin/*strip* | tail -n 1)
build-android:
	go build
	$(STRIP k3s)

.PHONY: check-androidndk-setup
check-androidndk-setup:
	@if [ -z "$(ANDROID_NDK_HOME)" ]; then \
		echo ":: Error: setup your Android NDK and 'export' variable ANDROID_NDK_HOME to the home of this NDK)"; \
		false; \
	else \
		true; \
	fi

.PHONY: check-golang-setup
check-golang-setup:
	@if [ -z "$(shell go version 2>/dev/null)" ]; then \
		echo ":: Error: no go binary found"; \
		false; \
	else \
		true; \
	fi
