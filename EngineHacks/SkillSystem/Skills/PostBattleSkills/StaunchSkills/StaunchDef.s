.thumb

.macro blh to, reg=r3
  ldr \reg, =\to
  mov lr, \reg
  .short 0xF800
.endm

@ Layout of EALiterals (like Witch's Brew style):
@ SkillTester:
@   POIN SkillTester
@   WORD StaunchDefID
@   POIN GetDebuffs

.equ SkillTesterPtr, SkillTester      @ points to POIN SkillTester
.equ StaunchDefID, SkillTester+4      @ WORD StaunchDefID
.equ GetDebuffsPtr, SkillTester+8     @ POIN GetDebuffs

@ r4 = unit
@ r6 = gActionData

StaunchDef:
  push {lr}

  @ if dead, do nothing
  ldrb r0, [r4, #0x13]
  cmp  r0, #0
  beq  StaunchEnd

  @ check action == Wait (gActionData+0x11 == 1)
  ldrb r0, [r6, #0x11]
  cmp  r0, #0x01
  bne  StaunchEnd

  @ check same unit (allegiance byte)
  ldrb r0, [r6, #0x0C]   @ acting unit allegiance
  ldrb r1, [r4, #0x0B]   @ this unit allegiance
  cmp  r0, r1
  bne  StaunchEnd

  @ check for StaunchDef skill
  mov  r0, r4
  ldr  r1, StaunchDefID
  ldr  r3, SkillTesterPtr
  ldr  r3, [r3]          @ load actual SkillTester pointer
  mov  lr, r3
  .short 0xF800
  cmp  r0, #0
  beq  StaunchEnd

  @ get debuff struct for this unit
  mov  r0, r4
  ldr  r3, GetDebuffsPtr
  ldr  r3, [r3]          @ load actual GetDebuffs pointer
  mov  lr, r3
  .short 0xF800
  mov  r3, r0            @ r3 = debuff pointer

  @ set StaunchDef bit (0x40) in byte 3
  ldrb r0, [r3, #3]
  mov  r1, #0x40         @ StaunchDef flag
  orr  r0, r1
  strb r0, [r3, #3]

StaunchEnd:
  pop {r0}
  bx  r0

  .align

SkillTester:
  @ EALiterals filled by EA:
  @ POIN SkillTester
  @ WORD StaunchDefID
  @ POIN GetDebuffs
