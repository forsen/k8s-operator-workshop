SHELL = bash
.DEFAULT_GOAL = build

$(shell mkdir -p bin)
export GOBIN = $(realpath bin)
export PATH := $(GOBIN):$(PATH)
export OS   := $(shell if [ "$(shell uname)" = "Darwin" ]; then echo "darwin"; else echo "linux"; fi)
export ARCH := $(shell if [ "$(shell uname -m)" = "x86_64" ]; then echo "amd64"; else echo "arm64"; fi)

# Extracts the version number for a given dependency found in go.mod.
# Makes the test setup be in sync with what the operator itself uses.
extract-version = $(shell cat go.mod | grep $(1) | awk '{$$1=$$1};1' | cut -d' ' -f2 | sed 's/^v//')

#### TOOLS ####
TOOLS_DIR                          := $(PWD)/.tools
KIND                               := $(TOOLS_DIR)/kind
KIND_VERSION                       := v0.25.0
CHAINSAW_VERSION                   := $(call extract-version,github.com/kyverno/chainsaw)
CONTROLLER_GEN_VERSION             := $(call extract-version,sigs.k8s.io/controller-tools)
PROMETHEUS_VERSION                 := 0.78.2

#### VARS ####
K8S_CONTEXT                ?= kind-$(KIND_CLUSTER_NAME)
KUBERNETES_VERSION          = 1.31.2
KIND_IMAGE                 ?= kindest/node:v$(KUBERNETES_VERSION)
KIND_CLUSTER_NAME          ?= workshop

.PHONY: generate
generate:
	go install sigs.k8s.io/controller-tools/cmd/controller-gen@v${CONTROLLER_GEN_VERSION}
	go generate ./...

.PHONY: build
build: generate
	go build \
	-tags osusergo,netgo \
	-trimpath \
	-ldflags="-s -w" \
	-o ./bin/bekk-ws-operator \
	./cmd/bekk-ws-operator

.PHONY: run-local
run-local: build install-operator
	kubectl --context ${K8S_CONTEXT} apply -f config/ --recursive
	./bin/bekk-ws-operator

.PHONY: setup-local
setup-local: kind-cluster install-prometheus-crds install-operator
	@echo "Cluster $(K8S_CONTEXT) is setup"


#### KIND ####

.PHONY: kind-cluster check-kind
check-kind:
	@which kind >/dev/null || (echo "kind not installed, please install it to proceed"; exit 1)

.PHONY: kind-cluster
kind-cluster: check-kind
	@echo Create kind cluster... >&2
	@kind create cluster --image $(KIND_IMAGE) --name ${KIND_CLUSTER_NAME}


#### OPERATOR DEPENDENCIES ####

.PHONY: install-prometheus-crds
install-prometheus-crds:
	@echo "Installing prometheus crds"
	@kubectl apply -f https://github.com/prometheus-operator/prometheus-operator/releases/download/v$(PROMETHEUS_VERSION)/stripped-down-crds.yaml --context $(K8S_CONTEXT)

.PHONY: install-operator
install-operator: generate
	@kubectl create namespace bekk-ws-operator-system --context $(K8S_CONTEXT) || true
	@kubectl apply -f config/ --recursive --context $(K8S_CONTEXT)

.PHONY: install-test-tools
install-test-tools:
	go install github.com/kyverno/chainsaw@v${CHAINSAW_VERSION}

#### TESTS ####
.PHONY: test-single
test-single: install-test-tools install-operator
	@./bin/chainsaw test --kube-context $(K8S_CONTEXT) --config tests/config.yaml --test-dir $(dir) && \
    echo "Test succeeded" || (echo "Test failed" && exit 1)

.PHONY: test
test: install-test-tools install-operator
	@./bin/chainsaw test --kube-context $(K8S_CONTEXT) --config tests/config.yaml --test-dir tests/ && \
    echo "Test succeeded" || (echo "Test failed" && exit 1)

.PHONY: run-unit-tests
run-unit-tests:
	@failed_tests=$$(go test ./... 2>&1 | grep "^FAIL" | awk '{print $$2}'); \
		if [ -n "$$failed_tests" ]; then \
			echo -e "\033[31mFailed Unit Tests: [$$failed_tests]\033[0m" && exit 1; \
		else \
			echo -e "\033[32mAll unit tests passed\033[0m"; \
		fi

.PHONY: run-test
run-test: build
	@echo "Starting operator in background..."
	@LOG_FILE=$$(mktemp -t operator-test.XXXXXXX); \
	./bin/bekk-ws-operator > "$$LOG_FILE" 2>&1 & \
	PID=$$!; \
	echo "operator PID: $$PID"; \
	echo "Log redirected to file: $$LOG_FILE"; \
	( \
		if [ -z "$(TEST_DIR)" ]; then \
			$(MAKE) test; \
		else \
			$(MAKE) test-single dir=$(TEST_DIR); \
		fi; \
	) && \
	(echo "Stopping operator (PID $$PID)..." && kill $$PID && echo "running unit tests..." && $(MAKE) run-unit-tests)  || (echo "Test or operator failed. Stopping operator (PID $$PID)" && kill $$PID && exit 1)
