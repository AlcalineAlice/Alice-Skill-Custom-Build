.thumb

.macro blh to, reg=r3
  ldr \reg, =\to
  mov lr, \reg
  .short 0xF800
.endm

.equ MugMemory,        0x03003F48   @ start of Mug memory block
.equ MugFlag,          MugMemory    @ byte 0
.equ MugItem,          MugMemory+2  @ halfword at offset 2
.equ MemorySlot3,      0x030004E8   @ vanilla item slot

push {lr}

@ check pending flag
ldr  r1, =MugFlag
ldrb r0, [r1]
cmp  r0, #1
bne  EndPost

@ ---------------------------------------------------------
@ NEW: clear MemorySlot3 BEFORE writing MugItem
ldr  r2, =MemorySlot3
mov  r0, #0
strh r0, [r2]
@ ---------------------------------------------------------

@ write MugItem into MemorySlot3 before running event
ldr  r1, =MugItem
ldrh r0, [r1]          @ r0 = MugItem (Slim Sword = 0x02)
ldr  r2, =MemorySlot3
strh r0, [r2]
@ ---------------------------------------------------------

@ call MugEvent
Event:
ldr r0, =0x800D07C      @ event engine
mov lr, r0
ldr r0, MugEventPointer @ load patched pointer
mov r1, #0x01           @ wait for events
.short 0xF800

@ ---------------------------------------------------------
@ clear entire MugMemory (flag + item)
ldr r1, =MugMemory
mov r0, #0
strb r0, [r1]          @ clear flag
strh r0, [r1, #2]      @ clear item
@ ---------------------------------------------------------

EndPost:
pop  {r0}
bx   r0

.ltorg
.align
MugEventPointer:
@POIN MugEvent
