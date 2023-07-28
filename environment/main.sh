#!/bin/bash
#set -x
terraform -chdir='../terraform' init -upgrade
#terraform -chdir='../terraform' plan -var-file="../environment/terraform.tfvars"
terraform -chdir='../terraform' apply -var-file="../environment/terraform.tfvars"
#terraform -chdir='../terraform' destroy -var-file="../environment/terraform.tfvars"

### FILE SHARE ### 
## mount file share
#sudo apt-get install -y cifs-utils
#mkdir tfshare
#name=$(az storage account list -g RG_Teddy --query "[0].name" --output tsv)
#key=$(az storage account keys list -g RG_Teddy --account-name $name --query "[0].value" -o tsv)
#dir=$(pwd)
#
#if [ ! -d tfshare ]; then
#  mkdir tfshare
#  if [ ! -d "/etc/smbcredentials" ]; then
#  sudo mkdir /etc/smbcredentials
#  fi
#  if [ ! -f "/etc/smbcredentials/$name.cred" ]; then
#      sudo bash -c 'echo "username=$name" >> /etc/smbcredentials/$name.cred'
#      sudo bash -c 'echo "password=$key" >> /etc/smbcredentials/$name.cred'
#  fi
#  sudo chmod 600 /etc/smbcredentials/$name.cred
#  
#  sudo bash -c 'echo "//$name.file.core.windows.net/tfshare $dir/tfshare cifs nofail,credentials=/etc/smbcredentials/$name.cred,dir_mode=0777,file_mode=0777,serverino,nosharesock,actimeo=30" >> /etc/fstab'
#  sudo mount -t cifs //$name.file.core.windows.net/tfshare $dir/tfshare -o credentials=/etc/smbcredentials/$name.cred,dir_mode=0777,file_mode=0777,serverino,nosharesock,actimeo=30
#else
#  echo "tfshare already exist"
#fi
#
## copy tfstate
#cp ../terraform/terraform.tfstate tfshare/ && echo "terraform.tfstate copied"
