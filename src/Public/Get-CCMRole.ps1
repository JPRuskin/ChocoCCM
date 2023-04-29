function Get-CCMRole {
    <#
    .SYNOPSIS
    Get roles available in Chocolatey Central Management

    .DESCRIPTION
    Return information about roles available in Chocolatey Central Management

    .PARAMETER Name
    The name of a role to query

    .EXAMPLE
    Get-CCMRole

    .EXAMPLE
    Get-CCMRole -Name CCMAdmin
    #>
    [CmdletBinding(HelpUri = "https://docs.chocolatey.org/en-us/central-management/chococcm/functions/getccmrole")]
    param(
        [Parameter(ParameterSetName = "Name")]
        [string]
        $Name
    )
    end {
        try {
            # TODO: Test this function
            # Is this ?permission= okay?
            $AllRoles = (Invoke-CCMApi -Slug "services/app/Role/GetRoles?permission=" -ErrorAction Stop).result.items
        }
        catch {
            throw $_.Exception.Message
        }

        switch ($PSCmdlet.ParameterSetName) {
            'Name' {
                $AllRoles | Where-Object { $_.name -eq $Name }
            }
            default {
                # Does this not return everything after the role you want? Do we need an All / default parameter set?
                $AllRoles
            }
        }
    }
}
