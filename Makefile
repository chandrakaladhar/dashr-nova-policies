# Uses a local `opa` if installed (brew install opa), otherwise the OPA image.
OPA_VERSION ?= 1.4.2
OPA ?= $(shell command -v opa 2>/dev/null || echo docker run --rm -v "$(CURDIR)":/src -w /src openpolicyagent/opa:$(OPA_VERSION))

.PHONY: fmt check test build
fmt:
	$(OPA) fmt --write policy

check:
	$(OPA) fmt --list --fail policy
	$(OPA) check --strict policy

test: check
	$(OPA) test policy --verbose
	$(OPA) test policy --coverage --threshold 100 > /dev/null

build: test
	$(OPA) build --bundle policy --ignore '*_test.rego' --revision dev --output bundle.tar.gz
