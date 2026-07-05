.thumb

.macro blh to, reg=r3
  ldr \reg, =\to
  mov lr, \reg
  .short 0xF800
.endm

.equ MugPendingDropFlag, 0x03003F48

push {lr}

@ check pending flag
ldr  r1, =MugPendingDropFlag
ldrb r0, [r1]
cmp  r0, #1
bne  EndPost

@ call event engine (same pattern as Despoil)
ldr  r0, =0x800D07C      @ EventEngine
mov  lr, r0
ldr  r0, =MugEvent       @ pointer from literal pool (EA will patch)
mov  r1, #0x01           @ wait for events
.short 0xF800

@ clear flag
mov  r0, #0
strb r0, [r1]

EndPost:
pop  {r0}
bx   r0

.ltorg
.align
SkillTester:
@POIN SkillTester
@WORD MugID
@POIN MugEvent
