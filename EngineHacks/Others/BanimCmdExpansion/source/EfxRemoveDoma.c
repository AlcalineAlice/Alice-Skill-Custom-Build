#include "global.h"
#include "anime.h"
#include "ekrbattle.h"
#include "efxbattle.h"
#include "ekrdragon.h"
#include "proc.h"
#include "bmlib.h"
#include "hardware.h"

#include "BanimUtils.h"

const s16 FrameLut_EfxRemoveDuma[] = {
    /* FrameIndex   Duration */
    14,             2,
    13,             2,
    12,             2,
    11,             2,
    10,             2,
    9,              2,
    8,              2,
    7,              2,
    6,              1,
    5,              1,
    4,              1,
    3,              1,
    2,              1,
    1,              1,
    0,              1,
    -1,
};

const struct ProcCmd ProScr_EfxRemoveDumaDragonStatus[] = {
    PROC_NAME("EfxRemoveDumaDragonStatus"),
    PROC_YIELD,
    PROC_REPEAT(EkrDK_ReloadTerrainEtc),
    PROC_REPEAT(EkrDK_ReloadCustomBgAndFadeOut),
    PROC_END
};

void EfxRemoveDumaDragonStatus(struct ProcEfxBmExpa * proc)
{
    struct ProcEkrDragon *edproc;
    edproc = Proc_StartBlocking(ProScr_EfxRemoveDumaDragonStatus, proc);
    edproc->timer = 0;
    edproc->anim = proc->anim;
}

void EfxRemoveDumaBG3(struct ProcEfxBmExpa * proc)
{
    int ret;
    ret = EfxAdvanceFrameLut(&proc->timer, (s16 *)&proc->frame, proc->frame_config);
    if (ret >= 0)
    {
        Decompress(proc->imgs[ret], gSpellAnimBgfx);
        RegisterDataMove(gSpellAnimBgfx, (void *)BG_VRAM + 0x8000, 0x2000);

        Fill16_EkrTsaBuffer_(1);
        BG_Fill(gBG3TilemapBuffer, 1);
        Decompress(proc->tsas[ret], gEkrTsaBuffer);
        EkrDragonTmCpyHFlip(0x80, 0);
        EkrDragonTmCpyExt(gEkrBgPosition, 0);

        CpuFastCopy(proc->pals[ret], PAL_BG(6), 0x20);
        EnablePaletteSync();
    }

    if (ret == -1)
    {
        proc->timer = 0;
        Proc_Break(proc);
        return;
    }
}

void EfxRemoveDumaOnEnd(struct ProcEfxBmExpa * proc)
{
    struct Anim * anim = proc->anim;
    struct Anim * anim1 = gAnims[GetAnimPosition(anim) * 2];
    struct Anim * anim2 = gAnims[GetAnimPosition(anim) * 2 + 1];

    SetAnimStateUnfrozen(anim);
    SetAnimStateUnfrozen(anim1);
    SetAnimStateUnfrozen(anim2);

    gBanimValid[GetAnimPosition(proc->anim)] = true;
    SetAnimStateUnHidden(GetAnimPosition(proc->anim));

    gEkrDragonStatusLeft.type = EKRDRGON_TYPE_NORMAL;
    gEkrDragonStatusRight.type = EKRDRGON_TYPE_NORMAL;

    anim->state3 |= ANIM_BIT3_BLOCKEND;
}

void EfxRemoveDumaOnExitBlocking(struct ProcEfxBmExpa * proc)
{
    if (proc->blocking)
        proc->anim->state3 |= ANIM_BIT3_BLOCKEND;
}

const struct ProcCmd ProScr_EfxRemoveDuma[] = {
    PROC_NAME("efxRemoveDuma"),
    PROC_YIELD,
    PROC_REPEAT(EfxRemoveDumaBG3),
    PROC_SLEEP(3),
    PROC_CALL(EfxRemoveDumaDragonStatus),
    PROC_YIELD,
    PROC_CALL(EfxRemoveDumaOnEnd),
    PROC_CALL(EfxRemoveDumaOnExitBlocking),
    PROC_END
};

void NewEfxRemoveDuma(struct Anim * anim)
{
    struct ProcEfxBmExpa * proc;
    struct Anim * anim1, * anim2;
    proc = Proc_Start(ProScr_EfxRemoveDuma, PROC_TREE_3);
    proc->anim = anim;
    proc->timer = 0;
    proc->frame = 0;
    proc->frame_config = FrameLut_EfxRemoveDuma;
    proc->imgs = ImgLut_Duma;
    proc->tsas = TsaLut_Duma;
    proc->pals = PalLut_Duma;
    proc->blocking = true;

    anim1 = gAnims[GetAnimPosition(anim) * 2];
    anim2 = gAnims[GetAnimPosition(anim) * 2 + 1];

    SetAnimStateFrozen(anim);
    SetAnimStateFrozen(anim1);
    SetAnimStateFrozen(anim2);
}

void BanimCmd_RemoveDuma(struct Anim * anim)
{
    anim->pScrCurrent = anim->pScrCurrent - 1;

    if (!(anim->state3 & ANIM_BIT3_BLOCKING))
    {
        anim->state3 |= ANIM_BIT3_BLOCKING;
        if (GetAISLayerId(anim) == 0)
            NewEfxRemoveDuma(anim);
    }
    else
    {
        if (anim->state3 & ANIM_BIT3_BLOCKEND)
        {
            anim->state3 &= ~ANIM_BIT3_BLOCKING;
            anim->state3 &= ~ANIM_BIT3_BLOCKEND;
            anim->pScrCurrent = anim->pScrCurrent + 1;
        }
    }
}

/* Non-blocking method */

void NewEfxRemoveDumaNonBlocking(struct Anim * anim)
{
    struct ProcEfxBmExpa * proc;
    proc = Proc_Start(ProScr_EfxRemoveDuma, PROC_TREE_3);
    proc->anim = anim;
    proc->timer = 0;
    proc->frame = 0;
    proc->frame_config = FrameLut_EfxRemoveDuma;
    proc->imgs = ImgLut_Duma;
    proc->tsas = TsaLut_Duma;
    proc->pals = PalLut_Duma;
    proc->blocking = false;
}

void BanimCmd_RemoveDumaNonBlocking(struct Anim * anim)
{
    if (GetAISLayerId(anim) == 0)
        NewEfxRemoveDumaNonBlocking(anim);
}
