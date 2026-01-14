#
# Build and test a perfSONAR test point
#
# From a Docker host, execute 'make run'.
#

# Override this on the command line if desired.
OS=el7

# Install staging repository.  Override this on the command line if desired.
# TODO: This won't actually work until make args can be passed into the container.
# STAGING=1


CONTAINER_NAME=testpoint-test


#
# These targets are built inside the container
#

# Figure out if we're on EL, Debian or Ubuntu

ifneq ($(wildcard /etc/redhat-release),)
  TO_BUILD := el
else ifneq ($(wildcard /etc/debian_version),)
  TO_BUILD := debuntu
  ifeq ($(shell awk -F= '$$1 == "DISTRIB_ID" { print $$2 }' /etc/lsb-release),Ubuntu)
    UBUNTU := 1
  endif
endif


default: $(TO_BUILD)
	pscheduler troubleshoot


# Build for Debian and Ubuntu

# This is a hack to get the services to start properly.
# See http://jpetazzo.github.io/2013/10/06/policy-rc-d-do-not-start-services-automatically
policy-rc-d-hack::
	sudo sh -c 'printf "exit 0\n" > /usr/sbin/policy-rc.d'
	sudo chmod +x /usr/sbin/policy-rc.d

APT_Y := DEBIAN_FRONTEND=noninteractive sudo --preserve-env=DEBIAN_FRONTEND apt-get -y
debuntu: policy-rc-d-hack
	sudo curl -o /etc/apt/sources.list.d/perfsonar-release.list \
		http://downloads.perfsonar.net/debian/perfsonar-release.list
	curl http://downloads.perfsonar.net/debian/perfsonar-official.gpg.key \
		| sudo apt-key add -
  ifdef UBUNTU
	$(APT_Y) install software-properties-common
	sudo add-apt-repository universe
  endif
  ifdef STAGING
	curl -o /etc/apt/sources.list.d/perfsonar-minor-staging.list \
		http://downloads.perfsonar.net/debian/perfsonar-minor-staging.list
	curl http://downloads.perfsonar.net/debian/perfsonar-snapshot.gpg.key | apt-key add -
  endif
	$(APT_Y) update
	$(APT_Y) install perfsonar-testpoint < /dev/null


# Build for EL

PERFSONAR_RPM_REPO := http://software.internet2.edu/rpms/$(OS)/x86_64/latest/packages/perfSONAR-repo-0.10-1.noarch.rpm
el:
	sudo dnf -y install epel-release
	rpm -q perfSONAR-repo > /dev/null 2>&1 \
		|| sudo dnf -y install $(PERFSONAR_RPM_REPO)
ifdef STAGING
	@printf "\n\nInstalling staging repo\n\n"
	sudo dnf -y install perfSONAR-repo-staging
endif
	sudo dnf -y makecache
	sudo dnf -y update
	sudo dnf -y install perfsonar-testpoint


#
# These targets are for use outside the container
#

run:
	curl -s https://raw.githubusercontent.com/perfsonar/docker-oneshot-builder/main/build \
		| sh -s - --name "$(CONTAINER_NAME)" . $(OS)

shell:
	docker exec -it "$(CONTAINER_NAME)" bash

halt:
	docker rm -f "$(CONTAINER_NAME)"

clean:
	rm -rf $(TO_CLEAN) DOSB *~

