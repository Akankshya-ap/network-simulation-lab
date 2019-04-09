
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
set val(x)  500   ;# in metres
set val(y)  500   ;# in metres
#Adhoc OnDemand Distance Vector
set val(energymodel) EnergyModel ;
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


for {set i 0} {$i<20} {incr i} { 
	set p [expr {int(rand()*500)+1}]
	set q [expr {int(rand()*500)+1}]
	set n($i) [$ns node]
	$n($i) set X_ $p
	$n($i) set Y_ $q
	$n($i) set Z_ 0.0
	$n($i) random-motion 0
	$ns initial_node_pos $n($i) 30
}

##neigbours

proc dist {ix iy jx jy} {
set d [expr int(sqrt(pow(($ix-$jx),2)+pow(($iy-$jy),2)))]
}

for {set x 0} {$x < 20} {incr x} {
	set nb($x) {}
      for {set c 0} {$c < 20} {incr c} {
          set myarray($x,$c) 0
      }
}


for {set i 0} {$i<20} {incr i} { 
	
	set ix [$n($i) set X_ ]
	set iy [$n($i) set Y_ ]
	for {set j $i} {$j<20} {incr j} { 
		if {$j!=$i} {
			set jx [$n($j) set X_ ]
			set jy [$n($j) set Y_ ]
			set dis [dist $ix $iy $jx $jy]
			set myarray($i,$j) $dis
			set myarray($j,$i) $dis
			if {$dis<=150} {
				lappend nb($i) $j
				lappend nb($j) $i
			}

			#puts $dis
			#puts $locx
			#puts $des
		}
	}
}

for {set x 0} {$x < 20} {incr x} {
              for {set c $x} {$c < 20} {incr c} {
                  puts "Distance between $x $c is $myarray($x,$c)" 
              }
}
				
for {set x 0} {$x < 20} {incr x} {
	puts "Neighbour of $x are "
	foreach j $nb($x) {
		puts $j
	}
}




$ns at 10.0 "finish"

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

