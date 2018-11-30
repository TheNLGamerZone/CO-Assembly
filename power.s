.text
string:	.asciz "%s, %s, %s\n"
name: 	.asciz "Tim/Eyup"
id:	.asciz "4953940/4929578"
assignment:
	.asciz "Assignment 2"
input: 	.asciz "%ld"
output:	.asciz "Result: %d\n"
base_input:
	.asciz "Base: "
exp_input:
	.asciz "Exponent: "

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

	## Getting pow() input
	call inout				# Call inout() to request 'base' and 'exp'
	
	movq %r15, %rdi				# Move 'base' from inout() to RDI
						# Set first pow() arg
	movq %rax, %rsi				# Move 'exp' from inout() to RSI
						# Set second pow() arg
	call pow				# Call pow(base, exp)

	## Printing pow() result
	movq $output, %rdi			# Set first printf() arg
	movq %rax, %rsi				# Set second printf() arg: result from pow()
	movq $0, %rax				# No vector arguments
	call printf
	
	## End program
	movq $0, %rdi				# Set exit code to 0
	call exit				# Call exit(0)

#
# * Subroutine: inout
# * Description: Asks user for two input values: base and exp
#
inout:
	pushq %rbp				# Prologue: Push base pointer on stack
	movq %rsp, %rbp				# Copy stack pointer to RBP

	## Getting 'base' input
	movq $base_input, %rdi			# Set first prinft() arg
	movq $0, %rax				# No vector args
	call printf				# Call printf(base_input)

	subq $8, %rsp				# Reserve stack space for local temp var 'base'
	leaq -8(%rbp), %rsi			# Load address of stack var in rsi
						# Set second scanf() argument
	movq $input, %rdi			# Set first scanf() argument
	movq $0, %rax				# No vector arguments
	call scanf				# Call scanf(input, &base)

	mov -8(%rbp), %r15			# Save local var 'base' in R15, in order to return it
	
	## Getting 'exp' input
	movq $exp_input, %rdi			# Set first printf() arg
	movq $0, %rax				# No vector args
	call printf				# Call printf(exp_input)

	leaq -8(%rbp), %rsi			# Reuse reserved stack space for local temp var 'exp'
	movq $input, %rdi			# Set second scanf() argument
	movq $0, %rax				# No vector args
	call scanf 				# Call scanf(input, &exp)
	
	movq -8(%rbp), %rax			# Save local var 'exp' in RAX, in order to return it
	
  	## End function
	movq %rbp, %rsp				# Epilogue: Clear local vars from stack
	popq %rbp				# Restore caller's base pointer
	ret					# Return from subroutine

#
# * Subroutine: pow
# * Description: The pow subroutine calculates powers of non-negative bases
# *		 and components.
# * Arguments:	base - the exponential base
# *		exp - the exponent
#
pow:
	pushq %rbp				# Prologue: Push BP on stack
	movq %rsp, %rbp				# Copy SP to BP
	
	## Init vars
	movq $1, %rax				# Initialize 'total' var with 1
	movq %rdi, %r8				# Set R8 to 'base'
	movq %rsi, %r9				# Initialize 'i' var with 'exp'
	
	## Adding values
   forloop:					# Set loop label
	cmpq $0, %r9
	jle end
	#mulq %r8				# Multiply 'total' with 'base'	
	imul %r8, %rax
	decq %r9				# Decrease 'i' by one
	jnz forloop				# If 'i' is 0 continue (end loop), else run loop again

   end:
	## End function
	movq %rbp, %rsp				# Epilogue: Clear local vars from stack
	popq %rbp 				# Restore caller's base pointer
	ret					# Return from subroutine
