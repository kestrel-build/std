# Kestrel Standard Library

The standard library for the [Kestrel programming language](https://kestrel-build.github.io).

## Modules

| Module | Description | Status |
|--------|-------------|--------|
| `io` | File and console I/O | In development |
| `collections` | Lists, maps, sets | In development |
| `math` | Math functions and constants | In development |
| `string` | String utilities | In development |

## Using the standard library

```kestrel
import io.file
import math
import collections.list

str content = io.file.read("data.txt")
float64 root = math.sqrt(2.0)
```

## Built-in string methods

These are available on any `str` value without an import:

```kestrel
str s = "Hello, World!"
int32 n = s.len()
bool b = s.contains("World")
str u = s.to_upper()
str l = s.to_lower()
str t = s.trim()
str r = s.replace("World", "Kestrel")
```

## Contributing

Each module lives in its own directory with a `mod.kst` entry point. See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## Documentation

Full API reference: [kestrel-build.github.io/reference/stdlib](https://kestrel-build.github.io/reference/stdlib/)
