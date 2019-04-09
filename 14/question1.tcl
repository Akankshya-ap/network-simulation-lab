# Step-1: Initialize variables 
set val(chan) Channel/WirelessChannel ;		# channel type
set val(prop) Propagation/TwoRayGround ; 	# radio-propagation model
set val(netif) Phy/WirelessPhy ; 		# network interface type
set val(mac) Mac/802_11 ;			# MAC type
set val(ifq) Queue/DropTail/PriQueue ;		# interface queue type
set val(ll) LL ;				# link layer type
set val(ant) Antenna/OmniAntenna ;		# antenna model
set val(ifqlen) 50 ;				# max packet in ifq
set val(nn) 23 ;					# number of mobile nodes
set val(rp) AODV ;				# routing protocol
set val(x) 300 ;				# X dimension of topography
set val(y) 300 ;				# Y dimension of topography
set val(stop) 150 ;				# time of simulation end

# Step-2: Creating an instance of the simulator
set ns [new Simulator]

# Step-3: Creation of trace and nam file & include new trace format
set tracefile [open question1.tr w]
$ns trace-all $tracefile

set namfile [open question1.nam w]
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
-agentTrace ON \
-routerTrace ON \
-macTrace ON \
-movementTrace ON \
-channel $channel1

# Step-8: Create random array
for {set i 0} {$i<20} {incr i} {
	set rn($i) 0
}

set n(0) [$ns node]
set x_coordinate(0) 10
set y_coordinate(0) 0

for {set i 1} {$i<=20} {incr i} {
	set n($i) [$ns node]
	$n($i) shape square
	$n($i) random-motion 0
	set mod [expr int([expr rand() * 20])]
	while {$rn($mod) == 1} {
		set mod [expr int([expr rand() * 20])]
	}
	set rn($mod) 1
	set x_coordinate($i) [expr int($mod/10) * 20 ]

	set y_coordinate($i) [expr (int($mod%10) * 20)  + 20]
	$n($i) set X_ $x_coordinate($i)
	$n($i) set Y_ $y_coordinate($i)
	$n($i) set Z_ 0

	$ns initial_node_pos $n($i) 10
}

set i 0
$n(0) random-motion 0
$n(0) set X_ 10.0
$n(0) set Y_ 0.0
$n(0) set Z_ 0
$ns initial_node_pos $n(0) 10
set speed 5


## Question 1
for {set i 0} {$i<5} {incr i} {
	set time 0.0
	set dest [expr int(rand() * 20) + 1]
	puts "destination node is $dest"
	set y_coor 20.0
	set time [expr $time + (20 / $speed)]

	
	set dest_y_coor $y_coordinate($dest)

	puts "dest_y_coor is $dest_y_coor"

	while { $dest_y_coor  != $y_coor} {
		set y_coor [expr $y_coor+20]
		set time [expr $time + 2]
		
		set time [expr $time + (20/$speed)]
		
	}
	puts "Time taken for 1st type transmission is $time"

	##Question2
	##Assuming that initial time taken for TCP acknowledgemt is 10msec
	set time 10
	set y_coor 20
	set speed 10
	set time [expr $time + (20 / $speed)]
	while { $dest_y_coor  != $y_coor} {
		set y_coor [expr $y_coor+20]
		
		set time [expr $time + (20/$speed)]
		
	}
	puts "Time taken for 2nd type transmission is $time"

	
}

set D [$ns node]
$D random-motion 0
$D set X_ 20.0
$D set Y_ 0.0
$D set Z_ 0.0
$ns initial_node_pos $D 10

set n(21) [$ns node]
$n(21) random-motion 0
$n(21) set X_ 10.0
$n(21) set Y_ 0.0
$n(21) set Z_ 0.0
$ns initial_node_pos $n(21) 10





## Simulation for first question


set time 0
set dest [expr int(rand() * 20) + 1]
puts "dest is $dest"
set y_coor 20.0
set speed 5
$ns at $time "$n(0) setdest 10.0 $y_coor $speed"
set time [expr $time + (20 / $speed)]


set dest_y_coor $y_coordinate($dest)

while { $dest_y_coor  != $y_coor} {
	set y_coor [expr $y_coor+20]
	set time [expr $time + 2]
	puts "y_coor is $y_coor"
	$ns at $time "$n(0) setdest 10.0 $y_coor $speed"
	set time [expr $time + (20/$speed)]

}

## Simulation for second question

set tcp1 [new Agent/TCP]
$ns attach-agent $n(21) $tcp1

set sink1 [new Agent/TCPSink]
$ns attach-agent $D $sink1

$ns connect $tcp1 $sink1

set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1

$ns at 0.1 "$ftp1 start"
$ns at 5 "$ftp1 stop"

set time 10
set y_coor 20
set speed 10
$ns at $time "$n(21) setdest 10.0 $y_coor $speed"
set time [expr $time + (20 / $speed)]
while { $dest_y_coor  != $y_coor} {
	set y_coor [expr $y_coor+20]
	$ns at $time "$n(21) setdest 10.0 $y_coor $speed"
	puts "y_coor is $y_coor"
	puts "time is $time "
	set time [expr $time + (20/$speed)]
	
}




proc finish {} {
	global ns tracefile namfile
	$ns flush-trace
	close $tracefile
	close $namfile	
	exec nam question1.nam &
	exit 0
}

$ns at 100.0 "finish"

$ns run