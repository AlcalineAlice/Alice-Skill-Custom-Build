#pragma once

#include "global.h"
#include "proc.h"
#include "anime.h"

struct ProcEfxBmExpa {
    PROC_HEADER;

    short timer;
    u32 frame;
    const s16 * frame_config;
    u16 const * const * imgs;
    u16 const * const * tsas;
    u16 const * const * pals;
    s8 blocking;

    struct Anim * anim;
};

void SetAnimStateFrozen(struct Anim *anim);
void SetAnimStateUnfrozen(struct Anim *anim);
void EfxDragonSetBgPriorityASM(int b0, int b1, int b2, int b3);

extern const s16 FrameLut_Duma[];
extern u16 const * const ImgLut_Duma[15];
extern u16 const * const TsaLut_Duma[15];
extern u16 const * const PalLut_Duma[15];

extern struct Anim * gAnims[4];
void EkrDragonTmCpyHFlip(int a, int b);
