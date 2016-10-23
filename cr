#!/usr/bin/env bash

# TODO: Not portable
script_dir=$(dirname "${BASH_SOURCE[0]}")

clr_args=()
fx_args=()
verbose=false

while getopts ':c:f:v' opt; do
    case "$opt" in
        c) clr_args+=("$OPTARG") ;;
        f) fx_args+=("$OPTARG") ;;
        v) verbose=true ;;
    esac
done

out_stream=/dev/stdout
if ! "$verbose"; then
    out_stream=/dev/null
fi

# We need to both echo the output to out_stream as the proc is running,
# and additionally use the text afterwards for comparison.
# Do this by using tee, which both echoes the text and persists it to a file.
"$script_dir/run_app" -p | tee /tmp/$$_o >"$out_stream"

# Copy coreclr/corefx binaries if requested.
if [ -n "${clr_args[@]}" ]; then
    "$script_dir/copy_coreclr" -t publish "${clr_args[@]}"
fi

if [ -n "${fx_args[@]}" ]; then
    "$script_dir/copy_corefx" -t publish "${fx_args[@]}"
fi

# Run the app again...
"$script_dir/run_app" -p | tee /tmp/$$_n >"$out_stream"

# Call through to another script to do the actual cmp
exec "$script_dir/cr_impl" -n "$$_o" "$$_n"
