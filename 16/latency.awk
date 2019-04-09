BEGIN  {
	seqno=-1;
	dp=0;
	rp=0;
	cnt=0;
}
{
	event = $1
	packet = $19

	if(packet=="AGT"&&(event == "+1" || event == "s")&&seqno<$6)
	{
		seqno=$6;
	}
	else if((packet=="AGT" || packet == "RTR")&&(event=="r"))
	{
		rp++;
	}
	else if($1=="d")
	{
	dp++;
	}
	#end_end delay
	if(packet=="AGT"&&(event == "+1" || event == "s"))
	{
	start_time[$6]=$2;
	}
	else if((packet=="AGT" || packet == "RTR")&&(event=="r"))
	{
	end_time[$6]=$2;
	}
	else if($1=="s")
	{
	end_time[$6]=-1;
	}
}
END{
	printf("\n%.2f", seqno);
	for(i=0;i<=seqno;i++)
	{
	if(end_time[i]>0)
	{
	delay[i]=end_time[i]-start_time[i];
	cnt++;
	}
	else
	{
	delay[i]=-1;
	}
	}
	for(i=0;i<=seqno;i++)
	{
	if(delay[i]>0)
	{
	ssdelay=ssdelay+delay[i];
	}
	}
	ssdelay=ssdelay/(cnt+1);
	printf( "average ssdelay= %.2f" ,ssdelay*1000);
	print "\n";
}
