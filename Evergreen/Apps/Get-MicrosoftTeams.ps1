Function Get-MicrosoftTeams {
    <#
        .SYNOPSIS
            Returns the available Microsoft Teams versions and download URIs.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]),

        [Parameter(Mandatory = $False, Position = 1)]
        [ValidateNotNull()]
        [System.String] $Filter
    )

    ForEach ($ring in $res.Get.Update.Rings.GetEnumerator()) {

        # Read the JSON and convert to a PowerShell object. Return the release version of Teams
        $Uri = $res.Get.Update.Uri -replace $res.Get.Update.ReplaceText, $res.Get.Update.Rings[$ring.Key]
        $params = @{
            Uri       = $Uri
            UserAgent = $res.Get.Update.UserAgent
        }
        $updateFeed = Invoke-RestMethodWrapper @params

        # Read the JSON and build an array of platform, channel, version
        If ($Null -ne $updateFeed) {

            # Match version number
            $Version = [RegEx]::Match($updateFeed.releasesPath, $res.Get.Update.MatchVersion).Captures.Groups[1].Value

            # Step through each architecture
            ForEach ($item in $res.Get.Download.Uri.GetEnumerator()) {

                # Build the output object
                $PSObject = [PSCustomObject] @{
                    Version      = $Version
                    Ring         = $ring.Name
                    Architecture = $item.Name
                    URI          = $res.Get.Download.Uri[$item.Key] -replace $res.Get.Download.ReplaceText, $Version
                }

                # Output object to the pipeline
                Write-Output -InputObject $PSObject
            }
        }
    }
}
