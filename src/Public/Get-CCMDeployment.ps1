function Get-CCMDeployment {
    <#
    .SYNOPSIS
    Return information about a CCM Deployment.

    .DESCRIPTION
    Returns detailed information about Central Management Deployment Plans.

    .PARAMETER Name
    Returns the named Deployment Plan.

    .PARAMETER Id
    Returns the Deployment Plan with the given Id.

    .PARAMETER IncludeStepResults
    If set, additionally retrieves the results for each step of the deployment.

    .EXAMPLE
    Get-CCMDeployment

    .EXAMPLE
    Get-CCMDeployment -Name Bob

    .EXAMPLE
    Get-CCMDeployment -Id 583 -IncludeStepResults
    #>
    [CmdletBinding(DefaultParameterSetname = "All", HelpUri = "https://docs.chocolatey.org/en-us/central-management/chococcm/functions/getccmdeployment")]
    param(
        [Parameter(ParameterSetName = "Name", Mandatory)]
        [string]
        $Name,

        [Parameter(ParameterSetName = "Id", Mandatory)]
        [string]
        $Id,

        [Parameter(ParameterSetName = "Name")]
        [Parameter(ParameterSetName = "Id")]
        [switch]
        $IncludeStepResults
    )
    end {
        if (-not $Id) {
            $Records = Invoke-CCMApi -Slug "services/app/DeploymentPlans/GetAll"
        }

        $Result = switch ($PSCmdlet.ParameterSetName) {
            'Name' {
                $Id = $Records.result | Where-Object { $_.Name -eq "$Name" } | Select-Object -ExpandProperty Id
                (Invoke-CCMApi -Slug "services/app/DeploymentPlans/GetDeploymentPlanForEdit?Id=$queryId").result.deploymentPlan
            }
            'Id' {
                #? Could refactor this both ID and Name to use the same code path? Actually may need to check that both objects return the same values?
                (Invoke-CCMApi -Slug "services/app/DeploymentPlans/GetDeploymentPlanForEdit?Id=$id").result.deploymentPlan
            }
            'All' {
                # TODO: Confirm that this should _not_ return the .deploymentPlan
                $Records.result
            }
        }

        if ($IncludeStepResults) {
            $Result.deploymentSteps = $Result.deploymentSteps | Get-CCMDeploymentStep -IncludeResults
        }

        $Result
    }
}
