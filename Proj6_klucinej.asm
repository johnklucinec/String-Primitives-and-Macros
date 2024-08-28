TITLE String Primitives and Macros     (Proj6_klucinej.asm)

; Author: John Klucinec
; Last Modified: 6/11/2023
; OSU email address: klucinej@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6                
; Due Date: 6/12/2023
; Description: The program is designed to practice low-level I/O procedures by taking a series of signed decimal integers from the user, 
; storing them in an array, and then calculating and displaying their sum and truncated average. The program also includes error handling 
; for invalid input and ensures that the input numbers are within the range of 32-bit signed integers.
;
; All code was type by me. No template was used. 

INCLUDE Irvine32.inc

; ------------------------------------
; Macro section containing mDisplayString and mGetString
; ------------------------------------
mGetString MACRO promptOffset, memoryOffset, countValue, bytesReadOffset
  PUSH  EDX                
  PUSH	ECX
  PUSH	EAX
	
  mDisplayString promptOffset	; Display the prompt using mDisplayString macro

  MOV   EDX, memoryOffset		  ; Set memory location for input
  MOV   ECX, countValue			  ; Set the max length of input string
  CALL	ReadString				    ; Read the input string from the user

  MOV	[bytesReadOffset], EAX	; Store the number of bytes read

  POP   EAX
  POP   ECX							
  POP   EDX							
ENDM

mDisplayString	MACRO	stringOffset
  PUSH  EDX						
  MOV   EDX, stringOffset ; Set memory location for output
  CALL	WriteString
  POP   EDX							
ENDM

; Define constants to represent the array size and lower and upper limits of the valid range

ARRAYSIZE	  = 10          ; Size of the array
BUFFER_SIZE	= 12			    ; Maximum SDWORD digits (11) + null terminator (1)
LO			    = 2147483648  ; Maximum negative SDWORD
HI			    = 2147483647  ; Maximum positive SDWORD

; ------------------------------------
; Data section containing strings, variables, and arrays
; ------------------------------------

.data

; Program introduction messages
intro1  BYTE	"Program to practice designing low-level I/O procedures			By: Johnny Klucinec", 13, 10, 13, 10, 0
intro2  BYTE	"Please provide ", 0
intro3  BYTE	" signed decimal integers. "
			  BYTE	13, 10,"Each number needs to be small enough to fit inside a 32 bit register. After you have finished inputting "
			  BYTE	"the raw numbers I will display a list of the integers, their sum, and their average value.", 13, 10, 13, 10, 0

; Prompt messages
prompt1     BYTE	"Please enter an signed number: ", 0
prompt2     BYTE	"Please try again: ", 0
error       BYTE	"ERROR: You did not enter an signed number or your number was too big. ", 13, 10, 0
results     BYTE	13, 10,"You entered the following numbers: ", 13, 10, 0
sumSTR      BYTE	13, 10, 13, 10,"The sum of these numbers is: ", 0
averageSTR  BYTE	13, 10, 13, 10,"The truncated average is: ", 0				
goodbye     BYTE	13, 10, 13, 10, "Thanks for playing! ", 0
comma       BYTE	",",0
space       BYTE	" ",0

; Data declarations
array     SDWORD	ARRAYSIZE DUP(?)
convSTR   SDWORD	0                     ; Converted String
sum       SDWORD	0
average   SDWORD	0                     ; Truncated average

inputBuffer BYTE	BUFFER_SIZE DUP(?)	; Buffer to store user input
outBuffer	  BYTE	BUFFER_SIZE DUP(?)	; Reserve space for the output buffer
bytesRead   DWORD	?					          ; Variable to store number of bytes read

.code
main PROC

  push	OFFSET outBuffer
  push	OFFSET intro3
  push	OFFSET intro2
  push	OFFSET intro1
  call	Introduction

  mov   ECX, ARRAYSIZE
  xor   EBX, EBX           ; Set EBX to 0 for the index
_fillArray:
  push  OFFSET error
  push  OFFSET prompt2
  push  OFFSET convSTR
  push  OFFSET prompt1
  push  OFFSET inputBuffer
  push  OFFSET bytesRead
  call  ReadVal

  mov   EAX, convSTR      ; Move the value of convSTR to EAX (filling array)
  mov   array[EBX*4], EAX ; Store the value of EAX in the current position of the array

  inc   EBX												
  loop  _fillArray										

  push	OFFSET space
  push	OFFSET comma
  push	OFFSET outBuffer
  push	OFFSET results
  push	OFFSET array
  call	WriteArray		

  push	OFFSET outBuffer
  push	OFFSET sumSTR
  push	OFFSET sum
  push	OFFSET array
  call	FindSum	

  push	OFFSET outBuffer
  push	OFFSET averageSTR
  push	OFFSET average
  push	OFFSET array
  call	FindAverage		

  push	OFFSET goodBye
  call	Farewell	

	Invoke ExitProcess,0  ; exit to operating system
main ENDP

; -- ReadVal --
; Reads a signed decimal integer from user input
; receives: addresses of prompt1, prompt2, inputBuffer, bytesRead, convSTR, and outBuffer are pushed onto the system stack
; returns: the signed decimal integer read from user input in convSTR
; preconditions: prompt1 and prompt2 are strings, inputBuffer is an array of characters, bytesRead is a DWORD, and convSTR is a DWORD
; registers changed: none
ReadVal PROC
  push  EBP
  mov   EBP, ESP
  push	EAX
  push	EBX
  push	ECX
  push	EDX
  push	ESI
  push	EDI

  ; Collect user input with prompt1
  mGetString	[EBP+16], [EBP+12], BUFFER_SIZE, [EBP+8] 

_restart:
  xor	  EAX, EAX
  xor   EBX, EBX
  mov	  ECX, [EBP+8]
  mov	  ESI, [EBP+12]
  cld

_nextChar:
  xor	  EAX, EAX      ; Clear EAX (and AL) for each number. 
  lodsb
  
_checkSign:                  
  cmp   AL, '+'				
  je    _subSign			; If AL contains a '+', jump to the next character
  cmp   AL, '-'			
  jne   _processChar  ; If not a sign character, process the current character
  mov   EDX, 1				; Set EDX to 1 if negative

_subSign:
  dec   ECX					  ; Decrement ECX to account for the sign character
  jmp   _nextChar										

_processChar:
  sub   AL, '0'
  jl    _error				; If AL is negative, it's an invalid character, jump to error handling
  cmp	  AL, 9
  jg	  _error				; If yes, it's an invalid character, jump to error handling

  push	ECX					  ; Save ECX for 10x loop.
  add	  ECX, -1	
  cmp	  ECX, 0
  jle	  _skip				  ; Jump if number has correct amount of 0's

_buildChar:
  imul	EAX, 10 
  loop	_buildChar

_skip:
  pop	  ECX
  add	  EBX, EAX
  loop	_nextChar

_storeValue:
  cmp	  EBX, LO				; Check if > the maximum negative SDWORD
  ja	  _error				; If yes, jump to error handling
  cmp	  EDX, 1				; Check if the number is negative
  jne	  _testPositive	; If not, jump to store positive value
  neg   EBX					  ; Negate EBX to store the negative value
  jmp	  _store

_testPositive:
  cmp	  EBX, HI				; Check if > maximum positive SDWORD
  ja	  _error	

_store:
  mov   EAX, EBX
  mov	  EDI, [EBP+20]	; Move the address of the array to EDI
  stosd		    				; Store the value in EAX at the address pointed to by EDI and increment EDI
  jmp	  _done
		
_error:
  mDisplayString [EBP+28]	; Display the error message
							            ; Collect user input, but with prompt2
  mGetString	[EBP+24], [EBP+12], BUFFER_SIZE, [EBP+8]	
  jmp	_restart

_done:
  mov	  EAX, EBX
  pop	  EDI
  pop	  ESI
  pop	  EDX
  pop	  ECX
  pop	  EBX
  pop	  EAX
  pop	  EBP
  ret	  24

ReadVal ENDP

; -- WriteVal --
; Writes a signed decimal integer as a string to the output
; receives: the signed decimal integer and the address of outBuffer are pushed onto the system stack
; returns: none
; preconditions: outBuffer is an array of characters with a size defined by BUFFER_SIZE
; registers changed: none
WriteVal PROC
  push  EBP
  mov   EBP, ESP
  push  EAX
  push  EBX
  push  ECX
  push  EDX
  push  EDI
  push  ESI

  ; Clear outBuffer
  mov   ECX, BUFFER_SIZE    ; Set loop counter BUFFER_SIZE
  mov   EDI, [EBP+12]		    ; Load the address of outBuffer into EDI
_clearLoop:
  cld
  mov	  AL,0
  stosb
  dec   ECX					        ; Decrement the loop counter
  jnz   _clearLoop			    ; Continue looping until counter reaches 0

  mov   EAX, [EBP+8]
  mov   EDX, [EBP+12]
  lea   EDI, [EDX]		  	  ; Point to the first digit position

  xor   EBX, EBX		    	  ; Clear EBX, used for count
  xor   ESI, ESI


  cmp   EAX, 0				      ; Check if value is zero
  je    _zero
  jg    _writeInt
  mov   ESI, 1			    	  ; Remember if number is negative
  neg	  EAX					        ; Neg EAX for printing

_writeInt:
  inc   EBX					        ; Increment count variable
  xor   EDX, EDX     
  mov   ECX, 10
  div   ECX
  add   DL, '0'			  	    ; Convert the remainder to a character
  dec   EDI					        ; Move to the next character
  mov   BYTE PTR [EDI], DL  ; Store the character
  test  EAX, EAX           
  jnz   _writeInt			      ; Continue if EAX is not zero

  cmp   ESI, 1				      ; Check if value is negative (1 = negative)
  je   _addSign
  jmp   _done

_zero:
  cld
  mov	  al, '0'
  stosb
  jmp   _done

_addSign:
  dec   EDI					        ; Move to the next character
  mov   BYTE PTR [EDI], '-' ; Store the character
  inc   EBX					        ; Increment count variable

_done:
  mov   EDX, [EBP+12]
  lea   EDX, [EDX]			    ; Load the address of [EBP+12] into EDX
  sub   EDX, EBX			      ; Point to the beginning of the String
  mDisplayString EDX        

  pop   ESI
  pop   EDI
  pop   EDX
  pop   ECX
  pop   EBX
  pop   EAX
  pop   EBP          
  ret   8
WriteVal ENDP

; -- WriteArray --
; Writes the elements of an integer array to the output, separated by commas and spaces
; receives: the address of the array, title string, and addresses of comma and space strings are pushed onto the system stack
; returns: none
; preconditions: the array contains ARRAYSIZE elements; title, comma, and space strings are null-terminated
; registers changed: none
WriteArray PROC
  push  EBP
  mov   EBP, ESP
  push  EBX
  push  EDX
  push  EDI
  push  ECX

  mov   EDI, [EBP+8]          ; Address of the array
  mov   ECX, ARRAYSIZE		    ; Number of elements in the array

  ; Write Results
  mov   EDX, [EBP+12]
  mDisplayString EDX          ; Title to print for the array

  xor   EDX, EDX              ; Initialize index to 0

_printLoop:
  cmp   EDX, ECX              ; Compare index with the number of elements
  jge   _endPrintLoop		      ; If index >= number of elements, exit loop

  mov   EBX, [EDI + EDX * 4]  ; Copy the array element to the EBX register
  push  [EBP+16]
  push  EBX
  call  WriteVal			        ; Print the number

  inc   EDX					          ; Increment the index

  cmp   EDX, ECX			        ; Compare index with the number of elements
  jge   _endPrintLoop		      ; If index >= number of elements, exit loop

  ; Print the comma and space
  mDisplayString  [EBP+20]	  ; Print comma
  mDisplayString  [EBP+24]	  ; Print space

  jmp   _printLoop         

_endPrintLoop:

  pop   ECX
  pop   EDI
  pop   EDX
  pop   EBX
  pop   EBP
  ret   20
WriteArray ENDP

; -- FindSum --
; Calculates the sum of the elements in an integer array and writes the result to the output
; receives: the address of the array, address of an SDWORD to store the sum, title string, and address of outBuffer are pushed onto the system stack
; returns: none
; preconditions: the array contains ARRAYSIZE elements; title string is null-terminated; outBuffer is an array of characters with a size defined by BUFFER_SIZE
; registers changed: none
FindSum PROC
  push  EBP
  mov   EBP, ESP
  push	EBX
  push	EDX
  push	EDI
  push	ECX

  mov	  EDI, [EBP+8]		      ; Address of the array
  mov	  EBX, [EBP+12]		      ; Address of an SDWORD that will store the sum			
  mov	  ECX, ARRAYSIZE	      ; Number of elements in the array

  xor   EAX, EAX			        ; Initialize sum to 0
  xor   EDX, EDX		      	  ; Initialize index to 0

_sumLoop:
  cmp   EDX, ECX			        ; Compare index with the number of elements
  jge   _endSumLoop			      ; If index >= number of elements, exit loop

  add   EAX, [EDI + EDX * 4]  ; Add the value of the array element to the sum 
  inc   EDX					          ; Increment the index

  jmp   _sumLoop        

_endSumLoop:
  mov   EBX, EAX			        ; Store the sum in the provided SDWORD variable
  
  ; Write Results
  mov	  EDX, [EBP+16]
  mDisplayString EDX		      ; Title to print for the sum

  push	[EBP+20]
  push	EBX
  call	WriteVal			        ; Print the sum

  pop	  ECX
  pop	  EDI
  pop	  EDX
  pop	  EBX
  pop	  EBP
  ret	  16
FindSum ENDP

; -- FindAverage --
; Calculates the truncated average of the elements in an integer array and writes the result to the output
; receives: the address of the array, address of an SDWORD to store the truncated average, title string, and address of outBuffer are pushed onto the system stack
; returns: none
; preconditions: the array contains ARRAYSIZE elements; title string is null-terminated; outBuffer is an array of characters with a size defined by BUFFER_SIZE
; registers changed: none
FindAverage PROC
  push  EBP
  mov   EBP, ESP
  push  EBX
  push  EDX
  push  EDI
  push  ECX

  mov   EDI, [EBP+8]		      ; Address of the array
  mov   EBX, [EBP+12]		      ; Address of an SDWORD that will store the truncated average
  mov   ECX, ARRAYSIZE		    ; Number of elements in the array

  xor   EAX, EAX			        ; Initialize average to 0
  xor   EDX, EDX			        ; Initialize index to 0

_sumLoop:
  cmp   EDX, ECX			        ; Compare index with the number of elements
  jge   _endSumLoop			      ; If index >= number of elements, exit loop

  add   EAX, [EDI + EDX * 4]  ; Add the value of the array element to the sum (scaled index addressing)
  inc   EDX					          ; Increment the index

  jmp   _sumLoop							

_endSumLoop:
  cdq                      
  idiv  ECX					          ; Divide EAX by the number of elements 
  mov   EBX, EAX			        ; Store the truncated average in the provided SDWORD variable
  
  ; Write Results
  mov   EDX, [EBP+16]
  mDisplayString EDX		      ; Title to print for the average

  push  [EBP+20]
  push  EBX
  call  WriteVal		        	; Print the truncated average
							                ; I realized I could have used the sum instead of looping.

  pop   ECX
  pop   EDI
  pop   EDX
  pop   EBX
  pop   EBP
  ret   16
FindAverage ENDP

; -- Introduction --
; Displays Introduction message
; receives: address of intro1, intro2, and intro3, and outBuffer is pushed onto the system stack
; returns: none
; preconditions: intro1, intro2, and intro3 are strings. ARRAYSIZE is a constant and an integer. 
; registers changed: none
Introduction PROC
  push  EBP         
  mov   EBP, ESP 
  push	EDX

  mov   EDX, [EBP+8]      
  mDisplayString EDX		  ; "Please provide"
  mov   EDX, [EBP+12]      
  mDisplayString EDX		  ; " signed decimal integers."
  push	[EBP+20]
  push	OFFSET ARRAYSIZE	; Size of the array
  call	WriteVal	
  mov   EDX, [EBP+16]      
  mDisplayString EDX		  ; "Rest of the introduction"

  pop	  EDX
  pop   EBP
  ret	  16
Introduction ENDP

; -- Farewell --
; Displays Farewell message
; receives: address of goodBye is pushed onto the system stack
; returns: none
; preconditions: goodbye is a string that says goodbye to user
; registers changed: none
Farewell PROC
  push  EBP         
  mov   EBP, ESP 
  push	EDX

  mov   EDX, [EBP+8]      
  mDisplayString EDX		; "Thanks for using my program"

  pop	  EDX
  pop   EBP
  ret	  8
Farewell ENDP

END main