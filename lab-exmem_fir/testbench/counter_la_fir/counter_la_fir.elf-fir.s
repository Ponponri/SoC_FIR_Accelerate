	.file	"fir.c"
	.option nopic
	.attribute arch, "rv32i2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
.Ltext0:
	.cfi_sections	.debug_frame
	.file 0 "/home/ponponri/Desktop/shared_folder/LAB4_2/lab-exmem_fir/testbench/counter_la_fir" "fir.c"
	.globl	AP_START
	.section	.srodata,"a"
	.align	2
	.type	AP_START, @object
	.size	AP_START, 4
AP_START:
	.word	-268435456
	.globl	FIR_DATA_DONE
	.align	2
	.type	FIR_DATA_DONE, @object
	.size	FIR_DATA_DONE, 4
FIR_DATA_DONE:
	.word	-16777216
	.globl	taps
	.data
	.align	2
	.type	taps, @object
	.size	taps, 44
taps:
	.word	0
	.word	-10
	.word	-9
	.word	23
	.word	56
	.word	63
	.word	56
	.word	23
	.word	-9
	.word	-10
	.word	0
	.globl	inputsignal
	.align	2
	.type	inputsignal, @object
	.size	inputsignal, 44
inputsignal:
	.word	1
	.word	2
	.word	3
	.word	4
	.word	5
	.word	6
	.word	7
	.word	8
	.word	9
	.word	10
	.word	11
	.globl	outputsignal
	.bss
	.align	2
	.type	outputsignal, @object
	.size	outputsignal, 44
outputsignal:
	.zero	44
	.globl	o_taps
	.align	2
	.type	o_taps, @object
	.size	o_taps, 44
o_taps:
	.zero	44
	.globl	ptr
	.section	.sbss,"aw",@nobits
	.align	2
	.type	ptr, @object
	.size	ptr, 4
ptr:
	.zero	4
	.globl	base_addr
	.section	.sdata,"aw"
	.align	2
	.type	base_addr, @object
	.size	base_addr, 4
base_addr:
	.word	805306368
	.globl	__mulsi3
	.section	.mprjram,"ax",@progbits
	.align	2
	.globl	fir
	.type	fir, @function
fir:
.LFB0:
	.file 1 "fir.c"
	.loc 1 4 56
	.cfi_startproc
	addi	sp,sp,-32
	.cfi_def_cfa_offset 32
	sw	ra,28(sp)
	sw	s0,24(sp)
	sw	s1,20(sp)
	.cfi_offset 1, -4
	.cfi_offset 8, -8
	.cfi_offset 9, -12
	addi	s0,sp,32
	.cfi_def_cfa 8, 0
.LBB2:
	.loc 1 6 10
	sw	zero,-20(s0)
	.loc 1 6 2
	j	.L2
.L5:
.LBB3:
	.loc 1 7 11
	sw	zero,-24(s0)
	.loc 1 7 3
	j	.L3
.L4:
	.loc 1 8 16 discriminator 3
	lui	a5,%hi(outputsignal)
	addi	a4,a5,%lo(outputsignal)
	lw	a5,-20(s0)
	slli	a5,a5,2
	add	a5,a4,a5
	lw	s1,0(a5)
	.loc 1 8 27 discriminator 3
	lui	a5,%hi(taps)
	addi	a4,a5,%lo(taps)
	lw	a5,-24(s0)
	slli	a5,a5,2
	add	a5,a4,a5
	lw	a3,0(a5)
	.loc 1 8 46 discriminator 3
	lw	a4,-20(s0)
	lw	a5,-24(s0)
	sub	a5,a4,a5
	.loc 1 8 44 discriminator 3
	lui	a4,%hi(inputsignal)
	addi	a4,a4,%lo(inputsignal)
	slli	a5,a5,2
	add	a5,a4,a5
	lw	a5,0(a5)
	.loc 1 8 31 discriminator 3
	mv	a1,a5
	mv	a0,a3
	call	__mulsi3
	mv	a5,a0
	.loc 1 8 20 discriminator 3
	add	a4,s1,a5
	lui	a5,%hi(outputsignal)
	addi	a3,a5,%lo(outputsignal)
	lw	a5,-20(s0)
	slli	a5,a5,2
	add	a5,a3,a5
	sw	a4,0(a5)
	.loc 1 7 26 discriminator 3
	lw	a5,-24(s0)
	addi	a5,a5,1
	sw	a5,-24(s0)
.L3:
	.loc 1 7 20 discriminator 1
	lw	a4,-24(s0)
	lw	a5,-20(s0)
	ble	a4,a5,.L4
.LBE3:
	.loc 1 6 25 discriminator 2
	lw	a5,-20(s0)
	addi	a5,a5,1
	sw	a5,-20(s0)
.L2:
	.loc 1 6 19 discriminator 1
	lw	a4,-20(s0)
	li	a5,10
	ble	a4,a5,.L5
.LBE2:
	.loc 1 11 9
	lui	a5,%hi(outputsignal)
	addi	a5,a5,%lo(outputsignal)
	.loc 1 12 1
	mv	a0,a5
	lw	ra,28(sp)
	.cfi_restore 1
	lw	s0,24(sp)
	.cfi_restore 8
	.cfi_def_cfa 2, 32
	lw	s1,20(sp)
	.cfi_restore 9
	addi	sp,sp,32
	.cfi_def_cfa_offset 0
	jr	ra
	.cfi_endproc
.LFE0:
	.size	fir, .-fir
	.align	2
	.globl	fir_tap
	.type	fir_tap, @function
fir_tap:
.LFB1:
	.loc 1 15 61
	.cfi_startproc
	addi	sp,sp,-32
	.cfi_def_cfa_offset 32
	sw	s0,28(sp)
	.cfi_offset 8, -4
	addi	s0,sp,32
	.cfi_def_cfa 8, 0
	.loc 1 16 8
	lui	a5,%hi(base_addr)
	lw	a5,%lo(base_addr)(a5)
	mv	a4,a5
	.loc 1 16 6
	lui	a5,%hi(ptr)
	sw	a4,%lo(ptr)(a5)
.LBB4:
	.loc 1 17 10
	sw	zero,-20(s0)
	.loc 1 17 2
	j	.L8
.L9:
	.loc 1 18 14 discriminator 3
	lui	a5,%hi(taps)
	addi	a4,a5,%lo(taps)
	lw	a5,-20(s0)
	slli	a5,a5,2
	add	a5,a4,a5
	lw	a4,0(a5)
	.loc 1 18 3 discriminator 3
	lui	a5,%hi(ptr)
	lw	a5,%lo(ptr)(a5)
	.loc 1 18 8 discriminator 3
	sw	a4,0(a5)
	.loc 1 17 25 discriminator 3
	lw	a5,-20(s0)
	addi	a5,a5,1
	sw	a5,-20(s0)
.L8:
	.loc 1 17 19 discriminator 1
	lw	a4,-20(s0)
	li	a5,10
	ble	a4,a5,.L9
.LBE4:
	.loc 1 20 9
	li	a4,-268435456
	.loc 1 20 2
	lui	a5,%hi(ptr)
	lw	a5,%lo(ptr)(a5)
	.loc 1 20 7
	sw	a4,0(a5)
	.loc 1 21 1
	nop
	lw	s0,28(sp)
	.cfi_restore 8
	.cfi_def_cfa 2, 32
	addi	sp,sp,32
	.cfi_def_cfa_offset 0
	jr	ra
	.cfi_endproc
.LFE1:
	.size	fir_tap, .-fir_tap
	.align	2
	.globl	fir_data
	.type	fir_data, @function
fir_data:
.LFB2:
	.loc 1 23 62
	.cfi_startproc
	addi	sp,sp,-32
	.cfi_def_cfa_offset 32
	sw	s0,28(sp)
	.cfi_offset 8, -4
	addi	s0,sp,32
	.cfi_def_cfa 8, 0
	.loc 1 24 8
	lui	a5,%hi(base_addr)
	lw	a5,%lo(base_addr)(a5)
	mv	a4,a5
	.loc 1 24 6
	lui	a5,%hi(ptr)
	sw	a4,%lo(ptr)(a5)
.LBB5:
	.loc 1 25 10
	sw	zero,-20(s0)
	.loc 1 25 2
	j	.L11
.L12:
	.loc 1 26 3 discriminator 3
	lui	a5,%hi(ptr)
	lw	a5,%lo(ptr)(a5)
	.loc 1 26 8 discriminator 3
	lw	a4,-20(s0)
	sw	a4,0(a5)
	.loc 1 25 28 discriminator 3
	lw	a5,-20(s0)
	addi	a5,a5,1
	sw	a5,-20(s0)
.L11:
	.loc 1 25 19 discriminator 1
	lw	a4,-20(s0)
	li	a5,62
	ble	a4,a5,.L12
.LBE5:
	.loc 1 28 6
	lui	a5,%hi(ptr)
	lw	a5,%lo(ptr)(a5)
	addi	a4,a5,4
	lui	a5,%hi(ptr)
	sw	a4,%lo(ptr)(a5)
	.loc 1 29 2
	lui	a5,%hi(ptr)
	lw	a5,%lo(ptr)(a5)
	.loc 1 29 7
	li	a4,63
	sw	a4,0(a5)
	.loc 1 30 9
	li	a4,-16777216
	.loc 1 30 2
	lui	a5,%hi(ptr)
	lw	a5,%lo(ptr)(a5)
	.loc 1 30 7
	sw	a4,0(a5)
	.loc 1 31 1
	nop
	lw	s0,28(sp)
	.cfi_restore 8
	.cfi_def_cfa 2, 32
	addi	sp,sp,32
	.cfi_def_cfa_offset 0
	jr	ra
	.cfi_endproc
.LFE2:
	.size	fir_data, .-fir_data
	.text
.Letext0:
	.file 2 "fir.h"
	.file 3 "/opt/riscv/lib/gcc/riscv32-unknown-elf/12.1.0/include/stdint-gcc.h"
	.section	.debug_info,"",@progbits
.Ldebug_info0:
	.4byte	0x1bf
	.2byte	0x5
	.byte	0x1
	.byte	0x4
	.4byte	.Ldebug_abbrev0
	.byte	0x7
	.4byte	.LASF20
	.byte	0x1d
	.4byte	.LASF0
	.4byte	.LASF1
	.4byte	.LLRL0
	.4byte	0
	.4byte	.Ldebug_line0
	.byte	0x1
	.byte	0x1
	.byte	0x6
	.4byte	.LASF2
	.byte	0x1
	.byte	0x2
	.byte	0x5
	.4byte	.LASF3
	.byte	0x1
	.byte	0x4
	.byte	0x5
	.4byte	.LASF4
	.byte	0x1
	.byte	0x8
	.byte	0x5
	.4byte	.LASF5
	.byte	0x1
	.byte	0x1
	.byte	0x8
	.4byte	.LASF6
	.byte	0x1
	.byte	0x2
	.byte	0x7
	.4byte	.LASF7
	.byte	0x8
	.4byte	.LASF21
	.byte	0x3
	.byte	0x34
	.byte	0x1b
	.4byte	0x61
	.byte	0x9
	.4byte	0x50
	.byte	0x1
	.byte	0x4
	.byte	0x7
	.4byte	.LASF8
	.byte	0x1
	.byte	0x8
	.byte	0x7
	.4byte	.LASF9
	.byte	0xa
	.byte	0x4
	.byte	0x5
	.string	"int"
	.byte	0xb
	.4byte	0x6f
	.byte	0x1
	.byte	0x4
	.byte	0x7
	.4byte	.LASF10
	.byte	0x2
	.4byte	.LASF11
	.byte	0x9
	.byte	0xb
	.4byte	0x76
	.byte	0x5
	.byte	0x3
	.4byte	AP_START
	.byte	0x2
	.4byte	.LASF12
	.byte	0xa
	.byte	0xb
	.4byte	0x76
	.byte	0x5
	.byte	0x3
	.4byte	FIR_DATA_DONE
	.byte	0xc
	.4byte	0x6f
	.4byte	0xb4
	.byte	0xd
	.4byte	0x7b
	.byte	0xa
	.byte	0
	.byte	0x2
	.4byte	.LASF13
	.byte	0xb
	.byte	0x5
	.4byte	0xa4
	.byte	0x5
	.byte	0x3
	.4byte	taps
	.byte	0x2
	.4byte	.LASF14
	.byte	0xc
	.byte	0x5
	.4byte	0xa4
	.byte	0x5
	.byte	0x3
	.4byte	inputsignal
	.byte	0x2
	.4byte	.LASF15
	.byte	0xd
	.byte	0x5
	.4byte	0xa4
	.byte	0x5
	.byte	0x3
	.4byte	outputsignal
	.byte	0x2
	.4byte	.LASF16
	.byte	0xe
	.byte	0x5
	.4byte	0xa4
	.byte	0x5
	.byte	0x3
	.4byte	o_taps
	.byte	0xe
	.string	"ptr"
	.byte	0x2
	.byte	0xf
	.byte	0x14
	.4byte	0x10a
	.byte	0x5
	.byte	0x3
	.4byte	ptr
	.byte	0x5
	.4byte	0x5c
	.byte	0x2
	.4byte	.LASF17
	.byte	0x10
	.byte	0x13
	.4byte	0x5c
	.byte	0x5
	.byte	0x3
	.4byte	base_addr
	.byte	0x6
	.4byte	.LASF18
	.byte	0x17
	.4byte	.LFB2
	.4byte	.LFE2-.LFB2
	.byte	0x1
	.byte	0x9c
	.4byte	0x14b
	.byte	0x3
	.4byte	.LBB5
	.4byte	.LBE5-.LBB5
	.byte	0x4
	.string	"i"
	.byte	0x19
	.byte	0xa
	.4byte	0x6f
	.byte	0x2
	.byte	0x91
	.byte	0x6c
	.byte	0
	.byte	0
	.byte	0x6
	.4byte	.LASF19
	.byte	0xf
	.4byte	.LFB1
	.4byte	.LFE1-.LFB1
	.byte	0x1
	.byte	0x9c
	.4byte	0x176
	.byte	0x3
	.4byte	.LBB4
	.4byte	.LBE4-.LBB4
	.byte	0x4
	.string	"i"
	.byte	0x11
	.byte	0xa
	.4byte	0x6f
	.byte	0x2
	.byte	0x91
	.byte	0x6c
	.byte	0
	.byte	0
	.byte	0xf
	.string	"fir"
	.byte	0x1
	.byte	0x4
	.byte	0x33
	.4byte	0x1bd
	.4byte	.LFB0
	.4byte	.LFE0-.LFB0
	.byte	0x1
	.byte	0x9c
	.4byte	0x1bd
	.byte	0x3
	.4byte	.LBB2
	.4byte	.LBE2-.LBB2
	.byte	0x4
	.string	"i"
	.byte	0x6
	.byte	0xa
	.4byte	0x6f
	.byte	0x2
	.byte	0x91
	.byte	0x6c
	.byte	0x3
	.4byte	.LBB3
	.4byte	.LBE3-.LBB3
	.byte	0x4
	.string	"j"
	.byte	0x7
	.byte	0xb
	.4byte	0x6f
	.byte	0x2
	.byte	0x91
	.byte	0x68
	.byte	0
	.byte	0
	.byte	0
	.byte	0x5
	.4byte	0x6f
	.byte	0
	.section	.debug_abbrev,"",@progbits
.Ldebug_abbrev0:
	.byte	0x1
	.byte	0x24
	.byte	0
	.byte	0xb
	.byte	0xb
	.byte	0x3e
	.byte	0xb
	.byte	0x3
	.byte	0xe
	.byte	0
	.byte	0
	.byte	0x2
	.byte	0x34
	.byte	0
	.byte	0x3
	.byte	0xe
	.byte	0x3a
	.byte	0x21
	.byte	0x2
	.byte	0x3b
	.byte	0xb
	.byte	0x39
	.byte	0xb
	.byte	0x49
	.byte	0x13
	.byte	0x3f
	.byte	0x19
	.byte	0x2
	.byte	0x18
	.byte	0
	.byte	0
	.byte	0x3
	.byte	0xb
	.byte	0x1
	.byte	0x11
	.byte	0x1
	.byte	0x12
	.byte	0x6
	.byte	0
	.byte	0
	.byte	0x4
	.byte	0x34
	.byte	0
	.byte	0x3
	.byte	0x8
	.byte	0x3a
	.byte	0x21
	.byte	0x1
	.byte	0x3b
	.byte	0xb
	.byte	0x39
	.byte	0xb
	.byte	0x49
	.byte	0x13
	.byte	0x2
	.byte	0x18
	.byte	0
	.byte	0
	.byte	0x5
	.byte	0xf
	.byte	0
	.byte	0xb
	.byte	0x21
	.byte	0x4
	.byte	0x49
	.byte	0x13
	.byte	0
	.byte	0
	.byte	0x6
	.byte	0x2e
	.byte	0x1
	.byte	0x3f
	.byte	0x19
	.byte	0x3
	.byte	0xe
	.byte	0x3a
	.byte	0x21
	.byte	0x1
	.byte	0x3b
	.byte	0xb
	.byte	0x39
	.byte	0x21
	.byte	0x33
	.byte	0x11
	.byte	0x1
	.byte	0x12
	.byte	0x6
	.byte	0x40
	.byte	0x18
	.byte	0x7a
	.byte	0x19
	.byte	0x1
	.byte	0x13
	.byte	0
	.byte	0
	.byte	0x7
	.byte	0x11
	.byte	0x1
	.byte	0x25
	.byte	0xe
	.byte	0x13
	.byte	0xb
	.byte	0x3
	.byte	0x1f
	.byte	0x1b
	.byte	0x1f
	.byte	0x55
	.byte	0x17
	.byte	0x11
	.byte	0x1
	.byte	0x10
	.byte	0x17
	.byte	0
	.byte	0
	.byte	0x8
	.byte	0x16
	.byte	0
	.byte	0x3
	.byte	0xe
	.byte	0x3a
	.byte	0xb
	.byte	0x3b
	.byte	0xb
	.byte	0x39
	.byte	0xb
	.byte	0x49
	.byte	0x13
	.byte	0
	.byte	0
	.byte	0x9
	.byte	0x35
	.byte	0
	.byte	0x49
	.byte	0x13
	.byte	0
	.byte	0
	.byte	0xa
	.byte	0x24
	.byte	0
	.byte	0xb
	.byte	0xb
	.byte	0x3e
	.byte	0xb
	.byte	0x3
	.byte	0x8
	.byte	0
	.byte	0
	.byte	0xb
	.byte	0x26
	.byte	0
	.byte	0x49
	.byte	0x13
	.byte	0
	.byte	0
	.byte	0xc
	.byte	0x1
	.byte	0x1
	.byte	0x49
	.byte	0x13
	.byte	0x1
	.byte	0x13
	.byte	0
	.byte	0
	.byte	0xd
	.byte	0x21
	.byte	0
	.byte	0x49
	.byte	0x13
	.byte	0x2f
	.byte	0xb
	.byte	0
	.byte	0
	.byte	0xe
	.byte	0x34
	.byte	0
	.byte	0x3
	.byte	0x8
	.byte	0x3a
	.byte	0xb
	.byte	0x3b
	.byte	0xb
	.byte	0x39
	.byte	0xb
	.byte	0x49
	.byte	0x13
	.byte	0x3f
	.byte	0x19
	.byte	0x2
	.byte	0x18
	.byte	0
	.byte	0
	.byte	0xf
	.byte	0x2e
	.byte	0x1
	.byte	0x3f
	.byte	0x19
	.byte	0x3
	.byte	0x8
	.byte	0x3a
	.byte	0xb
	.byte	0x3b
	.byte	0xb
	.byte	0x39
	.byte	0xb
	.byte	0x49
	.byte	0x13
	.byte	0x11
	.byte	0x1
	.byte	0x12
	.byte	0x6
	.byte	0x40
	.byte	0x18
	.byte	0x7c
	.byte	0x19
	.byte	0x1
	.byte	0x13
	.byte	0
	.byte	0
	.byte	0
	.section	.debug_aranges,"",@progbits
	.4byte	0x2c
	.2byte	0x2
	.4byte	.Ldebug_info0
	.byte	0x4
	.byte	0
	.2byte	0
	.2byte	0
	.4byte	.LFB0
	.4byte	.LFE0-.LFB0
	.4byte	.LFB1
	.4byte	.LFE1-.LFB1
	.4byte	.LFB2
	.4byte	.LFE2-.LFB2
	.4byte	0
	.4byte	0
	.section	.debug_rnglists,"",@progbits
.Ldebug_ranges0:
	.4byte	.Ldebug_ranges3-.Ldebug_ranges2
.Ldebug_ranges2:
	.2byte	0x5
	.byte	0x4
	.byte	0
	.4byte	0
.LLRL0:
	.byte	0x6
	.4byte	.LFB0
	.4byte	.LFE0
	.byte	0x6
	.4byte	.LFB1
	.4byte	.LFE1
	.byte	0x6
	.4byte	.LFB2
	.4byte	.LFE2
	.byte	0
.Ldebug_ranges3:
	.section	.debug_line,"",@progbits
.Ldebug_line0:
	.section	.debug_str,"MS",@progbits,1
.LASF14:
	.string	"inputsignal"
.LASF6:
	.string	"unsigned char"
.LASF8:
	.string	"long unsigned int"
.LASF7:
	.string	"short unsigned int"
.LASF20:
	.string	"GNU C17 12.1.0 -mabi=ilp32 -mtune=rocket -misa-spec=2.2 -march=rv32i -g -ffreestanding"
.LASF18:
	.string	"fir_data"
.LASF17:
	.string	"base_addr"
.LASF10:
	.string	"unsigned int"
.LASF13:
	.string	"taps"
.LASF12:
	.string	"FIR_DATA_DONE"
.LASF9:
	.string	"long long unsigned int"
.LASF16:
	.string	"o_taps"
.LASF19:
	.string	"fir_tap"
.LASF15:
	.string	"outputsignal"
.LASF5:
	.string	"long long int"
.LASF3:
	.string	"short int"
.LASF21:
	.string	"uint32_t"
.LASF4:
	.string	"long int"
.LASF11:
	.string	"AP_START"
.LASF2:
	.string	"signed char"
	.section	.debug_line_str,"MS",@progbits,1
.LASF0:
	.string	"fir.c"
.LASF1:
	.string	"/home/ponponri/Desktop/shared_folder/LAB4_2/lab-exmem_fir/testbench/counter_la_fir"
	.ident	"GCC: (g1ea978e3066) 12.1.0"
