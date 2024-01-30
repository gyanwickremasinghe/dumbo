# the number of remove AWS servers
N = 4

# public IPs --- This is the public IPs of AWS servers
 pubIPsVar=([0]='3.236.98.149'
 [1]='3.250.230.5'
 [2]='13.236.193.178'
 [3]='18.181.208.49')
 
# private IPs --- This is the private IPs of AWS servers
 priIPsVar=([0]='172.31.71.134'
 [1]='172.31.7.198'
 [2]='172.31.6.250'
 [3]='172.31.2.176')

# Clone code to all remote AWS servers from github
 i=0; while [ $i -le $(( N-1 )) ]; do
 ssh -i "/home/your-name/your-key-dir/your-sk.pem" -o StrictHostKeyChecking=no ubuntu@${pubIPsVar[i]} "git clone --branch master https://github.com/yylluu/dumbo.git" &
 i=$(( i+1 ))
 done

# Update IP addresses to all remote AWS servers 
 rm tmp_hosts.config
 i=0; while [ $i -le $(( N-1 )) ]; do
   echo $i ${priIPsVar[$i]} ${pubIPsVar[$i]} $(( $((200 * $i)) + 10000 )) >> tmp_hosts.config
   i=$(( i+1 ))
 done
 i=0; while [ $i -le $(( N-1 )) ]; do
   ssh -o "StrictHostKeyChecking no" -i "/home/your-name/your-key-dir/your-sk.pem" ubuntu@${pubIPsVar[i]} "rm /home/ubuntu/dumbo/hosts.config"
   scp -i "/home/your-name/your-key-dir/your-sk.pem" tmp_hosts.config ubuntu@${pubIPsVar[i]}:/home/ubuntu/dumbo/hosts.config &
   i=$(( i+1 ))
 done
 
 # Start Protocols at all remote AWS servers
 i=0; while [ $i -le $(( N-1 )) ]; do   ssh -i "/home/your-name/your-key-dir/your-sk.pem" ubuntu@${pubIPsVar[i]} "export LIBRARY_PATH=$LIBRARY_PATH:/usr/local/lib; export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib; cd dumbo; nohup python3 run_socket_node.py --sid 'sidA' --id $i --N $N --f $(( (N-1)/3 )) --B 10000 --K 11 --S 50 --T 2 --P "bdt" --F 1000000 > node-$i.out" &   i=$(( i+1 )); done

 # Download logs from all remote AWS servers to your local PC
 i=0
 while [ $i -le $(( N-1 )) ]
 do
   scp -i "/home/your-name/your-key-dir/your-sk.pem" ubuntu@${pubIPsVar[i]}:/home/ubuntu/dumbo/log/node-$i.log node-$i.log &
   i=$(( i+1 ))
 done
