#
# Makefile for One-Shot Docker Builder
#
# Note that this is for development and container image builds.
#


# Set this to a Docker image to use something other than the default.
# CONTAINER_IMAGE := ghcr.io/perfsonar/unibuild/el9:latest

# Set this to clone a Git repo instead of using the provided example.
#CLONE := https://github.com/perfsonar/unibuild.git

# Example:  Build Unibuild.
# # CONTAINER_IMAGE := The default is fine.
# CLONE := https://github.com/perfsonar/unibuild.git
# # CLONE_BRANCH := Not Applicable


# Example:  Build pScheduler
#CONTAINER_IMAGE := ghcr.io/perfsonar/unibuild/el8:latest
#CLONE := https://github.com/perfsonar/pscheduler.git
#CLONE_BRANCH := 5.0.0


# ----- NO USER-SERVICEABLE PARTS BELOW THIS LINE -----


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
CONTAINER := builder-test

default: run

BUILT := .built
ifdef CONTAINER_IMAGE
  IMAGE_ARG := --build-arg 'FROM=$(CONTAINER_IMAGE)'
endif
$(BUILT): Makefile prep service Dockerfile entry $(MAKEFILE)
	docker build \
		$(IMAGE_ARG) \
		-t $(IMAGE) \
		.
	touch $@
TO_CLEAN += $(BUILT)

container: $(BUILT)

DOCKER_ARGS :=

# TODO: Need to deal with this automagically for other systems.
# This is for EL8.
#  - macOS:
#    DOCKER_ARGS + --privileged
#  - Linux CGROUPS v1 (EL7, EL8):
    DOCKER_ARGS += --privileged
#  - Linux CGROUPS v2 (EL9; V2 is if /sys/fs/cgroup/cgroup.controllers exists):
#    DOCKER_ARGS += --volume /sys/fs/cgroup:/sys/fs/cgroup:ro

#
# Note that this exits with a 130 for a normal halt.

# Define this to prevent the container from halting when done.
ifdef NO_HALT
  DOCKER_ARGS += --env BUILD_NO_HALT=1
endif

run: $(BUILT) $(BUILD_DIR)
	docker run \
		--name "$(CONTAINER)" \
		--tty \
		--tmpfs /tmp \
		--tmpfs /run \
		--volume "$(BUILD_DIR):/build" \
		--rm \
		$(DOCKER_ARGS) \
		"$(IMAGE)" \
	|| STATUS=$$? ; \
	if [ $$STATUS -eq 0 -o $$STATUS -eq 130 ]; then \
		true ; \
	else \
		echo "Exited $$STATUS" ; \
		false ; \
	fi


halt:
	docker exec -it "$(CONTAINER)" halt

rm:
	-docker exec -it "$(CONTAINER)" halt
	docker rm -f "$(CONTAINER)"


shell:
	docker exec -it "$(CONTAINER)" bash


clean: rm
	make -C prep clean
	make -C service clean
	make -C test-product clean
	docker image rm -f "$(IMAGE)"
	rm -rf $(TO_CLEAN) *~