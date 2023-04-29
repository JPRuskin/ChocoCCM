function Get-CCMGroupMember {
    <#
    .SYNOPSIS
    Returns information about a CCM group's members

    .DESCRIPTION
    Return detailed group information from Chocolatey Central Management

    .PARAMETER Group
    The Group to query

    .EXAMPLE
    Get-CCMGroupMember -Name "WebServers"

    #>
    [CmdletBinding(HelpUri = "https://docs.chocolatey.org/en-us/central-management/chococcm/functions/getccmgroupmember")]
    param(
        [Parameter(Mandatory)]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                (Get-CCMGroup -All).Name.Where{ $_ -match "^$WordToComplete" }
            }
        )]
        [Alias('Group')]
        [string]
        $Name
    )
    process {
        $Result = Get-CCMGroup -Id (Get-CCMGroup -Group $Name).Id

        [pscustomobject]@{
            Id          = $Result.Id
            Name        = $Result.Name
            Description = $Result.Description
            Groups      = @($Result.Groups | Where-Object { $_ })
            Computers   = @($Result.Computers | Where-Object { $_ })
            CanDeploy   = $Result.isEligibleForDeployments
        }
    }
}
