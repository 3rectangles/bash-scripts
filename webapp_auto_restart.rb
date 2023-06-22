require 'time'
require 'socket'

ip_address = Socket.ip_address_list[1].ip_address
if ip_address == "10.140.15.207"
  puts "Not running on base server"
  exit
end
hikari_failure= tail -1000 /data/dist/payvoo-webapp/current/logs/application.log | grep 'java.sql.SQLTransientConnectionException: HikariPool-0 - Connection is not available' | wc -l.to_i > 0
process_running =ps -ef | grep payvoo-webapp | grep -v grep | wc -l.to_i > 0
puts %Q["process_running #{process_running}"]
restart_moh=11*(Socket.ip_address_list[1].ip_address.split(".")[-1].to_i % 6)+3
puts %Q["restart_moh #{restart_moh}"]
puts %Q["Socket #{Socket}"]
puts %Q["Socket.ip_address_list" #{Socket.ip_address_list}]
puts %Q["Socket.ip_address_list[1]" #{Socket.ip_address_list[1]}]
puts %Q["Socket.ip_address_list[1].ip_address.split(".")" #{Socket.ip_address_list[1].ip_address.split(".")}]
puts %Q["Socket.ip_address_list[1].ip_address.split(".")[-1] #{Socket.ip_address_list[1].ip_address.split(".")[-1]}"]
moh=Time.now.min
puts "moh #{moh}"
moh += 60 if moh < 3
puts "moh #{moh}"
puts "Time.now #{Time.now}"
last_try = (Time.now - 3*60).min
puts %Q["Time.now - 360" #{Time.now - 360}]
puts "last_try #{last_try}"
puts "restart_moh #{restart_moh}"
force_restart = false
puts "force restart #{force_restart}"

last_log_ts_arr = tail -100 /data/dist/payvoo-webapp/current/logs/application.log | awk '{print $1$2}'.split("\n")
last_log_ts = nil
last_log_ts_arr.each do |last_log_ts_line|
        begin
                last_log_ts=Time.strptime(last_log_ts_line.split(",")[0],'%Y-%m-%d%H:%M:%S')
                break
        rescue ArgumentError => ex
        end
end
cutoff_time=(DateTime.now - (1/(15*24.0))).to_time
puts "Cutoff Time #{cutoff_time.to_s}"
puts "Last Log Time #{last_log_ts.to_s}"
if ((not process_running) or force_restart or hikari_failure or ((not last_log_ts.nil?) and cutoff_time > last_log_ts))
        puts(" restarting cs server : /bin/bash /data/dist/scripts/stop_app.sh  payvoo-webapp 0  && /bin/bash /data/dist/scripts/start_app.sh payvoo-webapp 0 9000 disabled 1")
        system("/bin/bash /data/dist/scripts/stop_app.sh  payvoo-webapp 0  && /bin/bash /data/dist/scripts/start_app.sh payvoo-webapp 0 9000 disabled  1")
else
        puts "service already running, no restart required"
end