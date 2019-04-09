# AWK Script for Packet Delivery Calculation for OLD Trace Format
#s(5) with AGT(19) Packet id Ii(41) Flow id If(39)  Flow type It(45)

#begin #body-for each statement #end

BEGIN {
	NumofRecd=0
	sTime=1e6
	spTime=0
	recv_size=0
}

{
	event=$1
	time=$3
	node_id=$5
	packet=$19
	pkt_id=$41
	flow_is=$39
	packet_size=$37
	flow_type=$45

	if((event=="s" || event=="+1") && packet=="AGT" && sendTime[pkt_id]==0){
		if (time<sTime){
			sTime=time
		}
	sendTime[pkt_id]=time
	this_flow=flow_type
	}#|| packet=="RTR"
	if((packet=="AGT" || packet=="RTR" ) && event=="r"){
		if(time>spTime){
			spTime=time
		}
		recv_size=recv_size+packet_size
		recvTime[pkt_id]=time
		NumofRecd=NumofRecd+1
	}
 
}
END {
	 
	if(NumofRecd==0){
		printf("No packets, simulation must be small\n")}
		printf("\nStart time %d",sTime)
		printf("\nStop time %d",spTime)
		printf("\nReceived packet %d",NumofRecd)
		printf("\n The throughput in kbps is %f",(recv_size)/(spTime-sTime)*(8/1000));

	
}
