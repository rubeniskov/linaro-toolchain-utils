TEST_UNITS ?= $(wildcard test/units/*.sh)


test:
		@for TEST_UNIT in ${TEST_UNITS}; do \
			$$(pwd)/$$TEST_UNIT;  \
		done


.PHONY: test
