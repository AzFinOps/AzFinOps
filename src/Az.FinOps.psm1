function Get-AzFinOpsRecommendation {
<#
  .SYNOPSIS
    Retrieve Azure Advisor information.

  .DESCRIPTION
    Extraction from `Get-AzAdvisorRecommendation` the cost category related
    recommendations.

  .PARAMETER Subscription
    Subscription ID of where information is going to be extracted from. If empty,
    it will retrieve for subscriptions.

  .PARAMETER Output
    Path where the file will be extracted to.

  .EXAMPLE
    Get-AzFinOpsRecommendation
    Extracts Azure Advisor cost recommendations from all subscriptions.

  .EXAMPLE
    Get-AzFinOpsRecommendation -Output "C:\Temp"
    Extracts recommendations into a specified path.

  .EXAMPLE
    Get-AzFinOpsRecommendation -Subscription "ca34a07e-27a2-4031-8e48-e9043952b967" -Output "C:\Temp"
    Extracts recommendations for a single subscription into a specified path folder.

  .LINK
    https://github.com/AzFinOps/AzFinOps/wiki
#>

  param (
    [string] $Output = ".",
    [string] $Subscription
  )

  function Get-Recommendations {
    param (
      [string] $SubscriptionId
    )
    Set-AzContext $subscription | Out-Null
    $recommendations = Get-AzAdvisorRecommendation `
    | Where-Object 'Category' -eq 'Cost'
    return $recommendations
  }

  # Declare variables
  $data = @() # Data exported from Azure
  $report = @() # Contains final report data

  if ($Subscription) {
    $data += Get-Recommendations -SubscriptionId $Subscription
  } else {
    $subscriptions = Get-AzSubscription -WarningAction Ignore
    foreach ($subscription in $subscriptions) {
      $data += Get-Recommendations -SubscriptionId $subscription
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

  $numberOfRecommendations = $data.Count
  $report | Export-Csv -Path "$Output/FinOps-Recommendations.csv" -NoTypeInformation

  Write-Host "There are a total of $numberOfRecommendations recommendations." `
  "Check the exported file for more information."
}