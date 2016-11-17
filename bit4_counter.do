vlib work
vlog -timescale 1ns/1ns bit4_counter.v
vsim bit4_counter

log {/*}
add wave {/*}

force {start} 1010
force {enable} 1
force {in_pulse} 0 0, 1 1 -r 2

run 100ns