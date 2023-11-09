$source = "https://awscli.amazonaws.com/AWSCLIV2.msi"
$destination = "$env:USERPROFILE\Downloads\AWSCLIV2.msi"

# Create web client
$webClient = [System.Net.WebClient]::new()

# Download the file
$webClient.DownloadFile($source, $destination)

Start-Process -FilePath C:\windows\system32\msiexec.exe -Args "/i $destination /passive" -Verb RunAs -Wait
$env:Path += ";C:\Program Files\Amazon\AWSCLIV2"
