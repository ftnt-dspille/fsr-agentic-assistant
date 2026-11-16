# fsr-agentic-assistant monorepo: thin dispatcher over the two trees.
#   framework/  fsr_playbooks (PyPI: fsr-playbooks)      -> `make fw-<target>`
#   connector/  the FortiSOAR connector + dev loop         -> `make conn-<target>`
# Day-to-day connector/box targets are forwarded unprefixed (make loop BOX=<alias>);
# `make help` lists everything the connector knows. One branch, one stamp, one promote.
.DEFAULT_GOAL := help
ROOT := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
FW   := $(ROOT)/framework
CONN := $(ROOT)/connector

# Every connector target that reaches a box, plus the everyday gates.
CONN_FORWARD := help setup test loop doctor deploy ship ship-noverify dev-push ship-dev ship-dev-status ship-dev-restore \
  bump-framework live quick-live warmup health ssh workers logs session-health matrix tool-sweep local-turn
.PHONY: $(CONN_FORWARD) verify release fw-% conn-% test-all help-mono

help-mono: ## this dispatcher
	@sed -n 's/^\([a-z-]*%*\):.*## \(.*\)$$/  \1\t\2/p' $(lastword $(MAKEFILE_LIST))

$(CONN_FORWARD):
	@$(MAKE) --no-print-directory -C $(CONN) $@

fw-%:
	@$(MAKE) --no-print-directory -C $(FW) $*

conn-%:
	@$(MAKE) --no-print-directory -C $(CONN) $*

verify: ## framework suites (lint, types, pkg, tooling) THEN the connector suite, same commit, editable framework
	@bash "$(ROOT)/scripts/verify.sh"

release: ## cut a framework release (PyPI) and ship the connector against it: make release VERSION=X.Y.Z (owner only)
	@[ -n "$(VERSION)" ] || { echo "usage: make release VERSION=X.Y.Z [NOTES=...]   (agents need CONFIRM_DEPLOY=1)"; exit 2; }
	@$(MAKE) --no-print-directory -C $(CONN) deploy FW=$(VERSION) $(if $(BUMP),BUMP=$(BUMP),) $(if $(NOTES),NOTES="$(NOTES)",)
