// SinglePlayer.asm
if !{defined __SINGLE_PLAYER__} {
define __SINGLE_PLAYER__()
print "included SinglePlayer.asm\n"

// @ Description
// This file allows new characters to use 1P and Bonus features.

// TODO
// Name textures for MM, GDK and polygons

include "OS.asm"

scope SinglePlayer {

    // @ Description
    // This extends the high score BTT/BTP code that checks if all targets/platforms are achieved
    // to allow for new characters.
    scope extend_high_score_btx_count_check_: {
        OS.patch_start(0x149BAC, 0x80133B7C)
        j       extend_high_score_btx_count_check_
        nop
        _extend_high_score_btx_count_check_return:
        OS.patch_end()

        lui     t6, 0x8013                  // original line 1
        lw      t6, 0x7714(t6)              // original line 2

        // a0 is character ID
        slti    at, a0, Character.id.BOSS   // if (it's not an original character) then use extended table
        bnez    at, _original               // otherwise use original table
        nop                                 // ~

        // exclude some added characters from check
        li      at, Character.BTT_TABLE     // assume characters always have both BTT and BTP stage ids if legal
        addu    at, at, a0                  // at = address of BTX stage id
        lbu     v0, 0x0000(at)              // v0 = BTX stage id
        addiu   at, r0, 0x00FF              // at = 0x000000FF
        beq     at, v0, _return             // if not a valid stage id,
        addiu   v0, r0, 0x000A              // then set v0 to A in order to continue looping

        li      at, Character.EXTENDED_HIGH_SCORE_TABLE
        addiu   t8, a0, -Character.id.BOSS  // t8 = index to character struct in extended table
        sll     t8, t8, 0x0005              // t8 = offset to character struct in extended table
        addu    at, at, t8                  // at = address of high score character struct
        lbu     v0, 0x0014(at)              // v0 = # of targets
        bnel    t6, r0, _return             // if (t6 = 1) then get platforms instead:
        lbu     v0, 0x001C(at)              // v0 = # of platforms
        _return:
        addiu   at, r0, 0x000A              // original line 6
        j       0x80133BB0                  // return
        nop

        _original:
        j       _extend_high_score_btx_count_check_return
        nop
    }

    // @ Description
    // This extends the high score BTT/BTP display code to allow for new characters
    scope extend_high_score_btx_count_: {
        OS.patch_start(0x1499C0, 0x80133990)
        j       extend_high_score_btx_count_
        nop
        _extend_high_score_btx_count_return:
        OS.patch_end()

        lui     t6, 0x8013                  // original line 1
        lw      t6, 0x7714(t6)              // original line 2

        // a0 is character ID
        slti    t8, a0, Character.id.BOSS   // if (it's not an original character) then use extended table
        bnez    t8, _original               // otherwise use original table
        nop                                 // ~

        li      t7, Character.EXTENDED_HIGH_SCORE_TABLE
        addiu   t8, a0, -Character.id.BOSS  // t8 = index to character struct in extended table
        sll     t8, t8, 0x0005              // t8 = offset to character struct in extended table
        addu    t7, t7, t8                  // t7 = address of high score character struct
        lbu     v0, 0x0014(t7)              // v0 = # of targets
        bnel    t6, r0, _return             // if (t6 = 1) then get platforms instead:
        lbu     v0, 0x001C(t7)              // v0 = # of platforms
        _return:
        jr      ra                          // return
        nop

        _original:
        j       _extend_high_score_btx_count_return
        nop
    }

    // @ Description
    // This extends the high score BTT/BTP time display code to allow for new characters
    scope extend_high_score_btx_time_: {
        OS.patch_start(0x149440, 0x80133410)
        j       extend_high_score_btx_time_
        nop
        _extend_high_score_btx_time_return:
        OS.patch_end()

        lui     t6, 0x8013                  // original line 1
        lw      t6, 0x7714(t6)              // original line 2

        // a0 is character ID
        slti    t8, a0, Character.id.BOSS   // if (it's not an original character) then use extended table
        bnez    t8, _original               // otherwise use original table
        nop                                 // ~

        li      t7, Character.EXTENDED_HIGH_SCORE_TABLE
        addiu   t8, a0, -Character.id.BOSS  // t8 = index to character struct in extended table
        sll     t8, t8, 0x0005              // t8 = offset to character struct in extended table
        addu    t7, t7, t8                  // t7 = address of high score character struct
        lw      v1, 0x0010(t7)              // v0 = targets completion frame count
        bnel    t6, r0, _return             // if (t6 = 1) then get platforms instead:
        lw      v1, 0x0018(t7)              // v0 = platforms completion frame count
        _return:
        j       0x80133438                  // return to end of original routine
        nop

        _original:
        j       _extend_high_score_btx_time_return
        nop
    }

    // @ Description
    // This extends the high score BTT failure write code to allow for new characters
    scope extend_high_score_btt_count_write_: {
        OS.patch_start(0x1130E4, 0x8018E9A4)
        j       extend_high_score_btt_count_write_
        nop
        _extend_high_score_btt_count_write_return:
        OS.patch_end()

        // a1 is character ID
        slti    at, a1, Character.id.BOSS   // if (it's not an original character) then use extended table
        bnez    at, _original               // otherwise use original table
        nop                                 // ~

        li      t8, Character.EXTENDED_HIGH_SCORE_TABLE
        addiu   at, a1, -Character.id.BOSS  // at = index to character struct in extended table
        sll     at, at, 0x0005              // at = offset to character struct in extended table
        addu    t8, t8, at                  // t8 = address of high score character struct
        lbu     v0, 0x0014(t8)              // v0 = # of targets
        lbu     v1, 0x0038(a3)              // original line 3
        slt     at, v0, v1                  // original line 4
        beql    at, r0, _j_0x8018EA74       // original line 5 (modified to use jump)
        lw      ra, 0x0014(sp)              // original line 6
        jal     0x800D45F4                  // original line 7
        sb      v1, 0x0014(t8)              // store new high score in extended table
        beq     r0, r0, _j_0x8018EA74       // return (modified line 8)
        lw      ra, 0x0014(sp)              // original line 10

        _original:
        addu    v0, t8, t9                  // original line 1
        lbu     t0, 0x0470(v0)              // original line 2

        j       _extend_high_score_btt_count_write_return
        nop

        _j_0x8018EA74:
        j       0x8018EA74                  // jump instead of branch
        nop
    }

    // @ Description
    // This extends the high score BTT success write code to allow for new characters
    scope extend_high_score_btt_time_write_: {
        OS.patch_start(0x11310C, 0x8018E9CC)
        j       extend_high_score_btt_time_write_
        nop
        _extend_high_score_btt_time_write_return:
        OS.patch_end()

        // t1 is character ID sll'd 0x0005
        srl     v0, t1, 0x0005              // v0 = character_id
        slti    t2, v0, Character.id.BOSS   // if (it's not an original character) then use extended table
        bnez    t2, _original               // otherwise use original table
        nop                                 // ~

        li      t2, Character.EXTENDED_HIGH_SCORE_TABLE
        addiu   v0, v0, -Character.id.BOSS  // v0 = index to character struct in extended table
        sll     v0, v0, 0x0005              // v0 = offset to character struct in extended table
        addu    t2, t2, v0                  // t2 = address of high score character struct
        addiu   t3, r0, 0x000A              // original line 4
        sb      t3, 0x0014(t2)              // store target count (modified original line 5)
        lw      v1, 0x0018(a0)              // original line 6
        lw      t4, 0x0010(t2)              // original line 7 (modified)
        sltu    at, v1, t4                  // original line 8
        beql    at, r0, _j_0x8018EA74       // original line 9 (modified to use jump)
        lw      ra, 0x0014(sp)              // original line 10
        jal     0x800D45F4                  // original line 11
        sw      v1, 0x0010(t2)              // store new high score in extended table
        beq     r0, r0, _j_0x8018EA74       // return (modified line 13)
        lw      ra, 0x0014(sp)              // original line 14

        _original:
        lui     t2, 0x800A                  // original line 1
        addiu   t2, t2, 0x44E0              // original line 2

        j       _extend_high_score_btt_time_write_return
        nop

        _j_0x8018EA74:
        j       0x8018EA74                  // jump instead of branch
        nop
    }

    // @ Description
    // This extends the high score BTT success new record check to allow for new characters
    scope extend_high_score_btt_new_record_check_: {
        OS.patch_start(0x111C9C, 0x8018D55C)
        j       extend_high_score_btt_new_record_check_
        nop
        _extend_high_score_btt_new_record_check_return:
        OS.patch_end()

        // t0 is character ID
        slti    t2, t0, Character.id.BOSS   // if (it's not an original character) then use extended table
        bnez    t2, _original               // otherwise use original table
        nop                                 // ~

        li      t2, Character.EXTENDED_HIGH_SCORE_TABLE
        addiu   v0, t0, -Character.id.BOSS  // v0 = index to character struct in extended table
        sll     v0, v0, 0x0005              // v0 = offset to character struct in extended table
        addu    v0, t2, v0                  // v0 = address of high score character struct
        lbu     t3, 0x0014(v0)              // t3 = target count (modified original line 5)
        addiu   at, r0, 0x000A              // original line 6
        lui     t4, 0x800A                  // original line 7
        bne     t3, at, _j_0x8018D5A8       // original line 8 (modified to use jump)
        nop                                 // original line 9
        lw      t4, 0x50E8(t4)              // original line 10
        lw      t6, 0x0010(v0)              // t6 = current best time (modified original line 11)
        j       0x8018D588                  // return
        nop

        _original:
        lui     t2, 0x800A                  // original line 1
        addiu   t2, t2, 0x44E0              // original line 2

        j       _extend_high_score_btt_new_record_check_return
        nop

        _j_0x8018D5A8:
        j       0x8018D5A8                  // jump instead of branch
        nop
    }

    // @ Description
    // This extends the high score BTP failure write code to allow for new characters
    scope extend_high_score_btp_count_write_: {
        OS.patch_start(0x113158, 0x8018EA18)
        j       extend_high_score_btp_count_write_
        nop
        _extend_high_score_btp_count_write_return:
        OS.patch_end()

        // a1 is character ID
        slti    at, a1, Character.id.BOSS   // if (it's not an original character) then use extended table
        bnez    at, _original               // otherwise use original table
        nop                                 // ~

        li      t5, Character.EXTENDED_HIGH_SCORE_TABLE
        addiu   at, a1, -Character.id.BOSS  // at = index to character struct in extended table
        sll     at, at, 0x0005              // at = offset to character struct in extended table
        addu    t5, t5, at                  // t5 = address of high score character struct
        lbu     v0, 0x001C(t5)              // v0 = # of platforms
        lbu     v1, 0x0038(a3)              // original line 3
        slt     at, v0, v1                  // original line 4
        beql    at, r0, _j_0x8018EA74       // original line 5 (modified to use jump)
        lw      ra, 0x0014(sp)              // original line 6
        jal     0x800D45F4                  // original line 7
        sb      v1, 0x001C(t5)              // store new high score in extended table
        beq     r0, r0, _j_0x8018EA74       // return (modified line 8)
        lw      ra, 0x0014(sp)              // original line 10

        _original:
        addu    v0, t5, t6                  // original line 1
        lbu     t7, 0x0478(v0)              // original line 2

        j       _extend_high_score_btp_count_write_return
        nop

        _j_0x8018EA74:
        j       0x8018EA74                  // jump instead of branch
        nop
    }

    // @ Description
    // This extends the high score BTP success write code to allow for new characters
    scope extend_high_score_btp_time_write_: {
        OS.patch_start(0x113180, 0x8018EA40)
        j       extend_high_score_btp_time_write_
        nop
        _extend_high_score_btp_time_write_return:
        OS.patch_end()

        // t8 is character ID sll'd 0x0005
        srl     v0, t8, 0x0005              // v0 = character_id
        slti    t2, v0, Character.id.BOSS   // if (it's not an original character) then use extended table
        bnez    t2, _original               // otherwise use original table
        nop                                 // ~

        li      t9, Character.EXTENDED_HIGH_SCORE_TABLE
        addiu   v0, v0, -Character.id.BOSS  // v0 = index to character struct in extended table
        sll     v0, v0, 0x0005              // v0 = offset to character struct in extended table
        addu    t9, t9, v0                  // t9 = address of high score character struct
        addiu   t0, r0, 0x000A              // original line 4
        sb      t0, 0x001C(t9)              // store platform count (modified original line 5)
        lw      v1, 0x0018(a0)              // original line 6
        lw      t1, 0x0018(t9)              // original line 7 (modified)
        sltu    at, v1, t1                  // original line 8
        beql    at, r0, _j_0x8018EA74       // original line 9 (modified to use jump)
        lw      ra, 0x0014(sp)              // original line 10
        jal     0x800D45F4                  // original line 11
        sw      v1, 0x0018(t9)              // store new high score in extended table
        beq     r0, r0, _j_0x8018EA74       // return (modified line 13)
        lw      ra, 0x0014(sp)              // original line 14

        _original:
        lui     t9, 0x800A                  // original line 1
        addiu   t9, t9, 0x44E0              // original line 2

        j       _extend_high_score_btp_time_write_return
        nop

        _j_0x8018EA74:
        j       0x8018EA74                  // jump instead of branch
        nop
    }

    // @ Description
    // This extends the high score BTP success new record check to allow for new characters
    scope extend_high_score_btp_new_record_check_: {
        OS.patch_start(0x112100, 0x8018D9C0)
        j       extend_high_score_btp_new_record_check_
        nop
        _extend_high_score_btp_new_record_check_return:
        OS.patch_end()

        // t2 is character ID
        slti    t4, t2, Character.id.BOSS   // if (it's not an original character) then use extended table
        bnez    t4, _original               // otherwise use original table
        nop                                 // ~

        li      t4, Character.EXTENDED_HIGH_SCORE_TABLE
        addiu   v0, t2, -Character.id.BOSS  // v0 = index to character struct in extended table
        sll     v0, v0, 0x0005              // v0 = offset to character struct in extended table
        addu    v0, t4, v0                  // v0 = address of high score character struct
        lbu     t5, 0x001C(v0)              // t5 = platform count (modified original line 5)
        addiu   at, r0, 0x000A              // original line 6
        lui     t6, 0x800A                  // original line 7
        bne     t5, at, _j_0x8018DA0C       // original line 8 (modified to use jump)
        nop                                 // original line 9
        lw      t6, 0x50E8(t6)              // original line 10
        lw      t8, 0x0018(v0)              // t8 = current best time (modified original line 11)
        j       0x8018D9EC                  // return
        nop

        _original:
        lui     t4, 0x800A                  // original line 1
        addiu   t4, t4, 0x44E0              // original line 2

        j       _extend_high_score_btp_new_record_check_return
        nop

        _j_0x8018DA0C:
        j       0x8018DA0C                  // jump instead of branch
        nop
    }

    // @ Description
    // Modifies the tally loop for BTT/BTP to include new characters
    scope extend_btx_tally_: {
        OS.patch_start(0x14CCE8, 0x80136CB8)
        j       extend_btx_tally_._check_counts
        nop
        _extend_btx_tally_check_counts_return:
        OS.patch_end()
        OS.patch_start(0x1496C8, 0x80133698)
        j       extend_btx_tally_._ms
        nop
        _extend_btx_tally_ms_return:
        OS.patch_end()
        OS.patch_start(0x149698, 0x80133668)
        j     extend_btx_tally_._ms_exclude_check
        nop
        _ms_exclude_check_return:
        OS.patch_end()
        OS.patch_start(0x14965C, 0x8013362C)
        j       extend_btx_tally_._s
        nop
        _extend_btx_tally_s_return:
        OS.patch_end()
        OS.patch_start(0x14962C, 0x801335FC)
        j       extend_btx_tally_._s_exclude_check
        nop
        _s_exclude_check_return:
        OS.patch_end()
        OS.patch_start(0x1495F0, 0x801335C0)
        j       extend_btx_tally_._m
        nop
        _extend_btx_tally_m_return:
        OS.patch_end()
        OS.patch_start(0x1495C0, 0x80133590)
        j       extend_btx_tally_._m_exclude_check
        nop
        _m_exclude_check_return:
        OS.patch_end()

        // This checks that all targets have been broken or all platforms have been boarded
        _check_counts:
        addiu   v0, r0, 0x000C                   // v0 = 12
        bne     v0, s0, _original_check          // if (we are finished with new characters) then jump to original path
        nop                                      // otherwise set to new characters and loop some more:
        addiu   s1, r0, Character.NUM_CHARACTERS // end at last character
        addiu   s0, r0, Character.id.BOSS        // start after original cast
        _j_80136CA0:
        j       0x80136CA0                       // jump to loop start
        nop

        _original_check:
        bne     s0, s1, _j_80136CA0              // original line 1
        nop                                      // original line 2

        j       _extend_btx_tally_check_counts_return
        nop

        // This tallies milliseconds
        _ms:
        addiu   v0, r0, 0x000C                   // v0 = 12
        bne     v0, s0, _original_ms             // if (we are finished with new characters) then jump to original path
        nop                                      // otherwise set to new characters and loop some more:
        addiu   s2, r0, Character.NUM_CHARACTERS // end at last character
        addiu   s0, r0, Character.id.BOSS        // start after original cast
        j       0x80133668                       // jump to loop start
        nop

        _original_ms:
        lw      ra, 0x0024(sp)                   // original line 1
        or      v0, s1, r0                       // original line 2

        j       _extend_btx_tally_ms_return      // return
        nop

        // This excludes illegal characters from the milliseconds tally
        _ms_exclude_check:
        slti    a0, s0, Character.id.BOSS        // if (it's not an original character) then we'll check BTT_TABLE
        bnez    a0, _original_ms_exclude         // otherwise use original lines
        nop                                      // ~

        li      a0, Character.BTT_TABLE          // assume characters always have both BTT and BTP stage ids if legal
        addu    a0, a0, s0                       // a0 = address of BTX stage id
        lbu     v0, 0x0000(a0)                   // v0 = BTX stage id
        addiu   a0, r0, 0x00FF                   // a0 = 0x000000FF
        beq     a0, v0, _j_0x8013368C            // if not a valid stage id,
        nop                                      // then skip adding this to the highscore and continue

        _original_ms_exclude:
        jal     0x801322BC                       // original line 1
        or      a0, s0, r0                       // original line 2

        j       _ms_exclude_check_return         // return
        nop

        _j_0x8013368C:
        j       0x8013368C                       // jump since we can't branch
        nop

        // This tallies seconds
        _s:
        addiu   v0, r0, 0x000C                   // v0 = 12
        bne     v0, s0, _original_s              // if (we are finished with new characters) then jump to original path
        nop                                      // otherwise set to new characters and loop some more:
        addiu   s2, r0, Character.NUM_CHARACTERS // end at last character
        addiu   s0, r0, Character.id.BOSS        // start after original cast
        j       0x801335FC                       // jump to loop start
        nop

        _original_s:
        lw      ra, 0x0024(sp)                   // original line 1
        or      v0, s1, r0                       // original line 2

        j       _extend_btx_tally_s_return       // return
        nop

        // This excludes illegal characters from the seconds tally
        _s_exclude_check:
        slti    a0, s0, Character.id.BOSS        // if (it's not an original character) then we'll check BTT_TABLE
        bnez    a0, _original_s_exclude          // otherwise use original lines
        nop                                      // ~

        li      a0, Character.BTT_TABLE          // assume characters always have both BTT and BTP stage ids if legal
        addu    a0, a0, s0                       // a0 = address of BTX stage id
        lbu     v0, 0x0000(a0)                   // v0 = BTX stage id
        addiu   a0, r0, 0x00FF                   // a0 = 0x000000FF
        beq     a0, v0, _j_0x80133620            // if not a valid stage id,
        nop                                      // then skip adding this to the highscore and continue

        _original_s_exclude:
        jal     0x801322BC                       // original line 1
        or      a0, s0, r0                       // original line 2

        j       _s_exclude_check_return          // return
        nop

        _j_0x80133620:
        j       0x80133620                       // jump since we can't branch
        nop

        // This tallies minutes
        _m:
        addiu   v0, r0, 0x000C                   // v0 = 12
        bne     v0, s0, _original_m              // if (we are finished with new characters) then jump to original path
        nop                                      // otherwise set to new characters and loop some more:
        addiu   s2, r0, Character.NUM_CHARACTERS // end at last character
        addiu   s0, r0, Character.id.BOSS        // start after original cast
        j       0x80133590                       // jump to loop start
        nop

        _original_m:
        lw      ra, 0x0024(sp)                   // original line 1
        or      v0, s1, r0                       // original line 2

        j       _extend_btx_tally_m_return       // return
        nop

        // This excludes illegal characters from the minutes tally
        _m_exclude_check:
        slti    a0, s0, Character.id.BOSS        // if (it's not an original character) then we'll check BTT_TABLE
        bnez    a0, _original_m_exclude          // otherwise use original lines
        nop                                      // ~

        li      a0, Character.BTT_TABLE          // assume characters always have both BTT and BTP stage ids if legal
        addu    a0, a0, s0                       // a0 = address of BTX stage id
        lbu     v0, 0x0000(a0)                   // v0 = BTX stage id
        addiu   a0, r0, 0x00FF                   // a0 = 0x000000FF
        beq     a0, v0, _j_0x801335B4            // if not a valid stage id,
        nop                                      // then skip adding this to the highscore and continue

        _original_m_exclude:
        jal     0x801322BC                       // original line 1
        or      a0, s0, r0                       // original line 2

        j       _m_exclude_check_return          // return
        nop

        _j_0x801335B4:
        j       0x801335B4                       // jump since we can't branch
        nop
    }

    // @ Description
    // Modify the code that sets the stage ID for BTT so we can use new characters
    scope set_btt_stage_id_: {
        OS.patch_start(0x111950, 0x8018D210)
        j       set_btt_stage_id_
        nop
        _set_btt_stage_id_return:
        OS.patch_end()

        lw      t3, 0x0000(a2)              // original line 1

        // v0 is character ID
        slti    t8, v0, Character.id.BOSS   // if (it's not an original character) then use extended table
        bnez    t8, _original               // otherwise use original table
        nop                                 // ~

        li      t8, Character.BTT_TABLE     // t8 = address of stage_id table
        addu    t8, t8, v0                  // t8 = address of stage_id, adjusted to 0 base
        lb      t8, 0x0000(t8)              // t8 = stage_id
        j       _set_btt_stage_id_return    // return
        nop

        _original:
        addiu   t8, v0, 0x0011              // original line 2
        j       _set_btt_stage_id_return    // return
        nop
    }

    // @ Description
    // Modify the code that sets the stage ID for BTP so we can use new characters
    scope set_btp_stage_id_: {
        OS.patch_start(0x111964, 0x8018D224)
        j       set_btp_stage_id_
        nop
        _set_btp_stage_id_return:
        OS.patch_end()

        // v0 is character ID
        slti    t4, v0, Character.id.BOSS   // if (it's not an original character) then use extended table
        bnez    t4, _original               // otherwise use original table
        nop                                 // ~

        li      t4, Character.BTP_TABLE     // t4 = address of stage_id table
        addu    t4, t4, v0                  // t4 = address of stage_id, adjusted to 0 base
        lb      t4, 0x0000(t4)              // t4 = stage_id
        sb      t4, 0x0001(t5)              // original line 2
        j       _set_btp_stage_id_return    // return
        nop

        _original:
        addiu   t4, v0, 0x001D              // original line 1
        sb      t4, 0x0001(t5)              // original line 2
        j       _set_btp_stage_id_return    // return
        nop
    }

    // @ Description
    // This extends the 1P high score display code to allow for new characters
    scope extend_high_score_1p_: {
        OS.patch_start(0x13C958, 0x80134758)
        j       extend_high_score_1p_
        nop
        _extend_high_score_1p_return:
        OS.patch_end()

        // a0 is character ID
        slti    t6, a0, Character.id.BOSS   // if (it's not an original character) then use extended table
        bnez    t6, _original               // otherwise use original table
        nop                                 // ~

        li      t6, Character.EXTENDED_HIGH_SCORE_TABLE
        addiu   v0, a0, -Character.id.BOSS  // v0 = index to character struct in extended table
        sll     v0, v0, 0x0005              // v0 = offset to character struct in extended table
        addu    t6, t6, v0                  // t6 = address of high score character struct
        lw      v0, 0x0000(t6)              // v0 = high score
        jr      ra                          // return
        nop

        _original:
        sll     t6, a0, 0x0005              // original line 1
        lui     v0, 0x800A                  // original line 2

        j       _extend_high_score_1p_return
        nop
    }

    // @ Description
    // This extends the 1P high score stock count display code to allow for new characters
    scope extend_high_score_1p_stock_count_: {
        OS.patch_start(0x13CB68, 0x80134968)
        j       extend_high_score_1p_stock_count_
        nop
        _extend_high_score_1p_stock_count_return:
        OS.patch_end()

        // a0 is character ID
        slti    t6, a0, Character.id.BOSS   // if (it's not an original character) then use extended table
        bnez    t6, _original               // otherwise use original table
        nop                                 // ~

        li      t6, Character.EXTENDED_HIGH_SCORE_TABLE
        addiu   v0, a0, -Character.id.BOSS  // v0 = index to character struct in extended table
        sll     v0, v0, 0x0005              // v0 = offset to character struct in extended table
        addu    t6, t6, v0                  // t6 = address of high score character struct
        lw      v0, 0x0008(t6)              // v0 = stock count
        jr      ra                          // return
        nop

        _original:
        sll     t6, a0, 0x0005              // original line 1
        lui     v0, 0x800A                  // original line 2

        j       _extend_high_score_1p_stock_count_return
        nop
    }
    
    // @ Description
    // This extends the 1P high score difficulty display code to allow for new characters
    scope extend_high_score_1p_difficulty_: {
        OS.patch_start(0x13CAD8, 0x801348D8)
        j       extend_high_score_1p_difficulty_
        nop
        _extend_high_score_1p_difficulty_return:
        OS.patch_end()

        // t4 is character ID
        slti    t5, t4, Character.id.BOSS   // if (it's not an original character) then use extended table
        bnez    t5, _original               // otherwise use original table
        nop                                 // ~

        li      t5, Character.EXTENDED_HIGH_SCORE_TABLE
        addiu   a2, t4, -Character.id.BOSS  // a2 = index to character struct in extended table
        sll     a2, a2, 0x0005              // a2 = offset to character struct in extended table
        addu    t5, t5, a2                  // t5 = address of high score character struct
        lbu     a2, 0x000C(t5)              // a2 = difficulty
        b       _return                     // return
        nop

        _original:
        sll     t5, t4, 0x0005              // original line 0 (line before line 1)
        addu    a2, a2, t5                  // original line 1
        lbu     a2, 0x4948(a2)              // original line 2

        _return:
        j       _extend_high_score_1p_difficulty_return
        nop
    }

    // @ Description
    // This extends the high score 1P write code to allow for new characters
    scope extend_high_score_1p_write_: {
        OS.patch_start(0x51F44, 0x800D6744)
        j       extend_high_score_1p_write_
        nop
        _extend_high_score_1p_write_return:
        OS.patch_end()

        // t6 is character ID
        slti    t2, t6, Character.id.BOSS   // if (it's not an original character) then use extended table
        bnez    t2, _original               // otherwise use original table
        nop                                 // ~

        li      a3, Character.EXTENDED_HIGH_SCORE_TABLE
        addiu   a3, a3, -0x045C             // a3 = adjusted table base for extended table
        addiu   t6, t6, -Character.id.BOSS  // t6 = adjusted offset

        j       _extend_high_score_1p_write_return
        nop

        _original:
        lui     a3, 0x800A                  // original line 1
        addiu   a3, a3, 0x44E0              // original line 2

        j       _extend_high_score_1p_write_return
        nop
    }

    // @ Description
    // Modifies the tally loop for 1P to include new characters
    scope extend_1p_tally_: {
        OS.patch_start(0x13CD90, 0x80134B90)
        j       extend_1p_tally_
        nop
        _extend_1p_tally_return:
        OS.patch_end()

        addiu   a0, r0, 0x000C                   // a0 = 12
        bne     a0, s0, _original_check          // if (we are finished with new characters) then jump to original path
        nop                                      // otherwise set to new characters and loop some more:
        addiu   s2, r0, Character.NUM_CHARACTERS // end at last character
        addiu   s0, r0, Character.id.BOSS        // start after original cast
        _j_80134B84:
        j       0x80134B84                       // jump to loop start
        nop

        _original_check:
        bne     s0, s2, _j_80134B84              // original line 1
        addu    s1, s1, v0                       // original line 2

        j       _extend_1p_tally_return          // return
        nop
    }

    // @ Description
    // Modify the code that sets the stage ID for BTT during 1P so we can use new characters
    scope set_btt_stage_id_1p_: {
        OS.patch_start(0x1118F8, 0x8018D1B8)
        j       set_btt_stage_id_1p_
        nop
        _set_btt_stage_id_1p_return:
        OS.patch_end()

        lw      t8, 0x0000(a2)              // original line 1

        // v0 is character ID
        slti    t7, v0, Character.id.BOSS   // if (it's not an original character) then use extended table
        bnez    t7, _original               // otherwise use original table
        nop                                 // ~

        li      t7, Character.BTT_TABLE     // t7 = address of stage_id table
        addu    t7, t7, v0                  // t7 = address of stage_id, adjusted to 0 base
        lb      t7, 0x0000(t7)              // t7 = stage_id
        j       _set_btt_stage_id_1p_return // return
        nop

        _original:
        addiu   t7, v0, 0x0011              // original line 2
        j       _set_btt_stage_id_1p_return // return
        nop
    }

    // @ Description
    // Modify the code that sets the stage ID for BTP during 1P so we can use new characters
    scope set_btp_stage_id_1p_: {
        OS.patch_start(0x111920, 0x8018D1E0)
        j       set_btp_stage_id_1p_
        nop
        _set_btp_stage_id_1p_return:
        OS.patch_end()

        lw      t2, 0x0000(a2)              // original line 1

        // v0 is character ID
        slti    t5, v0, Character.id.BOSS   // if (it's not an original character) then use extended table
        bnez    t5, _original               // otherwise use original table
        nop                                 // ~

        li      t5, Character.BTP_TABLE     // t5 = address of stage_id table
        addu    t5, t5, v0                  // t5 = address of stage_id, adjusted to 0 base
        lb      t5, 0x0000(t5)              // t5 = stage_id
        j       _set_btp_stage_id_1p_return // return
        nop

        _original:
        addiu   t5, v0, 0x001D              // original line 2
        j       _set_btp_stage_id_1p_return // return
        nop
    }

    // @ Description
    // This piggybacks off the code that writes SSB data to SRAM to write our extended table as well
    scope write_extended_high_score_table_: {
        OS.patch_start(0x00050014, 0x800D4634)
        jal     write_extended_high_score_table_
        nop
        OS.patch_end()

        li      a0, Character.EXTENDED_HIGH_SCORE_TABLE_BLOCK
        jal     SRAM.save_
        nop

        jal     SRAM.mark_saved_            // mark save file present
        nop

        lw      ra, 0x0014(sp)              // original line 1
        addiu   sp, sp, 0x0018              // original line 2

        jr      ra                          // return
        nop
    }

    // @ Description
    // This piggybacks off the code that loads SSB data from SRAM to load our extended table as well
    scope load_extended_high_score_table_: {
        OS.patch_start(0x000500C4, 0x800D46E4)
        jal     load_extended_high_score_table_
        nop
        OS.patch_end()

        jal     SRAM.check_saved_           // v0 = has_saved
        nop
        beqz    v0, _initialize             // if there has never been a save, then we can skip loading
        nop

        li      a0, Character.EXTENDED_HIGH_SCORE_TABLE_BLOCK
        jal     SRAM.load_
        nop

        _initialize:
        // make sure times are correctly initialized
        li      a0, Character.EXTENDED_HIGH_SCORE_TABLE
        lli     a2, 0x0000
        li      a3, 0x00034BC0
        _loop:
        lw      a1, 0x0010(a0)              // a1 = btt time
        beql    a1, r0, pc() + 8            // if (btt time = 0)
        sw      a3, 0x0010(a0)              // then set to default time
        lw      a1, 0x0018(a0)              // a1 = btp time
        beql    a1, r0, pc() + 8            // if (btp time = 0)
        sw      a3, 0x0018(a0)              // then set to default time
        addiu   a0, 0x0020                  // increment a0 to next character
        addiu   a2, 0x0001                  // increment a2 to next character
        slti    a1, a2, Character.NUM_CHARACTERS - 0xC
        bnez    a1, _loop                   // if (more characters to loop over) then loop
        nop

        lw      ra, 0x0014(sp)              // original line 1
        addiu   sp, sp, 0x0018              // original line 2

        jr      ra                          // return
        nop
    }

    // @ Description
    // Name texture offsets in file 0x000C* (non-adjusted - don't add 0x10 here for DF000000 00000000)
    // *MM and GDK are from file 0x000B
    scope name_texture {
        constant MARIO(0x00000128)
        constant FOX(0x00000248)
        constant DONKEY_KONG(0x00000368)
        constant SAMUS(0x000004E8)
        constant LUIGI(0x00000608)
        constant LINK(0x00000728)
        constant YOSHI(0x00000848)
        constant CAPTAIN_FALCON(0x00000A28)
        constant KIRBY(0x00000BA8)
        constant PIKACHU(0x00000D28)
        constant JIGGLYPUFF(0x00000F68)
        constant NESS(0x00001088)
        constant METAL(0x00005318)            // file 0xB
        constant NMARIO(0x00001E68)
        constant NFOX(0x00002048)
        constant NDONKEY(0x00002228)
        constant NSAMUS(0x00002468)
        constant NLUIGI(0x00002888)
        constant NLINK(0x00002A68)
        constant NYOSHI(0x00002CA8)
        constant NCAPTAIN(0x00002EE8)
        constant NKIRBY(0x00003128)
        constant NPIKACHU(0x00003368)
        constant NJIGGLY(0x00003548)
        constant NNESS(0x00003728)
        constant GDONKEY(0x00005738)          // file 0xB
        constant GND(0x000012C8)
        constant FALCO(0x00001448)
        constant YLINK(0x00001688)
        constant DRM(0x00001868)
        constant WARIO(0x000019E8)
        constant DSAMUS(0x00001C28)
        constant ELINK(0x000038A8)
        constant JSAMUS(0x00003A88)
        constant JNESS(0x00003C08)
        constant LUCAS(0x00001C28)
        constant BLANK(0x0)
    }

    name_texture_table:
    constant name_texture_table_origin(origin())
    dw name_texture.MARIO                   // Mario
    dw name_texture.FOX                     // Fox
    dw name_texture.DONKEY_KONG             // Donkey Kong
    dw name_texture.SAMUS                   // Samus
    dw name_texture.LUIGI                   // Luigi
    dw name_texture.LINK                    // Link
    dw name_texture.YOSHI                   // Yoshi
    dw name_texture.CAPTAIN_FALCON          // Captain Falcon
    dw name_texture.KIRBY                   // Kirby
    dw name_texture.PIKACHU                 // Pikachu
    dw name_texture.JIGGLYPUFF              // Jigglypuff
    dw name_texture.NESS                    // Ness
    dw name_texture.BLANK                   // Master Hand
    dw name_texture.METAL                   // Metal Mario
    dw name_texture.NMARIO                  // Polygon Mario
    dw name_texture.NFOX                    // Polygon Fox
    dw name_texture.NDONKEY                 // Polygon Donkey Kong
    dw name_texture.NSAMUS                  // Polygon Samus
    dw name_texture.NLUIGI                  // Polygon Luigi
    dw name_texture.NLINK                   // Polygon Link
    dw name_texture.NYOSHI                  // Polygon Yoshi
    dw name_texture.NCAPTAIN                // Polygon Captain Falcon
    dw name_texture.NKIRBY                  // Polygon Kirby
    dw name_texture.NPIKACHU                // Polygon Pikachu
    dw name_texture.NJIGGLY                 // Polygon Jigglypuff
    dw name_texture.NNESS                   // Polygon Ness
    dw name_texture.GDONKEY                 // Giant Donkey Kong
    dw name_texture.BLANK                   // (Placeholder)
    dw name_texture.BLANK                   // None (Placeholder)
    // new characters
    dw name_texture.FALCO                   // Falco
    dw name_texture.GND                     // Ganondorf
    dw name_texture.YLINK                   // Young Link
    dw name_texture.DRM                     // Dr. Mario
    dw name_texture.WARIO                   // Wario
    dw name_texture.DSAMUS                  // Dark Samus
    dw name_texture.ELINK                   // E Link
    dw name_texture.JSAMUS                  // J Samus
    dw name_texture.JNESS                   // J Ness
    dw name_texture.LUCAS                   // Lucas

    // @ Description
    // allows for custom entries of name texture based on file offset (+0x10 for DF000000 00000000)
    // (requires modification of file 0x000C)
    scope get_name_texture_: {
        OS.patch_start(0x12BA4C, 0x8013270C)
//      lw      t4, 0x0028(t4)                    // original line 1
        jal     get_name_texture_
        or      a0, s1, r0                        // original line 2
        OS.patch_end()

        // Default is File 0xC, but we can reuse MM and GDK from file 0xB
        lli     a1, Character.id.METAL            // a1 = Character.id.METAL
        beq     t2, a1, _use_file_b               // if Metal Mario, then use file 0xB
        nop
        lli     a1, Character.id.GDONKEY          // a1 = Character.id.GDONKEY
        beq     t2, a1, _use_file_b               // if Giant DK, then use file 0xB
        nop

        _get_offset:
        li      t4, name_texture_table            // t4 = texture offset table
        addu    t4, t4, t3                        // t4 = address of texture offset
        lw      t4, 0x0000(t4)                    // t4 = texture offset
        addiu   t4, t4, 0x0010                    // t4 = adjusted texture offset (+0x10 for DF000000 00000000)

        jr      ra                                // return
        nop

        _use_file_b:
        li      t4, Global.files_loaded           // t4 = pointer to file list
        lw      t4, 0x0000(t4)                    // t4 = file list
        lw      t5, 0x0004(t4)                    // t5 = pointer to file 0xB

        b       _get_offset                       // continue to getting offset
        nop
    }

    // @ Description
    // Changes the load from fgm_table instead of the original function table
    scope get_fgm_: {
        OS.patch_start(0x12DA2C, 0x801346EC)
//      sll     t7, t8, 0x0002                // original line 1
//      addu    a0, sp, t7                    // original line 2
        jal     get_fgm_
        nop
        jal     0x800269C0                    // original line 3
//      lhu     a0, 0x008A(a0)                // original line 4
        nop
        OS.patch_end()

        li      a0, CharacterSelect.fgm_table // a0 = fgm_table
        sll     t7, t8, 0x0001                // ~
        addu    a0, a0, t7                    // a0 = fgm_table + char offset
        lhu     a0, 0x0000(a0)                // a0 = fgm id
        jr      ra                            // return
        nop
    }

    // @ Description
    // Represents the amount of time the announcer waits between saying the name and saying "VS"
    scope name_delay {
        constant MARIO(0x00000032)
        constant FOX(0x00000032)
        constant DONKEY_KONG(0x00000046)
        constant SAMUS(0x00000032)
        constant LUIGI(0x00000032)
        constant LINK(0x00000032)
        constant YOSHI(0x00000032)
        constant CAPTAIN_FALCON(0x00000046)
        constant KIRBY(0x00000032)
        constant PIKACHU(0x00000032)
        constant JIGGLYPUFF(0x00000032)
        constant NESS(0x00000032)
        constant METAL(0x00000024 + MARIO)
        constant POLYGON(0x00000028)
        constant NMARIO(POLYGON + MARIO)
        constant NFOX(POLYGON + FOX)
        constant NDONKEY(POLYGON + DONKEY_KONG)
        constant NSAMUS(POLYGON + SAMUS)
        constant NLUIGI(POLYGON + LUIGI)
        constant NLINK(POLYGON + LINK)
        constant NYOSHI(POLYGON + YOSHI)
        constant NCAPTAIN(POLYGON + CAPTAIN_FALCON)
        constant NKIRBY(POLYGON + KIRBY)
        constant NPIKACHU(POLYGON + PIKACHU)
        constant NJIGGLY(POLYGON + JIGGLYPUFF)
        constant NNESS(POLYGON + NESS)
        constant GDONKEY(0x00000024 + DONKEY_KONG)
        constant GND(0x00000046)
        constant FALCO(0x00000032)
        constant YLINK(0x00000046)
        constant DRM(0x00000052)
        constant WARIO(0x0000003C)
        constant DSAMUS(0x00000046)
        constant ELINK(0x00000038)
        constant JSAMUS(0x00000032)
        constant JNESS(0x00000032)
        constant LUCAS(0x00000046)
        constant PLACEHOLDER(0x00000032)
    }

    name_delay_table:
    constant name_delay_table_origin(origin())
    dw name_delay.MARIO                   // Mario
    dw name_delay.FOX                     // Fox
    dw name_delay.DONKEY_KONG             // Donkey Kong
    dw name_delay.SAMUS                   // Samus
    dw name_delay.LUIGI                   // Luigi
    dw name_delay.LINK                    // Link
    dw name_delay.YOSHI                   // Yoshi
    dw name_delay.CAPTAIN_FALCON          // Captain Falcon
    dw name_delay.KIRBY                   // Kirby
    dw name_delay.PIKACHU                 // Pikachu
    dw name_delay.JIGGLYPUFF              // Jigglypuff
    dw name_delay.NESS                    // Ness
    dw name_delay.PLACEHOLDER             // Master Hand
    dw name_delay.METAL                   // Metal Mario
    dw name_delay.NMARIO                  // Polygon Mario
    dw name_delay.NFOX                    // Polygon Fox
    dw name_delay.NDONKEY                 // Polygon Donkey Kong
    dw name_delay.NSAMUS                  // Polygon Samus
    dw name_delay.NLUIGI                  // Polygon Luigi
    dw name_delay.NLINK                   // Polygon Link
    dw name_delay.NYOSHI                  // Polygon Yoshi
    dw name_delay.NCAPTAIN                // Polygon Captain Falcon
    dw name_delay.NKIRBY                  // Polygon Kirby
    dw name_delay.NPIKACHU                // Polygon Pikachu
    dw name_delay.NJIGGLY                 // Polygon Jigglypuff
    dw name_delay.NNESS                   // Polygon Ness
    dw name_delay.GDONKEY                 // Giant Donkey Kong
    dw name_delay.PLACEHOLDER             // (Placeholder)
    dw name_delay.PLACEHOLDER             // None (Placeholder)
    // new characters
    dw name_delay.FALCO                   // Falco
    dw name_delay.GND                     // Ganondorf
    dw name_delay.YLINK                   // Young Link
    dw name_delay.DRM                     // Dr. Mario
    dw name_delay.WARIO                   // Wario
    dw name_delay.DSAMUS                  // Dark Samus
    dw name_delay.ELINK                   // E Link
    dw name_delay.JSAMUS                  // J Samus
    dw name_delay.JNESS                   // J Ness
    dw name_delay.LUCAS                   // Lucas

    // @ Description
    // Allows for custom entries of name delays (time from when announcer says name to when he says "VS")
    scope get_name_delay_: {
        OS.patch_start(0x12D9DC, 0x8013469C)
//      lw      t3, 0x0000(t1)                    // original line 1
//      addiu   t4, t3, 0x0001                    // original line 2
        jal     get_name_delay_
        nop
        OS.patch_end()

        // t2 is offset in table
        li      t4, name_delay_table              // t4 = delay table
        addu    t4, t4, t2                        // t4 = address of delay
        lw      t4, 0x0000(t4)                    // t4 = delay
        jr      ra                                // return
        nop
    }

    // @ Description
    // Patch which substitutes working character/opponent ids (0-11) for the 1p vs preview.
    // TODO: better handle so this can be customized
    scope singleplayer_vs_preview_fix_: {
        OS.patch_start(0x12D67C, 0x8013433C)
        j       singleplayer_vs_preview_fix_
        lw      a0, 0x5CC8(a0)              // original line 1
        _singleplayer_vs_preview_fix_return:
        OS.patch_end()

        sll     a0, a0, 0x0002              // a0 = id * 4
        li      t7, Character.singleplayer_vs_preview.table
        addu    t7, t7, a0                  // t7 = vs_record.table + (id * 4)
        lw      a0, 0x0000(t7)              // a0 = new id

        jal     0x80133F90                  // original line 2
        nop

        j       _singleplayer_vs_preview_fix_return
        nop
    }

    // @ Description
    // Patch which substitutes working character/opponent ids (0-11) for the 1p vs preview when there are allies present.
    // TODO: better handle so this can be customized
    scope singleplayer_vs_preview_with_allies_fix_: {
        // with one ally
        OS.patch_start(0x12D620, 0x801342E0)
        jal     singleplayer_vs_preview_with_allies_fix_
        lui     a0, 0x8013                  // original line 1
        jal     0x80133F90                  // original line 3
        addiu   a1, r0, 0x0001              // original line 4
        OS.patch_end()

        // with two allies
        OS.patch_start(0x12D580, 0x80134240)
        jal     singleplayer_vs_preview_with_allies_fix_
        lui     a0, 0x8013                  // original line 1
        jal     0x80133F90                  // original line 3
        addiu   a1, r0, 0x0003              // original line 4
        OS.patch_end()

        lw      a0, 0x5CC8(a0)              // original line 2

        sll     a0, a0, 0x0002              // a0 = id * 4
        li      t7, Character.singleplayer_vs_preview.table
        addu    t7, t7, a0                  // t7 = vs_record.table + (id * 4)
        lw      a0, 0x0000(t7)              // a0 = new id

        jr      ra
        nop
    }

    // @ Description
    // Patch which substitutes working character/opponent ids (0-11) for the 1p gameover screen.
    // TODO: better handle so this can be customized
    scope singleplayer_gameover_fix_: {
        OS.patch_start(0x178BE8, 0x80132188)
        jal     singleplayer_gameover_fix_
        lui     a1, 0x8013                  // original line 1
        OS.patch_end()

        lw      a1, 0x4348(a1)              // original line 2
        sll     a1, a1, 0x0002              // a1 = id * 4
        li      a0, Character.singleplayer_vs_preview.table
        addu    a0, a0, a1                  // a0 = vs_record.table + (id * 4)
        lw      a1, 0x0000(a0)              // a1 = new id

        jr      ra
        nop
    }

    // @ Description
    // Patch which substitutes working character/opponent ids (0-11) for the 1p gameover screen when choosing no.
    // TODO: better handle so this can be customized
    scope singleplayer_gameover_no_fix_: {
        OS.patch_start(0x179D54, 0x801332F4)
        mthi    ra                          // save ra
        jal     singleplayer_gameover_no_fix_
        lwc1    f4, 0x0000(a0)              // original line 2
        OS.patch_end()
        OS.patch_start(0x179D78, 0x80133318)
        jal     singleplayer_gameover_no_fix_
        lwc1    f10, 0x0000(a0)             // original line 2
        OS.patch_end()
        OS.patch_start(0x179D9C, 0x8013333C)
        jal     singleplayer_gameover_no_fix_
        lwc1    f4, 0x0000(a0)              // original line 2
        mfhi    ra                          // restore ra
        OS.patch_end()

        lw      t8, 0x0000(a3)              // original line 1
        lw      t1, 0x0000(a1)              // original line 2
        sll     t8, t8, 0x0002              // t8 = id * 4
        li      t3, Character.singleplayer_vs_preview.table
        addu    t3, t3, t8                  // t3 = vs_record.table + (id * 4)
        lw      t3, 0x0000(t3)              // t3 = new id
        addu    t8, t3, r0                  // t8 = new id as well

        jr      ra
        nop
    }

    // @ Description
    // constants for defining the victory picture
    constant VICTORY_FILE_1(File.SINGLEPLAYER_VICTORY_IMAGE_BOTTOM)
    constant VICTORY_OFFSET_1(0x00020718)
    constant VICTORY_FILE_2(File.SINGLEPLAYER_VICTORY_IMAGE_TOP)
    constant VICTORY_OFFSET_2(0x00020718)
    constant SPLASH_FILE_1(File.SPLASH_IMAGE_BOTTOM)
    constant SPLASH_FILE_2(File.SPLASH_IMAGE_TOP)

    // @ Description
    // Patch which substitutes the victory picture with a custom one for all non-original characters.
    // There are a number of hardcodings addressed.
    scope replace_victory_image_: {
        OS.patch_start(0x17E824, 0x80131E14)
        jal     replace_victory_image_
        nop
        jal     0x800CDBD0                  // original line
        nop
        OS.patch_end()

        OS.patch_start(0x17E850, 0x80131E40)
        jal     replace_victory_image_
        addu    t0, t2, r0                  // move t2 to t0 (character id)
        jal     0x800CDC88                  // original line
        nop
        OS.patch_end()

        OS.patch_start(0x17E870, 0x80131E60)
        jal     replace_victory_image_._2
        nop
        jal     0x800CCFDC                  // original line
        addu    a1, t6, v0                  // original line
        nop
        OS.patch_end()

        OS.patch_start(0x17E8B4, 0x80131EA4)
        jal     replace_victory_image_._3
        nop
        jal     0x800CDBD0                  // original line
        nop
        OS.patch_end()

        OS.patch_start(0x17E8E0, 0x80131ED0)
        jal     replace_victory_image_._3
        addu    t9, t1, r0                  // move t1 to t9 (character id)
        jal     0x800CDC88                  // original line
        nop
        OS.patch_end()

        OS.patch_start(0x17E900, 0x80131EF0)
        jal     replace_victory_image_._4
        nop
        jal     0x800CCFDC                  // original line
        addu    a1, t5, v0                  // original line
        nop
        OS.patch_end()

        sltiu   a0, t0, 0x000C
        beqz    a0, _custom                 // if this is a new character,
        nop                                 // then we will load a custom image

        lui     a0, 0x8013                  // original line
        sll     t1, t0, 0x0004              // original line
        addu    a0, a0, t1                  // original line
        lw      a0, 0x2100(a0)              // original line
        jr      ra
        nop

        _custom:
        lli     a0, Character.id.NONE       // a0 = Character.id.NONE
        beq     t0, a0, _splash_1           // if character id is NONE, then we're on the splash screen
        nop
        lli     a0, VICTORY_FILE_1          // use custom file

        jr      ra
        nop

        _splash_1:
        // To fix a blue line frame buffer glitch, we're going to overwrite the current frame buffer
        // For now, we'll comment this out since it introduces bugs on PJ64K and is not a perfect fix elsewhere
        // May be useful in development if not interested in having bleeding eyes
        // li      t0, 0xA4400000              // t0 = VI Base Register
        // lw      t0, 0x0004(t0)              // t0 = Origin (frame buffer origin in bytes)
        // lui     t1, 0x8000                  // t1 = 0x80000000
        // addu    t0, t0, t1                  // t0 = frame buffer RAM address
        // li      t1, 0x00023F00              // t1 = size of frame buffer
        // addu    a0, t0, t1                  // a0 = end of frame buffer
        // _loop:
        // sw      r0, 0x0000(t0)              // clear frame buffer
        // bnel    a0, t0, _loop               // loop until we reach the end of the frame buffer
        // addiu   t0, t0, 0x0004              // ~

        lli     a0, SPLASH_FILE_1           // use custom file

        jr      ra
        nop

        _2:
        sltiu   t5, t4, 0x000C
        beqz    t5, _custom_2               // if this is a new character,
        nop                                 // then we will load a custom image

        lui     t6, 0x8013                  // original line
        sll     t5, t4, 0x0004              // original line
        addu    t6, t6, t5                  // original line
        lw      t6, 0x2104(t6)              // original line
        jr      ra
        nop

        _custom_2:
        li      t6, VICTORY_OFFSET_1        // use custom offset

        jr      ra
        nop

        _3:
        sltiu   a0, t9, 0x000C
        beqz    a0, _custom_3               // if this is a new character,
        nop                                 // then we will load a custom image

        lui     a0, 0x8013                  // original line
        sll     t0, t9, 0x0004              // original line
        addu    a0, a0, t0                  // original line
        lw      a0, 0x2108(a0)              // original line
        jr      ra
        nop

        _custom_3:
        lli     a0, Character.id.NONE       // a0 = Character.id.NONE
        beq     t9, a0, _splash_2           // if character id is NONE, then we're on the splash screen
        nop
        lli     a0, VICTORY_FILE_2          // use custom file

        jr      ra
        nop

        _splash_2:
        lli     a0, SPLASH_FILE_2          // use custom file

        jr      ra
        nop

        _4:
        sltiu   t5, t3, 0x000C
        beqz    t5, _custom_4               // if this is a new character,
        nop                                 // then we will load a custom image

        lui     t5, 0x8013                  // original line
        sll     t4, t3, 0x0004              // original line
        addu    t5, t5, t4                  // original line
        lw      t5, 0x210C(t5)              // original line
        jr      ra
        nop

        _custom_4:
        li      t5, VICTORY_OFFSET_2        // use custom offset

        jr      ra
        nop
    }

    custom_lighting_1:
    dw 0x00000000 // RGB
    dw 0x44000000 // RGB
    dw 0x00008100 // Direction ([Signed] X, Y, Z)
    dw 0x00000000 // Pad
    custom_lighting_2:
    dw 0x00800000 // RGB
    dw 0x00800000 // RGB
    dw 0x31750000 // Direction ([Signed] X, Y, Z)
    dw 0x00000000 // Pad

    // @ Description
    // This is a hacky way of fixing the lack of env mapping for MM and polygons
    // on various screens by adding extra lighting commands. It is called too often,
    // so it may be worth trying to only call for certain characters, but it seems to be harmless as is.
    scope env_mapping_fix_: {
        OS.patch_start(0x17558, 0x80016958)
        j       env_mapping_fix_
        nop
        _return:
        OS.patch_end()

        // Only need to fix env mapping on some screens
        li      at, Global.current_screen   // ~
        lbu     at, 0x0000(at)              // at = screen id

        // vs preview screen = 0xE AND first file loaded = 0xB
        lli     t9, 0x000E                  // t9 = vs preview screen id
        bne     t9, at, _check_if_css       // if (screen id != 0xE), continue checking
        nop                                 // otherwise, check first file loaded:
        li      t9, Global.files_loaded     // ~
        lw      t9, 0x0000(t9)              // t9 = address of loaded files list
        lw      t9, 0x0000(t9)              // t9 = first loaded file
        lli     at, 0x000B                  // at = 0xB
        beq     t9, at, _add_lighting       // if (first file loaded = 0xB VS Image),
        nop                                 // then add custom lighting
        b       _original                   // otherwise we're not on a screen that needs updating
        nop

        _check_if_css:
        // css screen ids: vs - 0x10, 1p - 0x11, training - 0x12, bonus1 - 0x13, bonus2 - 0x14
        slti    t9, at, 0x0010              // if (screen id < 0x10)...
        bnez    t9, _check_gameover         // ...then skip (not on a CSS)
        nop
        slti    t9, at, 0x0015              // if (screen id is between 0x10 and 0x14)...
        bnez    t9, _add_lighting           // ...then we're on a CSS, so add custom lighting
        nop

        // results screen id: 0x18
        lli     t9, 0x0018                  // t9 = results screen id
        beq     t9, at, _add_lighting       // add custom lighting
        nop

        // 1p leave in room screen id: 0x30
        lli     t9, 0x0030                  // t9 = 1p leave in room screen id
        beq     t9, at, _add_lighting       // add custom lighting
        nop

        _check_gameover:
        // gameover screen = 0x1 AND first file loaded = 0x4F
        lli     t9, 0x0001                  // t9 = gameover screen id
        bne     t9, at, _original           // if not on 0x1, then skip adding lighting
        nop
        li      t9, Global.files_loaded     // ~
        lw      t9, 0x0000(t9)              // t9 = address of loaded files list
        lw      t9, 0x0000(t9)              // t9 = first loaded file
        lli     at, 0x004F                  // at = 0x4F
        beq     t9, at, _add_lighting       // if (first file loaded = 0x4F Continue Image),
        nop                                 // then add custom lighting

        _original:
        sw      t6, 0x0000(v0)              // original line 1
        sw      r0, 0x0004(v0)              // original line 2

        j       _return                     // return
        nop

        _add_lighting:
        li      t9, 0xDC08000A              // t9 = command MoveMem to G_MV_LIGHT
        sw      t9, 0x0000(v0)              // append display list
        li      t9, custom_lighting_1       // t9 = pointer to custom lighting (diffuse?)
        sw      t9, 0x0004(v0)              // append display list
        li      t9, 0xDC08030A              // t9 = command MoveMem to G_MV_LIGHT
        sw      t9, 0x0008(v0)              // append display list
        li      t9, custom_lighting_2       // t9 = pointer to custom lighting (ambient?)
        sw      t9, 0x000C(v0)              // append display list

        addiu   v1, v1, 0x0010              // make space for extra commands
        addiu   v0, v0, 0x0010              // make space for extra commands

        b       _original                   // return to original instructions
        nop
    }

} // __SINGLE_PLAYER__
