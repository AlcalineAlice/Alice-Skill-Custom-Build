#include "global.h"
#include "anime.h"
#include "ekrbattle.h"
#include "efxbattle.h"
#include "ekrdragon.h"
#include "proc.h"
#include "bmlib.h"
#include "hardware.h"

#include "BanimUtils.h"

void EfxCallDkBaseHide(struct ProcEfxBmExpa * proc)
{
    NewEkrDragonBaseHide(proc->anim);
}

void EfxCallDkCustomBgFadeIn(struct ProcEfxBmExpa * proc)
{
    int ret = Interpolate(INTERPOLATE_SQUARE, 4, 0x10, proc->timer, 8);
    EfxChapterMapFadeOUT(ret);
    if (++proc->timer == 0x9)
    {
        proc->timer = 0;
        Proc_Break(proc);
    }
}

void EfxCallDkMain(struct ProcEfxBmExpa * proc)
{
    if (proc->timer == 0x2)
    {
        SetEkrDragonStatusType(gAnims[0], EKRDRGON_TYPE_DEMON_KING);
        Fill16_EkrTsaBuffer_(1);
        EfxTmFill(0x60016001);
        BG_Fill(gBG3TilemapBuffer, 1);
        BG_EnableSyncByMask(BG3_SYNC_BIT);
        Decompress(Img_DemonKingBG, (void *)0x06008000);
        Decompress(Tsa_DemonKingBG1, gEkrTsaBuffer);
        EkrDragonTmCpyHFlip(0x90, 0);
        EkrDragonTmCpyExt(gEkrBgPosition, 0);

        // Some align issue exits for C
        // why ?
        EfxDragonSetBgPriorityASM(0, 1, 3, 2);

        CpuFastCopy(Pal_DemonKingBG, PAL_BG(6), 0x20);
        EnablePaletteSync();

        SetBlackPal(0x6);
        StartPalFade(Pal_DemonKingBG, 6, 0x78, proc);
    }

    if (++proc->timer == 0x7E)
        Proc_Break(proc);
}

void EfxCallDkOnEnd(struct ProcEfxBmExpa * proc)
{
    struct Anim * anim = proc->anim;
    struct Anim * anim1 = gAnims[GetAnimPosition(anim) * 2];
    struct Anim * anim2 = gAnims[GetAnimPosition(anim) * 2 + 1];

    SetAnimStateUnfrozen(anim);
    SetAnimStateUnfrozen(anim1);
    SetAnimStateUnfrozen(anim2);

    anim->state3 |= ANIM_BIT3_BLOCKEND;
}

const struct ProcCmd ProScr_EfxCallDK[] = {
    PROC_NAME("efxCallDK"),
    PROC_YIELD,
    PROC_CALL(EfxCallDkBaseHide),
    PROC_REPEAT(EfxCallDkCustomBgFadeIn),
    PROC_REPEAT(EfxCallDkMain),
    PROC_CALL(EfxCallDkOnEnd),
    PROC_END
};

void NewEfxCallDk(struct Anim * anim)
{
    struct ProcEfxBmExpa * proc;
    struct Anim * anim1, * anim2;
    proc = Proc_Start(ProScr_EfxCallDK, PROC_TREE_3);
    proc->anim = anim;
    proc->timer = 0;

    anim1 = gAnims[GetAnimPosition(anim) * 2];
    anim2 = gAnims[GetAnimPosition(anim) * 2 + 1];

    SetAnimStateFrozen(anim);
    SetAnimStateFrozen(anim1);
    SetAnimStateFrozen(anim2);
}

void BanimCmd_CallDK(struct Anim * anim)
{
    anim->pScrCurrent = anim->pScrCurrent - 1;

    if (!(anim->state3 & ANIM_BIT3_BLOCKING))
    {
        anim->state3 |= ANIM_BIT3_BLOCKING;
        if (GetAISLayerId(anim) == 0)
            NewEfxCallDk(anim);
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
