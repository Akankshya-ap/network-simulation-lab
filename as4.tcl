#Create a simulator object
set ns [new Simulator]

#Define different colors for data flows (for NAM)

$ns color 1 Blue

#Open the NAM trace file
set nf [open 4.nam w]
$ns namtrace-all $nf

set nf1 [open 4.tr w]
$ns trace-all $nf1

#Define a 'finish' procedure
proc finish {} {
        global ns nf nf1
        $ns flush-trace
        #Close the NAM trace file
        close $nf
	close $nf1
        #Execute NAM on the trace file
        exec nam 4.nam &
        exit 0
}

#Create four nodes
set clientC [$ns node]

set routerR [$ns node]
set serverS [$ns node]
$routerR shape square
$serverS shape hexagon

#Create links between the nodes
$ns duplex-link $clientC $routerR 2Mb 100ms DropTail
$ns duplex-link $routerR $serverS 200kb 100ms DropTail

#Set Queue Size of link (n2-n3) to 10
#$ns queue-limit $n0 $n1 50
#$ns queue-limit $n0 $n1 50

#Give node position (for NAM)
#$ns duplex-link-op $n0 $n1 orient right
#$ns duplex-link-op $n1 $n2 orient right-down


#Setup a TCP connection
set tcp [new Agent/TCP]

$ns attach-agent $clientC $tcp
set sink [new Agent/TCPSink]
$ns attach-agent $serverS $sink
$ns connect $tcp $sink


#Setup a FTP over TCP connection
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ftp set type_ FTP
$tcp set fid_ 1

#Schedule events for the CBR and FTP agents
$ns at 0.1 "$ftp start"
$ns at 7.0 "$ftp stop"


#Call the finish procedure after 5 seconds of simulation time
$ns at 8.0 "finish"


#Run the simulation
$ns run




grep ^r 4.nam | wc -l
grep ^d 4.nam| wc -l
grep ^+ 4.nam| wc -l
grep ^- 4.nam| wc -l
