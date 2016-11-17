vlib work
vlog -timescale 1ns/1ns AbstractConventionalTimer.v
vsim AbstractConventionalTimer

log {/*}
add wave {/*}

force {enable} 1
force {clock} 0 0, 1 1 -r 2

run 100ns