function Add-CCMGroup {
    <#
    .SYNOPSIS
    Adds a group to Central Management

    .DESCRIPTION
    Deployments in Central Management revolve around Groups. Before you can execute a deployment you must define a target group of computers the Deployment will execute on.
    Use this function to create new groups in your Central Management system

    .PARAMETER Name
    The name you wish to give the group

    .PARAMETER Description
    A short description of the group

    .PARAMETER Group
    The group(s) to include as members

    .PARAMETER Computer
    The computer(s) to include as members

    .EXAMPLE
    Add-CCMGroup -Name PowerShell -Description "I created this via the ChocoCCM module" -Computer pc1,pc2

    .EXAMPLE
    Add-CCMGroup -Name PowerShell -Description "I created this via the ChocoCCM module" -Group Webservers
    #>
    [CmdletBinding(HelpUri = "https://docs.chocolatey.org/en-us/central-management/chococcm/functions/addccmgroup")]
    param(
        [Parameter(Mandatory)]
        [string]
        $Name,

        [Parameter()]
        [string]
        $Description,

        [Parameter()]
        [string[]]
        $Group,

        [Parameter()]
        [string[]]
        $Computer
    )

    begin {
        if (-not $Session) {
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }

        $computers = Get-CCMComputer
        $groups = Get-CCMGroup

        $ComputerCollection = foreach ($item in $Computer) {
            if ($item -in $current.computers.computerName) {
                Write-Warning "Skipping $item, already exists"
            }
            else {
                $Cresult = $computers | Where-Object Name -EQ $item | Select-Object -ExpandProperty Id
                # Drop object into $computerCollection
                [pscustomobject]@{ computerId = $Cresult }
            }
        }

        $GroupCollection = foreach ($item in $Group) {
            if ($item -in $current.groups.subGroupName) {
                Write-Warning "Skipping $item, already exists"
            }
            else {
                $Gresult = $groups | Where-Object Name -EQ $item | Select-Object -ExpandProperty Id
                # Drop object into $computerCollection
                [pscustomobject]@{ subGroupId = $Gresult }
            }
        }

        $processedComputers = $ComputerCollection
        $processedGroups = $GroupCollection
    }

    process {
        $ccmParams = @{
            Slug   = "services/app/Groups/CreateOrEdit"
            Method = "POST"
            Body   = @{
                Name        = $Name
                Description = $Description
                Groups      = @($processedGroups)
                Computers   = @($processedComputers)
            }
        }

        Write-Verbose $ccmParams.Body

        try {
            $null = Invoke-RestMethod @ccmParams -ErrorAction Stop  # TODO: Check the output of this, to see if we can pass back actual values?
        } catch {
            throw $_.Exception.Message
        }

        # TODO: Implement CCMGroup class and/or formatter
        # TODO: See if these values make sense
        # TODO: Evaluate groups / based on the pluralisation of the value, e.g. should we use processedGroups and computers
        [pscustomobject]@{
            name        = $Name
            description = $Description
            groups      = $Group
            computers   = $Computer
        }
    }
}
