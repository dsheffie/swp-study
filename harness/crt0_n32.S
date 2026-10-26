/*
 * crt0_n32.S -- bare-metal startup for n32 (MIPSpro) test programs.
 *
 * n32 code needs Status.FR=1 (32 64-bit FP registers) and CU1; 64-bit integer
 * ops are legal in kernel mode without KX.  $gp points at the static GOT/small
 * data (_gp from the linker).  BSS is NOT zeroed here: the TSVC COMMON blocks
 * are ~20MB and simulated memory starts zeroed, so a store loop would only
 * burn RTL-sim cycles.
 */
#include "sim.h"
	.set	mips3
	.set	noreorder
	.set	noat
	.option	pic0

	.section .except_vec, "ax"
	.org	0x000			/* TLB refill (BEV=0) */
	j	swp_exc_entry
	nop
	.org	0x080			/* XTLB refill */
	j	swp_exc_entry
	nop
	.org	0x100			/* cache error */
	j	swp_exc_entry
	nop
	.org	0x180			/* general exception */
	j	swp_exc_entry
	nop

	.section .text.startup, "ax"
	.globl	_start
	.type	_start, @function
_start:
	lui	$sp, %hi(_stack_top)
	addiu	$sp, $sp, %lo(_stack_top)
	lui	$gp, %hi(_gp)
	addiu	$gp, $gp, %lo(_gp)
	lui	$k0, 0x2400		/* Status = CU1 (bit 29) | FR (bit 26): write it outright --  */
	mtc0	$k0, $12		/* reset leaves BEV=1/ERL=1, which vectors to 0xbfc00380 */
	nop
	nop
	ctc1	$zero, $31		/* FCSR: round-to-nearest, no enables */
	move	$k0, $zero
	move	$k1, $zero
	lui	$t9, %hi(main)
	addiu	$t9, $t9, %lo(main)
	jalr	$t9
	nop
	break
	nop

swp_exc_entry:
	lui	$sp, %hi(_exc_stack_top)
	addiu	$sp, $sp, %lo(_exc_stack_top)
	lui	$gp, %hi(_gp)
	addiu	$gp, $gp, %lo(_gp)
	lui	$t9, %hi(swp_exc)
	addiu	$t9, $t9, %lo(swp_exc)
	jalr	$t9
	nop
	break
	nop
