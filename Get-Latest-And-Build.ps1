Function Main()
{
    BEGIN
    {
        Clear-Host
        
        $TFSEXE = "C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\TF.exe"
        $MSBUILDEXE = "C:\Windows\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe"
        $NotepadEXE = "C:\Windows\System32\notepad.exe"
        $BuildOutput = "C:\Users\KCHOUHAN\Documents\Scripts\Batch Testing\$($Env:ComputerName)_BuildOutput.txt"
        $DEVTSTJCL = "C:\MF\es\DEVTST\jes\_jcl\"
        $ProjectPath = "C:\MF_Dev\UnifiedGrocers\"
        
        Remove-Item "${DEVTSTJCL}*.JCL" -Force
    }
    
    PROCESS
    {
        & $TFSEXE get $/EMC_Micro_Focus /recursive /noprompt
        
        [String[]] $ProjectNames = Get-ChildItem $ProjectPath | Where {($_.Attributes -Match "Directory") -And ($_.Name -NE "EMC2")}
        Set-Content $BuildOutput $Null
        
        # Build projects and move jcl from respective TFS project directory to DEVTST Enterprise Server folder
        ForEach ($ProjectName in $ProjectNames)
        {
            Write-Host "$ProjectName project build is in progress..."
            $Project = "$ProjectPath$ProjectName\$ProjectName.cblproj"
            & $MSBUILDEXE $Project /nologo /verbosity:minimal /detailedsummary >> $BuildOutput
            
            If (Test-Path "$ProjectPath$ProjectName\JCL")
            {
                Copy-Item "$ProjectPath$ProjectName\JCL\*.JCL" $DEVTSTJCL
            }
        }
        
        Get-ChildItem -Path $DEVTSTJCL -Include "*.JCL" | ForEach-Object { $_.IsReadOnly = $False }
        
        [String[]] $Errors = Select-String -Path $BuildOutput -Pattern "\serror\s"
        $ErrorCount = $Errors.Length
    }
    
    END
    {
        Write-Host "Error Count: $ErrorCount"
        & $NotepadEXE $BuildOutput 
    }
}

. Main
