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

### Choosing `coverage-type`

`coverage-type` defaults to `cobertura`, and **that default is applied regardless of the coverage
file's name or extension** — the action does not infer the format from a path like
`coverage/clover.xml`. If your reporter emits Clover or JaCoCo, set `coverage-type` explicitly:

```yaml
coverage-type: 'clover'   # Jest, Vitest, PHPUnit
```

Leaving it out for a Clover file means the Cobertura parser looks for a `/coverage/@line-rate`
attribute that a Clover document doesn't have, and the run fails with:

```
[ERROR] No line rate found in coverage file or invalid Cobertura format
```

That message names the coverage file, but a valid Clover file produces it too — the fix is the
missing `coverage-type` input, not the file.

#### What gets measured

The metric the action gates on depends on the format:

| `coverage-type` | Metric used |
|-----------------|-------------|
| `clover` | `coveredstatements` / `statements` from the `<metrics>` elements |
| `cobertura` | the `line-rate` attribute on `<coverage>` |
| `jacoco` | covered / (covered + missed) `INSTRUCTION` counters |

For **Vitest** this is worth spelling out: Vitest writes its *line* metric into Clover's
`statements`/`coveredstatements` attributes, so the percentage this action gates on is its line
coverage, not the `Statements` figure printed in Vitest's terminal table. The two commonly differ by
a point or so (e.g. a terminal reporting 54.34% against a gate that computes 53%). Set
`minimum-coverage` from the file the action reads, not from the terminal summary, or leave enough
margin to absorb the difference. The action also truncates rather than rounds, so 84.9% is reported
as `84`.

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
    coverage-type: 'clover'
```

> **Always set `coverage-type` to match your file.** It defaults to `cobertura`, and that default
> applies no matter what the file is named — a file called `clover.xml` is still parsed as Cobertura
> unless you say otherwise. See [Choosing `coverage-type`](#choosing-coverage-type).

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

`working-directory` is an input rather than something you can set once for the job: a job-level
`defaults.run.working-directory` applies only to `run:` steps and is ignored by `uses:` steps, so in
a monorepo this input is the only way to point the action at a subdirectory. Without it the action
resolves `coverage-file` from the repository root and fails to find a file that plainly exists.

### Using Outputs

```yaml
- name: Validate Coverage
  id: coverage
  uses: vln-devsecops/actions-validate-coverage@v1
  with:
    coverage-file: 'coverage/clover.xml'
    minimum-coverage: '80'
    coverage-type: 'clover'

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

#### Commit status (GitHub-native, any consumer)

Set `github-token` to have the action publish a [commit status](https://docs.github.com/en/rest/commits/statuses)
with the coverage result, readable by any dashboard or tool that consumes GitHub's commit-status API.

```yaml
permissions:
  contents: read
  statuses: write

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      # ...
      - name: Validate Coverage
        id: coverage
        uses: vln-devsecops/actions-validate-coverage@v1
        with:
          coverage-file: 'coverage/cobertura.xml'
          minimum-coverage: '80'
          coverage-type: 'cobertura'
          github-token: ${{ github.token }}
```

The status is posted using the workflow's own `GITHUB_TOKEN`, with a `context` starting with
`coverage` and a `description` of the form `Coverage: <percentage>% (min <minimum>%)`. No PAT or
cross-repo secret is needed.

> **The token needs `statuses: write`.** If your workflow (or job) declares no `permissions:` block
> at all, the repository default is normally enough. But an explicit `permissions:` block sets every
> scope it doesn't name to `none` — and declaring one is standard hardening advice — so a workflow
> that only says
>
> ```yaml
> permissions:
>   contents: read
> ```
>
> has **no** `statuses` permission, and the status POST is rejected with a 403. Because publishing
> the status is deliberately non-fatal, the only trace is a
> `::warning::failed to publish coverage commit status` annotation: the step is green, the run is
> green, and the dashboard silently never updates. Add `statuses: write` alongside whatever else you
> declare, as in the example above.

One example consumer is the `vln-devsecops/node-dashboard` org dashboard, which reads the combined
commit status of each monitored repo's **default branch** and looks for a `context` starting with
`coverage`. Most commit-status consumers work the same way — the status only shows up if it's
posted from a run against the default branch's latest commit (e.g. a `push` trigger on `main`), not
from a pull-request run against a feature-branch commit. If your dashboard reads a repo's default
branch status, make sure `github-token` is set on the workflow run that triggers there.

Each caller posts its own commit status to its own repo with its own token, so this works the same
way for any repo or org — it isn't specific to `vln-devsecops`. If your dashboard doesn't (or can't)
read commit statuses, use the JSON report below instead.

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
    coverage-type: 'clover'
    json-report-file: 'coverage-report.json'

- name: Upload coverage report
  if: always()
  uses: actions/upload-artifact@v4
  with:
    name: coverage-report
    path: ${{ steps.coverage.outputs.report-file }}
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
| `coverage-type` | XML format type (`clover`, `cobertura`, `jacoco`). The default applies regardless of the coverage file's name or extension — a file named `clover.xml` is still parsed as Cobertura unless you set this. See [Choosing `coverage-type`](#choosing-coverage-type) | ❌ | `cobertura` |
| `working-directory` | Working directory for the coverage file | ❌ | `.` |
| `github-token` | Token used to publish a commit status with the coverage result (e.g. `${{ github.token }}`). Omit to skip status publishing entirely — the action behaves exactly as before | ❌ | - |
| `status-context` | Commit status context to publish under. Use a prefix a consumer filters on — `coverage` (the default) is what the `vln-devsecops/node-dashboard` dashboard looks for | ❌ | `coverage/validate-coverage` |
| `json-report-file` | Path to write a machine-readable JSON coverage report (relative to `working-directory`), for dashboards that consume a workflow artifact instead of a commit status. Omit to skip file generation — the `report-json` output is still produced | ❌ | - |

## Outputs

| Output | Description |
|--------|-------------|
| `coverage-percentage` | The actual coverage percentage found |
| `status` | `pass` or `fail` status of validation |
| `report-json` | A compact JSON string summarizing the coverage report (see shape above) |
| `report-file` | Path to the written JSON report file, relative to `$GITHUB_WORKSPACE` when possible so it's directly usable by later steps like `actions/upload-artifact` (falls back to an absolute container path otherwise). Only set when `json-report-file` is provided and the write succeeds |

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
          coverage-type: 'clover'
```

`coverage-type: 'clover'` is required here — without it the file is parsed as Cobertura and the run
fails. If you're on Vitest, also note that the gated percentage is Vitest's *line* metric, not the
`Statements` column of its terminal table; see [Choosing `coverage-type`](#choosing-coverage-type).

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
    coverage-type: 'clover'
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
