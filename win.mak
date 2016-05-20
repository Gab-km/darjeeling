DMD = dmd
DFLAGS = -Isource -w -d -H

SRCS  = source/darjeeling/maybe.d

LIB   = darjeeling.lib

target:	$(LIB)

$(LIB):
	$(DMD) $(DFLAGS) -lib -of$(LIB) $(SRCS)

DUMMY_MAIN = empty_darjeeling_unittest.d

unittest:
	echo import darjeeling.maybe; void main(){} > $(DUMMY_MAIN)
	-$(DMD) $(DFLAGS) -unittest -of$(LIB) $(SRCS) -run $(DUMMY_MAIN)
	del $(DUMMY_MAIN)
