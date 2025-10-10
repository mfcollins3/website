---
mode: agent
model: Claude Sonnet 4.5 (Preview) (copilot)
description: Generate a GitHub Actions workflow to publish the website.
---
Use GitHub Actions to publish the website to GitHub Pages. The workflow should follow the best practices for building and publishing a static website to GitHub Pages.

The workflow should use the following triggers:

- On push to the main branch
- On a pull request to the main branch
- Scheduled to run daily at 1am Arizona time (Mountain Standard Time, UTC-7)

When triggered for a push to the main branch or on the schedule, the workflow should build the website and publish the website to GitHub Pages. When triggered from a pull request, the workflow should only build the website to ensure there are no build errors.

The workflow should include the following steps:

- check out the repository and retrieve binary assets from LFS
- set up Node.js. The version number of Node.js is specified in the `.node-version` file in the root directory of the repository.
- install NPM dependencies using `npm ci`. Cache the NPM dependencies to speed up subsequent runs of the workflow.
- build the website using `npm run build`
- if the workflow is triggered from a push to the main branch or on the schedule, publish the website to GitHub Pages using the `peaceiris/actions-gh-pages` action. The action should be configured to use the `GITHUB_TOKEN` secret for authentication, and the `publish_dir` input should be set to the directory where the built website is located (e.g., `./public`).

Publishing the website can happen in a separate job that depends on the build job, to ensure that the website is only published if the build job completes successfully and can be retried independently if it fails.

Use the latest versions of the actions used in the workflow.

The workflow should be named `publish.yaml` and placed in the `.github/workflows` directory of the repository.

- Use descriptive names for each job and step in the workflow
