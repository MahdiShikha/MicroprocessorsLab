	#include <xc.inc>
	
psect	code, abs
main:
	org 0x0
	goto	setup
	
	org 0x100		    ; Main code starts here at address 0x100

	; ******* Programme FLASH read Setup Code ****  
setup:	
	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	goto	start
	; ******* My data and where to put it in RAM *
myTable:
	db	0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07
	db	0x18,0x29,0x56,0x33,0x71;Table with 8 bytes
	myArray EQU 0x400	; Address in RAM for data
	counter EQU 0x10	; Address of counter variable
	align	2		; ensure alignment of subsequent instructions 
	; ******* Main programme *********************
start:	
	lfsr	0, myArray	; Load FSR0 with address in RAM	
	movlw	low highword(myTable)	; address of data in PM
	movwf	TBLPTRU, A	; load upper bits to TBLPTRU
	movlw	high(myTable)	; address of data in PM
	movwf	TBLPTRH, A	; load high byte to TBLPTRH
	movlw	low(myTable)	; address of data in PM
	movwf	TBLPTRL, A	; load low byte to TBLPTRL
	movlw	13		; 8 bytes to read
	movwf 	counter, A	; our counter register
	movlw 0x00
	movwf TRISC		;set port c to output
	movlw 0xFF	    
	movwf TRISD		;set port d to input
loop:
        tblrd*+			; move one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0	; move read data from TABLAT to (FSR0), increment FSR0	
	movff 	TABLAT, PORTC
	;movlw	high(0xFFFF)
	;movwf	0x41, A
	;movlw	low(0xFFFF)
	;movwf	0x40, A
	movff PORTD, 0x41
	movlw 0xFF
	movwf 0x40, A
	call delay
	decfsz	counter, A	; count down to zero
	bra	loop		; keep going until finished
	
	goto	0
delay:
	movlw 0x00
dloop:	decf 0x40, f, A
	subwfb 0x41, f, A
	bc dloop
	return
	end	main
