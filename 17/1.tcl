# Step-1: Initialize variables 
set val(chan) Channel/WirelessChannel ;		# channel type
set val(prop) Propagation/TwoRayGround ; 	# radio-propagation model
set val(netif) Phy/WirelessPhy ; 		# network interface type
set val(mac) Mac/802_11 ;			# MAC type
set val(ifq) Queue/DropTail/PriQueue ;		# interface queue type
set val(ll) LL ;				# link layer type
set val(ant) Antenna/OmniAntenna ;		# antenna model
set val(ifqlen) 50 ;				# max packet in ifq
set val(nn) 17 ;					# number of mobile nodes
set val(rp) AODV ;
set val(energymodel) EnergyModel ;				# routing protocol
set val(x) 956 ;				# X dimension of topography
set val(y) 600 ;				# Y dimension of topography
				
# Step-2: Creating an instance of the simulator
set ns [new Simulator]

# Step-3: Creation of trace and nam file & include new trace format
set tracefile [open 1.tr w]
$ns trace-all $tracefile

set namfile [open 1.nam w]
$ns namtrace-all-wireless $namfile $val(x) $val(y)

# for including new trace format as it consists of 52 columns
$ns use-newtrace

# Step-4: Create Topography
set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)

# Step-5: Create GOD (General Operations Director)
create-god $val(nn)

# Step-6: Create Channel
set channel1 [new $val(chan)]

# Step-7: Configure the nodes
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
-initialEnergy 50 \
-rxPower 0.7 \
-txPower 0.9 \
-idlePower 0.6 \
-sleepPower 0.1 \
-agentTrace ON \
-routerTrace ON \
-macTrace ON \
-movementTrace ON \
-channel $channel1

# Step-8: Create random array
for {set i 0} {$i<17} {incr i} {
	set rn($i) 0
}



for {set i 0} {$i<17} {incr i} {
	set n($i) [$ns node]
	$n($i) shape square

}

$n(0) set X_ 199
$n(0) set Y_ 443
$n(0) set Z_ 0

$n(1) set X_ 361
$n(1) set Y_ 432
$n(1) set Z_ 0

$n(2) set X_ 363
$n(2) set Y_ 487
$n(2) set Z_ 0

$n(3) set X_ 210
$n(3) set Y_ 271
$n(3) set Z_ 0

$n(4) set X_ 246
$n(4) set Y_ 149
$n(4) set Z_ 0

$n(5) set X_ 402
$n(5) set Y_ 141
$n(5) set Z_ 0

$n(6) set X_ 499
$n(6) set Y_ 261
$n(6) set Z_ 0

$n(7) set X_ 564
$n(7) set Y_ 418
$n(7) set Z_ 0

$n(8) set X_ 609
$n(8) set Y_ 292
$n(8) set Z_ 0

$n(9) set X_ 542
$n(9) set Y_ 115
$n(9) set Z_ 0

$n(10) set X_ 370
$n(10) set Y_ 41
$n(10) set Z_ 0

$n(11) set X_ 688
$n(11) set Y_ 156
$n(11) set Z_ 0

$n(12) set X_ 758
$n(12) set Y_ 316
$n(12) set Z_ 0

$n(13) set X_ 728
$n(13) set Y_ 428
$n(13) set Z_ 0

$n(14) set X_ 695
$n(14) set Y_ 54
$n(14) set Z_ 0

$n(15) set X_ 556
$n(15) set Y_ 21
$n(15) set Z_ 0

$n(16) set X_ 695
$n(16) set Y_ 188
$n(16) set Z_ 0



for {set i 0} {$i<17} {incr i} {
	$n($i) random-motion 0
	$ns initial_node_pos $n($i) 10
}


$ns at 1.0 "[$n(5) set ragent_] blackhole"

$ns at 1.0 "$n(2) setdest 500 300 10"
$ns at 10.0 "$n(2) setdest 600 500 30"
$ns at 2.0 "$n(9) setdest 363 287 30"
$ns at 8.0 "$n(9) setdest 695 54 25"
## Simulation for second question

set tcp1 [new Agent/TCP]
$ns attach-agent $n(3) $tcp1

set sink1 [new Agent/TCPSink]
$ns attach-agent $n(12) $sink1

$ns connect $tcp1 $sink1

set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1

$ns at 1.0 "$ftp1 start"



set tcp2 [new Agent/TCP]
$ns attach-agent $n(4) $tcp2

set sink2 [new Agent/TCPSink]
$ns attach-agent $n(16) $sink2

$ns connect $tcp2 $sink2

set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2

$ns at 2.0 "$ftp2 start"
$ns at 15 "$ftp1 stop"
$ns at 20 "$ftp2 stop"



proc finish {} {
	global ns tracefile namfile
	$ns flush-trace
	close $tracefile
	close $namfile	
	exec nam 1.nam &
	exit 0
}

$ns at 100.0 "finish"

$ns run
