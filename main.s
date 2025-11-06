	#include <xc.inc>

psect	code, abs
	goto Start
SPI_MasterInit: ; Set Clock edge to negative
	bcf CKE2 ; CKE bit in SSP2STAT,
	; MSSP enable; CKP=1; SPI master, clock=Fosc/64 (1MHz)
	movlw (SSP2CON1_SSPEN_MASK)|(SSP2CON1_CKP_MASK)|(SSP2CON1_SSPM1_MASK)
	movwf SSP2CON1, A
	; SDO2 output; SCK2 output
	bcf TRISD, PORTD_SDO2_POSN, A ; SDO2 output
	bcf TRISD, PORTD_SCK2_POSN, A ; SCK2 output
	return
SPI_MasterTransmit: ; Start transmission of data (held in W)
	movwf SSP2BUF, A ; write data to output buffer
Wait_Transmit: ; Wait for transmission to complete
	btfss PIR2, 5 ; check interrupt flag to see if data has been sent
	bra Wait_Transmit
	bcf PIR2, 5 ; clear interrupt flag
	return
Table:
	db 0x01,0x02,0x04,0x08,0x10,0x20,0x40,0x80
	myArray EQU 0x400	; Address in RAM for data
	counter EQU 0x10	; Address of counter variable
	align	2		; ensure alignment of subsequent instructions
Start:
	lfsr	0, myArray	; Load FSR0 with address in RAM	
	movlw	low highword(Table)	; address of data in PM
	movwf	TBLPTRU, A	; load upper bits to TBLPTRU
	movlw	high(Table)	; address of data in PM
	movwf	TBLPTRH, A	; load high byte to TBLPTRH
	movlw	low(Table)	; address of data in PM
	movwf	TBLPTRL, A	; load low byte to TBLPTRL
	movlw	8		; 16 bytes to read
	movwf 	counter, A	; our counter register
loop:
	tblrd*+
	movf    TABLAT, W, A            ; put byte in WREG for transmit
	call    SPI_MasterTransmit      ; shifts 8 bits on SDO2 with SCK2
	
	decfsz  counter, A
	bra	loop
	
	goto    0