/*
 * link_n32.ld -- bare-metal layout for n32 MIPSpro objects (TSVC/LFK shims).
 *
 *   0x80000000  BEV=0 exception vectors
 *   0x80010000  code, rodata, data, GOT/small data
 *   0x80400000  BSS (TSVC COMMONs are ~20MB)
 *   0x83ff0000  exception stack top, 0x83fffff0 stack top (64MB)
 */
OUTPUT_FORMAT("elf32-ntradbigmips")
OUTPUT_ARCH(mips)
ENTRY(_start)
SECTIONS
{
    . = 0x80000000;
    .except_vec : { KEEP(*(.except_vec)) }

    . = 0x80010000;
    .text : {
        *(.text.startup)
        *(.text .text.* .gnu.linkonce.t.*)
    }
    .rodata : {
        *(.rodata .rodata.* .gnu.linkonce.r.* .rdata)
    }
    .data : { *(.data .data.* .gnu.linkonce.d.*) }
    /* small data: everything MIPSpro/GCC address with 16-bit $gp offsets */
    . = ALIGN(16);
    _gp = . + 0x7ff0;
    .got : { *(.got) }
    .srdata : { *(.srdata) *(.lit4) *(.lit8) }
    .sdata : { *(.sdata .sdata.*) }
    .sbss : { *(.sbss .sbss.* .scommon) }

    . = 0x80400000;
    __bss_start = .;
    .bss : { *(.bss .bss.*) *(COMMON) }
    __bss_end = .;

    _exc_stack_top = 0x83ff0000;
    _stack_top = 0x83fffff0;

    /DISCARD/ : {
        *(.MIPS.abiflags) *(.MIPS.options) *(.MIPS.events*) *(.rel.MIPS.events*)
        *(.reginfo) *(.gnu.attributes) *(.comment) *(.note .note.*) *(.pdr)
        *(.debug*) *(.rel.debug*) *(.mdebug*)
    }
}
