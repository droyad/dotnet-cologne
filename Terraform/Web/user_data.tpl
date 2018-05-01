#!/bin/bash
hostname=`curl --silent --show-error http://169.254.169.254/latest/meta-data/public-hostname`
instanceId=`curl --silent --show-error http://169.254.169.254/latest/meta-data/instance-id`
thumbprint=`ssh-keygen -E md5 -lf /etc/ssh/ssh_host_rsa_key.pub | grep -P -o "(?<=MD5:)[0-9a-f]+:[^ ]*"`

echo $hostname
echo $instanceid
echo $instanceId
echo "${deploymentId}"
echo "${environmentId}"

curl https://cologne.octopushq.com/api/machines --silent  --show-error  --header "X-Octopus-ApiKey:${apiKey}" --data "{
 \"Endpoint\": {
     \"CommunicationStyle\": \"Ssh\",
     \"AccountId\": \"sshkeypair-frankfurt\",
     \"AccountType\": \"SshKeyPair\",
     \"Host\": \"$hostname\",
     \"Port\": 22,
     \"Fingerprint\": \"$thumbprint\",
     \"DotNetCorePlatform\": \"linux-x64\",
 },
 \"MachinePolicyId\": \"MachinePolicies-1\",
 \"Roles\": [
     \"Web\",
     \"${deploymentId}\"
 ],
 \"EnvironmentIds\": [
     \"${environmentId}\"
 ],
 \"Name\": \"$instanceId\"
}"