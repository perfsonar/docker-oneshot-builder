#
# Makefile for One-Shot Docker Builder
#
# Note that this is for development and container image builds.
#


# Set this to a Docker image to use something other than the default.
# CONTAINER_FROM := ghcr.io/perfsonar/unibuild/el9:latest

# Set this to clone a Git repo instead of using the provided example.
#CLONE := https://github.com/perfsonar/unibuild.git

# Example:  Build Unibuild.
# # CONTAINER_FROM := The default is fine.
# CLONE := https://github.com/perfsonar/unibuild.git
# # CLONE_BRANCH := Not Applicable


# Example:  Build pScheduler
#CONTAINER_FROM := ghcr.io/perfsonar/unibuild/el8:latest
#CLONE := https://github.com/perfsonar/pscheduler.git
#CLONE_BRANCH := 5.0.0


# ----- NO USER-SERVICEABLE PARTS BELOW THIS LINE -----

ifndef CONTANER_IMAGE
  CONTAINER_FROM=almalinux:8
endif


ifneq ($(shell id -u),0)
  DOCKER=sudo docker
else
  DOCKER=docker
endif


default: run


# Where the build happens.

BUILD_AREA := ./build-area
$(BUILD_AREA)::
	rm -rf "$@"
	mkdir -p "$@"
TO_CLEAN += $(BUILD_AREA)


ifdef CLONE
  BUILD_DIR := $(BUILD_AREA)/$(shell basename '$(CLONE)' .git)
  ifdef CLONE_BRANCH
    BRANCH_ARG := --branch '$(CLONE_BRANCH)'
  endif
else
  BUILD_DIR := $(BUILD_AREA)/test-product
endif
$(BUILD_DIR): $(BUILD_AREA)
ifdef CLONE
	git -C $(BUILD_AREA) clone $(BRANCH_ARG) "$(CLONE)"
else
	cp -r test-product "$(BUILD_AREA)"
endif



IMAGE := builder
CONTAINER_NAME := builder-test

default: run

BUILT := .built
ifdef CONTAINER_FROM
  IMAGE_ARG := --build-arg 'FROM=$(CONTAINER_FROM)'
endif
$(BUILT): prep Dockerfile Makefile
	$(DOCKER) build \
		$(IMAGE_ARG) \
		--tag $(IMAGE) \
		.
	touch $@
TO_CLEAN += $(BUILT)

image: $(BUILT)

BUILD_ARGS += \
	--name "$(CONTAINER_NAME)" \
	--absolute \
	"$(BUILD_DIR)" "$(IMAGE)"

# Show the command to run the container (for debug)
command::
	@./build --command $(BUILD_ARGS)


RUN_DEPS := $(BUILT) $(BUILD_DIR) build

# Run the container and exit
run: $(RUN_DEPS)
	./build $(BUILD_ARGS)


# Run the container but don't exit (for debug)
persist: $(RUN_DEPS)
	./build --no-halt $(BUILD_ARGS)


# Log into the persisted container
shell:
	$(DOCKER) exec -it "$(CONTAINER_NAME)" bash


# Stop the persisted container
halt:
	$(DOCKER) exec -it "$(CONTAINER_NAME)" halt


# Remove the container
rm:
	-$(DOCKER) exec -it "$(CONTAINER_NAME)" halt
	$(DOCKER) rm -f "$(CONTAINER_NAME)"


clean: rm
	make -C prep clean
	make -C test-product clean
	$(DOCKER) image rm -f "$(IMAGE)"
	rm -rf $(TO_CLEAN) *~
