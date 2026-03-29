.thumb

.macro blh to, reg=r3
  ldr \reg, =\to
  mov lr, \reg
  .short 0xF800
.endm

.equ StaunchResID, SkillTester+4
.equ GetDebuffsPtr, StaunchResID+4

StaunchRes:
  push {lr}

  ldrb r0, [r4, #0x13]
  cmp  r0, #0
  beq  End

  ldrb r0, [r6, #0x11]
  cmp  r0, #1
  bne  End

  ldrb r0, [r6, #0x0C]
  ldrb r1, [r4, #0x0B]
  cmp  r0, r1
  bne  End

  mov  r0, r4
  ldr  r1, StaunchResID
  ldr  r3, SkillTester
  mov  lr, r3
  .short 0xF800
  cmp  r0, #0
  beq  End

  mov  r0, r4
  ldr  r3, GetDebuffsPtr
  mov  lr, r3
  .short 0xF800
  mov  r3, r0

  ldrb r0, [r3, #3]
  mov  r1, #0x10
  orr  r0, r1
  strb r0, [r3, #3]

End:
  pop {r0}
  bx r0

.ltorg
.align

SkillTester:
  @ POIN SkillTester
  @ WORD StaunchStrID
  @ POIN GetDebuffs
