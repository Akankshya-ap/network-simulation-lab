
#initialize the variables
set val(chan)           Channel/WirelessChannel    ;#Channel Type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type WAVELAN DSSS 2.4GHz
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             26                          ;# number of mobilenodes
set val(rp)             AODV                       ;# routing protocol
set val(x)  250   ;# in metres
set val(y)  250   ;# in metres
#Adhoc OnDemand Distance Vector

#creation of Simulator
set ns [new Simulator]

#creation of Trace and namfile 
set tracefile [open wireless.tr w]
$ns trace-all $tracefile

#Creation of Network Animation file
set namfile [open wireless.nam w]
$ns namtrace-all-wireless $namfile $val(x) $val(y)

$ns use-newtrace

#create topography
set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)

#GOD Creation - General Operations Director
create-god $val(nn)

set channel1 [new $val(chan)]


#configure the node
$ns node-config -adhocRouting $val(rp) \
  -llType $val(ll) \
  -macType $val(mac) \
  -ifqType $val(ifq) \
  -ifqLen $val(ifqlen) \
  -antType $val(ant) \
  -propType $val(prop) \
  -phyType $val(netif) \
  -topoInstance $topo \
  -agentTrace ON \
  -macTrace ON \
  -routerTrace ON \
  -movementTrace ON \
  -channel $channel1 



######Node creationnnnnn###
for {set i 0} {$i<40} {incr i} { 
	set n($i) [$ns node]

}

set x {10 90 110 190 210}
set q 0
foreach p $x {
set y [expr {25/2}]
for {set i 0} {$i<8} {incr i} { 
	$n($q) set X_ $p
	$n($q) set Y_ $y
	if {$y>=75} {
	if {$y<=100} {
		set y [expr {$y+25}]
	}
	}
	set y [expr {$y+25}]
	$n($q) set Z_ 0.0
	$n($q) random-motion 0
	$n($q) color black
	$ns initial_node_pos $n($q) 20
	set q [expr {$q+1}]
	
}
}

$ns at 0.0 "$n(1) color green"
$ns at 0.0 "$n(5) color green"
$ns at 0.0 "$n(8) color green"
$ns at 0.0 "$n(14) color green"
$ns at 0.0 "$n(17) color green"
$ns at 0.0 "$n(19) color green"
$ns at 0.0 "$n(21) color green"
$ns at 0.0 "$n(23) color green"
$ns at 0.0 "$n(26) color green"
$ns at 0.0 "$n(29) color green"
$ns at 0.0 "$n(13) color green"
$ns at 0.0 "$n(33) color green"
$ns at 0.0 "$n(38) color green"
$ns at 0.0 "$n(39) color green"



$ns at 200.0 "finish"

proc finish {} {
 global ns tracefile namfile
 $ns flush-trace
 close $tracefile
 close $namfile
 exec nam wireless.nam &
 exit 0
}

puts "Starting Simulation"
$ns run


grep ^r wireless.tr | wc -l
grep ^D wireless.tr| wc -l
grep ^s wireless.tr| wc -l

grep ^+ wireless.tr| wc -l

