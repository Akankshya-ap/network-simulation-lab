#Create a simulator object
set ns [new Simulator]

#Define different colors for data flows (for NAM)

$ns color 1 Blue
$ns color 2 Red

#Open the NAM trace file
set nf [open 11.nam w]
$ns namtrace-all $nf

set nf1 [open 11.tr w]
$ns trace-all $nf1

#Define a 'finish' procedure
proc finish {} {
        global ns nf nf1
        $ns flush-trace
        #Close the NAM trace file
        close $nf
	close $nf1
        #Execute NAM on the trace file
        exec nam 11.nam &
        exit 0
}

#Create 8 nodes
set i 0
for {set i 0} {$i<6} {incr i} { 
set n($i) [$ns node]
}

#Create links between the nodes
$ns duplex-link $n(0) $n(2) 2Mb 10ms DropTail
$ns duplex-link $n(2) $n(1) 2Mb 10ms DropTail
$ns duplex-link $n(2) $n(3) 300kb 100ms DropTail

set lan [$ns newLan "$n(3) $n(4) $n(5)" 0.5Mb 40ms LL Queue/DropTail MAC/Csma/Cd Channel]

#Give node position (for NAM)
$ns duplex-link-op $n(0) $n(2)  orient right-down
$ns duplex-link-op $n(1) $n(2)  orient right-up
$ns duplex-link-op $n(2) $n(3) orient right
#$ns duplex-link-op $n(3) $n(4) orient right-up
#$ns duplex-link-op $n(3) $n(5) orient right-down


#Setup a tcp connection
set tcp(0) [new Agent/TCP]
$ns attach-agent $n(0) $tcp(0)

set sink(4) [new Agent/TCPSink]
$ns attach-agent $n(4) $sink(4)

$ns connect $tcp(0) $sink(4)

#set UDP
set udp1 [new Agent/UDP]
$ns attach-agent $n(1) $udp1

set NULL5 [new Agent/Null]
$ns attach-agent $n(5) $NULL5

$ns connect $udp1 $NULL5

#Setup a ftp over TCP connection

set ftp(0) [new Application/FTP]
$ftp(0) attach-agent $tcp(0)
$ftp(0) set type_ ftp
$tcp(0) set fid_ (0)+1

set cbr0 [new Application/Traffic/CBR]
$cbr0 attach-agent $udp1
$cbr0 set type_ CBR
$udp1 set fid_ 2



$ns at 0.1 "$ftp(0) start"
$ns at 6.0 "$ftp(0) stop"

$ns at 6.1 "$cbr0 start"

$ns at 12.0 "$cbr0 stop"



#Call the finish procedure after 5 seconds of simulation time
$ns at 10.0 "finish"

#Run the simulation
$ns run


grep ^r 11.nam | wc -l
grep ^d 11.nam| wc -l
grep ^+ 11.nam| wc -l
grep ^- 11.nam| wc -l
