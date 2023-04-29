function Set-CCMGroup {
    <#
    .SYNOPSIS
    Change information about a group in Chocolatey Central Management

    .DESCRIPTION
    Change the name or description of a Group in Chocolatey Central Management

    .PARAMETER Group
    The Group to edit

    .PARAMETER NewName
    The new name of the group

    .PARAMETER NewDescription
    The new description of the group

    .EXAMPLE
    Set-CCMGroup -Group Finance -Description 'Computers in the finance division'

    .EXAMPLE
    Set-CCMGroup -Group IT -NewName TheBestComputers

    .EXAMPLE
    Set-CCMGroup -Group Test -NewName NewMachineImaged -Description 'Group for freshly imaged machines needing a baseline package pushed to them'
    #>
    [CmdletBinding(HelpUri = "https://docs.chocolatey.org/en-us/central-management/chococcm/functions/setccmgroup")]
    param(
        [Parameter(Mandatory)]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                (Get-CCMGroup).Name.Where{ $_ -match "^$WordToComplete" }
            }
        )]
        [Alias("Group")]
        [string]
        $Name,

        [Parameter()]
        [string]
        $NewName,

        [Parameter()]
        [string]
        $NewDescription
    )
    process {
        $existing = Get-CCMGroupMember -Group $Name

        if ($NewName) {
            $Name = $NewName
        }
        else {
            $Name = $existing.name
        }

        if ($NewDescription) {
            $Description = $NewDescription
        }
        else {
            $Description = $existing.description
        }

        $ccmParams = @{
            Slug   = "services/app/Groups/CreateOrEdit"
            Method = "POST"
            Body   = @{
                Id          = $existing.id
                Name        = $Name
                Description = $Description
                Groups      = $existing.Groups
                Computers   = $existing.Computers
            }
        }

        try {
            $null = Invoke-CCMApi @ccmParams -ErrorAction Stop
        }
        catch {
            throw $_.Exception.Message
        }
    }
}
