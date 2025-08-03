<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

# Coverage Validation Action

This is a Docker-based GitHub Action for validating test coverage from XML files against minimum thresholds.

## Key Features
- **Pre-built Docker images**: Published to GHCR, eliminates build time in workflows
- **Multiple XML formats**: Supports Clover, Cobertura, and JaCoCo formats
- **Semantic versioning**: Uses semver with major/minor tag convenience
- **Fast execution**: No dependency installation required in user workflows
- **Auto-detection**: Automatically detects coverage format when possible

## Architecture
- **Runtime**: Alpine Linux container with xmllint, bc, bash
- **Registry**: GitHub Container Registry (ghcr.io/vlindersoftware/validate-coverage)
- **Versioning**: Semantic versioning with floating major/minor tags
- **CI/CD**: Automated build, test, and release pipeline

## Development Guidelines
- Keep the action lightweight and focused on coverage validation
- Use standard XML parsing tools (xmllint) for maximum compatibility  
- Provide clear error messages and colored output for better UX
- Follow GitHub Actions best practices for inputs/outputs
- Maintain backward compatibility within major versions
- Test all three coverage formats (clover, cobertura, jacoco) before release

## Release Process
- Use `release/vN` branches for major versions
- Tag with full semver (`v1.2.3`) to trigger releases
- CI automatically updates convenience tags (`v1`, `v1.2`)
- Use `./scripts/create-release.sh` for streamlined releases
- Release script updates action.yml to use specific version tag
- Development uses `main` tag, releases use specific version tags
- See RELEASE.md for detailed release instructions

## File Structure
- `action.yml` - GitHub Action definition (references GHCR image)
- `Dockerfile` - Container definition with all dependencies
- `validate-coverage.sh` - Main validation script
- `examples/` - Sample coverage files for testing
- `.github/workflows/release.yml` - Release automation
- `scripts/create-release.sh` - Release helper scripte to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

# Coverage Validation Action

This is a Docker-based GitHub Action for validating test coverage from XML files (like clover.xml) against minimum thresholds.

## Key Features
- Containerized validation logic eliminates dependency installation time
- Supports multiple XML coverage formats (Clover, Cobertura, etc.)
- Configurable minimum coverage thresholds
- Fast execution with pre-built Docker image

## Development Guidelines
- Keep the action lightweight and focused on coverage validation
- Use standard XML parsing tools (xmllint)
- Provide clear error messages and exit codes
- Follow GitHub Actions best practices for inputs/outputs
