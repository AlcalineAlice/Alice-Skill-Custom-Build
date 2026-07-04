.macro blh to, reg=r3
  ldr \reg, =\to
  mov lr, \reg
  .short 0xF800
.endm

.thumb
push {r4-r7, lr}

@----------------------------------------------------
@ r4 = attacker, r5 = defender, r6 = battle struct
@----------------------------------------------------
mov r4, r0
mov r5, r1
mov r6, r2

@----------------------------------------------------
@ 1. Check Mug flag (slot 14)
@----------------------------------------------------
ldr  r0, =0x30004DE     @ slot 14
ldrb r1, [r0]
cmp  r1, #1
bne  End_Post           @ Mug not triggered → exit

@----------------------------------------------------
@ 2. Check defender is dead
@----------------------------------------------------
ldrb r0, [r5, #0x13]    @ defender currHP
cmp  r0, #0
bne  End_ClearFlag      @ defender survived → clear flag, exit

@----------------------------------------------------
@ 3. Call MugEvent
@----------------------------------------------------
ldr  r0, =0x800D07C     @ event engine
mov  lr, r0
ldr  r0, [pc, #0x1C]   @ will load the EA‑appended MugEvent pointer
mov  r1, #1             @ wait for event
.short 0xF800

@----------------------------------------------------
@ 4. Clear Mug flag
@----------------------------------------------------
End_ClearFlag:
ldr  r0, =0x30004DE     @ slot 14
mov  r1, #0
strb r1, [r0]

End_Post:
pop {r4-r7}
pop {r0}
bx   r0

.ltorg
.align
MugEventPointer:
