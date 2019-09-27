using namespace System.IO;
function Get-NddResource {
    [CmdletBinding()]
    Param(
        [ValidateSet(
            "BankStatement",
            "BasicAutoTable_NoRules",
            "Claims_Document_Rules",
            "Correspondence",
            "FlowFrames",
            "HTMLFrames",
            "HTML_Preview",
            "ManyFrames_MsgFocus",
            "Simple_AutoTable_Rules",
            "SimpleLetter"
        )]
        [Parameter(Mandatory = $true, ParameterSetName = "default")]
        [Parameter(Mandatory = $true, ParameterSetName = "path")]
        [string]$Resource,
        [switch]$LocalPaths,
        [Parameter(ParameterSetName = "diagnostic")]
        [switch]$List,
        [Parameter(ParameterSetName = "path")]
        [switch]$Path,
        [Parameter(ParameterSetName = "path")]
        [ValidateSet("Baselines", "Manifests", "Packages", "ResourcePacks", "Templates", "ControlFiles", "Databases")]
        [string[]]$Find = @()
    )
    Begin {
        if ($LocalPaths) {
            $RealizedPath = $DriveMaps['testcase-repo'].DrivePath
        }
        else {
            $RealizedPath = $DriveMaps['testcase-repo'].UncPath
        }
        $RealizedPath = "$RealizedPath\Active\Resources"
        $Locations = @{
            "BankStatement"          = [IO.DirectoryInfo]"$RealizedPath\22997\";
            "BasicAutoTable_NoRules" = [IO.DirectoryInfo]"$RealizedPath\23425\";
            "Claims_Document_Rules"  = [IO.DirectoryInfo]"$RealizedPath\23805\";
            "Correspondence"         = [IO.DirectoryInfo]"$RealizedPath\23367\";
            "FlowFrames"             = [IO.DirectoryInfo]"$RealizedPath\23575\";
            "HTMLFrames"             = [IO.DirectoryInfo]"$RealizedPath\23713\";
            "HTML_Preview"           = [IO.DirectoryInfo]"$RealizedPath\23566\";
            "ManyFrames_MsgFocus"    = [IO.DirectoryInfo]"$RealizedPath\23066\";
            "Simple_AutoTable_Rules" = [IO.DirectoryInfo]"$RealizedPath\23487\";
            "SimpleLetter"           = [IO.DirectoryInfo]"$RealizedPath\23448\";
        }
        function Filter-Failures([FileInfo[]]$ResultsToFilter) {
            return $ResultsToFilter | Where-Object { $_.FullName -notmatch 'Failures' }
        }
        function Sort-Results([FileInfo[]]$ResultsToSort) {
            return $ResultsToSort | Sort-Object -Property LastWriteTime -Descending
        }
        function Find-Databases([IO.DirectoryInfo]$SearchRoot) {
            return Sort-Results(Filter-Failures(Get-ChildItem $SearchRoot -Include '*.orig', '*.accdb', '*.mdb' -File -Recurse))
        }
        function Find-ControlFiles([IO.DirectoryInfo]$SearchRoot) {
            return Sort-Results(Filter-Failures(Get-ChildItem $SearchRoot -Include '*.opt', '*.dat' -File -Recurse))
        }
        function Find-Manifests([IO.DirectoryInfo]$SearchRoot) {
            return Sort-Results(Filter-Failures(Get-ChildItem $SearchRoot\Baselines\CASManifestFile -File -Recurse))
        }
        function Find-ResourcePacks([IO.DirectoryInfo]$SearchRoot) {
            return Sort-Results(Filter-Failures(Get-ChildItem $SearchRoot\Baselines\CASResourcePack -File -Recurse))
        }
        function Find-Templates([IO.DirectoryInfo]$SearchRoot) {
            return Sort-Results(Filter-Failures(Get-ChildItem $SearchRoot\Baselines\CASVersionedTemplate -File -Recurse))
        }
        function Find-Packages([IO.DirectoryInfo]$SearchRoot) {
            return Sort-Results(Filter-Failures(Get-ChildItem $SearchRoot -Include "*.pub" -File -Recurse))
        }
    }
    Process {
        if ($List) {
            return $Locations | Format-Table
        }
        if ($Path) {
            if ($Find.Length -ne 0) {
                $Ret = [hashtable]@{}
                $Find | ForEach-Object {
                    $Ret.Add($_, (Invoke-Expression "Find-$_ '$($Locations[$Resource])'"))
                }
                return [pscustomobject]$Ret
            }
            return $Locations[$Resource].FullName
        }
    }
}

Export-ModuleMember -Function *-*