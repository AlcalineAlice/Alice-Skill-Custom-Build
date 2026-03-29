.thumb

.macro blh to, reg=r3
  ldr \reg, =\to
  mov lr, \reg
  .short 0xF800
.endm

.equ StaunchDefID, SkillTester+4
.equ GetDebuffsPtr, StaunchDefID+4

StaunchDef:
  push {lr}

  @ if dead, do nothing
  ldrb r0, [r4, #0x13]
  cmp  r0, #0
  beq  End

  @ check if Wait was used
  ldrb r0, [r6, #0x11]   @ action taken
  cmp  r0, #1            @ Wait
  bne  End

  @ same unit?
  ldrb r0, [r6, #0x0C]   @ acting unit allegiance
  ldrb r1, [r4, #0x0B]   @ this unit allegiance
  cmp  r0, r1
  bne  End

  @ has StaunchDef?
  mov  r0, r4
  ldr  r1, StaunchDefID
  ldr  r3, SkillTester     @ POIN SkillTester
  mov  lr, r3
  .short 0xF800
  cmp  r0, #0
  beq  End

  @ get debuff struct
  mov  r0, r4
  ldr  r3, GetDebuffsPtr   @ POIN GetDebuffs
  mov  lr, r3
  .short 0xF800
  mov  r3, r0              @ r3 = debuff pointer

  @ --- SET STAUNCH DEF FLAG ---
  @ Use the SAME bit as Rally Def: 0x08 in byte 3
  ldrb r0, [r3, #3]
  mov  r1, #0x08
  orr  r0, r1
  strb r0, [r3, #3]
  @ ----------------------------

End:
  pop {r0}
  bx r0

  .ltorg
  .align

SkillTester:
  @ POIN SkillTester
  @ WORD StaunchDefID
  @ POIN GetDebuffs
