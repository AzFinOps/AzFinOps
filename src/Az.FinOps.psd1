# Module manifest for AzFinOps module

@{
  # Script module or binary module file associated with this manifest.
  RootModule = 'Az.FinOps.psm1'

  # Version number of this module.
  ModuleVersion = '1.1.0'

  # Author of this module
  Author = 'André'

  # Copyright statement for this module
  Copyright = '(c) 2023 AzFinOps'

  # Description of the functionality provided by this module
  Description = 'This module provides functions for managing Azure Financial Operations.'

  # Modules that must be imported into the global environment prior to importing this module
  RequiredModules = @('Az.Accounts', 'Az.Advisor', 'Az.Resources',
  'Az.ResourceGraph')

  # Minimum version of the PowerShell engine required by this module
  PowerShellVersion = '7.0'

  # HelpInfo URI of this module
  HelpInfoURI = 'https://github.com/AzFinOps/AzFinOps'
}