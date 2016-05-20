# Darjeeling

A library for functional data types in D.

[![Build Status](https://travis-ci.org/Gab-km/darjeeling.svg?branch=master)](https://travis-ci.org/Gab-km/darjeeling)

## Usage

```dlang
import std.stdio : writeln;
import darjeeling.maybe;

void main()
{
    auto maybe = Maybe!int.just(42);
    if (maybe.isJust)
    {
        writeln(maybe.fromJust());  //#=> 42
    }
}
```

## Installation

TODO
