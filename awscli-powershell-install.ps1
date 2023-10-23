# Setting protocol versions

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls, [Net.SecurityProtocolType]::Tls11, [Net.SecurityProtocolType]::Tls12, [Net.SecurityProtocolType]::Ssl3
[Net.ServicePointManager]::SecurityProtocol = "Tls, Tls11, Tls12, Ssl3"

$source = 'https://awscli.amazonaws.com/AWSCLIV2.msi'
$destination = 'C:\Users\toko\Downloads\AWSCLIV2.msi'

# Create web client
$webClient = [System.Net.WebClient]::new()

# Download the file
$webClient.DownloadFile($source, $destination)

Start-Process -FilePath C:\windows\system32\msiexec.exe -Args "/i $destination /passive" -Verb RunAs -Wait
$env:Path += ";C:\Program Files\Amazon\AWSCLIV2"
