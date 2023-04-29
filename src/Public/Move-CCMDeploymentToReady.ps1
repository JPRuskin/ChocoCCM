function Move-CCMDeploymentToReady {
    <#
    .SYNOPSIS
    Moves a  deployment to Ready state

    .DESCRIPTION
    Moves a Deployment to the Ready state so it can start

    .PARAMETER Deployment
    The deployment  to  move

    .EXAMPLE
    Move-CCMDeploymentToReady -Deployment 'Upgrade Outdated VLC'

    .EXAMPLE
    Move-CCMDeploymenttoReady -Deployment 'Complex Deployment'

    #>
    [CmdletBinding(HelpUri = "https://docs.chocolatey.org/en-us/central-management/chococcm/functions/moveccmdeploymenttoready")]
    param(
        [Parameter(Mandatory, ParameterSetName = "Name")]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                (Get-CCMDeployment -All).name.Where{ $_ -match "^$WordToComplete" }
            }
        )]
        [Alias('Deployment')]
        [string]
        $Name,

        [Parameter(Mandatory, ParameterSetName = "Id")]
        $Id = (Get-CCMDeployment -Name $Name).id
    )
    end {
        $ccmParams = @{
            Slug   = "services/app/DeploymentPlans/MoveToReady"
            Method = "POST"
            Body   = @{ id = "$id" }
        }

        try {
            $null = Invoke-CCMApi @ccmParams -ErrorAction Stop
        }
        catch {
            throw $_.Exception.Message
        }
    }
}
