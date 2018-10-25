Write-Host ----------------------------------------------------------------------------------------------------
write-host "This script updates the version numbers in all .csproj files in a folder, optionally creates a git tag and pushes it"
Write-Host ----------------------------------------------------------------------------------------------------

$folders = Get-ChildItem ../ -Directory;
$count = 0;

foreach($folder in $folders){
    $count++;
    write-host $count")" $folder; 
}

$selection = $folders[[int](Read-Host "Choose a folder")-1].FullName;
$newVersion = $null;

Write-Host "Using folder: $selection";
Set-Location $selection;

Get-ChildItem -recurse *.csproj | ForEach-Object {
    [xml]$xml = (Get-Content $_);

    $nodes = $xml.SelectNodes("/Project/PropertyGroup/Version");

    if($nodes.Count -gt 0){
        Write-Host Processing: $_.FullName;

        foreach($node in $nodes) {
            Write-Host "Old version: " $node.InnerText;

            if($newVersion -eq $null){
                $newVersion = Read-Host "Pick a new version";
            }

            $node.InnerText = $newVersion;
        }
    } else {
        Write-Host Ignoring: $_.FullName " (does not have a 'Version' node)";
    }

    $xml.Save($_);
}

Write-Host "Git status:";
git status;

if((Read-Host "Add and commit to git? (y/n)").ToLower() -eq "y"){
    git add -A;
    git commit -m "Bumping version to $newVersion";
} else {
    exit;
}

if((Read-Host "Git tag? (y/n)").ToLower()  -eq "y") {
    git tag -a "v$newVersion" -m "v$newVersion"
} else {
    exit;
}

Write-Host "Git status:";
git status;

if((Read-Host "Git push? (y/n)").ToLower()  -eq "y") {
    git push origin "v$newVersion";
} else {
    exit;
}

Set-Location ../Utility/