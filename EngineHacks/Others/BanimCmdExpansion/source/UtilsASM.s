.thumb

.include "macros.inc"

@ r0 = bg0 priority
@ r2 = bg1 priority
@ r3 = bg2 priority
@ r4 = bg3 priority

THUMB_FUNC_START EfxDragonSetBgPriorityASM
EfxDragonSetBgPriorityASM:
    push {r4, r5, r6, lr}
    mov r4, r0
    mov r5, r1
    mov r6, r2

    ldr r2, =gLCDControlBuffer

    @ gLCDControlBuffer.bg0cnt.priority = 0;
    ldr r0, [r2, #0xC]
    ldr r1, =0xFFFFFFFC
    and r0, r0, r1
    mov r1, r4
    orr r0, r0, r1
    str r0, [r2, #0xC]

    @ gLCDControlBuffer.bg1cnt.priority = 1;
    ldr r0, [r2, #0x10]
    ldr r1, =0xFFFFFFFC
    and r0, r0, r1
    mov r1, r5
    orr r0, r0, r1
    str r0, [r2, #0x10]

    @ gLCDControlBuffer.bg2cnt.priority = 3;
    ldr r0, [r2, #0x14]
    ldr r1, =0xFFFFFFFC
    and r0, r0, r1
    mov r1, r6
    orr r0, r0, r1
    str r0, [r2, #0x14]

    @ gLCDControlBuffer.bg3cnt.priority = 2;
    ldr r0, [r2, #0x18]
    ldr r1, =0xFFFFFFFC
    and r0, r0, r1
    mov r1, r3
    orr r0, r0, r1
    str r0, [r2, #0x18]

    pop {r4, r5, r6, pc}
