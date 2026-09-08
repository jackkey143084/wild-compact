# Wild

Wild is a fast, incremental linker for Linux. It is distributed as the `wild` binary and is compatible with the GNU linker command-line interface.

## Build

    cargo build --release -p wild-linker

Requires Rust 1.97.1 or newer (the workspace is edition 2024); run `rustup update stable` if your
toolchain is older. The binary is written to `target/release/wild`.

The optimized distribution profile is available with `cargo build --profile dist -p wild-linker`.

## Use

With Clang, either point at the binary directly:

    clang --ld-path="$PWD/target/release/wild" hello.c -o hello

or put it on your PATH under the name Clang looks for:

    mkdir -p /tmp/wild-bin && ln -sf "$PWD/target/release/wild" /tmp/wild-bin/ld.wild
    PATH=/tmp/wild-bin:$PATH clang -fuse-ld=wild hello.c -o hello

With GCC, expose `wild` as `ld` in a directory passed via `-B`:

    mkdir -p /tmp/wild-bin && ln -sf "$PWD/target/release/wild" /tmp/wild-bin/ld
    gcc -B/tmp/wild-bin hello.c -o hello

## Test

The upstream test suite is not part of this repository. What is here is a smoke test that links
several small C programs with `wild` and with the system linker and compares what the resulting
binaries print:

    cargo build --release -p wild-linker
    ./ci/smoke-test.sh

Source and issue tracker: https://github.com/wild-linker/wild

## License

Licensed under either Apache License 2.0 or MIT, at your option.
