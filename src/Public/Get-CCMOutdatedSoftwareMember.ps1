function Get-CCMOutdatedSoftwareMember {
    <#
    .SYNOPSIS
    Returns computers with the requested outdated software. To see outdated software information use Get-CCMOutdatedSoftware

    .DESCRIPTION
    Returns the computers with the requested outdated software. To see outdated software information use Get-CCMOutdatedSoftware

    .PARAMETER Software
    The software to query. Software here refers to what would show up in Programs and Features on a machine.
    Example: If you have VLC installed, this shows as 'VLC Media Player' in Programs and Features.

    .PARAMETER Package
    This is the Chocolatey package name to search for.

    .EXAMPLE
    Get-CCMOutdatedSoftwareMember -Software 'VLC Media Player'

    .EXAMPLE
    Get-CCMOutdatedSoftwareMember -Package vlc
    #>
    [CmdletBinding(HelpUri = "https://docs.chocolatey.org/en-us/central-management/chococcm/functions/getccmoutdatedsoftwaremember")]
    param(
        [Parameter()]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                (Get-CCMSoftware -All | Where-Object { $_.isOutdated -eq $true }).Name.Where{ $_ -match "^$WordToComplete" }
            }
        )]
        [string]
        $Software,

        [Parameter()]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                (Get-CCMSoftware -All | Where-Object { $_.isOutdated -eq $true }).packageId.Where{ $_ -match "^$WordToComplete" }
            }
        )]
        [string]
        $Package
    )
    process {
        if ($Software) {
            $id = Get-CCMSoftware -Software $Software | Select-Object -ExpandProperty softwareId
        }

        if ($Package) {
            $id = Get-CCMSoftware -Package $Package | Select-Object -ExpandProperty softwareId
        }

        $id | ForEach-Object {
            $ccmParams = @{
                Slug = "services/app/ComputerSoftware/GetAllPagedBySoftwareId?filter=&softwareId=$($_)&skipCount=0&maxResultCount=100"
            }

            try {
                $Response = Invoke-CCMApi @ccmParams -ErrorAction Stop
            }
            catch {
                $_.Exception.Message
            }

            $Response.result.items | ForEach-Object {
                [pscustomobject]@{
                    softwareId     = $_.softwareId
                    software       = $_.software.name
                    packageName    = $_.software.packageId
                    packageVersion = $_.software.packageVersion
                    name           = $_.computer.name
                    friendlyName   = $_.computer.friendlyName
                    ipaddress      = $_.computer.ipaddress
                    fqdn           = $_.computer.fqdn
                    computerid     = $_.computer.id
                }
            }
        }
    }
}
