function Get-CCMOutdatedSoftwareReportDetail {
    <#
    .SYNOPSIS
    View detailed information about an Outdated Software Report

    .DESCRIPTION
    Return report details from an Outdated Software Report in Central Management

    .PARAMETER Report
    The report to query

    .EXAMPLE
    Get-CCMOutdatedSoftwareReportDetail -Report '7/4/2020 6:44:40 PM'

    #>
    [CmdletBinding(HelpUri = "https://docs.chocolatey.org/en-us/central-management/chococcm/functions/getccmoutdatedsoftwarereportdetail")]
    param(
        [Parameter(Mandatory)]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                (Get-CCMOutdatedSoftwareReport).creationTime.Where{ $_ -match "^$WordToComplete" }
            }
        )]
        [string]
        $Report
    )
    process {
        $ReportId = Get-CCMOutdatedSoftwareReport | Where-Object { $_.creationTime -eq "$Report" } | Select-Object -ExpandProperty id

        try {
            $Response = Invoke-CCMApi -Slug "services/app/OutdatedReports/GetAllByReportId?reportId=$reportId&sorting=outdatedReport.packageDisplayText%20asc&skipCount=0&maxResultCount=200" -ErrorAction Stop
        }
        catch {
            throw $_.Exception.Message
        }

        $Response.result.items.outdatedReport
    }
}
