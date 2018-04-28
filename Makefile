SHELL = /usr/bin/env bash
TEST_UNITS ?= $(wildcard test/units/*.sh)

RELEASE_LINKS_FILENAME ?= linaro_toolchain_release_links
GIST_RELEASE_LINKS_HASH ?= d5c04095c41076c4dfe5273015c9a871
GIST_RELEASE_LINKS_DESCRIPTION ?= Linaro Toolchain Releases Download URLs

STANDALONE_FILENAME ?= ltu
GIST_STANDALONE_HASH ?= 79c6f105b4ab472472bdcbcb3bd7fde6
GIST_STANDALONE_DESCRIPTION ?= Linaro Toolchain Utils Standalone

WGET_TOOLCHAIN_RELEASE_URL = http://releases.linaro.org/components/toolchain/binaries/
WGET_PARALLEL_CORES ?= $(shell echo $$(($$(nproc 2>/dev/null|| sysctl -n hw.physicalcpu) * 32)))
WGET_FLAGS = \
		--delete-after \
		--domains="$(shell echo '$(WGET_TOOLCHAIN_RELEASE_URL)'|awk -F/ '{print $$3}')" \
		--spider \
		--reject="css,js,jpg,jpeg,png,gif" \
		--force-html \
		--no-parent \
		--recursive \
		--random-wait \
		--limit-rate=20k \
		--execute="robots=off" \
		--user-agent="Googlebot/2.1 (+http://www.google.com/bot.html)"
WGET_PIPELINE = grep --line-buffered '^--' | awk '{ print $$3 }'


test:
		@for TEST_UNIT in ${TEST_UNITS}; do \
			$$(pwd)/$$TEST_UNIT;  \
		done

deploy: create_release_links_file publish_release_links_file create_standalone publish_standalone

create_standalone:
		@timestamp=$$(date +%s) && \
		echo "$(STANDALONE_FILENAME).sh"|awk -f ./scripts/concat.awk | tee "$(STANDALONE_FILENAME)" | bash -s help >/dev/null \
		&& chmod 755 "$(STANDALONE_FILENAME)" \
		&& echo "Build main file took $$(($$(date +%s)-timestamp)) seconds"

create_release_links_file:
		@timestamp=$$(date +%s) && \
		echo "$(WGET_TOOLCHAIN_RELEASE_URL)" |\
		$(foreach DEPTH_LEVEL, 1 1 1, \
				xargs -n 1 -P $(WGET_PARALLEL_CORES) \
						wget $(WGET_FLAGS) --level=$(DEPTH_LEVEL) 2>&1 | $(WGET_PIPELINE) | ) \
		grep --line-buffered 'gcc-.*\.tar\.xz$$' | sort -u | tee $(GIST_RELEASE_LINKS_FILENAME) | wc -l \
		&& echo "Collect links took $$(($$(date +%s)-timestamp)) seconds"

publish_standalone:
ifeq ($(CREATE_GIST_TOKEN),)
		$(error CREATE_GIST_TOKEN is undefined)
else
		@cat $(STANDALONE_FILENAME) |\
		awk -v description="$(GIST_STANDALONE_DESCRIPTION)" \
				-v filename="$(STANDALONE_FILENAME)" \
				-f ./scripts/json-gist.awk |\
		curl 'https://api.github.com/gists/$(GIST_STANDALONE_HASH)?access_token=$(CREATE_GIST_TOKEN)' \
		--request POST \
		--header "Content-Type: application/json" \
		--data @- 2>/dev/null |\
		grep 'raw_url' |\
		awk -F'"' '{print "remote_url "$$4}'
endif

publish_release_links_file:
ifeq ($(CREATE_GIST_TOKEN),)
		$(error CREATE_GIST_TOKEN is undefined)
else
		@cat $(RELEASE_LINKS_FILENAME) |\
		awk -v description="$(GIST_RELEASE_LINKS_DESCRIPTION)" \
				-v filename="$(RELEASE_LINKS_FILENAME)" \
				-f ./scripts/json-gist.awk |\
		curl 'https://api.github.com/gists/$(GIST_RELEASE_LINKS_HASH)?access_token=$(CREATE_GIST_TOKEN)' \
		--request POST \
		--header "Content-Type: application/json" \
		--data @- 2>/dev/null |\
		grep 'raw_url' |\
		awk -F'"' '{print "remote_url "$$4}'
endif

.PHONY: test
