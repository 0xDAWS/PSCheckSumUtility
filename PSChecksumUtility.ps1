# PSCheckSumUtility.ps1 
# Written by d4ws (https://github.com/d4ws) [2021]
# Provided under the CC License 

param (
[Parameter(ParameterSetName="SelectMode", Mandatory=$true)][ValidateSet("File", "Directory", "Check")][string]$Mode,
[Parameter(ParameterSetName="SelectMode", Mandatory=$true)][string]$Path,
[switch]$OutFile
)

function Get-FileChecksum([string]$InFile) {
    $FileResults = Get-FileHash -Algorithm SHA256 $InFile
    return $FileResults.Hash + "  " + $FileResults.Path
}

function Check-FileExists([string]$fn) {
    return Test-Path -Path $fn -PathType Leaf
}

if ($Mode -eq "Check") {
    # CHECK MODE HEADER
    Write-Host $("="*("Checksum File:".Length + $Path.Length + 1))
    Write-Host "Checksum File:" $Path
    Write-Host $("="*("Checksum File:".Length + $Path.Length + 1))

    $ChecksumFileContent = Get-Content $Path
    
    foreach ($Checksum in $ChecksumFileContent) {
        $SplitChecksum = $Checksum.Split("", 2)
        $StoredChecksum = $SplitChecksum[0].Trim().ToUpper()
        $PathToFile = $SplitChecksum[1].Trim()
        $PathVaild = Check-FileExists($PathToFile)

        # If the file can't be found then try searching in the same directory as the checksum file
        if ( -not $PathVaild ) {
            $CheckSumFileDirectoryPath = (Get-Item $Path).Directory.FullName
            $PathToFile = [System.IO.Path]::Combine($CheckSumFileDirectoryPath, $PathToFile)
        }

        # try block will fail if file can't be found
        try {
            $FileChecksum = (Get-FileHash -Algorithm SHA256 $PathToFile -ErrorAction stop).Hash 

            if ( $StoredChecksum.Equals($FileChecksum) ) {
                Write-Host -ForegroundColor Green "[ PASS ]" $PathToFile
            }
            else {
                Write-Host -ForegroundColor Red "[ FAIL ]" $PathToFile
            }
        }
        catch {
            Write-Host -ForegroundColor Red "[-] File does not exist at this path:" $PathToFile  
        }
    } 
    Write-Host -ForegroundColor Green "[+] Operation Complete!" 
}

elseif ($Mode -eq "Directory") {
    # DIRECTORY MODE HEADER
    Write-Host "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    Write-Host "Path:" $Path
    Write-Host "Mode: Directory" 
    Write-Host "Generate checksums file:" $OutFile
    Write-Host "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    
    if (Test-Path -Path $Path -PathType Container) {
        # Check if $OutFile is set or not, if set but not provided then set path to same directory as $Path
        # If SHA256SUMS.txt already exists, remove it
        if ($OutFile) {
            $OutFilePath = [IO.Path]::Combine($Path, "SHA256SUMS.txt")
            if ( Check-FileExists($OutFilePath) ) { 
                Remove-Item $OutFilePath
            }
        }

        $Files = @(Get-ChildItem $Path)
        foreach ($f in $Files) {
            $FilePath = [IO.Path]::Combine($Path,$f)
            if (Check-FileExists($FilePath)){
                $FileChecksum = Get-FileChecksum($FilePath)

                # Check that OutFile is set or not set, and display/write checksum content
                if ($OutFile)
                {
                    Add-Content $OutFilePath $FileChecksum
                    $FileChecksum
                }
                else {
                    $FileChecksum
                }
            }
            else{
                Write-Host -ForegroundColor Red "[-]" $FilePath "is not a file and will not be processed, continuing checksum operation.."
                continue
            }
        }
        Write-Host -ForegroundColor Green "[+] Operation Complete!" 
    }
    else {
        Write-Host -ForegroundColor Red "[-] Directory mode was selected, but path is not a valid directory!"
    }

}

elseif ($Mode -eq "File") {
    # FILE MODE HEADER
    Write-Host "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    Write-Host "Path:" $Path
    Write-Host "Mode: File" 
    Write-Host "Generate checksums file:" $OutFile
    Write-Host "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="

    if ( Check-FileExists($Path) ) {

        $FileChecksum = Get-FileChecksum($Path)

        if ($OutFile) {
            $DirPath = (Get-Item $Path).Directory.FullName
            $OutFilePath = [IO.Path]::Combine($DirPath, "SHA256SUMS.txt")

            if ( Check-FileExists($OutFilePath) ) { 
                Remove-Item $OutFilePath
            }
            
            Add-Content $OutFilePath $FileChecksum
            $FileChecksum
        }

        else {
            $FileChecksum
        }

        Write-Host -ForegroundColor Green "[+] Operation Complete!" 
    }
    else {
        Write-Host -ForegroundColor Red "[-] File mode was selected, but path is not a valid file!"
    }
}
