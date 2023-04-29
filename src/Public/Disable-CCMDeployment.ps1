function Disable-CCMDeployment {
    <#
    .SYNOPSIS
    Archive a CCM Deployment. This will move a Deployment to the Archived Deployments section in the Central Management Web UI.

    .DESCRIPTION
    Moves a deployment in Central Management to the archive. This Deployment will no longer be available for use.

    .PARAMETER Deployment
    The deployment to archive

    .EXAMPLE
    Disable-CCMDeployment -Deployment 'Upgrade VLC'

    .EXAMPLE
    Archive-CCMDeployment -Deployment 'Upgrade VLC'

    #>
    [Alias('Archive-CCMDeployment')]
    [CmdletBinding(ConfirmImpact = "High", SupportsShouldProcess, HelpUri = "https://docs.chocolatey.org/en-us/central-management/chococcm/functions/disableccmdeployment")]
    param(
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                (Get-CCMDeployment).Name.Where{ $_ -match "^$WordToComplete" }
            }
        )]
        [string]
        $Deployment
    )
    end {
        $deployId = Get-CCMDeployment -Name $Deployment | Select-Object -ExpandProperty Id

        if ($PSCmdlet.ShouldProcess("$Deployment", "ARCHIVE")) {
            $ccmParams = @{
                Slug   = "services/app/DeploymentPlans/Archive"
                Method = "POST"
                Body   = @{ id = "$deployId" }
            }

            try {
                $null = Invoke-CCMApi @ccmParams -ErrorAction Stop
            }
            catch {
                throw $_.Exception.Message
            }
        }
    }
}
