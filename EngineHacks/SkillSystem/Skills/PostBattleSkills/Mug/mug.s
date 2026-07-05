.macro blh to, reg=r3
  ldr \reg, =\to
  mov lr, \reg
  .short 0xF800
.endm

.equ MugID, SkillTester+4

.thumb
push {lr}

@check if dead (attacker must be alive)
ldrb  r0, [r4,#0x13]
cmp   r0, #0x00
beq   End

@check if attacked this turn
ldrb  r0, [r6,#0x11]    @ action taken this turn
cmp   r0, #0x2          @ 2 = attack
bne   End
ldrb  r0, [r6,#0x0C]    @ allegiance of acting unit
ldrb  r1, [r4,#0x0B]    @ allegiance of attacker
cmp   r0, r1
bne   End

@check for inventory space, but only if not a player unit
cmp   r1, #0x40
blo   SkipInventoryCheck

ldr   r0, =0x80179D8    @ inventory space check routine
mov   lr, r0
mov   r0, r4            @ attacker
.short 0xF800
cmp   r0, #0x04
bhi   End
SkipInventoryCheck:

@check if killed enemy
ldrb  r0, [r5,#0x13]    @ defender currhp
cmp   r0, #0
bne   End

@check for Mug skill
mov   r0, r4
ldr   r1, MugID
ldr   r3, SkillTester
mov   lr, r3
.short 0xF800
cmp   r0, #0x00
beq   End

@killed enemy, roll luck
ldr   r0, =0x8019298    @ luck getter
mov   lr, r0
mov   r0, r4            @ attacker
.short 0xF800
ldr   r2, =0x802A52C    @ 1RN routine
mov   r1, r4            @ attacker
mov   lr, r2
.short 0xF800
cmp   r0, #0x01
bne   End

@successful roll, set defender drop flag (byte 0x4A)
Event:
    mov  r1, r5          @ r1 = defender pointer
    add  r1, #0x40       @ r1 += 0x40
    add  r1, #0x0A       @ r1 += 0x0A → total +0x4A
    ldrb r0, [r1]
    mov  r2, #0x01
    orr  r0, r2
    strb r0, [r1]

End:
pop   {r0}
bx    r0

.ltorg
.align
SkillTester:
@POIN SkillTester
@WORD MugID
