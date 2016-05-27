/**
 *          __                        __                  __     __
 *         / /                       /_/ _____            \ \   /_/
 *   _____/ / _____     __   ___    __  / ___ \  _____    / /  __  __  ___  _____
 *  / ___  / / ___ \    \ \_/__/   / / / _____/ / ___ \  / /  / / / /_/  / / ___ \
 * / /__/ / / /__/  \   / _/      / / / /__/ / / _____/ / /  / / / _/ / / / /__/ /
 * \_____/  \_____/\_\ /_/  __   / /  \_____/ / /__/ /  \_\ /_/ /_/  /_/ _\___  /
 *                         / /__/ /           \_____/                   / /__/ /
 *                         \_____/                                      \_____/
 *
 * A module for assertion functions
 *
 * Copyright: (C) Kazuhiro Matsushima 2016.
 * License:   <a href="http://www.boost.org/LICENSE_1_0.txt">Boost License 1.0</a>.
 * Authors:   Kazuhiro Matsushima
 */
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

package Throwable trap(TReturn)(TReturn function() f)
{
    try
    {
        f();
    }
    catch (Throwable th)
    {
        return th;
    }
    assert(false);
}

package Throwable trap(TIn, TReturn)(TIn target, TReturn function(TIn) f)
{
    try
    {
        f(target);
    }
    catch (Throwable th)
    {
        return th;
    }
    assert(false);
}