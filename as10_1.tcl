#Create a simulator object
set ns [new Simulator]
$ns rtproto DV

#Define different colors for data flows (for NAM)

$ns color 1 Blue

#Open the NAM trace file
set nf [open 10.nam w]
$ns namtrace-all $nf

set nf1 [open 10.tr w]
$ns trace-all $nf1

#Define a 'finish' procedure
proc finish {} {
        global ns nf nf1
        $ns flush-trace
        #Close the NAM trace file
        close $nf
	close $nf1
        #Execute NAM on the trace file
        exec nam 10.nam &
        exit 0
}

#Create 8 nodes
set i 0
for {set i 0} {$i<6} {incr i} { 
set n($i) [$ns node]
}

#Create links between the nodes
$ns duplex-link $n(0) $n(1) 0.3Mb 10ms DropTail
$ns duplex-link $n(2) $n(1) 0.3Mb 10ms DropTail
$ns duplex-link $n(2) $n(3) 0.3Mb 10ms DropTail
$ns duplex-link $n(3) $n(5) 0.3Mb 10ms DropTail
$ns duplex-link $n(4) $n(5) 0.3Mb 10ms DropTail
$ns duplex-link $n(4) $n(1) 0.3Mb 10ms DropTail

#Give node position (for NAM)
$ns duplex-link-op $n(0) $n(1)  orient right-up
$ns duplex-link-op $n(1) $n(2)  orient right
$ns duplex-link-op $n(1) $n(4) orient left-up
$ns duplex-link-op $n(4) $n(5) orient right-up
$ns duplex-link-op $n(5) $n(3) orient right-down
$ns duplex-link-op $n(3) $n(2) orient down


#Setup a tcp connection
set tcp(0) [new Agent/TCP]
$ns attach-agent $n(0) $tcp(0)

set sink(5) [new Agent/TCPSink]
$ns attach-agent $n(5) $sink(5)

$ns connect $tcp(0) $sink(5)

#Setup a ftp over TCP connection

set ftp(0) [new Application/FTP]
$ftp(0) attach-agent $tcp(0)
$ftp(0) set type_ ftp
$tcp(0) set fid_ (0)+1

$ns at 0.1 "$ftp(0) start"
$ns rtmodel-at 1 down $n(1) $n(4)
$ns rtmodel-at 4.5 up $n(1) $n(4)
$ns at 12.0 "$ftp(0) stop"


#Call the finish procedure after 5 seconds of simulation time
$ns at 10.0 "finish"

#Run the simulation
$ns run


grep ^r 10.nam | wc -l
grep ^d 10.nam| wc -l
grep ^+ 10.nam| wc -l
grep ^- 10.nam| wc -l
