#!/usr/bin/env bats

setup() {
    REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
    SCRIPT="$REPO_ROOT/validate-coverage.sh"
    OUTPUT_FILE="$BATS_TEST_TMPDIR/github-output.txt"
    : > "$OUTPUT_FILE"
    unset GITHUB_OUTPUT
    unset STATUS_TOKEN
    unset STATUS_CONTEXT
    export GITHUB_SERVER_URL="https://github.com"
    export GITHUB_REPOSITORY="acme/widgets"
    export GITHUB_SHA="deadbeef"
    export GITHUB_RUN_ID="123"
    export GITHUB_API_URL="https://api.github.com"
}

assert_output_contains() {
    local expected="$1"
    [[ "$output" == *"$expected"* ]]
}

# Installs a fake `curl` ahead of the real one on PATH that records the
# arguments it was called with to $CURL_LOG and exits with $exit_code.
setup_fake_curl() {
    local exit_code="${1:-0}"
    CURL_LOG="$BATS_TEST_TMPDIR/curl-calls.log"
    : > "$CURL_LOG"
    local bin_dir="$BATS_TEST_TMPDIR/bin"
    mkdir -p "$bin_dir"
    cat > "$bin_dir/curl" <<EOF
#!/bin/bash
echo "\$@" >> "$CURL_LOG"
exit ${exit_code}
EOF
    chmod +x "$bin_dir/curl"
    PATH="$bin_dir:$PATH"
}

# Installs a fake `jq` ahead of the real one on PATH that always fails, to
# verify a broken payload build doesn't abort the script under `set -e`.
setup_failing_jq() {
    local bin_dir="$BATS_TEST_TMPDIR/bin"
    mkdir -p "$bin_dir"
    cat > "$bin_dir/jq" <<'EOF'
#!/bin/bash
exit 1
EOF
    chmod +x "$bin_dir/jq"
    PATH="$bin_dir:$PATH"
}

@test "passes clover coverage and writes action outputs" {
    export GITHUB_OUTPUT="$OUTPUT_FILE"

    run "$SCRIPT" "$REPO_ROOT/examples/clover.xml" 80 clover

    [ "$status" -eq 0 ]
    assert_output_contains "Actual coverage: 85%"
    assert_output_contains "Coverage validation passed!"
    grep -Fx "coverage-percentage=85" "$OUTPUT_FILE"
    grep -Fx "status=pass" "$OUTPUT_FILE"
}

@test "fails when coverage is below the minimum and writes fail status" {
    export GITHUB_OUTPUT="$OUTPUT_FILE"

    run "$SCRIPT" "$REPO_ROOT/examples/clover.xml" 90 clover

    [ "$status" -eq 1 ]
    assert_output_contains "Coverage validation failed!"
    assert_output_contains "Actual coverage (85%) is below minimum required (90%)"
    grep -Fx "coverage-percentage=85" "$OUTPUT_FILE"
    grep -Fx "status=fail" "$OUTPUT_FILE"
}

@test "auto-detects cobertura when clover is requested by default" {
    run "$SCRIPT" "$REPO_ROOT/examples/cobertura.xml" 80 clover

    [ "$status" -eq 0 ]
    assert_output_contains "Auto-detected coverage type as 'cobertura'"
    assert_output_contains "Actual coverage: 85%"
}

@test "auto-detects jacoco when clover is requested by default" {
    run "$SCRIPT" "$REPO_ROOT/examples/jacoco.xml" 80 clover

    [ "$status" -eq 0 ]
    assert_output_contains "Auto-detected coverage type as 'jacoco'"
    assert_output_contains "Actual coverage: 85%"
}

@test "resolves the coverage file relative to the working directory" {
    mkdir -p "$BATS_TEST_TMPDIR/project/coverage"
    cp "$REPO_ROOT/examples/clover.xml" "$BATS_TEST_TMPDIR/project/coverage/clover.xml"

    run "$SCRIPT" "coverage/clover.xml" 80 clover "$BATS_TEST_TMPDIR/project"

    [ "$status" -eq 0 ]
    assert_output_contains "Working directory: $BATS_TEST_TMPDIR/project"
}

@test "rejects a non-numeric minimum coverage" {
    run "$SCRIPT" "$REPO_ROOT/examples/clover.xml" eighty clover

    [ "$status" -eq 1 ]
    assert_output_contains "Minimum coverage must be a number between 0 and 100"
}

@test "rejects an out-of-range minimum coverage" {
    run "$SCRIPT" "$REPO_ROOT/examples/clover.xml" 101 clover

    [ "$status" -eq 1 ]
    assert_output_contains "Minimum coverage must be between 0 and 100"
}

@test "rejects unsupported coverage types" {
    run "$SCRIPT" "$REPO_ROOT/examples/clover.xml" 80 invalid-type

    [ "$status" -eq 1 ]
    assert_output_contains "Unsupported coverage type: invalid-type"
    assert_output_contains "Supported types: clover, cobertura, jacoco"
}

@test "fails for invalid cobertura files without a line rate" {
    run "$SCRIPT" "$REPO_ROOT/tests/fixtures/invalid-cobertura.xml" 80 cobertura

    [ "$status" -eq 1 ]
    assert_output_contains "No line rate found in coverage file or invalid Cobertura format"
}

@test "does not call curl when STATUS_TOKEN is unset" {
    setup_fake_curl 0
    unset STATUS_TOKEN

    run "$SCRIPT" "$REPO_ROOT/examples/clover.xml" 80 clover

    [ "$status" -eq 0 ]
    [ ! -s "$CURL_LOG" ]
}

@test "publishes a success commit status when coverage passes and STATUS_TOKEN is set" {
    setup_fake_curl 0
    export STATUS_TOKEN="test-token"
    export STATUS_CONTEXT="coverage/validate-coverage"

    run "$SCRIPT" "$REPO_ROOT/examples/clover.xml" 80 clover

    [ "$status" -eq 0 ]
    [ -s "$CURL_LOG" ]
    grep -q "api.github.com/repos/acme/widgets/statuses/deadbeef" "$CURL_LOG"
    grep -q '"state":"success"' "$CURL_LOG"
    grep -q '"context":"coverage/validate-coverage"' "$CURL_LOG"
    grep -q '"description":"Coverage: 85% (min 80%)"' "$CURL_LOG"
}

@test "publishes a failure commit status when coverage fails and STATUS_TOKEN is set" {
    setup_fake_curl 0
    export STATUS_TOKEN="test-token"

    run "$SCRIPT" "$REPO_ROOT/examples/clover.xml" 90 clover

    [ "$status" -eq 1 ]
    [ -s "$CURL_LOG" ]
    grep -q '"state":"failure"' "$CURL_LOG"
    grep -q '"description":"Coverage: 85% (min 90%)"' "$CURL_LOG"
}

@test "does not fail the script when the commit status POST fails" {
    setup_fake_curl 1
    export STATUS_TOKEN="test-token"

    run "$SCRIPT" "$REPO_ROOT/examples/clover.xml" 80 clover

    [ "$status" -eq 0 ]
    assert_output_contains "::warning::failed to publish coverage commit status"
    assert_output_contains "Coverage validation passed!"
}

@test "does not fail the script when building the status payload fails" {
    setup_failing_jq
    export STATUS_TOKEN="test-token"

    run "$SCRIPT" "$REPO_ROOT/examples/clover.xml" 80 clover

    [ "$status" -eq 0 ]
    assert_output_contains "::warning::failed to build coverage commit status payload"
    assert_output_contains "Coverage validation passed!"
}
