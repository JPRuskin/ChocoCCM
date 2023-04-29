function Set-CCMDeploymentStep {
    <#
    .SYNOPSIS
    Modify a Deployment Step of a Central Management Deployment

    .DESCRIPTION
    Modify a Deployment Step of a Central Management Deployment

    .PARAMETER Deployment
    The Deployment to modify

    .PARAMETER Step
    The step to modify

    .PARAMETER TargetGroup
    Set the target group of the deployment

    .PARAMETER ExecutionTimeoutSeconds
    Modify the execution timeout of the deployment in seconds

    .PARAMETER FailOnError
    Set the FailOnError flag for the deployment step

    .PARAMETER RequireSuccessOnAllComputers
    Set the RequreSuccessOnAllComputers for the deployment step

    .PARAMETER ValidExitCodes
    Set valid exit codes for the deployment

    .PARAMETER ChocoCommand
    For a basic step, set the choco command to execute. Install, Upgrade, or Uninstall

    .PARAMETER PackageName
    For a basic step, the choco package to use in the deployment

    .PARAMETER Script
    For an advanced step, this is a script block of PowerShell code to execute in the step

    .EXAMPLE
    Set-CCMDeploymentStep -Deployment 'Google Chrome Upgrade' -Step 'Upgrade' -TargetGroup LabPCs -ExecutionTimeoutSeconds 14400 -ChocoCommand Upgrade -PackageName googlechrome

    .EXAMPLE
    $stepParams = @{
        Deployment = 'OS Version'
        Step = 'Gather Info'
        TargetGroup = 'US-East servers'
        Script = { $data = Get-WMIObject win32_OperatingSystem
                    [pscustomobject]@{
                        Name = $data.caption
                        Version = $data.version
                    }
        }
    }

    Set-CCMDeploymentStep @stepParams
    #>
    [CmdletBinding(DefaultParameterSetName = "Dumby", HelpUri = "https://docs.chocolatey.org/en-us/central-management/chococcm/functions/setccmdeploymentstep")]
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
                $d = (Get-CCMDeployment -Name $($FakeBoundParams.Deployment)).id
                (Get-CCMDeployment -Id $d).deploymentSteps.Name.Where{ $_ -match "^$WordToComplete" }
            }
        )]
        [string]
        $Step,

        [Parameter()]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                (Get-CCMGroup -All).Name.Where{ $_ -match "^$WordToComplete" }
            }
        )]
        [string[]]
        $TargetGroup,

        [Parameter()]
        [string]
        $ExecutionTimeoutSeconds,

        [Parameter()]
        [switch]
        $FailOnError,

        [Parameter()]
        [switch]
        $RequireSuccessOnAllComputers,

        [Parameter()]
        [string[]]
        $ValidExitCodes,

        [Parameter(Mandatory, ParameterSetName = "Basic")]
        [ValidateSet('Install', 'Upgrade', 'Uninstall')]
        [string]
        $ChocoCommand,

        [Parameter(Mandatory, ParameterSetName = "Basic")]
        [string]
        $PackageName,

        [Parameter(Mandatory, ParameterSetName = "Advanced")]
        [scriptblock]
        $Script
    )

    begin {
        $deployId = Get-CCMDeployment -Name $Deployment | Select-Object -ExpandProperty Id
        $deploymentSteps = Get-CCMDeployment -Id $deployId | Select-Object deploymentSteps
        $stepId = $deploymentSteps.deploymentSteps | Where-Object { $_.Name -eq "$Step" } | Select-Object -ExpandProperty id

        try {
            $existingsteps = Invoke-RestMethod -Slug "services/app/DeploymentSteps/GetDeploymentStepForView?Id=$stepId" -ErrorAction Stop
        }
        catch {
            throw $_.Exception.Message
        }

        $existingsteps = $existingsteps.result.deploymentStep
        $existingsteps
    }
# TODO: YOLO
    process {
        #So many if statements, so little time
        foreach ($param in $PSBoundParameters) {
            $param.Name
            $param.Value
            #$existingsteps.$($param.Key) = $param.Value
        }

        #$existingsteps
    }
}
