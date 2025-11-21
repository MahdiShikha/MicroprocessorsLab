#include <xc.inc>
extrn   SPI1_Init, DAC_WriteWord
extrn   DAC_high, DAC_low

psect   code, abs
rst:    org 0x0000
        goto start

        org 0x0100
start:
        call    SPI1_Init

        ; Example 1: mid-scale (~0.5 * Vref)
        movlw   0x80
        movwf   DAC_high, A
        movlw   0x00
        movwf   DAC_low, A
        call    DAC_WriteWord

        ; Now change it after a bit if you like
        ; (add a crude delay loop here)
        ; movlw 0xFF
        ; movwf DAC2_hi, A
        ; movlw 0xFF
        ; movwf DAC2_lo, A
        ; call DAC2_WriteWord

        goto    $

        end rst