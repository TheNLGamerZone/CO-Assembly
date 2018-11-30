.text
string:	.asciz "%s, %s, %s\n"
name: 	.asciz "Tim"
id:	.asciz "4953940"
assignment:
	.asciz "Assignment 1"
input: 	.asciz "Input echo: "

.global main
#
# * Subroutine: main
# * Description: application entry point
#
main: 
	movq %rsp, %rbp				# Set base pointer
	movq $string, %rdi			# Set first printf() argument
	movq $name, %rsi			# Set second printf() argument
	movq $id, %rdx				# Set third printf() argument
	movq $assignment, %rcx			# Set fourth printf() argument
	movq $0, %rax				# No vector arguments
	call printf				# Call printf(string, name, id, assignment)

	movq $0, %rdi				# Set exit code to 0
	call exit				# Call exit(0)
