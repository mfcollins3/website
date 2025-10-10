---
mode: agent
model: Claude Sonnet 4.5 (Preview) (copilot)
description: Generate a GitHub Actions workflow to publish the website.
---
Use GitHub Actions to publish the website to GitHub Pages. The workflow should follow the best practices for building and publishing a static website to GitHub Pages using the official GitHub Actions.

The workflow should use the following triggers:

- On push to the main branch
- On a pull request to the main branch
- Scheduled to run daily at 1am Arizona time (Mountain Standard Time, UTC-7)
- Manual workflow dispatch for on-demand deployments

When triggered for a push to the main branch, on the schedule, or manually, the workflow should build the website and publish it to GitHub Pages. When triggered from a pull request, the workflow should only build the website to ensure there are no build errors.

The workflow should be split into two jobs for better separation of concerns and retry-ability:

## Build Job

The build job should include the following steps:

- Check out the repository and retrieve binary assets from LFS using `actions/checkout@v5` with `lfs: true`
- Set up Node.js using `actions/setup-node@v5` with the `node-version-file` parameter pointing to `.node-version` in the root directory. Enable NPM dependency caching.
- Install NPM dependencies using `npm ci`
- Build the website using `npm run build`
- Upload the built website as a Pages artifact using `actions/upload-pages-artifact@v3` with the `path` parameter set to the build output directory (e.g., `./dist`). This step should only run on push to main, scheduled runs, or manual dispatch.

## Publish Job

The publish job should:

- Depend on the build job completing successfully (`needs: build`)
- Only run when triggered from a push to the main branch, on the schedule, or manual dispatch (not on pull requests)
- Include the following permissions:
  - `pages: write` - To deploy to Pages
  - `id-token: write` - For OIDC authentication
- Configure the `github-pages` environment with the deployment URL output
- Deploy to GitHub Pages using `actions/deploy-pages@v4` (this action automatically retrieves the Pages artifact uploaded in the build job)

Use the latest stable versions of all actions in the workflow.

The workflow should be named `publish.yaml` and placed in the `.github/workflows` directory of the repository.

Guidelines:
- Use descriptive names for each job and step in the workflow
- Use the official GitHub Actions for Pages deployment (`actions/upload-pages-artifact` and `actions/deploy-pages`) instead of third-party actions for better security and integration
- The custom domain configuration (if needed) should be set in the repository settings, not in the workflow file
