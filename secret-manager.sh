project=$1

secret_list=$(gcloud secrets list | awk 'NR > 1 { print $1 }')

echo $secret_list

IFS=' ' read -ra secrets_list <<< "$(echo $secret_list | tr '\n' ' ')"
echo ${secrets_list[@]}

for secret in $secrets_list; do
    case $secret in
        ${project}_*) value=$(gcloud secrets versions access latest --secret=$secret --format='get(payload.data)' | tr '_-' '/+' | base64 -d);
        export $secret=$value;;
    esac
done




xxxxxxxxxxxxxxxxxxxxx



[play@payvoo-notification-119 scripts]$ cat secret-manager.sh 
project=$1
secrets_list=`gcloud secrets list --filter "labels.service=${project}" | awk '{ print $1 }' | grep -v "NAME"`
# IFS=' ' read -ra secrets_list <<< "$(echo $secret_list | tr '\n' ' ')"
# echo ${secrets_list[1]}


for secret in $secrets_list;
do
        value=$(gcloud secrets versions access latest --secret=$secret --format='get(payload.data)' | tr '_-' '/+' | base64 -d)
        export $secret=$value
    
done


xxxxxxxxxxxxxxxxxxxxx prod rundeck xxxxxxxxxxxxxx

[play@rundeck-mum-01 ~]$ cat secret-manager.sh 
service="credit-scoring"
secrets_list=`gcloud secrets list --filter "labels.${service}=service" --project="intense-nexus-126408" | awk '{ print $1 }' | sed '1d'`

echo $secrets_list
for secret in $secrets_list;
do
        value=$(gcloud secrets versions access latest --secret=$secret --project="intense-nexus-126408" --format='get(payload.data)' | tr '_-' '/+' | base64 -d)

        export $secret=$value
done




xxxxxxxxxxxxxxxxxxxxxxx qa-rundeck xxxxxxxxxxx

[play@rundeck-mum-01 ~]$ cat secret-manager.sh 
project=$1

secret_list=$(gcloud secrets list | awk 'NR > 1 { print $1 }')

echo $secret_list

IFS=' ' read -ra secrets_list <<< "$(echo $secret_list | tr '\n' ' ')"
echo ${secrets_list[@]}

for secret in $secrets_list; do
    case $secret in
        ${project}_*) value=$(gcloud secrets versions access latest --secret=$secret --format='get(payload.data)' | tr '_-' '/+' | base64 -d);
        export $secret=$value;;
    esac
done
