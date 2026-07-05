.thumb

.macro blh to, reg=r3
  ldr \reg, =\to
  mov lr, \reg
  .short 0xF800
.endm

.equ MugPendingDropFlag, 0x03003F48
.equ MugID, SkillTester+4   @ same definition you used in PreBattle

push {lr}

@ --------------------------------------------------------------------
@ NEW: Skill check to ensure only units with Mug trigger PostBattle
@ attacker BattleUnit = r4
mov  r0, r4
ldr  r1, MugID
ldr  r3, SkillTester
mov  lr, r3
.short 0xF800
cmp  r0, #0
beq  EndPost
@ --------------------------------------------------------------------

@ check pending flag
ldr  r1, =MugPendingDropFlag
ldrb r0, [r1]
cmp  r0, #1
bne  EndPost

@ call MugEvent
Event:
ldr r0, =0x800D07C      @ event engine
mov lr, r0
ldr r0, MugEventPointer @ load patched pointer
mov r1, #0x01           @ wait for events
.short 0xF800

@ clear flag properly
ldr r1, =MugPendingDropFlag
mov r0, #0
strb r0, [r1]

EndPost:
pop  {r0}
bx   r0

.ltorg
.align
SkillTester:
@POIN SkillTester
@WORD MugID
MugEventPointer:
@POIN MugEvent
