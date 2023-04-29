function Set-CCMNotificationStatus {
    <#
    .SYNOPSIS
    Turn notifications on or off in CCM

    .DESCRIPTION
    Manage your notification settings in Central Management. Currently only supports On, or Off

    .PARAMETER Enable
    Enables notifications

    .PARAMETER Disable
    Disables notifications

    .EXAMPLE
    Set-CCMNotificationStatus -Enable

    .EXAMPLE
    Set-CCMNotificationStatus -Disable

    #>
    [CmdletBinding(HelpUri = "https://docs.chocolatey.org/en-us/central-management/chococcm/functions/setccmnotificationstatus")]
    param(
        [Parameter(Mandatory, ParameterSetName = "Enabled")]
        [switch]
        $Enable,

        [Parameter(Mandatory, ParameterSetName = "Disabled")]
        [switch]
        $Disable
    )
    end {
        switch ($PSCmdlet.ParameterSetName) {
            'Enabled' {
                $status = $true
            }
            'Disabled' {
                $status = $false
            }
        }

        $ccmParams = @{
            Slug   = "services/app/Notification/UpdateNotificationSettings"
            Method = "PUT"
            Body   = @{
                receiveNotifications = $status
                notifications        = @(
                    @{
                        name         = "App.NewUserRegistered"
                        isSubscribed = $true
                    }
                )
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
