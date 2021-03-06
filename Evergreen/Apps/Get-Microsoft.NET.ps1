Function Get-Microsoft.NET {
    <#
        .SYNOPSIS
            Returns the available Microsoft .NET Desktop Runtime versions and download URIs.

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

    # Read the version number from the version URI
    ForEach ($Channel in $res.Get.Update.Channels) {
        $Content = Invoke-WebRequestWrapper -Uri ($res.Get.Update.Uri -replace $res.Get.Update.ReplaceText, $Channel)
        If ($Null -ne $Content) {

            # Read last line of the returned content to retrieve the version number
            $Version = (-split $Content)[-1]
            Write-Verbose -Message "$($MyInvocation.MyCommand): found version: $Version."

            # Step through each architecture
            ForEach ($architecture in $res.Get.Download.Architectures) {

                # Build the output object
                $PSObject = [PSCustomObject] @{
                    Version      = $Version
                    Architecture = $architecture
                    Channel      = $Channel
                    URI          = (($res.Get.Download.Uri.$Channel -replace $res.Get.Download.ReplaceTextVersion, $Version) -replace $res.Get.Download.ReplaceTextArch, $architecture)
                }

                # Output object to the pipeline
                Write-Output -InputObject $PSObject
                $PSObject = $Null
            }
        }
    }
}
