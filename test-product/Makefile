#
# Test Makefile
#

default: build


# In case someone builds this copy.
TO_CLEAN += DOSB

# What we build
a-file::
	touch "$@"
TO_CLEAN += a-file


build:: a-file


clean:
	rm -rf $(TO_CLEAN) *~
