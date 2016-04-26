Function Main()
{
    BEGIN
    {
        $Bundle2EBCDICLocation = "\\UGMFDEV1\Snapshots\Bundle2\"
        $EBCDICCountReport = "\\UGMFDEV1\Source\KP\Scripts\EBCDIC_Count_Report.csv"
        Set-Content $EBCDICCountReport "Snapshot Name,Input Files Count in .files,Input Files Count Actual,Output Files Count in .files,Output Files Count Actual,Other Files Count in .files,Other Files Count Actual"
        $Scripts = Get-ChildItem $Bundle2EBCDICLocation | Where {($_.Attributes -Match "Directory") -And ($_.Name -NotMatch "SQL")}
        Clear-Host
        Write-Host "Begin of processing..."
    }
    
    PROCESS
    {
        ForEach ($Script in $Scripts)
        {
            $DotFiles = "$Bundle2EBCDICLocation$($Script.Name)\$($Script.Name).files"
            $SnapshotName = "$($Script.Name)"
            $InputFilesCount = 0
            $InputFilesCountActual = 0
            $OutputFilesCount = 0
            $OutputFilesCountActual = 0
            $OtherFilesCount = 0
            $OtherFilesCountActual = 0
            
            If (Test-Path $DotFiles)
            {
                Write-Host "Processing $($Script.Name)"
                $Lines = Get-Content $DotFiles
                
                ForEach ($Line in $Lines)
                {
                    If ($Line -Match "^Folder")
                    {
                        $FolderName = $($Line -Split "\\")[3]
                        [String[]] $Files = Get-ChildItem "$Bundle2EBCDICLocation$($Script.Name)\$FolderName" | Where {$_.Attributes -NotMatch "Directory"}
                        
                        Switch ($FolderName)
                        {
                            {$_ -Match "Input"} {If ($Files -EQ $Null) 
                                                    {$InputFilesCountActual = 0} 
                                                 Else {$InputFilesCountActual = $Files.Length}}
                            {$_ -Match "Output"} {If ($Files -EQ $Null) 
                                                    {$OutputFilesCountActual = 0}
                                                  Else {$OutputFilesCountActual = $Files.Length}}
                            {$_ -Match "Other"} {If ($Files -EQ $Null) 
                                                    {$OtherFilesCountActual = 0}
                                                 Else {$OtherFilesCountActual = $Files.Length}}
                        }
                    }
                    ElseIf ($Line -Match "^File")
                    {
                        Switch ($FolderName)
                        {
                            {$_ -Match "Input"} {$InputFilesCount++}
                            {$_ -Match "Output"} {$OutputFilesCount++}
                            {$_ -Match "Other"} {$OtherFilesCount++}
                        }
                    }   
                }
                
                Add-Content $EBCDICCountReport "$SnapshotName,$InputFilesCount,$InputFilesCountActual,$OutputFilesCount,$OutputFilesCountActual,$OtherFilesCount,$OtherFilesCountActual"
            }    
        }
        
    }
    
    END
    {
        Write-Host "End of processing..."    
    }
}

. Main