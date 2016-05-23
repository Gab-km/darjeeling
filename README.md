# Darjeeling

A library for functional data types in D.

[![Build Status](https://travis-ci.org/Gab-km/darjeeling.svg?branch=master)](https://travis-ci.org/Gab-km/darjeeling)

## Usage

```dlang
import std.stdio : writeln;
import darjeeling.maybe;
import darjeeling.either;

void main()
{
    auto maybe = Maybe!int.just(42);
    if (maybe.isJust)
    {
        writeln(maybe.fromJust());  //#=> 42
    }
    
    auto either = Either!(string, int).right(33-4);
    if (either.isRight)
    {
        writeln(either.right());    //#=> 29
    }
}
```

## Installation

TODO

## Documentation

TODO