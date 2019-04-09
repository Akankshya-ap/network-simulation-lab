set opt(chan)           Channel/WirelessChannel    ;# channel type
set opt(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set opt(netif)          Phy/WirelessPhy            ;# network interface type
set opt(mac)            Mac/802_11                 ;# MAC type
set opt(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set opt(ll)             LL                         ;# link layer type
set opt(ant)            Antenna/OmniAntenna        ;# antenna model
set opt(ifqlen)         50                         ;# max packet in ifq
set opt(nn)             7                          ;# number of mobilenodes
set opt(adhocRouting)   DSDV                       ;# routing protocol
set opt(cp)             "tcpgen.tcl"                         ;# connection pattern file
set opt(sc)     "scene-7"    ;# node movement file. 

set opt(x)      670                            ;# x coordinate of topology
set opt(y)      670                            ;# y coordinate of topology
set opt(seed)   0.0                            ;# seed for random number gen.
set opt(stop)   250                            ;# time to stop simulation

set opt(ftp1-start)      160.0
set opt(ftp2-start)      170.0

set num_wired_nodes      2
set num_bs_nodes         2
#total number of nodes 7+2+2 = 11 nodes.
# ============================================================================
# check for boundary parameters and random seed
if { $opt(x) == 0 || $opt(y) == 0 } {
	puts "No X-Y boundary values given for wireless topology\n"
}
if {$opt(seed) > 0} {
	puts "Seeding Random number generator with $opt(seed)\n"
	ns-random $opt(seed)
}

# create simulator instance
set ns_   [new Simulator]

# set up for hierarchical routing
$ns_ node-config -addressType hierarchical
AddrParams set domain_num_ 2          ;# number of domains
lappend cluster_num 2 2                ;# number of clusters in each domain
#cluster 0, cluster 1, cluster 2 and cluster 3
AddrParams set cluster_num_ $cluster_num
lappend eilastlevel 1 1 4 5              ;# number of nodes in each cluster 
AddrParams set nodes_num_ $eilastlevel ;# of each domain

#Cluster 0 have W(0), Cluster 1 have W(1), Cluster 2 have 4 nodes, namely 
# BS(0) node_(0),1,2,3 and cluster 3 will have BS(1),node_(4),5,6

set tracefd  [open wandw.tr w]
set namtrace [open wandw.nam w]
$ns_ trace-all $tracefd
$ns_ namtrace-all-wireless $namtrace $opt(x) $opt(y)

# Create topography object
set topo   [new Topography]

# define topology
$topo load_flatgrid $opt(x) $opt(y)

# create God
create-god [expr $opt(nn) + $num_bs_nodes]
# 9 wireless nodes, GOD object will take care.

#create wired nodes
set temp {0.0.0 0.1.0}        ;# hierarchical addresses for wired domain
for {set i 0} {$i < $num_wired_nodes} {incr i} {
    set W($i) [$ns_ node [lindex $temp $i]] 
}

# configure for base-station node
$ns_ node-config -adhocRouting $opt(adhocRouting) \
                 -llType $opt(ll) \
                 -macType $opt(mac) \
                 -ifqType $opt(ifq) \
                 -ifqLen $opt(ifqlen) \
                 -antType $opt(ant) \
                 -propType $opt(prop) \
                 -phyType $opt(netif) \
                 -channelType $opt(chan) \
		 -topoInstance $topo \
                 -wiredRouting ON \
		 -agentTrace ON \
                 -routerTrace OFF \
                 -macTrace OFF 

#create base-station node
set temp {1.0.0 1.0.1 1.0.2 1.0.3 1.0.4 1.1.0 1.1.1 1.1.2 1.1.3 }   ;# hier address to be used for wireless
                                     ;# domain
set BS(0) [$ns_ node 1.0.0]
$BS(0) random-motion 0               ;# disable random motion

set BS(1) [$ns_ node 1.1.0]
$BS(1) random-motion 0

#provide some co-ord (fixed) to base station node
$BS(0) set X_ 200.0
$BS(0) set Y_ 200.0
$BS(0) set Z_ 0.0

$BS(1) set X_ 250.0
$BS(1) set Y_ 250.0
$BS(1) set Z_ 0.0

# create mobilenodes in the same domain as BS(0)  
# note the position and movement of mobilenodes is as defined
# in $opt(sc)

#configure for mobilenodes
$ns_ node-config -wiredRouting OFF
# attaching the mobile nodes to Base Station 0
set node_(0) [$ns_ node 1.0.1]
$node_(0) base-station [AddrParams addr2id [$BS(0) node-addr]]
set node_(1) [$ns_ node 1.0.2]
$node_(1) base-station [AddrParams addr2id [$BS(0) node-addr]]
set node_(2) [$ns_ node 1.0.3]
$node_(2) base-station [AddrParams addr2id [$BS(0) node-addr]]
set node_(3) [$ns_ node 1.0.4]
$node_(3) base-station [AddrParams addr2id [$BS(0) node-addr]]
#attaching mobile nodes to Base station 1
set node_(4) [$ns_ node 1.1.1]
$node_(4) base-station [AddrParams addr2id [$BS(1) node-addr]]
set node_(5) [$ns_ node 1.1.2]
$node_(5) base-station [AddrParams addr2id [$BS(1) node-addr]]
set node_(6) [$ns_ node 1.1.3]
$node_(6) base-station [AddrParams addr2id [$BS(1) node-addr]]

for {set j 0} {$j < 7} {incr j} {
#    set node_($j) [ $ns_ node [lindex $temp [expr $j+1]] ]
    $ns_ initial_node_pos $node_($j) 20
}

#create links between wired and BS nodes

$ns_ duplex-link $W(0) $W(1) 5Mb 2ms DropTail
$ns_ duplex-link $W(1) $BS(0) 5Mb 2ms DropTail
$ns_ duplex-link $W(1) $BS(1) 5Mb 2ms DropTail

$ns_ duplex-link-op $W(0) $W(1) orient down
$ns_ duplex-link-op $W(1) $BS(0) orient left-down
$ns_ duplex-link-op $W(1) $BS(1) orient down

# setup TCP connections
set tcp1 [new Agent/TCP]
$tcp1 set class_ 2
set sink1 [new Agent/TCPSink]
$ns_ attach-agent $node_(0) $tcp1
$ns_ attach-agent $W(0) $sink1
$ns_ connect $tcp1 $sink1
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ns_ at $opt(ftp1-start) "$ftp1 start"

set tcp2 [new Agent/TCP]
$tcp2 set class_ 2
set sink2 [new Agent/TCPSink]
$ns_ attach-agent $W(1) $tcp2
$ns_ attach-agent $node_(2) $sink2
$ns_ connect $tcp2 $sink2
set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2
$ns_ at $opt(ftp2-start) "$ftp2 start"


# source connection-pattern and node-movement scripts
if { $opt(cp) == "" } {
	puts "*** NOTE: no connection pattern specified."
        set opt(cp) "none"
} else {
	puts "Loading connection pattern..."
	source $opt(cp)
}
if { $opt(sc) == "" } {
	puts "*** NOTE: no scenario file specified."
        set opt(sc) "none"
} else {
	puts "Loading scenario file..."
	source $opt(sc)
	puts "Load complete..."
}

for {set j 0} {$j <$opt(nn)} {incr j} {
 $ns_ at $opt(stop).0 "$node_($j) reset";
}


# Tell all nodes when the simulation ends


$ns_ at $opt(stop).0 "$BS(0) reset";
$ns_ at $opt(stop).0 "$BS(1) reset";

$ns_ at $opt(stop).0002 "puts \"NS EXITING...\" ; $ns_ halt"
$ns_ at $opt(stop).0001 "stop"
proc stop {} {
    global ns_ tracefd namtrace
#    $ns_ flush-trace
    close $tracefd
    close $namtrace
}

puts "Starting Simulation..."
$ns_ run

