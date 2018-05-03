$deployment = $OctopusParameters["Octopus.Deployment.Id"]

$sw = [System.Diagnostics.StopWatch]::Startnew()
$instances = Get-Ec2Instance | % { $_.Instances }

$ready = $false
while($ready -ne $true)
{
    if($sw.Elapsed.TotalMinutes -gt 4)
    {
        throw "Timeout"
    }

    start-sleep 1
    $statuses = Get-EC2InstanceStatus
    $ready = $true;

    foreach($instance in $instances)
    {
        $deploymentTag = $instance.Tag | where { $_.Key -eq "Deployment" } | Select -First 1

        if($deploymentTag.Value -eq $deployment)
        {
            $status = $statuses | where { $_.InstanceId -eq $instance.InstanceId } | select -First 1
            Write-Host "$($instance.InstanceId) is $($status.Status.Status)"

            if($status -ne $null -and $status.Status.Status -ne "ok")
            {
               $ready = $false
            }
        }
    }
}