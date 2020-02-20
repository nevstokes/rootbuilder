.PHONY: build-% help
.DEFAULT_GOAL := help

LTS = 2019.02.9
STABLE = 2019.11.1

# Disable all command echoing without requiring @ prefixes
ifndef VERBOSE
.SILENT:
endif

ifndef ANSI
ANSI := $(shell test $$(command -v tput >/dev/null 2>&1 && tput colors || echo 0) -ge 8 && echo 1)
endif

ifeq ($(ANSI),1)
STYLE_reset = \033[0m

STYLE__COLOR_red = 31
STYLE__COLOR_green = 32
STYLE__COLOR_yellow = 33
STYLE__COLOR_blue = 34
STYLE__COLOR_cyan = 36

STYLE__normal = 0
STYLE__bold = 1
STYLE__faint = 2
STYLE__italic = 3
STYLE__underline = 4

# Declare STYLE_* variants
__ := $(foreach color,red green yellow blue cyan, \
		$(eval STYLE_$(color)=\033[$(STYLE__normal);$(STYLE__COLOR_$(color))m) \
	;) \
	$(foreach style,normal bold faint italic underline, \
		$(eval STYLE_$(style)=\033[$(STYLE__$(style))m) \
	;) \
;)

STYLE_success = $(STYLE_green)
STYLE_info = $(STYLE_yellow)
STYLE_error = $(STYLE_red)
endif

define style #(text,style)
@printf "$(2)%s$(STYLE_reset)\n" $(1)
endef

##@ Images

BUILD_ARGS = BUILD_DATE="$(shell date -u +"%Y-%m-%dT%H:%M:%SZ")"
BUILD_ARGS += VCS_REF="$(shell git rev-parse --short HEAD)"
BUILD_ARGS += VCS_URL="$(shell git config --get remote.origin.url)"

build-lts: ## Build LTS version of Buildroot
	docker build \
		$(foreach BUILD_ARG,$(BUILD_ARGS),--build-arg $(BUILD_ARG)) \
		--build-arg BUILDROOT_VERSION=$(LTS) \
		--tag nevstokes/rootbuilder:$(LTS) \
		--tag nevstokes/rootbuilder:lts \
		.

build-stable: ## Build stable version of Buildroot
	docker build \
		$(foreach BUILD_ARG,$(BUILD_ARGS),--build-arg $(BUILD_ARG)) \
		--build-arg BUILDROOT_VERSION=$(STABLE) \
		--tag nevstokes/rootbuilder:$(STABLE) \
		--tag nevstokes/rootbuilder:stable \
		--tag nevstokes/rootbuilder:latest \
		.

##@ Utilities

# Inspired by https://suva.sh/posts/well-documented-makefiles/
help: ## Display this help
	awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make $(STYLE_cyan)<target>$(STYLE_reset)\n"} /^[a-zA-Z_-%]+:.*?##/ { printf "  $(STYLE_cyan)%-15s$(STYLE_reset) %s\n", $$1, $$2 } /^##@/ { printf "\n$(STYLE_bold)%s$(STYLE_reset)\n", substr($$0, 5) }' $(MAKEFILE_LIST)
