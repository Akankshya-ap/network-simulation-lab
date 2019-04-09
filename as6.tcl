#Create a simulator object
set ns [new Simulator]

#Define different colors for data flows (for NAM)

$ns color 1 Blue
$ns color 2 Red

#Open the NAM trace file
set nf [open 6.nam w]
$ns namtrace-all $nf

set nf1 [open 6.tr w]
$ns trace-all $nf1

#Define a 'finish' procedure
proc finish {} {
        global ns nf nf1
        $ns flush-trace
        #Close the NAM trace file
        close $nf
	close $nf1
        #Execute NAM on the trace file
        exec nam 6.nam &
        exit 0
}

#Create four nodes
set C1 [$ns node]
set C2 [$ns node]
set R1 [$ns node]
set R2 [$ns node]
set S1 [$ns node]

$R1 shape square
$R2 shape square
$S1 shape hexagon

#Create links between the nodes
$ns duplex-link $R1 $R2 150kb 50ms DropTail
$ns duplex-link $R2 $S1 300kb 50ms DropTail
$ns duplex-link $C1 $R1 5Mb 50ms DropTail
$ns duplex-link $C2 $R1 5Mb 50ms DropTail

#Set Queue Size of link (n2-n3) to 10
#$ns queue-limit $n0 $n1 50
#$ns queue-limit $n0 $n1 50

#Give node position (for NAM)
#$ns duplex-link-op $n0 $n1 orient right
#$ns duplex-link-op $n1 $n2 orient right-down


#Setup a UdP connection
set udp0 [new Agent/UDP]
$ns attach-agent $C1 $udp0

set udp1 [new Agent/UDP]
$ns attach-agent $C2 $udp1

set NULL0 [new Agent/Null]
$ns attach-agent $S1 $NULL0

set NULL1 [new Agent/Null]
$ns attach-agent $S1 $NULL1

$ns connect $udp0 $NULL0
$ns connect $udp1 $NULL1


#Setup a CBR over UCP connection
set cbr0 [new Application/Traffic/CBR]
$cbr0 attach-agent $udp0
$cbr0 set type_ CBR
$udp0 set fid_ 1

set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp1
$cbr1 set type_ CBR
$udp1 set fid_ 2


$ns rtmodel-at 2.6 down $R1 $R2
#Schedule events for the CBR and cbr agents
$ns at 0.5 "$cbr0 start"
$ns at 0.7 "$cbr1 start"
$ns rtmodel-at 2.5 down $R1 $R2
$ns at 4.6 "$cbr0 stop"
$ns at 7.0 "$cbr1 stop"


#Call the finish procedure after 5 seconds of simulation time
$ns at 8.0 "finish"


#Run the simulation
$ns run




grep ^r 6.nam | wc -l
grep ^d 6.nam| wc -l
grep ^+ 6.nam| wc -l
grep ^- 6.nam| wc -l
