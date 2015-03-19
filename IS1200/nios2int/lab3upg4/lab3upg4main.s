#
# lab3upg1main.s - version 2010-01-14
#
# Written by F Lundevall.
# Copyright abandoned.
# This file is in the public domain.
#

########################################
# Definitions of device-addresses
# and important constants.
#

# de2_pio_keys4 - 0x840
.equ	keys4_base,0x840
.equ	key4_int, 0x848
.equ	key4_ack, 0x84c

# uart_0 - 0x860
.equ    uart_0_base,0x860

# timer_1 - 0x920
.equ    timer_1_base,0x920

#
# Timer 1 time-out definition.
# The clock frequency at the lab session is 50 MHz.
# For simulation, use a 0.1-second time-out.
# At the lab session, use a 1-second time-out.
#
.equ    timer1count,4999999    # Change this value (and this comment!)

#
# End of definitions of device-addresses
# and important constants.
########################################


########################################
# Macro definitions begin here
#

#
# PUSH reg - push a single register on the stack
#
.macro PUSH reg
    subi sp,sp,4    # reserve space on stack
    stw  \reg,0(sp) # store register
.endm

#
# POP  reg - pop a single register from the stack
#
.macro POP  reg
    ldw  \reg,0(sp) # fetch top of stack contents
    addi sp,sp,4    # return previously reserved space
.endm

#
# PUSHMOST - push all caller-save registers plus ra
#
.set noat           # required since we push r1
.macro PUSHMOST
    PUSH  at        # push assembler-temporary register r1
    PUSH  r2
    PUSH  r3
    PUSH  r4
    PUSH  r5
    PUSH  r6
    PUSH  r7
    PUSH  r8
    PUSH  r9
    PUSH r10
    PUSH r11
    PUSH r12
    PUSH r13
    PUSH r14
    PUSH r15
    PUSH  ra        # push return address register r31
.endm

#
# POPMOST - pop ra plus all caller-save registers
# POPMOST is the reverse of PUSHMOST
#
# .set noat is already done above - no need to repeat that
.macro POPMOST
    POP   ra
    POP  r15
    POP  r14
    POP  r13
    POP  r12
    POP  r11
    POP  r10
    POP   r9
    POP   r8
    POP   r7
    POP   r6
    POP   r5
    POP   r4
    POP   r3
    POP   r2
    POP   at
.endm

#
# Macro definitions end here
########################################

.text
.align 2

########################################
# Stub - three machine instructions (remember,
# movia is expanded into two instructions).
# The stub program-code must be copied
# to the exception-address
# (0x800020 in the current system).
#
# Stub explanation:
# move address of exception handler
# into exception-temporary register et
# Use JMP to jump to the interrupt handler
# (whose address is now in et)
stub:
    movia   et,exchand
    jmp     et
#
# End of stub.
########################################


########################################
# The following section replaces the
# Altera-supplied initialization code.
#
.global alt_main
alt_main:
    nop
    wrctl   status,r0
    br      main
    
    nop
    nop
    # Those NOPs are really not necessary,
    # but may help when you debug the program.
    # Without the NOPs, the branch instruction
    # would just jump to the next address
    # sequentially, which can be confusing.

#
# End of replacement for Altera-supplied
# initialization code.
########################################

    
########################################
# Main program follows.
#

    .data
    .align 2
mytime: .word 0x5957

    .text
    .align 2

#
# The label main
# must be declared global
#
.global main

main:
	# Always disable interupts before
	# initializing any devices
    wrctl   status, r0
    
    #
    # Add your code here to copy the stub
    # to address 0x800020 and on.
    # Remember to copy all three instructions
    # (movia is expanded to two instructions).
    #  
    	movia r4, 0x800020 # destination address
		movia r5, stub # source addres
		ldw r6, 0(r5) # läs 1:a instruktionen
		stw r6, 0(r4) # skriv 1:a instruktionen
		ldw r6, 4(r5) # läs 2:a instruktionen
		stw r6, 4(r4) # skriv 2:a instruktionen
		ldw r6, 8(r5) # läs 3:e instruktionen
		stw r6, 8(r4) # skriv 3:e instruktionen
    #
    # Add your code here to initialize timer_1 for
    # continuous interrupts every 100 ms (0.1 s)
    #
		movia 	r8, timer_1_base # Sparar 0x920 i r8
		mov 	r9, r0 # Ser till att det inte finns något skräp i r9
		movia 	r9, timer1count # Sparar 49 999 999 millisek i r9 
		stwio 	r9, 8(r8) # sparar r9 i periodl
		srli 	r9, r9, 16 # Skiftar värdet i r9 med 16 bitar och sparar i r9
		stwio 	r9, 12(r8) # sparar r9 i periodh
		mov   	r9, r0		# Ser till att det inte finns något skräp i r9
		movi 	r9, 0b0111 # Sparar 0111 i r9. Sätter då Continuous-Mode bit till 1 och interrupt on time out till 1
		stwio 	r9, 4(r8) # sparar r9 i control
	
    #
    # For Assignment 4 (but not earlier!),
    # add code here to initialize de2_pio_keys4
    # for interrupts from KEY0
    #
    
    #instantierar 
    movi	r5, keys4_base  #basadress til keys
    movi	r6, 0b1111 #Enable Int all 4 keys 
    stwio	r6, 8(r5) #Ettställ bitar med index 3,2,1 och 0 på adress 0x848 i Mask-registret
    
    #movi	r5, key4_int
    #movi	r6, 0b101
    #stwio	r6, 0(r5)
    
    
    #
    # Add your code here to initialize the CPU for
    # interrupts from timer_1 (index 10) only.
    # For Assignment 4 (but not earlier!),
    # add code here to also initialize the CPU for
    # interrupts from de2_pio_keys4 (index 2)
    #
    
	movi r7, 0x400		# Flyttar 0x404 till r7
    wrctl ienable, r7   # Läser in ienable värdet till r7
    
    # ettställ bit med index 2 i ienable dvs ctl3 för att tillåta IRQ-02
    rdctl r24, ienable
    ori r24, r24, 0b100
    wrctl ienable, r24
    
    #
    # Add your code here to enable interrupts
    # by writing 1 to the status register
    #
    
	movi r8,1 # ettställ PIE som är bit 0 i STATUS (CTL0)
	wrctl status,r8 # skriv CTL0
	
    #
    # Set start value for prime-space exploration.
    movia    r4,471123
    
#
# Main loop starts here.
mainloop:
    call    primesearch
    PUSH	r4
    movi	r4,33
    trap	# trigga trap efter varje prime-träff
    POP		r4
    mov     r4,r2
    
#
# This is the end of the main loop.
# We jump back to the beginning.
    br      mainloop

#
# End of main program.
########################################


########################################
# Exception handler.
#
# This exception handler is extremely simplified.
# You will expand and improve the handler.
# When you do this, you must add comments -
# and change this comment - to reflect your changes.
#

exchand:
    nop
    nop
    # Those NOPs are not really necessary.
    # However, in this particular program,
    # they may help you setting a breakpoint
    # at the beginning of the handler
    # when you debug the program.
    
    
    # Here we should check the contents of estatus
    # to see if interrupts were enabled (Condition 1).
   
    rdctl r24, estatus  # läs estatus
    andi r24, r24, 1 # kolla EPIE-biten
    beq r24, r0, not_interupt # hopp om EPIE=0 till not_interupt
    
    # Then we should check if ipending is nonzero
    # (Condition 2).
    
 	rdctl r24, ipending # read from ipending
 	beq r24, r0, not_interupt # hopp om EPIE=0 till not_interupt
    
    # If Conditions 1 and 2 are both true, the cause of
    # exception must have been an interrupt. In this case,
    # we should jump to the interrupt-handling code. 
    
    br exc_was_interrupt # no interrupts
    
not_interupt:
	
    # Now, we should check if the instruction at the
    # exception location is a TRAP instruction.
    
   
	PUSH r8

	movia r8,0x003b683a # maskinkod för TRAP
	ldw et,-4(ea) # läs instruktion närmast före returplats
	cmpeq et,et,r8 # jämför
		
	POP r8
		
	bne et,r0, exc_was_trap # om lika, hoppa till exc_was_trap
		

	br		excend 	# Hoppa ur
 
    # Then we should perhaps check if the bit-pattern,
    # at the exception location, is that of
    # an unimplemented instruction
    # that we handle by software emulation. However,
    # this would be beyond the scope of this course.
    
    # In this extremely simplified handler, we check nothing.
    # instead, we return
   
    # The following label is a place to jump to,
    # after making sure that the cause of exception
    # really was an interrupt.
    
exc_was_interrupt:

    # Since we had an interrupt, and not a TRAP,
    # we must subtract 4 from the contents of the
    # exception-address register (ea), so that
    # the interrupted instruction gets restarted
    # when we return from the interrupt.
    # This requirement is Nios2-specific.
    
    subi    ea,ea,4
   
    # This is the place to check if the interrupt
    # came from timer_1 or from another source.
    # Since we have only one source right now,
    # we omit the check (until Assignment 4).
    
    rdctl	r24, ipending
    andi	r24, r24, 0b00100 #IRQ2?
    bne		r24, r0, keyint # 
    
    br		timer1int 
    
    # The following code is specific for
    # interrupts from key4
    
keyint:
    
    PUSHMOST # spara r1-r15 samt r31
    PUSH r16 # långlivad plats för basadress
    PUSH r17 # långlivad plats för ECR
    movia r16, 0x840 # basadress till de2_pio_keys_4
    ldw r17, 12(r16) # läs av ECR
    stw r21, 12(r16) # nollställ ECR, ”kvittera”

KEY0:
	andi r8, r17, 0b0001 # avbrott från key0 ?
	beq r8, r0, KEY1 # nej inte från key0

IntK0: 
	ldw r8, 0(r16) # läs av knappar
	andi r8, r8, 0b0001 # maska fram key0
	bne r8, r0, Up0 # key0 är uppe dvs 1

Down0: 
	movi r4, 'D' # key0 är nere dvs D
	call out_char_uart_0 # skriv ut ”D”
	br KEY1 #

Up0:
	movi r4, 'U' # ascii för boktav U
	call out_char_uart_0 # skriv ut ”U”

KEY1:
	andi r8, r17, 0b0010 # avbrott från key1 ?
	beq r8, r0, KEY2 # nej inte från key1

IntK1: 
	ldw r8, 0(r16) # läs av knappar
	andi r8, r8, 0b0010 # maska fram key1
	bne r8, r0, Up1 # key1 är uppe

Down1: 
	movi r4, '1' # key1 är nere
	call out_char_uart_0 # skriv ut ”1”
	br KEY2 #hoppa till key2

Up1: 
	movi r4, 'I' # ascii för boktav I
	call out_char_uart_0 # skriv ut ”I”

KEY2:
	andi r8, r17, 0b0100 # avbrott från key2 ?
	beq r8, r0, KEY3 # nej inte från key2

IntK2: 
	ldw r8, 0(r16) # läs av knappar
	andi r8, r8, 0b0100 # maska fram key1
	bne r8, r0, Up2 # key2 är uppe

Down2: 
	movi r4, '2' # key2 är nere
	call out_char_uart_0 # skriv ut ”2”
	br KEY3 #

Up2: 
	movi r4, 'S' # ascii för boktav S
	call out_char_uart_0 # skriv ut ”S”

KEY3:
	andi r8, r17, 0b1000 # avbrott från key3 ?
	beq r8, r0, NoMore # nej inte från key3

IntK3: 
	ldw r8, 0(r16) # läs av knappar
	andi r8, r8, 0b1000 # maska fram key3
	bne r8, r0, Up3 # key3 är uppe

Down3: 
	movi r4, '3' # key3 är nere
	call out_char_uart_0 # skriv ut ”3”
	br NoMore #

Up3: 
	movi r4, 'E' # ascii för boktav E
	call out_char_uart_0 # skriv ut ”E”

NoMore:
	POP r17
	POP r16
	POPMOST # återställ r31 samt r15-r1
	eret #
    
timer1int:

    # Acknowledge the interrupt
    movia   et,timer_1_base
    PUSH    r8
    movi    r8,1
    stwio   r8,0(et)    # clears timeout bit
    POP     r8
    
    # This is a first, simple handler.
    # All we do when we get a timer interrupt
    # is print a T on the console.
    # Since the JTAG UART uses interrupts itself,
    # this program must be compiled with a special
    # system library using another UART for the console:
    # We use uart_0.

    # Before calling a subroutine, push r1 through r15, and r31.
    PUSHMOST
	
    movia   r4,mytime
    call    puttime
    movia   r4,mytime
    call    tick
    
    movi	r4, 'T'
    rdctl 	et, estatus  # läs estatus
    PUSH 	ea
    PUSH 	et
    trap
    
    POP	et
    POP	ea
    POPMOST
    
    # Afterwards, restore saved register values.
    
	wrctl 	estatus, et  # läs estatus
		
    # Branch to the end of the exception handler.
    br      excend

    # The following label is a place to jump to,
    # after making sure that the cause of exception
    # really was the result of a trap instruction.
exc_was_trap:

    # Our trap handler will call a subroutine.
    # We save the return address register R31,
    # to avoid problems for the code containing
    # the trap instruction.
    PUSH    ra
    # Print character in R4 using out_char_uart_0.
    call    out_char_uart_0
    # Restore the saved register.
    POP     ra

    # Fall-through to the end of the handler.
    # No branch needed (right now at least).
    
    # This is the end of the exception handler.
excend:
	
    eret
#
########################################

########################################
# Helper functions and support code.
# You do not need to study the following code.
#

# out_char_uart_0 - send byte on uart0
# one parameter, in r4: byte to send
# no return value
#
	.global out_char_uart_0
	
out_char_uart_0:

    movia   r8,uart_0_base
    ldwio   r8,8(r8)        # get uart0 status
    andi    r8,r8,0x40      # check TxRDY bit
    beq     r8,r0,out_char_uart_0   # loop if not ready
    andi    r4,r4,0xff      # sanitize argument
    movia   r8,uart_0_base
    stwio   r4,4(r8)        # write to uart0 TX data
    ret

################################################################
#
# A simplified printf() replacement.
# Implements the following conversions: %c, %d, %s and %x.
# No format-width specifications are allowed,
# for example "%08x" is not implemented.
# Up to four arguments are accepted, i.e. the format string
# and three more. Any extra arguments are silently ignored.
#
# The printf() replacement relies on routines
# out_char_uart_0, out_hex_uart_0,
# out_number_uart_0 and out_string_uart_0
# in file oslab_lowlevel_c.c
#
# We need the macros PUSH and POP (defined previously).
#

.text
.global nios2int_printf

nios2int_printf:
    PUSH    ra		# PUSH return address register r31.
    PUSH    r16     # R16 will point into format string.
    PUSH    r17     # R17 will contain the argument number.
    PUSH    r18     # R18 will contain a copy of r5.
    PUSH    r19     # R19 will contain a copy of r6.
    PUSH    r20     # R20 will contain a copy of r7.
    mov     r16,r4  # Get format string argument
    movi    r17,0   # Clear argument number.
    mov     r18,r5  # Copy r5 to safe place.
    mov     r19,r6  # Copy r6 to safe place.
    mov     r20,r7  # Copy r7 to safe place.
asm_printf_loop:

    ldb     r4,0(r16)   # Get a byte of format string.
    addi    r16,r16,1   # Point to next byte
    # End of format string is marked by a zero-byte.
    beq     r4,r0,asm_printf_end
    cmpeqi  r9,r4,92    # Check for backslash escape.
    bne     r9,r0,asm_printf_backslash
    cmpeqi  r9,r4,'%'   # Check for percent-sign escape.
    bne     r9,r0,asm_printf_percentsign
    
asm_printf_doprint:

    # No escapes present, just print the character.
    movia   r8,out_char_uart_0
    callr   r8
    br      asm_printf_loop
    
asm_printf_backslash:

    # Preload address to out_char_uart_0 into r8.
    movia   r8,out_char_uart_0
    ldb     r4,0(r16)	# Get byte after backslash
    addi    r16,r16,1   # Increase byte count.
    # Having a backslash at the end of the format string
    # is illegal, but must not crash our printf code.
    beq     r4,r0,asm_printf_end
    cmpeqi  r9,r4,'n'   # Newline
    beq     r9,r0,asm_printf_backslash_not_newline
    movi    r4,10       # Newline
    callr   r8
    br      asm_printf_loop
    
asm_printf_backslash_not_newline:

    cmpeqi  r9,r4,'r'   # Return
    beq     r9,r0,asm_printf_backslash_not_return
    movi    r4,13       # Return
    callr   r8
    br      asm_printf_loop
    
asm_printf_backslash_not_return:

    # Unknown character after backslash - ignore.
    br      asm_printf_loop
    
asm_printf_percentsign:

    addi    r17,r17,1	# Increase argument count.
    cmpgei  r8,r17,4    # Check against maximum argument count.
    # If maximum argument count exceeded, print format string.
    bne     r8,r0,asm_printf_doprint
    cmpeqi  r9,r17,1    # Is argument number equal to 1?
    beq     r9,r0,asm_printf_not_r5	# beq jumps if cmpeqi false
    mov     r4,r18      # If yes, get argument from saved copy of r5.
    br      asm_printf_do_conversion
    
asm_printf_not_r5:

    cmpeqi  r9,r17,2    # Is argument number equal to 2?
    beq     r9,r0,asm_printf_not_r6	# beq jumps if cmpeqi false
    mov     r4,r19      # If yes, get argument from saved copy of r6.
    br      asm_printf_do_conversion
    
asm_printf_not_r6:

    cmpeqi  r9,r17,3    # Is argument number equal to 3?
    beq     r9,r0,asm_printf_not_r7	# beq jumps if cmpeqi false
    mov     r4,r20       # If yes, get argument from saved copy of r7.
    br      asm_printf_do_conversion
    
asm_printf_not_r7:

    # This should not be possible.
    # If this strange error happens, print format string.
    br      asm_printf_doprint
    
asm_printf_do_conversion:

    ldb     r8,0(r16)	# Get byte after percent-sign.
    addi    r16,r16,1   # Increase byte count.
    cmpeqi  r9,r8,'x'   # Check for %x (hexadecimal).
    beq     r9,r0,asm_printf_not_x
    movia   r8,out_hex_uart_0
    callr   r8
    br      asm_printf_loop
    
asm_printf_not_x:

    cmpeqi  r9,r8,'d'   # Check for %d (decimal).
    beq     r9,r0,asm_printf_not_d
    movia   r8,out_number_uart_0
    callr   r8
    br      asm_printf_loop
    
asm_printf_not_d:

    cmpeqi  r9,r8,'c'   # Check for %c (character).
    beq     r9,r0,asm_printf_not_c
    # Print character argument.
    br      asm_printf_doprint
    
asm_printf_not_c:

    cmpeqi  r9,r8,'s'   # Check for %s (string).
    beq     r9,r0,asm_printf_not_s
    movia   r8,out_string_uart_0
    callr   r8
    br      asm_printf_loop
    
asm_printf_not_s:
asm_printf_unknown:

    # We do not know what to do with other formats.
    # Print the format string text.
    movi    r4,'%'
    movia   r8,out_char_uart_0
    callr   r8
    ldb     r4,-1(r16)
    br      asm_printf_doprint
    
asm_printf_end:

    POP     r20
    POP     r19
    POP     r18
    POP     r17
    POP     r16
    POP     ra
    ret

#
# End of simplified printf() replacement code.
#
################################################################

#
# End of file.
#
.end
