.bss
stack: .skip 300000

.global brainfuck

.text

format_str: .asciz "We should be executing the following code:\n%s\n"
done_str: .asciz "Done\n"

# Your brainfuck subroutine will receive one argument:
# a zero termianted string containing the code to execute.
# R15: Fake stack pointer
# R13: Brainfuck code
# R14: ] counter
# R12: [ counter 
brainfuck:
	pushq %rbp				# Push rbp
	movq %rsp, %rbp				# Set rbp
	
	#TODO: Save r10-> regs
	movq %rdi, %r13				# Save brainfuck string
	
	movq $0, %r14				# Counter ]
	movq $0, %r12				# Counter [

	movq %rdi, %rsi				# Second printf arg
	movq $format_str, %rdi			# First printf arg
	movq $0, %rax				# No vector args
	#call printf				# Call printf()
	movq $0, %rax				# IDK, but this was default

	movq $stack, %r15			# Save fake stack pointer in R9
	subq $1, %r13				# Subtract one from FSP (fake stack pointer) to compensate first addition

loop:
	addq $1, %r13				# Add one to FSP

	cmpb $0x0, (%r13)			# NULL byte
	je end					# EOF was reached
	cmpb $0x2b, (%r13)			# + byte
	je plus					# Jump to plus label
	cmpb $0x2d, (%r13)			# - byte
	je min					# Jump to min label
	cmpb $0x2e, (%r13)			# . byte
	je point				# Jump to point label
	cmpb $0x3c, (%r13)			# < byte
	je less_than				# Jump to less_than label
	cmpb $0x3e, (%r13)			# > byte
	je greater_than				# Jump to greater_than label
	cmpb $0x5b, (%r13)			# [ byte
	je start_loop				# Jump to start_loop label
	cmpb $0x5d, (%r13)			# ] byte	
	je end_loop				# Jump to end_loop label
	jmp loop				# Jump to loop labe;

loop_loop_back:
	subq $1, %r13				# Subtract one from FSP (move pointer to cell left)
	
	cmpb $0x0, (%r13)			# Check if we somehow ended up at the end of the file
	je end					# If so, jump to end

	cmpb $0x5d, (%r13)			# If we see a ] on the way back, add one to ] counter
	jne loop_loop_back_no_false		# Jump to loop_loop_back_no_false if this char is not a ]
	addq $1, %r14				# If it was, increment counter

    loop_loop_back_no_false:
	cmpb $0x5b, (%r13)			# Check if this char is [
	je loop_loop_back_check			# If so jump to loop_loop_back_check
	jmp loop_loop_back			# If not jump back to loop_loop_back

loop_loop_back_check:
	addq $1, %r12				# Add one to [ counter	
	cmpq %r12, %r14				# Check if the counters are equal
	jne loop_loop_back			# If this condition was not met this [ does not belong to our ], so we have to jump back to checking again
	jmp loop				# Jump to main loop

loop_loop_skip:
	addq $1, %r13				# Add one to FSP (move pointer to cell right)

	cmpb $0x0, (%r13)			# Check if somehow ended up at the end of the file
	je end					# If so, jump to end

	cmpb $0x5b, (%r13)			# If we see a [ on the way forward, we should also skip the next ], because that is not ours
	jne loop_loop_skip_no_false		# If it was not a [ jump to loop_loop_skip_no_false
	addq $1, %r12				# Increment [ counter

    loop_loop_skip_no_false:
	cmpb $0x5d, (%r13)			# Check if current char is ]
	je loop_loop_skip_check			# If so jump to loop_loop_skip_check
	jmp loop_loop_skip			# If not jump back to checking loop

loop_loop_skip_check:
	addq $1, %r14				# Increment ] counter
	cmpq %r12, %r14				# Check if the counters are equal
	jne loop_loop_skip			# If this condition was not met this ] does not belong to our [
	jmp loop				# Else just jump to main loop again

end:	
	movq $done_str, %rdi			# Move done_str to first printf() arg
	movq $0, %rax				# No vector args
	call printf				# Call printf

	jmp boi					# Jump to end function

plus:
	addb $1, (%r15)				# Increment value in cell
	jmp loop				# Jump back to main loop
	
min:
	subb $1, (%r15)				# Decrement value in cell
	jmp loop				# Jump back to main loop

point:
	movb (%r15), %dil			# Move current value to putchar arg
	call putchar				# Call putchar()
	jmp loop				# Jump back to main loop

less_than:
	sub $1, %r15				# Decrement cell pointer
	jmp loop				# Jump back to main loop

greater_than:
	add $1, %r15				# Increment cell pointer
	jmp loop				# Jump back to main loop

start_loop:
	movq $1, %r12				# Set [ counter to 1
	movq $0, %r14				# Set ] counter to 0
	cmpb $0, (%r15)				# Check if the current value is 0
	je loop_loop_skip			# If so jump to loop_loop_skip to skip to the end of the loop
	jmp loop				# If not, ignore this char and jump to main loop

end_loop:
	movq $0, %r12				# Set [ counter 0
	movq $1, %r14				# Set ] counter 1
	cmpb $0, (%r15)				# Check if the current value is 0
	jne loop_loop_back			# If so jump to loop_loop_back to go back to the beginning of the loop
	jmp loop				# If not, ignore this char and jump to main loop loop to continue normal execution

boi:
	movq %rbp, %rsp				# Clear local vars from stack
	popq %rbp				# Restore caller's RBP
	ret					# Return from function
