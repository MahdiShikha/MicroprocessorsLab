; =========================
; Minimal SPI2 demo (PIC18)
; RD4 = SDO2  -> 74HC164 A (data)
; RD6 = SCK2  -> 74HC164 CLK (rising-edge sample)
; =========================
#include <xc.inc>

; Scratch bytes
COUNT   EQU 0x21
TEMP    EQU 0x20

psect   code, abs
main:
    org 0x0
    goto start

    org 0x100

; -------------------------
; SPI2_Init
; CKP=1 (idle HIGH), CKE=0 (change on falling, stable on rising)
; Master, Fosc/64
; -------------------------
SPI2_Init:
    bcf   TRISD, 4, A            ; RD4 as output (SDO2)
    bcf   TRISD, 6, A            ; RD6 as output (SCK2)

    clrf  SSP2STAT, A            ; CKE=0, SMP=0, clear BF
    ; SSP2CON1: [WCOL SSPOV SSPEN CKP SSPM3 SSPM2 SSPM1 SSPM0]
    ;                         1     1     0     0     1     0  = 0x32
    movlw 0x32
    movwf SSP2CON1, A            ; Enable SPI2, CKP=1, Master Fosc/64
    return

; -------------------------
; SPI2_SendByte
; IN: W = byte to transmit (MSB first)
; HW auto-generates 8 clocks on RD6 and shifts out on RD4
; -------------------------
SPI2_SendByte:
    movwf SSP2BUF, A             ; start transfer
Wait_BF:
    btfss SSP2STAT, 0, A         ; BF bit set when done
    bra   Wait_BF
    movf  SSP2BUF, W, A          ; dummy read to clear BF
    return

; -------------------------
; Crude delay ~milliseconds (tune constants for your Fosc)
; IN: W ~= ms
; -------------------------
Delay_ms:
    movwf COUNT, A
D1: movlw 0xFF
    movwf TEMP, A
D2: nop
    nop
    decfsz TEMP, F, A
    bra   D2
    decfsz COUNT, F, A
    bra   D1
    return

; -------------------------
; Main demo: send 0xAA, 0x55 alternately
; LEDs will "jump" between two patterns
; -------------------------
start:
    rcall SPI2_Init

Demo:
    movlw 0x55
    rcall SPI2_SendByte
    movlw 0xFF
    rcall Delay_ms
    
    movlw 0xAA
    rcall SPI2_SendByte
    movlw 0xFF
    rcall Delay_ms

    bra Demo
    end