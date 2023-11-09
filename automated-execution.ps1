<#Definition der Parameter#>
Param(
    [Parameter(Mandatory=$False)]
    [string]$ProgramPath = "script.sh",

    [Parameter(Mandatory=$False)]
    [int]$NumberofInstances = 1
)

<#current AWS Sessions Credentials need to be copied in File: C:\Users\...\.aws\Credentials#>
$amiID = "ami-0fc5d935ebf8bc3bc"
$InstanceType = "t2.micro"
$Username = $env:USERNAME
<#Path for SSH-Key Security#>
$KeyPairPath = "$env:USERPROFILE\.ssh\current-key.pem"

<#Generating Key-Pair for EC2#>
Write-Output "### Creating Key-Pair for current User $Username ###"
Start-Sleep -Seconds 3
aws ec2 create-key-pair --key-name current-key-pair --query "KeyMaterial" --output text > $KeyPairPath
(Get-Content -Path $KeyPairPath -Raw) -replace "`r`n", "`n" | Set-Content -Path $KeyPairPath 

<#Generating Sec-Group in EC2#>
Write-Output "### Creating Security-Group for EC2 ###"
Start-Sleep -Seconds 3
$SecGroupID = aws ec2 create-security-group --group-name SecurityGroup --description "Current Sec-Group"

<#Creating Rule for SSH Access from specific IP Adress#>
Write-Output "### Creating Network Rule for SSH-Connection ###"
Start-Sleep -Seconds 3
aws ec2 authorize-security-group-ingress --group-id $SecGroupID --protocol tcp --port 22 --cidr 0.0.0.0/0

<#Creating EC2 Instance and getting Public IP of the Instance#>
Write-Output "### Creating EC2-Ubuntu Instance ###"
Start-Sleep -Seconds 3
$InstanceId = aws ec2 run-instances --image-id $amiID --count $NumberofInstances --instance-type $InstanceType --key-name current-key-pair --security-group-ids $SecGroupID --query 'Instances[0].InstanceId' --output text
$InstanceIP = aws ec2 describe-instances --instance-ids $InstanceId --query 'Reservations[*].Instances[*].PublicIpAddress' --output text

<#Wait until EC2 Instance is set up and running#>
$instanceState = "stopped"
Write-Output "### Waiting for Running EC2-Instance ###"
while ($instanceState -ne "running") {
    $instanceState = aws ec2 describe-instances --instance-ids $InstanceId --query 'Reservations[0].Instances[0].State.Name' --output text
    Start-Sleep -Seconds 5
    Write-Output "."
}
Write-Output "### EC2-Instance Running (IP: $InstanceIP) ###"
Start-Sleep -Seconds 10

Write-Output "### Starting Copying Files to EC2-Instance ###"
Start-Sleep -Seconds 3
<#Copying Programm Files to AWS#>
<#scp -i "C:\Users\Tommy\Desktop\Toko1.pem" "F:\OneDrive\PI21\awscli_cc_dhge\out.exe" ubuntu@$3.94.205.26:~#>
scp -i $KeyPairPath -o StrictHostKeyChecking=no $ProgramPath ubuntu@$($InstanceIP):~ 

Write-Output "### Program-Files copied to AWS EC2-Instance ###"
Write-Output "### Running Program in EC2-Instance ###"
Start-Sleep -Seconds 3

<#Connection to Instance via SSH#>
ssh -i $KeyPairPath ubuntu@$($InstanceIP) -o StrictHostKeyChecking=no "touch Time.txt; curl "http://worldtimeapi.org/api/timezone/Europe/London.txt" > Time.txt; cat Time.txt"

Write-Output "### Programm End - Results in Result-File ###"
Start-Sleep -Seconds 2

Write-Output "### Copying Results back to Local Computer ###"
Start-Sleep -Seconds 3
<#Copying Results back to Local#>
scp -i "$KeyPairPath" -r -o StrictHostKeyChecking=no ubuntu@$($InstanceIP):~/Time.txt "$env:USERPROFILE\Desktop"

Write-Output "### Stopping EC2 Instances ###"
aws ec2 terminate-instances --instance-ids $InstanceId
$instanceState = "running"
Write-Output "### Waiting for Terminating EC2-Instance"
while ($instanceState -ne "terminated") {
    $instanceState = aws ec2 describe-instances --instance-ids $InstanceId --query 'Reservations[0].Instances[0].State.Name' --output text
    Start-Sleep -Seconds 5
    Write-Output "."
}

Write-Output "### Deleting Security-Group ###"
Start-Sleep -Seconds 2
aws ec2 delete-security-group --group-id $SecGroupID

Write-Output "### Deleting Current-Key-Pair ###"
aws ec2 delete-key-pair --key-name current-key-pair
Remove-Item $KeyPairPath
