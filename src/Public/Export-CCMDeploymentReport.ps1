function Export-CCMDeploymentReport {
    <#
    .SYNOPSIS
    Downloads a deployment report from Central Management. This will be saved in the path you specify for OutputFolder

    .DESCRIPTION
    Downloads a deployment report from Central Management in PDF or Excel format. The file is saved to the OutputFolder

    .PARAMETER Deployment
    The deployment from which to generate and download a report

    .PARAMETER Type
    The type  of report, either PDF or Excel

    .PARAMETER OutputFolder
    The path to save the report too

    .EXAMPLE
    Export-CCMDeploymentReport -Deployment 'Complex' -Type PDF -OutputFolder C:\temp\

    .EXAMPLE
    Export-CCMDeploymentReport -Deployment 'Complex -Type Excel -OutputFolder C:\CCMReports
    #>
    [CmdletBinding(HelpUri = "https://docs.chocolatey.org/en-us/central-management/chococcm/functions/exportccmdeploymentreport")]
    param(
        [Parameter(Mandatory)]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                (Get-CCMDeployment -All).Name.Where{ $_ -match "^$WordToComplete" }
            }
        )]
        [string]
        $Deployment,

        [Parameter(Mandatory)]
        [ValidateSet('PDF', 'Excel')]
        [string]
        $Type,

        [Parameter(Mandatory)]
        [ValidateScript( { Test-Path $_ })]
        [string]
        $OutputFolder
    )

    end {
        $deployId = Get-CCMDeployment -Name $Deployment | Select-Object -ExpandProperty Id

        $Url = switch ($Type) {
            'PDF' {
                "services/app/DeploymentPlans/GetDeploymentPlanDetailsToPdf?deploymentPlanId=$deployId"
            }
            'Excel' {
                "services/app/DeploymentPlans/GetDeploymentPlanDetailsToExcel?deploymentPlanId=$deployId"
            }
        }

        try {
            $record = Invoke-CCMApi -Url $Url -ErrorAction Stop

            $fileName = $record.result.fileName
            $fileType = $record.result.fileType
            $fileToken = $record.result.fileToken
        }
        catch {
            throw $_.Exception
        }

        # TODO: Contemplate if this operation is frequent enough to merit adding OutFile
        $downloadParams = @{
            Uri         = "$($protocol)://$hostname/File/DownloadTempFile?fileType=$fileType&fileToken=$fileToken&fileName=$fileName"
            OutFile     = "$OutputFolder\$fileName"
            WebSession  = $Session
            Method      = "GET"
            ContentType = $fileType
        }

        try {
            $dl = Invoke-RestMethod @downloadParams -ErrorAction Stop
        }
        catch {
            $_.ErrorDetails
        }
    }
}
