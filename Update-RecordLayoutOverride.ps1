$RecordLayoutOverride = "\\UGMFDEV1\Source\KP\Scripts\RecordLayoutOverride.csv"
$NOSTR = "\\UGMFDEV1\Source\KP\Scripts\RecordLayoutOverrideNOSTR.csv"

[String[]] $Lines = Get-Content $NOSTR

ForEach($Line in $Lines)
{
    [String[]] $NOSTRRecord = $Line -Split "\s", 7
    $FileName = $NOSTRRecord[5]
    
    If (Select-String -Path $RecordLayoutOverride -Pattern "$FileName," -SimpleMatch -Quiet)
    {
        Continue    
    }
    Else
    {
        Add-Content $RecordLayoutOverride "$FileName,NO_STR_NEEDED,NO_COPYBOOK"
    }
}
