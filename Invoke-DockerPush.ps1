Param([Parameter(Mandatory=$true)][String]$DockerImage)
#$dockerPassword = "$ENV:password"
docker push $DockerImage
Write-Output  "Image Pushed Successfully"
