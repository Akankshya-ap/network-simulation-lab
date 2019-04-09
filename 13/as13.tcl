
#initialize the variables
set val(chan)           Channel/WirelessChannel    ;#Channel Type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type WAVELAN DSSS 2.4GHz
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             20                          ;# number of mobilenodes
set val(energymodel) EnergyModel ;
Phy/WirelessPhy  set CSThresh_ 		3.65262e-10 		;
set val(rp)             AODV                       ;# routing protocol
set val(x)  50   ;# in metres
set val(y)  50   ;# in metres
#Adhoc OnDemand Distance Vector 

#creation of Simulator
set ns [new Simulator]

$ns use-newtrace

#creation of Trace and namfile 
set tracefile [open wireless.tr w]
$ns trace-all $tracefile

#Creation of Network Animation file
set namfile [open wireless.nam w]
$ns namtrace-all-wireless $namfile $val(x) $val(y)

#create topography
set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)

#GOD Creation - General Operations Director
create-god $val(nn)

set channel1 [new $val(chan)]


$val(netif) set CPThresh_ 10.0
$val(netif) set CSThresh_ 2.28289e-11 ;#sensing range of 500m
$val(netif) set RXThresh_ 2.28289e-11 ;#communication range of 500m
$val(netif) set Rb_ 2*1e6
$val(netif) set Pt_ 0.2818
$val(netif) set freq_ 914e+6
$val(netif) set L_ 1.0

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
  -energyModel $val(energymodel) \
  -initialEnergy 10 \
  -rxPower 0.5 \
  -txPower 1.0 \
  -idlePower 0.0 \
  -agentTrace ON \
  -macTrace ON \
  -routerTrace ON \
  -movementTrace ON \
  -channel $channel1 

set i 0
for {set i 0} {$i<20} {incr i} { 
set n($i) [$ns node]
$n($i) random-motion 0 
$ns initial_node_pos $n($i) 3
}


set i 0
for {set i 0} {$i<10} {incr i} { 
#creation of agents
set t($i) $i
set udp($i) [new Agent/UDP]
set NULL($i) [new Agent/Null]
$ns attach-agent $n($i) $udp($i)
set v [expr {19-$i}]
puts $v
$ns attach-agent $n($v) $NULL($i)

$ns connect $udp($i) $NULL($i)
set cbr($i) [new Application/Traffic/CBR]
$cbr($i) set packetSize_ 500
$cbr($i) set interval_ 20
$cbr($i) set rate_ 0.033bps
$cbr($i) set burst-time 3.5
$cbr($i) attach-agent $udp($i)
$ns at [expr {$i+3.5}] "$cbr($i) start"
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

