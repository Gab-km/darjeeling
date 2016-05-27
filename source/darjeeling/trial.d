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
 * A module for results each of which is a value or an exception
 *
 * Copyright: (C) Kazuhiro Matsushima 2016.
 * License:   <a href="http://www.boost.org/LICENSE_1_0.txt">Boost License 1.0</a>.
 * Authors:   Kazuhiro Matsushima
 */
module darjeeling.trial;

import std.format : format;
import std.traits : fullyQualifiedName;
import darjeeling.either: Either;
import darjeeling.assertion;

/**
 * A interface to represent whether a value or an exception.
 *
 * Example:
 * -----
 * auto trial = Trial!int.trying({ return 9; });
 * if (trial.isSuccess)
 * {
 *     writeln(trial.get());
 * }
 * -----
 * Output:
 * -----
 * 9
 * -----
 */
interface Trial(T)
{
    /**
     * Return true if $(D this) is the Success!T instance, otherwise false.
     */
    @property bool isSuccess() nothrow pure @safe;

    /**
     * Return true if $(D this) is the Failure!T instance, otherwise false.
     */
    @property bool isFailure() nothrow pure @safe;

    /**
     * Return $(D value) if $(D this) is the Success!T instance,
     * otherwise throw Exception in the Failure!T instance.
     */
    T get() pure @safe;

    /**
     * Return Right!(Exception, T) value if $(D this) is the Success!T instance,
     * otherwise Left!(Exception, T) value.
     */
    Either!(Exception, T) getOrLeft() nothrow pure @safe;

    /**
     * A factory method to create Trial(T) instance.
     *
     * Params:
     *  expr = a function block to return T value, and it may also raise exception.
     *
     * Returns:
     *  A Success!T instance if (D_PARAM expr) is evaluated successfully,
     *  a Failure!T instance if (D_PARAM expr) raises an exception(not an error),
     *  otherwise raise an error.
     */
    static Trial!T trying(T function() expr) nothrow
    {
        try
        {
            auto value = expr();
            return new Success!T(value);
        }
        catch (Exception ex)
        {
            return new Failure!T(ex);
        }
    }
}

final class Success(T) : Trial!T
{
    private T value;

    package this(T value)
    {
        this.value = value;
    }

    @property bool isSuccess() nothrow pure @safe
    {
        return true;
    }

    unittest
    {
        auto success = new Success!int(9);
        assert(success.isSuccess);
    }

    @property bool isFailure() nothrow pure @safe
    {
        return !this.isSuccess;
    }

    unittest
    {
        auto success = new Success!string("success");
        assert(!success.isFailure);
    }

    T get() pure @safe
    {
        return this.value;
    }

    unittest
    {
        auto expected = 3.14;
        auto success = new Success!double(expected);
        auto actual = success.get();
        assertEquals(expected, actual);
    }

    Either!(Exception, T) getOrLeft() nothrow pure @safe
    {
        return Either!(Exception, T).right(this.value);
    }

    unittest
    {
        auto expected = 3.14;
        auto success = new Success!double(expected);
        auto actual = success.getOrLeft();
        assert(actual.isRight);
        assertEquals(expected, actual.right());
    }

    override string toString()
    {
        return format("Success!%s(%s)", fullyQualifiedName!T, this.value);
    }

    override bool opEquals(Object o)
    {
        if (typeid(o) == typeid(this))
        {
            auto other = cast(Success!T)(o);
            return this.value == other.value;
        }
        else
        {
            return false;
        }
    }
}

final class Failure(T): Trial!T
{
    private Exception exception;

    package this(Exception exception)
    {
        this.exception = exception;
    }

    @property bool isSuccess() nothrow pure @safe
    {
        return !this.isFailure;
    }

    unittest
    {
        auto failure = new Failure!int(new Exception("10"));
        assert(!failure.isSuccess);
    }

    @property bool isFailure() nothrow pure @safe
    {
        return true;
    }

    unittest
    {
        auto failure = new Failure!string(new Exception("failure"));
        assert(failure.isFailure);
    }

    T get() pure @safe
    {
        throw this.exception;
    }

    unittest
    {
        auto expected = new Exception("2.718");
        auto failure = new Failure!double(expected);
        auto actual = trap!(Failure!double, double)(failure, function(Failure!double fl) => fl.get());
        assertEquals(typeid(expected), typeid(actual));
        assertEquals(expected.msg, actual.msg);
    }

    Either!(Exception, T) getOrLeft() nothrow pure @safe
    {
        return Either!(Exception, T).left(this.exception);
    }

    unittest
    {
        auto expected = new Exception("2.718");
        auto failure = new Failure!double(expected);
        auto actual = failure.getOrLeft();
        assert(actual.isLeft);
        auto ex = actual.left();
        assertEquals(typeid(expected), typeid(ex));
        assertEquals(expected.msg, ex.msg);
    }

    override string toString()
    {
        return format("Failure!%s(%s(%s))", fullyQualifiedName!T, typeid(this.exception), this.exception.msg);
    }

    override bool opEquals(Object o)
    {
        if (typeid(o) == typeid(this))
        {
            auto other = cast(Failure!T)(o);
            return (typeid(this.exception) == typeid(other.exception))
                && (this.exception.msg == other.exception.msg);
        }
        else
        {
            return false;
        }
    }
}

unittest
{
    // Success(T)
    {
        Trial!int trial = Trial!int.trying(function int() { return -12; });
        assert(trial.isSuccess);
        assert(!trial.isFailure);
        auto success = trial.getOrLeft();
        assert(success.isRight);
        auto actual = success.right();
        assertEquals(-12, actual);
    }
    // Failure(T)
    {
        {
            Trial!int trial = Trial!int.trying(function int() { throw new Exception("hoge"); });
            assert(!trial.isSuccess);
            assert(trial.isFailure);
            auto success = trial.getOrLeft();
            assert(success.isLeft);
            auto actual = success.left();
            assertEquals(typeid(Exception), typeid(actual));
            assertEquals("hoge", actual.msg);
        }
        {
            auto actual = trap!(Trial!int)(function Trial!int(){
                return Trial!int.trying({
                    auto x = 1;
                    if (x > 0) throw new Error("It's error!");
                    return 1;
                });
            });
            auto expected = new Error("It's error!");
            assertEquals(typeid(expected), typeid(actual));
            assertEquals(expected.msg, actual.msg);
        }
    }
    // equality
    {
        {
            auto trial1 = Trial!int.trying({ return 0; });
            auto trial2 = Trial!int.trying({ return 0; });
            assertEquals(trial1, trial2);
        }
        {
            auto trial1 = Trial!int.trying({ return 1; });
            auto trial2 = Trial!int.trying({ return -1; });
            assertNotEquals(trial1, trial2);
        }
        {
            auto trial1 = Trial!short.trying(function short() { return 0; });
            auto trial2 = Trial!long.trying(function long() { return 0L; });
            assertNotObjEquals(trial1, trial2);
        }
        {
            auto trial1 = Trial!int.trying(function int() { throw new Exception("fail"); });
            auto trial2 = Trial!int.trying(function int() { throw new Exception("fail"); });
            assertEquals(trial1, trial2);
        }
        {
            auto trial1 = Trial!int.trying(function int() { throw new Exception("fail"); });
            auto trial2 = Trial!int.trying(function int() { throw new Exception("Fail"); });
            assertNotEquals(trial1, trial2);
        }
        {
            import core.exception : UnicodeException;

            auto trial1 = Trial!int.trying(function int() { throw new Exception("fail"); });
            auto trial2 = Trial!int.trying(function int() { throw new UnicodeException("fail", 0); });
            assertNotEquals(trial1, trial2);
        }
        {
            auto trial1 = Trial!string.trying(function string() { throw new Exception("fail"); });
            auto trial2 = Trial!double.trying(function double() { throw new Exception("fail"); });
            assertNotObjEquals(trial1, trial2);
        }
        {
            auto trial1 = Trial!int.trying({ return 0; });
            auto trial2 = Trial!int.trying({
                auto x = 1;
                if (x > 0) throw new Exception("positive");
                return x;
            });
            assertNotEquals(trial1, trial2);
        }
    }
}