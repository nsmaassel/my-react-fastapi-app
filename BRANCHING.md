# Trunk-Based Development Guide

This project follows trunk-based development practices for faster integration and deployment.

## Core Principles

1. **Main Branch is Always Deployable**
   - The `main` branch should always be in a deployable state
   - All tests must pass before merging
   - Automated deployments happen directly from main

2. **Short-Lived Feature Branches**
   - Create branches directly from `main`
   - Keep branches small and focused
   - Typical lifetime: 1-2 days maximum
   - Merge back to main as soon as possible

## Branch Naming Convention

```
feature/brief-description
fix/issue-description
```

## Development Workflow

1. **Start New Work**
   ```bash
   git checkout main
   git pull
   git checkout -b feature/your-feature
   ```

2. **Regular Updates**
   ```bash
   git checkout main
   git pull
   git checkout feature/your-feature
   git rebase main
   ```

3. **Prepare for Merge**
   - Ensure all tests pass locally
   - Rebase on latest main
   - Squash commits if needed

4. **Code Review & Merge**
   - Create a Pull Request
   - Address review comments
   - Merge using squash and merge

## Best Practices

1. **Small, Frequent Changes**
   - Break down large features into smaller, shippable increments
   - Commit frequently, push daily
   - Keep PRs small and focused

2. **Feature Flags**
   - Use feature flags for larger changes
   - This allows incomplete features to exist in main safely
   - Remove flags once feature is fully rolled out

3. **Continuous Integration**
   - All PRs must pass CI checks
   - Tests run on every push
   - Failed builds block merging

4. **Quick Fixes**
   - Critical fixes can be made directly on main
   - Must still pass all tests
   - Document emergency procedures

## Release Process

1. **Continuous Deployment**
   - Successful merges to main trigger deployment
   - Automated smoke tests run post-deployment
   - Tagged releases created automatically

2. **Versioning**
   - Automatic version tags: `vYYYYMMDD.HHMMSS-commit`
   - Production deployments tracked via tags
   - Roll back using previous tags if needed

## Monitoring & Rollback

1. **Deployment Monitoring**
   - Watch error rates after deployment
   - Monitor application metrics
   - Set up alerts for anomalies

2. **Rollback Procedure**
   ```bash
   # Identify last known good deployment
   git checkout <previous-tag>
   # CI/CD will handle the deployment
   ```

## Tips for Success

1. **Communication**
   - Announce significant changes
   - Keep team updated on feature progress
   - Document API changes

2. **Testing**
   - Write tests before merging
   - Run full test suite locally
   - Add regression tests for bugs

3. **Code Quality**
   - Follow project style guide
   - Use code formatters
   - Regular dependency updates

4. **Documentation**
   - Update docs with code changes
   - Include context in commit messages
   - Document breaking changes