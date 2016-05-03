#
# Script to generate VSAM catalog jcl for B2 sripts
#
# Provide the script name below and execute the script.
# It will modify the existing catalog jcl to add vsam delete/define/repor statments.
# Run the .bat file to copy all the .dat files and catalog jcl to your VMs
# after executing this script.
#

$ScriptNumber = "B2S1"

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
                
                Rename-Item "$ASCIIFilesPath$ASCIIFile" "$ASCIIFilesPath$NewASCIIFileName.DAT" -Verbose
                
                (Get-Content $CatalogJCL) | ForEach-Object {$_.Replace("$ASCIIFileName,", "$NewASCIIFileName,")} | Set-Content $CatalogJCL
                
                $StepNumber = $StepNumber + 1
                [String[]] $KeyDetails = Select-String -Path "$VSAMCtlPath$CtlName" -Pattern "KEYS" -SimpleMatch
                
                If ($KeyDetails.Length -GT 0)
                {
                    [String[]] $SplitText1 = $KeyDetails[0] -Split "KEYS\s*\("
                    [String[]] $SplitText2 = $SplitText1[1] -Split "\s+"
                    [String[]] $SplitText3 = $SplitText2[1] -Split "\)"
                    
                    $KeyLength = $SplitText2[0]
                    $KeyStartPos = [String]([Int]$SplitText3[0] + 1)
                    
                    Add-Content $CatalogJCL "//STEPS$StepNumber EXEC PGM=SORT"
                    Add-Content $CatalogJCL "//SORTLIB   DD DSN=SYS2.SORTLIB,DISP=SHR"
                    Add-Content $CatalogJCL "//SYSOUT    DD SYSOUT=*"
                    Add-Content $CatalogJCL "//SORTMSG   DD SYSOUT=*"
                    Add-Content $CatalogJCL "//SYSUDUMP  DD SYSOUT=*"
                    Add-Content $CatalogJCL "//SYSUDUMP  DD SYSOUT=*"
                    Add-Content $CatalogJCL "//SYSUDUMP  DD SYSOUT=*"
                    Add-Content $CatalogJCL "//SYSIN     DD *"
                    Add-Content $CatalogJCL " SORT FIELDS=($KeyStartPos,$KeyLength,CH,A)"
                    Add-Content $CatalogJCL "/*"
                    Add-Content $CatalogJCL "//SORTIN    DD DSN=$NewASCIIFileName,"
                    Add-Content $CatalogJCL "//             DISP=SHR"
                    Add-Content $CatalogJCL "//SORTOUT   DD DSN=$NewASCIIFileName,"
                    Add-Content $CatalogJCL "//             DISP=SHR"
                    Add-Content $CatalogJCL "//*"                    
                }

                Add-Content $CatalogJCL "//STEPR$StepNumber EXEC PGM=IDCAMS"
                Add-Content $CatalogJCL "//SYSOUT    DD SYSOUT=*"
                Add-Content $CatalogJCL "//SYSPRINT  DD SYSOUT=*"
                Add-Content $CatalogJCL "//DISKIN    DD DSN=$NewASCIIFileName,"
                Add-Content $CatalogJCL "//             DISP=(OLD,DELETE,KEEP)"
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
