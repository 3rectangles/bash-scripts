require 'time'

script_running = File.file?("/data/dist/scripts/script_running.txt")
if script_running
begin
file_created_time=(Time.now - File.mtime('/data/dist/scripts/script_running.txt')).to_i
old_file=file_created_time > 120

if old_file
puts "Script running file created before #{file_created_time} seconds"
        File.delete('/data/dist/scripts/script_running.txt')
end

puts "script is already running"
exit!
rescue ArgumentError => ex
        end
end


deploy_running = File.file?("/data/dist/scripts/deployTemp-payvoo-admin.txt")
if deploy_running
    begin
        file_created_time=(Time.now - File.mtime('/data/dist/scripts/deployTemp-payvoo-admin.txt')).to_i
        old_file=file_created_time > 900

        if old_file
            puts "Script running file created before #{file_created_time} seconds"
            File.delete('/data/dist/scripts/deployTemp-payvoo-admin.txt')
        end
        rescue ArgumentError => ex
        end
end


script_file = File.open('/data/dist/scripts/script_running.txt', 'w')
script_file.close

file_present = File.file?("/data/dist/scripts/deployTemp-payvoo-admin.txt")
process_running = ps -ef | grep payvoo-admin | grep -v grep| grep -v tail | wc -l.to_i > 0
deployment_not_running=ps -ef | grep "stop_app\|start_app" | grep -v grep | wc -l.to_i == 0
process_bootstrapped = grep "is running successfully at" /data/dist/payvoo-admin/current/logs/application.log | wc -l.to_i > 0
service_unhealthy=false
last_health_check=grep "is running successfully at" /data/dist/payvoo-admin/current/logs/application.log | tail -1 | awk '{print $1$2}'
health_cutoff_time=(DateTime.now - (1/(30*24.0))).to_time
puts "Health Cutoff Time #{health_cutoff_time.to_s}"
if not last_health_check.empty?
begin
last_health_check_ts=Time.strptime(last_health_check.split(",")[0],'%Y-%m-%d%H:%M:%S')
service_unhealthy = (last_health_check_ts.nil? or health_cutoff_time > last_health_check_ts)
puts "Health Check Time #{last_health_check_ts.to_s} service is #{service_unhealthy}"
rescue ArgumentError,TypeError => ex
end
end
last_log_ts_arr = tail -100 /data/dist/payvoo-admin/current/logs/application.log | awk '{print $1$2}'.split("\n")
last_log_ts = nil
last_log_ts_arr.each do |last_log_ts_line|
        begin
last_log_line_str = last_log_ts_line.split(",")[0]
if not last_log_line_str.nil?
                last_log_ts=Time.strptime(last_log_ts_line.split(",")[0],'%Y-%m-%d%H:%M:%S')
                break
end
        rescue ArgumentError,TypeError => ex
        end
end
puts "Last Log Time #{last_log_ts.to_s}"
puts "Deployemnt Temp file present is #{file_present}"
cutoff_time=(DateTime.now - (1/(6*24.0))).to_time
puts "Cutoff Time #{cutoff_time.to_s}"
logging_stopped = (last_log_ts.nil? or(cutoff_time > last_log_ts))

puts "Deployment Not Running #{deployment_not_running}, Process running : #{process_running}, Bootstrapped #{process_bootstrapped}, unhealthy #{service_unhealthy}, logging_stopped #{logging_stopped}"
#if (not service_unhealthy) or ((not last_log_ts.nil?) and cutoff_time > last_log_ts)
if deployment_not_running and ((not process_running) or (process_bootstrapped and (service_unhealthy or logging_stopped))) and (not file_present)
    puts(" Restart required:  retsarting admin server at #{Time.now.to_s} using command : /bin/bash /data/dist/scripts/stop_app.sh  payvoo-admin 0  && /bin/bash /data/dist/scripts/start_app.sh payvoo-admin 0 disabled 9011  1")
    system("/bin/bash /data/dist/scripts/stop_app.sh  payvoo-admin 0  && /bin/bash /data/dist/scripts/start_app.sh payvoo-admin  0 9011 0 1")
else
    puts "service already running, no restart required"
end

    File.delete('/data/dist/scripts/script_running.txt')