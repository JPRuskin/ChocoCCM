function Get-CCMOutdatedSoftwareReport {
    <#
    .SYNOPSIS
    List all Outdated Software Reports generated in Central Management

    .DESCRIPTION
    List all Outdated Software Reports generated in Central Management

    .EXAMPLE
    Get-CCMOutdatedSoftwareReport
    #>
    [CmdletBinding(HelpUri = "https://docs.chocolatey.org/en-us/central-management/chococcm/functions/getccmoutdatedsoftwarereport")]
    param()
    process {
        try {
            $Response = Invoke-CCMApi -Slug "services/app/Reports/GetAllPaged?reportTypeFilter=1"
        }
        catch {
            throw $_.Exception.Message
        }

        $Response.result.items | ForEach-Object {
            [pscustomobject]@{
                reportType   = $_.report.reportType -as [String]
                creationTime = $_.report.creationTime -as [String]
                id           = $_.report.id -as [string]
            }
        }
    }
}
