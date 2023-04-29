function Get-CCMGroup {
    <#
    .SYNOPSIS
    Returns group information for your CCM installation

    .DESCRIPTION
    Returns information about the groups created in your CCM Installation

    .PARAMETER Group
    Returns group with the provided name

    .PARAMETER Id
    Returns group withe the provided id

    .EXAMPLE
    Get-CCMGroup

    .EXAMPLE
    Get-CCMGroup -Id 1

    .EXAMPLE
    Get-CCMGroup -Group 'Web Servers'

    #>
    [CmdletBinding(DefaultParameterSetName = "All", HelpUri = "https://docs.chocolatey.org/en-us/central-management/chococcm/functions/getccmgroup")]
    param(
        [Parameter(Mandatory, ParameterSetName = "Group")]
        [Alias('Group')]
        [string[]]
        $Name,

        [Parameter(Mandatory, ParameterSetName = "Id")]
        [String[]]
        $Id
    )
    process {
        if (-not $Id) {
            $Records = Invoke-CCMApi -Slug "services/app/Groups/GetAll"
        }

        switch ($PSCmdlet.ParameterSetName) {
            "Group" {
                $Records.result = $Records.result | Where-Object { $_.name -in $Name }
            }
            "Id" {
                $Records = Invoke-CCMApi -Slug "services/app/Groups/GetGroupForEdit?Id=$Id"
            }
            default {
                $Records.result
            }
        }
    }
}
