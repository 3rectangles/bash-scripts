YEAR=`date +%Y`
MONTH=`date +%m`
DATE=`date +%d`
PROJECT="payvoo-stop"
BUCKET="smartcoin-rebase-logs"

function upload_to_gcs(){
    for log in $log_files;
    do 
    FILENAME=$(basename $log)
     gsutil cp -Z $log  gs://${BUCKET}/${YEAR}/${MONTH}/${DATE}/${PROJECT}/${HOSTNAME}/${FILENAME}.gz
     done 

}

function delete_the_log_file(){
    for log in $log_files;
    do
     rm $log
     done 
}


log_files=`find /data/dist/${PROJECT}/current/logs -maxdepth 1 -iname "application*.log" `

upload_to_gcs $log_files
delete_the_log_file $log_files

log_files=`find /data/dist/${PROJECT}/current/logs -maxdepth 1 -iname "application*.log.202?????_????" `

upload_to_gcs $log_files
delete_the_log_file $log_files

/usr/bin/touch  /data/dist/payvoo-stop/shutdown
