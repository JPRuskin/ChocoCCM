function Get-CCMDeploymentStep {
    <#
    .SYNOPSIS
    Return information about a CCM Deployment step.

    .DESCRIPTION
    Returns detailed information about Central Management Deployment Steps.

    .PARAMETER InputObject
    Retrieves additional details for the given step.

    .PARAMETER Id
    Returns the Deployment Step with the given Id.

    .PARAMETER IncludeResults
    If set, additionally retrieves the results for the targeted step.

    .EXAMPLE
    Get-CCMDeploymentStep -Id 583 -IncludeResults

    .EXAMPLE
    Get-CCMDeploymentStep -InputObject $step -IncludeResults
    #>
    [CmdletBinding(DefaultParameterSetName = 'IdOnly', HelpUri = "https://docs.chocolatey.org/en-us/central-management/chococcm/functions/getccmdeploymentstep")]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'StepObject')]
        [Alias('Step')]
        [psobject]
        $InputObject,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'IdOnly')]
        [Alias('DeploymentStepId')]
        [long]
        $Id,

        [Parameter()]
        [switch]
        $IncludeResults
    )
    process {
        if (-not $Id) {
            $Id = $InputObject.Id
        }

        $params = @{
            Slug = "services/app/DeploymentSteps/GetDeploymentStepForEdit"
            Body = @{ Id = $Id }
        }

        $DeploymentStep = Invoke-CCMApi @params

        if ($IncludeResults) {
            # TODO: Check this overwrites correctly
            $params = @{
                Slug = "services/app/DeploymentStepComputers/GetAllByDeploymentStepId"
                Body = @{ deploymentStepId = $_.id }
            }
            $DeploymentStep.deploymentStepComputers = (Invoke-CCMApi @params).result
        }

        $DeploymentStep
    }
}
