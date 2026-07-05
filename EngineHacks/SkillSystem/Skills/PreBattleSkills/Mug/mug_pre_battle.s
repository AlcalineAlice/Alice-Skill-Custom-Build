.macro blh to, reg=r3
  ldr \reg, =\to
  mov lr, \reg
  .short 0xF800
.endm

.equ MugID,        SkillTester+4

.thumb
push {r4-r7, lr}

@----------------------------------------------------
@ r4 = attacker, r5 = defender, r6 = battle struct
@----------------------------------------------------
mov r4, r0          @ attacker
mov r5, r1          @ defender
mov r6, r2          @ battle struct

@----------------------------------------------------
@ 1. Check attacker has Mug
@----------------------------------------------------
mov r0, r4
ldr r1, MugID
ldr r3, SkillTester
mov lr, r3
.short 0xF800
cmp r0, #0
beq NoMug

@----------------------------------------------------
@ 2. Scan defender inventory BEFORE death
@   (simple: first non-empty slot)
@----------------------------------------------------
mov r7, r5              @ defender pointer
mov r2, #0              @ slot index
add r7, #0x1E           @ inventory start

FindItemLoop_Pre:
ldrb r1, [r7]           @ item ID
cmp  r1, #0
bne  FoundItem_Pre

add r7, #0x02           @ next slot
add r2, #1
cmp  r2, #5
blt  FindItemLoop_Pre

b NoMug                 @ no items → no Mug

FoundItem_Pre:
@----------------------------------------------------
@ 3. Store item ID into slot 3
@----------------------------------------------------
ldr r0, =0x30004E0      @ slot 3
strb r1, [r0]

@----------------------------------------------------
@ 4. Set Mug flag in slot 14
@----------------------------------------------------
ldr r0, =0x30004DE      @ slot 14
mov r1, #1
strb r1, [r0]
b End_Pre

NoMug:
ldr r0, =0x30004DE      @ slot 14
mov r1, #0
strb r1, [r0]

End_Pre:
pop {r4-r7}
pop {r0}
bx r0

.ltorg
.align
SkillTester:
@POIN SkillTester
@WORD MugID
