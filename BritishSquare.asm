#
# DATA
#
	.data
	.align	0

#
# PLAY INFO
#

board:							# 25-element integer array that keeps track of stone placement
	.space 100					# -1 = clear, 0 = X claim, 1 = O claim

#
# STRINGS
#

intro_string:						# The header for the square program
	.ascii  "\n****************************\n"
	.ascii	  "**     British Square     **\n"
	.asciiz   "****************************\n\n"
board_border:						# The first and last row of the board
	.asciiz	"***********************\n"
row_border:						# Delineates tops and bottoms of cells
	.asciiz	"*+---+---+---+---+---+*\n"
cell_start:						# The left edge of the board
	.asciiz "*|"
cell_seperator:					# Seperates east and west cells
	.asciiz	"|"
cell_end:						# Right edge of the board
	.asciiz	"*\n"
cell_blank:						# Proper amount of whitespace for top half of empty cells
	.asciiz "   "
cell_blank_singledigit:				# Proper amount of whitespace for bottom half of empty cells (n < 10)
	.asciiz "  "
cell_blank_doubledigit:				# Proper amount of whitespace for bottom half of empty cells (n > 9)
	.asciiz " "
x_fill_row:						# For filled cell rows marked by player 1
	.asciiz "XXX"
o_fill_row:						# For filled cell rows marked by player 2
	.asciiz "OOO"
newline:						# Newline
	.asciiz "\n"
x_prompt_start:					# The start of the input prompt when it's X's turn
	.asciiz "Player X"
o_prompt_start:					# The start of the input prompt when it's O's turn
	.asciiz "Player O"
prompt_text_remainder:				# The remainder of the input prompt
	.asciiz " enter a move (-2 to quit, -1 to skip move): "
invalid_location_text:				# Location makes no sense
	.asciiz "Illegal location, try again\n\n"
occupied_location_text:				# Location is occupied
	.asciiz "Illegal move, square is occupied\n\n"
x_quit:						# Player X quit
	.asciiz "Player X quit the game.\n"
o_quit:						# Player O quit
	.asciiz "Player O quit the game.\n"
game_totals:						# Game totals title
	.asciiz "Game Totals\n"
x_total:						# Label for x's score
	.asciiz "X's total="
o_total:						# Label for o's score
	.asciiz " O's total="
blocked_square:					# If a player cant place a stone print this
	.asciiz "Illegal move, square is blocked\n\n"
o_no_more_text:					# O has no more moves to make
	.asciiz "Player O has no legal moves, turn skipped.\n\n"
x_no_more_text:					# X has no more moves to make
	.asciiz "Player X has no legal moves, turn skipped.\n\n"
no_middle_first_text:				# Alert that you can't play on square 12 on the first turn
	.asciiz "Illegal move, can't place first stone of game in middle square\n\n"
player_x_won:						# Banner that says that x won
	.ascii "************************\n"
	.ascii "**   Player X wins!   **\n"
	.asciiz "************************\n"
player_o_won:						# Banner that says that o won
	.ascii "************************\n"
	.ascii "**   Player O wins!   **\n"
	.asciiz "************************\n"
game_tied:						# Banner that said the game is a tie
	.ascii "************************\n"
	.ascii "**   Game is a tie    **\n"
	.asciiz "************************\n"
#
# CONSTANTS
#

# tells syscall what to do
WRITE_STRING = 4
READ_INT = 5
WRITE_INT = 1
EXIT_PROGRAM = 10

# board info
NUM_ROWS = 5
CELLS_PER_ROW = 5

#
# CODE
#
	.text
	.align	2
	j	main					# Start program main method

#
# Prints out a string, the pointer to which is saved in $a0.
# Arguments:
# 	$a0:	A pointer to the string that should be printed.
#
print_string:
	li	$v0, WRITE_STRING			# Tells system to write
	syscall					# Writes string
	jr	$ra					# Return

#
# Prints out a string, the pointer to which is saved in $a0.
# Arguments:
# 	$a0:	A pointer to the integer that should be printed.
#
print_int:
	li	$v0, WRITE_INT			# Tells system to write
	syscall					# Writes string
	jr	$ra					# Return

#
# Prints board in accordance to the spec located at
# http://www.cs.rit.edu/~vcss345/project/123/proj123.html
#
# Variables Used:
#	$t0	Row counter
#	$t1	Row total comparator. Always equal to NUM_ROWS.
#	$t2	Used to count index into row
#	$t3	Row index comparator. Always equal to CELLS_PER_ROW.
#	$t4	Used to store '9' so we know whether to print single digit or double digit whitespace 
#	$t5	Used to store what cell we are currently printing
#	$t6	Location in array to see board data
#

print_board:
	addi	$sp, $sp, -4				# Make room on stack to save ra
	sw	$ra, 0($sp)				# Save return location

	add	$t0, $0, $0				# Initialize row index counter
	addi	$t1, $0, NUM_ROWS			# Save number of rows to print
	addi	$t3, $0, CELLS_PER_ROW		# Save number of cells per row
	addi	$t4, $0, 9				# Used to see if we should print one space or two spaces in row
	la	$t6, board				# Load board into a register

	la	$a0, board_border			# Print top table row
	jal	print_string
	la	$a0, row_border			# Print first row border
	jal	print_string

print_all_cells:
	beq	$t0, $t1, bprint_done		# If NUM_ROWS rows are printed stop

print_row_top:					# Print each row
	add	$t2, $0, $0				# Initialize row counter
	la	$a0, cell_start			# Print row start
	jal	print_string

print_cell_top:
	beq	$t2, $t3, print_row_top_end		# If CELLS_PER_ROW is met finish row
	
	lw	$a0, 0($t6)				# Get contents of board array
	blt	$a0, $0, print_top_whitespace
	beq	$a0, $0, print_top_x
	bgt	$a0, $0, print_top_o

print_top_whitespace:
	la	$a0, cell_blank			# Print whitespace
	j	print_top_cell_content
	
print_top_x:
	la	$a0, x_fill_row			# Print "XXX"
	j	print_top_cell_content

print_top_o:
	la	$a0, o_fill_row			# Print "OOO"
	j	print_top_cell_content

print_top_cell_content:
	jal	print_string

	la	$a0, cell_seperator			# Print cell seperator
	jal	print_string

	addi	$t2, $t2, 1				# Increment cells in row printed
	addi	$t6, $t6, 4				# Increment index of board array
	j	print_cell_top			# Print another cell

print_row_top_end:
	la	$a0, cell_end				# Print row end + newline
	jal	print_string
	add	$t2, $0, $0				# Initialize row counter for the bottom half of the rows
	add	$t6, $t6, -20				# Roll back index by 5 to get bottom half of cells printed right

print_row_bottom:					
	la	$a0, cell_start			# Print row start
	jal	print_string

print_cell_bottom:
	beq	$t2, $t3, print_row_bottom_end	# If CELLS_PER_ROW is met finish row
	lw	$a0, 0($t6)				# Get the contents of the cell's index to examine
	beq	$a0, $0, print_bottom_x		# If contents = 0, print xs
	bgt	$a0, $0, print_bottom_o		# If contents = 1, print os

	mul	$a0, $t0, $t3				# Cell identifier = ([Completed Rows]*[Cells/row])+[Current row cell]
	add	$a0, $a0, $t2	
	jal	print_int				# Print cell

	bgt	$a0, $t4, load_doubledigit_space	# If n > 9, print one space, otherwise print two spaces

load_singledigit_space:
	la	$a0, cell_blank_singledigit		# Print top table row
	j	continue_printing_cell

load_doubledigit_space:
	la	$a0, cell_blank_doubledigit		# Print top table row
	j	continue_printing_cell

print_bottom_x:
	la	$a0, x_fill_row			# Print "XXX"
	j	continue_printing_cell

print_bottom_o:
	la	$a0, o_fill_row			# Print "OOO"

continue_printing_cell:
	jal	print_string				# Print label whitespace
	la	$a0, cell_seperator			# Print cell seperator
	jal	print_string

	addi	$t2, $t2, 1				# Increment cells in row printed
	addi	$t6, $t6, 4				# Increment index in array
	j	print_cell_bottom			# Print another cell


print_row_bottom_end:
	la	$a0, cell_end				# Print row end + newline
	jal	print_string
	la	$a0, row_border			# Print row delinator
	jal	print_string
	addi	$t0, $t0, 1				# Increment number of rows printed
	j	print_all_cells			# Loop back to top

bprint_done:
	la	$a0, board_border			# Print bottom border row
	jal	print_string

	lw	$ra, 0($sp)				# Restore return location
	addi	$sp, $sp, 4				# Restore stack
	jr	$ra					# Return
	
#
# Prints the prompt that gets what the user wants to do
#
# Arguments:
#	$a0	The player turn indicator (0 = X, 1 = 0)
#
print_prompt:
	addi	$sp, $sp, -8				# Make room for $a0 on stack
	sw	$a0, 0($sp)				# Save a0 and ra
	sw	$ra, 4($sp)
	bgtz	$a0, prompt_o				# if a0 is 1 it's o's turn 		

prompt_x:
	la	$a0, x_prompt_start		
	j	prompt_remainder			# Exit function

prompt_o:
	la	$a0, o_prompt_start

prompt_remainder:
	jal	print_string
	la	$a0, prompt_text_remainder
	jal	print_string
	la	$a0, newline
	jal	print_string

print_prompt_done:
	lw	$ra, 4($sp)				# Restore a0 and ra
	lw	$a0, 0($sp)
	addi	$sp, $sp, 8				# Restore stack
	jr	$ra					# Return

#
# Main method. Runs program.
#
# Variables Used:
#	$s0	12 - cannot be chosen the first time
#	$s1	Saves if its the first turn or not
#	$s2	Turn counter (0 = X, 1 = 0)
#	$s3	Used to flip turn counter
#	$s4	If input equals this, skip turn
#	$s5	If input equals this, quit
#	$s6	The address of the cell being affected by the current turn
#	$s7	The max number of cells (NUM_ROWS * CELLS_PER_ROW)
#
# Temporary Variables (don't care about these, SUPER temporary, documented for reference):
#	$t0	Loop index when initializing board array
#	$t1	Board address when initializing board array
#	$t2	Default value for board initialization (-1)
#	$t3	Stores location in array to store player turn input
#	$t4	Used to calculate array locs
#	$t5	Used as temp storage for things loaded from arrays
#	$t6	Temp storage for player scores
#
main:
	addi	$s0, $0, 12
	add	$s1, $0, $0
	add	$s2, $0, $0
	addi	$s3, $0, 1
	addi	$s4, $0, -1
	addi	$s5, $0, -2

	la	$t0, NUM_ROWS				# Get total number of cells in $s7
	la	$t1, CELLS_PER_ROW
	mul	$s7, $t0, $t1

	add	$t0, $0, $0				# Index counter for initializing board
	la	$t1, board				# The board
	addi	$t2, $0, -1				# Default number for board -> -1 = unclaimed spot

initialize_board:
	beq	$t0, $s7, intro			# If the array is fully initialized, play game
	sw	$t2, 0($t1)				# Put -1 in index in array
	addi	$t0, $t0, 1				# Increment array
	addi	$t1, $t1, 4				# Go to next index in array
	j	initialize_board			# Initialize next index in array

intro:
	la	$a0, intro_string			# Loads and prints intro string
	jal	print_string
	jal	print_board				# Print initial board
	la	$a0, newline				# Print a separating newline
	jal	print_string

play:
	add	$v1, $0, $0				# Check if both players are capable of moving
	jal	turn_to_take
	bgt	$v1, $0, game_done			# If both players are blocked then quit

	add	$v1, $0, $0				# Set default value to 0
	jal	check_player_remaining_moves	# Check if the player can actually move
	bne	$v1, $0, no_more_moves		# If the player is out of turns, skip

	add	$a0, $0, $s2				# Print prompt for user turn
	jal	print_prompt

	li	$v0, READ_INT				# Tells system to get user input
	syscall					# Reads int into v0

	bne	$s1, $0, validations_on_all_turns	# If it's not the first turn, don't check for first input being 12
	beq	$v0, $s0, not_middle_first		# Can't play in the middle square on the first turn
		
validations_on_all_turns:
	beq	$v0, $s4, turn_over			# If input == -1 skip turn
	beq	$v0, $s5, exit_program		# If input == -2 quit
	bge	$v0, $s7, illegal_loc		# If input > the max square, skip turn
	blt	$v0, $s5, illegal_loc		# If input < quit, it's invalid, skip turn
	move	$a0, $v0				# Check for board validity -> input must be moved to a0
	jal	check_valid_move			# Check valid move
	bne	$v1, $0, blocked
		
	
	la	$t3, board				# Get index of square to place
	addi 	$t4, $0, 4				# Multiplier to get to proper array index
	mul	$t4, $t4, $v0				# Get relative location of index
	add	$t3, $t3, $t4				# $t3 now has location in array to put things
	lw	$t5, 0($t3)				# Check if a player has put something in the cell specified
	bge	$t5, $0, illegal_move		# If $t5 > 0, do not persist input
	sw	$s2, 0($t3)				# Put player turn into the array
	j	turn_over				# Complete turn

blocked:
	la	$a0, blocked_square
	jal	print_string
	j 	play

no_more_moves:
	bne	$s2, $0, no_more_o
	la	$a0, x_no_more_text
	j	no_more_print
no_more_o:
	la	$a0, o_no_more_text
no_more_print:
	jal	print_string
	xor	$s2, $s2, $s3				# Change player turn by xoring player index with 1
	j	play	

not_middle_first:
	la	$a0, no_middle_first_text
	jal	print_string
	j	play

illegal_loc:
	la	$a0, invalid_location_text		# Tell user their choice isn't on the board
	jal 	print_string
	j	play

illegal_move:
	la	$a0, occupied_location_text		# Tell user their square has already been taken
	jal	print_string
	j 	play

turn_over:
	jal	print_board				# Print current board state
	addi	$s0, $s0, 1	
	la	$a0, newline				# Print a separating newline
	jal	print_string	

	ori	$s1, $s1, 1				# Mark that the first turn has occurred

	xor	$s2, $s2, $s3				# Change player turn by xoring player index with 1
	j play						# Take next turn

#
# Checks if both players are able to move.
#
# Returns:
# 	$v1	0 if either player is good to go, false otherwise
#
turn_to_take:
	addi	$sp, $sp, -12
	sw	$ra, 0($sp)
	sw	$a0, 4($sp)
	sw	$t0, 8($sp)

	add	$a0, $0, $0				# Check first player's move state
	jal	check_player_remaining_moves	
	move	$t0, $v1				# Store result in t1
	addi	$a0, $0, 1				# Check second player's move state
	jal	check_player_remaining_moves
	add	$t0, $t0, $v1				# If both results are 0, then we're good to go
	
	and	$t0, $t0, $v1				# If there are two false returns from 
	addi	$v1, $0, 1				# Set default failure state
	beq	$t0, $0, turn_to_take_true
	j	turn_to_take_finish

turn_to_take_true:
	add	$v1, $0, $0

turn_to_take_finish:
	lw	$ra, 0($sp)
	lw	$a0, 4($sp)
	lw	$t0, 8($sp)
	addi	$sp, $sp, 12
	jr	$ra


#
# Checks to see if a specific player has the ability to move
# 
# Returns:
#	$v1	0 if player has remaining moves, 1 if player does not
#
check_player_remaining_moves:
	addi	$sp, $sp, -12
	sw	$ra, 0($sp)
	sw	$a0, 4($sp)
	sw	$v1, 8($sp)

	addi	$v1, $0, 1				# Set default of "doesn't have moves"
	add	$a0, $0, $0				# For loop counter/cell to check
	addi	$t0, $0, 24				# Number of cells
	la	$t1, board				# Board (to check if cell is blank)

check_player_remaining_loop:
	bgt	$a0, $t0, check_player_finish	# If index > 24 we've scanned the entire board

	lw	$t2, 0($t1)				# Load contents of cell
	bge	$t2, $0, check_loop_increment	# If the cell is occupied, skip
	j	player_has_moves
	# j	check_valid_move			Checks validity of movement	
	# beq	$v1, $0, player_has_moves		If there is a valid move, we're good! Set to valid and return

check_loop_increment:
	addi	$a0, $a0, 1				# Increment loop counter
	addi	$t1, $t1, 4				# Increment cell pointer
	j	check_player_remaining_loop

player_has_moves:
	add	$v1, $0, $0				# Set return variable to 'yes, has remaining moves'

check_player_finish:
	lw	$v1, 8($sp)				# Restore stack and return
	lw	$a0, 4($sp)	
	lw	$ra, 0($sp)				
	addi	$sp, $sp, 12
	jr	$ra

#
# Checks if a square can be claimed by a player
#
# Arguments:
#	$a0	The player turn indicator (0 = X, 1 = 0)
#
# Variables:
#	$t0	The board pointer
#	$t1	Used to calculate offsets and to check square locations
#	$t2	Stores the opponents id and is used to calculate offsets
#	$t3	Stores contents of a cell at a cell being checked
#	$t4	Used to make sure a cell being checked actually exists
#
# Returns:
#	$v1	0 if true, 1 if false
#
check_valid_move:
	la	$t0, board				# Load the stack into a register
	addi	$t1, $0, 4				# Get offset to square
	mul	$t1, $t1, $a0
	add	$t0, $t0, $t1				# $t0 now has data for the given cell in a

	add	$t2, $0, $s2				# Get current player's turn (see main vars)
	xor	$t2, $t2, $s3				# Change player by xoring player index with 1

	move	$v1, $0				# Set default return to "winning" 
	

check_square_north:
	addi	$t1, $a0, -5				# Get square north (n-5)
	blt	$t1, $0, check_square_south		# If n - 5 < 0, go to next check

	addi	$t3, $0, 4				# Calculate relative location from board square
	mul	$t3, $t3, -5
	add	$t3, $t3, $t0				# Get location of square to check
	lw	$t3, 0($t3)				# $t2 now has contents of its location	
	
	beq	$t3, $t2, check_invalid		# If the board says that the opponent marked the square its invalid
	 

check_square_south:
	addi	$t4, $0, 24				# Max square value
	addi	$t1, $a0, 5				# Get square north (n+5)
	bgt	$t1, $t4, check_square_east		# If n + 5 < 0, go to next check

	addi	$t3, $0, 4				# Calculate relative location from board square
	mul	$t3, $t3, 5
	add	$t3, $t3, $t0				# Get location of square to check
	lw	$t3, 0($t3)				# $t2 now has contents of its location	
	
	beq	$t3, $t2, check_invalid		# If the board says that the opponent marked the square its invalid

check_square_east:
	addi	$t4, $0, 5				# Divide $a0 by 5 to get the remainder in $HI
	div	$a0, $t4					
	mflo	$t4					# Get the remainder into $t4
	addi	$t4, $t4, -4				# Check if the remainder is 4, if so, its on the east edge - move on
	beq	$t4, $0, check_square_west

	lw	$t3, 4($t0)				# Get the next square
	beq	$t3, $t2, check_invalid		# If the board says that the opponent marked the square its invalid

check_square_west:
	addi	$t4, $0, 5				# Divide $a0 by 5 to get the remainder in $HI
	div	$a0, $t4					
	mflo	$t4					# Get the remainder into $t4
	beq	$t4, $0, check_valid_move_end	# If no remainder then it's on the west end and we shouldn't check

	lw	$t3, -4($t0)				# Get the next square
	beq	$t3, $t2, check_invalid		# If the board says that the opponent marked the square its invalid
	j	check_valid_move_end

check_invalid:
	addi	$v1, $0, 1				# Set the return value to invalid
	j	check_valid_move_end

check_valid_move_end:
	jr	$ra

#
# Called when neither player can move.
#
game_done:
	jal	print_scores				# Print scores and return winner
	blt	$v1, $0, game_tie			# If $v1 < 0 then it was a tie
	beq	$v1, $0, game_x_won			# If $v1 == 0 then it was x's game
	la	$a0, player_o_won			# Otherwise o won
	j 	game_done_print

game_x_won:
	la	$a0, player_x_won
	j 	game_done_print

game_tie:
	la	$a0, game_tied

game_done_print:
	j	exit_process_call
	

#
# Exits the program in after printing out game totals.
#
exit_program:	
	jal 	print_scores				# Print out game totals
	bgt	$s2, $0, say_o_quit			# print out who actually quit the game
	la	$a0, x_quit	
	j exit_process_call
say_o_quit:
	la	$a0, o_quit

exit_process_call:
	jal print_string
	li	$v0, EXIT_PROGRAM			# Tells program to exit
	syscall					# Exit program

#
# Prints scores that have been tracked over the course of the game
#
# Returns:
#	$v1	Who won (0 for X, 1 for 0)
#
print_scores:
	addi	$sp, $sp, -4				# Make room for $ra on stack
	sw	$ra, 0($sp)				# Temporarily store $ra
	
	la	$t0, board				# Load board array into register	
	add	$t1, $0, $0				# Initialize index
	addi	$t2, $0, 24				# Max for loop
	add	$t3, $0, $0				# Stores X's points
	add	$t4, $0, $0				# Stores O's points

print_scores_loop:
	bgt	$t1, $t2, print_scores_loop_end	# If n > 24 we've finished the board
	lw	$t5, 0($t0)				# Get contents of cell at this point
	blt	$t5, $0, print_scores_loop_inc	# If the cell is unclaimed nobody gets points
	bgt	$t5, $0, print_score_for_o		# If contents == 1 then o had the cell
	addi	$t3, $t3, 1				# Give x the point
	j	print_scores_loop_inc		# Don't assign both x and o a point for this cell
	
print_score_for_o:
	addi	$t4, $t4, 1				# Increment o's score by 1

print_scores_loop_inc:
	addi	$t1, $t1, 1				# Increment loop index
	addi	$t0, $t0, 4				# Increment pointer index
	j print_scores_loop

print_scores_loop_end:
	la	$a0, game_totals			# Load and print game totals string
	jal	print_string
	la	$a0, x_total				# Load and print x's score
	jal	print_string
	move	$a0, $t3
	jal	print_int
	la	$a0, o_total				# Load and print o's score
	jal	print_string
	move	$a0, $t4
	jal	print_int	
	la	$a0, newline				# Load and print a newline
	jal	print_string

	addi	$v1, $0, -1				# Default value - it was a tie
	bgt	$t3, $t4, x_won			# If t3 > t4 then x won
	bgt	$t4, $t3, o_won			# If t4 > t3 then o won
	j print_scores_return

x_won:
	add	$v1, $0, $0 				# x won
	j print_scores_return

o_won:
	addi	$v1, $0, 1				# Give o the win

print_scores_return:
	lw	$ra, 0($sp)				# Restore return location
	addi	$sp, $sp, 4				# Restore stack pointer
	jr	$ra					# Return
