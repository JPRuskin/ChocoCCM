function New-CCMDeploymentStep {
    <#
    .SYNOPSIS
    Adds a Deployment Step to a Deployment Plan

    .DESCRIPTION
    Adds both Basic and Advanced steps to a Deployment Plan

    .PARAMETER Deployment
    The Deployment where the step will be added

    .PARAMETER Name
    The Name of the step

    .PARAMETER TargetGroup
    The group(s) the step will target

    .PARAMETER ExecutionTimeoutSeconds
    How long to wait for the step to timeout. Defaults to 14400 (4 hours)

    .PARAMETER FailOnError
    Fail the step if there is an error. Defaults to True

    .PARAMETER RequireSuccessOnAllComputers
    Ensure all computers are successful before moving to the next step.

    .PARAMETER ValidExitCodes
    Valid exit codes your script can emit. Default values are: '0','1605','1614','1641','3010'

    .PARAMETER Type
    Either a Basic or Advanced Step

    .PARAMETER ChocoCommand
    Select from Install,Upgrade, or Uninstall. Used with a Simple step type.

    .PARAMETER PackageName
    The chocolatey package to use with a simple step.

    .PARAMETER Script
    A scriptblock your Advanced step will use

    .EXAMPLE
    New-CCMDeploymentStep -Deployment PowerShell -Name 'From ChocoCCM' -TargetGroup WebServers -Type Basic -ChocoCommand upgrade -PackageName firefox

    .EXAMPLE
    New-CCMDeploymentStep -Deployment PowerShell -Name 'From ChocoCCM' -TargetGroup All,PowerShell -Type Advanced -Script { $process = Get-Process
>>
>> Foreach($p in $process){
>> Write-Host $p.PID
>> }
>>
>> Write-Host "end"
>>
>> }

    .EXAMPLE
    New-CCMDeploymentStep -Deployment PowerShell -Name 'From ChocoCCM' -TargetGroup All,PowerShell -Type Advanced -Script {(Get-Content C:\script.txt)}

    #>
    [CmdletBinding(HelpUri = "https://docs.chocolatey.org/en-us/central-management/chococcm/functions/newccmdeploymentstep")]
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
        [string]
        $Name,

        [Parameter()]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                (Get-CCMGroup).Name.Where{ $_ -match "^$WordToComplete" -and $_ -notin $FakeBoundParams['TargetGroup'] }
                # TODO: Test that this filters correctly
            }
        )]
        [string[]]
        $TargetGroup = @(),

        [Parameter()]
        [string]
        $ExecutionTimeoutSeconds = '14400',

        [Parameter()]
        [switch]
        $FailOnError = $true,

        [Parameter()]
        [switch]
        $RequireSuccessOnAllComputers,

        [Parameter()]
        [string[]]
        $ValidExitCodes = @('0', '1605', '1614', '1641', '3010'),

        [Parameter(Mandatory, ParameterSetName = "StepType")]
        [Parameter(Mandatory, ParameterSetName = "Basic")]
        [Parameter(Mandatory, ParameterSetName = "Advanced")]
        [ValidateSet('Basic', 'Advanced')]
        [string]
        $Type,

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
    end {
        $Body = @{
            Name                         = "$Name"
            DeploymentPlanId             = "$(Get-CCMDeployment -Name $Deployment | Select-Object -ExpandProperty Id)"
            DeploymentStepGroups         = @(
                Get-CCMGroup -Group $TargetGroup | Select-Object Name, Id | ForEach-Object {
                    [pscustomobject]@{ groupId = $_.id; groupName = $_.name }
                }
            )
            ExecutionTimeoutInSeconds    = "$ExecutionTimeoutSeconds"
            RequireSuccessOnAllComputers = "$RequireSuccessOnAllComputers"
            failOnError                  = "$FailOnError"
            validExitCodes               = "$($validExitCodes -join ',')"
        }
        switch ($PSCmdlet.ParameterSetName) {
            'Basic' {
                $Slug = "services/app/DeploymentSteps/CreateOrEdit"
                $Body.script = "$($ChocoCommand.ToLower())|$($PackageName)"
            }
            'Advanced' {
                $Slug = "services/app/DeploymentSteps/CreateOrEditPrivileged"
                $Body.script = "$($Script.ToString())"
            }
        }

        $ccmParams = @{
            Slug   = $Slug
            Method = "POST"
            Body   = $Body
        }

        try {
            $null = Invoke-CCMApi @ccmParams -ErrorAction Stop
        }
        catch {
            throw $_.Exception.Message
        }
    }
}
