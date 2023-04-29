function Remove-CCMDeployment {
    <#
    .SYNOPSIS
    Removes a deployment plan

    .DESCRIPTION
    Removes the Deployment Plan selected from a Central Management installation

    .PARAMETER Deployment
    The Deployment to  delete

    .EXAMPLE
    Remove-CCMDeployment -Name 'Super Complex Deployment'

    .EXAMPLE
    Remove-CCMDeployment -Name 'Deployment Alpha' -Confirm:$false

    #>
    [CmdletBinding(ConfirmImpact = "High", SupportsShouldProcess, HelpUri = "https://docs.chocolatey.org/en-us/central-management/chococcm/functions/removeccmdeployment")]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                (Get-CCMDeployment -All).Name.Where{ $_ -match "^$WordToComplete" }
            }
        )]
        [Alias("Deployment")]
        [string[]]
        $Name
    )
    begin {
        $deployId = [System.Collections.Generic.List[string]]::new()
    }
    process {
        Get-CCMDeployment | Where-Object { $_.Name -in $Name } | ForEach-Object { $deployId.Add($_.Id) }

        # ? Why are we doing it like this?
        $deployId | ForEach-Object {
            if ($PSCmdlet.ShouldProcess("$Name", "DELETE")) {
                $ccmParams = @{
                    Slug   = "services/app/DeploymentPlans/Delete?Id=$($_)"
                    Method = "DELETE"
                }

                Invoke-CCMApi @ccmParams
            }
        }
    }
}
