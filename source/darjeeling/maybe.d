/**
 * A module for optional values
 *
 * Copyright: (C) Kazuhiro Matsushima 2016.
 * License:   <a href="http://www.boost.org/LICENSE_1_0.txt">Boost License 1.0</a>.
 * Authors:   Kazuhiro Matsushima
 */
module darjeeling.maybe;

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
        auto just = new Just!int(3);
        auto value = just.fromJust();
        assert(value == 3);
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
        try
        {
            auto value = nothing.fromJust();
        }
        catch (Exception ex)
        {
            assert(ex.msg == "Invalid operation: Nothing(T) cannot return its value.");
            return;
        }
        assert(false);
    }
}

unittest
{
    Maybe!int just = Maybe!int.just(2);
    assert(just.isJust);
    assert(!just.isNothing);
    auto value = just.fromJust();
    assert(value == 2);
}
unittest
{
    Maybe!string nothing = Maybe!string.nothing();
    assert(!nothing.isJust);
    assert(nothing.isNothing);
}