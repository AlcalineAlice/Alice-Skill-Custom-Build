.thumb
.macro blh to, reg=r3
  ldr \reg, =\to
  mov lr, \reg
  .short 0xf800
.endm

.equ CancelID, SkillTester+4
.equ CancelPlusID, CancelID+4
.equ d100Result, 0x802a52c
.equ NextRN_100, 0x8000C64

@ r0 is attacker, r1 is defender, r2 is current buffer, r3 is battle data
push {r4-r7,lr}
mov r4, r0 @attacker
mov r5, r1 @defender
mov r6, r2 @battle buffer
mov r7, r3 @battle data
ldr     r0,[r2]           @r0 = battle buffer                @ 0802B40A 6800     
lsl     r0,r0,#0xD                @ 0802B40C 0340     
lsr     r0,r0,#0xD        @Without damage data                @ 0802B40E 0B40     
@ mov r1, #0xC0 @skill flag
@ lsl r1, #8 @0xC000
mov r1, #2 @miss @@@@OR BRAVE??????
tst r0, r1
bne End
//@if another skill already activated, don't do anything

//@check if we're already in astra
//ldrb r0, [r2, #4] @active skill
//@make sure no other skill is active
//cmp r0, #0
//bne End

@check if unit has CancelPlus, i.e. doesn't need to check for proc
ldr r0, SkillTester
mov lr, r0
mov r0, r4 @attacker data
ldr r1, CancelPlusID
.short 0xf800
cmp r0, #0
beq CancelCheck
@This will be useful for an edge case later
mov r3, #1

@Set CancelPlus to proc
ldrb r0, CancelPlusID
strb r0, [r6,#4] @save the skill ID at byte #4
b Proc

CancelCheck:
@otherwise, check for Cancel proc
ldr r0, SkillTester
mov lr, r0
mov r0, r4 @attacker data
ldr r1, CancelID
.short 0xf800
cmp r0, #0
beq End
@if user has Cancel, check for proc rate

ldrb r0, [r4, #0x16] @speed stat as activation rate
mov r1, r4 @skill user
blh d100Result
cmp r0, #1
bne End 

@Set Cancel to proc
ldrb r0, CancelID
strb r0, [r6,#4] @save the skill ID at byte #4

//Proc:
//@if we proc, set the offensive skill for the attacker and the no counter flag for the defender
//ldr     r2,[r6]    
//lsl     r1,r2,#0xD                @ 0802B42C 0351     
//lsr     r1,r1,#0xD                @ 0802B42E 0B49     
//mov     r0, #0x40              @Set the flags
//lsl     r0, #8  
//orr     r1, r0
//ldr     r0,=#0xFFF80000                @ 0802B434 4804     
//and     r0,r2                @ 0802B436 4010     
//orr     r0,r1                @ 0802B438 4308     
//str     r0,[r6]                @ 0802B43A 6018

mov     r0, #0x20              @Make next round (defender's attack) not occur
orr     r1, r0
ldr     r0,=#0xFFF80000                @ 0802B434 4804     
and     r0,r2                @ 0802B436 4010     
orr     r0,r1                @ 0802B438 4308     
str     r0, [r6, #8]

@This is the bit where we handle that edge case
cmp     r3, #1
bne     End
mov     r2, #0x5E
ldrh    r0, [r4, r2] @AS
ldrh    r1, [r5, r2]
sub     r1, r0
cmp     r1, #5
blt     End

ldr     r2,[r6]    
lsl     r1,r2,#0xD                @ 0802B42C 0351     
lsr     r1,r1,#0xD                @ 0802B42E 0B49     
mov     r0, #0x80              @Set the flags
lsl     r0, #16  
orr     r1, r0
ldr     r0,=#0xFFF80000                @ 0802B434 4804     
and     r0,r2                @ 0802B436 4010     
orr     r0,r1                @ 0802B438 4308     
str     r0,[r6, #8]                @ 0802B43A 6018

End:
pop {r4-r7}
pop {r15}

.align
.ltorg
SkillTester:
@POIN SkillTester
@WORD CancelID
@WORD CancelPlusID
