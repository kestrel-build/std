# Kestrel Standard Library

The standard library for the [Kestrel programming language](https://kestrel-build.github.io),
written in Kestrel itself.

## Modules

| Module | Description | Status |
|--------|-------------|--------|
| `string` | Text utilities: split/join, trim, case, pad, search, char classes | **Implemented + tested** |
| `math` | abs/sign/min/max/clamp (generic), gcd/lcm, pow_int, floor/ceil/round, sqrt (Newton's method), pi/e/tau | **Implemented + tested** |
| `list` | Generic `List[T]` helpers: first/last, contains/index_of/count, copy/concat/fill/reverse/take/drop | **Implemented + tested** |
| `collections` | Typed List helpers: range, sum/min/max, count, concat, slice | **Implemented + tested** |
| `io` | read_lines / write_lines / append_file over the file built-ins | **Implemented + tested** |
| `testing` | A tiny unit-test framework: expect / expect_eq_* / report | **Implemented + tested** |
| `os` | Process + argv helpers: run / run_ok / argc / arg_at / args / has_flag | **Implemented + tested** |
| `convert` | Primitive ↔ string: int/int64/float/bool_to_str, parse_int, is_int | **Implemented + tested** |
| `assert` | Runtime assertions built on `fail`: assert / assert_eq_* / unreachable | **Implemented + tested** |
| `kernel` | Linux kernel-module FFI bindings (printk, uaccess, chrdev, errno) | Designed |

Every implemented module has a sibling test program (`<mod>/test_<mod>.kst`)
that exercises each function and prints a PASS/FAIL summary.

## Running the tests

Each test is a standalone program; run it with the Kestrel compiler. The
tests import each other across modules (e.g. `os` uses `testing`), so point
`KESTREL_STD` at this checkout so `import std.*` resolves:

```bash
export KESTREL_STD=$(pwd)
kestrel run string/test_string.kst
kestrel run math/test_math.kst
kestrel run list/test_list.kst
kestrel run collections/test_collections.kst
kestrel run io/test_io.kst
kestrel run testing/test_testing.kst
kestrel run os/test_os.kst
kestrel run convert/test_convert.kst
kestrel run assert/test_assert.kst
```

All of them print `PASS` on a green tree.

## A taste

```kestrel
// string
List[str] parts = split("a,b,c", ",")        // ["a", "b", "c"]
str joined = join(parts, " | ")              // "a | b | c"
str t = trim("  hi  ")                       // "hi"
str u = to_upper("kestrel")                  // "KESTREL"

// math
float64 r = sqrt(2.0)                        // 1.41421...
int64 g = gcd(48, 36)                        // 12
int32 c = clamp(v, 0, 100)                   // generic min/max/clamp

// list (generic over the element type)
List[str] names = list_new()
names.push("kestrel")
bool has = contains(names, "kestrel")        // true, works for any List[T]
List[str] rev = reverse(names)               // new reversed list

// collections
List[int32] xs = range(1, 5)                 // [1, 2, 3, 4, 5]
int32 total = sum_i32(xs)                    // 15

// io
List[str] lines = read_lines("data.txt")
```

## How std is loaded

Kestrel compiles **whole programs from source** — there is no binary library
format yet. Today, std modules are compiled together with your program like
any other Kestrel source. The planned resolution (tracked on the roadmap):

1. `import std.string` will resolve against an installed std tree — the
   `KESTREL_STD` environment variable, or a `std/` directory shipped next to
   the compiler binary.
2. The compiler merges the imported std sources into your program's build,
   exactly as it merges your own modules.
3. Later, a package manager (`kestrel add`) and a precompiled module cache
   take over distribution; the source-tree model stays as the fallback.

Design notes: functions are free functions (not methods) so they work with
Kestrel's current module system; names carry explicit type suffixes
(`sum_i32`, `abs_f64`) where generics can't yet express the constraint, and
generics (`min[T]`, `clamp[T]`) where they can. No FFI — everything,
including `sqrt`, is pure Kestrel over the language's built-ins. (`repeat`
turned out to be reserved by the compiler, hence `repeat_str`.)

## Writing a Linux kernel module

The `kernel` module wraps the C kernel ABI (it does not reimplement the
kernel). Import the pieces you need instead of re-declaring externs:

```kestrel
import kernel.printk.{pr_info}
import kernel.uaccess.{copy_to_user_ok}
import kernel.chrdev.{FileOperations, register_chrdev}
import kernel.errno.{EFAULT}
import kernel.module.MODULE_OK

@section(".init.text")
pub func hello_init() -> int32 {
    pr_info("hello from a Kestrel module")
    return MODULE_OK
}

@section(".exit.text")
pub func hello_exit() -> void {
    pr_info("goodbye")
}
```

See `examples/showcase/kernel_module.kst` for a complete character device.
Building a real `.ko` needs freestanding kernel-ABI codegen + Kbuild (roadmap
Phase 18); the bindings define the intended surface today.

## Contributing

Each module lives in its own directory with a `mod.kst` entry point. See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## Documentation

Full API reference: [kestrel-build.github.io/reference/stdlib](https://kestrel-build.github.io/reference/stdlib/)
