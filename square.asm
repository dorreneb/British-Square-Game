#
# DATA
#
	.data
	.align	0

# The header for the square program
intro_string:
	.ascii  "\n****************************\n"
	.ascii	  "**     British Square     **\n"
	.asciiz   "****************************\n\n"

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
# Main method. Runs program.
#
main:
	la	$a0, intro_string
	jal	print_string

exit_program:
	li	$v0, EXIT_PROGRAM	# Tells program to exit
	syscall				# Exit program
