BEGIN {
	recv_size = 0
	sTime = 1e6
	spTime = 0
	NumofRecd = 0
}

{
	event = $1
	time = $3
	node_id = $5
	packet = $19
	pkt_id = $41
	flow_id = $39
	packet_size = $37
	flow_type = $45
	
	if(packet == "AGT" && sendTime[pkt_id] == 0 && (event == "+1" || event == "s")) 
	{
		if(time<sTime) {
			sTime = time
		}
		sendTime[pkt_id] = time
		this_flow = flow_type
	}
	if ((packet == "AGT" || packet == "RTR") && event == "r")
	{
		if (time>spTime)
		{
			spTime = time
		}
		recv_size = recv_size + packet_size
		recvTime[pkd_id] = time
		NumofRecd = NumofRecd + 1
	}
}

END {
	if (NumofRecd == 0) 
	{
		printf("No packets, simulation might be small\n")
	}
	else
	{
		printf("\nStart time %d", sTime)
		printf("\nStop time %d", spTime)
		printf("\nNo. of packets received is %d",NumofRecd)
		printf("\nThroughput in kbps is %f\n", (recv_size / (spTime-sTime) * (8/1000)))
	}
}
