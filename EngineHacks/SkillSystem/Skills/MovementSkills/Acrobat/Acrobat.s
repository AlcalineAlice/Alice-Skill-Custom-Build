.thumb
.org 0x0

.equ AcrobatID, SkillChecker+4
.equ AcrobatMinusID, AcrobatID+4
.equ FlierID, AcrobatMinusID+4

@r0=movement cost table. Function originally at 1A4CC, now jumped to here (jumpToHack)
push  {r4,r5,r14}
mov   r4,r0
ldr   r0,SkillChecker
mov   r14,r0
ldr   r0,CurrentCharPtr
ldr   r0,[r0]
cmp   r0, #0
bne   LoadFlier       @ No danger zone
mov   r0, r2          @ If the active unit is 0, we're being called from dangerzone

LoadFlier:
ldr   r1,FlierID
.short  0xF800
mov   r1,#0x0          @ counter
ldr   r5,MoveCostLoc
cmp   r0, #0x0         @ Check for Flier here
beq   LoadAcrobat      @ Unit doesn't have it, so check for Acrobat
ldr   r4,FlierMovementCostTable
b     StoreRegularMovementCostLoop      @ Unit has the Flier skill

LoadAcrobat:
ldr   r0,SkillChecker
mov   r14,r0
ldr   r1,AcrobatID
.short  0xF800
mov   r1,#0x0          @ counter
ldr   r5,MoveCostLoc
cmp   r0, #0x0         @ Check for Acrobat here
beq   LoadAcrobatMinus @ Unit doesn't have it, so check for AcrobatMinus
b     AcrobatLoop      @ Unit has it, so branch to Acrobat movement cost loop 

LoadAcrobatMinus:
ldr   r0,SkillChecker
mov   r14,r0
ldr   r1,AcrobatMinusID
.short  0xF800
mov   r1,#0x0          @ counter
ldr   r5,MoveCostLoc
cmp   r0, #0x0         @ Check for AcrobatMinus here
beq   StoreRegularMovementCostLoop
b     AcrobatMinusLoop

AcrobatLoop:
add   r2,r4,r1
add   r3,r5,r1
ldrb  r2,[r2]
cmp   r2,#0xFF 
beq   StoreAcrobatMovementCost @ Cannot traverse this tile normally
mov   r2,#0x1                  @ Otherwise set the movement cost to 1
b     StoreAcrobatMovementCost

AcrobatMinusLoop:
add   r2,r4,r1
add   r3,r5,r1
ldrb  r2,[r2]
cmp   r2,#0xFF 
beq   StoreAcrobatMinusMovementCost @ Cannot traverse this tile normally
cmp   r2,#1                         
ble   StoreAcrobatMinusMovementCost @ Store tile cost if it is already 1
sub   r2,#0x1                       @ Otherwise subtract 1 from the movement cost
b     StoreAcrobatMinusMovementCost

StoreAcrobatMovementCost:
strb  r2,[r3]
add   r1,#0x1
cmp   r1,#0x40
ble   AcrobatLoop       @ We have more tiles to check
b     End               @ Otherwise, we've checked all tiles in range of unit's movement path

StoreAcrobatMinusMovementCost:
strb  r2,[r3]
add   r1,#0x1
cmp   r1,#0x40
ble   AcrobatMinusLoop  @ We have more tiles to check
b     End               @ Otherwise, we've checked all tiles in range of unit's movement path

StoreRegularMovementCostLoop:
add   r2,r4,r1
add   r3,r5,r1
ldrb  r2,[r2]
strb  r2,[r3]
add   r1,#0x1
cmp   r1,#0x40
ble   StoreRegularMovementCostLoop  @ We have more tiles to check
b     End                           @ Otherwise, we've checked all tiles in range of unit's movement path

End:
pop   {r4-r5}
pop   {r0}
bx    r0

.align
CurrentCharPtr:
.long 0x03004E50
MoveCostLoc:
.long 0x03004BB0
FlierMovementCostTable:
.long 0x0880BB96 @Not sure if this location is set in stone?
SkillChecker:
@POIN SkillChecker
@WORD AcrobatID
