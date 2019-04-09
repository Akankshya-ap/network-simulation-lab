BEGIN {

start = 0.000000000;
end = 0.000000000;
packet_duration = 0.0000000000;
recvnum = 0;
delay = 0.000000000;
sum = 0.000000000;
i=0;
}

{
state		= 	$1;
time 		= 	$3;

level 		= 	$19;
pkt_type 	= 	$35;
packet_id	= 	$41;



# Calculating Average End to End Delay

if (( state == "s") &&  ( pkt_type == "tcp" ) && ( level == "AGT" ))  { start_time[packet_id] = time; }

 else if (( state == "r") &&  ( pkt_type == "tcp" ) && ( level == "AGT" )) {  end_time[packet_id] = time;  }
 else {  end_time[packet_id] = -1;  }

}

END {

# For End to End Delay

for ( i in end_time ) {
 start = start_time[i];
 end = end_time[i];
 packet_duration = end - start;
 if ( packet_duration > 0 )  { sum += packet_duration; recvnum++; }
}
 
delay=sum/recvnum;
printf("Average End to End Delay 	:%.9f ms\n", delay);


}
