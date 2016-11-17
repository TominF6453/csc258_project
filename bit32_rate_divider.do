vlib work
vlog -timescale 1ns/1ns bit32_rate_divider.v
vsim bit32_rate_divider

log {/*}
add wave {/*}

force {cycle_amt} 0000_0000_0000_0000_0000_0000_0000_0010
force {clock} 0 0, 1 1 -r 2

run 100ns