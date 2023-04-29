function Stop-CCMDeployment {
    <#
    .SYNOPSIS
    Stops a running CCM Deployment

    .DESCRIPTION
    Stops a deployment current running in Central Management

    .PARAMETER Deployment
    The deployment to Stop

    .EXAMPLE
    Stop-CCMDeployment -Deployment 'Upgrade VLC'

    #>
    [cmdletBinding(ConfirmImpact = "high", SupportsShouldProcess, HelpUri = "https://docs.chocolatey.org/en-us/central-management/chococcm/functions/stopccmdeployment")]
    param(
        [Parameter(Mandatory, Position = 0, ParameterSetName = "Name")]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                (Get-CCMDeployment).Name.Where{ $_ -match "^$WordToComplete" }
            }
        )]
        [Alias("Deployment")]
        [string]
        $Name,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = "Id")]
        $Id = (Get-CCMDeployment -Name $Name).Id
    )
    process {
        if ($PSCmdlet.ShouldProcess("$Deployment", "CANCEL")) {
            $irmParams = @{
                Slug   = "services/app/DeploymentPlans/Cancel"
                Method = "POST"
                Body   = @{ id = "$Id" }
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
