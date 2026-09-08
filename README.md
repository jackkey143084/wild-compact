# Wild

Wild is a fast, incremental linker for Linux. It is distributed as the `wild` binary and is compatible with the GNU linker command-line interface.

## Build

    cargo build --release -p wild-linker

The optimized distribution profile is available with `cargo build --profile dist -p wild-linker`.

## Use

Put `wild` on your PATH and select it through Clang:

    clang -fuse-ld=wild hello.c -o hello

Source and issue tracker: https://github.com/wild-linker/wild

## License

Licensed under either Apache License 2.0 or MIT, at your option.
