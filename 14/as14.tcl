
#initialize the variables
set val(chan)           Channel/WirelessChannel    ;#Channel Type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type WAVELAN DSSS 2.4GHz
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             21                          ;# number of mobilenodes
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

set n(0) [$ns node]
$n(0) set X_ 10.0
$n(0) set Y_ 0.0
$n(0) set Z_ 0.0





set mylist {}
#$ns at 1.0000000 "$n($p) setdest 0.0 0.0 0.0"


set s 0

set f 1
set i 0
for {set i 1} {$i<21} {incr i} { 
#puts "i"
#puts $i
	set f 1
	set p [expr {int(rand()*20)+1}]
	while {$f==1} {
		set p [expr {int(rand()*20)+1}]
		set f 0
		for {set j 0} {$j < [llength $mylist]} {incr j} {
	    if {[lindex $mylist $j]==$p} {
		set f 1
		}
	}   
	}
	puts $p

	lappend mylist $p

	if {$p%2!=0} {
		set r 0
	} else {
		set r 20.0
	}
	set s [expr {20*floor(($p-1)/2)}]
	
	set n($i) [$ns node]
	$n($i) set X_ $r
	$n($i) set Y_ $s
	$n($i) set Z_ 0.0
	$n($i) random-motion 0
	$ns initial_node_pos $n($i) 10
}



#####################################################
#####Set destination#########


proc add {y} {
    expr {$y + 20.001}
}

set d [expr {int(rand()*20)+1}]

set r 10
set s 0
#$ns at 1.0 "$n(0) setdest 10.0 0.0 5.0"


$n(0) set X_ 10.0
$n(0) set Y_ 0.1
$n(0) set Z_ 0.0

$ns at 0.0001 "$n(0) setdest 10.0 0.1 0.001"

set locx [$n($d) set X_ ]
set des [$n($d) set Y_ ]

set cur 0.1
set timer 1
puts $n($d)

puts $cur
puts $des

while {[expr abs($cur - $des)] > 5} {

	set cur [add $cur]
	puts $cur
	puts $des
	after 300
	$ns at $timer "$n(0) setdest 10.0 $cur 5.0"
	incr timer 6
}






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

