#!/usr/bin/env bash

# TODO: Not portable
script_dir=$(dirname "${BASH_SOURCE[0]}")

clr_args=()
fx_args=()
silent=false

while getopts ':c:f:s' opt; do
    case "$opt" in
        c) clr_args+=("$OPTARG") ;;
        f) fx_args+=("$OPTARG") ;;
        s) silent=true ;;
    esac
done

out_stream=/dev/stdout
if "$silent"; then
    out_stream=/dev/null
fi

# We need to both echo the output to out_stream as the proc is running,
# and additionally use the text afterwards for comparison.
# Do this by using tee, which both echoes the text and persists it to a file.
"$script_dir/run_app" -p | tee /tmp/$$_o >"$out_stream"

# Copy coreclr/corefx binaries if requested.
if [ "${#clr_args[@]}" -ne 0 ]; then
    "$script_dir/copy_coreclr" -t publish "${clr_args[@]}"
fi

if [ "${#fx_args[@]}" -ne 0 ]; then
    "$script_dir/copy_corefx" -t publish "${fx_args[@]}"
fi

# Run the app again...
DOTNET_TESTING_NEW=1 "$script_dir/run_app" | tee /tmp/$$_n >"$out_stream" # TODO: We need to clean up these files

# Call through to another script to do the actual cmp
exec "$script_dir/cr_impl" -n "/tmp/$$_o" "/tmp/$$_n"
