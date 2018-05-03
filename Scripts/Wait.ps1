Install-Module -Name Octoposh -force
Import-Module Octoposh -Force
Set-OctopusConnectionInfo -URL "https://cologne.octopushq.com" -APIKey $OctopusParameters["OctopusApiKey"]

$deployment = $OctopusParameters["Octopus.Deployment.Id"]

$sw = [System.Diagnostics.StopWatch]::Startnew()
$instances = Get-Ec2Instance | % { $_.Instances }

function IsThisDeployment($instance)
{
    $deploymentTag = $instance.Tag | where { $_.Key -eq "Deployment" } | Select -First 1
    return $deploymentTag.Value -eq $deployment
}

$instanceIds = $instances | where IsThisDeployment | select { $_.InstanceId }

while($true)
{
    if($sw.Elapsed.TotalMinutes -gt 4)
    {
        throw "Timeout"
    }

    start-sleep 1
   
    $machines = Get-OctopusMachine -EnvironmentName $OctopusParameters["Octopus.Environment.Name"]
    Write-Host "$($machines.Count) of $($instanceIds.Count) machines registered with Octopus"

    if($machines.Count -ge $instanceIds.Count)
    {
        return;
    }
}