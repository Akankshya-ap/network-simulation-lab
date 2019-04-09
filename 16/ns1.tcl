set val(chan)         Channel/WirelessChannel  ;# channel type
set val(prop)         Propagation/TwoRayGround ;# radio-propagation model
set val(ant)          Antenna/OmniAntenna      ;# Antenna type
set val(ll)           LL                       ;# Link layer type
set val(ifq)          Queue/DropTail/PriQueue  ;# Interface queue type
set val(ifqlen)       50                       ;# max packet in ifq
set val(netif)        Phy/WirelessPhy ;# network interface type
set val(mac)          Mac/SMAC		       ;# MAC type
set val(rp)           AODV                     ;# ad-hoc routing protocol 
set val(nn)           50                        ;# number of mobilenodes
set val(x)	      500;
set val(y)	      500;
set val(energymodel) EnergyModel ;#Energy set up
set ns [new Simulator]

set tracefile [open ns1_smac.tr w]
$ns trace-all $tracefile

set namfile [open ns1_smac.nam w]
$ns namtrace-all-wireless $namfile $val(x) $val(y)

$ns use-newtrace
set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)

create-god $val(nn)

set channel1 [new $val(chan)]
set channel2 [new $val(chan)]


# Configure nodes
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
                         -energyModel $val(energymodel) \
			 -rxPower 0.5 \
			 -txPower 1.0 \
			 -idlePower 0.0 \
   			 -sensePower 0.3 \
			 -initialEnergy 1000 \
			 -channel $channel1


set nnums 50


#Create Nodes
for {set i 0} {$i<$nnums} {incr i} {
	set n($i) [$ns node]
}


for {set i 0} {$i<$nnums} {incr i} {
	$n($i) shape square

}

#Disable Random Motion
for {set i 0} {$i<$nnums} {incr i} {
	$n($i) random-motion 0

}


#Define the size of nodes
for {set i 0} {$i<$nnums} {incr i} {
	$ns initial_node_pos $n($i) 20
}


#Randomly create nodes
proc myRand {min max} {
    expr {int(rand() * ($max + 1 - $min)) + $min}
}


set rmin 20
set rmax 480
set xnums {}
set ynums {}

set S [myRand 0 [expr $nnums-1]]
set R [myRand 0 [expr $nnums-1]]

while {$S == $R} {
	set S [myRand 0 [expr $nnums-1]]
}



while {[llength $xnums] < $nnums} {
	#X coordinate
	set node [myRand $rmin $rmax]
	if {$node ni $xnums} {lappend xnums $node}
}

while {[llength $ynums] < $nnums} {
	#Y coordinate
	set node [myRand $rmin $rmax]
	if {$node ni $ynums} {lappend ynums $node}
}

#set xnums [linsert $xnums 0 {}]
#set ynums [linsert $ynums 0 {}]

puts "Coordinates are : "
for {set i 0} {$i < $nnums} {incr i} {
	set X($i) [lindex $xnums $i]
	set Y($i) [lindex $ynums $i]
	
}

for {set i 0} {$i<$nnums} {incr i} {
	$n($i) set X_ $X($i)
	$n($i) set Y_ $Y($i)
	$n($i) set Z_ 0.0
	
	$ns at 0.0 "$n($i) setdest $X($i) $Y($i) 0.0"
}

puts "Sender $S"
puts "Receiver $R"


set udp [new Agent/UDP]
$ns attach-agent $n($S) $udp
set null [new Agent/Null]
$ns attach-agent $n($R) $null
$ns connect $udp $null
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp

$ns at 1.0 "$cbr start"

$ns at 100.0 "finish"

proc finish {} {
        global ns tracefile namfile
        $ns flush-trace
        close $tracefile
        close $namfile  
	exec nam ns1_smac.nam &      
        exit 0
}

puts "Starting Simulation"
$ns run

