function New-CCMDeployment {
    <#
    .SYNOPSIS
    Create a new CCM Deployment Plan

    .DESCRIPTION
    Creates a new CCM Deployment. This is just a shell. You'll need to add steps with New-CCMDeploymentStep.

    .PARAMETER Name
    The name for the deployment

    .EXAMPLE
    New-CCMDeployment -Name 'This is awesome'

    #>
    [CmdletBinding(HelpUri = "https://docs.chocolatey.org/en-us/central-management/chococcm/functions/newccmdeployment")]
    param(
        [Parameter(Mandatory)]
        [string]
        $Name
    )
    end {
        $ccmParams = @{
            Slug   = "services/app/DeploymentPlans/CreateOrEdit"
            Method = "POST"
            Body   = @{ Name = "$Name" }
        }

        try {
            $Response = Invoke-CCMApi @ccmParams -ErrorAction Stop
        }
        catch {
            throw $_.Exception.Message
        }

        [pscustomobject]@{
            name = $Name
            id   = $Response.result.id
        }
    }
}
