function Get-CCMSoftware {
    <#
    .SYNOPSIS
    Returns information about software tracked inside of CCM

    .DESCRIPTION
    Return information about each piece of software managed across all of your estate inside Central Management

    .PARAMETER Software
    Return information about a specific piece of software by friendly name

    .PARAMETER Package
    Return information about a specific package

    .PARAMETER Id
    Return information about a specific piece of software by id

    .EXAMPLE
    Get-CCMSoftware

    .EXAMPLE
    Get-CCMSoftware -Software 'VLC Media Player'

    .EXAMPLE
    Get-CCMSoftware -Package vlc

    .EXAMPLE
    Get-CCMSoftware -Id 37

    .NOTES
    #>
    [CmdletBinding(DefaultParameterSetname = "All", HelpUri = "https://docs.chocolatey.org/en-us/central-management/chococcm/functions/getccmsoftware")]
    param(
        [Parameter(Mandatory, ParameterSetName = "Software")]
        [string]
        $Software,

        [Parameter(Mandatory, ParameterSetName = "Package")]
        [string]
        $Package,

        [Parameter(Mandatory, ParameterSetName = "Id")]
        [int]
        $Id
    )
    end {
        if (-not $Id) {
            $Records = Invoke-CCMApi -Slug "api/services/app/Software/GetAll"
        }

        switch ($PSCmdlet.ParameterSetName) {
            "Software" {
                $IDs = $Records.result.items.Where{ $_.name -eq "$Software" }.Id
            }

            "Package" {
                $IDs = $Records.result.items.Where{ $_.packageId -eq "$Package" }.Id
            }

            "Id" {
                $IDs = @($Id)
            }

            default {
                if ($IDs) {
                    $Records = foreach ($Id in $IDs) {
                        Invoke-CCMApi "services/app/ComputerSoftware/GetAllPagedBySoftwareId?filter=&softwareId=$Id&skipCount=0&maxResultCount=500"
                    }
                }
                # TODO: Test that this works as expected.
                $Records.result.items
            }
        }
    }
}
