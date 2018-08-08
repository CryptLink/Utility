# recursivly upgrades all zerver packages for a specific nuget package

Param(
    [string]$packageName = ""
)

if($packageName -eq ""){
    throw "No package name provided, it is required.";
}

Write-Host "Upgrading all projects to the latest version of '$packageName'"

Get-ChildItem ("..\*.csproj") -Recurse | foreach {

    # Check the csproj
    if(Select-Xml -Path $_.FullName -XPath "//ItemGroup/PackageReference[@Include='$packageName']") {
        Write-Host Upgrading $_.FullName;
        dotnet add $_.FullName package $packageName
    }

}