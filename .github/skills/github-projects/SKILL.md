---
name: github-projects
description: >
  A skill for creating GitHub Projects and linking projects to GitHub
  repositories or teams.
---
# GitHub Projects Skill

This skills allows you to manage GitHub Projects. The following features are
supported:

1. [Create a new GitHub Project](#1-create-a-new-github-project)
1. [Link a GitHub Project to a repository](#2-link-a-github-project-to-a-repository)

## 1. Create a new GitHub Project

To create a new GitHub Project, provide the following information:

- **Project Title**: The title of the project
- **Owner**: The GitHub user or organization that will own the project. If not
  specified, the default value of `@me` will be used, which refers to the
  authenticated user.

To create the project, run the following command:

```bash
gh project create --format json --owner {owner} --title "{project_title}"
```

The output will be formatted as JSON. The `number` field contains the project
number, which is used to reference the project in future commands. The `url`
field contains the URL of the project on GitHub.

If you have issues processing the output of the `gh project create` command, try
the following steps to debug before attempting to create the project again:

1. Use the `execute/getTerminalOutput` tool to get the raw output of the
   command. Check for any error messages or unexpected output that may indicate
   what went wrong.
2. Use the `github/projects_list` tool to list all projects for the owner. Check
   if the project was created successfully and if it appears in the list.

## 2. Link a GitHub Project to a repository

To link a GitHub Project to a repository, provide the following information:

- **Project Number**: The number of the project you want to link.
- **Repository**: The name of the repository to link the project to, in the
  format `owner/repo`.

To link the project to the repository, run the following command:

```bash
gh project link {project_number} --repo {repository} --owner {owner}
```
