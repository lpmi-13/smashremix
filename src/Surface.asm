// Surface.asm
if !{defined __SURFACE__} {
define __SURFACE__()
print "included Surface.asm\n"

// This file adds support for additional surface types.

scope Surface {   
    variable new_surface_count(0)           // number of new surface types
    variable new_knockback_struct_count(0)  // number of new knockback structs

    // @ Description
    // Add a new surface type.
    // name - surface name, used for display only
    // friction - friction value used by the surface, default = 4.0
    // bool_knockback - OS.FALSE = no knockback, OS.TRUE = apply knockback
    // knockback_type - not a well understood variable, usually determines FGM but has other uses
    // damage - parameter for knockback
    // knockback_angle - parameter for knockback
    // knockback_growth - parameter for knockback
    // fixed_knockback - parameter for knockback
    // base_knockback - parameter for knockback
    // effect - parameter for knockback
    // fgm_id - FGM id to use when applying knockback
    macro add_surface(name, friction, bool_knockback, knockback_type, damage, knockback_angle, knockback_growth, fixed_knockback, base_knockback, effect, fgm_id) {
        global variable new_surface_count(new_surface_count + 1)
        evaluate n(new_surface_count)
        // add surface parameters
        global define new_surface_{n}_name({name})
        global define new_surface_{n}_friction({friction})
        global define new_surface_{n}_struct(OS.NULL)
        // add knockback parameters
        if {bool_knockback} == OS.TRUE {
            global variable new_knockback_struct_count(new_knockback_struct_count + 1)
            evaluate m(new_knockback_struct_count)
            global define new_surface_{n}_struct(NEW_STRUCT_{m})
            
            global variable knockback_struct_{m}.type({knockback_type})
            global variable knockback_struct_{m}.damage({damage})
            global variable knockback_struct_{m}.angle({knockback_angle})
            global variable knockback_struct_{m}.growth({knockback_growth})
            global variable knockback_struct_{m}.fixed({fixed_knockback})
            global variable knockback_struct_{m}.base({base_knockback})
            global variable knockback_struct_{m}.effect({effect})
            global variable knockback_struct_{m}.fgm({fgm_id})
        }
        // print message
        print "Added Surface Type: {name} - ID is 0x" ; OS.print_hex(new_surface_count + 0xF) ; print "\n"
    }
    
    // @ Description
    // Move/extend the original 6 knockback structs
    macro move_original_structs() {
        constant ORIGINAL_ARRAY(0xA4530)
        evaluate n(1)
        while {n} <= 6 {
            // copy original struct
            constant ORIGINAL_STRUCT_{n}(pc())
            OS.copy_segment(ORIGINAL_ARRAY + (({n} - 1) * 0x1C), 0x1C)
            // add fgm override parameter
            dw -1
            // increment
            evaluate n({n}+1)
        }
    }
    
    // @ Description
    // Add new knockback structs
    macro add_new_structs() {
        evaluate n(1)
        while {n} <= new_knockback_struct_count {
            // add struct
            constant NEW_STRUCT_{n}(pc())
            dw  knockback_struct_{n}.type
            dw  knockback_struct_{n}.damage
            dw  knockback_struct_{n}.angle
            dw  knockback_struct_{n}.growth
            dw  knockback_struct_{n}.fixed
            dw  knockback_struct_{n}.base
            dw  knockback_struct_{n}.effect
            dw  knockback_struct_{n}.fgm
            // increment
            evaluate n({n}+1)
        }
    }
    
    // @ Description
    // Writes new surfaces to the ROM
    macro write_surfaces() {
        // Move/extend original knockback structs
        move_original_structs()
        
        // Add zebes acid struct
        zebes_acid_struct:
        dw 0x00000000
        dw 0x00000010
        dw 0x00000050
        dw 0x00000082
        dw 0x00000000
        dw 0x0000001E
        dw 0x00000001
        dw 0xFFFFFFFF
        
        // Add new knockback structs
        add_new_structs()
    
        // Define a table containing knockback struct pointers for surfaces.
        knockback_table:
        // define original knockback structs
        dw ORIGINAL_STRUCT_1                // surface 0x7
        dw ORIGINAL_STRUCT_2                // surface 0x8
        dw ORIGINAL_STRUCT_3                // surface 0x9
        dw ORIGINAL_STRUCT_4                // surface 0xA
        dw ORIGINAL_STRUCT_5                // surface 0xB
        dw OS.NULL                          // surface 0xC
        dw OS.NULL                          // surface 0xD
        dw OS.NULL                          // surface 0xE
        dw ORIGINAL_STRUCT_6                // surface 0xF
        // add new knockback structs
        evaluate n(1)
        while {n} <= new_surface_count {
            // add struct pointer to table
            dw  {new_surface_{n}_struct}
            // increment
            evaluate n({n}+1)
        }
        
        // Define a table containing friction values for surfaces.
        friction_table:
        // copy original table
        OS.copy_segment(0xA7CE0, 0x40)
        // add new surfaces
        evaluate n(1)
        while {n} <= new_surface_count {
            // add friction value to table
            float32  {new_surface_{n}_friction}
            // increment
            evaluate n({n}+1)
        }
    }
    
    
    // ADD NEW SURFACES HERE
    
    print "============================== SURFACE TYPES ============================== \n"
    
    // name - surface name, used for display only
    // friction - friction value used by the surface, default = 4.0
    // bool_knockback - OS.FALSE = no knockback, OS.TRUE = apply knockback
    // knockback_type - not a well understood variable, usually determines FGM but has other uses
    // damage - parameter for knockback
    // knockback_angle - parameter for knockback
    // knockback_growth - parameter for knockback
    // fixed_knockback - parameter for knockback
    // base_knockback - parameter for knockback
    // effect - parameter for knockback
    // fgm - FGM id to use when applying knockback
    
    add_surface(big_blue_surface_1, 4.0, OS.TRUE, 8, 4, 105, 5, 0, 125, 1, -1)
    add_surface(cool_cool_surface_1, 0.3, OS.FALSE, 0, 0, 0, 0, 0, 0, 0, 0)
    add_surface(onett_car_1, 4.0, OS.TRUE, 8, 20, 45, 20, 0, 140, 0, 0x11F)
    
    // write surfaces to ROM
    write_surfaces()
    
    print "========================================================================== \n"
    
    // ASM PATCHES
    
    // @ Description
    // Modifies the 3 known functions which load the friction of a surface to load from an
    // extended friction table.
    scope get_friction_: {
        constant UPPER(friction_table >> 16)
        constant LOWER(friction_table & 0xFFFF)
        
        // this patch modifies the general grounded physics function which is used to load/apply friction most of the time
        OS.patch_start(0x543DC, 0x800D8BDC)
        if LOWER > 0x7FFF {
            lui     at, (UPPER + 0x1)
        } else {
            lui     at, UPPER
        }
        addu    at, at, t9
        lwc1    f4, LOWER(at)
        OS.patch_end()
        
        // this patch modifies a function which loads from the friction table after a character has
        // taken low knockback?
        OS.patch_start(0x5D9DC, 0x800E21DC)
        if LOWER > 0x7FFF {
            lui     at, (UPPER + 0x1)
        } else {
            lui     at, UPPER
        }
        addu    at, at, t9
        lwc1    f4, LOWER(at)
        OS.patch_end()
        
        // this patch modifies a physics subroutine of kirby's down special which uses the friction
        // table
        OS.patch_start(0xDC2BC, 0x8016187C)
        if LOWER > 0x7FFF {
            lui     at, (UPPER + 0x1)
        } else {
            lui     at, UPPER
        }
        addu    at, at, t1
        lwc1    f8, LOWER(at)
        OS.patch_end()  
    }
    
    // @ Description
    // Revised version of in-game function which is used for loading a knockback struct for a
    // surface. Originally, a jump table was used, but it is replaced by an extended struct table.
    scope get_struct_: {
        OS.patch_start(0x61474, 0x800E5C74)
        // t0 = surface id - 7
        bltz    t0, _end                    // skip if surface id < 7
        or      v0, r0, r0                  // v0 = 0 (disable knockback)
        sll     t0, t0, 0x2                 // t0 = offset ((surface id - 7) * 0x4)
        li      at, knockback_table         // at = knockback_table
        addu    at, at, t0                  // at = knockback_table + offset
        lw      t0, 0x000(at)               // t0 = knockback struct address
        beq     t0, r0, _end                // branch if knockback struct = NULL
        or      v0, r0, r0                  // v0 = 0 (disable knockback)
        
        _struct:
        sw      t0, 0x0000(a1)              // store knockback struct
        ori     v0, r0, 0x0001              // v0 = 1 (enable knockback)
        
        _end:
        jr      ra                          // return
        nop
        
        fill 0x800E5D10 - pc()              // nop the rest of the original function
        OS.patch_end()
    }
    
    // @ Description
    // Patch which checks for a custom FGM id for surface knockback and redirects to a new routine
    // if an FGM id is present.
    scope fgm_override_: {
        OS.patch_start(0x5F538, 0x800E3D38)
        j       fgm_override_
        nop
        _return:
        OS.patch_end()
        
        lw      v1, 0x0034(sp)              // v1 = knockback struct
        lw      at, 0x001C(v1)              // at = FGM id
        bltz    at, _original               // branch if FGM id < 0
        nop
        
        _override:
        // TODO: figure out what this timer/variable is being used for..
        // My theory is that this timer disables knockback from the surface until it resets to 0.
        // If that is the case, it may be worth allowing a custom value to be set.
        ori     t8, r0, 0x0010              // ~
        sw      t8, 0x0170(a3)              // unknown timer (0x170 in player struct) = 0x10       
        jal     0x800269C0                  // play FGM
        or      a0, at, r0                  // move FGM id to a0
        lw      ra, 0x0014(sp)              // ~
        addiu   sp, sp, 0x0028              // ~
        jr      ra                          // end subroutine using original logic
        nop
        
        _original:
        lw      v1, 0x0038(sp)              // original line 1
        sltiu   at, v1, 0x000A              // original line 2
        j       _return                     // return
        nop
    }
    
    // @ Description
    // Redirects the Zebes acid struct to a hard coded location where the struct has been extended.
    scope zebes_acid_fix_: {
        OS.patch_start(0x83A08, 0x80108208)
        li      t7, zebes_acid_struct       // t7 = zebes_acid_struct
        OS.patch_end()
    }
}
}