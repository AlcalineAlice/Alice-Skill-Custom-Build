#include "global.h"
#include "anime.h"
#include "ekrbattle.h"
#include "efxbattle.h"
#include "ekrdragon.h"
#include "proc.h"
#include "bmlib.h"
#include "hardware.h"

#include "BanimUtils.h"

const s16 FrameLut_EfxCallDuma[] = {
    /* FrameIndex   Duration */
    0,              1,
    1,              1,
    2,              1,
    3,              2,
    4,              2,
    5,              2,
    6,              2,
    7,              2,
    8,              3,
    9,              3,
    10,             3,
    11,             3,
    12,             4,
    13,             4,
    14,             4,
    -1,
};

void EfxCallDumaBaseHide(struct ProcEfxBmExpa * proc)
{
    NewEkrDragonBaseHide(proc->anim);
}

void EfxCallDumaCustomBgFadeIn(struct ProcEfxBmExpa * proc)
{
    int ret = Interpolate(INTERPOLATE_SQUARE, 4, 0x10, proc->timer, 8);
    EfxChapterMapFadeOUT(ret);
    if (++proc->timer == 0x9)
    {
        proc->timer = 0;
        Proc_Break(proc);
    }
}

// unused
#if 0
void EfxCallDumaBG1(struct ProcEfxBmExpa * proc)
{
    int i;

    // SpellFx_WriteBgMap(proc->anim, TsaLut_Duma[4], TsaLut_Duma[4]);
    LZ77UnCompWram(TsaLut_Duma[4], gEkrTsaBuffer);
    sub_8070EC4(gEkrTsaBuffer, gBG1TilemapBuffer, 0x1E, 0x14, 1, 0x100);
    BG_EnableSyncByMask(BG1_SYNC_BIT);

    // SpellFx_RegisterBgGfx(ImgLut_Duma[4], 0x2000);
    LZ77UnCompWram(ImgLut_Duma[4], gSpellAnimBgfx);
    RegisterDataMove(gSpellAnimBgfx, (void *)BG_VRAM + 0x2000, 0x2000);

    // SpellFx_RegisterBgPal(PalLut_Duma[4], 0x20);
    CpuFastCopy(PalLut_Duma[4], PAL_BG(1), 0x20);
    EnablePaletteSync();

    for (i = 0; i < 0x14; i++)
    {
        gBG1TilemapBuffer[0x20 * i + 0x1E] = gBG1TilemapBuffer[0];
        gBG1TilemapBuffer[0x20 * i + 0x1F] = gBG1TilemapBuffer[0];
    }
    SpellFx_SetSomeColorEffect();
}
#endif

void EfxCallDumaBG3Start(struct ProcEfxBmExpa * proc)
{
    SetEkrDragonStatusType(gAnims[0], EKRDRGON_TYPE_DEMON_KING);

#if 0
    gLCDControlBuffer.bg0cnt.priority = 0;
    gLCDControlBuffer.bg1cnt.priority = 1;
    gLCDControlBuffer.bg2cnt.priority = 3;
    gLCDControlBuffer.bg3cnt.priority = 2;
#else
    EfxDragonSetBgPriorityASM(0, 1, 3, 2);
#endif
}

void EfxCallDumaBG3(struct ProcEfxBmExpa * proc)
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

void EfxCallDumaOnEnd(struct ProcEfxBmExpa * proc)
{
    struct Anim * anim = proc->anim;
    struct Anim * anim1 = gAnims[GetAnimPosition(anim) * 2];
    struct Anim * anim2 = gAnims[GetAnimPosition(anim) * 2 + 1];

    SetAnimStateUnfrozen(anim);
    SetAnimStateUnfrozen(anim1);
    SetAnimStateUnfrozen(anim2);

    anim->state3 |= ANIM_BIT3_BLOCKEND;
}

const struct ProcCmd ProScr_EfxCallDuma[] = {
    PROC_NAME("efxCallDuma"),
    PROC_YIELD,
    PROC_CALL(EfxCallDumaBaseHide),
    PROC_REPEAT(EfxCallDumaCustomBgFadeIn),
    PROC_CALL(EfxCallDumaBG3Start),
    PROC_REPEAT(EfxCallDumaBG3),
    PROC_CALL(EfxCallDumaOnEnd),
    PROC_END
};

void NewEfxCallDuma(struct Anim * anim)
{
    struct ProcEfxBmExpa * proc;
    struct Anim * anim1, * anim2;
    proc = Proc_Start(ProScr_EfxCallDuma, PROC_TREE_3);
    proc->anim = anim;
    proc->timer = 0;
    proc->frame = 0;
    proc->frame_config = FrameLut_EfxCallDuma;
    proc->imgs = ImgLut_Duma;
    proc->tsas = TsaLut_Duma;
    proc->pals = PalLut_Duma;

    anim1 = gAnims[GetAnimPosition(anim) * 2];
    anim2 = gAnims[GetAnimPosition(anim) * 2 + 1];

    SetAnimStateFrozen(anim);
    SetAnimStateFrozen(anim1);
    SetAnimStateFrozen(anim2);
}

void BanimCmd_CallDuma(struct Anim * anim)
{
    anim->pScrCurrent = anim->pScrCurrent - 1;

    if (!(anim->state3 & ANIM_BIT3_BLOCKING))
    {
        anim->state3 |= ANIM_BIT3_BLOCKING;
        if (GetAISLayerId(anim) == 0)
            NewEfxCallDuma(anim);
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
