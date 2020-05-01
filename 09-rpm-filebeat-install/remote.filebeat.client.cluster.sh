#!/bin/bash

NODE01=10.10.4.105 
NODE02=10.10.4.166 
NODE02=10.10.5.14 
NODE04=10.10.5.42 
NODE05=10.10.6.114 
NODE06=10.10.6.159

for Y in $NODE{01..06}
do
   ssh -i /home/dihogoteixeira/Documents/.key/elk-cluster.pem ec2-user@$NODE$Y \
       'bash -s' < /home/dihogoteixeira/Documents/dteixeira-core/elk-stack-template-tf/09-rpm-filebeat-install/filebeat.daemon.install.sh
done

exit 0