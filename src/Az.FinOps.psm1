function Get-AzFinOpsRecommendation {
<#
  .SYNOPSIS
    Retrieve Azure Advisor information.

  .DESCRIPTION
    Extraction from `Get-AzAdvisorRecommendation` the cost category related
    recommendations.

  .PARAMETER SubscriptionId
    Subscription ID of where information is going to be extracted from. If empty,
    it will retrieve for all subscriptions.

  .PARAMETER OutputPath
    Path where the file will be extracted to.

  .EXAMPLE
    Get-AzFinOpsRecommendation
    Extract Azure Advisor cost recommendations from all subscriptions.

  .EXAMPLE
    Get-AzFinOpsRecommendation -OutputPath "C:\Temp"
    Extract recommendations into a specified path.

  .EXAMPLE
    Get-AzFinOpsRecommendation -SubscriptionId "ca34a07e-27a2-4031-8e48-e9043952b967" -OutputPath "C:\Temp"
    Extract recommendations for a single subscription into a specified path folder.

  .LINK
    https://github.com/AzFinOps/AzFinOps/wiki
#>

  param (
    [string] $OutputPath = ".",
    [string] $SubscriptionId
  )

  function Get-Recommendation {
    param (
      [string] $SubscriptionId
    )
    Set-AzContext $SubscriptionId | Out-Null
    $recommendations = Get-AzAdvisorRecommendation `
    | Where-Object 'Category' -eq 'Cost'
    return $recommendations
  }

  # Declare variables
  $data = @() # Data exported from Azure
  $report = @() # Contains final report data

  if ($SubscriptionId) {
    $data += Get-Recommendation -SubscriptionId $SubscriptionId
  } else {
    $subscriptions = Get-AzSubscription
    foreach ($subscription in $subscriptions) {
      $data += Get-Recommendation -SubscriptionId $subscription
    }
  }

  foreach ($recommendation in $data) {
    $row = [PSCustomObject]@{
      Impact = $recommendation.Impact
      ImpactedField = $recommendation.ImpactedField
      ImpactedValue = $recommendation.ImpactedValue
      PotentialBenefit = $recommendation.PotentialBenefit
      Problem = $recommendation.ShortDescriptionProblem
      Solution = $recommendation.ShortDescriptionSolution
      ResourceId = $recommendation.ResourceMetadataResourceId
    }
    $report += $row
  }

  $report | Export-Csv -Path "$OutputPath/FinOps-Recommendations.csv" -NoTypeInformation
}

function Get-AzFinOpsTag {
<#
  .SYNOPSIS
    Retrieve all tags from resource groups and resources.

  .DESCRIPTION
    The Get-AzFinOpsTag will create a csv with all resource groups and resources
    and their tags. This helps tracking which resources are missing tags.

  .PARAMETER SubscriptionId
    Subscription ID of where information is going to be extracted from. If empty,
    it will retrieve for all subscriptions.

  .PARAMETER OutputPath
    Path where the file will be extracted to.

  .EXAMPLE
    Get-AzFinOpsTag
    Extract all tags from all resource groups and resources.

  .EXAMPLE
    Get-AzFinOpsTag -OutputPath "C:\Temp"
    Extract tags list into a specified folder.

  .EXAMPLE
    Get-AzFinOpsTag -Subscription "ca34a07e-27a2-4031-8e48-e9043952b967" -OutputPath "C:\Temp"
    Extract tags from a specific subscription into a specified folder.

  .LINK
    https://github.com/AzFinOps/AzFinOps/wiki
#>

  param (
    [string] $SubscriptionId,
    [string] $OutputPath = "."
  )

  function Compress-ResourceGroupData {
  <#
    .SYNOPSIS
      Get all resource groups in a given subscription and extract their tags.
  #>

    $subscriptionId = (Get-AzContext).Subscription.Id
    $subscriptionName = (Get-AzContext).Subscription.Name
    $resourceGroups = Get-AzResourceGroup
    $localReport = @()

    foreach ($resourceGroup in $resourceGroups) {
      Write-Information "Checking $($resourceGroup.ResourceId)"
      $row = New-Object PSObject -Property @{
        "ResourceName" = $null
        "ResourceGroup" = $resourceGroup.ResourceGroupName
        "Location" = $resourceGroup.Location
        "Type" = "Microsoft.Resources/resourceGroups"
        "SubscriptionName" = $subscriptionName
        "SubscriptionId" = $subscriptionId
        "ResourceId" = $resourceGroup.ResourceId
      }

      $tags = $resourceGroup.tags
      Write-Information "Found $($tags.Count) tags"
      foreach ($tag in $tags.keys) {
        $row | Add-Member -NotePropertyName $tag -NotePropertyValue $tags[$tag]
      }
      $localReport += $row
    }
    return $localReport
  }

  function Compress-ResourceData {
  <#
    .SYNOPSIS
      Get all resources in a given subscription and extract their tags.
  #>

    $subscriptionId = (Get-AzContext).Subscription.Id
    $subscriptionName = (Get-AzContext).Subscription.Name
    $resources = @()
    $localReport = @()

    do {
      $query = Search-AzGraph `
      -Subscription $subscriptionId `
      -Query "resources" `
      -First 1000 `
      -SkipToken $query.SkipToken
      $resources += $query
    } until (
      $null -eq $query.SkipToken
    )
    
    foreach ($resource in $resources) {
      Write-Information "Checking $($resource.ResourceId)"
      $row = New-Object PSObject -Property @{
        "ResourceName" = $resource.name
        "ResourceGroup" = $resource.resourceGroup
        "Location" = $resource.location
        "Type" = $resource.type
        "SubscriptionName" = $subscriptionName
        "SubscriptionId" = $subscriptionId
        "ResourceId" = $resource.ResourceId
      }

      if ($resource.tags) {
        $tags = $resource.tags | Get-Member `
        | Where-Object { $_.MemberType -eq 'NoteProperty' }
        Write-Information "Found $($tags.Count) tags"
        foreach ($tag in $tags) {
          $row | Add-Member -NotePropertyName $tag.Name -NotePropertyValue $resource.Tags.$($tag.Name)
        }
      }
      $localReport += $row
    }
    return $localReport
  }

  # Declare variables
  $report = @() # Contains final report data
  $usedTagNames = @() # List to track used tag names
  $columnOrder = "ResourceName", "ResourceGroup", "Location", "Type",
  "SubscriptionName", "SubscriptionId", "ResourceId"

  if ($SubscriptionId) {
    Set-AzContext $SubscriptionId | Out-Null
    $report += Compress-ResourceGroupData
    $report += Compress-ResourceData
  } else {
    $subscriptions = Get-AzSubscription
    foreach ($subscription in $subscriptions) {
      Set-AzContext $subscription | Out-Null
      $report += Compress-ResourceGroupData
      $report += Compress-ResourceData
    }
  }

  # Determine unique tag names and add them to the column order
  $report | ForEach-Object {
      $_.PSObject.Properties | Where-Object { $_.Name -notin $columnOrder } | ForEach-Object {
          $tagName = $_.Name
          if ($tagName -notin $usedTagNames) {
              $usedTagNames += $tagName
              $columnOrder += $tagName
          }
      }
  }

  Write-Information "Exporting report to '$OutputPath/FinOps-Tags.csv'"
  $report | Select-Object $columnOrder `
  | Export-Csv -Path "$OutputPath/FinOps-Tags.csv" -NoTypeInformation
}