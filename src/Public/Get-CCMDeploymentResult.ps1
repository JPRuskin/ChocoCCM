function Get-CCMDeploymentResult {
    <#
    .SYNOPSIS
    Return the result of a Central Management Deployment

    .DESCRIPTION
    Return the result of a Central Management Deployment

    .PARAMETER Deployment
    The Deployment for which to return information

    .EXAMPLE
    Get-CCMDeploymentResult -Name 'Google Chrome Upgrade'

    #>
    [Alias('Get-DeploymentResult')]  # Added alias for backwards compatibility
    [CmdletBinding(DefaultParameterSetName = "Name", HelpUri = "https://docs.chocolatey.org/en-us/central-management/chococcm/functions/getdeploymentresult")]
    param(
        [Parameter(Mandatory, ParameterSetName = "Name")]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                (Get-CCMDeployment -All).Name.Where{ $_ -match "^$WordToComplete" }
            }
        )]
        [Alias('Deployment')]
        [string]
        $Name,

        [Parameter(Mandatory, ParameterSetName = "Id")]
        $Id = (Get-CCMDeployment -Name $Name).Id # TODO: Find out what type this is
    )
    end {
        try {
            $Slug = "services/app/DeploymentSteps/GetAllPagedByDeploymentPlanId?resultFilter=Success%2CFailed%2CUnreachable%2CInconclusive%2CReady%2CActive%2CCancelled%2CUnknown%2CDraft&deploymentPlanId=$Id&sorting=planOrder%20asc&skipCount=0&maxResultCount=10"
            (Invoke-CCMApi -Slug $Slug -ErrorAction Stop).results.items
        }
        catch {
            throw $_.Exception.Message
        }
    }
}
