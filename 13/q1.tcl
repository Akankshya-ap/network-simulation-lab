set val(chan)           Channel/WirelessChannel    ;# channel type 
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model 
set val(netif)          Phy/WirelessPhy            ;# network interface type 
set val(mac)            Mac/802_11                 ;# MAC type 
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type 
set val(ll)             LL                         ;# link layer type 
set val(ant)            Antenna/OmniAntenna        ;# antenna model 
set val(ifqlen)         50                         ;# max packet in ifq 
set val(nn)             20                          ;# number of mobilenodes 
set val(rp)             AODV                       ;# routing protocol 
set val(x)              50  			           ;# X dimension of topography 
set val(y)              50  			           ;# Y dimension of topography   
#set val(stop)		50			   ;# time of simulation end set val(err)        UniformErrorProc 

set ns [new Simulator]

$ns color 1 Blue
$ns color 2 Red

set tracefile [open wireless.tr w]
$ns trace-all $tracefile

set namfile [open wireless.nam w]
$ns namtrace-all-wireless $namfile $val(x) $val(y)

set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)

create-god $val(nn)

set channel1 [new $val(chan)]
set channel2 [new $val(chan)]

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
			 	-routerTrace ON \
			 	-macTrace ON \
			 	-movementTrace ON \
				-energyModel EnergyModel \
				-initialEnergy 1 \
				-rxPower 0.0591 \
				-txPower 0.0522 \
				-idlePower 0.0591 \
			 	-channel $channel1

for {set i 0} {$i < 6} {incr i} {
	set n($i) [$ns node]
	$n($i) random-motion 0
	$ns initial_node_pos $n($i) 5
	$n($i) set X_ 25.0
	$n($i) set Y_ 25.0
	$n($i) set Z_ 0.0
}

set null [new Agent/Null]
$ns attach-agent $n(5) $null

for {set j 0} {$j < 3} {incr j} {
	set udp($j) [new Agent/UDP]
	$ns attach-agent $n($j) $udp($j)
	$udp($j) set packetSize_ 1024
	set cbr($j) [new Application/Traffic/CBR]
	$cbr($j) set packetSize_ 500
	$cbr($j) set interval_ 20
	$cbr($j) set rate_ 0.033mbps
	$cbr($j) attach-agent $udp($j)
	$ns connect $udp($j) $null
	$ns at [expr ($j + 3.0)] "$cbr($j) start"
	puts $n($j)
}


$ns at 50.0 "finish"

proc finish {} {
        global ns namfile tracefile
        $ns flush-trace
        #Close the NAM trace file
        close $namfile
        #Close the tf file
        close $tracefile
        #Execute NAM on the trace file
        exec nam wireless.nam &
        exit 0
}

puts "Starting Simulation"

$ns run
