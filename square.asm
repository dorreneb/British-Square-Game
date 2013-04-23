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
	.asciiz	"|*"
# Proper amount of whitespace for top half of empty cells
cell_blank:
	.asciiz "   "
# For filled cell rows marked by player 1
x_fill_row:
	.asciiz "XXX"
# For filled cell rows marked by player 2
o_fill_row:
	.asciiz "OOO"

#
# CONSTANTS
#

# tells syscall what to do
WRITE_STRING = 4
EXIT_PROGRAM = 10

#
# CODE
#
	.text
	.align	2
	j	main			# Start program main method

#
# Prints out a string, the pointer to which is saved in $a0.
# Arguments:	$a0:	A pointer to the string that should be printed.
#
print_string:
	li	$v0, WRITE_STRING	# Tells system to write
	syscall				# Writes string
	jr	$ra			# Return

#
# Prints board in accordance to the spec located at
# http://www.cs.rit.edu/~vcss345/project/123/proj123.html
#

print_board:
	addi	$sp, $sp, -4		# Make room on stack to save ra
	sw	$ra, 0($sp)		# Save return location

	la	$a0, board_border	# Print top border row
	jal	print_string


	la	$a0, board_border	# Print bottom border row
	jal	print_string

	lw	$ra, 0($sp)		# Restore return location
	addi	$sp, $sp, 4		# Restore stack
	jr	$ra			# Return

#
# Main method. Runs program.
#
main:
	la	$a0, intro_string	# Loads and prints intro string
	jal	print_string

	jal	print_board		# Print the board

exit_program:
	li	$v0, EXIT_PROGRAM	# Tells program to exit
	syscall				# Exit program
