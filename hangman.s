##CSC35 project
##Paul McHugh

.data

##VT100 codes
ClearScreenCode:
	.byte 0x1B
	.ascii "[2J\0"

ColorCodeTable:
	.quad ForegroundBlack
	.quad ForegroundRed
	.quad ForegroundGreen
	.quad ForegroundYellow
	.quad ForegroundBlue
	.quad ForegroundMagenta
	.quad ForegroundCyan
	.quad ForegroundWhite

ForegroundBlack:
	.byte 0x1B
	.ascii "[30m\0"
ForegroundRed:
	.byte 0x1B
	.ascii "[31m\0"
ForegroundGreen:
	.byte 0x1B
	.ascii "[32m\0"
ForegroundYellow:
	.byte 0x1B
	.ascii "[33m\0"
ForegroundBlue:
	.byte 0x1B
	.ascii "[34m\0"
ForegroundMagenta:
	.byte 0x1B
	.ascii "[35m\0"
ForegroundCyan:
	.byte 0x1B
	.ascii "[36m\0"
ForegroundWhite:
	.byte 0x1B
	.ascii "[37m\0"

##this where the execution strings are stored
AboveBladeTable:
	.quad ExecutionProg0_0
	.quad ExecutionProg1_0
	.quad ExecutionProg2_0
	.quad ExecutionProg3_0
	.quad ExecutionProg4_0
	.quad ExecutionProg5_0
	.quad ExecutionProg6_0

BelowBladeTable:
	.quad ExecutionProg0_1
	.quad ExecutionProg1_1
	.quad ExecutionProg2_1
	.quad ExecutionProg3_1
	.quad ExecutionProg4_1
	.quad ExecutionProg5_1
	.quad ExecutionProg6_1

ExecutionProg0_0:
	.ascii "   | |\n"
	.ascii "   | |\n"
	.ascii "   | |\n"
	.ascii "   | |\n"
	.ascii "   | |\n"
	.ascii "   |\0"
ExecutionProg0_1:	
	.ascii "|\n"
	.ascii "___|O|___\n"
	.ascii "=========\n\0"
ExecutionProg1_0:
	.ascii "   | |\n"
	.ascii "   | |\n"
	.ascii "   | |\n"
	.ascii "   | |\n"
	.ascii "   |\0"
ExecutionProg1_1:
	.ascii "|\n"
	.ascii "   | |\n"
	.ascii "___|O|___\n"
	.ascii "=========\n\0"
ExecutionProg2_0:
	.ascii "   | |\n"
	.ascii "   | |\n"
	.ascii "   | |\n"
	.ascii "   |\0"
ExecutionProg2_1:
	.ascii "|\n"
	.ascii "   | |\n"
	.ascii "   | |\n"
	.ascii "___|O|___\n"
	.ascii "=========\n\0"
ExecutionProg3_0:
	.ascii "   | |\n"
	.ascii "   | |\n"
	.ascii "   |\0"
ExecutionProg3_1:
	.ascii "|\n"
	.ascii "   | |\n"
	.ascii "   | |\n"
	.ascii "   | |\n"
	.ascii "___|O|___\n"
	.ascii "=========\n\0"
ExecutionProg4_0:
	.ascii "   | |\n"
	.ascii "   |\0"
ExecutionProg4_1:
	.ascii "|\n"
	.ascii "   | |\n"
	.ascii "   | |\n"
	.ascii "   | |\n"
	.ascii "   | |\n"
	.ascii "___|O|___\n"
	.ascii "=========\n\0"
ExecutionProg5_0:
	.ascii "   |\0"
ExecutionProg5_1:
	.ascii "|\n"
	.ascii "   | |\n"
	.ascii "   | |\n"
	.ascii "   | |\n"
	.ascii "   | |\n"
	.ascii "   | |\n"
	.ascii "___|O|___\n"
	.ascii "=========\n\0"
ExecutionProg6_0:
	.ascii "   | |\n"
	.ascii "   | |\n"
	.ascii "   | |\n"
	.ascii "   | |\n"
	.ascii "   | |\n"
	.ascii "   | |\n"
	.ascii "___|\0"
ExecutionProg6_1:
	.ascii "|___\n"
	.ascii "====\0"
ExecutionProg6_2:
	.ascii "====\n\0"

BloodyBlade:
	.ascii "\\\0"
BloodyHead:
	.ascii "O\0"
##END STUFF FOR THE ASCII ART

GameDesc_pt1:
	.ascii "Hello and welcome to this game of \0"
GameDesc_pt2:
	.ascii "EXECUTION\n\0"
PromptEnterWord:
	.ascii "Enter a word shorter than 25 characters.  If the prisoner can't guess it he gets the guillotine.\n\0"
GuessNewPrompt:
	.ascii "\nMake a new guess:\0"
PlayerWinsText:
	.ascii "Congratulations you survived!!!\n\0"
PlayerLosesText:
	.ascii "You got executed :(\n\0"
NewLine:
	.ascii "\n\0"
Buffer:
	.space 25, 0
DisplayBuffer:
	.space 25, 0

.text
.global _start

_start:	
	##print the game description
	mov $GameDesc_pt1, %rax
	call PrintCString
	
	##Eecution in red
	mov $1, %rax
	call SetForeColor
	mov $GameDesc_pt2, %rax
	call PrintCString
	
	##reset color
	mov $7, %rax
	call SetForeColor
	
	##print the prompt
	mov $PromptEnterWord, %rax
	call PrintCString
	
	##get the string in red
	mov $1, %rax
	call SetForeColor
	mov $Buffer, %rax
	mov $25, %rbx
	call ScanCString
	mov $7, %rax
	call SetForeColor	##then reset the color
	
	##clear the screen to stop cheaty players from looking at the word
	call ClearScreen
	
	mov $0, %rdi
LowercaseLoop:
	cmpb $0, Buffer(%rdi)
	je LowercaseLoopEnd
	##check to make sure the value of the index is between 97 and 122 inclusive
	cmpb $65, Buffer(%rdi)
	jl NextIndex
	cmpb $90, Buffer(%rdi)
	jg NextIndex
	##do the actual changing of the char value
	addb $32, Buffer(%rdi)
	
NextIndex:
	add $1, %rdi
	jmp LowercaseLoop
LowercaseLoopEnd:
	
	##compute info
	mov $Buffer, %rax
	call LengthCString
	mov %rax, %rcx
	
	##initalize the display buffer
	mov $0, %rdi
DisplayBufferInitLoop:
	cmp %rcx, %rdi
	jge DisplayBufferInitLoopEnd
	movb $'-', DisplayBuffer(%rdi)
	inc %rdi
	
	jmp DisplayBufferInitLoop
DisplayBufferInitLoopEnd:
	##display buffer initalized
	
	##initalize r8 to 0.  r8 stores the number of failed guesses
	mov $0, %r8
	##here is the meat and potatoes guess loop
GuessLoop:
	##find out if all the letters have been guessed(and jump out of the guess loop if so)
	##set %rdi to 0 the start of the buffer
	mov $0, %rdi
StringNotComplete:	##this loop is nested in the guess loop
	##if the character is a '-' then accept a guess
	cmpb $'-', DisplayBuffer(%rdi)
	je StringNotCompleteEnd
	
	##if we have hit the end of the buffer then we stop guesses by jumping out of the GuessLoop
	cmp %rcx, %rdi
	jge GuessLoopEnd
	
	##we are not at the end of the buffer and we haven't hit a '-' yet.  We must probe the next character.
	inc %rdi
	jmp StringNotComplete
StringNotCompleteEnd:
	##print the Guillotine
	call PrintStickFig
	##we need to print out the display buffer
	mov $DisplayBuffer, %rax
	call PrintCString
	##print guess prompt
	mov $GuessNewPrompt, %rax
	call PrintCString
	##read the guessed char
	call ScanChar
	
	##case insensitivity
	cmpb $65, %al
	jl NotUppercase
	cmpb $90, %al
	jg NotUppercase
	addb $32, %al	##if it is uppercase then we make it lowercase
NotUppercase:
	
	mov %al, %r9b	##backup the most recently read character	
	
	##copy the letter to all matching indices in the DisplayBuffer
	mov $0, %rdi
	
	##%rbx will be set to 1 if letter is correct(e.g. any of the - are changed)
	mov $0, %rbx
CopyCorrectLoop:
	##if we are at the end of the string then we jump out of the loop
	cmp %rcx, %rdi
	je CopyCorrectLoopEnd
	
	##copy the value in the buffer to the display buffer if the value in the buffer matches the guess
	cmpb %al, Buffer(%rdi)
	jne CopyNextIndex
	movb Buffer(%rdi), %ah
	movb %ah, DisplayBuffer(%rdi)
	mov $1, %rbx	##this guess is correct
CopyNextIndex:
	inc %rdi
	jmp CopyCorrectLoop
CopyCorrectLoopEnd:
	
	cmp $1, %rbx
	je GotACorrectLetter
	inc %r8		##increment the failure counter if the player is wrong
GotACorrectLetter:
	
	cmp $6, %r8	##if the execution progress hits 6 then he is dead
	je PlayerLoses
	
	jmp GuessLoop
GuessLoopEnd:
	
PlayerWins:
	call PrintStickFig
	##print the word
	mov $2, %rax
	call SetForeColor
	mov $DisplayBuffer, %rax
	call PrintCString
	mov $NewLine, %rax
	call PrintCString
	mov $7, %rax
	call SetForeColor
	
	mov $PlayerWinsText, %rax
	call PrintCString
	
	jmp WinEvalDone
	
PlayerLoses:
	call PrintStickFig
	##print the word in red
	mov $1, %rax
	call SetForeColor
	mov $Buffer, %rax
	call PrintCString
	mov $NewLine, %rax
	call PrintCString
	mov $7, %rax
	call SetForeColor
	
	mov $PlayerLosesText, %rax
	call PrintCString
	
WinEvalDone:
	
	call EndProgram
	
	
PrintStickFig:	##%r8 contains the failcounter The failcounter determines the execution progress
	push %rax
	##sanity check. %r8 must be less than or equal to 6
	cmp $6, %r8
	jg StickManPrintOver
	
	call ClearScreen	##Clear the screen it looks much better
	
	mov AboveBladeTable(,%r8,8), %rax	##get the part of the Guillotine above the blade and load it into %rax
	call PrintCString			##print the part of the Guillotine above the blade
	
	mov $1, %rax		##the color code for red(blood)
	call SetForeColor	##the red bloddy blade
	
	mov $BloodyBlade, %rax
	call PrintCString	##actually printing the blade
	
	mov $7, %rax		##7 is code for white
	call SetForeColor	##reset the fore color to white
	
	mov BelowBladeTable(,%r8,8), %rax	##get the part of the Guillotine below the blade and load it into %rax
	call PrintCString			##print the part of the Guillotine below the blade
	
	##At this point the entire Guillotine will have been printed in the case where the Execution progress is less than 6
	##if the execution progress is at 6 then we need to print the bloody head and the rest of the Guillotine
	##otherwise we jump to the StickManPrintOver
	cmp $6, %r8
	jne StickManPrintOver
	
	##ok it seems like the player just died
	mov $1, %rax		##the color code for red(blood)
	call SetForeColor	##the red bloddy head
	
	mov $BloodyHead, %rax
	call PrintCString	##actually printing the head
	
	mov $7, %rax		##7 is code for white
	call SetForeColor	##reset the fore color to white
	
	##now we print the last bit of the Guillotine
	mov $ExecutionProg6_2, %rax	##load the last bit of the Guillotine
	call PrintCString		##print it
	
StickManPrintOver:
	
	pop %rax
	ret

PrintCString:  ##print a C string starting at the address in %RAX and continuing to the newline
	
	push %rax
	push %rsi
	push %rdi
	push %rdx
	push %rcx
	push %r11
	
	mov %rax, %rsi		##copy the address in %rax to %rsi which is the register to pass the string
	
	##get the length of the string and put it in %rdx
	call LengthCString
	mov %rax, %rdx
	
	##set the %rdi value to STD_OUT
	mov $1, %rdi
	
	##set the syscall to 1 (for the read syscall)
	mov $1, %rax
	syscall
	
	pop %r11
	pop %rcx
	pop %rdx
	pop %rdi
	pop %rsi
	pop %rax
	ret

LengthCString:  ##takes the address of the start of a C string in %rax and returns the length of it in %rax 
	
	push %rbx
	push %rcx
	push %r11
	
	##initalize %rbx to %rax
	mov %rax, %rbx
	
NotNullTerm:
	cmpb $0, (%rbx)
	je IsNullTerm		##if this char is a null terminator then we jump to the code that calculates the length from the first and last char in the string
	add  $1, %rbx		##increment the %rbx register untill we get the null terminator
	jmp NotNullTerm		##have not reached the null terminator yet keep going
IsNullTerm:
	sub %rax, %rbx		##subtract the start index from the end index to get the length
	mov %rbx, %rax		##copy the result to the %rax register
	
	pop %r11
	pop %rcx
	pop %rbx
	ret

ScanCString:	##reads %rbx bytes from STD_IN to the buffer that %rax is pointing at
	push %rax
	push %rcx
	push %rdx
	push %rsi
	push %rdi
	push %r11
	
	##read %rax=0,%rdi=<file descriptor>,%rsi=<destination buffer address>,%rdx=<# of bytes to read>
	mov %rax, %rsi
	mov $0, %rax
	mov $0, %rdi
	mov %rbx, %rdx
	syscall
	##the number of bytes read is now in %rax
	
	sub $1, %rax			##don't count the terminating new line as a character
	movb $0, (%rsi,%rax,1)	##and zero the new line into a null terminator
	
	##restore the registers
	pop %r11
	pop %rdi
	pop %rsi
	pop %rdx
	pop %rcx
	pop %rax
	ret

ScanChar:		##get one character from STD_IN and return it in %al
	
	##create stack frame
	push %rbp
	mov %rsp, %rbp
	sub $2, %rsp
	
	##backup registers
	push %rdi
	push %rsi
	push %rdx
	push %rcx
	push %r11
	
	##read a byte onto the stack
	mov $0, %rax		##set the syscall to read
	mov $0, %rdi		##set the read target to stdin
	lea -2(%rbp), %rsi	##load the address to read the input from STDIN into
	mov $2, %rdx		##read the char and the endline
	syscall
	
	##clear %rax and copy the result of the syscall into %al
	mov $0, %rax
	movb -2(%rbp), %al
	
	##restore registers
	pop %r11
	pop %rcx
	pop %rdx
	pop %rsi
	pop %rdi
	
	##delete stack frame
	mov %rbp, %rsp
	pop %rbp
	ret

SetForeColor:		##Sets the foreground color to the color code in %rax 0=black,1=Red,2=Green,3=Yellow,4=Blue,5=Magenta,6=Cyan,7=White
	push %rax
	cmp $7, %rax
	ja ForegroundCCInvalid
	mov ColorCodeTable(,%rax,8), %rax
	call PrintCString
ForegroundCCInvalid:
	pop %rax
	ret

ClearScreen:		##clears the screen
	push %rax
	mov $ClearScreenCode, %rax
	call PrintCString
	pop %rax
	ret

EndProgram:		##exit the program normally
	
	mov $60, %rax	##set the syscall to 60 (sys_exit)
	mov	$0,  %rdi	##set the error code to 0 (no error)
	syscall
	ret
