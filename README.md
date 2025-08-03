# Coverage Validation Action

A fast, Docker-based GitHub Action for validating test coverage from XML files against minimum thresholds. This action eliminates the need to install dependencies like `libxml2-utils`, `bc`, and other tools in your workflows.

## Features

- ✅ **Fast execution** - Pre-built Docker container with all dependencies
- ✅ **Multiple formats** - Supports Clover, Cobertura, and JaCoCo XML formats  
- ✅ **Configurable thresholds** - Set minimum coverage percentages
- ✅ **Clear output** - Colored logs and detailed error messages
- ✅ **GitHub Actions integration** - Outputs for use in other steps

## Supported Coverage Formats

| Format | Description | Example Tools |
|--------|-------------|---------------|
| `clover` | Clover XML format | PHPUnit, Jest, Vitest |
| `cobertura` | Cobertura XML format | pytest-cov, coverage.py |
| `jacoco` | JaCoCo XML format | JaCoCo (Java) |

## Usage

### Basic Usage

```yaml
- name: Validate Coverage
  uses: vlindersoftware/validate-coverage@v1
  with:
    coverage-file: 'coverage/clover.xml'
    minimum-coverage: '80'
```

### Advanced Usage

```yaml
- name: Validate Coverage
  uses: vlindersoftware/validate-coverage@v1
  with:
    coverage-file: 'coverage/coverage.xml'
    minimum-coverage: '85'
    coverage-type: 'cobertura'
    working-directory: './backend'
```

### Using Outputs

```yaml
- name: Validate Coverage
  id: coverage
  uses: vlindersoftware/validate-coverage@v1
  with:
    coverage-file: 'coverage/clover.xml'
    minimum-coverage: '80'

- name: Comment on PR
  if: failure()
  uses: actions/github-script@v6
  with:
    script: |
      github.rest.issues.createComment({
        issue_number: context.issue.number,
        owner: context.repo.owner,
        repo: context.repo.repo,
        body: `❌ Coverage validation failed! Actual: ${{ steps.coverage.outputs.coverage-percentage }}%`
      })
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `coverage-file` | Path to the coverage XML file | ✅ | - |
| `minimum-coverage` | Minimum coverage percentage required | ❌ | 85 |
| `coverage-type` | XML format type (`clover`, `cobertura`, `jacoco`) | ❌ | `cobertura` |
| `working-directory` | Working directory for the coverage file | ❌ | `.` |

## Outputs

| Output | Description |
|--------|-------------|
| `coverage-percentage` | The actual coverage percentage found |
| `status` | `pass` or `fail` status of validation |

## Examples

### Node.js with Jest/Vitest (Clover)

```yaml
name: Test Coverage
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Run tests with coverage
        run: npm run test:coverage
        
      - name: Validate Coverage
        uses: VlinderSoftware/validate-coverage@v1
        with:
          coverage-file: 'coverage/clover.xml'
          minimum-coverage: '80'
```

### Python with pytest-cov (Cobertura)

```yaml
name: Test Coverage
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.9'
          
      - name: Install dependencies
        run: |
          pip install pytest pytest-cov
          
      - name: Run tests with coverage
        run: pytest --cov=src --cov-report=xml
        
      - name: Validate Coverage
        uses: VlinderSoftware/validate-coverage@v1
        with:
          coverage-file: 'coverage.xml'
          minimum-coverage: '85'
          coverage-type: 'cobertura'
```

### Java with JaCoCo

```yaml
name: Test Coverage
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Java
        uses: actions/setup-java@v3
        with:
          java-version: '11'
          distribution: 'temurin'
          
      - name: Run tests with JaCoCo
        run: ./mvnw test jacoco:report
        
      - name: Validate Coverage
        uses: VlinderSoftware/validate-coverage@v1
        with:
          coverage-file: 'target/site/jacoco/jacoco.xml'
          minimum-coverage: '75'
          coverage-type: 'jacoco'
```

## Migration Guide

### From manual xmllint commands

**Before:**
```yaml
- name: Validate coverage
  run: |
    sudo apt-get update -y && sudo apt-get install -y libxml2-utils
    COVERED=$(xmllint --xpath "string(/coverage/project/metrics/@coveredstatements)" coverage/clover.xml)
    TOTAL=$(xmllint --xpath "string(/coverage/project/metrics/@statements)" coverage/clover.xml)
    COVERAGE=$(echo "($COVERED * 100) / $TOTAL" | bc | awk '{print int($1)}')
    if [ "$COVERAGE" -lt "80" ]; then
      echo "Coverage $COVERAGE% is below 80%"
      exit 1
    fi
```

**After:**
```yaml
- name: Validate coverage
  uses: VlinderSoftware/validate-coverage@v1
  with:
    coverage-file: 'coverage/clover.xml'
    minimum-coverage: '80'
```

## Development

To test this action locally:

```bash
# Build the Docker image
docker build -t validate-coverage .

# Test with a sample coverage file
docker run --rm -v $(pwd):/workspace validate-coverage \
  coverage/clover.xml 80 clover .
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with different coverage file formats
5. Submit a pull request (including evidence of non-regression)

## License

MIT License - see [LICENSE](LICENSE) file for details.
