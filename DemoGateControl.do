vlib work
vlog -timescale 1ns/1ns DemoGateControl.v
vsim DemoGateControl

log {/*}
add wave {/*}

force {CLOCK_50} 1 0, 0 1 -r 2

# Nothing should change as the game hasn't "started"
run 10ns

# Start the game on XOR
force {KEY[3]} 1 0, 0 2
run 10ns

# Start alternating the inputs to 10, 11, 01, 00, switching every 2ns
force {KEY[1]} 1 0, 0 4 -r 8
force {KEY[0]} 1 2, 0 6 -r 8
run 16ns

# Move the selection to XOR (8)
force {KEY[2]} 1 0, 0 1
run 2ns
force {KEY[2]} 1 0, 0 1
run 2ns
force {KEY[2]} 1 0, 0 1
run 2ns
force {KEY[2]} 1 0, 0 1
run 2ns

# Confirm XOR
force {KEY[3]} 1 0, 0 1
run 2ns

# Continue running to see what the next gate is
run 20ns
