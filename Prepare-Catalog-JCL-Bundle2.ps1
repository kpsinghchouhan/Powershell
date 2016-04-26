$ScriptNumber = "SE14"

Function Main ()
{
    BEGIN
    {
        Clear-Host
        
        $ASCIIFilesPathRemote = "\\UGMFDEV1\Snapshots\Bundle2_ASCII\${ScriptNumber}\FLAT_FILES\INPUT\"
        $ASCIIFilesPathLocal = "C:\MF\es\DEVTST\catalog\data\"
        $OldCatalogJCL = "\\UGMFDEV1\Snapshots\EBCDIC_ASCII_B234\DFCONV\2_CATALOG\${ScriptNumber}.JCL"
        $NewCatalogJCL = "C:\MF\es\DEVTST\jes\cat_jcl\${ScriptNumber}.JCL"
        $VSAMCtlPath = "\\UGMFDEV1\Source\VSAM_Delete_Define_Cards\"
        $VSAMCtlXref = "${VSAMCtlPath}01 VSAM_Ctl_Xref.csv"
        $StepNumber = 0
        
    }
    
    PROCESS
    {
        If (Test-Path $OldCatalogJCL)
        {
            Copy-Item $OldCatalogJCL $NewCatalogJCL
        }
        Else
        {
            Write-Host "No files to catalog..."
            Return
        }
        
        [String[]] $ASCIIFiles = Get-ChildItem $ASCIIFilesPathRemote -Include "*.DAT" -Name
        
        ForEach ($ASCIIFile in $ASCIIFiles)
        {
            $ASCIIFileName = $ASCIIFile.Substring(0, ($ASCIIFile.Length - 4))
            
            $VSAMEntry = Select-String -Path $VSAMCtlXref -Pattern "$ASCIIFileName," -SimpleMatch
            
            If ($VSAMEntry -NE $Null)
            {
                $CtlName = $VSAMEntry.Line.Split(",", 2)[1]
                
                $NewASCIIFileName = "$ASCIIFileName.SEQ"
                
                Copy-Item "$ASCIIFilesPathRemote$ASCIIFile" "$ASCIIFilesPathLocal${NewASCIIFileName}.DAT" -Verbose
                
                (Get-Content $NewCatalogJCL) | ForEach-Object {$_.Replace("$ASCIIFileName,", "$NewASCIIFileName,")} | Set-Content $NewCatalogJCL
                
                $StepNumber = $StepNumber + 1
                Add-Content $NewCatalogJCL "//STEPR$StepNumber EXEC PGM=IDCAMS"
                Add-Content $NewCatalogJCL "//SYSOUT    DD SYSOUT=*"
                Add-Content $NewCatalogJCL "//SYSPRINT  DD SYSOUT=*"
                Add-Content $NewCatalogJCL "//DISKIN    DD DSN=$NewASCIIFileName,"
                Add-Content $NewCatalogJCL "//          DISP=(OLD,DELETE,KEEP)"
                Add-Content $NewCatalogJCL "//SYSIN     DD *"
                
                [String[]] $CtlContents = Get-Content "$VSAMCtlPath$CtlName"
                
                Add-Content $NewCatalogJCL $CtlContents
                
                Write-Host "Added delete/define/repro statements for VSAM file $ASCIIFileName"                
            }
            Else
            {
                Copy-Item "$ASCIIFilesPathRemote$ASCIIFile" $ASCIIFilesPathLocal -Verbose
            }
        }    
        
        Write-Host "Catalog jcl created..."
    }
    
    END
    {
        Write-Host "End of processing..."
    }    
}

. Main