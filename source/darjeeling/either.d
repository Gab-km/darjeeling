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
 * A module for values with two possiblities
 *
 * Copyright: (C) Kazuhiro Matsushima 2016.
 * License:   <a href="http://www.boost.org/LICENSE_1_0.txt">Boost License 1.0</a>.
 * Authors:   Kazuhiro Matsushima
 */
module darjeeling.either;

import std.format : format;
import std.traits : fullyQualifiedName;
import darjeeling.maybe : Maybe;
import darjeeling.assertion;

/**
 * A interface to represent a two possible value.
 *
 * Example:
 * -----
 * auto either = Either!(string, int).right(33-4);
 * if (either.isRight)
 * {
 *     writeln(either.right());
 * }
 * -----
 * Output:
 * -----
 * 29
 * -----
 */
interface Either(TLeft, TRight)
{
    /**
     * Return true if $(D this) is the Right!(TLeft, TRight) instance, otherwise false.
     */
    @property bool isRight() nothrow pure @safe;

    /**
     * Return true if $(D this) is the Left!(TLeft, TRight) instance, otherwise false.
     */
    @property bool isLeft() nothrow pure @safe;

    /**
     * Return TLeft value if $(D this) is the Left!(TLeft, TRight) instance, otherwise throw Exception.
     */
    TLeft left() pure @safe;

    /**
     * Return TRight value if $(D this) is the Right!(TLeft, TRight) instance, otherwise throw Exception.
     */
    TRight right() pure @safe;

    /**
     * Return Just!TLeft value if $(D this) is the Left!(TLeft, TRight) instance, otherwise Nothing!TLeft value.
     */
    Maybe!TLeft tryLeft() nothrow pure @safe;

    /**
     * Return Just!TRight value if $(D this) is the Right!(TLeft, TRight) instance, otherwise Nothing!TRight value.
     */
    Maybe!TRight tryRight() nothrow pure @safe;

    /**
     * A factory method to create Right(TLeft, TRight) instance.
     *
     * Params:
     *  value = a TRight value to contain
     *
     * Returns:
     *  A Right!(TLeft, TRight) instance which has $(D_PARAM value).
     */
    static Either!(TLeft, TRight) right(TRight value) nothrow pure @safe
    {
        return new Right!(TLeft, TRight)(value);
    }

    /**
     * A factory method to create Left(TLeft, TRight) instance.
     *
     * Params:
     *  value = a TLeft value to contain
     *
     * Returns:
     *  A Left!(TLeft, TRight) instance which has $(D_PARAM value).
     */
    static Either!(TLeft, TRight) left(TLeft value) nothrow pure @safe
    {
        return new Left!(TLeft, TRight)(value);
    }
}

final class Left(TLeft, TRight) : Either!(TLeft, TRight)
{
    TLeft value;

    package this(TLeft value) nothrow pure @safe
    {
        this.value = value;
    }

    @property bool isRight() nothrow pure @safe
    {
        return !this.isLeft;
    }

    unittest
    {
        auto left = new Left!(string, int)("hoge");
        assert(!left.isRight);
    }

    @property bool isLeft() nothrow pure @safe
    {
        return true;
    }

    unittest
    {
        auto left = new Left!(Exception, string)(new Exception("fuga"));
        assert(left.isLeft);
    }

    TLeft left() pure @safe
    {
        return this.value;
    }

    unittest
    {
        auto expected = "hoge";
        auto left = new Left!(string, int)(expected);
        auto actual = left.left();
        assertEquals(expected, actual);
    }

    TRight right() pure @safe
    {
        throw new Exception("Invalid operation: Left(TLeft, TRight) cannot return its right value.");
    }

    unittest
    {
        auto left = new Left!(Exception, string)(new Exception("bar"));
        auto ex = trap!(Left!(Exception, string), string)(left, function(Left!(Exception, string) l) => l.right());
        auto expected = "Invalid operation: Left(TLeft, TRight) cannot return its right value.";
        assertEquals(expected, ex.msg);
    }

    Maybe!TLeft tryLeft() nothrow pure @safe
    {
        return Maybe!TLeft.just(this.value);
    }

    unittest
    {
        auto expected = "left";
        auto left = new Left!(string, int)(expected);
        auto actual = left.tryLeft();
        assert(actual.isJust);
        assertEquals(expected, actual.fromJust());
    }

    Maybe!TRight tryRight() nothrow pure @safe
    {
        return Maybe!TRight.nothing();
    }

    unittest
    {
        auto left = new Left!(Exception, string)(new Exception("LeFT"));
        auto actual = left.tryRight();
        assert(!actual.isJust);
    }

    override string toString()
    {
        return format("Left!(%s, %s)(%s)", fullyQualifiedName!TLeft, fullyQualifiedName!TRight, this.value);
    }

    override bool opEquals(Object o)
    {
        if (typeid(o) == typeid(this))
        {
            auto other = cast(Left!(TLeft, TRight))(o);
            return this.value == other.value;
        }
        else
        {
            return false;
        }
    }
}

final class Right(TLeft, TRight) : Either!(TLeft, TRight)
{
    TRight value;

    package this(TRight value) nothrow pure @safe
    {
        this.value = value;
    }

    @property bool isRight() nothrow pure @safe
    {
        return true;
    }

    unittest
    {
        auto right = new Right!(string, int)(334);
        assert(right.isRight);
    }

    @property bool isLeft() nothrow pure @safe
    {
        return !this.isRight;
    }

    unittest
    {
        auto right = new Right!(Exception, string)("right");
        assert(!right.isLeft);
    }

    TLeft left() pure @safe
    {
        throw new Exception("Invalid operation: Right(TLeft, TRight) cannot return its left value.");
    }

    unittest
    {
        auto right = new Right!(string, int)(42);
        auto ex = trap!(Right!(string, int), string)(right, function(r) => r.left());
        auto expected = "Invalid operation: Right(TLeft, TRight) cannot return its left value.";
        assertEquals(expected, ex.msg);
    }

    TRight right() pure @safe
    {
        return this.value;
    }

    unittest
    {
        auto expected = "That's right";
        auto right = new Right!(Exception, string)(expected);
        auto actual = right.right();
        assertEquals(expected, actual);
    }

    Maybe!TLeft tryLeft() nothrow pure @safe
    {
        return Maybe!TLeft.nothing();
    }

    unittest
    {
        auto right = new Right!(string, int)(-10);
        auto actual = right.tryLeft();
        assert(!actual.isJust);
    }

    Maybe!TRight tryRight() nothrow pure @safe
    {
        return Maybe!TRight.just(this.value);
    }

    unittest
    {
        auto expected = "right";
        auto right = new Right!(Exception, string)(expected);
        auto actual = right.tryRight();
        assert(actual.isJust);
        assertEquals(expected, actual.fromJust());
    }

    override string toString()
    {
        return format("Right!(%s, %s)(%s)", fullyQualifiedName!TLeft, fullyQualifiedName!TRight, this.value);
    }

    override bool opEquals(Object o)
    {
        if (typeid(o) == typeid(this))
        {
            auto other = cast(Right!(TLeft, TRight))(o);
            return this.value == other.value;
        }
        else
        {
            return false;
        }
    }
}

unittest
{
    // Left(TLeft, TRight)
    {
        auto expected = "hoge";
        Either!(string, int) either = Either!(string, int).left(expected);
        assert(either.isLeft);
        assert(!either.isRight);
        auto left = either.tryLeft();
        assert(left.isJust);
        assertEquals(expected, left.fromJust());
    }
    // Right(TLeft, TRight)
    {
        auto expected = 334;
        Either!(string, int) either = Either!(string, int).right(expected);
        assert(!either.isLeft);
        assert(either.isRight);
        auto right = either.tryRight();
        assert(right.isJust);
        assertEquals(expected, right.fromJust());
    }
    // Equality
    {
        {
            auto either1 = Either!(string, int).left("hoge");
            auto either2 = Either!(string, int).left("hoge");
            assertEquals(either1, either2);
        }
        {
            auto either1 = Either!(string, int).left("Left");
            auto either2 = Either!(string, int).left("left");
            assertNotEquals(either1, either2);
        }
        {
            auto either1 = Either!(string, int).left("fuga");
            auto either2 = Either!(Exception, string).left(new Exception("fuga"));
            assertNotObjEquals(either1, either2);
        }
        {
            auto either1 = Either!(string, int).right(42);
            auto either2 = Either!(string, int).right(42);
            assertEquals(either1, either2);
        }
        {
            auto either1 = Either!(string, int).right(33);
            auto either2 = Either!(string, int).right(4);
            assertNotEquals(either1, either2);
        }
        {
            auto either1 = Either!(string, int).right(10);
            auto either2 = Either!(Exception, int).right(10);
            assertNotObjEquals(either1, either2);
        }
        {
            auto either1 = Either!(string, int).right(10);
            auto either2 = Either!(string, int).left("ten");
            assertNotObjEquals(either1, either2);
        }
        {
            auto either1 = Either!(string, int).left("test");
            auto either2 = Either!(Exception, string).right("test");
            assertNotObjEquals(either1, either2);
        }
    }
}