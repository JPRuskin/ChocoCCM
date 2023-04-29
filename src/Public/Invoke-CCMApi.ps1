function Invoke-CCMApi {
    <#
        .SYNOPSIS
            Calls the CCM API

        .EXAMPLE
            Invoke-CcmApi
    #>
    [Alias('ccm')]
    [CmdletBinding()]
    param(
        # The hostname (and port) of the machine in question.
        [Parameter(ParameterSetName = "Combine")]
        [ValidateNotNullOrEmpty()]
        [string]$HostName = $script:HostName,

        # The portion of the API call after /api/
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = "Combine")]
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

        if ($Body) {
            $RestArguments.ContentType = $ContentType
            $RestArguments.Body = switch ($ContentType) {
                "application/json" {$Body | ConvertTo-Json}
                "application/x-www-form-urlencoded" {$Body}  # This seems to not happen ever
            }
        }

        Invoke-RestMethod @RestArguments
    }
}