<#
	.DESCRIPTION
	Generates a hash file of the current device in the form of a CSV.
	This will generate the file on the device.

	.PARAMETER 
		- Uninstall <switch>
			Uninstalls Get-WindowsAutoPilotInfo.ps1 script after a successful hash generation.
		
		- Output <string>
			The output path of the file. By default this will create the file in C:\Hashes.

	.AUTHOR
	Tri Nguyen
#>
param(
	[switch] $Uninstall,
	[string] $Output
)

$serialNumber = (Get-WmiObject -class win32_bios).SerialNumber
echo "Generating hash for $serialNumber"

# if nuget does not exist then install. this supresses the prompt
# if this is not installed in the install-script command.
if(-not (get-packageprovider | where {$_.name -eq "NuGet"})){
	install-packageprovider nuget -minimumversion 2.8.5.201 -Force | out-null
}

install-script get-windowsautopilotinfo -Force

$currDate = Date -Format "MM-dd-yyyy-HH-mm"

if($Output.trim() -eq ""){
	$Output = "C:\Hashes"
}

if(-not (test-path -path $Output)){
	mkdir $Output
}

try{
	Get-WindowsAutoPilotInfo -OutputFile "$Output\$currDate-$serialNumber.csv" -append
}catch{
	echo "Failed to gather Windows Autopilot information: $_"
	exit 1
}

# clean up
if($Uninstall){
	uninstall-script get-windowsautopilotinfo -Force
}