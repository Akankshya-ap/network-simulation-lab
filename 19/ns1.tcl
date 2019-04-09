set val(chan)       Channel/WirelessChannel
set val(prop)       Propagation/TwoRayGround
set val(netif)      Phy/WirelessPhy
set val(mac)        Mac/802_11
set val(ifq)        Queue/DropTail/PriQueue
set val(ll)         LL
set val(ant)        Antenna/OmniAntenna
set val(x)              670   ;# X dimension of the topography
set val(y)              670   ;# Y dimension of the topography
set val(ifqlen)         50            ;# max packet in ifq
set val(seed)           0.0
set val(adhocRouting)   DSDV
set val(nn)            	7             ;# how many nodes are simulated
set val(cp)             "tcpgen.tcl" 
set val(sc)             "scene-7" 
set val(seed)   	0.0 ;# seed for random number gen.
set val(stop)           300.0           ;# simulation time


set val(ftp1-start)      160.0
set val(ftp2-start)      170.0

set num_wired_nodes      2
set num_bs_nodes         2


# ============================================================================
# check for boundary parameters and random seed
if { $val(x) == 0 || $val(y) == 0 } {
	puts "No X-Y boundary values given for wireless topology\n"
}
if {$val(seed) > 0} {
	puts "Seeding Random number generator with $val(seed)\n"
	ns-random $val(seed)
}



set ns_		[new Simulator]


# create trace object for ns and nam
$ns_ node-config -addressType hierarchical    
AddrParams set domain_num_ 2           ;# number of domains
lappend cluster_num 2 2                ;# number of clusters in each
                                       ;#domain
AddrParams set cluster_num_ $cluster_num
lappend eilastlevel 1 1 5 4               ;# number of nodes in each cluster
AddrParams set nodes_num_ $eilastlevel ;# for each domain

set tracefd  [open ns1.tr w]
set namtrace [open ns1.nam w]
$ns_ trace-all $tracefd
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)

$ns_ use-newtrace
# setup topography object
set topo	[new Topography]
# define topology
$topo load_flatgrid $val(x) $val(y)

# create wired nodes
set temp {0.0.0 0.1.0}           ;# hierarchical addresses to be used
for {set i 0} {$i < $num_wired_nodes} {incr i} {
    set W($i) [$ns_ node [lindex $temp $i]]
}		
#
# Create God
#
set god_ [create-god [expr $val(nn) + $num_bs_nodes]]

	

# configure for base-station node
$ns_ node-config -adhocRouting $val(adhocRouting) \
                 -llType $val(ll) \
                 -macType $val(mac) \
                 -ifqType $val(ifq) \
                 -ifqLen $val(ifqlen) \
                 -antType $val(ant) \
                 -propType $val(prop) \
                 -phyType $val(netif) \
                 -channelType $val(chan) \
		 -topoInstance $topo \
                 -wiredRouting ON \
		 -agentTrace ON \
                 -routerTrace OFF \
                 -macTrace OFF 



#create base-station node
set temp0 {1.0.0 1.0.1 1.0.2 1.0.3 1.0.4}   ;# hier address to be used for
                                      ;# wireless domain
set temp1 {1.1.0 1.1.1 1.1.2 1.1.3}   ;# hier address to be used for
                                      ;# wireless domain



set BS(0) [ $ns_ node [lindex $temp0 0]]
$BS(0) random-motion 0               ;# disable random motion

set BS(1) [ $ns_ node [lindex $temp1 0]]
$BS(1) random-motion 0               ;# disable random motion


#provide some co-ordinates (fixed) to base station node
$BS(0) set X_ 11.0
$BS(0) set Y_ 12.0
$BS(0) set Z_ 0.0

$BS(1) set X_ 1.0
$BS(1) set Y_ 2.0
$BS(1) set Z_ 0.0

# create mobilenodes in the same domain as BS(0)
# note the position and movement of mobilenodes is as defined
# in $opt(sc)
# Note there has been a change of the earlier AddrParams 
# function 'set-hieraddr' to 'addr2id'.

#configure for mobilenodes
$ns_ node-config -wiredRouting OFF

# now create mobilenodes for BS(0)
for {set j 0} {$j < 4} {incr j} {
    set node_($j) [ $ns_ node [lindex $temp0 [expr $j+1]] ]
    $node_($j) base-station [AddrParams addr2id \
            [$BS(0) node-addr]]   ;# provide each mobilenode with
                                  ;# hier address of its base-station
}


# now create mobilenodes for BS(1)
set i 0
for {set j 4} {$j < 7} {incr j} {
    set node_($j) [ $ns_ node [lindex $temp1 [expr $i+1]] ]
	incr i
    $node_($j) base-station [AddrParams addr2id \
            [$BS(1) node-addr]]   ;# provide each mobilenode with
                                  ;# hier address of its base-station
}

$node_(0) set X_ -90.0
$node_(0) set Y_ 2.0
$node_(0) set Z_ 0.0

$node_(1) set X_ -70.0
$node_(1) set Y_ -11.0
$node_(1) set Z_ 0.0

$node_(2) set X_ -60.0
$node_(2) set Y_ -20.0
$node_(2) set Z_ 0.0

$node_(3) set X_ 7.0
$node_(3) set Y_ -40.0
$node_(3) set Z_ 0.0

$node_(4) set X_ 30.0
$node_(4) set Y_ -35.0
$node_(4) set Z_ 0.0

$node_(5) set X_ 43.0
$node_(5) set Y_ -27.0
$node_(5) set Z_ 0.0

$node_(6) set X_ 50.0
$node_(6) set Y_ -12.0
$node_(6) set Z_ 0.0

for {set i 0} {$i < $val(nn)} {incr i} {

    # 20 defines the node size in nam, must adjust it according to your scenario
    # The function must be called after mobility model is defined
    
    $ns_ initial_node_pos $node_($i) 5
}


#create links between wired and BS nodes      
$ns_ duplex-link $W(0) $W(1) 5Mb 2ms DropTail
$ns_ duplex-link $W(1) $BS(0) 5Mb 2ms DropTail
$ns_ duplex-link $W(1) $BS(1) 5Mb 2ms DropTail

$ns_ duplex-link-op $W(0) $W(1) orient right-down
$ns_ duplex-link-op $W(1) $BS(0) orient down
$ns_ duplex-link-op $W(1) $BS(1) orient left-down

# setup TCP connections
set tcp1 [new Agent/TCP]
$tcp1 set class_ 2
set sink1 [new Agent/TCPSink]
$ns_ attach-agent $node_(0) $tcp1
$ns_ attach-agent $W(0) $sink1
$ns_ connect $tcp1 $sink1
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ns_ at $val(ftp1-start) "$ftp1 start"

set tcp2 [new Agent/TCP]
$tcp2 set class_ 2
set sink2 [new Agent/TCPSink]
$ns_ attach-agent $W(1) $tcp2        
$ns_ attach-agent $node_(4) $sink2
$ns_ connect $tcp2 $sink2
set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2
$ns_ at $val(ftp2-start) "$ftp2 start"


# source connection-pattern and node-movement scripts
if { $val(cp) == "" } {
	puts "*** NOTE: no connection pattern specified."
        set val(cp) "none"
} else {
	puts "Loading connection pattern..."
	source $val(cp)
}
if { $val(sc) == "" } {
	puts "*** NOTE: no scenario file specified."
        set val(sc) "none"
} else {
	puts "Loading scenario file..."
	source $val(sc)
	puts "Load complete..."
}

for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at $val(stop).0 "$node_($i) reset";
}

$ns_ at $val(stop).0 "$BS(0) reset";
$ns_ at $val(stop).0 "$BS(1) reset";

# Define node initial position in nam

proc finish {} {
        global ns_ tracefd namtrace
        $ns_ flush-trace
        close $tracefd
        close $namtrace
	exec nam ns1.nam &    
        exit 0
}


$ns_ at $val(stop) "finish"

puts "Starting Simulation..."
$ns_ run




