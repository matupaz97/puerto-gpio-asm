// Cortex-M3 Devices Generic User Guide: https://developer.arm.com/documentation/dui0552/
// STM32f103xx Family Reference Manual: https://www.st.com/resource/en/reference_manual/cd00171190-stm32f101xx-stm32f102xx-stm32f103xx-stm32f105xx-and-stm32f107xx-advanced-arm-based-32-bit-mcus-stmicroelectronics.pdf
// STM32f103c8 Datasheet: https://www.st.com/resource/en/datasheet/stm32f103c8.pdf
// Procedure Call Standard for the Arm Architecture: https://github.com/ARM-software/abi-aa/blob/main/aapcs32/aapcs32.rst
.syntax unified
.cpu cortex-m3
.fpu softvfp
.thumb

.macro defun nombre
    .section .text.\nombre
    .global \nombre
    .type \nombre, %function
\nombre:
.endm
.macro endfun nombre
    .size \nombre, . - \nombre
.endm

.set Pin__puerto,0
.set Pin__numero,4

defun Pin_init
    // R0: self, R1: puerto, R2: numPin
    str R1,[R0,#Pin__puerto]
    str R2,[R0,#Pin__numero]
    bx lr
endfun Pin_init

.set CRL,0x00
.set CRH,0x04
.set IDR,0x08
.set ODR,0x0C
.set BSRR,0x10
.set BRR,0x14

defun Pin_configura
    // R0: self, R1: config
    push {R4,R5,LR}
    ands R5,R1,#0xF
    cmp R5,#0b1000
    bne 0f
    movs R4,R0
    ubfx R1,R1,#4,#1
    bl Pin_escribe
    movs R0,R4
0:
    ldrd R0,R1,[R0]
    cmp R1,#8
    itee lo
    movlo R4,#CRL
    movhs R4,#CRH
    subhs R1,#8
    lsls R1,#2
    cpsid i // Sección de configuración, lectura/modificación/escritura
    movs R2,#0xF
    lsls R2,R1
    ldr R3,[R0,R4]
    bics R3,R2
    movs R2,R5
    lsls R2,R1
    orrs R3,R2
    str R3,[R0,R4]
    cpsie i // fin sección de configuración, lectura/modificación/escritura
    pop {R4,R5,PC}
endfun Pin_configura



defun Pin_escribe
    // R0: self, R1: valor
    push {LR}
    movs R3,#(1<<16)
    cbz R1,0f
    movs R3,#1
0:
    ldrd R1,R2,[R0]
    lsls R3,R2
    str R3,[R1,#BSRR]
    pop {PC}
endfun Pin_escribe

defun Pin_lee
    // R0: self
    ldrd R0,R1,[R0]
    movs R2,#1
    lsls R1,R2,R1
    ldr R2,[R0,#IDR]
    movs R0,#0
    tst R2,R1
    it ne
    movne R0,#1
    bx lr
    // R0: valor
endfun Pin_lee
defun Pin_leeSalida
    // R0: self
    ldrd R0,R1,[R0]
    movs R2,#1
    lsls R1,R2,R1
    ldr R2,[R0,#ODR]
    movs R0,#0
    tst R2,R1
    it ne
    movne R0,#1
    bx lr
    // R0: valor
endfun Pin_leeSalida
