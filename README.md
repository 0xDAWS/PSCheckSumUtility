# PSCheckSumUtility
A PowerShell module to perform cryptographic checksum operations

### Sections
- [Params](https://github.com/0xDAWS/PSCheckSumUtility#params)
- [Modes](https://github.com/0xDAWS/PSCheckSumUtility#modes)
- [Supported Algorithms](https://github.com/0xDAWS/PSCheckSumUtility#supported-algorithms)
- [Verify Installation Files (Optional)](https://github.com/0xDAWS/PSCheckSumUtility/blob/main/README.md#verify-installation-files-optional)
- [Installation](https://github.com/0xDAWS/PSCheckSumUtility#installation)
    - [Manual Installation](https://github.com/0xDAWS/PSCheckSumUtility#manual-installation)
    - [Import-Module](https://github.com/0xDAWS/PSCheckSumUtility#importing-the-module)
- [Examples](https://github.com/0xDAWS/PSCheckSumUtility#examples)

# Params
| Param | Description | Required |
| --- | --- | --- |
| `Mode` | Sets the mode of operation | True |
| `Path` | The path to a given file or directory | True |
| `Algorithm` | Sets the hashing algorithm to be used in the checksum operation (Default: SHA256) | False |
| `Hash` | Specific previously known hash, which can be used in Compare mode | Only for Mode: Compare | 
| `OutFile` | Boolean value that when set will generate a checksum file in the same directory as -Path | False |

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

Note: A checksum file has no information about the algorithm used to generate its content, so if you generate a `SHA512` checksum file, you must explicitly tell the script to use the correct algorithm. 

The script will correctly name the generated checksum files according to the algorithm chosen, for example: `MD5` would generate a checksum file with the name `MD5SUMS.txt`. Which makes it easy to identify the algorithm used to create the checksum, but does not automatically set the algorithm for `Check` or `Compare` modes.

# Verify installation files (Optional)
For added security I create a checksum for each release, which can be verified with the PowerShell `Get-FileHash` command, this will ensure the script is unaltered and safe to execute on your machine/s without the need to run the script itself to check its checksums.

In a powershell prompt enter the following command (replacing with the correct paths for where the module was downloaded to your machine)

```
(Get-FileHash -Algorithm SHA256 PSCheckSumUtility.psm1).hash -eq (Get-Content -Path SHA256SUM.txt)
```
This will return a boolean value of `True` if the hash matches, or `False` if it has been tampered or corrupted in some way. This is essentially a simplified version of what PSCheckSumUtility does behind the scenes anyway but it's nice to be able to verify it with Microsofts own tools for peace of mind.

You can also find a signature file in each release, for those who value absolute security and have access to GPG you can verify the SHA256SUM.txt file as being genuine using my [signing key](https://github.com/0xDAWS/Public-Keys/blob/main/0xDAWS.SigningKey.Public.asc) and the GPG --verify command (after importing the key into your keyring). 

```
gpg --verify SHA256SUM.txt.sig SHA256SUM.txt
```

# Installation
To install PSCheckSumUtility as a module it must first be added to the PSModulePath on your machine, after which it can be imported into powershell with the Import-Module command.

### Manual Installation
To install the module manually, you will need to create a `PSCheckSumUtility` directory (the name must match exactly) and then place the PSCheckSumUtility.psm1 file inside the directory. The location of this directory is decided by if you wish install the module for a single user or all users on the machine. The paths are listed below.

##### Single User
```$home\Documents\WindowsPowerShell\Modules\PSCheckSumUtility\PSCheckSumUtility.psm1```

##### All Users
```C:\ProgramFiles\WindowsPowerShell\Modules\PSCheckSumUtility\PSCheckSumUtility.psm1```

If you cannot import the module after adding it to PSModulePath then please read through this [article](https://docs.microsoft.com/en-us/powershell/scripting/developer/module/installing-a-powershell-module?view=powershell-7.1) from Microsoft on installing PowerShell modules, before opening an issue.

### Importing the module
Once the module has been added to the PSModulePath, simply use Import-Module and you are ready to go!
```
Import-Module PSCheckSumUtility
```

# Examples
Here is the example directory structure we will use in the following examples:
```
    Directory: C:\Test

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d-----        19/04/2021   6:37 PM                TestDirectory
-a----        19/04/2021   6:37 PM             12 TestDoc-1.txt
-a----        19/04/2021   6:37 PM             24 TestDoc-2.txt
-a----        19/04/2021   6:37 PM             36 TestDoc-3.txt
```
You can see it contains a directory and three .txt files. Directories are not able to be hashed by PSCheckSumUtility, so the script should recognise it as a directory and continue on without any problem. 

Note: Currently there is no way to use PSCheckSumUtility to recursively checksum a directories subdirectories, but should be added in a future release.

### Checksum a single file, and output to console 
```
PSCheckSum -Mode File -Path C:\Test\TestDoc-1.txt

5FCABC98978A52501FD64C1E8C38BC790D3DD09BDCED3E378161B5C20FE9CA03  C:\Test\TestDoc-1.txt
[+] Operation Complete!
```

### Checksum an entire directory using the MD5 algorithm and create a checksum file
```
PSCheckSum -Mode Directory -Path C:\Test\ -Algorithm MD5 -OutFile

[-] C:\Test\TestDirectory is not a file and will not be processed, continuing checksum operation..
4765C0B343E5431B301BC375628B4DED  C:\Test\TestDoc-1.txt
2D00830E08511A445020D235D40931E7  C:\Test\TestDoc-2.txt
0CFE13A6B94A7904315340DC7A5893C3  C:\Test\TestDoc-3.txt
[+] Operation Complete!
```

### Perform a check operation on a checksum file
```
PSCheckSum -Mode Check -Path C:\Test\MD5SUMS.txt -Algorithm MD5

[ PASS ] C:\Test\TestDoc-1.txt
[ PASS ] C:\Test\TestDoc-2.txt
[ PASS ] C:\Test\TestDoc-3.txt
[+] Operation Complete!
```

### Perform a compare operation on a file with a known hash
```
PSCheckSum -Mode Compare -Path C:\Test\TestDoc-1.txt -Algorithm MD5 -Hash 4765C0B343E5431B301BC375628B4DED

[ PASS ] C:\Test\TestDoc-1.txt
[+] Operation Complete!
```
