#!/bin/bash
set -e

# Input parameters
COVERAGE_FILE="$1"
MINIMUM_COVERAGE="$2"
COVERAGE_TYPE="${3:-clover}"
WORKING_DIRECTORY="${4:-.}"

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
    echo "Usage: $0 <coverage-file> <minimum-percentage> [coverage-type] [working-directory]"
    echo ""
    echo "Parameters:"
    echo "  coverage-file       Path to the coverage file"
    echo "  minimum-percentage  Minimum coverage percentage (0-100)"
    echo "  coverage-type       Type of coverage file (clover, cobertura, jacoco) - defaults to 'clover'"
    echo "  working-directory   Working directory - defaults to current directory"
    echo ""
    echo "Examples:"
    echo "  $0 coverage/clover.xml 80"
    echo "  $0 coverage/cobertura.xml 75 cobertura"
    echo "  $0 coverage/jacoco.xml 90 jacoco /path/to/project"
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
    # Check if it's actually a clover file
    if ! grep -q "clover" "$COVERAGE_FILE" 2>/dev/null; then
        if grep -q "cobertura" "$COVERAGE_FILE" 2>/dev/null; then
            COVERAGE_TYPE="cobertura"
            warning "Auto-detected coverage type as 'cobertura'"
        elif grep -q "jacoco" "$COVERAGE_FILE" 2>/dev/null; then
            COVERAGE_TYPE="jacoco"
            warning "Auto-detected coverage type as 'jacoco'"
        fi
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

# Set outputs for GitHub Actions (if running in GitHub Actions)
if [ -n "$GITHUB_OUTPUT" ]; then
    echo "coverage-percentage=${COVERAGE}" >> "$GITHUB_OUTPUT"
fi

# Compare with minimum
if [ "$COVERAGE" -lt "$MINIMUM_COVERAGE" ]; then
    if [ -n "$GITHUB_OUTPUT" ]; then
        echo "status=fail" >> "$GITHUB_OUTPUT"
    fi
    error "Coverage validation failed!"
    error "Actual coverage (${COVERAGE}%) is below minimum required (${MINIMUM_COVERAGE}%)"
    exit 1
else
    if [ -n "$GITHUB_OUTPUT" ]; then
        echo "status=pass" >> "$GITHUB_OUTPUT"
    fi
    success "Coverage validation passed!"
    success "Actual coverage (${COVERAGE}%) meets minimum requirement (${MINIMUM_COVERAGE}%)"
fi
