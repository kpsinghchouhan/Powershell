#
# Script to generate VSAM catalog jcl for B2 sripts
#
# Provide the script name below and execute the script.
# It will modify the existing catalog jcl to add vsam delete/define/repor statments.
# Run the .bat file to copy all the .dat files and catalog jcl to your VMs
# after executing this script.
#

$ScriptNumber = "SE14"

Function Main ()
{
    BEGIN
    {
        Clear-Host
        
        $ASCIIFilesPath = "\\UGMFDEV1\Snapshots\Bundle2_ASCII\${ScriptNumber}\FLAT_FILES\INPUT\"
        $CatalogJCL = "\\UGMFDEV1\Snapshots\EBCDIC_ASCII_B234\DFCONV\2_CATALOG\${ScriptNumber}.JCL"
        $VSAMCtlPath = "\\UGMFDEV1\Source\VSAM_Delete_Define_Cards\"
        $VSAMCtlXref = "${VSAMCtlPath}01 VSAM_Ctl_Xref.csv"
        $StepNumber = 0
    }
    
    PROCESS
    {
        If (-Not(Test-Path $CatalogJCL))
        {
            Write-Host "No files to catalog..."
            Return
        }
        
        [String[]] $ASCIIFiles = Get-ChildItem $ASCIIFilesPath -Include "*.DAT" -Name
        
        ForEach ($ASCIIFile in $ASCIIFiles)
        {
            $ASCIIFileName = $ASCIIFile.Substring(0, ($ASCIIFile.Length - 4))
            
            $VSAMEntry = Select-String -Path $VSAMCtlXref -Pattern "$ASCIIFileName," -SimpleMatch
            
            If ($VSAMEntry -NE $Null)
            {
              
                $CtlName = $VSAMEntry.Line.Split(",", 2)[1]
                
                $NewASCIIFileName = "$ASCIIFileName.SEQ"
                
                # Renaming file with .SEQ  
                Rename-Item "$ASCIIFilesPath$ASCIIFile" "$ASCIIFilesPath$NewASCIIFileName.DAT" -Verbose
                
                (Get-Content $CatalogJCL) | ForEach-Object {$_.Replace("$ASCIIFileName,", "$NewASCIIFileName,")} | Set-Content $CatalogJCL
                
                $StepNumber = $StepNumber + 1
                Add-Content $CatalogJCL "//STEPR$StepNumber EXEC PGM=IDCAMS"
                Add-Content $CatalogJCL "//SYSOUT    DD SYSOUT=*"
                Add-Content $CatalogJCL "//SYSPRINT  DD SYSOUT=*"
                Add-Content $CatalogJCL "//DISKIN    DD DSN=$NewASCIIFileName,"
                Add-Content $CatalogJCL "//          DISP=(OLD,DELETE,KEEP)"
                Add-Content $CatalogJCL "//SYSIN     DD *"
                
                [String[]] $CtlContents = Get-Content "$VSAMCtlPath$CtlName"
                
                Add-Content $CatalogJCL $CtlContents
                
                Write-Host "Added delete/define/repro statements for VSAM file $ASCIIFileName"                
            }
        }    
        
        Write-Host "Catalog jcl modified..."
    }
    
    END
    {
        Write-Host "End of processing..."
    }    
}

. Main
