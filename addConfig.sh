BUILD_NO="$1"
PROJECT_NAME="$2"
CONF_FILE="$3"



VM_NAME="${PROJECT_NAME}-${BUILD_NO}"

echo $VM_NAME

########################### retrive ip address of newly created vm ##########################################
IP_ADDRESS=$(gcloud compute instances describe $VM_NAME --zone="asia-south1-a" --format='value(networkInterfaces.networkIP)')
echo $IP_ADDRESS


############################ replace the holder {} with project for the filebeat config ################################## 


echo "CREATE FILEBEAT"
sed "s/{}/$PROJECT_NAME/g" /home/play/scripts/filebeat.yml > /home/play/scripts/filebeat.yml.tmp

echo "CREATE DEL_LOGS.SH"
sed "s/{}/$PROJECT_NAME/g" /home/play/scripts/del_logs.sh > /home/play/scripts/del_logs.sh.tmp


#ADD the ip address of the new VM in inventory.txt to be used for ansible playbook

echo "create inventory.text for ansible **************"
echo "[${PROJECT_NAME}]" >>${VM_NAME}-inventory.txt
echo "$IP_ADDRESS ansible_connection=ssh ansible_user=play" >>${VM_NAME}-inventory.txt



############################# USIN ANSIBLE PLAYBOOKS TO -->  COPY THE updated filebeat, del_logs,  auto_restart & cron ############################

echo "COPY FILEBEat To VM"
ansible-playbook /home/play/playbooks/copyFile.yml -i ${VM_NAME}-inventory.txt --extra-vars "source_path=/home/play/scripts/filebeat.yml.tmp dest_path=/etc/filebeat/filebeat.yml user=root host=${PROJECT_NAME} flag=yes"


echo "COPY DEL_logs.sh  To VM"
ansible-playbook /home/play/playbooks/copyFile.yml -i ${VM_NAME}-inventory.txt --extra-vars "source_path=/home/play/scripts/del_logs.sh.tmp dest_path=/home/play/del_logs.sh user=play host=${PROJECT_NAME} flag=yes"


echo "COPY auto_restart.rb  To VM"
ansible-playbook /home/play/playbooks/copyFile.yml -i ${VM_NAME}-inventory.txt  --extra-vars "source_path=/home/play/scripts/${PROJECT_NAME}/auto_restart.rb dest_path=/data/dist/scripts/auto_restart.rb user=play host=${PROJECT_NAME} flag=no"


echo " ADD CRON BY ANSIBLE"
ansible-playbook /home/play/playbooks/addcron.yml -i ${VM_NAME}-inventory.txt --extra-vars "host=${PROJECT_NAME}"


########################## COPY BUILD TO MACHINE #############################

echo "COPY BUILD"
ansible-playbook /home/play/playbooks/copyFile.yml -i ${VM_NAME}-inventory.txt --extra-vars "source_path=/home/play/builds/${PROJECT_NAME}-${BUILD_NO}.zip dest_path=/data/dist/builds/${PROJECT_NAME}-${BUILD_NO}.zip user=play host=${PROJECT_NAME} flag=no" 


#### RUNNING DEPLOYMENT SCRIPT FOR UNZIPPING THE BUILD ###############################
echo "UNZIP BUILD"
ansible-playbook /home/play/playbooks/deployBuild.yml -i ${VM_NAME}-inventory.txt --extra-vars "PROJECT=${PROJECT_NAME} BUILD=${BUILD_NO} user=play host=${PROJECT_NAME}"


echo "Change symlinks"
ansible-playbook /home/play/playbooks/changesymlinks.yml -i ${VM_NAME}-inventory.txt --extra-vars "PROJECT=${PROJECT_NAME} BUILD=${BUILD_NO} user=play host=${PROJECT_NAME}"

###########Adding Application configfs #####################



#ansible-playbook /home/play/playbooks/copyFile.yml -i ${VM_NAME}-inventory.txt --extra-vars "source_path=/home/play/scripts/${VM_NAME}/conf/${CONF_FILE} dest_path=/data/dist/${PROJECT_NAME}/production.conf user=root host=${PROJECT_NAME} flag=no"
#ansible-playbook /home/play/playbooks/copyFile.yml -i ${VM_NAME}-inventory.txt --extra-vars "source_path=/home/play/scripts/${VM_NAME}/conf/logback.xml dest_path=/data/dist/${PROJECT_NAME}/logback.xml user=play host=${PROJECT_NAME} flag=no"

rm ${VM_NAME}-inventory.txt
