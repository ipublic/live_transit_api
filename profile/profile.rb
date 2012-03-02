AUTH_TOKEN=""
URL="http://rideonrealtime.net/arrivals/26328.json?auth_token=#{AUTH_TOKEN}"

(1..14).to_a.reverse.each do |conc_num|
  prof_cmd = "/usr/sbin/ab -n 250 -c #{conc_num}_users.dat -g #{conc_num}.dat -e #{conc_num}_users.csv '#{URL}' > #{conc_num}_users.txt"
  puts "Running: #{prof_cmd}"
  Kernel.system(prof_cmd)
end
