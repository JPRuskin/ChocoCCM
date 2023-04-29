function Get-CCMComputer {
    <#
    .SYNOPSIS
    Returns information about computers in CCM

    .DESCRIPTION
    Query for all, or by computer name/id to retrieve information about the system as reported in Central Management

    .PARAMETER Computer
    Returns the specified computer(s)

    .PARAMETER Id
    Returns the information for the computer with the specified id

    .EXAMPLE
    Get-CCMComputer

    .EXAMPLE
    Get-CCMComputer -Computer web1

    .EXAMPLE
    Get-CCMComputer -Id 13

    .NOTES

    #>
    [CmdletBinding(DefaultParameterSetName = "All", HelpUri = "https://docs.chocolatey.org/en-us/central-management/chococcm/functions/getccmcomputer")]
    param(
        [Parameter(Mandatory, ParameterSetName = "Computer")]
        [string[]]
        $Computer,

        [Parameter(Mandatory, ParameterSetName = "Id")]
        [uint]
        $Id
    )
    end {
        if (-not $Id) {
            $Records = Invoke-CCMApi -Slug "services/app/Computers/GetAll"
        }
        switch ($PSCmdlet.ParameterSetName) {
            "Computer" {
                [pscustomobject]$records.result | Where-Object { $_.name -in $Computer }
                # TODO: Check that we didn't want the potential fuzziness here, e.g. matching "local1", "local2" etc when called with "oca" only
            }
            "Id" {
                Invoke-CCMApi -Slug "services/app/Computers/GetComputerForEdit?Id=$Id"
            }
            default {
                $records.result
            }
        }
    }
}
