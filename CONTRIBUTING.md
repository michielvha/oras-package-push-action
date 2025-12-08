# Contributing to ORAS Package and Push Action

Thank you for considering contributing!

## Development Setup

1. Clone the repository
2. Make changes to scripts in `scripts/`
3. Test locally using `act` or in a real workflow
4. Update README.md with any new features

## Testing

Test the action locally:

```bash
# Set environment variables
export REGISTRY=ghcr.io
export REPOSITORY=test/artifact
export SOURCE_PATH="*.yaml"
export VERSION=v0.0.1
export GITHUB_TOKEN=your_token

# Run scripts
bash scripts/setup-oras.sh
bash scripts/login.sh
bash scripts/package-push.sh
```

## Pull Request Guidelines

- Add examples for new features
- Update README.md
- Test with real workflows when possible
- Follow existing code style