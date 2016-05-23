module darjeeling.assertion;

import std.stdio : writefln;

package void assertObjEquals(TLhs, TRhs)(TLhs expected, TRhs actual)
{
    if (expected != actual)
    {
        writefln("Expect: %s", expected);
        writefln("Actual: %s", actual);
        assert(false);
    }
}

package void assertEquals(T)(T expected, T actual)
{
    if (expected != actual)
    {
        writefln("Expect: %s", expected);
        writefln("Actual: %s", actual);
        assert(false);
    }
}

package void assertNotObjEquals(TLhs, TRhs)(TLhs expected, TRhs actual)
{
    if (expected == actual)
    {
        writefln("Expect: Not %s", expected);
        writefln("Actual:     %s", actual);
        assert(false);
    }
}

package void assertNotEquals(T)(T expected, T actual)
{
    if (expected == actual)
    {
        writefln("Expect: Not %s", expected);
        writefln("Actual:     %s", actual);
        assert(false);
    }
}

package Exception trap(TIn, TReturn)(TIn target, TReturn function(TIn) f)
{
    try
    {
        f(target);
    }
    catch (Exception ex)
    {
        return ex;
    }
    assert(false);
}