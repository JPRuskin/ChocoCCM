function Invoke-CCMApi {
    <#
        .SYNOPSIS
            Calls the CCM API

        .EXAMPLE
            Invoke-CCMApi
    #>
    [Alias('ccm')]
    [CmdletBinding(DefaultParameterSetName = "Combine")]
    param(
        # The hostname (and port) of the machine in question.
        [Parameter(ParameterSetName = "Combine")]
        [ValidateNotNullOrEmpty()]
        [string]$HostName = $script:HostName,

        # The portion of the API call after /api/
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = "Combine")]
        [string]$Slug,

        # The full URL of the API call
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = "URL")]
        [string]$Uri = "$($script:Protocol)://$($HostName.TrimEnd('/'))/api/$($Slug -replace '^/api/?')",

        # The Web Request method to use
        [Microsoft.PowerShell.Commands.WebRequestMethod]$Method = "GET",

        # The content type, if submitting body
        [string]$ContentType = "application/json",

        # The body to submit with the request
        [Object]$Body
    )
    begin {
        if (-not $script:Session) {
            Connect-CCMServer
            # TODO: Add handling / timeout for non-active sessions?
        }
    }
    process {
        $RestArguments = @{
            Uri        = $Uri
            Method     = $Method
            WebSession = $script:Session
        }

        if ((Get-Command Invoke-RestMethod).Parameters.ContainsKey("UseBasicParsing")) {
            $RestArguments.UseBasicParsing = $true
        }

        if ($Body) {
            $RestArguments.ContentType = $ContentType
            $RestArguments.Body = switch ($ContentType) {
                "application/json" {
                    $Body | ConvertTo-Json -Depth 5  # ? Consider handling the difference between 5 and 7 with single item arrays
                }
                "application/x-www-form-urlencoded" {
                    $Body  # This seems to not happen ever, other than login
                }
            }
        }

        Invoke-RestMethod @RestArguments
    }
}