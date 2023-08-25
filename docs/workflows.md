# Workflows

## PSScriptAnalyzer Workflow

The PSScriptAnalyzer workflow is an integral part of maintaining code quality and adherence to PowerShell scripting standards within this repository. It is powered by the [psscriptanalyzer-action](https://github.com/microsoft/psscriptanalyzer-action) GitHub Action, provided by Microsoft.

### Purpose

The primary purpose of this workflow is to analyse PowerShell script files using PSScriptAnalyzer. PSScriptAnalyzer is a PowerShell module that provides script analysis and checks for various coding standards, best practices, and potential issues.

### Workflow Triggers

This workflow is automatically triggered when a pull request is submitted to the dev branch. Pull requests are a crucial part of the development process, allowing changes to be reviewed and tested before being merged into the main codebase.

### Workflow Steps

1. **Set Up Environment:** The workflow sets up the required environment for running PSScriptAnalyzer by checking out the repository and configuring the PowerShell environment.
2. **Run PSScriptAnalyzer:** PSScriptAnalyzer is executed on the PowerShell script files in the repository. It analyses the scripts for compliance with coding standards, naming conventions, and potential issues.
3. **Generate Report:** The analysis results are generated as a report, which is then used to provide feedback to the pull request.

### Benefits

- **Code Quality:** By automatically analysing scripts, we ensure that the codebase adheres to established coding standards and best practices. This helps maintain consistency and readability.
- **Early Issue Detection:** PSScriptAnalyzer detects potential issues early in the development process, allowing developers to address them before merging changes.
- **Consistent Reviews:** Code analysis helps reviewers focus on higher-level aspects of the code during pull request reviews, as many common issues are automatically caught.

### How to Use

1. Create a `feature` branch from `dev` for your changes.
2. Make your changes and commit them.
3. Push your changes and create a pull request targeting the `dev` branch.
4. The PSScriptAnalyzer workflow will automatically run and provide feedback on the quality of your changes.
5. Address any issues identified by the analysis and collaborate with reviewers to ensure code quality.

This workflow plays a vital role in maintaining a healthy codebase and ensuring that contributions align with our coding standards and best practices.
