# Wild

Wild is a fast, incremental linker for Linux. It is distributed as the `wild` binary and is compatible with the GNU linker command-line interface.

## Build

    cargo build --release -p wild-linker

The toolchain is pinned by `rust-toolchain.toml`; rustup installs it automatically. The binary is
written to `target/release/wild`.

The optimized distribution profile is available with `cargo build --profile dist -p wild-linker`.

## Use

With Clang, put `wild` on your PATH and select it by name:

    clang -fuse-ld=wild hello.c -o hello

With GCC, expose `wild` as `ld` in a directory passed via `-B`:

    mkdir -p /tmp/wild-bin && ln -sf "$PWD/target/release/wild" /tmp/wild-bin/ld
    gcc -B/tmp/wild-bin hello.c -o hello

Source and issue tracker: https://github.com/wild-linker/wild

## License

Licensed under either Apache License 2.0 or MIT, at your option.
