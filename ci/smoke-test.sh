#!/usr/bin/env bash
#
# Links a handful of small C programs with wild and with the system linker, runs both and
# compares their output. Requires a `wild` binary; pass its path as the first argument or set
# WILD_BIN (defaults to target/release/wild).

set -euo pipefail

wild_bin="${1:-${WILD_BIN:-target/release/wild}}"
if [ ! -x "$wild_bin" ]; then
  echo "smoke-test: no wild binary at '$wild_bin'; build one with:" >&2
  echo "    cargo build --release -p wild-linker" >&2
  exit 1
fi
wild_bin="$(cd "$(dirname "$wild_bin")" && pwd)/$(basename "$wild_bin")"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

# GCC selects a linker by looking for `ld` in the directories given with -B, so expose wild
# under that name.
mkdir -p "$work/wild-bin"
ln -sf "$wild_bin" "$work/wild-bin/ld"

cat > "$work/greet.c" <<'EOF'
#include <stdio.h>
void greet(const char *who) { printf("hello, %s\n", who); }
EOF

cat > "$work/count.c" <<'EOF'
int count(int n) { int total = 0; for (int i = 1; i <= n; i++) total += i; return total; }
EOF

cat > "$work/main.c" <<'EOF'
#include <stdio.h>
#include <stdlib.h>
void greet(const char *who);
int count(int n);
int main(void) {
    greet("wild");
    printf("sum=%d\n", count(10));
    char *buf = malloc(16);
    snprintf(buf, 16, "heap ok");
    puts(buf);
    free(buf);
    return 0;
}
EOF

failures=0

# Compiles and links "$@" twice, once with wild and once with the system linker, then compares
# the output of the two resulting binaries.
check() {
  local name="$1"
  shift
  local wild_out system_out

  rm -f "$work/prog-wild" "$work/prog-system"
  if ! gcc "-B$work/wild-bin" "$@" -o "$work/prog-wild" > "$work/wild-link.log" 2>&1; then
    echo "FAIL $name: wild failed to link"
    sed 's/^/    /' "$work/wild-link.log"
    failures=$((failures + 1))
    return
  fi
  gcc "$@" -o "$work/prog-system" > /dev/null 2>&1

  if ! wild_out="$(LD_LIBRARY_PATH=$work "$work/prog-wild" 2>&1)"; then
    echo "FAIL $name: binary linked by wild did not run"
    echo "$wild_out" | sed 's/^/    /'
    failures=$((failures + 1))
    return
  fi
  system_out="$(LD_LIBRARY_PATH=$work "$work/prog-system" 2>&1)"

  if [ "$wild_out" != "$system_out" ]; then
    echo "FAIL $name: output differs from the system linker"
    diff <(echo "$system_out") <(echo "$wild_out") | sed 's/^/    /' || true
    failures=$((failures + 1))
    return
  fi

  echo "ok   $name"
}

gcc -c -o "$work/greet.o" "$work/greet.c"
gcc -c -o "$work/count.o" "$work/count.c"
gcc -c -o "$work/main.o" "$work/main.c"

check "multiple objects" "$work/main.o" "$work/greet.o" "$work/count.o"

ar rcs "$work/libhelpers.a" "$work/greet.o" "$work/count.o"
check "static archive" "$work/main.o" -L"$work" -lhelpers

gcc -fPIC -shared -o "$work/libhelpers.so" "$work/greet.c" "$work/count.c"
check "shared library" "$work/main.o" -L"$work" -lhelpers

check "static executable" -static "$work/main.o" "$work/greet.o" "$work/count.o"

if [ "$failures" -ne 0 ]; then
  echo "$failures smoke test(s) failed"
  exit 1
fi

echo "all smoke tests passed"
