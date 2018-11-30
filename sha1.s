.global sha1_chunk
#
#
# * Args: Address of h0 - %rdi
#	  Address of first 32-bit word - %rsi
#
sha1_chunk:
	pushq %rbp				# Prologue: Push caller's BP onto stack
	movq %rsp, %rbp				# Set BP
	
	## Save non-volatile registers to stack
	pushq %r10				# Push R10 to stack
	pushq %r11				# Push R11 to stack
	pushq %r12				# Push R12 to stack
	pushq %r13				# Push R13 to stack
	pushq %r14				# Push R14 to stack
	pushq %r15				# Push R15 to stack

	## Extending 32-bit words into eighty 32-bit words
	movq $16, %rcx				# Create variable 'i' with value 16
	
	## START LOOP ##
    extend_loop:
	movq %rcx, %r8				# Copy variable 'i' to variable 'index'

	## Get first word
	sub $3, %r8				# Subtract 3 from 'index' (w[i-3])
	movl (%rsi, %r8, 4), %r9d		# Get value from array with index 'index' and
						# move it into R9
	## Get second word
	sub $5, %r8				# Subtract 5 from 'index' (w[i-8])
	movl (%rsi, %r8, 4), %r10d 		# Get value from array with index 'index' and 
						# move it into R10
	
 	## XOR first two words
	xor %r10d,  %r9d			# XOR R9 and R10 and store result in R9	

	## Get third word
	sub $6, %r8				# Subtract 6 from 'index' (w[i-14])
	movl (%rsi, %r8, 4), %r10d		# Get value from array with index 'index' and
						# move it into R10

	## XOR first three words
	xor %r10d, %r9d				# XOR R9 and R10 and store result in R9

	## Get fourth word
	sub $2, %r8				# Subtract 2 from 'index' (w[-16])
	movl (%rsi, %r8, 4), %r10d		# Get value from array with index 'index' and
						# move it into R10

	## XOR all words
	xor %r10d, %r9d				# XOR R9 and R10 and store result in R9

	## Rotate result one to the left
	rol $1, %r9d				# Rotate value in R9 (XOR'ed words) one to the left
						# and store the result in R9
	
	## Move result into array
	movl %r9d, (%rsi, %rcx, 4)		# Move result into array at index 'index'
	
	## Loop check
	incq %rcx				# Increment 'i' by one
	cmpq $79, %rcx				# Compare 'i' to 79
	jle extend_loop				# If i <= 79, then jump to beginning loop
	## END LOOP ##

	## At this point the following registers are free to use:
	## rcx, rdx, r8-15, rax
	## rcx - i
  	## rdx - temp/calculations
	## r8 - a
	## r9 - b
	## r10 - c
	## r11 - d
	## r12 - e
	## r13 - f
	## r14 - k
	## r15 - calculations
	## rax - calculations

	## Initialize hash values
	movq %rdi, %rdx				# Move address of h0 to RDX
	movl (%rdx), %r8d			# Dereference address (h0) of RDX and load it into R8,
						# creating var 'a'
	add $4, %rdx				# Add 4 to the value in RDX, effectively creating
						# an offset of 4 bytes (32 bits)
	movl (%rdx), %r9d			# Save the next value (h1) in R9, creating 'b'
	add $4, %rdx				# Moving the address by 4 bytes
	movl (%rdx), %r10d			# Save the next value (h2) in R10, creating 'c'
	add $4, %rdx				# Moving the address by 4 bytes again
	movl (%rdx), %r11d			# Save the next value (h3) in R11, creating 'd'
	add $4, %rdx				# Moving the address by 4 bytes again
	movl (%rdx), %r12d 			# Save the next value (h4) in R12, creating 'e'

	## Main hash loop
	movq $0, %rcx				# Initialize variable 'i' with value 0
	 
	## START LOOP ##
    main_loop:
	cmpq $19, %rcx				# Compare 'i' to 19
	jg second_case				# If 'i' > 19, then skip to second case/check

	# IF 0 <= i <= 19:
	movl %r9d, %edx				# Save 'b' in EDX to preserve original value
	and %r10d, %edx				# Calculate 'b' AND 'c' and save result in EDX
	movl %r9d, %r15d			# Save 'b' in R15 to preserve original value
	not %r15d				# Calculate complement of b and store it in R15
	and %r11d, %r15d			# Calculate (NOT 'b') AND 'd' and save result in R15
	or %r15d, %edx				# Calculate ('b' AND 'c') OR ((NOT 'b') AND 'd') and
						# save the result in EDX

	movl %edx, %r13d			# Set 'f' to the result of the previous calculation	
	movl $0x5A827999, %r14d			# Set 'k' to 0x5A827999	
	jmp resume_loop				# Return to normal loop
	
      second_case:
	cmpq $39, %rcx				# Compare 'i' to 39
	jg third_case				# If 'i' > 39, then skip to third case/check

	# IF 20 <= i <= 39:
	movl %r9d, %edx				# Save 'b' in EDX to preserve original value
	xor %r10d, %edx				# Calculate 'b' XOR 'c' and save the result in EDX	
	xor %r11d, %edx				# Calculate ('b' XOR 'c') XOR 'd' and save the result
						# in EDX

	movl %edx, %r13d			# Set 'f' to the result of the previous calculation
	movl $0x6ED9EBA1, %r14d			# Set 'k' to 0x6ED9EBA1
	jmp resume_loop				# Return to normal loop
	
      third_case:
	cmpq $59, %rcx				# Compare 'i' to 59
	jg fourth_case				# If 'i' > 59, then skip to fourth case
	
	# IF 40 <= i <= 59:
	movl %r9d, %edx				# Save 'b' in EDX to preserve original value
	and %r10d, %edx				# Calculate 'b' AND 'c' and store the result in EDX
	movl %r9d, %r15d			# Save 'b' in EDX to preserve original value
	and %r11d, %r15d			# Calculate 'b' AND 'd' and store the result in R15
	movl %r10d, %eax			# Save 'c' in EAX to preserve original value
	and %r11d, %eax				# Calculate 'c' AND 'd' and store the result in EAX
	
	or %r15d, %edx				# Calculate ('b' AND 'c') OR ('b' AND 'd') and store
						# the result in EDX
	or %eax, %edx				# Calculate (('b' AND 'c') OR ('b' AND 'd')) OR 
						# ('c' AND 'd') and store the result in EDX
	
	movl %edx, %r13d			# Set 'f' to the result of the previous calculation
	movl $0x8F1BBCDC, %r14d			# Set 'k' to 0x8F1BBCDC
	jmp resume_loop				# Return to normal loop

      fourth_case:
	cmpq $79, %rcx				# Compare 'i' to 79
	jg resume_loop				# If 'i' > 79, then skip to resume_loop
	
	# IF 60 <= i <= 79:
	movl %r9d, %edx				# Save 'b' in EDX to preserve the original value
	xor %r10d, %edx				# Calculate 'b' XOR 'c' and store the result in EDX
	xor %r11d, %edx				# Calculate ('b' XOR 'c') XOR 'd' and store the 
						# result in EDX

	movl %edx, %r13d			# Set 'f' to the result of the previous calculation
	movl $0xCA62C1D6, %r14d			# Set 'k' to 0xCA62C1D6
	
      resume_loop:
	movl %r8d, %edx				# Save 'a' in EDX to preserve the original value
	rol $5, %edx				# Rotate 'a' 5 to the left
	movl (%rsi, %rcx, 4), %eax		# Save 'w[i]' in EAX
	add %eax, %edx				# Set 'temp' to (a rotl 5) + w[i]
	add %r13d, %edx				# Add the value of 'f' to 'temp'
	add %r14d, %edx				# Add the value of 'k' to 'temp'
	add %r12d, %edx				# Add the value of 'e' to 'temp'
						# Temp = (a rotl 5) + w[i] + f + k + e	
	
	movl %r11d, %r12d			# Set 'e' to 'd'
	movl %r10d, %r11d			# Set 'd' to 'c'
	movl %r9d, %r15d			# Save 'b' in R15 to preserve the original value
	rol $30, %r15d				# Rotate 'b' 30 to the left
	movl %r15d, %r10d			# Set 'c' to ('b' rotl 30)
	movl %r8d, %r9d				# Set 'b' to 'a'
	movl %edx, %r8d				# Set 'a' to 'temp'

	incq %rcx
	cmpq $79, %rcx
	jle main_loop
	## END LOOP ##
	
	## Set new hash values
	# (rdi) = (rdi) + r8d
	# (rdi + 4) = (rdi + 4) + r9d
	# (rdi + 8) = (rdi + 8) + r10d
	# (rdi + 12) = (rdi + 12) + r11d
	# (rdi + 16) = (rdi + 12) + r12d
	movq %rdi, %rdx 			# Save the address of 'h0' to preserve the original value
	add %r8d, (%rdx)			# Add 'a' to 'h0'
	add $4, %rdx				# Add 4 to the address stored in RDX to get the 
						# address of h1
	add %r9d, (%rdx)			# Add 'b' to 'h1' 
	add $4, %rdx				# Add 4 to the address stored in RDX to get the 
						# address of h2
	add %r10d, (%rdx)			# Add 'c' to 'h2'
	add $4, %rdx				# Add 4 to the adress stored in RDX to get the
						# address of h3
	add %r11d, (%rdx)			# Add 'd' to 'h3'
	add $4, %rdx				# Add 4 to the address stored in RDX to get the
						# address of h4
	add %r12d, (%rdx)			# Add 'e' to 'h4'			

	## Restore non-volatile registers
	popq %r15				# Pop R15 from stack
	popq %r14				# Pop R14 from stack
	popq %r13				# Pop R13 from stack
	popq %r12				# Pop R12 from stack
	popq %r11				# Pop R11 from stack
	popq %r10				# Pop R10 from stack
	
	## End function
	movq %rbp, %rsp				# Epilogue: Clear local vars from stack
	popq %rbp				# Restore caller's BP
	ret
