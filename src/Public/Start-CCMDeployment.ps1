function Start-CCMDeployment {
    <#
    .SYNOPSIS
    Starts a deployment

    .DESCRIPTION
    Starts the specified deployment in Central  Management

    .PARAMETER Deployment
    The deployment to start

    .EXAMPLE
    Start-CCMDeployment -Name 'Upgrade Outdated VLC'

    .EXAMPLE
    Start-CCMDeployment -Name 'Complex Deployment'

    .EXAMPLE
    Get-CCMDeployment | Where Name -like "Adobe*" | Start-CCMDeployment
    #>
    [CmdletBinding(HelpUri = "https://docs.chocolatey.org/en-us/central-management/chococcm/functions/startccmdeployment")]
    param(
        [Parameter(Mandatory, Position = 0, ParameterSetName = "Name")]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                (Get-CCMDeployment).name.Where{ $_ -match "^$WordToComplete" }
            }
        )]
        [Alias("Deployment")]
        [string]
        $Name,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = "Id")]
        $Id = (Get-CCMDeployment -Name $Deployment).id
    )
    end {
        $ccmParams = @{
            Slug   = "services/app/DeploymentPlans/Start"
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
