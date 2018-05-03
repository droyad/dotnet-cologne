$environment = $OctopusParameters["Octopus.Environment.Name"]
$instances = Get-EC2Instance | % { $_.Instances }
$elb = Get-ELBLoadBalancer -LoadBalancerName $OctopusParameters["LoadBalancerName"]

foreach($elbInstance in $elb.Instances) {
    $instance = $instances | where { $_.InstanceId -eq $elbInstance.InstanceId } | select -First 1
    $envTag = $instance.Tag | where { $_.Key -eq "Environment" }
    Write-Host "The load balanced instance $($instance.InstanceId) is in $($envTag.Value)"
    if($envTag.Value -eq $environment)
    {
        throw "The instance $elbInstance is in $environment and is currently in the load balancer"
    }
}