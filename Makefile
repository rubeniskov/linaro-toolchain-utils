SHELL = /usr/bin/env bash
TEST_UNITS ?= $(wildcard test/units/*.sh)
TOOLCHAIN_RELEASE_URL = http://releases.linaro.org/components/toolchain/binaries/
TOOLCHAIN_RELEASE_LINKS_FILENAME ?= linaro_toolchain_release_links
TOOLCHAIN_GIST_HASH ?= d5c04095c41076c4dfe5273015c9a871
TOOLCHAIN_GIST_DESCRIPTION ?= Linaro Toolchain Releases Download URLs
WGET_PARALLEL_CORES ?= $(shell echo $$(($$(nproc 2>/dev/null|| sysctl -n hw.physicalcpu) * 32)))
WGET_FLAGS = \
		--delete-after \
		--domains="$(shell echo '$(TOOLCHAIN_RELEASE_URL)'|awk -F/ '{print $$3}')" \
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

deploy: deploy_release_links_file

deploy_release_links_file: create_release_links_file publish_release_links_file

create_release_links_file:
		@timestamp=$$(date +%s) && \
		echo "$(TOOLCHAIN_RELEASE_URL)" |\
		$(foreach DEPTH_LEVEL, 1 1 1, \
				xargs -n 1 -P $(WGET_PARALLEL_CORES) \
						wget $(WGET_FLAGS) --level=$(DEPTH_LEVEL) 2>&1 | $(WGET_PIPELINE) | ) \
		grep --line-buffered 'gcc-.*\.tar\.xz$$' | uniq | tee /dev/tty | sort > $(TOOLCHAIN_RELEASE_LINKS_FILENAME) \
		&& echo "Collect links took $$(($$(date +%s)-timestamp)) seconds"

publish_release_links_file:
ifeq ($(CREATE_GIST_TOKEN),)
		$(error CREATE_GIST_TOKEN is undefined)
else
		@cat $(TOOLCHAIN_RELEASE_LINKS_FILENAME) | awk '\
		BEGIN { \
			ORS = "";\
			print("{"); \
			printf("\"description\": \"%s\",", "$(TOOLCHAIN_GIST_DESCRIPTION)");\
			printf("\"public\": %s,", "true");\
			print("\"files\": {");\
			printf("\"%s\": {", "$(TOOLCHAIN_RELEASE_LINKS_FILENAME)");\
			print("\"content\": \"");\
		} { \
			printf("%s\\n", $$0);\
		} END { \
			print("\"}}}");\
		}' |\
		curl 'https://api.github.com/gists/$(TOOLCHAIN_GIST_HASH)?access_token=$(CREATE_GIST_TOKEN)' \
		--request POST \
		--header "Content-Type: application/json" \
		--data @- 2>/dev/null |\
		grep 'raw_url' |\
		awk -F'"' '{print "remote_url "$$4}'
endif

.PHONY: test
