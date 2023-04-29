function Connect-CCMServer {
    <#
    .SYNOPSIS
    Creates a session to a central management instance

    .DESCRIPTION
    Creates a web session cookie used for other functions in the ChocoCCM module

    .PARAMETER Hostname
    The hostname and port number of your Central Management installation

    .PARAMETER Credential
    The credentials for your Central Management installation. You'll be prompted if left blank

    .EXAMPLE
    Connect-CCMServer -HostName localhost:8090

    .EXAMPLE
    $cred = Get-Credential ; Connect-CCMServer -Hostname localhost:8090 -Credential $cred
    #>
    [CmdletBinding(HelpUri = "https://docs.chocolatey.org/en-us/central-management/chococcm/functions/connectccmserver")]
    param(
        [Parameter(Mandatory, Position = 0)]
        [String]
        $HostName,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter()]
        [switch]
        $UseSSL
    )
    end {
        $Protocol = if ($UseSSL) {
            'https'
        } else {
            'http'
        }

        $LoginArguments = @{
            Uri             = "$($Protocol)://$HostName/Account/Login"
            Method          = "POST"
            ContentType     = 'application/x-www-form-urlencoded'
            SessionVariable = "Session"
            Body            = @{
                usernameOrEmailAddress = "$($Credential.UserName)"
                password               = "$($Credential.GetNetworkCredential().Password)"
            }
        }

        $Result = Invoke-WebRequest @LoginArguments -ErrorAction Stop

        $script:Hostname = $Hostname
        $script:Session = $Session
        $script:Protocol = $protocol
    }
}
