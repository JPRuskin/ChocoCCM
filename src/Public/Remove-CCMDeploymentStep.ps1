function Remove-CCMDeploymentStep {
    <#
    .SYNOPSIS
    Removes a deployment plan

    .DESCRIPTION
    Removes the Deployment Plan selected from a Central Management installation

    .PARAMETER Deployment
    The Deployment to  remove a step from

    .PARAMETER Step
    The Step to remove

    .EXAMPLE
    Remove-CCMDeploymentStep -Name 'Super Complex Deployment' -Step 'Kill web services'

    .EXAMPLE
    Remove-CCMDeploymentStep -Name 'Deployment Alpha' -Step 'Copy Files' -Confirm:$false

    #>
    [CmdletBinding(ConfirmImpact = "High", SupportsShouldProcess, HelpUri = "https://docs.chocolatey.org/en-us/central-management/chococcm/functions/removeccmdeploymentstep")]
    param(
        [Parameter(Mandatory)]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                (Get-CCMDeployment).Name.Where{ $_ -match "^$WordToComplete" }
            }
        )]
        [string]
        $Deployment,

        [Parameter(Mandatory)]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                (Get-CCMDeployment -Name $($FakeBoundParams.Deployment)).deploymentSteps.Name.Where{ $_ -match "^$WordToComplete" }
            }
        )]
        [string]
        $Step
    )
    end {
        $deployId = Get-CCMDeployment -Name $Deployment | Select-Object -ExpandProperty Id
        $deploymentSteps = Get-CCMDeployment -Id $deployId | Select-Object deploymentSteps
        $stepId = $deploymentSteps.deploymentSteps | Where-Object { $_.Name -eq "$Step" } | Select-Object -ExpandProperty id

        if ($PSCmdlet.ShouldProcess("$Step", "DELETE")) {
            $null = Invoke-CCMApi -Slug "services/app/DeploymentSteps/Delete?Id=$stepId" -Method Delete
        }
    }
}
