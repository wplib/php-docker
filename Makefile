#
# Standard top level Makefile used to build a Docker container for WPLib - https://github.com/wplib/wplib-box/
# 

# VERSIONS = $(sort $(dir $(wildcard */)))
VERSIONS = 5.2.17 5.3.29 5.4.45 5.5.38 5.6.36 7.0.30 7.1.18 7.2.6

BASEDIR = $(shell pwd)

.PHONY: build push release clean list help

################################################################################
# Image related commands.

help:
	@cat README.md

build:
	@echo "Building for versions: $(VERSIONS)"
	$(foreach ver,$(VERSIONS), cd $(BASEDIR)/$(ver); make $@;)

push:
	@echo "Pushing to GitHub for versions: $(VERSIONS)"
	$(foreach ver,$(VERSIONS), cd $(BASEDIR)/$(ver); make $@;)

release:
	$(foreach ver,$(VERSIONS), cd $(BASEDIR)/$(ver); make $@;)

clean:
	@echo "Cleaning up for versions: $(VERSIONS)"
	$(foreach ver,$(VERSIONS), cd $(BASEDIR)/$(ver); make $@;)

list:
	@echo "Listing for versions: $(VERSIONS)"
	$(foreach ver,$(VERSIONS), cd $(BASEDIR)/$(ver); make $@;)

################################################################################
default: help

