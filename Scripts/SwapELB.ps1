$deployment = $OctopusParameters["Octopus.Deployment.Id"]

$instances = Get-Ec2Instance | % { $_.Instances }
$elb = Get-ELBLoadBalancer -LoadBalancerName $OctopusParameters["LoadBalancerName"]

$currentInstanceIds = @( $elb.Instances | % { $_.InstanceId } )

$instancesToAdd = $instances |  where { $_.State.Name -eq "running" }
foreach($instance in $instancesToAdd)
{
    $deploymentTag = $instance.Tag | where { $_.Key -eq "Deployment" } | Select -First 1
    $registered =  $currentInstanceIds.Contains($instance.InstanceId)

    if($deploymentTag.Value -eq $deployment)
    {
        if($currentInstanceIds.Contains($instance.InstanceId) -eq $true)
        {
            Write-Highlight "Skipping $($instance.InstanceId) as it is already registered"
        }
        else
        {
            Write-Highlight "Registering $($instance.InstanceId) with the Load Balancer"
            Register-ELBInstanceWithLoadBalancer $elb.LoadBalancerName $instance.InstanceId > $null
        }
    }
    elseif($registered)
    {
        Write-Host "Removing $($instance.InstanceId) from the Load Balancer as it belongs to a different deployment $($deploymentTag.Value)"
        Remove-ELBInstanceFromLoadBalancer $elb.LoadBalancerName $instance.InstanceId -Force > $null
    }
}


