vlib work
vlog -timescale 1ns/1ns six_counter.v
vsim six_counter

log {/*}
add wave {/*}

force {enable} 1
force {in_pulse} 0 0, 1 1 -r 2

run 100ns