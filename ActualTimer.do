vlib work
vlog -timescale 1ns/1ns ActualTimer.v
vsim ActualTimer

log {/*}
add wave {/*}

force {SW[9]} 1
force {SW[0]} 1

force {CLOCK_50} 0 0, 1 1 -r 2

run 100ns
