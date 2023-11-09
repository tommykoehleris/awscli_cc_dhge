Param(
    [Parameter(Mandatory=$False)]
    [string]$KeyPairPath = "$env:USERPROFILE\.ssh\current-key.pem",

    [Parameter(Mandatory=$True)]
    [int]$InstanceIP;   
)

sh -i $KeyPairPath ubuntu@$($InstanceIP) -o StrictHostKeyChecking=no @' 
    chmod +x out.exe
    touch Result
    ./out.exe > Result
    rm out.exe
'@