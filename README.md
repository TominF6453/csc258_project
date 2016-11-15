# CSC258 Project - Timed Logic Gate Checking

## PREMISE: Educational Game
	- The player is given 2 minutes displayed on the HEX displays.
	- The player is given a logic gate randomly.
	- The player uses switches to test the inputs and outputs of the gate.
	- The player inputs a number on the keyboard corresponding to the gate.
	- 2 minutes to solve 10 gates, randomized each playthrough.

## INPUTS:
	- SW[1:0] - control inputs to test gate
	- NUMPAD[0-9] - input selection for which gate they are testing.

## OUTPUTS:
	- HEX[5:0] - timer digits
	- VGA - displays gate animations and list of possible selections
	- LED[0] - during testing, displays output of the gate

## MILESTONES:
1. Setup the HEX timer to count down correctly, setup case statements to allow us to choose which gate we wish to test. We can test this using other switches on the board to select the gate and use two buttons or switches as inputs to test the gate, an LED as the output. This will provide us with the basis for the random generation and gate selection.
2. VGA graphics. Converting the LED output to an actual animation on screen as well as displaying the different types of gates possible in boxes. These boxes will be the basis for selecting the gate in the full game, as well as helping us with creating methods to create and animate the shapes and font we need.
3. Random generation, final game touches. Setup the random generation to work with the various gates as well as making the final product more into a game by adding failure/win states.
