#!/bin/bash
set -e

# Input parameters
COVERAGE_FILE="$1"
MINIMUM_COVERAGE="$2"
COVERAGE_TYPE="${3:-clover}"
WORKING_DIRECTORY="${4:-.}"
JSON_REPORT_FILE="${5:-}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored log messages
log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Function to show usage
show_usage() {
    echo "Usage: $0 <coverage-file> <minimum-percentage> [coverage-type] [working-directory] [json-report-file]"
    echo ""
    echo "Parameters:"
    echo "  coverage-file       Path to the coverage file"
    echo "  minimum-percentage  Minimum coverage percentage (0-100)"
    echo "  coverage-type       Type of coverage file (clover, cobertura, jacoco) - defaults to 'clover'"
    echo "  working-directory   Working directory - defaults to current directory"
    echo "  json-report-file    Path to write a machine-readable JSON report - optional"
    echo ""
    echo "Examples:"
    echo "  $0 coverage/clover.xml 80"
    echo "  $0 coverage/cobertura.xml 75 cobertura"
    echo "  $0 coverage/jacoco.xml 90 jacoco /path/to/project"
    echo "  $0 coverage/clover.xml 80 clover . coverage-report.json"
}

detect_coverage_type() {
    local coverage_file="$1"

    if ! command -v xmllint &> /dev/null; then
        return 1
    fi

    if [ "$(xmllint --xpath "boolean(/coverage/project/metrics)" "$coverage_file" 2>/dev/null)" = "true" ]; then
        echo "clover"
        return 0
    fi

    if [ "$(xmllint --xpath "boolean(/coverage[@line-rate])" "$coverage_file" 2>/dev/null)" = "true" ]; then
        echo "cobertura"
        return 0
    fi

    if [ "$(xmllint --xpath "boolean(/report/counter[@type='INSTRUCTION'])" "$coverage_file" 2>/dev/null)" = "true" ]; then
        echo "jacoco"
        return 0
    fi

    return 1
}

# Validate required parameters
if [ -z "$COVERAGE_FILE" ]; then
    error "Coverage file path is required"
    show_usage
    exit 1
fi

if [ -z "$MINIMUM_COVERAGE" ]; then
    error "Minimum coverage percentage is required"
    show_usage
    exit 1
fi

# Validate minimum coverage is a number
if ! [[ "$MINIMUM_COVERAGE" =~ ^[0-9]+$ ]]; then
    error "Minimum coverage must be a number between 0 and 100"
    exit 1
fi

if [ "$MINIMUM_COVERAGE" -lt 0 ] || [ "$MINIMUM_COVERAGE" -gt 100 ]; then
    error "Minimum coverage must be between 0 and 100"
    exit 1
fi

# Change to working directory
cd "$WORKING_DIRECTORY"

# Check if coverage file exists
if [ ! -f "$COVERAGE_FILE" ]; then
    error "Coverage file not found: $COVERAGE_FILE"
    exit 1
fi

log "Validating coverage from: $COVERAGE_FILE"
log "Coverage type: $COVERAGE_TYPE"
log "Working directory: $(pwd)"
log "Required minimum coverage: ${MINIMUM_COVERAGE}%"

# Auto-detect coverage type if not specified
if [ "$COVERAGE_TYPE" = "clover" ]; then
    DETECTED_COVERAGE_TYPE="$(detect_coverage_type "$COVERAGE_FILE" || true)"
    if [ -n "$DETECTED_COVERAGE_TYPE" ] && [ "$DETECTED_COVERAGE_TYPE" != "$COVERAGE_TYPE" ]; then
        COVERAGE_TYPE="$DETECTED_COVERAGE_TYPE"
        warning "Auto-detected coverage type as '$COVERAGE_TYPE'"
    fi
fi

# Parse coverage based on type
case "$COVERAGE_TYPE" in
    "clover")
        log "Parsing Clover XML format..."
        
        # Check if xmllint is available
        if ! command -v xmllint &> /dev/null; then
            error "xmllint is required but not installed"
            exit 1
        fi
        
        # Extract covered and total statements from Clover XML
        COVERED=$(xmllint --xpath "sum(//metrics/@coveredstatements)" "$COVERAGE_FILE" 2>/dev/null || echo "0")
        TOTAL=$(xmllint --xpath "sum(//metrics/@statements)" "$COVERAGE_FILE" 2>/dev/null || echo "0")
        
        if [ "$TOTAL" -eq 0 ]; then
            error "No statements found in coverage file or invalid Clover format"
            exit 1
        fi
        ;;
        
    "cobertura")
        log "Parsing Cobertura XML format..."
        
        # Check if xmllint is available
        if ! command -v xmllint &> /dev/null; then
            error "xmllint is required but not installed"
            exit 1
        fi
        
        # Extract line-rate from Cobertura XML (already a percentage)
        LINE_RATE=$(xmllint --xpath "string(/coverage/@line-rate)" "$COVERAGE_FILE" 2>/dev/null || echo "0")
        
        if [ "$LINE_RATE" = "0" ] || [ -z "$LINE_RATE" ]; then
            error "No line rate found in coverage file or invalid Cobertura format"
            exit 1
        fi
        
        # Convert decimal to percentage
        COVERAGE=$(echo "$LINE_RATE * 100" | bc | cut -d. -f1)

        # Extract covered/total line counts if present, for the JSON report
        COVERED=$(xmllint --xpath "string(/coverage/@lines-covered)" "$COVERAGE_FILE" 2>/dev/null || echo "")
        TOTAL=$(xmllint --xpath "string(/coverage/@lines-valid)" "$COVERAGE_FILE" 2>/dev/null || echo "")
        ;;
        
    "jacoco")
        log "Parsing JaCoCo XML format..."
        
        # Check if xmllint is available
        if ! command -v xmllint &> /dev/null; then
            error "xmllint is required but not installed"
            exit 1
        fi
        
        # Extract covered and missed instructions from JaCoCo XML
        COVERED=$(xmllint --xpath "sum(//counter[@type='INSTRUCTION']/@covered)" "$COVERAGE_FILE" 2>/dev/null || echo "0")
        MISSED=$(xmllint --xpath "sum(//counter[@type='INSTRUCTION']/@missed)" "$COVERAGE_FILE" 2>/dev/null || echo "0")
        TOTAL=$((COVERED + MISSED))
        
        if [ "$TOTAL" -eq 0 ]; then
            error "No instructions found in coverage file or invalid JaCoCo format"
            exit 1
        fi
        ;;
        
    *)
        error "Unsupported coverage type: $COVERAGE_TYPE"
        error "Supported types: clover, cobertura, jacoco"
        exit 1
        ;;
esac

# Calculate coverage percentage if not already calculated
if [ -z "$COVERAGE" ]; then
    if [ "$TOTAL" -eq 0 ]; then
        error "Total statements/instructions is zero"
        exit 1
    fi
    
    COVERAGE=$((COVERED * 100 / TOTAL))
    
    log "Covered statements: $COVERED"
    log "Total statements: $TOTAL"
fi

log "Actual coverage: ${COVERAGE}%"

# Determine pass/fail status up front so the report and outputs below agree
# with the exit code decided later.
if [ "$COVERAGE" -lt "$MINIMUM_COVERAGE" ]; then
    STATUS="fail"
else
    STATUS="pass"
fi

# Build a machine-readable JSON report, for orgs whose dashboards consume a
# workflow artifact rather than a commit status. Report generation is
# best-effort: a broken jq must never fail an otherwise-successful run.
REPORT_JSON=""
if command -v jq &> /dev/null; then
    if ! REPORT_JSON=$(jq -n -c \
        --arg coverageFile "$COVERAGE_FILE" \
        --arg coverageType "$COVERAGE_TYPE" \
        --argjson coveragePercentage "$COVERAGE" \
        --argjson minimumCoverage "$MINIMUM_COVERAGE" \
        --arg status "$STATUS" \
        --arg covered "${COVERED:-}" \
        --arg total "${TOTAL:-}" \
        --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        '{
            coverageFile: $coverageFile,
            coverageType: $coverageType,
            coveragePercentage: $coveragePercentage,
            minimumCoverage: $minimumCoverage,
            status: $status,
            covered: (if $covered == "" then null else ($covered | tonumber) end),
            total: (if $total == "" then null else ($total | tonumber) end),
            timestamp: $timestamp
        }'); then
        echo "::warning::failed to build coverage JSON report"
        REPORT_JSON=""
    fi
else
    echo "::warning::jq is not installed; skipping JSON report generation"
fi

# Write the JSON report to file, if requested. This runs inside the action's
# Docker container, so an absolute path here (e.g. /github/workspace/...) is a
# container-local path that later, non-container workflow steps (like
# actions/upload-artifact) can't use. Emit a path relative to $GITHUB_WORKSPACE
# instead, when the report lives under it, so it's directly usable by
# subsequent steps; fall back to the absolute path otherwise.
REPORT_FILE_OUTPUT=""
if [ -n "$JSON_REPORT_FILE" ] && [ -n "$REPORT_JSON" ]; then
    if mkdir -p "$(dirname "$JSON_REPORT_FILE")" && echo "$REPORT_JSON" | jq '.' > "$JSON_REPORT_FILE"; then
        report_file_abs="$(cd "$(dirname "$JSON_REPORT_FILE")" && pwd)/$(basename "$JSON_REPORT_FILE")"
        if [ -n "${GITHUB_WORKSPACE:-}" ] && [[ "$report_file_abs" == "$GITHUB_WORKSPACE"/* ]]; then
            REPORT_FILE_OUTPUT="${report_file_abs#"$GITHUB_WORKSPACE"/}"
        else
            REPORT_FILE_OUTPUT="$report_file_abs"
        fi
        log "Wrote JSON report to: $report_file_abs"
    else
        echo "::warning::failed to write JSON report to: $JSON_REPORT_FILE"
    fi
fi

# Set outputs for GitHub Actions (if running in GitHub Actions)
if [ -n "$GITHUB_OUTPUT" ]; then
    {
        echo "coverage-percentage=${COVERAGE}"
        echo "status=${STATUS}"
        if [ -n "$REPORT_JSON" ]; then
            echo "report-json=${REPORT_JSON}"
        fi
        if [ -n "$REPORT_FILE_OUTPUT" ]; then
            echo "report-file=${REPORT_FILE_OUTPUT}"
        fi
    } >> "$GITHUB_OUTPUT"
fi

# Publish a commit status with the coverage result, if a token was provided.
# This is entirely opt-in: with no STATUS_TOKEN, this is a no-op so existing
# callers see zero behavior change.
publish_commit_status() {
    local state="$1"
    local description="$2"

    if [ -z "${STATUS_TOKEN:-}" ]; then
        return 0
    fi

    if [ "${#description}" -gt 140 ]; then
        description="${description:0:140}"
    fi

    local context="${STATUS_CONTEXT:-coverage/validate-coverage}"
    local target_url="${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}"
    local api_url="${GITHUB_API_URL:-https://api.github.com}/repos/${GITHUB_REPOSITORY}/statuses/${GITHUB_SHA}"

    # Building the payload must never fail the run either, so guard the jq
    # call itself rather than letting `set -e` abort on a non-zero exit.
    local body
    if ! body=$(jq -n -c \
        --arg state "$state" \
        --arg context "$context" \
        --arg description "$description" \
        --arg target_url "$target_url" \
        '{state: $state, context: $context, description: $description, target_url: $target_url}'); then
        echo "::warning::failed to build coverage commit status payload"
        return 0
    fi

    # A failed status POST must never fail an otherwise-successful validation run.
    if ! curl --silent --show-error --fail \
        --request POST \
        --header "Authorization: Bearer ${STATUS_TOKEN}" \
        --header "Accept: application/vnd.github+json" \
        --header "X-GitHub-Api-Version: 2022-11-28" \
        --header "Content-Type: application/json" \
        --data "$body" \
        --output /dev/null \
        "$api_url"; then
        echo "::warning::failed to publish coverage commit status"
    fi
}

# Report the final result and exit accordingly
if [ "$STATUS" = "fail" ]; then
    publish_commit_status "failure" "Coverage: ${COVERAGE}% (min ${MINIMUM_COVERAGE}%)"
    error "Coverage validation failed!"
    error "Actual coverage (${COVERAGE}%) is below minimum required (${MINIMUM_COVERAGE}%)"
    exit 1
else
    publish_commit_status "success" "Coverage: ${COVERAGE}% (min ${MINIMUM_COVERAGE}%)"
    success "Coverage validation passed!"
    success "Actual coverage (${COVERAGE}%) meets minimum requirement (${MINIMUM_COVERAGE}%)"
fi
