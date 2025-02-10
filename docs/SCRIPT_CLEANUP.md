# Script Migration and Cleanup Todo

## Files to Remove
These files are not actively used and should be removed:
- [ ] `infrastructure/configure-github.sh`
- [ ] `infrastructure/deploy.sh`
- [ ] `infrastructure/deploy-test.sh`
- [ ] `scripts/test-deployment.sh`

## Documentation to Update
- [x] Created SCRIPTS.md to document Windows/.bat usage
- [ ] Update README.md to clarify Windows-first approach
- [ ] Update DEPLOYMENT_CHECKLIST.md to reference correct scripts
- [ ] Update GitHub Actions workflow to ensure Windows compatibility

## Next Steps
1. Manually remove unused .sh files
2. Test deployment process using only .bat files
3. Verify all documentation references correct script names
4. Add Windows prerequisite notes to setup docs

## Note
This is an internal tracking document for the development team.
All future development should focus on the Windows/.bat versions of scripts
unless cross-platform support becomes a priority.