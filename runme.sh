set -x
zig build
./zig-cache/bin/zsql -h postgres.local -d test
echo gdb ./zig-cache/bin/zsql
