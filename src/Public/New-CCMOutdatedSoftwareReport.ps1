function New-CCMOutdatedSoftwareReport {
    <#
    .SYNOPSIS
    Create a new Outdated Software Report in Central Management

    .DESCRIPTION
    Create a new Outdated Software Report in Central Management

    .EXAMPLE
    New-CCMOutdatedSoftwareReport

    .NOTES
    Creates a new report named with a creation date timestamp in UTC format
    #>
    [CmdletBinding(HelpUri = "https://docs.chocolatey.org/en-us/central-management/chococcm/functions/newccmoutdatedsoftwarereport")]
    param()
    end {
        try {
            $null = Invoke-CCMApi -Slug "services/app/OutdatedReports/Create" -ErrorAction Stop
        }
        catch {
            throw $_.Exception.Message
        }

        #? Should we return the report ID?
    }
}
