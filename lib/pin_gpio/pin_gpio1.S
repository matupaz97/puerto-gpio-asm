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
    Push {R4-R6, LR}           // Guardo los registros en la pila
    ands R2, R1, #0xF
    cmp R2, #8
    bne 0f
    push {R0, R1}
    lsrs R1, #4
    bl Pin_escribe
    pop {R0, R1}
0:
    ldr R2, [R0, #Pin__puerto] // R2: base del puerto
    ldr R3, [R0, #Pin__numero] // R3: numero de pin
    cmp R3, #7                 // Comparo para saber si utilizo CRL o CRH
    bls 0f
    mov R5, #8                 // En caso de usar CRH, le restamos 8 al numero de pin para utilizarlo como pin de CRH
    mov R0, #CRH               // Le cargamos a R0 el offset correspondiente segun el caso
    b 1f
0:
    mov R0, #CRL
    mov R5, #0
1:
    ldr R6, [R2, R0]           // R6 sera el valor actual que posee el puerto
    subs R3, R5
    lsls R3, #2                // Multiplicamos el numero de pin por 4 debido a que cada pin utiliza 4 bits
    movs R4, #0xF              // R4: Mascara
    lsls R4, R3                // colocamos 1 en cada bit del pin elegido
    bics R6, R4                // Borramos solamente los bits del pin elegido
    ands R1, #0xF
    lsls R1, R3                // Movemos la configuracion para poder aplicar la mascara y solo cambiar la configuracion de nuestro pin
    orrs R6, R1
    str R0, [R2, R0]           // Guardamos el valor de la configuracion en el lugar correspondiente
    Pop {R4-R6, PC} // Devuelvo al los registros sus valores previos
    bx lr
endfun Pin_configura



defun Pin_escribe
    // R0: self, R1: valor
    ldr R2, [R0, #Pin__puerto] // R2: base del puerto
    ldr R3, [R0, #Pin__numero] // R3: numero de pin
    mov R0, #1
    lsls R0, R3
    cbz R1, 0f
    str R0, [R2, #BSRR]
    b 1f
0:
    str R0, [R2, #BRR]
1:
    bx lr
endfun Pin_escribe

defun Pin_lee
    // R0: self
    bx lr
    // R0: valor
endfun Pin_lee
defun Pin_leeSalida
    // R0: self
    bx lr
    // R0: valor
endfun Pin_leeSalida
