# Darjeeling

A library for functional data types in D.

[![Build Status](https://travis-ci.org/Gab-km/darjeeling.svg?branch=master)](https://travis-ci.org/Gab-km/darjeeling)

[![Dub version](https://img.shields.io/dub/v/darjeeling.svg)](https://code.dlang.org/packages/darjeeling)

## Usage

```dlang
import std.stdio : writeln;
import darjeeling.maybe : Maybe;
import darjeeling.either : Either;
import darjeeling.trial : Trial;

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
    
    auto trial = Trial!int.trying({
        auto x = 1;
        if (x > 0) throw new Exception("positive");
        return x;
    });
    if (trial.isFailure)
    {
        auto left = trial.getOrLeft();
        writeln(left.left().msg);   //#=> positive
    }
}
```

## Installation

You can use this package with DUB:

```json
dependencies {
    "darjeeling": "~>0.3.0"
}
```

## Documentation

TODO