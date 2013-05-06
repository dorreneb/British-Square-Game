#
# DATA
#
	.data
	.align	0

#
# STRINGS
#

# The header for the square program
intro_string:
	.ascii  "\n****************************\n"
	.ascii	  "**     British Square     **\n"
	.asciiz   "****************************\n\n"
# The first and last row of the board
board_border:
	.asciiz	"***********************\n"
# Delineates tops and bottoms of cells
row_border:
	.asciiz	"*+---+---+---+---+---+*\n"
# The left edge of the board
cell_start:
	.asciiz "*|"
# Seperates east and west cells
cell_seperator:
	.asciiz	"|"
# Right edge of the board
cell_end:
	.asciiz	"*\n"
# Proper amount of whitespace for top half of empty cells
cell_blank:
	.asciiz "   "
# For filled cell rows marked by player 1
x_fill_row:
	.asciiz "XXX"
# For filled cell rows marked by player 2
o_fill_row:
	.asciiz "OOO"
# Newline
newline:
	.asciiz "\n"
# The start of the input prompt when it's X's turn
x_prompt_start:
	.asciiz "Player X"
# The start of the input prompt when it's O's turn
o_prompt_start:
	.asciiz "Player O"
# The remainder of the input prompt
prompt_text_remainder:
	.asciiz " enter a move (-2 to quit, -1 to skip move): "

#
# CONSTANTS
#

# tells syscall what to do
WRITE_STRING = 4
READ_INT = 5
EXIT_PROGRAM = 10

# board info
NUM_ROWS = 5
CELLS_PER_ROW = 5

#
# CODE
#
	.text
	.align	2
	j	main			# Start program main method

#
# Prints out a string, the pointer to which is saved in $a0.
# Arguments:
# 	$a0:	A pointer to the string that should be printed.
#
print_string:
	li	$v0, WRITE_STRING	# Tells system to write
	syscall				# Writes string
	jr	$ra			# Return

#
# Prints board in accordance to the spec located at
# http://www.cs.rit.edu/~vcss345/project/123/proj123.html
#
# Variables Used:
#	$t0	Row counter
#	$t1	Row total comparator. Always equal to NUM_ROWS.
#	$t2	Used to count index into row
#	$t3	Row index comparator. Always equal to CELLS_PER_ROW.
#

print_board:
	addi	$sp, $sp, -20				# Make room on stack to save ra
	sw	$ra, 0($sp)				# Save return location
	sw	$t0, 4($sp)				# Store register values used
	sw	$t1, 8($sp)
	sw	$t2, 12($sp)
	sw	$t3, 16($sp)

	add	$t0, $0, $0				# Initialize row index counter
	addi	$t1, $0, NUM_ROWS			# Save number of rows to print
	addi	$t3, $0, CELLS_PER_ROW		# Save number of cells per row

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
	
	la	$a0, cell_blank			# Print whitespace
	jal	print_string

	la	$a0, cell_seperator			# Print cell seperator
	jal	print_string

	addi	$t2, $t2, 1				# Increment cells in row printed
	j	print_cell_top			# Print another cell

print_row_top_end:
	la	$a0, cell_end				# Print row end + newline
	jal	print_string
	add	$t2, $0, $0				# Initialize row counter for the bottom half of the rows

print_row_bottom:					# Print each row
	la	$a0, cell_start			# Print row start
	jal	print_string

print_cell_bottom:
	beq	$t2, $t3, print_row_bottom_end	# If CELLS_PER_ROW is met finish row
	
	la	$a0, cell_blank			# Print whitespace
	jal	print_string

	la	$a0, cell_seperator			# Print cell seperator
	jal	print_string

	addi	$t2, $t2, 1				# Increment cells in row printed
	j	print_cell_bottom			# Print another cell

print_row_bottom_end:
	la	$a0, cell_end				# Print row end + newline
	jal	print_string
	la	$a0, row_border			# Print row delinator
	jal	print_string
	addi	$t0, $t0, 1				# Increment number of rows printed
	j	print_all_cells			# Loop back to top

bprint_done:
	la	$a0, board_border	# Print bottom border row
	jal	print_string

	lw	$t3, 16($sp)		# Restore registers
	lw	$t2, 12($sp)
	lw	$t1, 8($sp)
	lw	$t0, 4($sp)
	lw	$ra, 0($sp)		# Restore return location
	addi	$sp, $sp, 20		# Restore stack
	jr	$ra			# Return

#
# Prints the prompt that gets what the user wants to do
#
# Arguments:
#	$a0	The player turn indicator (0 = X, 1 = 0)
#
print_prompt:
	addi	$sp, $sp, -8		# Make room for $a0 on stack
	sw	$a0, 0($sp)		# Save a0 and ra
	sw	$ra, 4($sp)
	bgtz	$a0, prompt_o		# if a0 is 1 it's o's turn 		

prompt_x:
	la	$a0, x_prompt_start		
	j	prompt_remainder	# Exit function

prompt_o:
	la	$a0, o_prompt_start

prompt_remainder:
	jal	print_string
	la	$a0, prompt_text_remainder
	jal	print_string
	la	$a0, newline
	jal	print_string

print_prompt_done:
	lw	$ra, 4($sp)		# Restore a0 and ra
	lw	$a0, 0($sp)
	addi	$sp, $sp, 8		# Restore stack
	jr	$ra			# Return

#
# Main method. Runs program.
#
# Variables Used:
#	$t0	Counter to print 3 boards
#	$t1	Board max counter
#	$t2	Turn counter (0 = X, 1 = 0)
#	$t3	Used to flip turn counter
#	$t4	If input equals this, skip turn
#	$t5	If input equals this, quit
#
main:
	add	$t0, $0, $0
	addi	$t1, $0, 3
	add	$t2, $0, $0
	addi	$t3, $0, 1
	addi	$t4, $0, -1
	addi	$t5, $0, -2

	la	$a0, intro_string	# Loads and prints intro string
	jal	print_string

play:
	jal	print_board		# Print the board
	addi	$t0, $t0, 1
	la	$a0, newline		# Print a separating newline
	jal	print_string
	
	add	$a0, $0, $t2		# Print prompt for user turn
	jal	print_prompt

	li	$v0, READ_INT		# Tells system to get user input
	syscall				# Reads int into v0

	beq	$v0, $t4, turn_over	# If input == -1 skip turn
	beq	$v0, $t5, exit_program	# If input == -2 quit


turn_over:
	xor	$t2, $t2, $t3		# Change player turn
	j play

exit_program:
	li	$v0, EXIT_PROGRAM	# Tells program to exit
	syscall				# Exit program
