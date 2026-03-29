@Encumbered: If this unit is rescuing another unit who's CON is equal or higher than half this unit's AID, 
@            unit gets -1 Mov. The penalty changes to -2 if this unit has Mounted AID calc
.thumb

.equ GetUnit,0x08019430+1
.equ GetUnitAid, 0x80189B8+1

.type Encumbered, %function 
.global Encumbered 
Encumbered: 
push {r4-r7, lr} 
mov r4, r0 @ stat value
mov r5, r1 @ unit 

mov r0, r5 
ldr r1, =EncumberedID_Link 
ldr r1, [r1] 
bl SkillTester 
cmp r0, #0 
beq End

@ Get the rescuee unit struct
ldr r0, =GetUnit
mov r14, r0
mov r1, #0x1B
ldrb r0, [r5, r1]
mov r3, #0
cmp r0, r3
beq End @if the unit isn't rescuing, branch to end
.short 0xF800
@ unit struct pointer in r0
mov r7, r0

@Now load the rescuee unit's CON
ldr r0,  [r7, #0x0] 
ldrb r0, [r0, #0x13] @unit CON
ldr r1,  [r7, #0x04]
ldrb r1, [r1, #0x11] @class CON
add r0,  r1
ldrb r1, [r7, #0x1A] @CON bonus
mov r6,  r0 @r6 contains rescuee CON

@Now load the rescuer unit's AID
mov r0, r5
ldr r1, =GetUnitAid
mov r14, r1
.short 0xF800
lsr r0, #1 @r0 now has the rescuer's AID from the GetUnitAid function and we're dividing it by 2
cmp r0, r6 @compare the rescuer's AID/2 to the rescuee's CON
ble CheckForMount @if the halved AID is less than or equal to the CON, check for mount
b   End

@ Check if the rescuer is mounted
CheckForMount:
ldr		r0,[r5]         @load the unit's character data
ldr	    r0,[r0,#0x28]   @load the ability 1 bitfield
ldr		r1,[r5,#0x4]    @load the unit's class data
ldr	    r1,[r1,#0x28]   @load the ability 1 bitfield
orr		r0,r1           @perform an OR logical operation on the two bitfields
mov		r1,#0x1	        @add 1 to the a seperate register to compare it to the bitfield for mounted aid (which is 1)
tst		r0,r1           @compare them
bne		SubtractTwo     @if equal, the rescuer is mounted, subtract 2 from their movement
b       SubtractOne     @else subtract 1

SubtractOne:
mov	 r3, #0x01
b ApplySkill

SubtractTwo:
mov  r3, #0x02
b ApplySkill

@subtract bonus to movement value
ApplySkill:
sub r4, r3

End:
mov r0, r4 @ value 
mov r1, r5 @ unit 
pop {r4-r7} 
pop {r2} 
bx r2 
.ltorg



