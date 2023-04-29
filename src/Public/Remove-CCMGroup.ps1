function Remove-CCMGroup {
    <#
    .SYNOPSIS
    Removes a CCM group

    .DESCRIPTION
    Removes a group from Chocolatey Central Management

    .PARAMETER Group
    The group(s) to delete

    .EXAMPLE
    Remove-CCMGroup -Group WebServers

    .EXAMPLE
    Remove-CCMGroup -Group WebServer,TestAppDeployment

    .EXAMPLE
    Remove-CCMGroup -Group PilotPool -Confirm:$false

    #>
    [CmdletBinding(ConfirmImpact = "High", SupportsShouldProcess, HelpUri = "https://docs.chocolatey.org/en-us/central-management/chococcm/functions/removeccmdeploymentstep")]
    param(
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                (Get-CCMGroup -All).Name.Where{ $_ -match "^$WordToComplete" }
            }
        )]
        [Alias('Group')]
        [string[]]
        $Name
    )
    end {
        $Name | ForEach-Object {
            $Group = Get-CCMGroup -Name $_

            if ($PSCmdlet.ShouldProcess("group '$($Group.Name)' with Id '$($Group.Id)'", "Removing")) {
                try {
                    $null = Invoke-CCMApi -Slug "services/app/Groups/Delete?id=$($Group.Id)" -Method Delete -ErrorAction Stop
                }
                catch {
                    throw $_.Exception.Message
                }
            }
        }
    }
}
