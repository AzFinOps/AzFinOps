# AzFinOps

AzFinOps is a collection of PowerShell functions designed for Azure Financial Operations (FinOps). These functions help manage and optimize costs and financial aspects within Azure.

## Prerequisites

This module was developed using PowerShell Core 7.3.6. While compatibility with Windows PowerShell 5.1 and later is anticipated, it has not been fully tested. To get started, you'll need to have the base Az module installed:

```PowerShell
Install-Module Az
```

If you encounter any challenges while using this module, consider updating both your PowerShell version and the Az module to the latest available versions.

## Installation

As of now, the AzFinOps module is not available on the PowerShell Gallery. To install the module, you'll need to manually download it and place it in your module's folder. Follow these steps:

1. **Download Module:**  
    Download the module from the [release page](https://github.com/sc-andrep/AzFinOps/releases).

2. **Extract to Module Folder:**  
    Extract the downloaded module files and place them in your PowerShell module folder.

## Usage

Detailed information about each function and its usage can be found using the `Get-Help` cmdlet. This provides both a description of the function and practical examples of how to use it effectively.

## FAQ

**Q: Can I customize the output format?**
A: By default, all functions display output in the host window using `Write-Host`. However, if you wish to save the output to a file, you can use the `-Output path-to-file` parameter. This allows the function to export the output as a CSV file.

Feel free to explore the various functions in this module to streamline your Azure Financial Operations and enhance your cost optimization efforts.
