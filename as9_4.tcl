#Create a simulator object
set ns [new Simulator]
$ns rtproto DV

#randomize
set p [expr {int(rand()*7)}]
set q [expr {int(rand()*7)}]
while {$p==$q} {
    set q [expr {int(rand()*7)}]
}
#puts "$p"
#puts "$q"
#Define different colors for data flows (for NAM)

$ns color 1 Blue
$ns color 2 Red
$ns color 3 Purple
$ns color 4 Black
$ns color 5 White
$ns color 6 Pink
$ns color 7 Brown

#Open the NAM trace file
set nf [open 9.nam w]
$ns namtrace-all $nf

set nf1 [open 9.tr w]
$ns trace-all $nf1

#Define a 'finish' procedure
proc finish {} {
        global ns nf nf1
        $ns flush-trace
        #Close the NAM trace file
        close $nf
	close $nf1
        #Execute NAM on the trace file
        exec nam 9.nam &
        exit 0
}

#Create 8 nodes
set i 0
for {set i 0} {$i<7} {incr i} { 
set n($i) [$ns node]
}

#Create links between the nodes

for {set i 0} {$i<7} {incr i} {
set w [expr {($i+1)%7}]
#puts "$w"
$ns duplex-link $n($i) $n($w) 1Mb 10ms DropTail
}

#Set Queue Size of link (n2-n3) to 10
#$ns queue-limit $n0 $n1 50
#$ns queue-limit $n0 $n1 50

#Give node position (for NAM)
$ns duplex-link-op $n(0) $n(1)  orient right-up
$ns duplex-link-op $n(1) $n(2)  orient right-down
$ns duplex-link-op $n(2) $n(3) orient right-down
$ns duplex-link-op $n(3) $n(4) orient left-down
$ns duplex-link-op $n(4) $n(5) orient left-down
$ns duplex-link-op $n(5) $n(6) orient left-up
$ns duplex-link-op $n(6) $n(0) orient up

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



#$ns rtmodel-at 2.6 down $R1 $R2
#Schedule events for the ftp and ftp agents


$ns at 0.1 "$ftp(0) start"
$ns rtmodel-at 3 down $n(6) $n(5)
$ns rtmodel-at 7 up $n(6) $n(5)
$ns at 12.0 "$ftp(0) stop"


#Call the finish procedure after 5 seconds of simulation time
$ns at 2.0 "finish"


#Run the simulation
$ns run




grep ^r 9.nam | wc -l
grep ^d 9.nam| wc -l
grep ^+ 9.nam| wc -l
grep ^- 9.nam| wc -l
