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