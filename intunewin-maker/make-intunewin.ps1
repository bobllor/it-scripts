<#
	.DESCRIPTION
	Creates the .intunewin file. This requires the IntuneWinAppUtil.exe executable to run.

	.PARAMETERS
		-$Source <string>
			The target source folder. The output .intunewin file will also be created in this folder.

		-SetupFile <string>
			The target setup file.
		
		-RemoveIntuneWin
			Removes all .intunewin files from the source directory before making a new .intunewin file.
		
	.AUTHOR
	Tri Nguyen

	.UDPATED
	2/7/2026
#>

param(
	[Parameter(Mandatory=$true)]
	[string] $Source,
	[Parameter(Mandatory=$true)]
	[string] $SetupFile,
	[switch] $RemoveIntuneWin
)

$app = "IntuneWinAppUtil.exe"

if(!(test-path $app)){
	Write-Error "Missing $app in path $(pwd).path"
	exit 1
}

if(test-path $Source -pathtype Container){
	$folderName = ($Source -split "\\")[-2]
	$fileName = ($SetupFile -split "\\")[-1]

	if($RemoveIntuneWin){
		get-childitem -recurse -path "$Source" | where {$_.extension -eq ".intunewin"} | foreach-object{
			echo "Removing file $($_.name)"
			rm $_.fullname
		}
	}
	
	echo "Source: $Source"
	echo "Setup file: $fileName"
	echo "Output: $Source"
	echo ""
	
	& ".\$app" -c "$Source" -s "$fileName" -o "$Source"
}else{
	Write-Error "Source path must be a directory"
	exit 1
}