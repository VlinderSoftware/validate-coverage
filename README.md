# Coverage Validation Action

A fast, Docker-based GitHub Action for validating test coverage from XML files against minimum thresholds. This action eliminates the need to install dependencies like `libxml2-utils`, `bc`, and other tools in your workflows.

## Features

- ✅ **Fast execution** - Pre-built Docker container with all dependencies
- ✅ **Multiple formats** - Supports Clover, Cobertura, and JaCoCo XML formats  
- ✅ **Configurable thresholds** - Set minimum coverage percentages
- ✅ **Clear output** - Colored logs and detailed error messages
- ✅ **GitHub Actions integration** - Outputs for use in other steps
- ✅ **Portable machine-readable report** - A JSON summary any org's dashboard can consume as a workflow artifact

## Supported Coverage Formats

| Format | Description | Example Tools |
|--------|-------------|---------------|
| `clover` | Clover XML format | PHPUnit, Jest, Vitest |
| `cobertura` | Cobertura XML format | pytest-cov, coverage.py |
| `jacoco` | JaCoCo XML format | JaCoCo (Java) |

## Usage

### Versioning

This action follows semantic versioning with convenience tags:

- `@v1` - Latest v1.x.x release (gets all updates, including new features)
- `@v1.0` - Latest v1.0.x release (gets patch updates only)
- `@v1.0.4` - Exact version (no automatic updates)

**Recommended:** Use `@v1` for most use cases to get the latest improvements and security updates.

### Basic Usage

```yaml
- name: Validate Coverage
  uses: vln-devsecops/actions-validate-coverage@v1
  with:
    coverage-file: 'coverage/clover.xml'
    minimum-coverage: '80'
```

### Advanced Usage

```yaml
- name: Validate Coverage
  uses: vln-devsecops/actions-validate-coverage@v1
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
  uses: vln-devsecops/actions-validate-coverage@v1
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

### Reporting to dashboards

There are two independent, opt-in ways to feed a coverage result to a dashboard. Use either or
both — neither changes the action's default behavior, and enabling one does not require the other.

#### Commit status (for the `vln-devsecops` org dashboard)

Set `github-token` to have the action publish a [commit status](https://docs.github.com/en/rest/commits/statuses)
with the coverage result.

```yaml
- name: Validate Coverage
  id: coverage
  uses: vln-devsecops/actions-validate-coverage@v1
  with:
    coverage-file: 'coverage/cobertura.xml'
    minimum-coverage: '80'
    github-token: ${{ github.token }}
```

The status is posted using the workflow's own `GITHUB_TOKEN` (the default `statuses: write`
permission is enough — no PAT or cross-repo secret needed), with a `context` starting with
`coverage` and a `description` of the form `Coverage: <percentage>% (min <minimum>%)`.

This is what feeds the `vln-devsecops/operations` org dashboard's coverage column specifically.
That dashboard reads the combined commit status of each monitored repo's **default branch**, so the
status only shows up there if it's posted from a run against the default branch's latest commit
(e.g. a `push` trigger on `main`) — a status posted from a pull-request run against a feature-branch
commit won't be picked up. If you want that dashboard to reflect your coverage, make sure
`github-token` is set on the workflow run that triggers on your default branch.

This mechanism isn't specific to any one repo or org beyond needing that dashboard's consumer code
to be pointed at it — each caller posts to its own repo with its own token. If your org's tooling
can't read commit statuses, use the JSON report below instead.

#### JSON report (portable — any org, any dashboard)

The action always produces a `report-json` output: a compact JSON summary of the coverage result,
independent of the commit-status feature above and requiring no token. Set `json-report-file` to
additionally have it written to disk, so it can be uploaded as a workflow artifact for a dashboard
(in any org) to fetch and parse later:

```yaml
- name: Validate Coverage
  id: coverage
  uses: vln-devsecops/actions-validate-coverage@v1
  with:
    coverage-file: 'coverage/clover.xml'
    minimum-coverage: '80'
    json-report-file: 'coverage-report.json'

- name: Upload coverage report
  if: always()
  uses: actions/upload-artifact@v4
  with:
    name: coverage-report
    path: coverage-report.json
```

The report has the following shape:

```json
{
  "coverageFile": "coverage/clover.xml",
  "coverageType": "clover",
  "coveragePercentage": 85,
  "minimumCoverage": 80,
  "status": "pass",
  "covered": 85,
  "total": 100,
  "timestamp": "2026-07-11T16:10:40Z"
}
```

`covered` and `total` are `null` when the coverage format doesn't expose those counts (for example,
a Cobertura file without `lines-covered`/`lines-valid` attributes). Report generation is
best-effort: if `jq` is unavailable or fails to build the report, the action logs a warning and
still exits with the normal pass/fail status — a broken report never fails an otherwise-successful
validation run.

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `coverage-file` | Path to the coverage XML file | ✅ | - |
| `minimum-coverage` | Minimum coverage percentage required | ❌ | 85 |
| `coverage-type` | XML format type (`clover`, `cobertura`, `jacoco`) | ❌ | `cobertura` |
| `working-directory` | Working directory for the coverage file | ❌ | `.` |
| `github-token` | Token used to publish a commit status with the coverage result (e.g. `${{ github.token }}`). Omit to skip status publishing entirely — the action behaves exactly as before | ❌ | - |
| `status-context` | Commit status context to publish under. Must start with `coverage` to be picked up by the org dashboard | ❌ | `coverage/validate-coverage` |
| `json-report-file` | Path to write a machine-readable JSON coverage report (relative to `working-directory`), for dashboards in other orgs that consume a workflow artifact instead of a commit status. Omit to skip file generation — the `report-json` output is still produced | ❌ | - |

## Outputs

| Output | Description |
|--------|-------------|
| `coverage-percentage` | The actual coverage percentage found |
| `status` | `pass` or `fail` status of validation |
| `report-json` | A compact JSON string summarizing the coverage report (see shape above) |
| `report-file` | Absolute path to the written JSON report file (only set when `json-report-file` is provided and the write succeeds) |

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
        uses: vln-devsecops/actions-validate-coverage@v1
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
        uses: vln-devsecops/actions-validate-coverage@v1
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
        uses: vln-devsecops/actions-validate-coverage@v1
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
  uses: vln-devsecops/actions-validate-coverage@v1
  with:
    coverage-file: 'coverage/clover.xml'
    minimum-coverage: '80'
```

## Development

### Local Testing

```bash
# Run the unit test suite
bats tests/validate-coverage.bats

# Test the script directly
./validate-coverage.sh examples/clover.xml 80

# Build and test Docker image
./scripts/test-docker.sh

# Build Docker image manually
docker build -t validate-coverage .

# Test with a sample coverage file
docker run --rm -v $(pwd)/examples:/workspace validate-coverage \
  /workspace/clover.xml 80 clover
```

### Publishing

```bash
# Manual publish to GHCR (for initial setup)
./scripts/publish-docker.sh

# Create a release (automated pipeline)
./scripts/create-release.sh 1.0.0
```

**Important**: The release script automatically updates action.yml to reference the specific version Docker image (e.g., `ghcr.io/vln-devsecops/actions-validate-coverage:v1.0.0`), ensuring reproducible releases.

### VS Code Tasks

The project includes VS Code tasks for development:
- **Build Docker Image**: Builds the Docker container
- **Test Coverage Script**: Tests the script directly
- **Test Docker Action**: Tests the Docker action
- **Test Docker (All Formats)**: Comprehensive Docker testing
- **Publish Docker to GHCR**: Manual publish to registry
- **Create Release**: Streamlined release creation

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with different coverage file formats
5. Submit a pull request (including evidence of non-regression)

## License

MIT License - see [LICENSE](LICENSE) file for details.
