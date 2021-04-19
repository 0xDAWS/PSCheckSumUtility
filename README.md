# PSCheckSumUtility
Powershell Checksum Utility

# Params
| Param | Description | Required |
| --- | --- | --- |
| `Mode` | Sets the mode of operation | True |
| `Path` | The path to a given file | True |
| `Algorithm` | Sets the hashing algorithm to be used in the checksum operation (Default: SHA256) | False |
| `Hash` | Perform the check operation on a valid checksum file | Only for Mode: Compare | 
| `OutFile` | Boolean that when set will generate a checksum file in the same directory as -Path | False |

# Modes
| Mode | Description |
| --- | --- |
| `File` | Generate a checksum for a single file |
| `Directory` | Generate checksums for all files in a given directory |
| `Check` | Perform the check operation on a valid checksum file |
| `Compare` | Compare a single hash to a known hash (Without the need a checksum file) |

# Supported Algorithms
PSCheckSumUtility allows for different hashing algorithms to be set using the `-Algorithm` flag. 

Algorithms: 
- `MD5`
- `SHA1`
- `SHA256` (Default)
- `SHA384`
- `SHA512` 

Note: A checksum file has no information about the algorithm used to generate its content, so if you generate a `SHA512` checksum file, you must explicitly tell the script to use the correct algorithm. The script does correctly name the generated checksum files according to the algorithm chosen, for example: `MD5` would generate a checksum file with the name `MD5SUMS.txt`.

# Examples
Here is a test directory structure we will use in the following examples:
```
    Directory: C:\Test

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d-----        19/04/2021   6:37 PM                TestDirectory
-a----        19/04/2021   6:37 PM             12 TestDoc-1.txt
-a----        19/04/2021   6:37 PM             24 TestDoc-2.txt
-a----        19/04/2021   6:37 PM             36 TestDoc-3.txt
```

### Checksum a single file, and output to console 
```
PSCheckSumUtility.ps1 -Mode File -Path C:\Test\TestDoc-1.txt

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
Path: C:\Test\TestDoc-1.txt
Mode: File
Algorithm: SHA256
Generate checksums file: False
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
5FCABC98978A52501FD64C1E8C38BC790D3DD09BDCED3E378161B5C20FE9CA03  C:\Test\TestDoc-1.txt
```

### Checksum an entire directory using the MD5 algorithm and create a checksum file
```
PSCheckSumUtility.ps1 -Mode Directory -Path C:\Test\ -Algorithm MD5 -OutFile

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
Path: C:\Test\
Mode: Directory
Algorithm: MD5
Generate checksums file: True
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
[-] C:\Test\TestDirectory is not a file and will not be processed, continuing checksum operation..
4765C0B343E5431B301BC375628B4DED  C:\Test\TestDoc-1.txt
2D00830E08511A445020D235D40931E7  C:\Test\TestDoc-2.txt
0CFE13A6B94A7904315340DC7A5893C3  C:\Test\TestDoc-3.txt
```

### Perform a check operation on a checksum file
```
PSCheckSumUtility.ps1 -Mode Check -Path C:\Test\MD5SUMS.txt -Algorithm MD5

==================================
Checksum File: C:\Test\MD5SUMS.txt
==================================
[ PASS ] C:\Test\TestDoc-1.txt
[ PASS ] C:\Test\TestDoc-2.txt
[ PASS ] C:\Test\TestDoc-3.txt
[+] Operation Complete!
```

### Perform a compare operation on a file with a known hash
```
PSCheckSumUtility.ps1 -Mode Compare -Path C:\Test\TestDoc-1.txt -Algorithm MD5 -Hash 4765C0B343E5431B301BC375628B4DED

[ PASS ] C:\Test\TestDoc-1.txt
[+] Operation Complete!
```
