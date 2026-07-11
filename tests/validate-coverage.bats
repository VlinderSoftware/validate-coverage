#!/usr/bin/env bats

setup() {
    REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
    SCRIPT="$REPO_ROOT/validate-coverage.sh"
    OUTPUT_FILE="$BATS_TEST_TMPDIR/github-output.txt"
    : > "$OUTPUT_FILE"
    unset GITHUB_OUTPUT
}

assert_output_contains() {
    local expected="$1"
    [[ "$output" == *"$expected"* ]]
}

@test "passes clover coverage and writes action outputs" {
    export GITHUB_OUTPUT="$OUTPUT_FILE"

    run "$SCRIPT" "$REPO_ROOT/examples/clover.xml" 80 clover

    [ "$status" -eq 0 ]
    assert_output_contains "Actual coverage: 85%"
    assert_output_contains "Coverage validation passed!"
    grep -Fx "coverage-percentage=85" "$OUTPUT_FILE"
    grep -Fx "status=pass" "$OUTPUT_FILE"

    report_json="$(grep "^report-json=" "$OUTPUT_FILE" | cut -d= -f2-)"
    [ "$(echo "$report_json" | jq -r '.coveragePercentage')" = "85" ]
    [ "$(echo "$report_json" | jq -r '.status')" = "pass" ]
    [ "$(echo "$report_json" | jq -r '.covered')" = "85" ]
    [ "$(echo "$report_json" | jq -r '.total')" = "100" ]
}

@test "fails when coverage is below the minimum and writes fail status" {
    export GITHUB_OUTPUT="$OUTPUT_FILE"

    run "$SCRIPT" "$REPO_ROOT/examples/clover.xml" 90 clover

    [ "$status" -eq 1 ]
    assert_output_contains "Coverage validation failed!"
    assert_output_contains "Actual coverage (85%) is below minimum required (90%)"
    grep -Fx "coverage-percentage=85" "$OUTPUT_FILE"
    grep -Fx "status=fail" "$OUTPUT_FILE"

    report_json="$(grep "^report-json=" "$OUTPUT_FILE" | cut -d= -f2-)"
    [ "$(echo "$report_json" | jq -r '.status')" = "fail" ]
}

@test "writes a JSON report file when json-report-file is provided" {
    export GITHUB_OUTPUT="$OUTPUT_FILE"
    report_file="$BATS_TEST_TMPDIR/coverage-report.json"

    run "$SCRIPT" "$REPO_ROOT/examples/clover.xml" 80 clover . "$report_file"

    [ "$status" -eq 0 ]
    [ -f "$report_file" ]
    [ "$(jq -r '.coveragePercentage' "$report_file")" = "85" ]
    [ "$(jq -r '.status' "$report_file")" = "pass" ]
    grep -Fx "report-file=${report_file}" "$OUTPUT_FILE"
}

@test "reports null covered/total for cobertura files without line counts" {
    export GITHUB_OUTPUT="$OUTPUT_FILE"

    run "$SCRIPT" "$REPO_ROOT/examples/cobertura.xml" 80 cobertura

    [ "$status" -eq 0 ]

    report_json="$(grep "^report-json=" "$OUTPUT_FILE" | cut -d= -f2-)"
    [ "$(echo "$report_json" | jq -r '.covered')" = "null" ]
    [ "$(echo "$report_json" | jq -r '.total')" = "null" ]
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
