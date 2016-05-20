# Darjeeling

A library for functional data types in D.

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
