<#current AWS Sessions Credentials need to be copied in File: C:\Users\...\.aws\Credentials#>
$OwnPublicIP = 91.18.74.48
$amiID = ami-0df435f331839b2d6
$NumberOfInstances = 1
$InstanceType = t2.micro

<#Generating Key-Pair and Security Group for EC2#>
aws ec2 create-key-pair --key-name current-key-pair --query "KeyMaterial" --output text > C:\current-key-pair.pem
$SecGroupID = aws ec2 create-security-group --group-name SecurityGroup --description "Current Sec-Group"

<#Creating Rule for SSH Access from specific IP Adress#>
aws ec2 authorize-security-group-ingress --group-id $SecGroupID --protocol tcp --port 22 --cidr $OwnPublicIP/32

<#Creating EC2 Instance and getting Public IP of the Instance#>
$InstanceId = aws ec2 run-instances --image-id $amiID --count $NumberOfInstances --instance-type $InstanceType --key-name current-key-pair --security-group-ids $SecGroupID --query 'Instances[0].InstanceId' --output text
$InstanceIP = aws ec2 describe-instances --instance-ids $InstanceId --query 'Reservations[*].Instances[*].PublicIpAddress' --output text

<#Test-Command für direkt in der PS#>
<#aws ec2 run-instances --image-id ami-0df435f331839b2d6 --count 1 --instance-type t2.micro --key-name first-key-pair --security-group-ids sg-085bf6d31cf65a4d8 --query 'Instances[0].InstanceId' --output text#>

<#Connection to Instance via SSH#>
