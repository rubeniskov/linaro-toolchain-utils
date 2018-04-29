SHELL = /usr/bin/env bash
TEST_UNITS ?= $(wildcard test/units/*.sh)


VERSION ?=
CREATE_GIST_TOKEN ?=

RELEASE_LINKS_FILENAME ?= ltu_release_links
GIST_RELEASE_LINKS_HASH ?= d5c04095c41076c4dfe5273015c9a871
GIST_RELEASE_LINKS_DESCRIPTION ?= Linaro Toolchain Releases Download URLs

STANDALONE_FILENAME ?= ltu
GIST_STANDALONE_HASH ?= 79c6f105b4ab472472bdcbcb3bd7fde6
GIST_STANDALONE_DESCRIPTION ?= Linaro Toolchain Utils Standalone

TOOLCHAIN_RELEASE_URL = http://releases.linaro.org/components/toolchain/binaries/


define build_benchmark
		timestamp=$$(date +%s) && \
    $(1) \
		&& printf "Build took %d seconds\n" $$(($$(date +%s)-timestamp))
endef

define publish_gist
		cat $(1) |\
		awk -v description="$(2)" \
				-v filename="$(1)" \
				-f ./scripts/json-gist.awk |\
		curl 'https://api.github.com/gists/$(3)?access_token=$(CREATE_GIST_TOKEN)' \
		--request POST \
		--header "Content-Type: application/json" \
		--data @- 2>/dev/null |\
		grep 'raw_url' |\
		awk -F'"' '{print "remote_url "$$4}'
endef

define crawl
		echo '$(1)' |\
		$(foreach DEPTH_LEVEL, $(shell printf '1 %.0s' {1..$(2)}), \
				xargs -n 1 -P $(shell echo $$(($$(nproc 2>/dev/null|| sysctl -n hw.physicalcpu) * 32))) \
						wget \
							--delete-after \
							--level=$(DEPTH_LEVEL) \
							--domains="$(shell echo '$(1)'|awk -F/ '{print $$3}')" \
							--spider \
							--reject="css,js,jpg,jpeg,png,gif" \
							--force-html \
							--no-parent \
							--recursive \
							--random-wait \
							--limit-rate=20k \
							--execute="robots=off" \
							--user-agent="Googlebot/2.1 (+http://www.google.com/bot.html)" 2>&1 |\
						grep --line-buffered '^--' |\
						awk '{ print $$3 }' | uniq | ) \
		sort
endef

test: test_exec_units

deploy: build_release_links_file publish_release_links_file build_standalone publish_standalone

test_exec_units:
		@for TEST_UNIT in ${TEST_UNITS}; do \
			$$(pwd)/$$TEST_UNIT;  \
		done

build_standalone:
		@$(call build_benchmark, \
		echo "$(STANDALONE_FILENAME).sh" |\
				awk -v version="$(VERSION)" \
						-f ./scripts/concat.awk |\
				tee "$(STANDALONE_FILENAME)" |\
				bash -s help >/dev/null \
		&& chmod 755 "$(STANDALONE_FILENAME)" \
		&& curl -s https://raw.githubusercontent.com/precious/bash_minifier/master/minifier.py|\
				python - "$(STANDALONE_FILENAME)" > "$(STANDALONE_FILENAME)")

build_release_links_file:
		@$(call build_benchmark, \
				$(call crawl,$(TOOLCHAIN_RELEASE_URL),3) |\
						grep --line-buffered 'gcc-.*\.tar\.xz$$' |\
						tee "$(RELEASE_LINKS_FILENAME)" |\
						wc -l |\
						xargs printf "Links collected %s into $(RELEASE_LINKS_FILENAME)\n")

publish_standalone:
		@$(call publish_gist,$(STANDALONE_FILENAME),$(GIST_STANDALONE_DESCRIPTION),$(GIST_STANDALONE_HASH))

publish_release_links_file:
		@$(call publish_gist,$(RELEASE_LINKS_FILENAME),$(GIST_RELEASE_LINKS_DESCRIPTION),$(GIST_RELEASE_LINKS_HASH))

.PHONY: test
