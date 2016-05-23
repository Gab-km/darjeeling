/**
 * A module for optional values
 *
 * Copyright: (C) Kazuhiro Matsushima 2016.
 * License:   <a href="http://www.boost.org/LICENSE_1_0.txt">Boost License 1.0</a>.
 * Authors:   Kazuhiro Matsushima
 */
module darjeeling.maybe;

import std.format : format;
import std.traits : fullyQualifiedName;
import darjeeling.assertion;

/**
 * A interface to represent an optional value.
 *
 * Example:
 * -----
 * auto maybe = Maybe!int.just(42);
 * if (maybe.isJust)
 * {
 *     writeln(maybe.fromJust());
 * }
 * -----
 * Output:
 * -----
 * 42
 * -----
 */
interface Maybe(T)
{
    /**
     * Return true if $(D this) is the Just!T instance, otherwise false.
     */
    @property bool isJust() nothrow pure @safe;

    /**
     * Return true if $(D this) is the Nothing!T instance, otherwise false.
     */
    @property bool isNothing() nothrow pure @safe;

    /**
     * Return $(D value) if $(D this) is the Just!T instance, otherwise throw Exception.
     */
    T fromJust() pure @safe;

    /**
     * A factory method to create Just(T) instance.
     *
     * Params:
     *  value = a T value to contain
     *
     * Returns:
     *  A Just!T instance which has $(D_PARAM value).
     */
    static Maybe!T just(T value) nothrow pure @safe
    {
        return new Just!T(value);
    }

    /**
     * A factory method to create Nothing(T) instance.
     *
     * Returns:
     *  A Nothing!T instance.
     */
    static Maybe!T nothing() nothrow pure @safe
    {
        return new Nothing!T();
    }
}

final class Just(T) : Maybe!T
{
    private T value;

    package this(T value) nothrow pure @safe
    {
        this.value = value;
    }

    @property bool isJust() nothrow pure @safe
    {
        return true;
    }

    unittest
    {
        auto just = new Just!int(2);
        assert(just.isJust);
    }

    @property bool isNothing() nothrow pure @safe
    {
        return !this.isJust;
    }

    unittest
    {
        auto just = new Just!string("hoge");
        assert(!just.isNothing);
    }

    T fromJust() nothrow pure @safe
    {
        return this.value;
    }

    unittest
    {
        auto expected = 3;
        auto just = new Just!int(expected);
        auto actual = just.fromJust();
        assertEquals(expected, actual);
    }

    override string toString()
    {
        return format("Just!%s(%s)", fullyQualifiedName!T, this.value);
    }

    override bool opEquals(Object o)
    {
        if (typeid(o) == typeid(this))
        {
            auto other = cast(Just!T)(o);
            return this.value == other.value;
        }
        else
        {
            return false;
        }
    }
}

final class Nothing(T) : Maybe!T
{
    package this() nothrow pure @safe {}

    @property bool isJust() nothrow pure @safe
    {
        return !this.isNothing();
    }

    unittest
    {
        auto nothing = new Nothing!string();
        assert(!nothing.isJust);
    }

    @property bool isNothing() nothrow pure @safe
    {
        return true;
    }

    unittest
    {
        auto nothing = new Nothing!int();
        assert(nothing.isNothing);
    }

    T fromJust() pure @safe
    {
        throw new Exception("Invalid operation: Nothing(T) cannot return its value.");
    }

    unittest
    {
        auto nothing = new Nothing!string();
        auto ex = trap!(Nothing!string, string)(nothing, function(Nothing!string n) => n.fromJust());
        auto expected = "Invalid operation: Nothing(T) cannot return its value.";
        assertEquals(expected, ex.msg);
    }

    override string toString()
    {
        return format("Nothing!%s", fullyQualifiedName!T);
    }

    override bool opEquals(Object o)
    {
        return (typeid(o) == typeid(this));
    }
}

unittest
{
    // Just(T)
    {
        auto expected = 2;
        Maybe!int just = Maybe!int.just(expected);
        assert(just.isJust);
        assert(!just.isNothing);
        auto actual = just.fromJust();
        assertEquals(expected, actual);
    }
    // Nothing(T)
    {
        Maybe!string nothing = Maybe!string.nothing();
        assert(!nothing.isJust);
        assert(nothing.isNothing);
    }
    // Equality
    {
        {
            auto maybe1 = Maybe!int.just(1);
            auto maybe2 = Maybe!int.just(1);
            assertEquals(maybe1, maybe2);
        }
        {
            auto maybe1 = Maybe!string.just("hoge");
            auto maybe2 = Maybe!string.just("fuga");
            assertNotEquals(maybe1, maybe2);
        }
        {
            auto maybe1 = Maybe!short.just(1);
            auto maybe2 = Maybe!long.just(1);
            assertNotObjEquals(maybe1, maybe2);
        }
        {
            auto maybe1 = Maybe!int.just(1);
            auto maybe2 = Maybe!int.nothing();
            assertNotEquals(maybe1, maybe2);
        }
        {
            auto maybe1 = Maybe!string.nothing();
            auto maybe2 = Maybe!int.nothing();
            assertNotObjEquals(maybe1, maybe2);
        }
        {
            auto maybe1 = Maybe!double.nothing();
            auto maybe2 = Maybe!double.nothing();
            assertEquals(maybe1, maybe2);
        }
    }
}