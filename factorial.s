.text
string:	.asciz "%s, %s, %s\n"
name: 	.asciz "Tim/Eyup"
id:	.asciz "4953940/4929578"
assignment:
	.asciz "Assignment 3"
input: 	.asciz "%ld"
output:	.asciz "Result: %d\n"
factorial_input:
	.asciz "Input for n!: "

.global main
#
# * Subroutine: main
# * Description: application entry point
#
main: 
	movq %rsp, %rbp				# Prologue: Set base pointer

	## Printing string
	movq $string, %rdi			# Set first printf() argument
	movq $name, %rsi			# Set second printf() argument
	movq $id, %rdx				# Set third printf() argument
	movq $assignment, %rcx			# Set fourth printf() argument
	movq $0, %rax				# No vector arguments
	call printf				# Call printf(string, name, id, assignment)

	## Getting factorial() input
	call inout				# Call inout() to request 'n'
	
	movq %rax, %rdi				# Move 'n' from inout() to RDI
						# Set second factorial() arg
	call factorial				# Call factorial(n)

	## Printing factorial() result
	movq $output, %rdi			# Set first printf() arg
	movq %rax, %rsi				# Set second printf() arg: result from pow()
	movq $0, %rax				# No vector arguments
	call printf
	
	## End program
	movq $0, %rdi				# Set exit code to 0
	call exit				# Call exit(0)

#
# * Subroutine: inout
# * Description: Asks user for one input value: n
#
inout:
	pushq %rbp				# Prologue: Push base pointer on stack
	movq %rsp, %rbp				# Copy stack pointer to RBP

	## Getting 'n' input
	movq $factorial_input, %rdi		# Set first prinft() arg
	movq $0, %rax				# No vector args
	call printf				# Call printf(factorial_input)

	subq $8, %rsp				# Reserve stack space for local temp var 'n'
	leaq -8(%rbp), %rsi			# Load address of stack var in rsi
						# Set second scanf() argument
	movq $input, %rdi			# Set first scanf() argument
	movq $0, %rax				# No vector arguments
	call scanf				# Call scanf(input, &n)

	mov -8(%rbp), %rax			# Save local var 'base' in RAX, in order to return it
		
  	## End function
	movq %rbp, %rsp				# Epilogue: Clear local vars from stack
	popq %rbp				# Restore caller's base pointer
	ret					# Return from subroutine

#
# * Subroutine: factorial
# * Description: The pow subroutine calculates the factorial of the given number 'n'.
# * Arguments:	n - the number
#
factorial:
	pushq %rbp				# Prologue: Push RBP on stack
	movq %rsp, %rbp				# Copy SP to BP
	
	## Check start value
	cmpq $1, %rdi				# Compare 1 to RDI (='n')
	jg recursive				# Jump to 'recursive' if n > 1

	movq $1, %rax				# Set return value to 1
	jmp finish				# Jump to finish

	## Recursive code 
   recursive:
	pushq %rdi				# Save 'n' on stack

	subq $1, %rdi				# Subtract 1 from n (n = n - 1)
	call factorial				# Call factorial(n - 1)
	
	popq %rdi				# Get original 'n' from stack
	mulq %rdi				# Multiply 'n' by result from factorial(n - 1)
	
	## End function
   finish:
       	movq %rbp, %rsp				# Epilogue: Clear local vars from stack
	popq %rbp				# Restore caller's base pointer
	ret					# Return from subroutine
	
