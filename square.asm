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

#
# CONSTANTS
#

# tells syscall what to do
WRITE_STRING = 4
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
	addi	$sp, $sp, -20		# Make room on stack to save ra
	sw	$ra, 0($sp)		# Save return location
	sw	$t0, 4($sp)		# Store register values used
	sw	$t1, 8($sp)
	sw	$t2, 12($sp)
	sw	$t3, 16($sp)

	add	$t0, $0, $0		# Initialize row index counter
	addi	$t1, $0, NUM_ROWS	# Save number of rows to print
	addi	$t3, $0, CELLS_PER_ROW	# Save number of cells per row

	la	$a0, board_border	# Print top table row
	jal	print_string
	la	$a0, row_border		# Print first row border
	jal	print_string

print_all_cells:
	beq	$t0, $t1, bprint_done	# If NUM_ROWS rows are printed stop

print_row:				# Print each row
	add	$t2, $0, $0		# Initialize row counter
	la	$a0, cell_start		# Print row start
	jal	print_string

print_cell:
	beq	$t2, $t3, print_row_end	# If CELLS_PER_ROW is met finish row

	la	$a0, cell_blank		# Print whitespace
	jal	print_string

	la	$a0, cell_seperator	# Print cell seperator
	jal	print_string

	addi	$t2, $t2, 1		# Increment cells in row printed
	j	print_cell		# Print another cell

print_row_end:
	la	$a0, cell_end		# Print row end + newline
	jal	print_string
	la	$a0, row_border		# Print row delinator
	jal	print_string
	addi	$t0, $t0, 1		# Increment number of rows printed
	j	print_all_cells		# Loop back to top

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
# Main method. Runs program.
#
main:
	la	$a0, intro_string	# Loads and prints intro string
	jal	print_string

	jal	print_board		# Print the board

exit_program:
	li	$v0, EXIT_PROGRAM	# Tells program to exit
	syscall				# Exit program
