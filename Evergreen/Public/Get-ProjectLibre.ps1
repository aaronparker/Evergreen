Function Get-ProjectLibre {
    <#
        .SYNOPSIS
            Get the current version and download URL for ProjectLibre.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-ProjectLibre

            Description:
            Returns the current version and download URLs for ProjectLibre.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Get latest version and download latest release via SourceForge API
    $iwcParams = @{
        Uri         = $res.Get.Update.Uri
        ContentType = $res.Get.Update.ContentType
    }
    $Content = Invoke-WebContent @iwcParams

    # Convert the returned release data into a useable object with Version, URI etc.
    $params = @{
        Content      = $Content
        Download     = $res.Get.Download
        MatchVersion = $res.Get.MatchVersion
    }
    $object = ConvertFrom-SourceForgeReleasesJson @params
    Write-Output -InputObject $object
}