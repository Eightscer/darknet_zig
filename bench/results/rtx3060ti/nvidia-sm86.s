	.headerflags	@"EF_CUDA_TEXMODE_UNIFIED EF_CUDA_64BIT_ADDRESS EF_CUDA_SM86 EF_CUDA_VIRTUAL_SM(EF_CUDA_SM86)"
	.elftype	@"ET_EXEC"


//--------------------- .text.gemm_kernel         --------------------------
	.section	.text.gemm_kernel,"ax",@progbits
	.sectionflags	@"SHF_BARRIERS=1"
	.sectioninfo	@"SHI_REGISTERS=37"
	.align	128
        .global         gemm_kernel
        .type           gemm_kernel,@function
        .size           gemm_kernel,(.L_x_448 - gemm_kernel)
        .other          gemm_kernel,@"STO_CUDA_ENTRY STV_DEFAULT"
gemm_kernel:
.text.gemm_kernel:
        /*0000*/                   MOV R1, c[0x0][0x28] ;
        /*0010*/                   S2R R6, SR_CTAID.X ;
        /*0020*/                   IMAD.MOV.U32 R4, RZ, RZ, c[0x0][0x170] ;
        /*0030*/                   ULDC.64 UR6, c[0x0][0x118] ;
        /*0040*/                   IMAD.MOV.U32 R9, RZ, RZ, RZ ;
        /*0050*/                   S2R R2, SR_TID.X ;
        /*0060*/                   ISETP.GE.AND P1, PT, R4, 0x1, PT ;
        /*0070*/                   S2R R7, SR_CTAID.Y ;
        /*0080*/                   S2R R17, SR_TID.Y ;
        /*0090*/                   LEA R0, R6, R2, 0x4 ;
        /*00a0*/                   ISETP.GE.AND P0, PT, R0, c[0x0][0x16c], PT ;
        /*00b0*/                   LEA R3, R7, R17, 0x4 ;
        /*00c0*/                   ISETP.GE.OR P0, PT, R3, c[0x0][0x168], P0 ;
        /*00d0*/              @!P1 BRA `(.L_x_0) ;
        /*00e0*/                   IADD3 R4, R4, 0xf, RZ ;
        /*00f0*/                   IMAD R19, R17.reuse, c[0x0][0x190], R2 ;
        /*0100*/                   SHF.L.U32 R21, R17, 0x6, RZ ;
        /*0110*/                   IMAD R18, R2, c[0x0][0x180], R17.reuse ;
        /*0120*/                   SHF.R.S32.HI R5, RZ, 0x1f, R4 ;
        /*0130*/                   IMAD.MOV.U32 R9, RZ, RZ, RZ ;
        /*0140*/                   LEA R19, R6, R19, 0x4 ;
        /*0150*/                   IMAD R16, R0, c[0x0][0x190], R17 ;
        /*0160*/                   LEA.HI R5, R5, R4, RZ, 0x4 ;
        /*0170*/                   IMAD R23, R3, c[0x0][0x180], R2 ;
        /*0180*/                   LEA R18, R7, R18, 0x4 ;
        /*0190*/                   UMOV UR4, URZ ;
        /*01a0*/                   LEA R20, R2, 0x400, 0x2 ;
        /*01b0*/                   LEA R24, R2, R21, 0x2 ;
        /*01c0*/                   SHF.R.S32.HI R22, RZ, 0x4, R5 ;
.L_x_1:
        /*01d0*/                   ISETP.GE.AND P1, PT, R2, c[0x0][0x170], PT ;
        /*01e0*/                   IMAD.MOV.U32 R27, RZ, RZ, RZ ;
        /*01f0*/                   ISETP.GE.AND P2, PT, R17, c[0x0][0x170], PT ;
        /*0200*/                   ISETP.GE.OR P1, PT, R3, c[0x0][0x168], P1 ;
        /*0210*/                   ISETP.GE.OR P2, PT, R0, c[0x0][0x16c], P2 ;
        /*0220*/                   MOV R25, RZ ;
        /*0230*/              @!P1 ISETP.NE.AND P3, PT, RZ, c[0x0][0x160], PT ;
        /*0240*/              @!P1 IMAD.MOV.U32 R5, RZ, RZ, 0x4 ;
        /*0250*/              @!P2 ISETP.NE.AND P4, PT, RZ, c[0x0][0x164], PT ;
        /*0260*/              @!P2 MOV R11, 0x4 ;
        /*0270*/              @!P1 SEL R4, R23, R18, !P3 ;
        /*0280*/              @!P2 SEL R10, R19, R16, !P4 ;
        /*0290*/              @!P1 IMAD.WIDE R4, R4, R5, c[0x0][0x178] ;
        /*02a0*/              @!P2 IMAD.WIDE R10, R10, R11, c[0x0][0x188] ;
        /*02b0*/              @!P1 LDG.E R25, [R4.64] ;
        /*02c0*/              @!P2 LDG.E R27, [R10.64] ;
        /*02d0*/                   UIADD3 UR4, UR4, 0x1, URZ ;
        /*02e0*/                   IADD3 R17, R17, 0x10, RZ ;
        /*02f0*/                   IADD3 R2, R2, 0x10, RZ ;
        /*0300*/                   IADD3 R16, R16, 0x10, RZ ;
        /*0310*/                   ISETP.LE.AND P1, PT, R22, UR4, PT ;
        /*0320*/                   IADD3 R23, R23, 0x10, RZ ;
        /*0330*/                   STS [R24], R25 ;
        /*0340*/                   STS [R24+0x400], R27 ;
        /*0350*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*0360*/                   LDS R8, [R20] ;
        /*0370*/                   LDS.128 R12, [R21] ;
        /*0380*/                   LDS R29, [R20+0x40] ;
        /*0390*/                   LDS R34, [R20+0x80] ;
        /*03a0*/                   LDS R32, [R20+0xc0] ;
        /*03b0*/                   LDS R31, [R20+0x100] ;
        /*03c0*/                   LDS.128 R4, [R21+0x10] ;
        /*03d0*/                   LDS R28, [R20+0x140] ;
        /*03e0*/                   LDS R25, [R20+0x180] ;
        /*03f0*/                   LDS R26, [R20+0x1c0] ;
        /*0400*/                   LDS R27, [R20+0x200] ;
        /*0410*/                   FFMA R12, R8, R12, R9 ;
        /*0420*/                   LDS R30, [R20+0x240] ;
        /*0430*/                   FFMA R13, R29, R13, R12 ;
        /*0440*/                   LDS.128 R8, [R21+0x20] ;
        /*0450*/                   FFMA R13, R34, R14, R13 ;
        /*0460*/                   LDS R29, [R20+0x280] ;
        /*0470*/                   FFMA R12, R32, R15, R13 ;
        /*0480*/                   LDS R32, [R20+0x2c0] ;
        /*0490*/                   FFMA R33, R31, R4, R12 ;
        /*04a0*/                   LDS R31, [R20+0x300] ;
        /*04b0*/                   FFMA R34, R28, R5, R33 ;
        /*04c0*/                   LDS.128 R12, [R21+0x30] ;
        /*04d0*/                   FFMA R25, R25, R6, R34 ;
        /*04e0*/                   MOV R6, 0x10 ;
        /*04f0*/                   LDS R28, [R20+0x340] ;
        /*0500*/                   FFMA R26, R26, R7, R25 ;
        /*0510*/                   LDS R5, [R20+0x380] ;
        /*0520*/                   IMAD R19, R6.reuse, c[0x0][0x190], R19 ;
        /*0530*/                   IMAD R18, R6, c[0x0][0x180], R18 ;
        /*0540*/                   LDS R4, [R20+0x3c0] ;
        /*0550*/                   FFMA R27, R27, R8, R26 ;
        /*0560*/                   FFMA R30, R30, R9, R27 ;
        /*0570*/                   FFMA R29, R29, R10, R30 ;
        /*0580*/                   FFMA R32, R32, R11, R29 ;
        /*0590*/                   FFMA R31, R31, R12, R32 ;
        /*05a0*/                   FFMA R28, R28, R13, R31 ;
        /*05b0*/                   FFMA R5, R5, R14, R28 ;
        /*05c0*/                   FFMA R9, R4, R15, R5 ;
        /*05d0*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*05e0*/              @!P1 BRA `(.L_x_1) ;
.L_x_0:
        /*05f0*/               @P0 EXIT ;
        /*0600*/                   FSETP.NEU.AND P0, PT, RZ, c[0x0][0x194], PT ;
        /*0610*/                   IMAD R3, R3, c[0x0][0x1a0], R0 ;
        /*0620*/                   MOV R2, 0x4 ;
        /*0630*/                   FMUL R9, R9, c[0x0][0x174] ;
        /*0640*/                   IMAD.WIDE R2, R3, R2, c[0x0][0x198] ;
        /*0650*/              @!P0 BRA `(.L_x_2) ;
        /*0660*/                   LDG.E R0, [R2.64] ;
        /*0670*/                   FFMA R9, R0, c[0x0][0x194], R9 ;
.L_x_2:
        /*0680*/                   STG.E [R2.64], R9 ;
        /*0690*/                   EXIT ;
.L_x_3:
        /*06a0*/                   BRA `(.L_x_3);
        /*06b0*/                   NOP;
        /*06c0*/                   NOP;
        /*06d0*/                   NOP;
        /*06e0*/                   NOP;
        /*06f0*/                   NOP;
        /*0700*/                   NOP;
        /*0710*/                   NOP;
        /*0720*/                   NOP;
        /*0730*/                   NOP;
        /*0740*/                   NOP;
        /*0750*/                   NOP;
        /*0760*/                   NOP;
        /*0770*/                   NOP;
.L_x_448:


//--------------------- .text.adam_kernel         --------------------------
	.section	.text.adam_kernel,"ax",@progbits
	.sectioninfo	@"SHI_REGISTERS=21"
	.align	128
        .global         adam_kernel
        .type           adam_kernel,@function
        .size           adam_kernel,(.L_x_434 - adam_kernel)
        .other          adam_kernel,@"STO_CUDA_ENTRY STV_DEFAULT"
adam_kernel:
.text.adam_kernel:
        /*0000*/                   MOV R1, c[0x0][0x28] ;
        /*0010*/                   S2R R2, SR_CTAID.X ;
        /*0020*/                   S2R R3, SR_TID.X ;
        /*0030*/                   IMAD R2, R2, c[0x0][0x0], R3 ;
        /*0040*/                   ISETP.GE.AND P0, PT, R2, c[0x0][0x160], PT ;
        /*0050*/               @P0 EXIT ;
        /*0060*/                   MOV R3, c[0x0][0x180] ;
        /*0070*/                   IMAD.MOV.U32 R5, RZ, RZ, 0x4 ;
        /*0080*/                   ULDC.64 UR4, c[0x0][0x118] ;
        /*0090*/                   FSETP.GEU.AND P0, PT, |R3|.reuse, 1.175494350822287508e-38, PT ;
        /*00a0*/                   FMUL R6, |R3|, 16777216 ;
        /*00b0*/                   IMAD.WIDE R4, R2, R5, c[0x0][0x170] ;
        /*00c0*/                   FSEL R6, R6, |c[0x0][0x180]|, !P0 ;
        /*00d0*/                   LDG.E R0, [R4.64] ;
        /*00e0*/                   MOV R10, 0x3a2c32e4 ;
        /*00f0*/                   IADD3 R7, R6, -0x3f3504f3, RZ ;
        /*0100*/                   LOP3.LUT R7, R7, 0xff800000, RZ, 0xc0, !PT ;
        /*0110*/                   FSEL R4, RZ, -24, P0 ;
        /*0120*/                   IMAD.IADD R6, R6, 0x1, -R7 ;
        /*0130*/                   I2FP.F32.S32 R7, R7 ;
        /*0140*/                   FADD R8, R6.reuse, 1 ;
        /*0150*/                   FADD R6, R6, -1 ;
        /*0160*/                   FFMA R4, R7, 1.1920928955078125e-07, R4 ;
        /*0170*/                   FADD R5, R6, R6 ;
        /*0180*/                   MUFU.RCP R8, R8 ;
        /*0190*/                   FMUL R5, R8, R5 ;
        /*01a0*/                   FADD R9, R6, -R5 ;
        /*01b0*/                   FMUL R7, R5.reuse, R5.reuse ;
        /*01c0*/                   FFMA R11, R5, 1.4426950216293334961, R4 ;
        /*01d0*/                   FADD R9, R9, R9 ;
        /*01e0*/                   FFMA R10, R7.reuse, R10, 0.0032181653659790754318 ;
        /*01f0*/                   FADD R4, R4, -R11 ;
        /*0200*/                   FFMA R9, R6, -R5, R9 ;
        /*0210*/                   FFMA R10, R7, R10, 0.018033718690276145935 ;
        /*0220*/                   FFMA R4, R5, 1.4426950216293334961, R4 ;
        /*0230*/                   FMUL R9, R8, R9 ;
        /*0240*/                   FFMA R10, R7, R10, 0.12022458761930465698 ;
        /*0250*/                   FFMA R4, R9, 1.4426950216293334961, R4 ;
        /*0260*/                   FMUL R10, R7, R10 ;
        /*0270*/                   FFMA R4, R5, 1.9251366722983220825e-08, R4 ;
        /*0280*/                   FMUL R6, R10, 3 ;
        /*0290*/                   FFMA R9, R9, R6, R4 ;
        /*02a0*/                   I2FP.F32.S32 R4, c[0x0][0x190] ;
        /*02b0*/                   FFMA R10, R5, R10, R9 ;
        /*02c0*/                   IMAD.MOV.U32 R9, RZ, RZ, 0x391fcb8e ;
        /*02d0*/                   FADD R5, R11, R10 ;
        /*02e0*/                   FMUL R7, R4, R5 ;
        /*02f0*/                   FADD R11, -R11, R5 ;
        /*0300*/                   FRND R8, R7 ;
        /*0310*/                   FADD R11, R10, -R11 ;
        /*0320*/                   FFMA R6, R4.reuse, R5, -R7 ;
        /*0330*/                   FSETP.GT.AND P1, PT, |R7|.reuse, 152, PT ;
        /*0340*/                   FSETP.GEU.AND P3, PT, R7.reuse, RZ, PT ;
        /*0350*/                   FFMA R6, R4, R11, R6 ;
        /*0360*/                   F2I.NTZ R10, R7 ;
        /*0370*/                   FADD R5, R7, -R8 ;
        /*0380*/                   FSETP.GT.AND P0, PT, R8, RZ, PT ;
        /*0390*/                   FADD R6, R6, R5 ;
        /*03a0*/                   SEL R11, RZ, 0x83000000, P0 ;
        /*03b0*/                   ISETP.NE.AND P0, PT, RZ, c[0x0][0x190], PT ;
        /*03c0*/                   FFMA R5, R6.reuse, R9, 0.0013391353422775864601 ;
        /*03d0*/                   IADD3 R8, R11, 0x7f000000, RZ ;
        /*03e0*/                   FSETP.EQ.OR P2, PT, R3, 1, !P0 ;
        /*03f0*/                   FFMA R5, R6, R5, 0.0096188392490148544312 ;
        /*0400*/                   LEA R11, R10, -R11, 0x17 ;
        /*0410*/                   FFMA R9, R6, R5, 0.055503588169813156128 ;
        /*0420*/                   FMUL R5, R4, 0.5 ;
        /*0430*/                   FFMA R9, R6, R9, 0.24022644758224487305 ;
        /*0440*/                   FRND.TRUNC R5, R5 ;
        /*0450*/                   FFMA R9, R6, R9, 0.69314718246459960938 ;
        /*0460*/                   FFMA R9, R6, R9, 1 ;
        /*0470*/                   IMAD.MOV.U32 R6, RZ, RZ, 0x3f800000 ;
        /*0480*/                   FMUL R8, R9, R8 ;
        /*0490*/                   SHF.R.S32.HI R9, RZ, 0x1f, R2 ;
        /*04a0*/                   FMUL R8, R8, R11 ;
        /*04b0*/               @P1 FSEL R8, RZ, +INF , !P3 ;
        /*04c0*/                   FADD R5, R5, R5 ;
        /*04d0*/                   FADD R5, R4, -R5 ;
        /*04e0*/               @P2 BRA `(.L_x_4) ;
        /*04f0*/                   FSETP.GTU.AND P1, PT, |R4|, +INF , PT ;
        /*0500*/                   FSETP.GTU.OR P1, PT, |R3|, +INF , P1 ;
        /*0510*/               @P1 BRA `(.L_x_5) ;
        /*0520*/                   FSETP.NEU.AND P1, PT, |R3|, +INF , PT ;
        /*0530*/                   FSETP.EQ.OR P1, PT, RZ, c[0x0][0x180], !P1 ;
        /*0540*/              @!P1 BRA `(.L_x_6) ;
        /*0550*/                   ISETP.LE.AND P2, PT, RZ, c[0x0][0x190], PT ;
        /*0560*/                   FADD R6, R3, c[0x0][0x180] ;
        /*0570*/                   FSETP.NEU.AND P1, PT, |R5|, 1, PT ;
        /*0580*/              @!P2 LOP3.LUT R6, R6, 0x7f800000, RZ, 0x3c, !PT ;
        /*0590*/               @P1 LOP3.LUT R6, R6, 0x7fffffff, RZ, 0xc0, !PT ;
        /*05a0*/                   BRA `(.L_x_4) ;
.L_x_6:
        /*05b0*/                   FSETP.EQ.AND P2, PT, R3, -1, PT ;
        /*05c0*/                   FSETP.NEU.AND P1, PT, |R4|, +INF , PT ;
        /*05d0*/                   MOV R6, 0x3f800000 ;
        /*05e0*/              @!P1 BRA P2, `(.L_x_4) ;
        /*05f0*/                   FSETP.LEU.AND P1, PT, RZ, c[0x0][0x180], PT ;
        /*0600*/                   IMAD.MOV.U32 R6, RZ, RZ, R8 ;
        /*0610*/               @P1 BRA `(.L_x_4) ;
        /*0620*/                   FRND.FLOOR R3, R4 ;
        /*0630*/                   FSETP.NEU.AND P2, PT, |R5|, 1, PT ;
        /*0640*/                   FSEL R6, -R8, R8, !P2 ;
        /*0650*/                   FSETP.NEU.AND P1, PT, R3, R4, PT ;
        /*0660*/                   FSEL R6, R6, +QNAN , !P1 ;
        /*0670*/                   BRA `(.L_x_4) ;
.L_x_5:
        /*0680*/                   FADD R6, R4, c[0x0][0x180] ;
.L_x_4:
        /*0690*/                   FADD R11, -R6, 1 ;
        /*06a0*/                   BSSY B0, `(.L_x_7) ;
        /*06b0*/                   MUFU.RCP R3, R11 ;
        /*06c0*/                   FCHK P1, R0, R11 ;
        /*06d0*/                   FFMA R6, -R11, R3, 1 ;
        /*06e0*/                   FFMA R3, R3, R6, R3 ;
        /*06f0*/                   MOV R6, 0x3f800000 ;
        /*0700*/                   FFMA R8, R0, R3, RZ ;
        /*0710*/                   FFMA R7, -R11, R8, R0 ;
        /*0720*/                   FFMA R7, R3, R7, R8 ;
        /*0730*/              @!P1 BRA `(.L_x_8) ;
        /*0740*/                   IMAD.MOV.U32 R3, RZ, RZ, R11 ;
        /*0750*/                   MOV R10, 0x770 ;
        /*0760*/                   CALL.REL.NOINC `($__internal_1_$__cuda_sm3x_div_rn_noftz_f32_slowpath) ;
        /*0770*/                   MOV R7, R3 ;
.L_x_8:
        /*0780*/                   BSYNC B0 ;
.L_x_7:
        /*0790*/                   IMAD.SHL.U32 R8, R2.reuse, 0x4, RZ ;
        /*07a0*/                   MOV R3, c[0x0][0x184] ;
        /*07b0*/                   SHF.L.U64.HI R2, R2, 0x2, R9 ;
        /*07c0*/                   IADD3 R10, P1, R8, c[0x0][0x178], RZ ;
        /*07d0*/                   FMUL R9, |R3|, 16777216 ;
        /*07e0*/                   IADD3.X R11, R2, c[0x0][0x17c], RZ, P1, !PT ;
        /*07f0*/                   FSETP.GEU.AND P1, PT, |R3|, 1.175494350822287508e-38, PT ;
        /*0800*/                   LDG.E R0, [R10.64] ;
        /*0810*/                   FSEL R9, R9, |c[0x0][0x184]|, !P1 ;
        /*0820*/                   MOV R16, 0x3a2c32e4 ;
        /*0830*/                   IADD3 R12, R9, -0x3f3504f3, RZ ;
        /*0840*/                   FSETP.EQ.OR P0, PT, R3, 1, !P0 ;
        /*0850*/                   LOP3.LUT R12, R12, 0xff800000, RZ, 0xc0, !PT ;
        /*0860*/                   IMAD.IADD R9, R9, 0x1, -R12 ;
        /*0870*/                   I2FP.F32.S32 R12, R12 ;
        /*0880*/                   FADD R14, R9.reuse, 1 ;
        /*0890*/                   FADD R13, R9, -1 ;
        /*08a0*/                   FSEL R9, RZ, -24, P1 ;
        /*08b0*/                   FADD R11, R13, R13 ;
        /*08c0*/                   MUFU.RCP R14, R14 ;
        /*08d0*/                   FFMA R9, R12, 1.1920928955078125e-07, R9 ;
        /*08e0*/                   FMUL R10, R14, R11 ;
        /*08f0*/                   FADD R12, R13, -R10 ;
        /*0900*/                   FMUL R11, R10.reuse, R10 ;
        /*0910*/                   FFMA R18, R10, 1.4426950216293334961, R9 ;
        /*0920*/                   FADD R12, R12, R12 ;
        /*0930*/                   FFMA R16, R11, R16, 0.0032181653659790754318 ;
        /*0940*/                   FADD R9, R9, -R18 ;
        /*0950*/                   FFMA R13, R13, -R10, R12 ;
        /*0960*/                   FFMA R16, R11, R16, 0.018033718690276145935 ;
        /*0970*/                   FFMA R12, R10, 1.4426950216293334961, R9 ;
        /*0980*/                   FMUL R13, R14, R13 ;
        /*0990*/                   FFMA R16, R11, R16, 0.12022458761930465698 ;
        /*09a0*/                   IMAD.MOV.U32 R14, RZ, RZ, 0x391fcb8e ;
        /*09b0*/                   FFMA R9, R13, 1.4426950216293334961, R12 ;
        /*09c0*/                   FMUL R11, R11, R16 ;
        /*09d0*/                   FFMA R12, R10, 1.9251366722983220825e-08, R9 ;
        /*09e0*/                   FMUL R9, R11, 3 ;
        /*09f0*/                   FFMA R12, R13, R9, R12 ;
        /*0a00*/                   FFMA R11, R10, R11, R12 ;
        /*0a10*/                   FADD R9, R18, R11 ;
        /*0a20*/                   FMUL R13, R4, R9 ;
        /*0a30*/                   FADD R18, -R18, R9 ;
        /*0a40*/                   FRND R12, R13 ;
        /*0a50*/                   FADD R11, R11, -R18 ;
        /*0a60*/                   FFMA R10, R4, R9, -R13 ;
        /*0a70*/                   FSETP.GEU.AND P2, PT, R13, RZ, PT ;
        /*0a80*/                   FFMA R10, R4, R11, R10 ;
        /*0a90*/                   F2I.NTZ R11, R13 ;
        /*0aa0*/                   FADD R9, R13, -R12 ;
        /*0ab0*/                   FSETP.GT.AND P1, PT, R12, RZ, PT ;
        /*0ac0*/                   FADD R9, R10, R9 ;
        /*0ad0*/                   SEL R12, RZ, 0x83000000, P1 ;
        /*0ae0*/                   FSETP.GT.AND P1, PT, |R13|, 152, PT ;
        /*0af0*/                   FFMA R10, R9, R14, 0.0013391353422775864601 ;
        /*0b00*/                   FFMA R10, R9, R10, 0.0096188392490148544312 ;
        /*0b10*/                   FFMA R10, R9, R10, 0.055503588169813156128 ;
        /*0b20*/                   FFMA R10, R9, R10, 0.24022644758224487305 ;
        /*0b30*/                   FFMA R10, R9, R10, 0.69314718246459960938 ;
        /*0b40*/                   FFMA R10, R9, R10, 1 ;
        /*0b50*/                   IADD3 R9, R12, 0x7f000000, RZ ;
        /*0b60*/                   LEA R12, R11, -R12, 0x17 ;
        /*0b70*/                   FMUL R9, R10, R9 ;
        /*0b80*/                   FMUL R9, R9, R12 ;
        /*0b90*/               @P1 FSEL R9, RZ, +INF , !P2 ;
        /*0ba0*/               @P0 BRA `(.L_x_9) ;
        /*0bb0*/                   FSETP.GTU.AND P0, PT, |R4|, +INF , PT ;
        /*0bc0*/                   FSETP.GTU.OR P0, PT, |R3|, +INF , P0 ;
        /*0bd0*/               @P0 BRA `(.L_x_10) ;
        /*0be0*/                   FSETP.NEU.AND P0, PT, |R3|, +INF , PT ;
        /*0bf0*/                   FSETP.EQ.OR P0, PT, RZ, c[0x0][0x184], !P0 ;
        /*0c00*/              @!P0 BRA `(.L_x_11) ;
        /*0c10*/                   ISETP.LE.AND P1, PT, RZ, c[0x0][0x190], PT ;
        /*0c20*/                   FADD R6, R3, c[0x0][0x184] ;
        /*0c30*/                   FSETP.NEU.AND P0, PT, |R5|, 1, PT ;
        /*0c40*/              @!P1 LOP3.LUT R6, R6, 0x7f800000, RZ, 0x3c, !PT ;
        /*0c50*/               @P0 LOP3.LUT R6, R6, 0x7fffffff, RZ, 0xc0, !PT ;
        /*0c60*/                   BRA `(.L_x_9) ;
.L_x_11:
        /*0c70*/                   FSETP.EQ.AND P1, PT, R3, -1, PT ;
        /*0c80*/                   IMAD.MOV.U32 R6, RZ, RZ, 0x3f800000 ;
        /*0c90*/                   FSETP.NEU.AND P0, PT, |R4|, +INF , PT ;
        /*0ca0*/              @!P0 BRA P1, `(.L_x_9) ;
        /*0cb0*/                   FSETP.LEU.AND P0, PT, RZ, c[0x0][0x184], PT ;
        /*0cc0*/                   MOV R6, R9 ;
        /*0cd0*/               @P0 BRA `(.L_x_9) ;
        /*0ce0*/                   FRND.FLOOR R3, R4 ;
        /*0cf0*/                   FSETP.NEU.AND P0, PT, |R5|, 1, PT ;
        /*0d00*/                   FSEL R6, -R9, R9, !P0 ;
        /*0d10*/                   FSETP.NEU.AND P1, PT, R3, R4, PT ;
        /*0d20*/                   FSEL R6, R6, +QNAN , !P1 ;
        /*0d30*/                   BRA `(.L_x_9) ;
.L_x_10:
        /*0d40*/                   FADD R6, R4, c[0x0][0x184] ;
.L_x_9:
        /*0d50*/                   FADD R9, -R6, 1 ;
        /*0d60*/                   BSSY B0, `(.L_x_12) ;
        /*0d70*/                   MUFU.RCP R3, R9 ;
        /*0d80*/                   FCHK P0, R0, R9 ;
        /*0d90*/                   FFMA R4, -R9, R3, 1 ;
        /*0da0*/                   FFMA R3, R3, R4, R3 ;
        /*0db0*/                   FFMA R4, R0, R3, RZ ;
        /*0dc0*/                   FFMA R5, -R9, R4, R0 ;
        /*0dd0*/                   FFMA R3, R3, R5, R4 ;
        /*0de0*/              @!P0 BRA `(.L_x_13) ;
        /*0df0*/                   IMAD.MOV.U32 R3, RZ, RZ, R9 ;
        /*0e00*/                   MOV R10, 0xe20 ;
        /*0e10*/                   CALL.REL.NOINC `($__internal_1_$__cuda_sm3x_div_rn_noftz_f32_slowpath) ;
.L_x_13:
        /*0e20*/                   BSYNC B0 ;
.L_x_12:
        /*0e30*/                   IADD3 R0, R3, -0xd000000, RZ ;
        /*0e40*/                   MUFU.RSQ R4, R3 ;
        /*0e50*/                   BSSY B0, `(.L_x_14) ;
        /*0e60*/                   ISETP.GT.U32.AND P0, PT, R0, 0x727fffff, PT ;
        /*0e70*/              @!P0 BRA `(.L_x_15) ;
        /*0e80*/                   MOV R0, R3 ;
        /*0e90*/                   MOV R10, 0xeb0 ;
        /*0ea0*/                   CALL.REL.NOINC `($__internal_0_$__cuda_sm20_sqrt_rn_f32_slowpath) ;
        /*0eb0*/                   IMAD.MOV.U32 R0, RZ, RZ, R3 ;
        /*0ec0*/                   BRA `(.L_x_16) ;
.L_x_15:
        /*0ed0*/                   FMUL.FTZ R0, R4.reuse, R3 ;
        /*0ee0*/                   FMUL.FTZ R4, R4, 0.5 ;
        /*0ef0*/                   FFMA R3, -R0, R0, R3 ;
        /*0f00*/                   FFMA R0, R3, R4, R0 ;
.L_x_16:
        /*0f10*/                   BSYNC B0 ;
.L_x_14:
        /*0f20*/                   FADD R9, R0, c[0x0][0x18c] ;
        /*0f30*/                   FMUL R0, R7, c[0x0][0x188] ;
        /*0f40*/                   BSSY B0, `(.L_x_17) ;
        /*0f50*/                   MUFU.RCP R3, R9 ;
        /*0f60*/                   FCHK P0, R0, R9 ;
        /*0f70*/                   FFMA R4, -R9, R3, 1 ;
        /*0f80*/                   FFMA R3, R3, R4, R3 ;
        /*0f90*/                   FFMA R4, R0, R3, RZ ;
        /*0fa0*/                   FFMA R5, -R9, R4, R0 ;
        /*0fb0*/                   FFMA R3, R3, R5, R4 ;
        /*0fc0*/              @!P0 BRA `(.L_x_18) ;
        /*0fd0*/                   MOV R3, R9 ;
        /*0fe0*/                   MOV R10, 0x1000 ;
        /*0ff0*/                   CALL.REL.NOINC `($__internal_1_$__cuda_sm3x_div_rn_noftz_f32_slowpath) ;
.L_x_18:
        /*1000*/                   BSYNC B0 ;
.L_x_17:
        /*1010*/                   IADD3 R8, P0, R8, c[0x0][0x168], RZ ;
        /*1020*/                   IADD3.X R9, R2, c[0x0][0x16c], RZ, P0, !PT ;
        /*1030*/                   LDG.E R0, [R8.64] ;
        /*1040*/                   FADD R3, R0, R3 ;
        /*1050*/                   STG.E [R8.64], R3 ;
        /*1060*/                   EXIT ;
        .weak           $__internal_0_$__cuda_sm20_sqrt_rn_f32_slowpath
        .type           $__internal_0_$__cuda_sm20_sqrt_rn_f32_slowpath,@function
        .size           $__internal_0_$__cuda_sm20_sqrt_rn_f32_slowpath,($__internal_1_$__cuda_sm3x_div_rn_noftz_f32_slowpath - $__internal_0_$__cuda_sm20_sqrt_rn_f32_slowpath)
$__internal_0_$__cuda_sm20_sqrt_rn_f32_slowpath:
        /*1070*/                   LOP3.LUT P0, RZ, R0, 0x7fffffff, RZ, 0xc0, !PT ;
        /*1080*/              @!P0 IMAD.MOV.U32 R3, RZ, RZ, R0 ;
        /*1090*/              @!P0 BRA `(.L_x_19) ;
        /*10a0*/                   FSETP.GEU.FTZ.AND P0, PT, R0, RZ, PT ;
        /*10b0*/              @!P0 MOV R3, 0x7fffffff ;
        /*10c0*/              @!P0 BRA `(.L_x_19) ;
        /*10d0*/                   FSETP.GTU.FTZ.AND P0, PT, |R0|, +INF , PT ;
        /*10e0*/               @P0 FADD.FTZ R3, R0, 1 ;
        /*10f0*/               @P0 BRA `(.L_x_19) ;
        /*1100*/                   FSETP.NEU.FTZ.AND P0, PT, |R0|, +INF , PT ;
        /*1110*/               @P0 FFMA R4, R0, 1.84467440737095516160e+19, RZ ;
        /*1120*/               @P0 MUFU.RSQ R3, R4 ;
        /*1130*/               @P0 FMUL.FTZ R5, R4, R3 ;
        /*1140*/               @P0 FMUL.FTZ R9, R3, 0.5 ;
        /*1150*/              @!P0 IMAD.MOV.U32 R3, RZ, RZ, R0 ;
        /*1160*/               @P0 FADD.FTZ R6, -R5, -RZ ;
        /*1170*/               @P0 FFMA R6, R5, R6, R4 ;
        /*1180*/               @P0 FFMA R6, R6, R9, R5 ;
        /*1190*/               @P0 FMUL.FTZ R3, R6, 2.3283064365386962891e-10 ;
.L_x_19:
        /*11a0*/                   MOV R4, R10 ;
        /*11b0*/                   IMAD.MOV.U32 R5, RZ, RZ, 0x0 ;
        /*11c0*/                   RET.REL.NODEC R4 `(adam_kernel) ;
        .weak           $__internal_1_$__cuda_sm3x_div_rn_noftz_f32_slowpath
        .type           $__internal_1_$__cuda_sm3x_div_rn_noftz_f32_slowpath,@function
        .size           $__internal_1_$__cuda_sm3x_div_rn_noftz_f32_slowpath,(.L_x_434 - $__internal_1_$__cuda_sm3x_div_rn_noftz_f32_slowpath)
$__internal_1_$__cuda_sm3x_div_rn_noftz_f32_slowpath:
        /*11d0*/                   SHF.R.U32.HI R12, RZ, 0x17, R3 ;
        /*11e0*/                   BSSY B1, `(.L_x_20) ;
        /*11f0*/                   SHF.R.U32.HI R11, RZ, 0x17, R0 ;
        /*1200*/                   LOP3.LUT R16, R12, 0xff, RZ, 0xc0, !PT ;
        /*1210*/                   LOP3.LUT R14, R11, 0xff, RZ, 0xc0, !PT ;
        /*1220*/                   IADD3 R13, R16, -0x1, RZ ;
        /*1230*/                   IADD3 R12, R14, -0x1, RZ ;
        /*1240*/                   ISETP.GT.U32.AND P1, PT, R13, 0xfd, PT ;
        /*1250*/                   ISETP.GT.U32.OR P1, PT, R12, 0xfd, P1 ;
        /*1260*/              @!P1 MOV R11, RZ ;
        /*1270*/              @!P1 BRA `(.L_x_21) ;
        /*1280*/                   FSETP.GTU.FTZ.AND P1, PT, |R0|, +INF , PT ;
        /*1290*/                   FSETP.GTU.FTZ.AND P2, PT, |R3|, +INF , PT ;
        /*12a0*/                   PLOP3.LUT P1, PT, P1, P2, PT, 0xa8, 0x0 ;
        /*12b0*/               @P1 BRA `(.L_x_22) ;
        /*12c0*/                   LOP3.LUT P1, RZ, R3, 0x7fffffff, R0, 0xc8, !PT ;
        /*12d0*/              @!P1 BRA `(.L_x_23) ;
        /*12e0*/                   FSETP.NEU.FTZ.AND P3, PT, |R0|.reuse, +INF , PT ;
        /*12f0*/                   FSETP.NEU.FTZ.AND P2, PT, |R3|, +INF , PT ;
        /*1300*/                   FSETP.NEU.FTZ.AND P1, PT, |R0|, +INF , PT ;
        /*1310*/              @!P2 BRA !P3, `(.L_x_23) ;
        /*1320*/                   LOP3.LUT P3, RZ, R0, 0x7fffffff, RZ, 0xc0, !PT ;
        /*1330*/                   PLOP3.LUT P2, PT, P2, P3, PT, 0x2a, 0x0 ;
        /*1340*/               @P2 BRA `(.L_x_24) ;
        /*1350*/                   LOP3.LUT P2, RZ, R3, 0x7fffffff, RZ, 0xc0, !PT ;
        /*1360*/                   PLOP3.LUT P1, PT, P1, P2, PT, 0x2a, 0x0 ;
        /*1370*/               @P1 BRA `(.L_x_25) ;
        /*1380*/                   ISETP.GE.AND P1, PT, R12, RZ, PT ;
        /*1390*/                   ISETP.GE.AND P2, PT, R13, RZ, PT ;
        /*13a0*/               @P1 MOV R11, RZ ;
        /*13b0*/              @!P1 IMAD.MOV.U32 R11, RZ, RZ, -0x40 ;
        /*13c0*/              @!P1 FFMA R0, R0, 1.84467440737095516160e+19, RZ ;
        /*13d0*/              @!P2 FFMA R3, R3, 1.84467440737095516160e+19, RZ ;
        /*13e0*/              @!P2 IADD3 R11, R11, 0x40, RZ ;
.L_x_21:
        /*13f0*/                   LEA R12, R16, 0xc0800000, 0x17 ;
        /*1400*/                   BSSY B2, `(.L_x_26) ;
        /*1410*/                   IADD3 R12, -R12, R3, RZ ;
        /*1420*/                   IADD3 R3, R14, -0x7f, RZ ;
        /*1430*/                   MUFU.RCP R13, R12 ;
        /*1440*/                   FADD.FTZ R15, -R12, -RZ ;
        /*1450*/                   IMAD R0, R3.reuse, -0x800000, R0 ;
        /*1460*/                   IADD3 R12, R3, 0x7f, -R16 ;
        /*1470*/                   IADD3 R12, R12, R11, RZ ;
        /*1480*/                   FFMA R14, R13, R15, 1 ;
        /*1490*/                   FFMA R18, R13, R14, R13 ;
        /*14a0*/                   FFMA R13, R0, R18, RZ ;
        /*14b0*/                   FFMA R14, R15, R13, R0 ;
        /*14c0*/                   FFMA R17, R18, R14, R13 ;
        /*14d0*/                   FFMA R14, R15, R17, R0 ;
        /*14e0*/                   FFMA R13, R18, R14, R17 ;
        /*14f0*/                   SHF.R.U32.HI R0, RZ, 0x17, R13 ;
        /*1500*/                   LOP3.LUT R0, R0, 0xff, RZ, 0xc0, !PT ;
        /*1510*/                   IMAD.IADD R15, R0, 0x1, R12 ;
        /*1520*/                   IADD3 R0, R15, -0x1, RZ ;
        /*1530*/                   ISETP.GE.U32.AND P1, PT, R0, 0xfe, PT ;
        /*1540*/              @!P1 BRA `(.L_x_27) ;
        /*1550*/                   ISETP.GT.AND P1, PT, R15, 0xfe, PT ;
        /*1560*/               @P1 BRA `(.L_x_28) ;
        /*1570*/                   ISETP.GE.AND P1, PT, R15, 0x1, PT ;
        /*1580*/               @P1 BRA `(.L_x_29) ;
        /*1590*/                   ISETP.GE.AND P1, PT, R15, -0x18, PT ;
        /*15a0*/                   LOP3.LUT R13, R13, 0x80000000, RZ, 0xc0, !PT ;
        /*15b0*/              @!P1 BRA `(.L_x_29) ;
        /*15c0*/                   FFMA.RZ R0, R18.reuse, R14.reuse, R17.reuse ;
        /*15d0*/                   IADD3 R12, R15.reuse, 0x20, RZ ;
        /*15e0*/                   FFMA.RM R3, R18, R14.reuse, R17.reuse ;
        /*15f0*/                   ISETP.NE.AND P3, PT, R15.reuse, RZ, PT ;
        /*1600*/                   LOP3.LUT R11, R0, 0x7fffff, RZ, 0xc0, !PT ;
        /*1610*/                   FFMA.RP R0, R18, R14, R17 ;
        /*1620*/                   ISETP.NE.AND P2, PT, R15, RZ, PT ;
        /*1630*/                   LOP3.LUT R11, R11, 0x800000, RZ, 0xfc, !PT ;
        /*1640*/                   IADD3 R14, -R15, RZ, RZ ;
        /*1650*/                   SHF.L.U32 R12, R11, R12, RZ ;
        /*1660*/                   FSETP.NEU.FTZ.AND P1, PT, R0, R3, PT ;
        /*1670*/                   SEL R0, R14, RZ, P3 ;
        /*1680*/                   ISETP.NE.AND P2, PT, R12, RZ, P2 ;
        /*1690*/                   SHF.R.U32.HI R0, RZ, R0, R11 ;
        /*16a0*/                   PLOP3.LUT P1, PT, P1, P2, PT, 0xa8, 0x0 ;
        /*16b0*/                   SHF.R.U32.HI R12, RZ, 0x1, R0 ;
        /*16c0*/                   SEL R3, RZ, 0x1, !P1 ;
        /*16d0*/                   LOP3.LUT R3, R3, 0x1, R12, 0xf8, !PT ;
        /*16e0*/                   LOP3.LUT R3, R3, R0, RZ, 0xc0, !PT ;
        /*16f0*/                   IADD3 R12, R12, R3, RZ ;
        /*1700*/                   LOP3.LUT R13, R12, R13, RZ, 0xfc, !PT ;
        /*1710*/                   BRA `(.L_x_29) ;
.L_x_28:
        /*1720*/                   LOP3.LUT R13, R13, 0x80000000, RZ, 0xc0, !PT ;
        /*1730*/                   LOP3.LUT R13, R13, 0x7f800000, RZ, 0xfc, !PT ;
        /*1740*/                   BRA `(.L_x_29) ;
.L_x_27:
        /*1750*/                   IMAD R13, R12, 0x800000, R13 ;
.L_x_29:
        /*1760*/                   BSYNC B2 ;
.L_x_26:
        /*1770*/                   BRA `(.L_x_30) ;
.L_x_25:
        /*1780*/                   LOP3.LUT R0, R3, 0x80000000, R0, 0x48, !PT ;
        /*1790*/                   LOP3.LUT R13, R0, 0x7f800000, RZ, 0xfc, !PT ;
        /*17a0*/                   BRA `(.L_x_30) ;
.L_x_24:
        /*17b0*/                   LOP3.LUT R13, R3, 0x80000000, R0, 0x48, !PT ;
        /*17c0*/                   BRA `(.L_x_30) ;
.L_x_23:
        /*17d0*/                   MUFU.RSQ R13, -QNAN  ;
        /*17e0*/                   BRA `(.L_x_30) ;
.L_x_22:
        /*17f0*/                   FADD.FTZ R13, R0, R3 ;
.L_x_30:
        /*1800*/                   BSYNC B1 ;
.L_x_20:
        /*1810*/                   MOV R11, 0x0 ;
        /*1820*/                   MOV R3, R13 ;
        /*1830*/                   RET.REL.NODEC R10 `(adam_kernel) ;
.L_x_31:
        /*1840*/                   BRA `(.L_x_31);
        /*1850*/                   NOP;
        /*1860*/                   NOP;
        /*1870*/                   NOP;
        /*1880*/                   NOP;
        /*1890*/                   NOP;
        /*18a0*/                   NOP;
        /*18b0*/                   NOP;
        /*18c0*/                   NOP;
        /*18d0*/                   NOP;
        /*18e0*/                   NOP;
        /*18f0*/                   NOP;
.L_x_434:


//--------------------- .text.shortcut_kernel     --------------------------
	.section	.text.shortcut_kernel,"ax",@progbits
	.sectioninfo	@"SHI_REGISTERS=13"
	.align	128
        .global         shortcut_kernel
        .type           shortcut_kernel,@function
        .size           shortcut_kernel,(.L_x_450 - shortcut_kernel)
        .other          shortcut_kernel,@"STO_CUDA_ENTRY STV_DEFAULT"
shortcut_kernel:
.text.shortcut_kernel:
        /*0000*/                   IMAD.MOV.U32 R1, RZ, RZ, c[0x0][0x28] ;
        /*0010*/                   S2R R0, SR_CTAID.X ;
        /*0020*/                   S2R R3, SR_TID.X ;
        /*0030*/                   IMAD R0, R0, c[0x0][0x0], R3 ;
        /*0040*/                   ISETP.GE.AND P0, PT, R0, c[0x0][0x160], PT ;
        /*0050*/               @P0 EXIT ;
        /*0060*/                   IABS R8, c[0x0][0x164] ;
        /*0070*/                   ULDC.64 UR4, c[0x0][0x118] ;
        /*0080*/                   IABS R7, c[0x0][0x168] ;
        /*0090*/                   I2F.RP R4, R8 ;
        /*00a0*/                   IABS R10, c[0x0][0x16c] ;
        /*00b0*/                   IABS R9, c[0x0][0x178] ;
        /*00c0*/                   I2F.RP R6, R7 ;
        /*00d0*/                   MUFU.RCP R4, R4 ;
        /*00e0*/                   MUFU.RCP R6, R6 ;
        /*00f0*/                   IADD3 R2, R4, 0xffffffe, RZ ;
        /*0100*/                   IABS R4, R0 ;
        /*0110*/                   F2I.FTZ.U32.TRUNC.NTZ R3, R2 ;
        /*0120*/                   MOV R2, RZ ;
        /*0130*/                   IMAD.MOV R5, RZ, RZ, -R3 ;
        /*0140*/                   IMAD R5, R5, R8, RZ ;
        /*0150*/                   IMAD.HI.U32 R3, R3, R5, R2 ;
        /*0160*/                   IMAD.HI.U32 R2, R3, R4, RZ ;
        /*0170*/                   IMAD.MOV R3, RZ, RZ, -R2 ;
        /*0180*/                   IMAD R3, R8, R3, R4 ;
        /*0190*/                   IADD3 R4, R6, 0xffffffe, RZ ;
        /*01a0*/                   ISETP.GT.U32.AND P2, PT, R8, R3, PT ;
        /*01b0*/                   F2I.FTZ.U32.TRUNC.NTZ R5, R4 ;
        /*01c0*/                   IMAD.MOV.U32 R4, RZ, RZ, RZ ;
        /*01d0*/              @!P2 IMAD.IADD R3, R3, 0x1, -R8 ;
        /*01e0*/              @!P2 IADD3 R2, R2, 0x1, RZ ;
        /*01f0*/                   ISETP.NE.AND P2, PT, RZ, c[0x0][0x164], PT ;
        /*0200*/                   ISETP.GE.U32.AND P0, PT, R3, R8, PT ;
        /*0210*/                   LOP3.LUT R3, R0, c[0x0][0x164], RZ, 0x3c, !PT ;
        /*0220*/                   IADD3 R6, RZ, -R5, RZ ;
        /*0230*/                   ISETP.GE.AND P1, PT, R3, RZ, PT ;
        /*0240*/                   IMAD R3, R6, R7, RZ ;
        /*0250*/               @P0 IADD3 R2, R2, 0x1, RZ ;
        /*0260*/                   IMAD.HI.U32 R4, R5, R3, R4 ;
        /*0270*/              @!P1 IMAD.MOV R2, RZ, RZ, -R2 ;
        /*0280*/              @!P2 LOP3.LUT R2, RZ, c[0x0][0x164], RZ, 0x33, !PT ;
        /*0290*/                   IABS R6, R2 ;
        /*02a0*/                   MOV R5, R6 ;
        /*02b0*/                   I2F.RP R6, R10 ;
        /*02c0*/                   IMAD.HI.U32 R3, R4, R5, RZ ;
        /*02d0*/                   IMAD.MOV R4, RZ, RZ, -R3 ;
        /*02e0*/                   IMAD R4, R7.reuse, R4, R5 ;
        /*02f0*/                   MUFU.RCP R6, R6 ;
        /*0300*/                   ISETP.GT.U32.AND P2, PT, R7, R4, PT ;
        /*0310*/              @!P2 IMAD.IADD R4, R4, 0x1, -R7 ;
        /*0320*/              @!P2 IADD3 R3, R3, 0x1, RZ ;
        /*0330*/                   IADD3 R5, R6, 0xffffffe, RZ ;
        /*0340*/                   ISETP.GE.U32.AND P0, PT, R4, R7, PT ;
        /*0350*/                   LOP3.LUT R4, R2, c[0x0][0x168], RZ, 0x3c, !PT ;
        /*0360*/                   F2I.FTZ.U32.TRUNC.NTZ R5, R5 ;
        /*0370*/                   ISETP.NE.AND P2, PT, RZ, c[0x0][0x168], PT ;
        /*0380*/                   ISETP.GE.AND P1, PT, R4, RZ, PT ;
        /*0390*/                   IMAD.MOV.U32 R4, RZ, RZ, RZ ;
        /*03a0*/               @P0 IADD3 R3, R3, 0x1, RZ ;
        /*03b0*/                   IADD3 R7, RZ, -R5, RZ ;
        /*03c0*/              @!P1 IMAD.MOV R3, RZ, RZ, -R3 ;
        /*03d0*/              @!P2 LOP3.LUT R3, RZ, c[0x0][0x168], RZ, 0x33, !PT ;
        /*03e0*/                   IMAD R7, R7, R10, RZ ;
        /*03f0*/                   IABS R6, R3 ;
        /*0400*/                   IMAD.HI.U32 R4, R5, R7, R4 ;
        /*0410*/                   MOV R5, R6 ;
        /*0420*/                   I2F.RP R7, R9 ;
        /*0430*/                   IMAD.HI.U32 R4, R4, R5, RZ ;
        /*0440*/                   IMAD.MOV R6, RZ, RZ, -R4 ;
        /*0450*/                   IMAD R5, R10.reuse, R6, R5 ;
        /*0460*/                   LOP3.LUT R6, R3, c[0x0][0x16c], RZ, 0x3c, !PT ;
        /*0470*/                   MUFU.RCP R7, R7 ;
        /*0480*/                   ISETP.GT.U32.AND P2, PT, R10, R5, PT ;
        /*0490*/                   ISETP.GE.AND P1, PT, R6, RZ, PT ;
        /*04a0*/              @!P2 IMAD.IADD R5, R5, 0x1, -R10 ;
        /*04b0*/              @!P2 IADD3 R4, R4, 0x1, RZ ;
        /*04c0*/                   IADD3 R8, R7, 0xffffffe, RZ ;
        /*04d0*/                   ISETP.GE.U32.AND P0, PT, R5, R10, PT ;
        /*04e0*/                   F2I.FTZ.U32.TRUNC.NTZ R5, R8 ;
        /*04f0*/                   ISETP.NE.AND P2, PT, RZ, c[0x0][0x16c], PT ;
        /*0500*/               @P0 IADD3 R4, R4, 0x1, RZ ;
        /*0510*/                   MOV R6, R4 ;
        /*0520*/                   IMAD.MOV R4, RZ, RZ, -R5 ;
        /*0530*/              @!P1 IADD3 R6, -R6, RZ, RZ ;
        /*0540*/                   IMAD R7, R4, R9, RZ ;
        /*0550*/              @!P2 LOP3.LUT R6, RZ, c[0x0][0x16c], RZ, 0x33, !PT ;
        /*0560*/                   IMAD.MOV.U32 R4, RZ, RZ, RZ ;
        /*0570*/                   IABS R8, R6 ;
        /*0580*/                   IMAD.HI.U32 R4, R5, R7, R4 ;
        /*0590*/                   ISETP.GE.AND P2, PT, R6, RZ, PT ;
        /*05a0*/                   MOV R5, R8 ;
        /*05b0*/                   IMAD.MOV R6, RZ, RZ, -R6 ;
        /*05c0*/                   IMAD.MOV R7, RZ, RZ, -R2 ;
        /*05d0*/                   IMAD.HI.U32 R4, R4, R5, RZ ;
        /*05e0*/                   IMAD.MOV R4, RZ, RZ, -R4 ;
        /*05f0*/                   IMAD R0, R7, c[0x0][0x164], R0 ;
        /*0600*/                   IMAD R4, R9, R4, R5 ;
        /*0610*/                   IADD3 R5, -R3, RZ, RZ ;
        /*0620*/                   IMAD R3, R6, c[0x0][0x16c], R3 ;
        /*0630*/                   ISETP.GT.U32.AND P0, PT, R9, R4, PT ;
        /*0640*/                   IMAD R2, R5, c[0x0][0x168], R2 ;
        /*0650*/                   IMAD R5, R2.reuse, c[0x0][0x170], RZ ;
        /*0660*/                   IMAD R2, R2, c[0x0][0x174], RZ ;
        /*0670*/              @!P0 IADD3 R4, R4, -R9, RZ ;
        /*0680*/                   ISETP.NE.AND P0, PT, RZ, c[0x0][0x178], PT ;
        /*0690*/                   ISETP.GT.U32.AND P1, PT, R9, R4, PT ;
        /*06a0*/              @!P1 IMAD.IADD R4, R4, 0x1, -R9 ;
        /*06b0*/              @!P2 IADD3 R4, -R4, RZ, RZ ;
        /*06c0*/              @!P0 LOP3.LUT R4, RZ, c[0x0][0x178], RZ, 0x33, !PT ;
        /*06d0*/                   IMAD R6, R4.reuse, c[0x0][0x184], R3.reuse ;
        /*06e0*/                   IMAD R3, R4, c[0x0][0x198], R3 ;
        /*06f0*/                   IMAD R5, R6, c[0x0][0x180], R5 ;
        /*0700*/                   IMAD R4, R0, c[0x0][0x170], RZ ;
        /*0710*/                   IMAD R3, R3, c[0x0][0x194], R2 ;
        /*0720*/                   MOV R2, 0x4 ;
        /*0730*/                   IMAD R4, R5, c[0x0][0x17c], R4 ;
        /*0740*/                   IMAD R0, R0, c[0x0][0x174], RZ ;
        /*0750*/                   IMAD.WIDE R4, R4, R2, c[0x0][0x188] ;
        /*0760*/                   IMAD R3, R3, c[0x0][0x190], R0 ;
        /*0770*/                   LDG.E R4, [R4.64] ;
        /*0780*/                   IMAD.WIDE R2, R3, R2, c[0x0][0x1a8] ;
        /*0790*/                   LDG.E R0, [R2.64] ;
        /*07a0*/                   FMUL R7, R4, c[0x0][0x1a0] ;
        /*07b0*/                   FFMA R7, R0, c[0x0][0x19c], R7 ;
        /*07c0*/                   STG.E [R2.64], R7 ;
        /*07d0*/                   EXIT ;
.L_x_32:
        /*07e0*/                   BRA `(.L_x_32);
        /*07f0*/                   NOP;
        /*0800*/                   NOP;
        /*0810*/                   NOP;
        /*0820*/                   NOP;
        /*0830*/                   NOP;
        /*0840*/                   NOP;
        /*0850*/                   NOP;
        /*0860*/                   NOP;
        /*0870*/                   NOP;
.L_x_450:


//--------------------- .text.dropout_kernel      --------------------------
	.section	.text.dropout_kernel,"ax",@progbits
	.sectioninfo	@"SHI_REGISTERS=10"
	.align	128
        .global         dropout_kernel
        .type           dropout_kernel,@function
        .size           dropout_kernel,(.L_x_451 - dropout_kernel)
        .other          dropout_kernel,@"STO_CUDA_ENTRY STV_DEFAULT"
dropout_kernel:
.text.dropout_kernel:
        /*0000*/                   MOV R1, c[0x0][0x28] ;
        /*0010*/                   S2R R4, SR_CTAID.X ;
        /*0020*/                   S2R R3, SR_TID.X ;
        /*0030*/                   IMAD R4, R4, c[0x0][0x0], R3 ;
        /*0040*/                   ISETP.GE.AND P0, PT, R4, c[0x0][0x168], PT ;
        /*0050*/               @P0 EXIT ;
        /*0060*/                   MOV R5, 0x4 ;
        /*0070*/                   ULDC.64 UR4, c[0x0][0x118] ;
        /*0080*/                   IMAD.WIDE R2, R4, R5, c[0x0][0x170] ;
        /*0090*/                   LDG.E R2, [R2.64] ;
        /*00a0*/                   BSSY B0, `(.L_x_33) ;
        /*00b0*/                   MOV R7, RZ ;
        /*00c0*/                   IMAD.WIDE R4, R4, R5, c[0x0][0x160] ;
        /*00d0*/                   FSETP.GEU.AND P0, PT, R2, c[0x0][0x178], PT ;
        /*00e0*/              @!P0 BRA `(.L_x_34) ;
        /*00f0*/                   LDG.E R7, [R4.64] ;
        /*0100*/                   FMUL R7, R7, c[0x0][0x17c] ;
.L_x_34:
        /*0110*/                   BSYNC B0 ;
.L_x_33:
        /*0120*/                   STG.E [R4.64], R7 ;
        /*0130*/                   EXIT ;
.L_x_35:
        /*0140*/                   BRA `(.L_x_35);
        /*0150*/                   NOP;
        /*0160*/                   NOP;
        /*0170*/                   NOP;
        /*0180*/                   NOP;
        /*0190*/                   NOP;
        /*01a0*/                   NOP;
        /*01b0*/                   NOP;
        /*01c0*/                   NOP;
        /*01d0*/                   NOP;
        /*01e0*/                   NOP;
        /*01f0*/                   NOP;
.L_x_451:


//--------------------- .text.backward_avgpool_kernel --------------------------
	.section	.text.backward_avgpool_kernel,"ax",@progbits
	.sectioninfo	@"SHI_REGISTERS=39"
	.align	128
        .global         backward_avgpool_kernel
        .type           backward_avgpool_kernel,@function
        .size           backward_avgpool_kernel,(.L_x_435 - backward_avgpool_kernel)
        .other          backward_avgpool_kernel,@"STO_CUDA_ENTRY STV_DEFAULT"
backward_avgpool_kernel:
.text.backward_avgpool_kernel:
        /*0000*/                   IMAD.MOV.U32 R1, RZ, RZ, c[0x0][0x28] ;
        /*0010*/                   S2R R2, SR_CTAID.X ;
        /*0020*/                   S2R R3, SR_TID.X ;
        /*0030*/                   IMAD R2, R2, c[0x0][0x0], R3 ;
        /*0040*/                   ISETP.GE.AND P0, PT, R2, c[0x0][0x160], PT ;
        /*0050*/               @P0 EXIT ;
        /*0060*/                   IMAD.MOV.U32 R7, RZ, RZ, 0x4 ;
        /*0070*/                   ULDC.64 UR6, c[0x0][0x118] ;
        /*0080*/                   IMAD.WIDE R6, R2, R7, c[0x0][0x178] ;
        /*0090*/                   LDG.E R0, [R6.64] ;
        /*00a0*/                   IMAD.MOV.U32 R5, RZ, RZ, c[0x0][0x168] ;
        /*00b0*/                   BSSY B0, `(.L_x_36) ;
        /*00c0*/                   IMAD R5, R5, c[0x0][0x164], RZ ;
        /*00d0*/                   I2FP.F32.S32 R9, R5 ;
        /*00e0*/                   MUFU.RCP R4, R9 ;
        /*00f0*/                   FFMA R3, -R9, R4, 1 ;
        /*0100*/                   FFMA R3, R4, R3, R4 ;
        /*0110*/                   FCHK P0, R0, R9 ;
        /*0120*/                   FFMA R4, R0, R3, RZ ;
        /*0130*/                   FFMA R8, -R9, R4, R0 ;
        /*0140*/                   FFMA R3, R3, R8, R4 ;
        /*0150*/              @!P0 BRA `(.L_x_37) ;
        /*0160*/                   MOV R4, 0x180 ;
        /*0170*/                   CALL.REL.NOINC `($__internal_2_$__cuda_sm3x_div_rn_noftz_f32_slowpath) ;
.L_x_37:
        /*0180*/                   BSYNC B0 ;
.L_x_36:
        /*0190*/                   ISETP.GE.AND P0, PT, R5, 0x1, PT ;
        /*01a0*/              @!P0 EXIT ;
        /*01b0*/                   IADD3 R0, R5, -0x1, RZ ;
        /*01c0*/                   UMOV UR4, URZ ;
        /*01d0*/                   ISETP.GE.U32.AND P0, PT, R0, 0x3, PT ;
        /*01e0*/                   LOP3.LUT R0, R5, 0x3, RZ, 0xc0, !PT ;
        /*01f0*/              @!P0 BRA `(.L_x_38) ;
        /*0200*/                   IMAD.IADD R4, R5, 0x1, -R0 ;
        /*0210*/                   UMOV UR4, URZ ;
        /*0220*/                   IMAD.MOV.U32 R7, RZ, RZ, 0x4 ;
        /*0230*/                   IMAD R6, R2, R5, RZ ;
        /*0240*/                   ISETP.GT.AND P0, PT, R4, RZ, PT ;
        /*0250*/                   IMAD.WIDE R6, R6, R7, c[0x0][0x170] ;
        /*0260*/              @!P0 BRA `(.L_x_39) ;
        /*0270*/                   ISETP.GT.AND P1, PT, R4, 0xc, PT ;
        /*0280*/                   PLOP3.LUT P0, PT, PT, PT, PT, 0x80, 0x0 ;
        /*0290*/              @!P1 BRA `(.L_x_40) ;
        /*02a0*/                   PLOP3.LUT P0, PT, PT, PT, PT, 0x8, 0x0 ;
.L_x_41:
        /*02b0*/                   LDG.E R10, [R6.64] ;
        /*02c0*/                   LDG.E R18, [R6.64+0x10] ;
        /*02d0*/                   LDG.E R12, [R6.64+0x4] ;
        /*02e0*/                   LDG.E R14, [R6.64+0x8] ;
        /*02f0*/                   LDG.E R16, [R6.64+0xc] ;
        /*0300*/                   LDG.E R22, [R6.64+0x18] ;
        /*0310*/                   LDG.E R8, [R6.64+0x3c] ;
        /*0320*/                   LDG.E R20, [R6.64+0x14] ;
        /*0330*/                   LDG.E R24, [R6.64+0x1c] ;
        /*0340*/                   LDG.E R26, [R6.64+0x20] ;
        /*0350*/                   LDG.E R28, [R6.64+0x24] ;
        /*0360*/                   LDG.E R30, [R6.64+0x28] ;
        /*0370*/                   LDG.E R32, [R6.64+0x2c] ;
        /*0380*/                   LDG.E R34, [R6.64+0x30] ;
        /*0390*/                   LDG.E R36, [R6.64+0x34] ;
        /*03a0*/                   LDG.E R29, [R6.64+0x38] ;
        /*03b0*/                   IADD3 R4, R4, -0x10, RZ ;
        /*03c0*/                   ISETP.GT.AND P1, PT, R4, 0xc, PT ;
        /*03d0*/                   UIADD3 UR4, UR4, 0x10, URZ ;
        /*03e0*/                   FADD R9, R10, R3.reuse ;
        /*03f0*/                   FADD R17, R18, R3 ;
        /*0400*/                   STG.E [R6.64], R9 ;
        /*0410*/                   FADD R11, R12, R3 ;
        /*0420*/                   STG.E [R6.64+0x10], R17 ;
        /*0430*/                   FADD R13, R14, R3.reuse ;
        /*0440*/                   FADD R15, R16, R3.reuse ;
        /*0450*/                   FADD R9, R22, R3.reuse ;
        /*0460*/                   STG.E [R6.64+0x4], R11 ;
        /*0470*/                   FADD R17, R8, R3.reuse ;
        /*0480*/                   IADD3 R8, P2, R6, 0x40, RZ ;
        /*0490*/                   STG.E [R6.64+0x8], R13 ;
        /*04a0*/                   FADD R19, R20, R3 ;
        /*04b0*/                   STG.E [R6.64+0xc], R15 ;
        /*04c0*/                   FADD R21, R24, R3 ;
        /*04d0*/                   STG.E [R6.64+0x18], R9 ;
        /*04e0*/                   FADD R23, R26, R3.reuse ;
        /*04f0*/                   FADD R25, R28, R3.reuse ;
        /*0500*/                   FADD R27, R30, R3.reuse ;
        /*0510*/                   IADD3.X R9, RZ, R7, RZ, P2, !PT ;
        /*0520*/                   FADD R11, R32, R3.reuse ;
        /*0530*/                   FADD R13, R34, R3.reuse ;
        /*0540*/                   FADD R15, R36, R3.reuse ;
        /*0550*/                   FADD R29, R29, R3 ;
        /*0560*/                   STG.E [R6.64+0x14], R19 ;
        /*0570*/                   STG.E [R6.64+0x1c], R21 ;
        /*0580*/                   STG.E [R6.64+0x20], R23 ;
        /*0590*/                   STG.E [R6.64+0x24], R25 ;
        /*05a0*/                   STG.E [R6.64+0x28], R27 ;
        /*05b0*/                   STG.E [R6.64+0x2c], R11 ;
        /*05c0*/                   STG.E [R6.64+0x30], R13 ;
        /*05d0*/                   STG.E [R6.64+0x34], R15 ;
        /*05e0*/                   STG.E [R6.64+0x38], R29 ;
        /*05f0*/                   STG.E [R6.64+0x3c], R17 ;
        /*0600*/                   IMAD.MOV.U32 R6, RZ, RZ, R8 ;
        /*0610*/                   IMAD.MOV.U32 R7, RZ, RZ, R9 ;
        /*0620*/               @P1 BRA `(.L_x_41) ;
.L_x_40:
        /*0630*/                   ISETP.GT.AND P1, PT, R4, 0x4, PT ;
        /*0640*/              @!P1 BRA `(.L_x_42) ;
        /*0650*/                   LDG.E R8, [R6.64] ;
        /*0660*/                   LDG.E R10, [R6.64+0x4] ;
        /*0670*/                   LDG.E R12, [R6.64+0x8] ;
        /*0680*/                   LDG.E R14, [R6.64+0xc] ;
        /*0690*/                   LDG.E R16, [R6.64+0x10] ;
        /*06a0*/                   LDG.E R18, [R6.64+0x14] ;
        /*06b0*/                   LDG.E R20, [R6.64+0x18] ;
        /*06c0*/                   LDG.E R22, [R6.64+0x1c] ;
        /*06d0*/                   PLOP3.LUT P0, PT, PT, PT, PT, 0x8, 0x0 ;
        /*06e0*/                   UIADD3 UR4, UR4, 0x8, URZ ;
        /*06f0*/                   IADD3 R4, R4, -0x8, RZ ;
        /*0700*/                   FADD R9, R8, R3.reuse ;
        /*0710*/                   IADD3 R8, P1, R6, 0x20, RZ ;
        /*0720*/                   FADD R11, R10, R3 ;
        /*0730*/                   STG.E [R6.64], R9 ;
        /*0740*/                   FADD R13, R12, R3 ;
        /*0750*/                   STG.E [R6.64+0x4], R11 ;
        /*0760*/                   FADD R15, R14, R3 ;
        /*0770*/                   STG.E [R6.64+0x8], R13 ;
        /*0780*/                   FADD R17, R16, R3 ;
        /*0790*/                   IMAD.X R9, RZ, RZ, R7, P1 ;
        /*07a0*/                   STG.E [R6.64+0xc], R15 ;
        /*07b0*/                   FADD R19, R18, R3 ;
        /*07c0*/                   STG.E [R6.64+0x10], R17 ;
        /*07d0*/                   FADD R21, R20, R3 ;
        /*07e0*/                   STG.E [R6.64+0x14], R19 ;
        /*07f0*/                   FADD R23, R22, R3 ;
        /*0800*/                   STG.E [R6.64+0x18], R21 ;
        /*0810*/                   STG.E [R6.64+0x1c], R23 ;
        /*0820*/                   IMAD.MOV.U32 R6, RZ, RZ, R8 ;
        /*0830*/                   MOV R7, R9 ;
.L_x_42:
        /*0840*/                   ISETP.NE.OR P0, PT, R4, RZ, P0 ;
        /*0850*/              @!P0 BRA `(.L_x_38) ;
.L_x_39:
        /*0860*/                   LDG.E R8, [R6.64] ;
        /*0870*/                   LDG.E R10, [R6.64+0x4] ;
        /*0880*/                   LDG.E R12, [R6.64+0x8] ;
        /*0890*/                   LDG.E R14, [R6.64+0xc] ;
        /*08a0*/                   IADD3 R4, R4, -0x4, RZ ;
        /*08b0*/                   UIADD3 UR4, UR4, 0x4, URZ ;
        /*08c0*/                   ISETP.NE.AND P0, PT, R4, RZ, PT ;
        /*08d0*/                   FADD R9, R8, R3.reuse ;
        /*08e0*/                   IADD3 R8, P1, R6, 0x10, RZ ;
        /*08f0*/                   FADD R11, R10, R3 ;
        /*0900*/                   STG.E [R6.64], R9 ;
        /*0910*/                   IMAD.X R17, RZ, RZ, R7, P1 ;
        /*0920*/                   FADD R13, R12, R3.reuse ;
        /*0930*/                   STG.E [R6.64+0x4], R11 ;
        /*0940*/                   FADD R15, R14, R3 ;
        /*0950*/                   STG.E [R6.64+0x8], R13 ;
        /*0960*/                   STG.E [R6.64+0xc], R15 ;
        /*0970*/                   IMAD.MOV.U32 R6, RZ, RZ, R8 ;
        /*0980*/                   IMAD.MOV.U32 R7, RZ, RZ, R17 ;
        /*0990*/               @P0 BRA `(.L_x_39) ;
.L_x_38:
        /*09a0*/                   ISETP.NE.AND P0, PT, R0, RZ, PT ;
        /*09b0*/              @!P0 EXIT ;
        /*09c0*/                   IMAD.MOV.U32 R4, RZ, RZ, 0x4 ;
        /*09d0*/                   IMAD R5, R2, R5, UR4 ;
        /*09e0*/                   IMAD.WIDE R4, R5, R4, c[0x0][0x170] ;
        /*09f0*/                   IMAD.MOV.U32 R9, RZ, RZ, R5 ;
        /*0a00*/                   MOV R2, R4 ;
.L_x_43:
        /*0a10*/                   IMAD.MOV.U32 R4, RZ, RZ, R2 ;
        /*0a20*/                   IMAD.MOV.U32 R5, RZ, RZ, R9 ;
        /*0a30*/                   LDG.E R2, [R4.64] ;
        /*0a40*/                   IADD3 R0, R0, -0x1, RZ ;
        /*0a50*/                   ISETP.NE.AND P0, PT, R0, RZ, PT ;
        /*0a60*/                   FADD R7, R2, R3 ;
        /*0a70*/                   IADD3 R2, P1, R4, 0x4, RZ ;
        /*0a80*/                   STG.E [R4.64], R7 ;
        /*0a90*/                   IMAD.X R9, RZ, RZ, R5, P1 ;
        /*0aa0*/               @P0 BRA `(.L_x_43) ;
        /*0ab0*/                   EXIT ;
        .weak           $__internal_2_$__cuda_sm3x_div_rn_noftz_f32_slowpath
        .type           $__internal_2_$__cuda_sm3x_div_rn_noftz_f32_slowpath,@function
        .size           $__internal_2_$__cuda_sm3x_div_rn_noftz_f32_slowpath,(.L_x_435 - $__internal_2_$__cuda_sm3x_div_rn_noftz_f32_slowpath)
$__internal_2_$__cuda_sm3x_div_rn_noftz_f32_slowpath:
        /*0ac0*/                   SHF.R.U32.HI R6, RZ, 0x17, R9 ;
        /*0ad0*/                   BSSY B1, `(.L_x_44) ;
        /*0ae0*/                   SHF.R.U32.HI R3, RZ, 0x17, R0 ;
        /*0af0*/                   LOP3.LUT R7, R6, 0xff, RZ, 0xc0, !PT ;
        /*0b00*/                   LOP3.LUT R6, R3, 0xff, RZ, 0xc0, !PT ;
        /*0b10*/                   IADD3 R12, R7, -0x1, RZ ;
        /*0b20*/                   IADD3 R11, R6, -0x1, RZ ;
        /*0b30*/                   ISETP.GT.U32.AND P0, PT, R12, 0xfd, PT ;
        /*0b40*/                   MOV R8, R0 ;
        /*0b50*/                   ISETP.GT.U32.OR P0, PT, R11, 0xfd, P0 ;
        /*0b60*/              @!P0 IMAD.MOV.U32 R10, RZ, RZ, RZ ;
        /*0b70*/              @!P0 BRA `(.L_x_45) ;
        /*0b80*/                   FSETP.GTU.FTZ.AND P0, PT, |R0|, +INF , PT ;
        /*0b90*/                   IMAD.MOV.U32 R3, RZ, RZ, R9 ;
        /*0ba0*/                   FSETP.GTU.FTZ.AND P1, PT, |R9|, +INF , PT ;
        /*0bb0*/                   PLOP3.LUT P0, PT, P0, P1, PT, 0xa8, 0x0 ;
        /*0bc0*/               @P0 BRA `(.L_x_46) ;
        /*0bd0*/                   LOP3.LUT P0, RZ, R9, 0x7fffffff, R8, 0xc8, !PT ;
        /*0be0*/              @!P0 BRA `(.L_x_47) ;
        /*0bf0*/                   FSETP.NEU.FTZ.AND P2, PT, |R0|.reuse, +INF , PT ;
        /*0c00*/                   FSETP.NEU.FTZ.AND P1, PT, |R3|, +INF , PT ;
        /*0c10*/                   FSETP.NEU.FTZ.AND P0, PT, |R0|, +INF , PT ;
        /*0c20*/              @!P1 BRA !P2, `(.L_x_47) ;
        /*0c30*/                   LOP3.LUT P2, RZ, R8, 0x7fffffff, RZ, 0xc0, !PT ;
        /*0c40*/                   PLOP3.LUT P1, PT, P1, P2, PT, 0x2a, 0x0 ;
        /*0c50*/               @P1 BRA `(.L_x_48) ;
        /*0c60*/                   LOP3.LUT P1, RZ, R9, 0x7fffffff, RZ, 0xc0, !PT ;
        /*0c70*/                   PLOP3.LUT P0, PT, P0, P1, PT, 0x2a, 0x0 ;
        /*0c80*/               @P0 BRA `(.L_x_49) ;
        /*0c90*/                   ISETP.GE.AND P0, PT, R11, RZ, PT ;
        /*0ca0*/                   ISETP.GE.AND P1, PT, R12, RZ, PT ;
        /*0cb0*/               @P0 IMAD.MOV.U32 R10, RZ, RZ, RZ ;
        /*0cc0*/              @!P0 FFMA R8, R0, 1.84467440737095516160e+19, RZ ;
        /*0cd0*/              @!P0 IMAD.MOV.U32 R10, RZ, RZ, -0x40 ;
        /*0ce0*/              @!P1 FFMA R9, R3, 1.84467440737095516160e+19, RZ ;
        /*0cf0*/              @!P1 IADD3 R10, R10, 0x40, RZ ;
.L_x_45:
        /*0d00*/                   LEA R0, R7, 0xc0800000, 0x17 ;
        /*0d10*/                   BSSY B2, `(.L_x_50) ;
        /*0d20*/                   IADD3 R6, R6, -0x7f, RZ ;
        /*0d30*/                   IADD3 R9, -R0, R9, RZ ;
        /*0d40*/                   IADD3 R7, R6.reuse, 0x7f, -R7 ;
        /*0d50*/                   IMAD R0, R6, -0x800000, R8 ;
        /*0d60*/                   MUFU.RCP R3, R9 ;
        /*0d70*/                   FADD.FTZ R11, -R9, -RZ ;
        /*0d80*/                   IMAD.IADD R7, R7, 0x1, R10 ;
        /*0d90*/                   FFMA R12, R3, R11, 1 ;
        /*0da0*/                   FFMA R12, R3, R12, R3 ;
        /*0db0*/                   FFMA R3, R0, R12, RZ ;
        /*0dc0*/                   FFMA R8, R11, R3, R0 ;
        /*0dd0*/                   FFMA R13, R12, R8, R3 ;
        /*0de0*/                   FFMA R8, R11, R13, R0 ;
        /*0df0*/                   FFMA R3, R12, R8, R13 ;
        /*0e00*/                   SHF.R.U32.HI R0, RZ, 0x17, R3 ;
        /*0e10*/                   LOP3.LUT R0, R0, 0xff, RZ, 0xc0, !PT ;
        /*0e20*/                   IMAD.IADD R10, R0, 0x1, R7 ;
        /*0e30*/                   IADD3 R0, R10, -0x1, RZ ;
        /*0e40*/                   ISETP.GE.U32.AND P0, PT, R0, 0xfe, PT ;
        /*0e50*/              @!P0 BRA `(.L_x_51) ;
        /*0e60*/                   ISETP.GT.AND P0, PT, R10, 0xfe, PT ;
        /*0e70*/               @P0 BRA `(.L_x_52) ;
        /*0e80*/                   ISETP.GE.AND P0, PT, R10, 0x1, PT ;
        /*0e90*/               @P0 BRA `(.L_x_53) ;
        /*0ea0*/                   ISETP.GE.AND P0, PT, R10, -0x18, PT ;
        /*0eb0*/                   LOP3.LUT R3, R3, 0x80000000, RZ, 0xc0, !PT ;
        /*0ec0*/              @!P0 BRA `(.L_x_53) ;
        /*0ed0*/                   FFMA.RZ R0, R12, R8.reuse, R13.reuse ;
        /*0ee0*/                   IADD3 R9, R10, 0x20, RZ ;
        /*0ef0*/                   FFMA.RM R7, R12, R8.reuse, R13.reuse ;
        /*0f00*/                   ISETP.NE.AND P2, PT, R10, RZ, PT ;
        /*0f10*/                   LOP3.LUT R6, R0, 0x7fffff, RZ, 0xc0, !PT ;
        /*0f20*/                   FFMA.RP R0, R12, R8, R13 ;
        /*0f30*/                   IMAD.MOV R8, RZ, RZ, -R10 ;
        /*0f40*/                   ISETP.NE.AND P1, PT, R10, RZ, PT ;
        /*0f50*/                   LOP3.LUT R6, R6, 0x800000, RZ, 0xfc, !PT ;
        /*0f60*/                   FSETP.NEU.FTZ.AND P0, PT, R0, R7, PT ;
        /*0f70*/                   SHF.L.U32 R9, R6, R9, RZ ;
        /*0f80*/                   SEL R7, R8, RZ, P2 ;
        /*0f90*/                   ISETP.NE.AND P1, PT, R9, RZ, P1 ;
        /*0fa0*/                   SHF.R.U32.HI R7, RZ, R7, R6 ;
        /*0fb0*/                   PLOP3.LUT P0, PT, P0, P1, PT, 0xa8, 0x0 ;
        /*0fc0*/                   SHF.R.U32.HI R9, RZ, 0x1, R7 ;
        /*0fd0*/                   SEL R0, RZ, 0x1, !P0 ;
        /*0fe0*/                   LOP3.LUT R0, R0, 0x1, R9, 0xf8, !PT ;
        /*0ff0*/                   LOP3.LUT R0, R0, R7, RZ, 0xc0, !PT ;
        /*1000*/                   IMAD.IADD R0, R9, 0x1, R0 ;
        /*1010*/                   LOP3.LUT R3, R0, R3, RZ, 0xfc, !PT ;
        /*1020*/                   BRA `(.L_x_53) ;
.L_x_52:
        /*1030*/                   LOP3.LUT R3, R3, 0x80000000, RZ, 0xc0, !PT ;
        /*1040*/                   LOP3.LUT R3, R3, 0x7f800000, RZ, 0xfc, !PT ;
        /*1050*/                   BRA `(.L_x_53) ;
.L_x_51:
        /*1060*/                   LEA R3, R7, R3, 0x17 ;
.L_x_53:
        /*1070*/                   BSYNC B2 ;
.L_x_50:
        /*1080*/                   BRA `(.L_x_54) ;
.L_x_49:
        /*1090*/                   LOP3.LUT R3, R9, 0x80000000, R8, 0x48, !PT ;
        /*10a0*/                   LOP3.LUT R3, R3, 0x7f800000, RZ, 0xfc, !PT ;
        /*10b0*/                   BRA `(.L_x_54) ;
.L_x_48:
        /*10c0*/                   LOP3.LUT R3, R9, 0x80000000, R8, 0x48, !PT ;
        /*10d0*/                   BRA `(.L_x_54) ;
.L_x_47:
        /*10e0*/                   MUFU.RSQ R3, -QNAN  ;
        /*10f0*/                   BRA `(.L_x_54) ;
.L_x_46:
        /*1100*/                   FADD.FTZ R3, R0, R3 ;
.L_x_54:
        /*1110*/                   BSYNC B1 ;
.L_x_44:
        /*1120*/                   IMAD.MOV.U32 R6, RZ, RZ, R4 ;
        /*1130*/                   IMAD.MOV.U32 R7, RZ, RZ, 0x0 ;
        /*1140*/                   RET.REL.NODEC R6 `(backward_avgpool_kernel) ;
.L_x_55:
        /*1150*/                   BRA `(.L_x_55);
        /*1160*/                   NOP;
        /*1170*/                   NOP;
        /*1180*/                   NOP;
        /*1190*/                   NOP;
        /*11a0*/                   NOP;
        /*11b0*/                   NOP;
        /*11c0*/                   NOP;
        /*11d0*/                   NOP;
        /*11e0*/                   NOP;
        /*11f0*/                   NOP;
.L_x_435:


//--------------------- .text.forward_avgpool_kernel --------------------------
	.section	.text.forward_avgpool_kernel,"ax",@progbits
	.sectioninfo	@"SHI_REGISTERS=39"
	.align	128
        .global         forward_avgpool_kernel
        .type           forward_avgpool_kernel,@function
        .size           forward_avgpool_kernel,(.L_x_436 - forward_avgpool_kernel)
        .other          forward_avgpool_kernel,@"STO_CUDA_ENTRY STV_DEFAULT"
forward_avgpool_kernel:
.text.forward_avgpool_kernel:
        /*0000*/                   IMAD.MOV.U32 R1, RZ, RZ, c[0x0][0x28] ;
        /*0010*/                   S2R R5, SR_CTAID.X ;
        /*0020*/                   S2R R0, SR_TID.X ;
        /*0030*/                   IMAD R5, R5, c[0x0][0x0], R0 ;
        /*0040*/                   ISETP.GE.AND P0, PT, R5, c[0x0][0x160], PT ;
        /*0050*/               @P0 EXIT ;
        /*0060*/                   IABS R7, c[0x0][0x16c] ;
        /*0070*/                   ULDC.64 UR6, c[0x0][0x118] ;
        /*0080*/                   IABS R6, R5 ;
        /*0090*/                   I2F.RP R0, R7 ;
        /*00a0*/                   MUFU.RCP R0, R0 ;
        /*00b0*/                   IADD3 R2, R0, 0xffffffe, RZ ;
        /*00c0*/                   F2I.FTZ.U32.TRUNC.NTZ R3, R2 ;
        /*00d0*/                   IMAD.MOV.U32 R2, RZ, RZ, RZ ;
        /*00e0*/                   IMAD.MOV R4, RZ, RZ, -R3 ;
        /*00f0*/                   IMAD R9, R4, R7, RZ ;
        /*0100*/                   IMAD.HI.U32 R3, R3, R9, R2 ;
        /*0110*/                   IMAD.MOV.U32 R9, RZ, RZ, RZ ;
        /*0120*/                   IMAD.HI.U32 R4, R3, R6, RZ ;
        /*0130*/                   IMAD.MOV R0, RZ, RZ, -R4 ;
        /*0140*/                   IMAD R0, R7, R0, R6 ;
        /*0150*/                   ISETP.GT.U32.AND P2, PT, R7, R0, PT ;
        /*0160*/              @!P2 IMAD.IADD R0, R0, 0x1, -R7 ;
        /*0170*/              @!P2 IADD3 R4, R4, 0x1, RZ ;
        /*0180*/                   ISETP.NE.AND P2, PT, RZ, c[0x0][0x16c], PT ;
        /*0190*/                   ISETP.GE.U32.AND P0, PT, R0, R7, PT ;
        /*01a0*/                   LOP3.LUT R0, R5, c[0x0][0x16c], RZ, 0x3c, !PT ;
        /*01b0*/                   ISETP.GE.AND P1, PT, R0, RZ, PT ;
        /*01c0*/                   IMAD.MOV.U32 R0, RZ, RZ, c[0x0][0x168] ;
        /*01d0*/                   IMAD R0, R0, c[0x0][0x164], RZ ;
        /*01e0*/               @P0 IADD3 R4, R4, 0x1, RZ ;
        /*01f0*/                   ISETP.GE.AND P0, PT, R0, 0x1, PT ;
        /*0200*/              @!P1 IADD3 R4, -R4, RZ, RZ ;
        /*0210*/              @!P2 LOP3.LUT R4, RZ, c[0x0][0x16c], RZ, 0x33, !PT ;
        /*0220*/                   IMAD.MOV R2, RZ, RZ, -R4 ;
        /*0230*/                   IMAD R5, R2, c[0x0][0x16c], R5 ;
        /*0240*/              @!P0 BRA `(.L_x_56) ;
        /*0250*/                   IADD3 R2, R0.reuse, -0x1, RZ ;
        /*0260*/                   UMOV UR4, URZ ;
        /*0270*/                   LOP3.LUT R7, R0, 0x3, RZ, 0xc0, !PT ;
        /*0280*/                   IMAD.MOV.U32 R9, RZ, RZ, RZ ;
        /*0290*/                   ISETP.GE.U32.AND P0, PT, R2, 0x3, PT ;
        /*02a0*/              @!P0 BRA `(.L_x_57) ;
        /*02b0*/                   IMAD.IADD R6, R0, 0x1, -R7 ;
        /*02c0*/                   UMOV UR4, URZ ;
        /*02d0*/                   IMAD R3, R4, c[0x0][0x16c], R5 ;
        /*02e0*/                   MOV R9, RZ ;
        /*02f0*/                   IMAD.MOV.U32 R2, RZ, RZ, 0x4 ;
        /*0300*/                   ISETP.GT.AND P0, PT, R6, RZ, PT ;
        /*0310*/                   IMAD R3, R0, R3, RZ ;
        /*0320*/                   IMAD.WIDE R2, R3, R2, c[0x0][0x170] ;
        /*0330*/              @!P0 BRA `(.L_x_58) ;
        /*0340*/                   ISETP.GT.AND P1, PT, R6, 0xc, PT ;
        /*0350*/                   PLOP3.LUT P0, PT, PT, PT, PT, 0x80, 0x0 ;
        /*0360*/              @!P1 BRA `(.L_x_59) ;
        /*0370*/                   PLOP3.LUT P0, PT, PT, PT, PT, 0x8, 0x0 ;
.L_x_60:
        /*0380*/                   LDG.E R12, [R2.64] ;
        /*0390*/                   LDG.E R11, [R2.64+0x4] ;
        /*03a0*/                   LDG.E R14, [R2.64+0x8] ;
        /*03b0*/                   LDG.E R16, [R2.64+0xc] ;
        /*03c0*/                   LDG.E R18, [R2.64+0x10] ;
        /*03d0*/                   LDG.E R20, [R2.64+0x14] ;
        /*03e0*/                   LDG.E R22, [R2.64+0x18] ;
        /*03f0*/                   LDG.E R24, [R2.64+0x1c] ;
        /*0400*/                   LDG.E R26, [R2.64+0x20] ;
        /*0410*/                   LDG.E R28, [R2.64+0x24] ;
        /*0420*/                   LDG.E R30, [R2.64+0x28] ;
        /*0430*/                   LDG.E R32, [R2.64+0x2c] ;
        /*0440*/                   LDG.E R34, [R2.64+0x30] ;
        /*0450*/                   LDG.E R36, [R2.64+0x34] ;
        /*0460*/                   LDG.E R10, [R2.64+0x38] ;
        /*0470*/                   LDG.E R8, [R2.64+0x3c] ;
        /*0480*/                   IADD3 R6, R6, -0x10, RZ ;
        /*0490*/                   UIADD3 UR4, UR4, 0x10, URZ ;
        /*04a0*/                   ISETP.GT.AND P1, PT, R6, 0xc, PT ;
        /*04b0*/                   IADD3 R2, P2, R2, 0x40, RZ ;
        /*04c0*/                   IMAD.X R3, RZ, RZ, R3, P2 ;
        /*04d0*/                   FADD R12, R12, R9 ;
        /*04e0*/                   FADD R11, R12, R11 ;
        /*04f0*/                   FADD R11, R11, R14 ;
        /*0500*/                   FADD R11, R11, R16 ;
        /*0510*/                   FADD R11, R11, R18 ;
        /*0520*/                   FADD R11, R11, R20 ;
        /*0530*/                   FADD R11, R11, R22 ;
        /*0540*/                   FADD R11, R11, R24 ;
        /*0550*/                   FADD R11, R11, R26 ;
        /*0560*/                   FADD R11, R11, R28 ;
        /*0570*/                   FADD R11, R11, R30 ;
        /*0580*/                   FADD R11, R11, R32 ;
        /*0590*/                   FADD R11, R11, R34 ;
        /*05a0*/                   FADD R11, R11, R36 ;
        /*05b0*/                   FADD R11, R11, R10 ;
        /*05c0*/                   FADD R9, R11, R8 ;
        /*05d0*/               @P1 BRA `(.L_x_60) ;
.L_x_59:
        /*05e0*/                   ISETP.GT.AND P1, PT, R6, 0x4, PT ;
        /*05f0*/              @!P1 BRA `(.L_x_61) ;
        /*0600*/                   LDG.E R8, [R2.64] ;
        /*0610*/                   LDG.E R11, [R2.64+0x4] ;
        /*0620*/                   LDG.E R13, [R2.64+0x8] ;
        /*0630*/                   LDG.E R15, [R2.64+0xc] ;
        /*0640*/                   LDG.E R17, [R2.64+0x10] ;
        /*0650*/                   LDG.E R19, [R2.64+0x14] ;
        /*0660*/                   LDG.E R21, [R2.64+0x18] ;
        /*0670*/                   LDG.E R23, [R2.64+0x1c] ;
        /*0680*/                   IADD3 R10, P1, R2, 0x20, RZ ;
        /*0690*/                   UIADD3 UR4, UR4, 0x8, URZ ;
        /*06a0*/                   PLOP3.LUT P0, PT, PT, PT, PT, 0x8, 0x0 ;
        /*06b0*/                   IADD3 R6, R6, -0x8, RZ ;
        /*06c0*/                   IMAD.X R3, RZ, RZ, R3, P1 ;
        /*06d0*/                   IMAD.MOV.U32 R2, RZ, RZ, R10 ;
        /*06e0*/                   FADD R8, R9, R8 ;
        /*06f0*/                   FADD R8, R8, R11 ;
        /*0700*/                   FADD R8, R8, R13 ;
        /*0710*/                   FADD R8, R8, R15 ;
        /*0720*/                   FADD R8, R8, R17 ;
        /*0730*/                   FADD R8, R8, R19 ;
        /*0740*/                   FADD R8, R8, R21 ;
        /*0750*/                   FADD R9, R8, R23 ;
.L_x_61:
        /*0760*/                   ISETP.NE.OR P0, PT, R6, RZ, P0 ;
        /*0770*/              @!P0 BRA `(.L_x_57) ;
.L_x_58:
        /*0780*/                   LDG.E R8, [R2.64] ;
        /*0790*/                   LDG.E R11, [R2.64+0x4] ;
        /*07a0*/                   LDG.E R13, [R2.64+0x8] ;
        /*07b0*/                   LDG.E R15, [R2.64+0xc] ;
        /*07c0*/                   IADD3 R6, R6, -0x4, RZ ;
        /*07d0*/                   UIADD3 UR4, UR4, 0x4, URZ ;
        /*07e0*/                   IADD3 R10, P1, R2, 0x10, RZ ;
        /*07f0*/                   ISETP.NE.AND P0, PT, R6, RZ, PT ;
        /*0800*/                   IMAD.MOV.U32 R2, RZ, RZ, R10 ;
        /*0810*/                   FADD R8, R8, R9 ;
        /*0820*/                   FADD R8, R8, R11 ;
        /*0830*/                   IMAD.X R11, RZ, RZ, R3, P1 ;
        /*0840*/                   FADD R8, R8, R13 ;
        /*0850*/                   MOV R3, R11 ;
        /*0860*/                   FADD R9, R8, R15 ;
        /*0870*/               @P0 BRA `(.L_x_58) ;
.L_x_57:
        /*0880*/                   ISETP.NE.AND P0, PT, R7, RZ, PT ;
        /*0890*/              @!P0 BRA `(.L_x_56) ;
        /*08a0*/                   IMAD R3, R4, c[0x0][0x16c], R5 ;
        /*08b0*/                   IMAD.MOV.U32 R11, RZ, RZ, 0x4 ;
        /*08c0*/                   IMAD R2, R0, R3, UR4 ;
        /*08d0*/                   IMAD.WIDE R2, R2, R11, c[0x0][0x170] ;
        /*08e0*/                   IMAD.MOV.U32 R6, RZ, RZ, R2 ;
.L_x_62:
        /*08f0*/                   IMAD.MOV.U32 R2, RZ, RZ, R6 ;
        /*0900*/                   LDG.E R2, [R2.64] ;
        /*0910*/                   IADD3 R7, R7, -0x1, RZ ;
        /*0920*/                   IADD3 R6, P1, R6, 0x4, RZ ;
        /*0930*/                   ISETP.NE.AND P0, PT, R7, RZ, PT ;
        /*0940*/                   IMAD.X R3, RZ, RZ, R3, P1 ;
        /*0950*/                   FADD R9, R2, R9 ;
        /*0960*/               @P0 BRA `(.L_x_62) ;
.L_x_56:
        /*0970*/                   I2FP.F32.S32 R6, R0 ;
        /*0980*/                   BSSY B0, `(.L_x_63) ;
        /*0990*/                   IMAD R2, R4, c[0x0][0x16c], R5 ;
        /*09a0*/                   MUFU.RCP R3, R6 ;
        /*09b0*/                   FCHK P0, R9, R6 ;
        /*09c0*/                   FFMA R0, -R6, R3, 1 ;
        /*09d0*/                   FFMA R0, R3, R0, R3 ;
        /*09e0*/                   FFMA R3, R0, R9, RZ ;
        /*09f0*/                   FFMA R8, -R6, R3, R9 ;
        /*0a00*/                   FFMA R5, R0, R8, R3 ;
        /*0a10*/              @!P0 BRA `(.L_x_64) ;
        /*0a20*/                   MOV R3, R9 ;
        /*0a30*/                   MOV R4, 0xa50 ;
        /*0a40*/                   CALL.REL.NOINC `($__internal_3_$__cuda_sm3x_div_rn_noftz_f32_slowpath) ;
        /*0a50*/                   IMAD.MOV.U32 R5, RZ, RZ, R3 ;
.L_x_64:
        /*0a60*/                   BSYNC B0 ;
.L_x_63:
        /*0a70*/                   IMAD.MOV.U32 R3, RZ, RZ, 0x4 ;
        /*0a80*/                   IMAD.WIDE R2, R2, R3, c[0x0][0x178] ;
        /*0a90*/                   STG.E [R2.64], R5 ;
        /*0aa0*/                   EXIT ;
        .weak           $__internal_3_$__cuda_sm3x_div_rn_noftz_f32_slowpath
        .type           $__internal_3_$__cuda_sm3x_div_rn_noftz_f32_slowpath,@function
        .size           $__internal_3_$__cuda_sm3x_div_rn_noftz_f32_slowpath,(.L_x_436 - $__internal_3_$__cuda_sm3x_div_rn_noftz_f32_slowpath)
$__internal_3_$__cuda_sm3x_div_rn_noftz_f32_slowpath:
        /*0ab0*/                   SHF.R.U32.HI R5, RZ, 0x17, R6 ;
        /*0ac0*/                   BSSY B1, `(.L_x_65) ;
        /*0ad0*/                   SHF.R.U32.HI R0, RZ, 0x17, R3 ;
        /*0ae0*/                   LOP3.LUT R5, R5, 0xff, RZ, 0xc0, !PT ;
        /*0af0*/                   LOP3.LUT R10, R0, 0xff, RZ, 0xc0, !PT ;
        /*0b00*/                   IADD3 R8, R5, -0x1, RZ ;
        /*0b10*/                   IADD3 R9, R10, -0x1, RZ ;
        /*0b20*/                   ISETP.GT.U32.AND P0, PT, R8, 0xfd, PT ;
        /*0b30*/                   ISETP.GT.U32.OR P0, PT, R9, 0xfd, P0 ;
        /*0b40*/              @!P0 IMAD.MOV.U32 R7, RZ, RZ, RZ ;
        /*0b50*/              @!P0 BRA `(.L_x_66) ;
        /*0b60*/                   FSETP.GTU.FTZ.AND P0, PT, |R3|, +INF , PT ;
        /*0b70*/                   IMAD.MOV.U32 R0, RZ, RZ, R6 ;
        /*0b80*/                   FSETP.GTU.FTZ.AND P1, PT, |R6|, +INF , PT ;
        /*0b90*/                   PLOP3.LUT P0, PT, P0, P1, PT, 0xa8, 0x0 ;
        /*0ba0*/               @P0 BRA `(.L_x_67) ;
        /*0bb0*/                   LOP3.LUT P0, RZ, R6, 0x7fffffff, R3, 0xc8, !PT ;
        /*0bc0*/              @!P0 BRA `(.L_x_68) ;
        /*0bd0*/                   FSETP.NEU.FTZ.AND P2, PT, |R3|.reuse, +INF , PT ;
        /*0be0*/                   FSETP.NEU.FTZ.AND P1, PT, |R0|, +INF , PT ;
        /*0bf0*/                   FSETP.NEU.FTZ.AND P0, PT, |R3|, +INF , PT ;
        /*0c00*/              @!P1 BRA !P2, `(.L_x_68) ;
        /*0c10*/                   LOP3.LUT P2, RZ, R3, 0x7fffffff, RZ, 0xc0, !PT ;
        /*0c20*/                   PLOP3.LUT P1, PT, P1, P2, PT, 0x2a, 0x0 ;
        /*0c30*/               @P1 BRA `(.L_x_69) ;
        /*0c40*/                   LOP3.LUT P1, RZ, R6, 0x7fffffff, RZ, 0xc0, !PT ;
        /*0c50*/                   PLOP3.LUT P0, PT, P0, P1, PT, 0x2a, 0x0 ;
        /*0c60*/               @P0 BRA `(.L_x_70) ;
        /*0c70*/                   ISETP.GE.AND P0, PT, R9, RZ, PT ;
        /*0c80*/                   ISETP.GE.AND P1, PT, R8, RZ, PT ;
        /*0c90*/               @P0 MOV R7, RZ ;
        /*0ca0*/              @!P0 IMAD.MOV.U32 R7, RZ, RZ, -0x40 ;
        /*0cb0*/              @!P0 FFMA R3, R3, 1.84467440737095516160e+19, RZ ;
        /*0cc0*/              @!P1 FFMA R6, R0, 1.84467440737095516160e+19, RZ ;
        /*0cd0*/              @!P1 IADD3 R7, R7, 0x40, RZ ;
.L_x_66:
        /*0ce0*/                   LEA R9, R5, 0xc0800000, 0x17 ;
        /*0cf0*/                   BSSY B2, `(.L_x_71) ;
        /*0d00*/                   IMAD.IADD R9, R6, 0x1, -R9 ;
        /*0d10*/                   IADD3 R6, R10, -0x7f, RZ ;
        /*0d20*/                   MUFU.RCP R8, R9 ;
        /*0d30*/                   FADD.FTZ R11, -R9, -RZ ;
        /*0d40*/                   IMAD R0, R6.reuse, -0x800000, R3 ;
        /*0d50*/                   IADD3 R6, R6, 0x7f, -R5 ;
        /*0d60*/                   IMAD.IADD R6, R6, 0x1, R7 ;
        /*0d70*/                   FFMA R13, R8, R11, 1 ;
        /*0d80*/                   FFMA R10, R8, R13, R8 ;
        /*0d90*/                   FFMA R3, R0, R10, RZ ;
        /*0da0*/                   FFMA R8, R11, R3, R0 ;
        /*0db0*/                   FFMA R13, R10, R8, R3 ;
        /*0dc0*/                   FFMA R8, R11, R13, R0 ;
        /*0dd0*/                   FFMA R3, R10, R8, R13 ;
        /*0de0*/                   SHF.R.U32.HI R0, RZ, 0x17, R3 ;
        /*0df0*/                   LOP3.LUT R0, R0, 0xff, RZ, 0xc0, !PT ;
        /*0e00*/                   IMAD.IADD R9, R0, 0x1, R6 ;
        /*0e10*/                   IADD3 R0, R9, -0x1, RZ ;
        /*0e20*/                   ISETP.GE.U32.AND P0, PT, R0, 0xfe, PT ;
        /*0e30*/              @!P0 BRA `(.L_x_72) ;
        /*0e40*/                   ISETP.GT.AND P0, PT, R9, 0xfe, PT ;
        /*0e50*/               @P0 BRA `(.L_x_73) ;
        /*0e60*/                   ISETP.GE.AND P0, PT, R9, 0x1, PT ;
        /*0e70*/               @P0 BRA `(.L_x_74) ;
        /*0e80*/                   ISETP.GE.AND P0, PT, R9, -0x18, PT ;
        /*0e90*/                   LOP3.LUT R3, R3, 0x80000000, RZ, 0xc0, !PT ;
        /*0ea0*/              @!P0 BRA `(.L_x_74) ;
        /*0eb0*/                   FFMA.RZ R0, R10.reuse, R8.reuse, R13.reuse ;
        /*0ec0*/                   IADD3 R7, R9.reuse, 0x20, RZ ;
        /*0ed0*/                   FFMA.RM R5, R10, R8.reuse, R13.reuse ;
        /*0ee0*/                   ISETP.NE.AND P2, PT, R9.reuse, RZ, PT ;
        /*0ef0*/                   LOP3.LUT R6, R0, 0x7fffff, RZ, 0xc0, !PT ;
        /*0f00*/                   FFMA.RP R0, R10, R8, R13 ;
        /*0f10*/                   ISETP.NE.AND P1, PT, R9.reuse, RZ, PT ;
        /*0f20*/                   LOP3.LUT R6, R6, 0x800000, RZ, 0xfc, !PT ;
        /*0f30*/                   IADD3 R8, -R9, RZ, RZ ;
        /*0f40*/                   SHF.L.U32 R7, R6, R7, RZ ;
        /*0f50*/                   FSETP.NEU.FTZ.AND P0, PT, R0, R5, PT ;
        /*0f60*/                   SEL R5, R8, RZ, P2 ;
        /*0f70*/                   ISETP.NE.AND P1, PT, R7, RZ, P1 ;
        /*0f80*/                   SHF.R.U32.HI R5, RZ, R5, R6 ;
        /*0f90*/                   PLOP3.LUT P0, PT, P0, P1, PT, 0xa8, 0x0 ;
        /*0fa0*/                   SHF.R.U32.HI R7, RZ, 0x1, R5 ;
        /*0fb0*/                   SEL R0, RZ, 0x1, !P0 ;
        /*0fc0*/                   LOP3.LUT R0, R0, 0x1, R7, 0xf8, !PT ;
        /*0fd0*/                   LOP3.LUT R0, R0, R5, RZ, 0xc0, !PT ;
        /*0fe0*/                   IMAD.IADD R0, R7, 0x1, R0 ;
        /*0ff0*/                   LOP3.LUT R3, R0, R3, RZ, 0xfc, !PT ;
        /*1000*/                   BRA `(.L_x_74) ;
.L_x_73:
        /*1010*/                   LOP3.LUT R3, R3, 0x80000000, RZ, 0xc0, !PT ;
        /*1020*/                   LOP3.LUT R3, R3, 0x7f800000, RZ, 0xfc, !PT ;
        /*1030*/                   BRA `(.L_x_74) ;
.L_x_72:
        /*1040*/                   IMAD R3, R6, 0x800000, R3 ;
.L_x_74:
        /*1050*/                   BSYNC B2 ;
.L_x_71:
        /*1060*/                   BRA `(.L_x_75) ;
.L_x_70:
        /*1070*/                   LOP3.LUT R3, R6, 0x80000000, R3, 0x48, !PT ;
        /*1080*/                   LOP3.LUT R3, R3, 0x7f800000, RZ, 0xfc, !PT ;
        /*1090*/                   BRA `(.L_x_75) ;
.L_x_69:
        /*10a0*/                   LOP3.LUT R3, R6, 0x80000000, R3, 0x48, !PT ;
        /*10b0*/                   BRA `(.L_x_75) ;
.L_x_68:
        /*10c0*/                   MUFU.RSQ R3, -QNAN  ;
        /*10d0*/                   BRA `(.L_x_75) ;
.L_x_67:
        /*10e0*/                   FADD.FTZ R3, R3, R0 ;
.L_x_75:
        /*10f0*/                   BSYNC B1 ;
.L_x_65:
        /*1100*/                   IMAD.MOV.U32 R5, RZ, RZ, 0x0 ;
        /*1110*/                   RET.REL.NODEC R4 `(forward_avgpool_kernel) ;
.L_x_76:
        /*1120*/                   BRA `(.L_x_76);
        /*1130*/                   NOP;
        /*1140*/                   NOP;
        /*1150*/                   NOP;
        /*1160*/                   NOP;
        /*1170*/                   NOP;
        /*1180*/                   NOP;
        /*1190*/                   NOP;
        /*11a0*/                   NOP;
        /*11b0*/                   NOP;
        /*11c0*/                   NOP;
        /*11d0*/                   NOP;
        /*11e0*/                   NOP;
        /*11f0*/                   NOP;
.L_x_436:


//--------------------- .text.backward_maxpool_kernel --------------------------
	.section	.text.backward_maxpool_kernel,"ax",@progbits
	.sectioninfo	@"SHI_REGISTERS=34"
	.align	128
        .global         backward_maxpool_kernel
        .type           backward_maxpool_kernel,@function
        .size           backward_maxpool_kernel,(.L_x_454 - backward_maxpool_kernel)
        .other          backward_maxpool_kernel,@"STO_CUDA_ENTRY STV_DEFAULT"
backward_maxpool_kernel:
.text.backward_maxpool_kernel:
        /*0000*/                   IMAD.MOV.U32 R1, RZ, RZ, c[0x0][0x28] ;
        /*0010*/                   IABS R2, c[0x0][0x170] ;
        /*0020*/                   IMAD.MOV.U32 R8, RZ, RZ, c[0x0][0x174] ;
        /*0030*/                   S2R R15, SR_TID.X ;
        /*0040*/                   IMAD.MOV.U32 R6, RZ, RZ, c[0x0][0x164] ;
        /*0050*/                   I2F.RP R0, R2 ;
        /*0060*/                   IADD3 R8, R8, -0x1, RZ ;
        /*0070*/                   IABS R13, R8 ;
        /*0080*/                   LOP3.LUT R8, R8, c[0x0][0x170], RZ, 0x3c, !PT ;
        /*0090*/                   ISETP.GE.AND P5, PT, R8, RZ, PT ;
        /*00a0*/                   MUFU.RCP R0, R0 ;
        /*00b0*/                   IADD3 R4, R0, 0xffffffe, RZ ;
        /*00c0*/                   IADD3 R0, R6, -c[0x0][0x174], RZ ;
        /*00d0*/                   F2I.FTZ.U32.TRUNC.NTZ R5, R4 ;
        /*00e0*/                   IADD3 R0, R0, c[0x0][0x178], RZ ;
        /*00f0*/                   IMAD.MOV.U32 R4, RZ, RZ, RZ ;
        /*0100*/                   IMAD.MOV R3, RZ, RZ, -R5 ;
        /*0110*/                   IMAD R3, R3, R2, RZ ;
        /*0120*/                   IMAD.HI.U32 R3, R5, R3, R4 ;
        /*0130*/                   IMAD.MOV.U32 R5, RZ, RZ, c[0x0][0x168] ;
        /*0140*/                   IMAD.HI.U32 R11, R3, R13, RZ ;
        /*0150*/                   IADD3 R4, R5, -c[0x0][0x174], RZ ;
        /*0160*/                   IMAD.MOV R6, RZ, RZ, -R11 ;
        /*0170*/                   IABS R5, R0 ;
        /*0180*/                   IADD3 R4, R4, c[0x0][0x178], RZ ;
        /*0190*/                   IMAD R13, R2, R6, R13 ;
        /*01a0*/                   LOP3.LUT R0, R0, c[0x0][0x170], RZ, 0x3c, !PT ;
        /*01b0*/                   S2R R6, SR_CTAID.X ;
        /*01c0*/                   IABS R12, R4 ;
        /*01d0*/                   IMAD.HI.U32 R9, R3, R5, RZ ;
        /*01e0*/                   ISETP.GT.U32.AND P1, PT, R2, R13, PT ;
        /*01f0*/                   IMAD.HI.U32 R10, R3, R12, RZ ;
        /*0200*/                   IMAD.MOV R7, RZ, RZ, -R9 ;
        /*0210*/                   IMAD.MOV R17, RZ, RZ, -R10 ;
        /*0220*/                   IMAD R5, R2.reuse, R7, R5 ;
        /*0230*/                   IMAD R7, R2.reuse, R17, R12 ;
        /*0240*/              @!P1 IADD3 R11, R11, 0x1, RZ ;
        /*0250*/              @!P1 IMAD.IADD R13, R13, 0x1, -R2 ;
        /*0260*/                   ISETP.GT.U32.AND P3, PT, R2.reuse, R5, PT ;
        /*0270*/                   ISETP.GT.U32.AND P2, PT, R2, R7, PT ;
        /*0280*/                   ISETP.GE.U32.AND P0, PT, R13, R2, PT ;
        /*0290*/                   IMAD R6, R6, c[0x0][0x0], R15 ;
        /*02a0*/                   ISETP.GE.AND P4, PT, R6, c[0x0][0x160], PT ;
        /*02b0*/              @!P3 IMAD.IADD R5, R5, 0x1, -R2.reuse ;
        /*02c0*/              @!P2 IMAD.IADD R7, R7, 0x1, -R2 ;
        /*02d0*/               @P0 IADD3 R11, R11, 0x1, RZ ;
        /*02e0*/                   ISETP.GE.U32.AND P1, PT, R5, R2.reuse, PT ;
        /*02f0*/                   ISETP.GE.U32.AND P0, PT, R7, R2, PT ;
        /*0300*/                   LOP3.LUT R5, R4, c[0x0][0x170], RZ, 0x3c, !PT ;
        /*0310*/               @P4 EXIT ;
        /*0320*/              @!P5 IMAD.MOV R11, RZ, RZ, -R11 ;
        /*0330*/                   ISETP.NE.AND P4, PT, RZ, c[0x0][0x170], PT ;
        /*0340*/                   ULDC.64 UR6, c[0x0][0x118] ;
        /*0350*/                   LOP3.LUT R4, RZ, c[0x0][0x170], RZ, 0x33, !PT ;
        /*0360*/              @!P2 IADD3 R10, R10, 0x1, RZ ;
        /*0370*/                   SEL R7, R4, R11, !P4 ;
        /*0380*/               @P0 IADD3 R10, R10, 0x1, RZ ;
        /*0390*/                   ISETP.GE.AND P6, PT, R0, RZ, PT ;
        /*03a0*/                   IMAD.MOV R8, RZ, RZ, -R7 ;
        /*03b0*/                   ISETP.GE.AND P5, PT, R5, RZ, PT ;
        /*03c0*/                   IMAD.MOV.U32 R5, RZ, RZ, R10 ;
        /*03d0*/              @!P3 IADD3 R9, R9, 0x1, RZ ;
        /*03e0*/                   IMAD.MOV.U32 R0, RZ, RZ, RZ ;
        /*03f0*/                   ISETP.GE.AND P0, PT, R7, R8, PT ;
        /*0400*/               @P1 IADD3 R9, R9, 0x1, RZ ;
        /*0410*/              @!P6 IMAD.MOV R9, RZ, RZ, -R9 ;
        /*0420*/              @!P5 IMAD.MOV R5, RZ, RZ, -R5 ;
        /*0430*/              @!P0 BRA `(.L_x_77) ;
        /*0440*/                   IABS R13, c[0x0][0x168] ;
        /*0450*/                   ULDC UR4, c[0x0][0x178] ;
        /*0460*/                   IABS R17, c[0x0][0x164] ;
        /*0470*/                   ULEA.HI UR4, UR4, UR4, URZ, 0x1 ;
        /*0480*/                   I2F.RP R0, R13 ;
        /*0490*/                   IABS R14, R6 ;
        /*04a0*/                   IMAD.MOV.U32 R20, RZ, RZ, R8 ;
        /*04b0*/                   USHF.R.S32.HI UR4, URZ, 0x1, UR4 ;
        /*04c0*/                   IMNMX R22, R7, R8, !PT ;
        /*04d0*/                   SEL R9, R4, R9, !P4 ;
        /*04e0*/                   IADD3 R25, -R7.reuse, 0x1, RZ ;
        /*04f0*/                   IMAD.IADD R22, R7.reuse, 0x1, R22 ;
        /*0500*/                   IADD3 R23, -R7.reuse, 0x2, RZ ;
        /*0510*/                   IADD3 R21, -R7, 0x3, RZ ;
        /*0520*/                   IADD3 R18, R22, 0x1, RZ ;
        /*0530*/                   MUFU.RCP R0, R0 ;
        /*0540*/                   LOP3.LUT R18, R18, 0x3, RZ, 0xc0, !PT ;
        /*0550*/                   IADD3 R10, R0, 0xffffffe, RZ ;
        /*0560*/                   F2I.FTZ.U32.TRUNC.NTZ R11, R10 ;
        /*0570*/                   IMAD.MOV.U32 R10, RZ, RZ, RZ ;
        /*0580*/                   IMAD.MOV R12, RZ, RZ, -R11 ;
        /*0590*/                   IMAD R15, R12, R13, RZ ;
        /*05a0*/                   I2F.RP R12, R17 ;
        /*05b0*/                   IMAD.HI.U32 R11, R11, R15, R10 ;
        /*05c0*/                   IMAD.HI.U32 R0, R11, R14, RZ ;
        /*05d0*/                   IMAD.MOV R10, RZ, RZ, -R0 ;
        /*05e0*/                   IMAD R10, R13.reuse, R10, R14 ;
        /*05f0*/                   MUFU.RCP R12, R12 ;
        /*0600*/                   ISETP.GT.U32.AND P1, PT, R13, R10, PT ;
        /*0610*/                   IADD3 R11, R12, 0xffffffe, RZ ;
        /*0620*/              @!P1 IMAD.IADD R10, R10, 0x1, -R13 ;
        /*0630*/              @!P1 IADD3 R0, R0, 0x1, RZ ;
        /*0640*/                   ISETP.NE.AND P1, PT, RZ, c[0x0][0x168], PT ;
        /*0650*/                   ISETP.GE.U32.AND P0, PT, R10, R13, PT ;
        /*0660*/                   F2I.FTZ.U32.TRUNC.NTZ R11, R11 ;
        /*0670*/                   LOP3.LUT R10, R6, c[0x0][0x168], RZ, 0x3c, !PT ;
        /*0680*/                   ISETP.GE.AND P2, PT, R10, RZ, PT ;
        /*0690*/                   IMAD.MOV.U32 R10, RZ, RZ, RZ ;
        /*06a0*/               @P0 IADD3 R0, R0, 0x1, RZ ;
        /*06b0*/                   IMAD.MOV.U32 R15, RZ, RZ, R0 ;
        /*06c0*/                   IMAD.MOV R0, RZ, RZ, -R11 ;
        /*06d0*/              @!P2 IMAD.MOV R15, RZ, RZ, -R15 ;
        /*06e0*/              @!P1 LOP3.LUT R15, RZ, c[0x0][0x168], RZ, 0x33, !PT ;
        /*06f0*/                   IMAD R13, R0, R17, RZ ;
        /*0700*/                   IABS R0, R15 ;
        /*0710*/                   IMAD.HI.U32 R10, R11, R13, R10 ;
        /*0720*/                   IMAD.HI.U32 R10, R10, R0, RZ ;
        /*0730*/                   IMAD.MOV R11, RZ, RZ, -R10 ;
        /*0740*/                   IMAD R0, R17, R11, R0 ;
        /*0750*/                   IMAD.MOV R11, RZ, RZ, -R15 ;
        /*0760*/                   ISETP.GT.U32.AND P1, PT, R17, R0, PT ;
        /*0770*/              @!P1 IMAD.IADD R0, R0, 0x1, -R17 ;
        /*0780*/              @!P1 IADD3 R10, R10, 0x1, RZ ;
        /*0790*/                   ISETP.NE.AND P1, PT, RZ, c[0x0][0x164], PT ;
        /*07a0*/                   ISETP.GE.U32.AND P0, PT, R0, R17, PT ;
        /*07b0*/                   LOP3.LUT R0, R15, c[0x0][0x164], RZ, 0x3c, !PT ;
        /*07c0*/                   ISETP.GE.AND P2, PT, R0, RZ, PT ;
        /*07d0*/                   IMAD R0, R11, c[0x0][0x168], R6 ;
        /*07e0*/               @P0 IADD3 R10, R10, 0x1, RZ ;
        /*07f0*/                   IMAD.MOV.U32 R17, RZ, RZ, R10 ;
        /*0800*/              @!P2 IMAD.MOV R17, RZ, RZ, -R17 ;
        /*0810*/              @!P1 LOP3.LUT R17, RZ, c[0x0][0x164], RZ, 0x33, !PT ;
        /*0820*/                   IMAD.MOV R10, RZ, RZ, -R17 ;
        /*0830*/                   IMAD R10, R10, c[0x0][0x164], R15 ;
        /*0840*/                   IADD3 R15, R0, UR4, RZ ;
        /*0850*/                   IADD3 R10, R10, UR4, RZ ;
        /*0860*/                   IABS R12, R15 ;
        /*0870*/                   IABS R13, R10 ;
        /*0880*/                   LOP3.LUT R10, R10, c[0x0][0x170], RZ, 0x3c, !PT ;
        /*0890*/                   IMAD.HI.U32 R0, R3, R12, RZ ;
        /*08a0*/                   ISETP.GE.AND P6, PT, R10, RZ, PT ;
        /*08b0*/                   IMAD.HI.U32 R11, R3, R13, RZ ;
        /*08c0*/                   IADD3 R10, R9, 0x1, RZ ;
        /*08d0*/                   IMAD.MOV R3, RZ, RZ, -R0 ;
        /*08e0*/                   IMAD.MOV R14, RZ, RZ, -R11 ;
        /*08f0*/                   IMAD R3, R2.reuse, R3, R12 ;
        /*0900*/                   IMAD R13, R2, R14, R13 ;
        /*0910*/                   IMAD R10, R10, R17, RZ ;
        /*0920*/                   ISETP.GT.U32.AND P2, PT, R2.reuse, R3, PT ;
        /*0930*/                   ISETP.GT.U32.AND P5, PT, R2, R13, PT ;
        /*0940*/              @!P2 IMAD.IADD R3, R3, 0x1, -R2.reuse ;
        /*0950*/              @!P2 IADD3 R0, R0, 0x1, RZ ;
        /*0960*/              @!P5 IMAD.IADD R13, R13, 0x1, -R2 ;
        /*0970*/              @!P5 IADD3 R11, R11, 0x1, RZ ;
        /*0980*/                   ISETP.GE.U32.AND P0, PT, R3, R2.reuse, PT ;
        /*0990*/                   ISETP.GE.U32.AND P1, PT, R13, R2, PT ;
        /*09a0*/                   LOP3.LUT R2, R15, c[0x0][0x170], RZ, 0x3c, !PT ;
        /*09b0*/                   ISETP.GE.AND P3, PT, R2, RZ, PT ;
        /*09c0*/               @P0 IADD3 R0, R0, 0x1, RZ ;
        /*09d0*/               @P1 IADD3 R11, R11, 0x1, RZ ;
        /*09e0*/                   IMAD.MOV.U32 R13, RZ, RZ, R11 ;
        /*09f0*/                   SEL R11, R4.reuse, R5, !P4 ;
        /*0a00*/              @!P3 IMAD.MOV R0, RZ, RZ, -R0 ;
        /*0a10*/              @!P6 IMAD.MOV R13, RZ, RZ, -R13 ;
        /*0a20*/                   IADD3 R19, R11, 0x1, RZ ;
        /*0a30*/                   SEL R12, R4.reuse, R0, !P4 ;
        /*0a40*/                   IMAD.MOV.U32 R0, RZ, RZ, RZ ;
        /*0a50*/                   SEL R13, R4, R13, !P4 ;
        /*0a60*/                   IMAD.IADD R17, R12.reuse, 0x1, -R7 ;
        /*0a70*/                   IMAD.IADD R16, R12.reuse, 0x1, R25 ;
        /*0a80*/                   IMAD.IADD R15, R12, 0x1, R23 ;
.L_x_95:
        /*0a90*/                   ISETP.NE.AND P0, PT, R18, RZ, PT ;
        /*0aa0*/                   IMAD.IADD R14, R13, 0x1, R20 ;
        /*0ab0*/                   ISETP.GE.AND P4, PT, R20.reuse, R7, PT ;
        /*0ac0*/                   IMAD.MOV.U32 R27, RZ, RZ, R8 ;
        /*0ad0*/                   IADD3 R20, R20, 0x1, RZ ;
        /*0ae0*/                   IMAD.IADD R24, R10, 0x1, R14 ;
        /*0af0*/                   IMAD R24, R19, R24, RZ ;
        /*0b00*/              @!P0 BRA `(.L_x_78) ;
        /*0b10*/                   LOP3.LUT R2, R14, R17, RZ, 0xfc, !PT ;
        /*0b20*/                   IMAD.IADD R4, R17.reuse, 0x1, R24 ;
        /*0b30*/                   BSSY B0, `(.L_x_79) ;
        /*0b40*/                   IMAD.MOV.U32 R5, RZ, RZ, 0x4 ;
        /*0b50*/                   ISETP.GE.AND P0, PT, R2, RZ, PT ;
        /*0b60*/                   IMAD.MOV.U32 R29, RZ, RZ, RZ ;
        /*0b70*/                   ISETP.NE.AND P1, PT, R18, 0x1, PT ;
        /*0b80*/                   IMAD.WIDE R2, R4, R5, c[0x0][0x190] ;
        /*0b90*/                   ISETP.GT.OR P0, PT, R17, R11, !P0 ;
        /*0ba0*/                   IMAD.WIDE R4, R4, R5, c[0x0][0x180] ;
        /*0bb0*/                   ISETP.GT.OR P0, PT, R14, R9, P0 ;
        /*0bc0*/               @P0 BRA `(.L_x_80) ;
        /*0bd0*/                   LDG.E R27, [R2.64] ;
        /*0be0*/                   IMAD.MOV.U32 R29, RZ, RZ, RZ ;
        /*0bf0*/                   ISETP.NE.AND P0, PT, R27, R6, PT ;
        /*0c00*/               @P0 BRA `(.L_x_80) ;
        /*0c10*/                   LDG.E R29, [R4.64] ;
.L_x_80:
        /*0c20*/                   BSYNC B0 ;
.L_x_79:
        /*0c30*/                   IMAD.MOV.U32 R27, RZ, RZ, R25 ;
        /*0c40*/                   FADD R0, R0, R29 ;
        /*0c50*/              @!P1 BRA `(.L_x_78) ;
        /*0c60*/                   LOP3.LUT R26, R14, R16, RZ, 0xfc, !PT ;
        /*0c70*/                   BSSY B0, `(.L_x_81) ;
        /*0c80*/                   ISETP.NE.AND P1, PT, R18, 0x2, PT ;
        /*0c90*/                   IMAD.MOV.U32 R29, RZ, RZ, RZ ;
        /*0ca0*/                   ISETP.GE.AND P0, PT, R26, RZ, PT ;
        /*0cb0*/                   ISETP.GT.OR P0, PT, R16, R11, !P0 ;
        /*0cc0*/                   ISETP.GT.OR P0, PT, R14, R9, P0 ;
        /*0cd0*/               @P0 BRA `(.L_x_82) ;
        /*0ce0*/                   LDG.E R27, [R2.64+0x4] ;
        /*0cf0*/                   ISETP.NE.AND P0, PT, R27, R6, PT ;
        /*0d00*/               @P0 BRA `(.L_x_82) ;
        /*0d10*/                   LDG.E R29, [R4.64+0x4] ;
.L_x_82:
        /*0d20*/                   BSYNC B0 ;
.L_x_81:
        /*0d30*/                   IMAD.MOV.U32 R27, RZ, RZ, R23 ;
        /*0d40*/                   FADD R0, R0, R29 ;
        /*0d50*/              @!P1 BRA `(.L_x_78) ;
        /*0d60*/                   LOP3.LUT R26, R14, R15, RZ, 0xfc, !PT ;
        /*0d70*/                   BSSY B0, `(.L_x_83) ;
        /*0d80*/                   IMAD.MOV.U32 R29, RZ, RZ, RZ ;
        /*0d90*/                   ISETP.GE.AND P0, PT, R26, RZ, PT ;
        /*0da0*/                   ISETP.GT.OR P0, PT, R15, R11, !P0 ;
        /*0db0*/                   ISETP.GT.OR P0, PT, R14, R9, P0 ;
        /*0dc0*/               @P0 BRA `(.L_x_84) ;
        /*0dd0*/                   LDG.E R3, [R2.64+0x8] ;
        /*0de0*/                   ISETP.NE.AND P0, PT, R3, R6, PT ;
        /*0df0*/               @P0 BRA `(.L_x_84) ;
        /*0e00*/                   LDG.E R29, [R4.64+0x8] ;
.L_x_84:
        /*0e10*/                   BSYNC B0 ;
.L_x_83:
        /*0e20*/                   IMAD.MOV.U32 R27, RZ, RZ, R21 ;
        /*0e30*/                   FADD R0, R0, R29 ;
.L_x_78:
        /*0e40*/                   ISETP.GE.U32.AND P0, PT, R22, 0x3, PT ;
        /*0e50*/              @!P0 BRA `(.L_x_85) ;
.L_x_94:
        /*0e60*/                   IMAD.IADD R5, R12, 0x1, R27 ;
        /*0e70*/                   IADD3 R26, R27, 0x3, RZ ;
        /*0e80*/                   BSSY B0, `(.L_x_86) ;
        /*0e90*/                   LOP3.LUT R28, R14, R5, RZ, 0xfc, !PT ;
        /*0ea0*/                   IMAD.IADD R4, R12, 0x1, R26 ;
        /*0eb0*/                   IADD3 R2, R5.reuse, 0x1, RZ ;
        /*0ec0*/                   ISETP.GE.AND P0, PT, R28, RZ, PT ;
        /*0ed0*/                   IADD3 R3, R5, 0x2, RZ ;
        /*0ee0*/                   ISETP.GT.OR P0, PT, R5, R11, !P0 ;
        /*0ef0*/                   LOP3.LUT R31, R14.reuse, R4, RZ, 0xfc, !PT ;
        /*0f00*/                   ISETP.GT.OR P0, PT, R14.reuse, R9, P0 ;
        /*0f10*/                   LOP3.LUT R29, R14.reuse, R2, RZ, 0xfc, !PT ;
        /*0f20*/                   LOP3.LUT R30, R14, R3, RZ, 0xfc, !PT ;
        /*0f30*/                   ISETP.GE.AND P2, PT, R31, RZ, PT ;
        /*0f40*/                   IMAD.MOV.U32 R31, RZ, RZ, 0x4 ;
        /*0f50*/                   ISETP.GE.AND P3, PT, R29, RZ, PT ;
        /*0f60*/                   ISETP.GE.AND P1, PT, R30, RZ, PT ;
        /*0f70*/                   CS2R R28, SRZ ;
        /*0f80*/                   ISETP.GT.OR P2, PT, R4, R11.reuse, !P2 ;
        /*0f90*/                   IMAD.IADD R4, R24, 0x1, R5 ;
        /*0fa0*/                   ISETP.GT.OR P3, PT, R2, R11.reuse, !P3 ;
        /*0fb0*/                   ISETP.GT.OR P1, PT, R3, R11, !P1 ;
        /*0fc0*/                   IMAD.WIDE R2, R4, R31, c[0x0][0x190] ;
        /*0fd0*/                   ISETP.GT.OR P3, PT, R14.reuse, R9.reuse, P3 ;
        /*0fe0*/                   ISETP.GT.OR P1, PT, R14, R9, P1 ;
        /*0ff0*/                   IMAD.WIDE R4, R4, R31, c[0x0][0x180] ;
        /*1000*/                   ISETP.GT.OR P2, PT, R14, R9, P2 ;
        /*1010*/               @P0 BRA `(.L_x_87) ;
        /*1020*/                   LDG.E R31, [R2.64] ;
        /*1030*/                   ISETP.NE.AND P0, PT, R31, R6, PT ;
        /*1040*/               @P0 BRA `(.L_x_87) ;
        /*1050*/                   LDG.E R29, [R4.64] ;
.L_x_87:
        /*1060*/                   BSYNC B0 ;
.L_x_86:
        /*1070*/                   BSSY B0, `(.L_x_88) ;
        /*1080*/                   FADD R31, R29, R0 ;
        /*1090*/               @P3 BRA `(.L_x_89) ;
        /*10a0*/                   LDG.E R29, [R2.64+0x4] ;
        /*10b0*/                   ISETP.NE.AND P0, PT, R29, R6, PT ;
        /*10c0*/               @P0 BRA `(.L_x_89) ;
        /*10d0*/                   LDG.E R28, [R4.64+0x4] ;
.L_x_89:
        /*10e0*/                   BSYNC B0 ;
.L_x_88:
        /*10f0*/                   BSSY B0, `(.L_x_90) ;
        /*1100*/                   FADD R31, R31, R28 ;
        /*1110*/                   IMAD.MOV.U32 R28, RZ, RZ, RZ ;
        /*1120*/               @P1 BRA `(.L_x_91) ;
        /*1130*/                   LDG.E R29, [R2.64+0x8] ;
        /*1140*/                   ISETP.NE.AND P0, PT, R29, R6, PT ;
        /*1150*/               @P0 BRA `(.L_x_91) ;
        /*1160*/                   LDG.E R28, [R4.64+0x8] ;
.L_x_91:
        /*1170*/                   BSYNC B0 ;
.L_x_90:
        /*1180*/                   BSSY B0, `(.L_x_92) ;
        /*1190*/                   IMAD.MOV.U32 R0, RZ, RZ, RZ ;
        /*11a0*/                   FADD R31, R31, R28 ;
        /*11b0*/               @P2 BRA `(.L_x_93) ;
        /*11c0*/                   LDG.E R3, [R2.64+0xc] ;
        /*11d0*/                   ISETP.NE.AND P0, PT, R3, R6, PT ;
        /*11e0*/               @P0 BRA `(.L_x_93) ;
        /*11f0*/                   LDG.E R0, [R4.64+0xc] ;
.L_x_93:
        /*1200*/                   BSYNC B0 ;
.L_x_92:
        /*1210*/                   ISETP.GE.AND P0, PT, R26, R7, PT ;
        /*1220*/                   FADD R0, R31, R0 ;
        /*1230*/                   IADD3 R27, R27, 0x4, RZ ;
        /*1240*/              @!P0 BRA `(.L_x_94) ;
.L_x_85:
        /*1250*/              @!P4 BRA `(.L_x_95) ;
.L_x_77:
        /*1260*/                   IMAD.MOV.U32 R7, RZ, RZ, 0x4 ;
        /*1270*/                   IMAD.WIDE R6, R6, R7, c[0x0][0x188] ;
        /*1280*/                   LDG.E R3, [R6.64] ;
        /*1290*/                   FADD R3, R3, R0 ;
        /*12a0*/                   STG.E [R6.64], R3 ;
        /*12b0*/                   EXIT ;
.L_x_96:
        /*12c0*/                   BRA `(.L_x_96);
        /*12d0*/                   NOP;
        /*12e0*/                   NOP;
        /*12f0*/                   NOP;
        /*1300*/                   NOP;
        /*1310*/                   NOP;
        /*1320*/                   NOP;
        /*1330*/                   NOP;
        /*1340*/                   NOP;
        /*1350*/                   NOP;
        /*1360*/                   NOP;
        /*1370*/                   NOP;
.L_x_454:


//--------------------- .text.forward_maxpool_kernel --------------------------
	.section	.text.forward_maxpool_kernel,"ax",@progbits
	.sectioninfo	@"SHI_REGISTERS=28"
	.align	128
        .global         forward_maxpool_kernel
        .type           forward_maxpool_kernel,@function
        .size           forward_maxpool_kernel,(.L_x_455 - forward_maxpool_kernel)
        .other          forward_maxpool_kernel,@"STO_CUDA_ENTRY STV_DEFAULT"
forward_maxpool_kernel:
.text.forward_maxpool_kernel:
        /*0000*/                   IMAD.MOV.U32 R1, RZ, RZ, c[0x0][0x28] ;
        /*0010*/                   S2R R3, SR_CTAID.X ;
        /*0020*/                   S2R R0, SR_TID.X ;
        /*0030*/                   IMAD R3, R3, c[0x0][0x0], R0 ;
        /*0040*/                   ISETP.GE.AND P0, PT, R3, c[0x0][0x160], PT ;
        /*0050*/               @P0 EXIT ;
        /*0060*/                   IABS R8, c[0x0][0x170] ;
        /*0070*/                   IMAD.MOV.U32 R2, RZ, RZ, c[0x0][0x168] ;
        /*0080*/                   ULDC.64 UR6, c[0x0][0x118] ;
        /*0090*/                   I2F.RP R0, R8 ;
        /*00a0*/                   IADD3 R2, R2, -c[0x0][0x174], RZ ;
        /*00b0*/                   IADD3 R2, R2, c[0x0][0x178], RZ ;
        /*00c0*/                   MUFU.RCP R0, R0 ;
        /*00d0*/                   IADD3 R4, R0, 0xffffffe, RZ ;
        /*00e0*/                   IABS R0, R2 ;
        /*00f0*/                   F2I.FTZ.U32.TRUNC.NTZ R5, R4 ;
        /*0100*/                   LOP3.LUT R2, R2, c[0x0][0x170], RZ, 0x3c, !PT ;
        /*0110*/                   ISETP.GE.AND P2, PT, R2, RZ, PT ;
        /*0120*/                   IMAD.MOV.U32 R4, RZ, RZ, RZ ;
        /*0130*/                   IMAD.MOV R7, RZ, RZ, -R5 ;
        /*0140*/                   IMAD R7, R7, R8, RZ ;
        /*0150*/                   IMAD.HI.U32 R5, R5, R7, R4 ;
        /*0160*/                   IMAD.HI.U32 R4, R5, R0, RZ ;
        /*0170*/                   IMAD.MOV R7, RZ, RZ, -R4 ;
        /*0180*/                   IMAD R0, R8, R7, R0 ;
        /*0190*/                   LOP3.LUT R7, RZ, c[0x0][0x170], RZ, 0x33, !PT ;
        /*01a0*/                   ISETP.GT.U32.AND P1, PT, R8, R0, PT ;
        /*01b0*/              @!P1 IMAD.IADD R0, R0, 0x1, -R8 ;
        /*01c0*/              @!P1 IADD3 R4, R4, 0x1, RZ ;
        /*01d0*/                   ISETP.NE.AND P1, PT, RZ, c[0x0][0x170], PT ;
        /*01e0*/                   ISETP.GE.U32.AND P0, PT, R0, R8, PT ;
        /*01f0*/                   IMAD.MOV.U32 R0, RZ, RZ, c[0x0][0x164] ;
        /*0200*/                   IADD3 R0, R0, -c[0x0][0x174], RZ ;
        /*0210*/                   IADD3 R2, R0, c[0x0][0x178], RZ ;
        /*0220*/               @P0 IADD3 R4, R4, 0x1, RZ ;
        /*0230*/                   IABS R6, R2 ;
        /*0240*/                   LOP3.LUT R2, R2, c[0x0][0x170], RZ, 0x3c, !PT ;
        /*0250*/              @!P2 IMAD.MOV R4, RZ, RZ, -R4 ;
        /*0260*/                   ISETP.GE.AND P3, PT, R2, RZ, PT ;
        /*0270*/                   SEL R0, R7, R4, !P1 ;
        /*0280*/                   IMAD.HI.U32 R4, R5, R6, RZ ;
        /*0290*/                   IADD3 R0, R0, 0x1, RZ ;
        /*02a0*/                   IMAD.MOV R5, RZ, RZ, -R4 ;
        /*02b0*/                   IABS R10, R0 ;
        /*02c0*/                   IMAD R5, R8, R5, R6 ;
        /*02d0*/                   I2F.RP R6, R10 ;
        /*02e0*/                   ISETP.GT.U32.AND P2, PT, R8, R5, PT ;
        /*02f0*/              @!P2 IMAD.IADD R5, R5, 0x1, -R8 ;
        /*0300*/                   MUFU.RCP R6, R6 ;
        /*0310*/              @!P2 IADD3 R4, R4, 0x1, RZ ;
        /*0320*/                   ISETP.GE.U32.AND P0, PT, R5, R8, PT ;
        /*0330*/                   IABS R8, R0 ;
        /*0340*/                   IADD3 R5, R6, 0xffffffe, RZ ;
        /*0350*/               @P0 IADD3 R4, R4, 0x1, RZ ;
        /*0360*/                   IABS R6, R3 ;
        /*0370*/                   F2I.FTZ.U32.TRUNC.NTZ R5, R5 ;
        /*0380*/              @!P3 IMAD.MOV R4, RZ, RZ, -R4 ;
        /*0390*/                   SEL R2, R7, R4, !P1 ;
        /*03a0*/                   IMAD.MOV.U32 R4, RZ, RZ, RZ ;
        /*03b0*/                   IADD3 R2, R2, 0x1, RZ ;
        /*03c0*/                   IABS R11, R2 ;
        /*03d0*/                   IMAD.MOV R9, RZ, RZ, -R5 ;
        /*03e0*/                   I2F.RP R7, R11 ;
        /*03f0*/                   IMAD R9, R9, R10, RZ ;
        /*0400*/                   IMAD.HI.U32 R4, R5, R9, R4 ;
        /*0410*/                   IMAD.MOV.U32 R5, RZ, RZ, R6 ;
        /*0420*/                   IMAD.MOV R6, RZ, RZ, -R8 ;
        /*0430*/                   IMAD.HI.U32 R4, R4, R5, RZ ;
        /*0440*/                   MUFU.RCP R7, R7 ;
        /*0450*/                   IMAD R5, R4, R6, R5 ;
        /*0460*/                   LOP3.LUT R6, R3, R0, RZ, 0x3c, !PT ;
        /*0470*/                   ISETP.GT.U32.AND P1, PT, R10, R5, PT ;
        /*0480*/                   ISETP.GE.AND P2, PT, R6, RZ, PT ;
        /*0490*/                   IADD3 R8, R7, 0xffffffe, RZ ;
        /*04a0*/              @!P1 IMAD.IADD R5, R5, 0x1, -R10 ;
        /*04b0*/              @!P1 IADD3 R4, R4, 0x1, RZ ;
        /*04c0*/                   ISETP.NE.AND P1, PT, R0, RZ, PT ;
        /*04d0*/                   ISETP.GE.U32.AND P0, PT, R5, R10, PT ;
        /*04e0*/                   IMAD.MOV.U32 R10, RZ, RZ, c[0x0][0x174] ;
        /*04f0*/                   F2I.FTZ.U32.TRUNC.NTZ R5, R8 ;
        /*0500*/                   IABS R8, R2 ;
        /*0510*/               @P0 IADD3 R4, R4, 0x1, RZ ;
        /*0520*/                   IMAD.MOV R8, RZ, RZ, -R8 ;
        /*0530*/                   IMAD.MOV.U32 R13, RZ, RZ, R4 ;
        /*0540*/                   IMAD.MOV R4, RZ, RZ, -R5 ;
        /*0550*/              @!P2 IMAD.MOV R13, RZ, RZ, -R13 ;
        /*0560*/              @!P1 LOP3.LUT R13, RZ, R0, RZ, 0x33, !PT ;
        /*0570*/                   IMAD R7, R4, R11, RZ ;
        /*0580*/                   IMAD.MOV.U32 R4, RZ, RZ, RZ ;
        /*0590*/                   IABS R6, R13 ;
        /*05a0*/                   IMAD.MOV R9, RZ, RZ, -R13 ;
        /*05b0*/                   IMAD.HI.U32 R4, R5, R7, R4 ;
        /*05c0*/                   IMAD.MOV.U32 R5, RZ, RZ, R6 ;
        /*05d0*/                   IMAD.MOV.U32 R6, RZ, RZ, R8 ;
        /*05e0*/                   IMAD.HI.U32 R7, R4, R5, RZ ;
        /*05f0*/                   IMAD R4, R7, R6, R5 ;
        /*0600*/                   IMAD R9, R0, R9, R3 ;
        /*0610*/                   IMAD.MOV.U32 R3, RZ, RZ, -0x1 ;
        /*0620*/                   ISETP.GT.U32.AND P1, PT, R11, R4, PT ;
        /*0630*/                   IMAD.MOV.U32 R6, RZ, RZ, -0x800000 ;
        /*0640*/              @!P1 IMAD.IADD R4, R4, 0x1, -R11 ;
        /*0650*/              @!P1 IADD3 R7, R7, 0x1, RZ ;
        /*0660*/                   ISETP.NE.AND P1, PT, R2, RZ, PT ;
        /*0670*/                   ISETP.GE.U32.AND P0, PT, R4, R11, PT ;
        /*0680*/                   LOP3.LUT R4, R13, R2, RZ, 0x3c, !PT ;
        /*0690*/                   ISETP.GE.AND P2, PT, R4, RZ, PT ;
        /*06a0*/               @P0 IADD3 R7, R7, 0x1, RZ ;
        /*06b0*/                   ISETP.GE.AND P0, PT, R10, 0x1, PT ;
        /*06c0*/              @!P2 IMAD.MOV R7, RZ, RZ, -R7 ;
        /*06d0*/              @!P1 LOP3.LUT R7, RZ, R2, RZ, 0x33, !PT ;
        /*06e0*/                   IMAD.MOV R5, RZ, RZ, -R7 ;
        /*06f0*/                   IMAD R8, R2, R5, R13 ;
        /*0700*/              @!P0 BRA `(.L_x_97) ;
        /*0710*/                   IMAD.MOV.U32 R3, RZ, RZ, c[0x0][0x178] ;
        /*0720*/                   IADD3 R4, R10.reuse, -0x1, RZ ;
        /*0730*/                   IMAD.MOV.U32 R6, RZ, RZ, -0x800000 ;
        /*0740*/                   LOP3.LUT R10, R10, 0x3, RZ, 0xc0, !PT ;
        /*0750*/                   IMAD.MOV.U32 R11, RZ, RZ, RZ ;
        /*0760*/                   LEA.HI R3, R3, c[0x0][0x178], RZ, 0x1 ;
        /*0770*/                   ISETP.GE.U32.AND P3, PT, R4, 0x3, PT ;
        /*0780*/                   SHF.R.S32.HI R13, RZ, 0x1, R3 ;
        /*0790*/                   IMAD.MOV.U32 R3, RZ, RZ, -0x1 ;
        /*07a0*/                   IADD3 R12, -R10, c[0x0][0x174], RZ ;
        /*07b0*/                   IMAD R14, R8, c[0x0][0x170], -R13.reuse ;
        /*07c0*/                   IMAD R13, R9, c[0x0][0x170], -R13 ;
.L_x_107:
        /*07d0*/                   IMAD.IADD R16, R14, 0x1, R11 ;
        /*07e0*/                   IADD3 R11, R11, 0x1, RZ ;
        /*07f0*/                   UMOV UR4, URZ ;
        /*0800*/                   ISETP.NE.AND P4, PT, R10, RZ, PT ;
        /*0810*/                   IMAD R15, R7, c[0x0][0x164], R16 ;
        /*0820*/                   ISETP.GE.AND P2, PT, R11, c[0x0][0x174], PT ;
        /*0830*/              @!P3 BRA `(.L_x_98) ;
        /*0840*/                   ISETP.GE.AND P5, PT, R16, c[0x0][0x164], PT ;
        /*0850*/                   IMAD.MOV.U32 R17, RZ, RZ, R12 ;
        /*0860*/                   UMOV UR4, URZ ;
.L_x_99:
        /*0870*/                   IADD3 R18, R13, UR4, RZ ;
        /*0880*/                   IMAD.MOV.U32 R19, RZ, RZ, -0x800000 ;
        /*0890*/                   LOP3.LUT R4, R18.reuse, R16.reuse, RZ, 0xfc, !PT ;
        /*08a0*/                   IMAD R22, R15, c[0x0][0x168], R18 ;
        /*08b0*/                   IADD3 R23, R18, 0x1, RZ ;
        /*08c0*/                   ISETP.LT.OR P1, PT, R4, RZ, P5 ;
        /*08d0*/                   IMAD.MOV.U32 R4, RZ, RZ, 0x4 ;
        /*08e0*/                   LOP3.LUT R5, R23, R16, RZ, 0xfc, !PT ;
        /*08f0*/                   ISETP.GE.OR P1, PT, R18.reuse, c[0x0][0x168], P1 ;
        /*0900*/                   IADD3 R24, R18, 0x2, RZ ;
        /*0910*/                   ISETP.LT.OR P0, PT, R5, RZ, P5 ;
        /*0920*/                   IMAD.WIDE R4, R22, R4, c[0x0][0x180] ;
        /*0930*/                   LOP3.LUT R20, R24, R16.reuse, RZ, 0xfc, !PT ;
        /*0940*/                   ISETP.GE.OR P0, PT, R23, c[0x0][0x168], P0 ;
        /*0950*/                   IADD3 R25, R18, 0x3, RZ ;
        /*0960*/                   ISETP.LT.OR P6, PT, R20, RZ, P5 ;
        /*0970*/              @!P1 LDG.E R19, [R4.64] ;
        /*0980*/                   IMAD.MOV.U32 R18, RZ, RZ, -0x800000 ;
        /*0990*/                   LOP3.LUT R20, R25, R16, RZ, 0xfc, !PT ;
        /*09a0*/                   ISETP.GE.OR P1, PT, R24, c[0x0][0x168], P6 ;
        /*09b0*/                   ISETP.LT.OR P6, PT, R20, RZ, P5 ;
        /*09c0*/              @!P0 LDG.E R18, [R4.64+0x4] ;
        /*09d0*/                   IMAD.MOV.U32 R21, RZ, RZ, -0x800000 ;
        /*09e0*/                   ISETP.GE.OR P6, PT, R25, c[0x0][0x168], P6 ;
        /*09f0*/                   IMAD.MOV.U32 R20, RZ, RZ, -0x800000 ;
        /*0a00*/              @!P1 LDG.E R21, [R4.64+0x8] ;
        /*0a10*/              @!P6 LDG.E R20, [R4.64+0xc] ;
        /*0a20*/                   IADD3 R17, R17, -0x4, RZ ;
        /*0a30*/                   UIADD3 UR4, UR4, 0x4, URZ ;
        /*0a40*/                   FSETP.GT.AND P1, PT, R19, R6, PT ;
        /*0a50*/                   FSEL R19, R19, R6, P1 ;
        /*0a60*/                   SEL R3, R22, R3, P1 ;
        /*0a70*/                   FSETP.GT.AND P0, PT, R18, R19, PT ;
        /*0a80*/                   FSEL R18, R18, R19, P0 ;
        /*0a90*/                   FSETP.GT.AND P6, PT, R21, R18, PT ;
        /*0aa0*/                   FSEL R21, R21, R18, P6 ;
        /*0ab0*/               @P0 IMAD R3, R15, c[0x0][0x168], R23 ;
        /*0ac0*/                   ISETP.NE.AND P0, PT, R17, RZ, PT ;
        /*0ad0*/                   FSETP.GT.AND P1, PT, R20, R21, PT ;
        /*0ae0*/                   FSEL R6, R20, R21, P1 ;
        /*0af0*/               @P6 IMAD R3, R15, c[0x0][0x168], R24 ;
        /*0b00*/               @P1 IMAD R3, R15, c[0x0][0x168], R25 ;
        /*0b10*/               @P0 BRA `(.L_x_99) ;
.L_x_98:
        /*0b20*/              @!P4 BRA `(.L_x_100) ;
        /*0b30*/                   IADD3 R18, R13, UR4, RZ ;
        /*0b40*/                   IMAD.MOV.U32 R5, RZ, RZ, 0x4 ;
        /*0b50*/                   ISETP.GE.AND P0, PT, R16, c[0x0][0x164], PT ;
        /*0b60*/                   BSSY B0, `(.L_x_101) ;
        /*0b70*/                   LOP3.LUT R4, R18, R16, RZ, 0xfc, !PT ;
        /*0b80*/                   IMAD R20, R15, c[0x0][0x168], R18 ;
        /*0b90*/                   ISETP.NE.AND P4, PT, R10, 0x1, PT ;
        /*0ba0*/                   IMAD.MOV.U32 R17, RZ, RZ, -0x800000 ;
        /*0bb0*/                   ISETP.LT.OR P1, PT, R4, RZ, P0 ;
        /*0bc0*/                   IMAD.WIDE R4, R20, R5, c[0x0][0x180] ;
        /*0bd0*/                   ISETP.GE.OR P1, PT, R18, c[0x0][0x168], P1 ;
        /*0be0*/               @P1 BRA `(.L_x_102) ;
        /*0bf0*/                   LDG.E R17, [R4.64] ;
.L_x_102:
        /*0c00*/                   BSYNC B0 ;
.L_x_101:
        /*0c10*/                   FSETP.GT.AND P1, PT, R17, R6, PT ;
        /*0c20*/                   SEL R3, R20, R3, P1 ;
        /*0c30*/                   FSEL R6, R17, R6, P1 ;
        /*0c40*/              @!P4 BRA `(.L_x_100) ;
        /*0c50*/                   IADD3 R19, R18, 0x1, RZ ;
        /*0c60*/                   BSSY B0, `(.L_x_103) ;
        /*0c70*/                   LOP3.LUT R17, R19, R16, RZ, 0xfc, !PT ;
        /*0c80*/                   ISETP.LT.OR P1, PT, R17, RZ, P0 ;
        /*0c90*/                   IMAD.MOV.U32 R17, RZ, RZ, -0x800000 ;
        /*0ca0*/                   ISETP.GE.OR P1, PT, R19, c[0x0][0x168], P1 ;
        /*0cb0*/               @P1 BRA `(.L_x_104) ;
        /*0cc0*/                   LDG.E R17, [R4.64+0x4] ;
.L_x_104:
        /*0cd0*/                   BSYNC B0 ;
.L_x_103:
        /*0ce0*/                   ISETP.NE.AND P4, PT, R10, 0x2, PT ;
        /*0cf0*/                   FSETP.GT.AND P1, PT, R17, R6, PT ;
        /*0d00*/                   FSEL R6, R17, R6, P1 ;
        /*0d10*/               @P1 IMAD R3, R15, c[0x0][0x168], R19 ;
        /*0d20*/              @!P4 BRA `(.L_x_100) ;
        /*0d30*/                   IADD3 R17, R18, 0x2, RZ ;
        /*0d40*/                   BSSY B0, `(.L_x_105) ;
        /*0d50*/                   LOP3.LUT R16, R17, R16, RZ, 0xfc, !PT ;
        /*0d60*/                   ISETP.LT.OR P0, PT, R16, RZ, P0 ;
        /*0d70*/                   IMAD R16, R15, c[0x0][0x168], R17 ;
        /*0d80*/                   IMAD.MOV.U32 R15, RZ, RZ, -0x800000 ;
        /*0d90*/                   ISETP.GE.OR P0, PT, R17, c[0x0][0x168], P0 ;
        /*0da0*/               @P0 BRA `(.L_x_106) ;
        /*0db0*/                   LDG.E R15, [R4.64+0x8] ;
.L_x_106:
        /*0dc0*/                   BSYNC B0 ;
.L_x_105:
        /*0dd0*/                   FSETP.GT.AND P0, PT, R15, R6, PT ;
        /*0de0*/                   SEL R3, R16, R3, P0 ;
        /*0df0*/                   FSEL R6, R15, R6, P0 ;
.L_x_100:
        /*0e00*/              @!P2 BRA `(.L_x_107) ;
.L_x_97:
        /*0e10*/                   IMAD R2, R2, R7, R8 ;
        /*0e20*/                   IMAD.MOV.U32 R7, RZ, RZ, 0x4 ;
        /*0e30*/                   IMAD R2, R0, R2, R9 ;
        /*0e40*/                   IMAD.WIDE R4, R2, R7, c[0x0][0x188] ;
        /*0e50*/                   IMAD.WIDE R8, R2, R7, c[0x0][0x190] ;
        /*0e60*/                   STG.E [R4.64], R6 ;
        /*0e70*/                   STG.E [R8.64], R3 ;
        /*0e80*/                   EXIT ;
.L_x_108:
        /*0e90*/                   BRA `(.L_x_108);
        /*0ea0*/                   NOP;
        /*0eb0*/                   NOP;
        /*0ec0*/                   NOP;
        /*0ed0*/                   NOP;
        /*0ee0*/                   NOP;
        /*0ef0*/                   NOP;
        /*0f00*/                   NOP;
        /*0f10*/                   NOP;
        /*0f20*/                   NOP;
        /*0f30*/                   NOP;
        /*0f40*/                   NOP;
        /*0f50*/                   NOP;
        /*0f60*/                   NOP;
        /*0f70*/                   NOP;
.L_x_455:


//--------------------- .text.col2im_kernel       --------------------------
	.section	.text.col2im_kernel,"ax",@progbits
	.sectioninfo	@"SHI_REGISTERS=40"
	.align	128
        .global         col2im_kernel
        .type           col2im_kernel,@function
        .size           col2im_kernel,(.L_x_456 - col2im_kernel)
        .other          col2im_kernel,@"STO_CUDA_ENTRY STV_DEFAULT"
col2im_kernel:
.text.col2im_kernel:
        /*0000*/                   IMAD.MOV.U32 R1, RZ, RZ, c[0x0][0x28] ;
        /*0010*/                   S2R R0, SR_CTAID.X ;
        /*0020*/                   S2R R3, SR_TID.X ;
        /*0030*/                   IMAD R0, R0, c[0x0][0x0], R3 ;
        /*0040*/                   ISETP.GE.AND P0, PT, R0, c[0x0][0x160], PT ;
        /*0050*/               @P0 EXIT ;
        /*0060*/                   ULDC.64 UR8, c[0x0][0x180] ;
        /*0070*/                   IMAD.MOV.U32 R3, RZ, RZ, c[0x0][0x174] ;
        /*0080*/                   ULDC UR10, c[0x0][0x188] ;
        /*0090*/                   UIADD3 UR5, URZ, -UR8, URZ ;
        /*00a0*/                   IMAD R3, R3, c[0x0][0x170], RZ ;
        /*00b0*/                   UIMAD UR4, UR10, UR9, URZ ;
        /*00c0*/                   ULDC UR6, c[0x0][0x178] ;
        /*00d0*/                   UIMAD UR6, UR5, UR6, URZ ;
        /*00e0*/                   UIADD3 UR11, URZ, -UR9, URZ ;
        /*00f0*/                   UIMAD UR7, UR4, UR8, URZ ;
        /*0100*/                   UIMAD UR6, UR6, UR9, 0x1 ;
        /*0110*/                   UIMAD UR8, UR11, UR8, URZ ;
        /*0120*/                   UIADD3 UR9, -UR7, URZ, URZ ;
        /*0130*/                   UMOV UR11, 0x4 ;
        /*0140*/                   ULDC.64 UR4, c[0x2][0x0] ;
        /*0150*/                   UIADD3 UR13, -UR7, 0x1, URZ ;
        /*0160*/                   UIMAD UR7, UR8, UR10, 0x1 ;
        /*0170*/                   UIMAD.WIDE UR4, UR9, UR11, UR4 ;
        /*0180*/                   ULOP3.LUT UR12, URZ, UR10, URZ, 0x33, !UPT ;
        /*0190*/                   ULDC.64 UR8, c[0x0][0x118] ;
.L_x_126:
        /*01a0*/                   IABS R11, c[0x0][0x174] ;
        /*01b0*/                   BSSY B0, `(.L_x_109) ;
        /*01c0*/                   IABS R5, c[0x0][0x170] ;
        /*01d0*/                   I2F.RP R4, R11 ;
        /*01e0*/                   IABS R8, R0 ;
        /*01f0*/                   I2F.RP R10, R5 ;
        /*0200*/                   MUFU.RCP R4, R4 ;
        /*0210*/                   MUFU.RCP R10, R10 ;
        /*0220*/                   IADD3 R6, R4, 0xffffffe, RZ ;
        /*0230*/                   F2I.FTZ.U32.TRUNC.NTZ R7, R6 ;
        /*0240*/                   IMAD.MOV.U32 R6, RZ, RZ, RZ ;
        /*0250*/                   IMAD.MOV R2, RZ, RZ, -R7 ;
        /*0260*/                   IMAD R9, R2, R11, RZ ;
        /*0270*/                   IMAD.MOV.U32 R2, RZ, RZ, R8 ;
        /*0280*/                   IADD3 R8, R10, 0xffffffe, RZ ;
        /*0290*/                   IMAD.HI.U32 R7, R7, R9, R6 ;
        /*02a0*/                   IABS R6, c[0x0][0x180] ;
        /*02b0*/                   F2I.FTZ.U32.TRUNC.NTZ R9, R8 ;
        /*02c0*/                   IMAD.HI.U32 R7, R7, R2, RZ ;
        /*02d0*/                   IMAD.MOV R4, RZ, RZ, -R7 ;
        /*02e0*/                   I2F.RP R14, R6 ;
        /*02f0*/                   IMAD.MOV.U32 R8, RZ, RZ, RZ ;
        /*0300*/                   IMAD R4, R11, R4, R2 ;
        /*0310*/                   ISETP.GT.U32.AND P1, PT, R11, R4, PT ;
        /*0320*/                   MUFU.RCP R14, R14 ;
        /*0330*/              @!P1 IMAD.IADD R4, R4, 0x1, -R11 ;
        /*0340*/              @!P1 IADD3 R7, R7, 0x1, RZ ;
        /*0350*/                   ISETP.NE.AND P1, PT, RZ, c[0x0][0x174], PT ;
        /*0360*/                   ISETP.GE.U32.AND P0, PT, R4, R11, PT ;
        /*0370*/                   LOP3.LUT R4, R0, c[0x0][0x174], RZ, 0x3c, !PT ;
        /*0380*/                   ISETP.GE.AND P2, PT, R4, RZ, PT ;
        /*0390*/                   IMAD.MOV R4, RZ, RZ, -R9.reuse ;
        /*03a0*/                   IADD3 R12, R14, 0xffffffe, RZ ;
        /*03b0*/                   IABS R14, R3 ;
        /*03c0*/                   IMAD R11, R4, R5, RZ ;
        /*03d0*/                   IABS R4, R3 ;
        /*03e0*/                   F2I.FTZ.U32.TRUNC.NTZ R13, R12 ;
        /*03f0*/               @P0 IADD3 R7, R7, 0x1, RZ ;
        /*0400*/                   IMAD.HI.U32 R8, R9, R11, R8 ;
        /*0410*/              @!P2 IMAD.MOV R7, RZ, RZ, -R7 ;
        /*0420*/              @!P1 LOP3.LUT R7, RZ, c[0x0][0x174], RZ, 0x33, !PT ;
        /*0430*/                   I2F.RP R9, R4 ;
        /*0440*/                   IMAD.MOV.U32 R12, RZ, RZ, RZ ;
        /*0450*/                   IABS R10, R7 ;
        /*0460*/                   IMAD.MOV R17, RZ, RZ, -R14 ;
        /*0470*/                   ISETP.GE.AND P2, PT, R7, RZ, PT ;
        /*0480*/                   IMAD.MOV R7, RZ, RZ, -R7 ;
        /*0490*/                   IMAD.HI.U32 R8, R8, R10, RZ ;
        /*04a0*/                   IMAD.MOV R8, RZ, RZ, -R8 ;
        /*04b0*/                   IMAD R7, R7, c[0x0][0x174], R0 ;
        /*04c0*/                   IMAD R8, R5, R8, R10 ;
        /*04d0*/                   MUFU.RCP R9, R9 ;
        /*04e0*/                   IADD3 R7, R7, c[0x0][0x17c], RZ ;
        /*04f0*/                   ISETP.GT.U32.AND P0, PT, R5, R8, PT ;
        /*0500*/                   IADD3 R10, R9, 0xffffffe, RZ ;
        /*0510*/              @!P0 IMAD.IADD R8, R8, 0x1, -R5 ;
        /*0520*/                   ISETP.NE.AND P0, PT, RZ, c[0x0][0x170], PT ;
        /*0530*/                   IMAD.MOV R9, RZ, RZ, -R13 ;
        /*0540*/                   F2I.FTZ.U32.TRUNC.NTZ R11, R10 ;
        /*0550*/                   ISETP.GT.U32.AND P1, PT, R5, R8, PT ;
        /*0560*/                   IMAD R9, R9, R6, RZ ;
        /*0570*/                   IMAD.HI.U32 R9, R13, R9, R12 ;
        /*0580*/                   IABS R12, R7 ;
        /*0590*/                   IMAD.MOV.U32 R10, RZ, RZ, RZ ;
        /*05a0*/              @!P1 IMAD.IADD R8, R8, 0x1, -R5 ;
        /*05b0*/                   IMAD.MOV R5, RZ, RZ, -R11 ;
        /*05c0*/              @!P2 IMAD.MOV R8, RZ, RZ, -R8 ;
        /*05d0*/              @!P0 LOP3.LUT R8, RZ, c[0x0][0x170], RZ, 0x33, !PT ;
        /*05e0*/                   IMAD R5, R5, R4, RZ ;
        /*05f0*/                   IADD3 R8, R8, c[0x0][0x17c], RZ ;
        /*0600*/                   IMAD.HI.U32 R11, R11, R5, R10 ;
        /*0610*/                   IABS R13, R8 ;
        /*0620*/                   IMAD.HI.U32 R5, R9, R12, RZ ;
        /*0630*/                   IMAD.HI.U32 R10, R9, R13, RZ ;
        /*0640*/                   IMAD.MOV R14, RZ, RZ, -R10 ;
        /*0650*/                   IMAD.HI.U32 R15, R11, R2, RZ ;
        /*0660*/                   IMAD R13, R6, R14, R13 ;
        /*0670*/                   IMAD R17, R15, R17, R2 ;
        /*0680*/                   LOP3.LUT R2, R0, R3, RZ, 0x3c, !PT ;
        /*0690*/                   IMAD.MOV R11, RZ, RZ, -R5 ;
        /*06a0*/                   ISETP.GT.U32.AND P3, PT, R6, R13, PT ;
        /*06b0*/                   ISETP.GT.U32.AND P4, PT, R4, R17, PT ;
        /*06c0*/                   IMAD R11, R6, R11, R12 ;
        /*06d0*/                   ISETP.GE.AND P1, PT, R2, RZ, PT ;
        /*06e0*/                   LOP3.LUT R2, R8, c[0x0][0x180], RZ, 0x3c, !PT ;
        /*06f0*/                   ISETP.GT.U32.AND P5, PT, R6, R11, PT ;
        /*0700*/              @!P3 IMAD.IADD R13, R13, 0x1, -R6 ;
        /*0710*/              @!P3 IADD3 R10, R10, 0x1, RZ ;
        /*0720*/              @!P4 IMAD.IADD R17, R17, 0x1, -R4 ;
        /*0730*/                   ISETP.GE.AND P3, PT, R2, RZ, PT ;
        /*0740*/                   ISETP.GE.U32.AND P6, PT, R13, R6, PT ;
        /*0750*/                   ISETP.GE.U32.AND P0, PT, R17, R4, PT ;
        /*0760*/              @!P5 IMAD.IADD R11, R11, 0x1, -R6 ;
        /*0770*/              @!P4 IADD3 R15, R15, 0x1, RZ ;
        /*0780*/                   LOP3.LUT R2, R7, c[0x0][0x180], RZ, 0x3c, !PT ;
        /*0790*/                   ISETP.GE.U32.AND P2, PT, R11, R6, PT ;
        /*07a0*/              @!P5 IADD3 R5, R5, 0x1, RZ ;
        /*07b0*/                   ISETP.NE.AND P4, PT, R3, RZ, PT ;
        /*07c0*/               @P6 IADD3 R10, R10, 0x1, RZ ;
        /*07d0*/               @P0 IADD3 R15, R15, 0x1, RZ ;
        /*07e0*/                   ISETP.GE.AND P0, PT, R2, RZ, PT ;
        /*07f0*/                   IMAD.MOV.U32 R11, RZ, RZ, R10 ;
        /*0800*/                   ISETP.NE.AND P5, PT, RZ, c[0x0][0x180], PT ;
        /*0810*/              @!P1 IMAD.MOV R15, RZ, RZ, -R15 ;
        /*0820*/               @P2 IADD3 R5, R5, 0x1, RZ ;
        /*0830*/              @!P3 IMAD.MOV R11, RZ, RZ, -R11 ;
        /*0840*/                   ISETP.GE.AND P2, PT, R7, c[0x0][0x178], PT ;
        /*0850*/                   IMAD.MOV.U32 R2, RZ, RZ, RZ ;
        /*0860*/                   LOP3.LUT R10, RZ, c[0x0][0x180], RZ, 0x33, !PT ;
        /*0870*/              @!P4 LOP3.LUT R15, RZ, R3, RZ, 0x33, !PT ;
        /*0880*/                   SEL R11, R10, R11, !P5 ;
        /*0890*/              @!P0 IMAD.MOV R5, RZ, RZ, -R5 ;
        /*08a0*/                   ISETP.GE.AND P1, PT, R8, c[0x0][0x178], PT ;
        /*08b0*/                   IMAD R12, R15, c[0x0][0x178], R8 ;
        /*08c0*/                   IADD3 R4, R11, 0x1, RZ ;
        /*08d0*/                   SEL R11, R10, R5, !P5 ;
        /*08e0*/                   IMNMX R5, R4, c[0x0][0x184], PT ;
        /*08f0*/                   IMAD.MOV.U32 R4, RZ, RZ, RZ ;
        /*0900*/              @!P2 BRA `(.L_x_110) ;
        /*0910*/                   I2F.RP R13, R6 ;
        /*0920*/                   IADD3 R4, R7, -c[0x0][0x178], RZ ;
        /*0930*/                   IABS R16, R4 ;
        /*0940*/                   LOP3.LUT R4, R4, c[0x0][0x180], RZ, 0x3c, !PT ;
        /*0950*/                   ISETP.GE.AND P3, PT, R4, RZ, PT ;
        /*0960*/                   MUFU.RCP R13, R13 ;
        /*0970*/                   IADD3 R14, R13, 0xffffffe, RZ ;
        /*0980*/                   F2I.FTZ.U32.TRUNC.NTZ R15, R14 ;
        /*0990*/                   IMAD.MOV.U32 R14, RZ, RZ, RZ ;
        /*09a0*/                   IMAD.MOV R17, RZ, RZ, -R15 ;
        /*09b0*/                   IMAD R17, R17, R6, RZ ;
        /*09c0*/                   IMAD.HI.U32 R15, R15, R17, R14 ;
        /*09d0*/                   IMAD.HI.U32 R15, R15, R16, RZ ;
        /*09e0*/                   IMAD.MOV R13, RZ, RZ, -R15 ;
        /*09f0*/                   IMAD R13, R6, R13, R16 ;
        /*0a00*/                   ISETP.GT.U32.AND P2, PT, R6, R13, PT ;
        /*0a10*/              @!P2 IMAD.IADD R13, R13, 0x1, -R6 ;
        /*0a20*/              @!P2 IADD3 R15, R15, 0x1, RZ ;
        /*0a30*/                   ISETP.NE.AND P2, PT, RZ, c[0x0][0x180], PT ;
        /*0a40*/                   ISETP.GE.U32.AND P0, PT, R13, R6, PT ;
        /*0a50*/               @P0 IADD3 R15, R15, 0x1, RZ ;
        /*0a60*/              @!P3 IMAD.MOV R15, RZ, RZ, -R15 ;
        /*0a70*/              @!P2 LOP3.LUT R15, RZ, c[0x0][0x180], RZ, 0x33, !PT ;
        /*0a80*/                   IADD3 R4, R15, 0x1, RZ ;
.L_x_110:
        /*0a90*/                   BSYNC B0 ;
.L_x_109:
        /*0aa0*/                   BSSY B0, `(.L_x_111) ;
        /*0ab0*/              @!P1 BRA `(.L_x_112) ;
        /*0ac0*/                   IADD3 R8, R8, -c[0x0][0x178], RZ ;
        /*0ad0*/                   IABS R13, R8 ;
        /*0ae0*/                   LOP3.LUT R8, R8, c[0x0][0x180], RZ, 0x3c, !PT ;
        /*0af0*/                   IMAD.HI.U32 R9, R9, R13, RZ ;
        /*0b00*/                   ISETP.GE.AND P2, PT, R8, RZ, PT ;
        /*0b10*/                   IMAD.MOV R2, RZ, RZ, -R9 ;
        /*0b20*/                   IMAD R13, R6, R2, R13 ;
        /*0b30*/                   ISETP.GT.U32.AND P1, PT, R6, R13, PT ;
        /*0b40*/              @!P1 IMAD.IADD R13, R13, 0x1, -R6 ;
        /*0b50*/              @!P1 IADD3 R9, R9, 0x1, RZ ;
        /*0b60*/                   ISETP.GE.U32.AND P0, PT, R13, R6, PT ;
        /*0b70*/               @P0 IADD3 R9, R9, 0x1, RZ ;
        /*0b80*/              @!P2 IMAD.MOV R9, RZ, RZ, -R9 ;
        /*0b90*/                   SEL R2, R10, R9, !P5 ;
        /*0ba0*/                   IADD3 R2, R2, 0x1, RZ ;
.L_x_112:
        /*0bb0*/                   BSYNC B0 ;
.L_x_111:
        /*0bc0*/                   ISETP.GE.AND P0, PT, R2, R5, PT ;
        /*0bd0*/                   BSSY B1, `(.L_x_113) ;
        /*0be0*/                   IADD3 R6, R11, 0x1, RZ ;
        /*0bf0*/                   IMAD R9, R12, c[0x0][0x178], R7 ;
        /*0c00*/                   IMAD.MOV.U32 R15, RZ, RZ, RZ ;
        /*0c10*/                   IMNMX R7, R6, c[0x0][0x188], PT ;
        /*0c20*/               @P0 BRA `(.L_x_114) ;
        /*0c30*/                   IADD3 R11, -R11, -0x2, RZ ;
        /*0c40*/                   IMAD R9, R9, c[0x0][0x184], RZ ;
        /*0c50*/                   LOP3.LUT R6, RZ, R4, RZ, 0x33, !PT ;
        /*0c60*/                   IMAD.MOV.U32 R15, RZ, RZ, RZ ;
        /*0c70*/                   IMNMX R11, R11, UR12, !PT ;
        /*0c80*/                   IADD3 R10, R4, 0x1, RZ ;
        /*0c90*/                   IADD3 R8, -R11, -0x2, -R4 ;
        /*0ca0*/                   IMAD.IADD R6, R6, 0x1, -R11 ;
        /*0cb0*/                   IADD3 R11, R4, 0x2, RZ ;
        /*0cc0*/                   ISETP.GE.U32.AND P1, PT, R8, 0x3, PT ;
        /*0cd0*/                   IMAD R8, R4.reuse, UR7, RZ ;
        /*0ce0*/                   IADD3 R12, R4, 0x3, RZ ;
        /*0cf0*/                   LOP3.LUT R13, R6, 0x3, RZ, 0xc0, !PT ;
.L_x_124:
        /*0d00*/                   ISETP.GE.AND P0, PT, R4, R7, PT ;
        /*0d10*/                   BSSY B0, `(.L_x_115) ;
        /*0d20*/               @P0 BRA `(.L_x_116) ;
        /*0d30*/                   ISETP.NE.AND P0, PT, R13, RZ, PT ;
        /*0d40*/                   IMAD R6, R2, UR6, R9 ;
        /*0d50*/                   BSSY B2, `(.L_x_117) ;
        /*0d60*/                   IMAD.MOV.U32 R32, RZ, RZ, R4 ;
        /*0d70*/                   IMAD R21, R6, c[0x0][0x188], RZ ;
        /*0d80*/              @!P0 BRA `(.L_x_118) ;
        /*0d90*/                   IMAD.IADD R6, R8, 0x1, R21 ;
        /*0da0*/                   IMAD.MOV.U32 R19, RZ, RZ, 0x4 ;
        /*0db0*/                   IMAD.WIDE R16, R6, R19, c[0x0][0x168] ;
        /*0dc0*/                   LDG.E R16, [R16.64] ;
        /*0dd0*/                   ISETP.NE.AND P0, PT, R13, 0x1, PT ;
        /*0de0*/                   IMAD.MOV.U32 R32, RZ, RZ, R10 ;
        /*0df0*/                   FADD R15, R15, R16 ;
        /*0e00*/              @!P0 BRA `(.L_x_118) ;
        /*0e10*/                   ISETP.NE.AND P0, PT, R13, 0x2, PT ;
        /*0e20*/                   IADD3 R6, R6, UR7, RZ ;
        /*0e30*/                   IMAD.WIDE R16, R6, R19, c[0x0][0x168] ;
        /*0e40*/               @P0 IADD3 R18, R6, UR7, RZ ;
        /*0e50*/                   LDG.E R16, [R16.64] ;
        /*0e60*/               @P0 IMAD.WIDE R18, R18, R19, c[0x0][0x168] ;
        /*0e70*/               @P0 LDG.E R18, [R18.64] ;
        /*0e80*/                   IMAD.MOV.U32 R32, RZ, RZ, R11 ;
        /*0e90*/               @P0 IMAD.MOV.U32 R32, RZ, RZ, R12 ;
        /*0ea0*/                   FADD R15, R15, R16 ;
        /*0eb0*/               @P0 FADD R15, R15, R18 ;
.L_x_118:
        /*0ec0*/                   BSYNC B2 ;
.L_x_117:
        /*0ed0*/              @!P1 BRA `(.L_x_116) ;
        /*0ee0*/                   IMAD.IADD R6, R7, 0x1, -R32 ;
        /*0ef0*/                   BSSY B2, `(.L_x_119) ;
        /*0f00*/                   IMAD.MOV.U32 R31, RZ, RZ, 0x4 ;
        /*0f10*/                   PLOP3.LUT P0, PT, PT, PT, PT, 0x80, 0x0 ;
        /*0f20*/                   IMAD R30, R32, UR13, R21 ;
        /*0f30*/                   ISETP.GT.AND P2, PT, R6, 0xc, PT ;
        /*0f40*/                   IMAD.WIDE R30, R30, R31, c[0x0][0x168] ;
        /*0f50*/              @!P2 BRA `(.L_x_120) ;
        /*0f60*/                   PLOP3.LUT P0, PT, PT, PT, PT, 0x8, 0x0 ;
        /*0f70*/                   IADD3 R6, R7, -0xc, RZ ;
.L_x_121:
        /*0f80*/                   IADD3 R20, P2, R30, UR4, RZ ;
        /*0f90*/                   LDG.E R30, [R30.64] ;
        /*0fa0*/                   IADD3.X R21, R31, UR5, RZ, P2, !PT ;
        /*0fb0*/                   IADD3 R34, P2, R20, UR4, RZ ;
        /*0fc0*/                   LDG.E R14, [R20.64] ;
        /*0fd0*/                   IADD3.X R35, R21, UR5, RZ, P2, !PT ;
        /*0fe0*/                   IADD3 R18, P2, R34, UR4, RZ ;
        /*0ff0*/                   LDG.E R31, [R34.64] ;
        /*1000*/                   IADD3.X R19, R35, UR5, RZ, P2, !PT ;
        /*1010*/                   IADD3 R16, P2, R18, UR4, RZ ;
        /*1020*/                   LDG.E R33, [R18.64] ;
        /*1030*/                   IADD3.X R17, R19, UR5, RZ, P2, !PT ;
        /*1040*/                   IADD3 R24, P2, R16, UR4, RZ ;
        /*1050*/                   LDG.E R37, [R16.64] ;
        /*1060*/                   IADD3.X R25, R17, UR5, RZ, P2, !PT ;
        /*1070*/                   IADD3 R26, P2, R24, UR4, RZ ;
        /*1080*/                   LDG.E R36, [R24.64] ;
        /*1090*/                   IADD3.X R27, R25, UR5, RZ, P2, !PT ;
        /*10a0*/                   IADD3 R28, P2, R26, UR4, RZ ;
        /*10b0*/                   LDG.E R35, [R26.64] ;
        /*10c0*/                   IADD3.X R29, R27, UR5, RZ, P2, !PT ;
        /*10d0*/                   IADD3 R22, P2, R28, UR4, RZ ;
        /*10e0*/                   LDG.E R34, [R28.64] ;
        /*10f0*/                   IADD3.X R23, R29, UR5, RZ, P2, !PT ;
        /*1100*/                   IADD3 R20, P2, R22, UR4, RZ ;
        /*1110*/                   LDG.E R22, [R22.64] ;
        /*1120*/                   IADD3.X R21, R23, UR5, RZ, P2, !PT ;
        /*1130*/                   IADD3 R18, P2, R20, UR4, RZ ;
        /*1140*/                   LDG.E R20, [R20.64] ;
        /*1150*/                   IADD3.X R19, R21, UR5, RZ, P2, !PT ;
        /*1160*/                   IADD3 R16, P2, R18, UR4, RZ ;
        /*1170*/                   IADD3.X R17, R19, UR5, RZ, P2, !PT ;
        /*1180*/                   IADD3 R24, P2, R16, UR4, RZ ;
        /*1190*/                   LDG.E R21, [R18.64] ;
        /*11a0*/                   IADD3.X R25, R17, UR5, RZ, P2, !PT ;
        /*11b0*/                   LDG.E R16, [R16.64] ;
        /*11c0*/                   IADD3 R26, P2, R24, UR4, RZ ;
        /*11d0*/                   LDG.E R24, [R24.64] ;
        /*11e0*/                   IADD3.X R27, R25, UR5, RZ, P2, !PT ;
        /*11f0*/                   IADD3 R28, P2, R26, UR4, RZ ;
        /*1200*/                   LDG.E R26, [R26.64] ;
        /*1210*/                   IADD3.X R29, R27, UR5, RZ, P2, !PT ;
        /*1220*/                   IADD3 R18, P2, R28, UR4, RZ ;
        /*1230*/                   LDG.E R23, [R28.64] ;
        /*1240*/                   IADD3.X R19, R29, UR5, RZ, P2, !PT ;
        /*1250*/                   LDG.E R17, [R18.64] ;
        /*1260*/                   IADD3 R32, R32, 0x10, RZ ;
        /*1270*/                   ISETP.GE.AND P2, PT, R32, R6, PT ;
        /*1280*/                   FADD R15, R30, R15 ;
        /*1290*/                   FADD R14, R15, R14 ;
        /*12a0*/                   FADD R14, R14, R31 ;
        /*12b0*/                   FADD R14, R14, R33 ;
        /*12c0*/                   FADD R37, R14, R37 ;
        /*12d0*/                   FADD R36, R37, R36 ;
        /*12e0*/                   FADD R35, R36, R35 ;
        /*12f0*/                   FADD R35, R35, R34 ;
        /*1300*/                   FADD R35, R35, R22 ;
        /*1310*/                   FADD R20, R35, R20 ;
        /*1320*/                   FADD R21, R20, R21 ;
        /*1330*/                   FADD R21, R21, R16 ;
        /*1340*/                   FADD R21, R21, R24 ;
        /*1350*/                   IADD3 R30, P3, R18, UR4, RZ ;
        /*1360*/                   FADD R26, R21, R26 ;
        /*1370*/                   IADD3.X R31, R19, UR5, RZ, P3, !PT ;
        /*1380*/                   FADD R26, R26, R23 ;
        /*1390*/                   FADD R15, R26, R17 ;
        /*13a0*/              @!P2 BRA `(.L_x_121) ;
.L_x_120:
        /*13b0*/                   BSYNC B2 ;
.L_x_119:
        /*13c0*/                   IMAD.IADD R6, R7, 0x1, -R32 ;
        /*13d0*/                   BSSY B2, `(.L_x_122) ;
        /*13e0*/                   ISETP.GT.AND P2, PT, R6, 0x4, PT ;
        /*13f0*/              @!P2 BRA `(.L_x_123) ;
        /*1400*/                   IADD3 R16, P0, R30, UR4, RZ ;
        /*1410*/                   LDG.E R30, [R30.64] ;
        /*1420*/                   IADD3.X R17, R31, UR5, RZ, P0, !PT ;
        /*1430*/                   IADD3 R18, P0, R16, UR4, RZ ;
        /*1440*/                   IADD3.X R19, R17, UR5, RZ, P0, !PT ;
        /*1450*/                   IADD3 R20, P0, R18, UR4, RZ ;
        /*1460*/                   LDG.E R17, [R16.64] ;
        /*1470*/                   IADD3.X R21, R19, UR5, RZ, P0, !PT ;
        /*1480*/                   LDG.E R18, [R18.64] ;
        /*1490*/                   IADD3 R22, P0, R20, UR4, RZ ;
        /*14a0*/                   LDG.E R20, [R20.64] ;
        /*14b0*/                   IADD3.X R23, R21, UR5, RZ, P0, !PT ;
        /*14c0*/                   IADD3 R24, P0, R22, UR4, RZ ;
        /*14d0*/                   LDG.E R22, [R22.64] ;
        /*14e0*/                   IADD3.X R25, R23, UR5, RZ, P0, !PT ;
        /*14f0*/                   IADD3 R26, P0, R24, UR4, RZ ;
        /*1500*/                   LDG.E R24, [R24.64] ;
        /*1510*/                   IADD3.X R27, R25, UR5, RZ, P0, !PT ;
        /*1520*/                   IADD3 R28, P0, R26, UR4, RZ ;
        /*1530*/                   LDG.E R26, [R26.64] ;
        /*1540*/                   IADD3.X R29, R27, UR5, RZ, P0, !PT ;
        /*1550*/                   LDG.E R6, [R28.64] ;
        /*1560*/                   PLOP3.LUT P0, PT, PT, PT, PT, 0x8, 0x0 ;
        /*1570*/                   IADD3 R32, R32, 0x8, RZ ;
        /*1580*/                   FADD R30, R15, R30 ;
        /*1590*/                   FADD R17, R30, R17 ;
        /*15a0*/                   FADD R17, R17, R18 ;
        /*15b0*/                   FADD R17, R17, R20 ;
        /*15c0*/                   FADD R17, R17, R22 ;
        /*15d0*/                   IADD3 R30, P2, R28, UR4, RZ ;
        /*15e0*/                   FADD R17, R17, R24 ;
        /*15f0*/                   IADD3.X R31, R29, UR5, RZ, P2, !PT ;
        /*1600*/                   FADD R17, R17, R26 ;
        /*1610*/                   FADD R15, R17, R6 ;
.L_x_123:
        /*1620*/                   BSYNC B2 ;
.L_x_122:
        /*1630*/                   ISETP.LT.OR P0, PT, R32, R7, P0 ;
        /*1640*/              @!P0 BRA `(.L_x_116) ;
        /*1650*/                   IADD3 R16, P0, R30, UR4, RZ ;
        /*1660*/                   LDG.E R30, [R30.64] ;
        /*1670*/                   IADD3.X R17, R31, UR5, RZ, P0, !PT ;
        /*1680*/                   IADD3 R18, P0, R16, UR4, RZ ;
        /*1690*/                   LDG.E R16, [R16.64] ;
        /*16a0*/                   IADD3.X R19, R17, UR5, RZ, P0, !PT ;
        /*16b0*/                   IADD3 R20, P0, R18, UR4, RZ ;
        /*16c0*/                   LDG.E R18, [R18.64] ;
        /*16d0*/                   IADD3.X R21, R19, UR5, RZ, P0, !PT ;
        /*16e0*/                   LDG.E R20, [R20.64] ;
        /*16f0*/                   FADD R15, R15, R30 ;
        /*1700*/                   FADD R15, R15, R16 ;
        /*1710*/                   FADD R15, R15, R18 ;
        /*1720*/                   FADD R15, R15, R20 ;
.L_x_116:
        /*1730*/                   BSYNC B0 ;
.L_x_115:
        /*1740*/                   IADD3 R2, R2, 0x1, RZ ;
        /*1750*/                   ISETP.GE.AND P0, PT, R2, R5, PT ;
        /*1760*/              @!P0 BRA `(.L_x_124) ;
.L_x_114:
        /*1770*/                   BSYNC B1 ;
.L_x_113:
        /*1780*/                   IMAD.MOV.U32 R5, RZ, RZ, 0x4 ;
        /*1790*/                   IMAD.WIDE R4, R0, R5, c[0x0][0x190] ;
        /*17a0*/                   LDG.E R2, [R4.64] ;
        /*17b0*/                   IMAD.MOV.U32 R7, RZ, RZ, c[0x0][0x0] ;
        /*17c0*/                   IMAD R0, R7, c[0x0][0xc], R0 ;
        /*17d0*/                   ISETP.GE.AND P0, PT, R0, c[0x0][0x160], PT ;
        /*17e0*/                   FADD R15, R2, R15 ;
        /*17f0*/                   STG.E [R4.64], R15 ;
        /*1800*/               @P0 CALL.REL.NOINC `(.L_x_125) ;
        /*1810*/                   BRA `(.L_x_126) ;
.L_x_125:
        /*1820*/                   EXIT ;
.L_x_127:
        /*1830*/                   BRA `(.L_x_127);
        /*1840*/                   NOP;
        /*1850*/                   NOP;
        /*1860*/                   NOP;
        /*1870*/                   NOP;
        /*1880*/                   NOP;
        /*1890*/                   NOP;
        /*18a0*/                   NOP;
        /*18b0*/                   NOP;
        /*18c0*/                   NOP;
        /*18d0*/                   NOP;
        /*18e0*/                   NOP;
        /*18f0*/                   NOP;
.L_x_456:


//--------------------- .text.im2col_kernel       --------------------------
	.section	.text.im2col_kernel,"ax",@progbits
	.sectioninfo	@"SHI_REGISTERS=40"
	.align	128
        .global         im2col_kernel
        .type           im2col_kernel,@function
        .size           im2col_kernel,(.L_x_457 - im2col_kernel)
        .other          im2col_kernel,@"STO_CUDA_ENTRY STV_DEFAULT"
im2col_kernel:
.text.im2col_kernel:
        /*0000*/                   IMAD.MOV.U32 R1, RZ, RZ, c[0x0][0x28] ;
        /*0010*/                   S2R R0, SR_CTAID.X ;
        /*0020*/                   S2R R3, SR_TID.X ;
        /*0030*/                   IMAD R0, R0, c[0x0][0x0], R3 ;
        /*0040*/                   ISETP.GE.AND P0, PT, R0, c[0x0][0x160], PT ;
        /*0050*/               @P0 EXIT ;
        /*0060*/                   ISETP.LT.AND P0, PT, RZ, c[0x0][0x178], PT ;
        /*0070*/              @!P0 EXIT ;
        /*0080*/                   IMAD.MOV.U32 R13, RZ, RZ, c[0x0][0x188] ;
        /*0090*/                   ULDC.64 UR4, c[0x0][0x118] ;
        /*00a0*/                   IMAD.MOV.U32 R12, RZ, RZ, c[0x0][0x178] ;
        /*00b0*/                   IMAD R13, R13, c[0x0][0x184], RZ ;
        /*00c0*/                   IMAD.MOV.U32 R14, RZ, RZ, 0x3 ;
        /*00d0*/                   IADD3 R2, R12.reuse, -0x1, RZ ;
        /*00e0*/                   IMAD R15, R12.reuse, c[0x0][0x178], RZ ;
        /*00f0*/                   LOP3.LUT R12, R12, 0x3, RZ, 0xc0, !PT ;
        /*0100*/                   IMAD.SHL.U32 R19, R13, 0x4, RZ ;
        /*0110*/                   SHF.R.S32.HI R16, RZ, 0x1f, R13 ;
        /*0120*/                   IMAD R15, R15, c[0x0][0x184], RZ ;
        /*0130*/                   ISETP.GE.U32.AND P2, PT, R2, 0x3, PT ;
        /*0140*/                   IADD3 R14, R14, -c[0x0][0x17c], RZ ;
        /*0150*/                   IADD3 R17, R12, -c[0x0][0x178], RZ ;
        /*0160*/                   SHF.L.U64.HI R21, R13, 0x2, R16 ;
.L_x_132:
        /*0170*/                   IABS R8, c[0x0][0x188] ;
        /*0180*/                   IMAD.MOV.U32 R20, RZ, RZ, c[0x0][0x180] ;
        /*0190*/                   IABS R10, c[0x0][0x184] ;
        /*01a0*/                   IMAD.MOV.U32 R25, RZ, RZ, RZ ;
        /*01b0*/                   I2F.RP R4, R8 ;
        /*01c0*/                   MUFU.RCP R4, R4 ;
        /*01d0*/                   IADD3 R2, R4, 0xffffffe, RZ ;
        /*01e0*/                   IABS R4, R0 ;
        /*01f0*/                   F2I.FTZ.U32.TRUNC.NTZ R3, R2 ;
        /*0200*/                   IMAD.MOV.U32 R2, RZ, RZ, RZ ;
        /*0210*/                   IMAD.MOV R5, RZ, RZ, -R3 ;
        /*0220*/                   IMAD R5, R5, R8, RZ ;
        /*0230*/                   IMAD.HI.U32 R3, R3, R5, R2 ;
        /*0240*/                   I2F.RP R5, R10 ;
        /*0250*/                   IMAD.HI.U32 R2, R3, R4, RZ ;
        /*0260*/                   IMAD.MOV R3, RZ, RZ, -R2 ;
        /*0270*/                   IMAD R3, R8, R3, R4 ;
        /*0280*/                   LOP3.LUT R4, R0, c[0x0][0x188], RZ, 0x3c, !PT ;
        /*0290*/                   MUFU.RCP R5, R5 ;
        /*02a0*/                   ISETP.GT.U32.AND P1, PT, R8, R3, PT ;
        /*02b0*/                   ISETP.GE.AND P3, PT, R4, RZ, PT ;
        /*02c0*/              @!P1 IMAD.IADD R3, R3, 0x1, -R8 ;
        /*02d0*/              @!P1 IADD3 R2, R2, 0x1, RZ ;
        /*02e0*/                   IADD3 R6, R5, 0xffffffe, RZ ;
        /*02f0*/                   ISETP.GE.U32.AND P0, PT, R3, R8, PT ;
        /*0300*/                   F2I.FTZ.U32.TRUNC.NTZ R3, R6 ;
        /*0310*/                   ISETP.NE.AND P1, PT, RZ, c[0x0][0x188], PT ;
        /*0320*/               @P0 IADD3 R2, R2, 0x1, RZ ;
        /*0330*/                   IMAD.MOV.U32 R7, RZ, RZ, R2 ;
        /*0340*/                   IMAD.MOV R5, RZ, RZ, -R3 ;
        /*0350*/              @!P3 IMAD.MOV R7, RZ, RZ, -R7 ;
        /*0360*/              @!P1 LOP3.LUT R7, RZ, c[0x0][0x188], RZ, 0x33, !PT ;
        /*0370*/                   IMAD R5, R5, R10, RZ ;
        /*0380*/                   IMAD.MOV.U32 R2, RZ, RZ, RZ ;
        /*0390*/                   IABS R4, R7 ;
        /*03a0*/                   IMAD.HI.U32 R2, R3, R5, R2 ;
        /*03b0*/                   IMAD.MOV.U32 R3, RZ, RZ, R4 ;
        /*03c0*/                   IMAD.HI.U32 R2, R2, R3, RZ ;
        /*03d0*/                   IMAD.MOV R4, RZ, RZ, -R2 ;
        /*03e0*/                   IMAD R3, R10, R4, R3 ;
        /*03f0*/                   ISETP.GT.U32.AND P1, PT, R10, R3, PT ;
        /*0400*/              @!P1 IMAD.IADD R3, R3, 0x1, -R10 ;
        /*0410*/              @!P1 IADD3 R2, R2, 0x1, RZ ;
        /*0420*/                   ISETP.NE.AND P1, PT, RZ, c[0x0][0x184], PT ;
        /*0430*/                   ISETP.GE.U32.AND P0, PT, R3, R10, PT ;
        /*0440*/                   LOP3.LUT R3, R7, c[0x0][0x184], RZ, 0x3c, !PT ;
        /*0450*/                   ISETP.GE.AND P3, PT, R3, RZ, PT ;
        /*0460*/                   IMAD.MOV R3, RZ, RZ, -R7 ;
        /*0470*/                   IMAD R3, R3, c[0x0][0x188], R0 ;
        /*0480*/               @P0 IADD3 R2, R2, 0x1, RZ ;
        /*0490*/                   IMAD R24, R3, c[0x0][0x180], R14 ;
        /*04a0*/              @!P3 IMAD.MOV R2, RZ, RZ, -R2 ;
        /*04b0*/              @!P1 LOP3.LUT R2, RZ, c[0x0][0x184], RZ, 0x33, !PT ;
        /*04c0*/                   IMAD.MOV R18, RZ, RZ, -R2 ;
        /*04d0*/                   IMAD R18, R18, c[0x0][0x184], R7 ;
        /*04e0*/                   SHF.R.S32.HI R7, RZ, 0x1f, R3 ;
        /*04f0*/                   IMAD R4, R15, R2, R18 ;
        /*0500*/                   IMAD R18, R18, R20.reuse, -c[0x0][0x17c] ;
        /*0510*/                   IMAD R4, R4, c[0x0][0x188], RZ ;
        /*0520*/                   IMAD R5, R2, c[0x0][0x170], R18 ;
        /*0530*/                   IMAD R20, R3.reuse, R20, -c[0x0][0x17c] ;
        /*0540*/                   IADD3 R28, P0, R3, R4, RZ ;
        /*0550*/                   IMAD R5, R5, c[0x0][0x174], RZ ;
        /*0560*/                   LEA.HI.X.SX32 R9, R4, R7, 0x1, P0 ;
        /*0570*/                   IMAD R7, R2, c[0x0][0x170], R18 ;
        /*0580*/                   LEA R27, P0, R28.reuse, c[0x0][0x190], 0x2 ;
        /*0590*/                   SHF.R.S32.HI R4, RZ, 0x1f, R20.reuse ;
        /*05a0*/                   IMAD R2, R7, c[0x0][0x174], R20 ;
        /*05b0*/                   LEA.HI.X R28, R28, c[0x0][0x194], R9, 0x2, P0 ;
        /*05c0*/                   IMAD.MOV.U32 R9, RZ, RZ, 0x4 ;
        /*05d0*/                   IADD3 R22, P1, R20, R5, RZ ;
        /*05e0*/                   IMAD.WIDE R2, R2, R9, c[0x0][0x168] ;
        /*05f0*/                   LEA.HI.X.SX32 R23, R5, R4, 0x1, P1 ;
.L_x_131:
        /*0600*/                   IMAD.IADD R26, R18, 0x1, R25 ;
        /*0610*/                   ISETP.NE.AND P3, PT, R12, RZ, PT ;
        /*0620*/                   IMAD R29, R25.reuse, c[0x0][0x174], RZ ;
        /*0630*/                   IADD3 R25, R25, 0x1, RZ ;
        /*0640*/                   IMAD.MOV.U32 R30, RZ, RZ, RZ ;
        /*0650*/                   ISETP.GE.AND P1, PT, R25, c[0x0][0x178], PT ;
        /*0660*/              @!P2 BRA `(.L_x_128) ;
        /*0670*/                   IMAD.WIDE R4, R29, 0x4, R2 ;
        /*0680*/                   ISETP.GE.AND P4, PT, R26, c[0x0][0x170], PT ;
        /*0690*/                   IMAD.MOV.U32 R9, RZ, RZ, R5 ;
        /*06a0*/                   IMAD.MOV.U32 R30, RZ, RZ, RZ ;
        /*06b0*/                   IMAD.MOV.U32 R32, RZ, RZ, R17 ;
        /*06c0*/                   IMAD.MOV.U32 R31, RZ, RZ, R24 ;
.L_x_129:
        /*06d0*/                   IADD3 R5, R31, -0x3, RZ ;
        /*06e0*/                   IMAD.MOV.U32 R11, RZ, RZ, RZ ;
        /*06f0*/                   LOP3.LUT R6, R5, R26, RZ, 0xfc, !PT ;
        /*0700*/                   ISETP.LT.OR P0, PT, R6, RZ, P4 ;
        /*0710*/                   ISETP.GE.OR P0, PT, R5, c[0x0][0x174], P0 ;
        /*0720*/                   IMAD.MOV.U32 R5, RZ, RZ, R9 ;
        /*0730*/              @!P0 LDG.E R11, [R4.64] ;
        /*0740*/                   IADD3 R7, R31, -0x2, RZ ;
        /*0750*/                   IMAD.MOV.U32 R33, RZ, RZ, RZ ;
        /*0760*/                   LOP3.LUT R6, R7, R26, RZ, 0xfc, !PT ;
        /*0770*/                   ISETP.LT.OR P0, PT, R6, RZ, P4 ;
        /*0780*/                   IMAD.MOV.U32 R6, RZ, RZ, R27 ;
        /*0790*/                   ISETP.GE.OR P0, PT, R7, c[0x0][0x174], P0 ;
        /*07a0*/                   IMAD.MOV.U32 R7, RZ, RZ, R28 ;
        /*07b0*/                   IADD3 R9, R31, -0x1, RZ ;
        /*07c0*/                   LOP3.LUT R8, R9, R26, RZ, 0xfc, !PT ;
        /*07d0*/                   STG.E [R6.64], R11 ;
        /*07e0*/              @!P0 LDG.E R33, [R4.64+0x4] ;
        /*07f0*/                   ISETP.LT.OR P0, PT, R8, RZ, P4 ;
        /*0800*/                   IMAD.MOV.U32 R37, RZ, RZ, RZ ;
        /*0810*/                   IADD3 R8, P5, R27, R19, RZ ;
        /*0820*/                   ISETP.GE.OR P0, PT, R9, c[0x0][0x174], P0 ;
        /*0830*/                   IMAD.X R9, R28, 0x1, R21, P5 ;
        /*0840*/                   LOP3.LUT R6, R31, R26, RZ, 0xfc, !PT ;
        /*0850*/                   STG.E [R8.64], R33 ;
        /*0860*/              @!P0 LDG.E R37, [R4.64+0x8] ;
        /*0870*/                   ISETP.LT.OR P0, PT, R6, RZ, P4 ;
        /*0880*/                   IMAD.MOV.U32 R35, RZ, RZ, RZ ;
        /*0890*/                   IADD3 R6, P5, R8, R19, RZ ;
        /*08a0*/                   ISETP.GE.OR P0, PT, R31, c[0x0][0x174], P0 ;
        /*08b0*/                   IMAD.X R7, R9, 0x1, R21, P5 ;
        /*08c0*/                   STG.E [R6.64], R37 ;
        /*08d0*/              @!P0 LDG.E R35, [R4.64+0xc] ;
        /*08e0*/                   IADD3 R10, P0, R6, R19.reuse, RZ ;
        /*08f0*/                   IADD3 R32, R32, 0x4, RZ ;
        /*0900*/                   IADD3 R27, P6, R10, R19, RZ ;
        /*0910*/                   IMAD.X R11, R7, 0x1, R21, P0 ;
        /*0920*/                   ISETP.NE.AND P0, PT, R32, RZ, PT ;
        /*0930*/                   IADD3 R30, R30, 0x4, RZ ;
        /*0940*/                   IMAD.X R28, R11, 0x1, R21, P6 ;
        /*0950*/                   IADD3 R4, P5, R4, 0x10, RZ ;
        /*0960*/                   IADD3 R31, R31, 0x4, RZ ;
        /*0970*/                   IMAD.X R9, RZ, RZ, R5, P5 ;
        /*0980*/                   STG.E [R10.64], R35 ;
        /*0990*/               @P0 BRA `(.L_x_129) ;
.L_x_128:
        /*09a0*/              @!P3 BRA `(.L_x_130) ;
        /*09b0*/                   IMAD.IADD R11, R20, 0x1, R30.reuse ;
        /*09c0*/                   ISETP.GE.AND P0, PT, R26, c[0x0][0x170], PT ;
        /*09d0*/                   IMAD.IADD R29, R29, 0x1, R30 ;
        /*09e0*/                   LOP3.LUT R4, R11, R26, RZ, 0xfc, !PT ;
        /*09f0*/                   IADD3 R5, P4, R29.reuse, R22, RZ ;
        /*0a00*/                   ISETP.LT.OR P3, PT, R4, RZ, P0 ;
        /*0a10*/                   LEA.HI.X.SX32 R6, R29, R23, 0x1, P4 ;
        /*0a20*/                   IMAD.MOV.U32 R29, RZ, RZ, RZ ;
        /*0a30*/                   ISETP.GE.OR P3, PT, R11, c[0x0][0x174], P3 ;
        /*0a40*/                   LEA R4, P4, R5, c[0x0][0x168], 0x2 ;
        /*0a50*/                   LEA.HI.X R5, R5, c[0x0][0x16c], R6, 0x2, P4 ;
        /*0a60*/              @!P3 LDG.E R29, [R4.64] ;
        /*0a70*/                   IMAD.MOV.U32 R8, RZ, RZ, R27.reuse ;
        /*0a80*/                   ISETP.NE.AND P3, PT, R12, 0x1, PT ;
        /*0a90*/                   IMAD.MOV.U32 R9, RZ, RZ, R28.reuse ;
        /*0aa0*/                   IMAD.MOV.U32 R6, RZ, RZ, R27 ;
        /*0ab0*/                   IADD3 R27, P4, R27, R19, RZ ;
        /*0ac0*/                   IMAD.MOV.U32 R7, RZ, RZ, R28 ;
        /*0ad0*/                   IMAD.X R28, R28, 0x1, R21, P4 ;
        /*0ae0*/                   STG.E [R8.64], R29 ;
        /*0af0*/              @!P3 BRA `(.L_x_130) ;
        /*0b00*/                   IADD3 R9, R11, 0x1, RZ ;
        /*0b10*/                   IMAD.MOV.U32 R29, RZ, RZ, RZ ;
        /*0b20*/                   LOP3.LUT R8, R9, R26, RZ, 0xfc, !PT ;
        /*0b30*/                   ISETP.LT.OR P3, PT, R8, RZ, P0 ;
        /*0b40*/                   ISETP.GE.OR P3, PT, R9, c[0x0][0x174], P3 ;
        /*0b50*/              @!P3 LDG.E R29, [R4.64+0x4] ;
        /*0b60*/                   IMAD.MOV.U32 R8, RZ, RZ, R27 ;
        /*0b70*/                   ISETP.NE.AND P3, PT, R12, 0x2, PT ;
        /*0b80*/                   IMAD.MOV.U32 R9, RZ, RZ, R28 ;
        /*0b90*/                   LEA R27, P4, R13, R6, 0x3 ;
        /*0ba0*/                   LEA.HI.X R28, R13, R7, R16, 0x3, P4 ;
        /*0bb0*/                   STG.E [R8.64], R29 ;
        /*0bc0*/              @!P3 BRA `(.L_x_130) ;
        /*0bd0*/                   IADD3 R11, R11, 0x2, RZ ;
        /*0be0*/                   IMAD.MOV.U32 R9, RZ, RZ, RZ ;
        /*0bf0*/                   LOP3.LUT R26, R11, R26, RZ, 0xfc, !PT ;
        /*0c00*/                   ISETP.LT.OR P0, PT, R26, RZ, P0 ;
        /*0c10*/                   ISETP.GE.OR P0, PT, R11, c[0x0][0x174], P0 ;
        /*0c20*/              @!P0 LDG.E R9, [R4.64+0x8] ;
        /*0c30*/                   IMAD R11, R16, 0xc, RZ ;
        /*0c40*/                   IMAD.WIDE.U32 R6, R13, 0xc, R6 ;
        /*0c50*/                   IMAD.MOV.U32 R4, RZ, RZ, R27 ;
        /*0c60*/                   IMAD.MOV.U32 R5, RZ, RZ, R28 ;
        /*0c70*/                   IMAD.IADD R28, R7, 0x1, R11 ;
        /*0c80*/                   IMAD.MOV.U32 R27, RZ, RZ, R6 ;
        /*0c90*/                   STG.E [R4.64], R9 ;
.L_x_130:
        /*0ca0*/              @!P1 BRA `(.L_x_131) ;
        /*0cb0*/                   IMAD.MOV.U32 R3, RZ, RZ, c[0x0][0x0] ;
        /*0cc0*/                   IMAD R0, R3, c[0x0][0xc], R0 ;
        /*0cd0*/                   ISETP.GE.AND P0, PT, R0, c[0x0][0x160], PT ;
        /*0ce0*/              @!P0 BRA `(.L_x_132) ;
        /*0cf0*/                   EXIT ;
.L_x_133:
        /*0d00*/                   BRA `(.L_x_133);
        /*0d10*/                   NOP;
        /*0d20*/                   NOP;
        /*0d30*/                   NOP;
        /*0d40*/                   NOP;
        /*0d50*/                   NOP;
        /*0d60*/                   NOP;
        /*0d70*/                   NOP;
        /*0d80*/                   NOP;
        /*0d90*/                   NOP;
        /*0da0*/                   NOP;
        /*0db0*/                   NOP;
        /*0dc0*/                   NOP;
        /*0dd0*/                   NOP;
        /*0de0*/                   NOP;
        /*0df0*/                   NOP;
.L_x_457:


//--------------------- .text.smooth_l1_kernel    --------------------------
	.section	.text.smooth_l1_kernel,"ax",@progbits
	.sectioninfo	@"SHI_REGISTERS=18"
	.align	128
        .global         smooth_l1_kernel
        .type           smooth_l1_kernel,@function
        .size           smooth_l1_kernel,(.L_x_458 - smooth_l1_kernel)
        .other          smooth_l1_kernel,@"STO_CUDA_ENTRY STV_DEFAULT"
smooth_l1_kernel:
.text.smooth_l1_kernel:
        /*0000*/                   MOV R1, c[0x0][0x28] ;
        /*0010*/                   S2R R8, SR_CTAID.X ;
        /*0020*/                   S2R R3, SR_TID.X ;
        /*0030*/                   IMAD R8, R8, c[0x0][0x0], R3 ;
        /*0040*/                   ISETP.GE.AND P0, PT, R8, c[0x0][0x160], PT ;
        /*0050*/               @P0 EXIT ;
        /*0060*/                   MOV R9, 0x4 ;
        /*0070*/                   ULDC.64 UR4, c[0x0][0x118] ;
        /*0080*/                   IMAD.WIDE R4, R8, R9, c[0x0][0x168] ;
        /*0090*/                   IMAD.WIDE R2, R8.reuse, R9.reuse, c[0x0][0x170] ;
        /*00a0*/                   LDG.E R4, [R4.64] ;
        /*00b0*/                   LDG.E R3, [R2.64] ;
        /*00c0*/                   IMAD.WIDE R6, R8, R9, c[0x0][0x180] ;
        /*00d0*/                   IMAD.WIDE R8, R8, R9, c[0x0][0x178] ;
        /*00e0*/                   FADD R11, -R4, R3 ;
        /*00f0*/                   FSETP.GEU.AND P0, PT, |R11|, 1, PT ;
        /*0100*/               @P0 MOV R0, 0x3f800000 ;
        /*0110*/               @P0 FSETP.GEU.AND P1, PT, R3, R4, PT ;
        /*0120*/               @P0 FFMA R13, |R11|, 2, -R0 ;
        /*0130*/               @P0 FSEL R15, R0, -1, !P1 ;
        /*0140*/               @P0 STG.E [R6.64], R13 ;
        /*0150*/               @P0 STG.E [R8.64], R15 ;
        /*0160*/               @P0 EXIT ;
        /*0170*/                   FMUL R3, R11, R11 ;
        /*0180*/                   STG.E [R6.64], R3 ;
        /*0190*/                   STG.E [R8.64], R11 ;
        /*01a0*/                   EXIT ;
.L_x_134:
        /*01b0*/                   BRA `(.L_x_134);
        /*01c0*/                   NOP;
        /*01d0*/                   NOP;
        /*01e0*/                   NOP;
        /*01f0*/                   NOP;
        /*0200*/                   NOP;
        /*0210*/                   NOP;
        /*0220*/                   NOP;
        /*0230*/                   NOP;
        /*0240*/                   NOP;
        /*0250*/                   NOP;
        /*0260*/                   NOP;
        /*0270*/                   NOP;
.L_x_458:


//--------------------- .text.l1_kernel           --------------------------
	.section	.text.l1_kernel,"ax",@progbits
	.sectioninfo	@"SHI_REGISTERS=16"
	.align	128
        .global         l1_kernel
        .type           l1_kernel,@function
        .size           l1_kernel,(.L_x_459 - l1_kernel)
        .other          l1_kernel,@"STO_CUDA_ENTRY STV_DEFAULT"
l1_kernel:
.text.l1_kernel:
        /*0000*/                   MOV R1, c[0x0][0x28] ;
        /*0010*/                   S2R R8, SR_CTAID.X ;
        /*0020*/                   S2R R3, SR_TID.X ;
        /*0030*/                   IMAD R8, R8, c[0x0][0x0], R3 ;
        /*0040*/                   ISETP.GE.AND P0, PT, R8, c[0x0][0x160], PT ;
        /*0050*/               @P0 EXIT ;
        /*0060*/                   MOV R9, 0x4 ;
        /*0070*/                   ULDC.64 UR4, c[0x0][0x118] ;
        /*0080*/                   IMAD.WIDE R4, R8, R9, c[0x0][0x168] ;
        /*0090*/                   IMAD.WIDE R2, R8.reuse, R9.reuse, c[0x0][0x170] ;
        /*00a0*/                   LDG.E R4, [R4.64] ;
        /*00b0*/                   LDG.E R3, [R2.64] ;
        /*00c0*/                   MOV R11, 0x3f800000 ;
        /*00d0*/                   IMAD.WIDE R6, R8, R9, c[0x0][0x180] ;
        /*00e0*/                   IMAD.WIDE R8, R8, R9, c[0x0][0x178] ;
        /*00f0*/                   FADD R0, -R4, R3 ;
        /*0100*/                   FSETP.GT.AND P0, PT, R3, R4, PT ;
        /*0110*/                   FADD R13, |R0|, -RZ ;
        /*0120*/                   FSEL R11, R11, -1, P0 ;
        /*0130*/                   STG.E [R6.64], R13 ;
        /*0140*/                   STG.E [R8.64], R11 ;
        /*0150*/                   EXIT ;
.L_x_135:
        /*0160*/                   BRA `(.L_x_135);
        /*0170*/                   NOP;
        /*0180*/                   NOP;
        /*0190*/                   NOP;
        /*01a0*/                   NOP;
        /*01b0*/                   NOP;
        /*01c0*/                   NOP;
        /*01d0*/                   NOP;
        /*01e0*/                   NOP;
        /*01f0*/                   NOP;
.L_x_459:


//--------------------- .text.l2_kernel           --------------------------
	.section	.text.l2_kernel,"ax",@progbits
	.sectioninfo	@"SHI_REGISTERS=16"
	.align	128
        .global         l2_kernel
        .type           l2_kernel,@function
        .size           l2_kernel,(.L_x_460 - l2_kernel)
        .other          l2_kernel,@"STO_CUDA_ENTRY STV_DEFAULT"
l2_kernel:
.text.l2_kernel:
        /*0000*/                   MOV R1, c[0x0][0x28] ;
        /*0010*/                   S2R R8, SR_CTAID.X ;
        /*0020*/                   S2R R3, SR_TID.X ;
        /*0030*/                   IMAD R8, R8, c[0x0][0x0], R3 ;
        /*0040*/                   ISETP.GE.AND P0, PT, R8, c[0x0][0x160], PT ;
        /*0050*/               @P0 EXIT ;
        /*0060*/                   MOV R9, 0x4 ;
        /*0070*/                   ULDC.64 UR4, c[0x0][0x118] ;
        /*0080*/                   IMAD.WIDE R4, R8, R9, c[0x0][0x168] ;
        /*0090*/                   IMAD.WIDE R2, R8.reuse, R9.reuse, c[0x0][0x170] ;
        /*00a0*/                   LDG.E R4, [R4.64] ;
        /*00b0*/                   LDG.E R3, [R2.64] ;
        /*00c0*/                   IMAD.WIDE R6, R8, R9, c[0x0][0x180] ;
        /*00d0*/                   IMAD.WIDE R8, R8, R9, c[0x0][0x178] ;
        /*00e0*/                   FADD R11, -R4, R3 ;
        /*00f0*/                   FMUL R13, R11, R11 ;
        /*0100*/                   STG.E [R6.64], R13 ;
        /*0110*/                   STG.E [R8.64], R11 ;
        /*0120*/                   EXIT ;
.L_x_136:
        /*0130*/                   BRA `(.L_x_136);
        /*0140*/                   NOP;
        /*0150*/                   NOP;
        /*0160*/                   NOP;
        /*0170*/                   NOP;
        /*0180*/                   NOP;
        /*0190*/                   NOP;
        /*01a0*/                   NOP;
        /*01b0*/                   NOP;
        /*01c0*/                   NOP;
        /*01d0*/                   NOP;
        /*01e0*/                   NOP;
        /*01f0*/                   NOP;
.L_x_460:


//--------------------- .text.softmax_x_ent_kernel --------------------------
	.section	.text.softmax_x_ent_kernel,"ax",@progbits
	.sectioninfo	@"SHI_REGISTERS=14"
	.align	128
        .global         softmax_x_ent_kernel
        .type           softmax_x_ent_kernel,@function
        .size           softmax_x_ent_kernel,(.L_x_461 - softmax_x_ent_kernel)
        .other          softmax_x_ent_kernel,@"STO_CUDA_ENTRY STV_DEFAULT"
softmax_x_ent_kernel:
.text.softmax_x_ent_kernel:
        /*0000*/                   MOV R1, c[0x0][0x28] ;
        /*0010*/                   S2R R0, SR_CTAID.X ;
        /*0020*/                   S2R R3, SR_TID.X ;
        /*0030*/                   IMAD R0, R0, c[0x0][0x0], R3 ;
        /*0040*/                   ISETP.GE.AND P0, PT, R0, c[0x0][0x160], PT ;
        /*0050*/               @P0 EXIT ;
        /*0060*/                   MOV R9, 0x4 ;
        /*0070*/                   ULDC.64 UR4, c[0x0][0x118] ;
        /*0080*/                   IMAD.WIDE R6, R0, R9, c[0x0][0x170] ;
        /*0090*/                   LDG.E R7, [R6.64] ;
        /*00a0*/                   IMAD.WIDE R8, R0, R9, c[0x0][0x168] ;
        /*00b0*/                   LDG.E R8, [R8.64] ;
        /*00c0*/                   IMAD.SHL.U32 R4, R0, 0x4, RZ ;
        /*00d0*/                   SHF.R.S32.HI R3, RZ, 0x1f, R0 ;
        /*00e0*/                   BSSY B0, `(.L_x_137) ;
        /*00f0*/                   IADD3 R2, P1, R4, c[0x0][0x180], RZ ;
        /*0100*/                   SHF.L.U64.HI R0, R0, 0x2, R3 ;
        /*0110*/                   IADD3 R4, P2, R4, c[0x0][0x178], RZ ;
        /*0120*/                   IADD3.X R3, R0.reuse, c[0x0][0x184], RZ, P1, !PT ;
        /*0130*/                   IADD3.X R5, R0, c[0x0][0x17c], RZ, P2, !PT ;
        /*0140*/                   FSETP.NEU.AND P0, PT, R7, RZ, PT ;
        /*0150*/                   FADD R11, -R8, R7 ;
        /*0160*/                   MOV R7, RZ ;
        /*0170*/              @!P0 BRA `(.L_x_138) ;
        /*0180*/                   FMNMX R8, R8, 9.999999682655225389e-21, !PT ;
        /*0190*/                   MOV R9, 0x3e055027 ;
        /*01a0*/                   FSETP.GEU.AND P0, PT, R8, 1.175494350822287508e-38, PT ;
        /*01b0*/              @!P0 FMUL R8, R8, 8388608 ;
        /*01c0*/                   IADD3 R0, R8.reuse, -0x3f2aaaab, RZ ;
        /*01d0*/                   ISETP.GE.U32.AND P1, PT, R8, 0x7f800000, PT ;
        /*01e0*/                   LOP3.LUT R7, R0, 0xff800000, RZ, 0xc0, !PT ;
        /*01f0*/                   IMAD.IADD R0, R8, 0x1, -R7 ;
        /*0200*/                   I2FP.F32.S32 R7, R7 ;
        /*0210*/                   FADD R6, R0, -1 ;
        /*0220*/                   FSEL R0, RZ, -23, P0 ;
        /*0230*/                   FSETP.NEU.AND P0, PT, R8, RZ, PT ;
        /*0240*/                   FFMA R9, R6.reuse, -R9, 0.14084610342979431152 ;
        /*0250*/                   FFMA R0, R7, 1.1920928955078125e-07, R0 ;
        /*0260*/               @P1 MOV R7, 0x7f800000 ;
        /*0270*/                   FFMA R9, R6, R9, -0.12148627638816833496 ;
        /*0280*/                   FFMA R9, R6, R9, 0.13980610668659210205 ;
        /*0290*/                   FFMA R9, R6, R9, -0.16684235632419586182 ;
        /*02a0*/                   FFMA R9, R6, R9, 0.20012299716472625732 ;
        /*02b0*/                   FFMA R9, R6, R9, -0.24999669194221496582 ;
        /*02c0*/                   FFMA R9, R6, R9, 0.33333182334899902344 ;
        /*02d0*/                   FFMA R9, R6, R9, -0.5 ;
        /*02e0*/                   FMUL R9, R6, R9 ;
        /*02f0*/                   FFMA R9, R6, R9, R6 ;
        /*0300*/                   FFMA R0, R0, 0.69314718246459960938, R9 ;
        /*0310*/               @P1 FFMA R0, R8, R7, +INF  ;
        /*0320*/                   FSEL R7, -R0, +INF , P0 ;
.L_x_138:
        /*0330*/                   BSYNC B0 ;
.L_x_137:
        /*0340*/                   STG.E [R2.64], R7 ;
        /*0350*/                   STG.E [R4.64], R11 ;
        /*0360*/                   EXIT ;
.L_x_139:
        /*0370*/                   BRA `(.L_x_139);
        /*0380*/                   NOP;
        /*0390*/                   NOP;
        /*03a0*/                   NOP;
        /*03b0*/                   NOP;
        /*03c0*/                   NOP;
        /*03d0*/                   NOP;
        /*03e0*/                   NOP;
        /*03f0*/                   NOP;
.L_x_461:


//--------------------- .text.softmax_kernel      --------------------------
	.section	.text.softmax_kernel,"ax",@progbits
	.sectioninfo	@"SHI_REGISTERS=38"
	.align	128
        .global         softmax_kernel
        .type           softmax_kernel,@function
        .size           softmax_kernel,(.L_x_437 - softmax_kernel)
        .other          softmax_kernel,@"STO_CUDA_ENTRY STV_DEFAULT"
softmax_kernel:
.text.softmax_kernel:
        /*0000*/                   IMAD.MOV.U32 R1, RZ, RZ, c[0x0][0x28] ;
        /*0010*/                   S2R R0, SR_CTAID.X ;
        /*0020*/                   ULDC UR4, c[0x0][0x174] ;
        /*0030*/                   ULDC UR5, c[0x0][0x16c] ;
        /*0040*/                   S2R R3, SR_TID.X ;
        /*0050*/                   UIMAD UR4, UR4, UR5, URZ ;
        /*0060*/                   IMAD R0, R0, c[0x0][0x0], R3 ;
        /*0070*/                   ISETP.GE.AND P0, PT, R0, UR4, PT ;
        /*0080*/               @P0 EXIT ;
        /*0090*/                   IABS R5, c[0x0][0x174] ;
        /*00a0*/                   IMAD.MOV.U32 R19, RZ, RZ, c[0x0][0x168] ;
        /*00b0*/                   ULDC.64 UR4, c[0x0][0x118] ;
        /*00c0*/                   I2F.RP R4, R5 ;
        /*00d0*/                   MUFU.RCP R4, R4 ;
        /*00e0*/                   IADD3 R2, R4, 0xffffffe, RZ ;
        /*00f0*/                   F2I.FTZ.U32.TRUNC.NTZ R3, R2 ;
        /*0100*/                   MOV R2, RZ ;
        /*0110*/                   IMAD.MOV R6, RZ, RZ, -R3 ;
        /*0120*/                   IMAD R7, R6, R5, RZ ;
        /*0130*/                   IABS R6, R0 ;
        /*0140*/                   IMAD.HI.U32 R3, R3, R7, R2 ;
        /*0150*/                   LOP3.LUT R2, R0, c[0x0][0x174], RZ, 0x3c, !PT ;
        /*0160*/                   ISETP.GE.AND P2, PT, R2, RZ, PT ;
        /*0170*/                   IMAD.HI.U32 R3, R3, R6, RZ ;
        /*0180*/                   IMAD.MOV R4, RZ, RZ, -R3 ;
        /*0190*/                   IMAD R4, R5, R4, R6 ;
        /*01a0*/                   ISETP.GT.U32.AND P1, PT, R5, R4, PT ;
        /*01b0*/              @!P1 IMAD.IADD R4, R4, 0x1, -R5 ;
        /*01c0*/              @!P1 IADD3 R3, R3, 0x1, RZ ;
        /*01d0*/                   ISETP.NE.AND P1, PT, RZ, c[0x0][0x174], PT ;
        /*01e0*/                   ISETP.GE.U32.AND P0, PT, R4, R5, PT ;
        /*01f0*/               @P0 IADD3 R3, R3, 0x1, RZ ;
        /*0200*/              @!P2 IADD3 R3, -R3, RZ, RZ ;
        /*0210*/              @!P1 LOP3.LUT R3, RZ, c[0x0][0x174], RZ, 0x33, !PT ;
        /*0220*/                   ISETP.GE.AND P2, PT, R19, 0x1, PT ;
        /*0230*/                   IMAD.MOV R5, RZ, RZ, -R3 ;
        /*0240*/                   IMAD R4, R3, c[0x0][0x170], RZ ;
        /*0250*/                   IMAD R3, R5, c[0x0][0x174], R0 ;
        /*0260*/                   MOV R0, 0xff800000 ;
        /*0270*/                   IMAD R4, R3, c[0x0][0x178], R4 ;
        /*0280*/                   SHF.R.S32.HI R5, RZ, 0x1f, R4 ;
        /*0290*/              @!P2 BRA `(.L_x_140) ;
        /*02a0*/                   IADD3 R0, R19.reuse, -0x1, RZ ;
        /*02b0*/                   IMAD.MOV.U32 R18, RZ, RZ, RZ ;
        /*02c0*/                   LOP3.LUT R19, R19, 0x3, RZ, 0xc0, !PT ;
        /*02d0*/                   ISETP.GE.U32.AND P0, PT, R0, 0x3, PT ;
        /*02e0*/                   IMAD.MOV.U32 R0, RZ, RZ, -0x800000 ;
        /*02f0*/              @!P0 BRA `(.L_x_141) ;
        /*0300*/                   IADD3 R20, -R19, c[0x0][0x168], RZ ;
        /*0310*/                   IMAD.MOV.U32 R18, RZ, RZ, RZ ;
        /*0320*/                   LEA R10, P1, R4, c[0x0][0x160], 0x2 ;
        /*0330*/                   ISETP.GT.AND P0, PT, R20, RZ, PT ;
        /*0340*/                   LEA.HI.X R11, R4, c[0x0][0x164], R5, 0x2, P1 ;
        /*0350*/                   MOV R0, 0xff800000 ;
        /*0360*/              @!P0 BRA `(.L_x_142) ;
        /*0370*/                   ISETP.GT.AND P1, PT, R20, 0xc, PT ;
        /*0380*/                   PLOP3.LUT P0, PT, PT, PT, PT, 0x80, 0x0 ;
        /*0390*/              @!P1 BRA `(.L_x_143) ;
        /*03a0*/                   PLOP3.LUT P0, PT, PT, PT, PT, 0x8, 0x0 ;
.L_x_144:
        /*03b0*/                   IMAD.MOV.U32 R21, RZ, RZ, c[0x0][0x17c] ;
        /*03c0*/                   LDG.E R23, [R10.64] ;
        /*03d0*/                   IMAD.WIDE R12, R21, 0x4, R10 ;
        /*03e0*/                   LDG.E R22, [R12.64] ;
        /*03f0*/                   IMAD.WIDE R14, R21, 0x4, R12 ;
        /*0400*/                   LDG.E R26, [R14.64] ;
        /*0410*/                   IMAD.WIDE R34, R21, 0x4, R14 ;
        /*0420*/                   LDG.E R27, [R34.64] ;
        /*0430*/                   IMAD.WIDE R16, R21, 0x4, R34 ;
        /*0440*/                   LDG.E R30, [R16.64] ;
        /*0450*/                   IMAD.WIDE R28, R21, 0x4, R16 ;
        /*0460*/                   IMAD.WIDE R24, R21.reuse, 0x4, R28 ;
        /*0470*/                   LDG.E R28, [R28.64] ;
        /*0480*/                   IMAD.WIDE R8, R21.reuse, 0x4, R24 ;
        /*0490*/                   LDG.E R31, [R24.64] ;
        /*04a0*/                   LDG.E R32, [R8.64] ;
        /*04b0*/                   IMAD.WIDE R2, R21, 0x4, R8 ;
        /*04c0*/                   IMAD.WIDE R6, R21.reuse, 0x4, R2 ;
        /*04d0*/                   LDG.E R2, [R2.64] ;
        /*04e0*/                   IMAD.WIDE R10, R21.reuse, 0x4, R6 ;
        /*04f0*/                   LDG.E R6, [R6.64] ;
        /*0500*/                   IMAD.WIDE R12, R21, 0x4, R10 ;
        /*0510*/                   LDG.E R10, [R10.64] ;
        /*0520*/                   IMAD.WIDE R14, R21.reuse, 0x4, R12 ;
        /*0530*/                   LDG.E R12, [R12.64] ;
        /*0540*/                   IMAD.WIDE R16, R21, 0x4, R14 ;
        /*0550*/                   LDG.E R14, [R14.64] ;
        /*0560*/                   IMAD.WIDE R24, R21.reuse, 0x4, R16 ;
        /*0570*/                   LDG.E R16, [R16.64] ;
        /*0580*/                   IMAD.WIDE R8, R21, 0x4, R24 ;
        /*0590*/                   LDG.E R24, [R24.64] ;
        /*05a0*/                   LDG.E R3, [R8.64] ;
        /*05b0*/                   IADD3 R20, R20, -0x10, RZ ;
        /*05c0*/                   ISETP.GT.AND P1, PT, R20, 0xc, PT ;
        /*05d0*/                   IADD3 R18, R18, 0x10, RZ ;
        /*05e0*/                   FMNMX R23, R23, R0, !PT ;
        /*05f0*/                   FMNMX R23, R23, R22, !PT ;
        /*0600*/                   FMNMX R26, R23, R26, !PT ;
        /*0610*/                   FMNMX R27, R26, R27, !PT ;
        /*0620*/                   FMNMX R27, R27, R30, !PT ;
        /*0630*/                   FMNMX R28, R27, R28, !PT ;
        /*0640*/                   FMNMX R31, R28, R31, !PT ;
        /*0650*/                   FMNMX R31, R31, R32, !PT ;
        /*0660*/                   FMNMX R31, R31, R2, !PT ;
        /*0670*/                   FMNMX R31, R31, R6, !PT ;
        /*0680*/                   FMNMX R31, R31, R10, !PT ;
        /*0690*/                   FMNMX R31, R31, R12, !PT ;
        /*06a0*/                   FMNMX R31, R31, R14, !PT ;
        /*06b0*/                   FMNMX R31, R31, R16, !PT ;
        /*06c0*/                   IMAD.WIDE R10, R21, 0x4, R8 ;
        /*06d0*/                   FMNMX R24, R31, R24, !PT ;
        /*06e0*/                   FMNMX R0, R24, R3, !PT ;
        /*06f0*/               @P1 BRA `(.L_x_144) ;
.L_x_143:
        /*0700*/                   ISETP.GT.AND P1, PT, R20, 0x4, PT ;
        /*0710*/              @!P1 BRA `(.L_x_145) ;
        /*0720*/                   MOV R7, c[0x0][0x17c] ;
        /*0730*/                   IMAD.WIDE R8, R7.reuse, 0x4, R10 ;
        /*0740*/                   LDG.E R11, [R10.64] ;
        /*0750*/                   IMAD.WIDE R12, R7.reuse, 0x4, R8 ;
        /*0760*/                   LDG.E R8, [R8.64] ;
        /*0770*/                   IMAD.WIDE R14, R7, 0x4, R12 ;
        /*0780*/                   LDG.E R13, [R12.64] ;
        /*0790*/                   IMAD.WIDE R16, R7.reuse, 0x4, R14 ;
        /*07a0*/                   LDG.E R15, [R14.64] ;
        /*07b0*/                   IMAD.WIDE R22, R7, 0x4, R16 ;
        /*07c0*/                   LDG.E R17, [R16.64] ;
        /*07d0*/                   IMAD.WIDE R24, R7.reuse, 0x4, R22 ;
        /*07e0*/                   LDG.E R23, [R22.64] ;
        /*07f0*/                   IMAD.WIDE R2, R7, 0x4, R24 ;
        /*0800*/                   LDG.E R25, [R24.64] ;
        /*0810*/                   LDG.E R21, [R2.64] ;
        /*0820*/                   PLOP3.LUT P0, PT, PT, PT, PT, 0x8, 0x0 ;
        /*0830*/                   IADD3 R18, R18, 0x8, RZ ;
        /*0840*/                   IADD3 R20, R20, -0x8, RZ ;
        /*0850*/                   FMNMX R11, R0, R11, !PT ;
        /*0860*/                   FMNMX R8, R11, R8, !PT ;
        /*0870*/                   FMNMX R8, R8, R13, !PT ;
        /*0880*/                   FMNMX R8, R8, R15, !PT ;
        /*0890*/                   FMNMX R8, R8, R17, !PT ;
        /*08a0*/                   FMNMX R8, R8, R23, !PT ;
        /*08b0*/                   IMAD.WIDE R10, R7, 0x4, R2 ;
        /*08c0*/                   FMNMX R8, R8, R25, !PT ;
        /*08d0*/                   FMNMX R0, R8, R21, !PT ;
.L_x_145:
        /*08e0*/                   ISETP.NE.OR P0, PT, R20, RZ, P0 ;
        /*08f0*/              @!P0 BRA `(.L_x_141) ;
.L_x_142:
        /*0900*/                   IMAD.MOV.U32 R15, RZ, RZ, c[0x0][0x17c] ;
        /*0910*/                   IMAD.WIDE R2, R15.reuse, 0x4, R10 ;
        /*0920*/                   LDG.E R11, [R10.64] ;
        /*0930*/                   IMAD.WIDE R6, R15.reuse, 0x4, R2 ;
        /*0940*/                   LDG.E R3, [R2.64] ;
        /*0950*/                   IMAD.WIDE R8, R15, 0x4, R6 ;
        /*0960*/                   LDG.E R7, [R6.64] ;
        /*0970*/                   LDG.E R13, [R8.64] ;
        /*0980*/                   IADD3 R20, R20, -0x4, RZ ;
        /*0990*/                   IADD3 R18, R18, 0x4, RZ ;
        /*09a0*/                   ISETP.NE.AND P0, PT, R20, RZ, PT ;
        /*09b0*/                   FMNMX R0, R11, R0, !PT ;
        /*09c0*/                   IMAD.WIDE R10, R15, 0x4, R8 ;
        /*09d0*/                   FMNMX R0, R0, R3, !PT ;
        /*09e0*/                   FMNMX R0, R0, R7, !PT ;
        /*09f0*/                   FMNMX R0, R0, R13, !PT ;
        /*0a00*/               @P0 BRA `(.L_x_142) ;
.L_x_141:
        /*0a10*/                   ISETP.NE.AND P0, PT, R19, RZ, PT ;
        /*0a20*/              @!P0 BRA `(.L_x_140) ;
        /*0a30*/                   IMAD R18, R18, c[0x0][0x17c], RZ ;
        /*0a40*/                   IADD3 R3, P0, R4, R18, RZ ;
        /*0a50*/                   LEA R2, P1, R3, c[0x0][0x160], 0x2 ;
        /*0a60*/                   LEA.HI.X.SX32 R18, R18, R5, 0x1, P0 ;
        /*0a70*/                   LEA.HI.X R3, R3, c[0x0][0x164], R18, 0x2, P1 ;
.L_x_146:
        /*0a80*/                   IMAD.MOV.U32 R6, RZ, RZ, R2 ;
        /*0a90*/                   MOV R7, R3 ;
        /*0aa0*/                   LDG.E R9, [R6.64] ;
        /*0ab0*/                   IADD3 R19, R19, -0x1, RZ ;
        /*0ac0*/                   IMAD.MOV.U32 R3, RZ, RZ, c[0x0][0x17c] ;
        /*0ad0*/                   ISETP.NE.AND P0, PT, R19, RZ, PT ;
        /*0ae0*/                   IMAD.WIDE R2, R3, 0x4, R6 ;
        /*0af0*/                   FMNMX R0, R9, R0, !PT ;
        /*0b00*/               @P0 BRA `(.L_x_146) ;
.L_x_140:
        /*0b10*/                   IMAD.MOV.U32 R12, RZ, RZ, RZ ;
        /*0b20*/              @!P2 BRA `(.L_x_147) ;
        /*0b30*/                   MUFU.RCP R11, c[0x0][0x180] ;
        /*0b40*/                   MOV R2, c[0x0][0x180] ;
        /*0b50*/                   BSSY B2, `(.L_x_148) ;
        /*0b60*/                   FCHK P0, R0, c[0x0][0x180] ;
        /*0b70*/                   FFMA R2, R11, -R2, 1 ;
        /*0b80*/                   FFMA R11, R11, R2, R11 ;
        /*0b90*/                   FFMA R3, R11, R0, RZ ;
        /*0ba0*/                   FFMA R2, R3, -c[0x0][0x180], R0 ;
        /*0bb0*/                   FFMA R11, R11, R2, R3 ;
        /*0bc0*/              @!P0 BRA `(.L_x_149) ;
        /*0bd0*/                   IMAD.MOV.U32 R3, RZ, RZ, R0 ;
        /*0be0*/                   MOV R0, c[0x0][0x180] ;
        /*0bf0*/                   MOV R2, 0xc10 ;
        /*0c00*/                   CALL.REL.NOINC `($__internal_4_$__cuda_sm3x_div_rn_noftz_f32_slowpath) ;
        /*0c10*/                   IMAD.MOV.U32 R11, RZ, RZ, R0 ;
.L_x_149:
        /*0c20*/                   BSYNC B2 ;
.L_x_148:
        /*0c30*/                   MOV R9, c[0x0][0x168] ;
        /*0c40*/                   IMAD.MOV.U32 R12, RZ, RZ, RZ ;
        /*0c50*/                   MOV R10, RZ ;
        /*0c60*/                   IADD3 R0, R9.reuse, -0x1, RZ ;
        /*0c70*/                   LOP3.LUT R9, R9, 0x3, RZ, 0xc0, !PT ;
        /*0c80*/                   ISETP.GE.U32.AND P0, PT, R0, 0x3, PT ;
        /*0c90*/              @!P0 BRA `(.L_x_150) ;
        /*0ca0*/                   IMAD.SHL.U32 R6, R4.reuse, 0x4, RZ ;
        /*0cb0*/                   SHF.L.U64.HI R13, R4, 0x2, R5 ;
        /*0cc0*/                   IMAD.MOV.U32 R10, RZ, RZ, RZ ;
        /*0cd0*/                   IADD3 R8, -R9, c[0x0][0x168], RZ ;
        /*0ce0*/                   IADD3 R18, P0, R6.reuse, c[0x0][0x160], RZ ;
        /*0cf0*/                   IADD3 R6, P1, R6, c[0x0][0x188], RZ ;
        /*0d00*/                   IADD3.X R19, R13, c[0x0][0x164], RZ, P0, !PT ;
        /*0d10*/                   MOV R12, RZ ;
        /*0d20*/                   IADD3.X R13, R13, c[0x0][0x18c], RZ, P1, !PT ;
.L_x_159:
        /*0d30*/                   LDG.E R16, [R18.64] ;
        /*0d40*/                   MUFU.RCP R0, c[0x0][0x180] ;
        /*0d50*/                   MOV R3, c[0x0][0x180] ;
        /*0d60*/                   BSSY B2, `(.L_x_151) ;
        /*0d70*/                   IMAD.MOV.U32 R14, RZ, RZ, R6 ;
        /*0d80*/                   MOV R15, R13 ;
        /*0d90*/                   FFMA R3, R0, -R3, 1 ;
        /*0da0*/                   FFMA R0, R0, R3, R0 ;
        /*0db0*/                   FCHK P0, R16, c[0x0][0x180] ;
        /*0dc0*/                   FFMA R3, R0, R16, RZ ;
        /*0dd0*/                   FFMA R2, R3, -c[0x0][0x180], R16 ;
        /*0de0*/                   FFMA R0, R0, R2, R3 ;
        /*0df0*/              @!P0 BRA `(.L_x_152) ;
        /*0e00*/                   IMAD.MOV.U32 R3, RZ, RZ, R16 ;
        /*0e10*/                   MOV R0, c[0x0][0x180] ;
        /*0e20*/                   MOV R2, 0xe40 ;
        /*0e30*/                   CALL.REL.NOINC `($__internal_4_$__cuda_sm3x_div_rn_noftz_f32_slowpath) ;
.L_x_152:
        /*0e40*/                   BSYNC B2 ;
.L_x_151:
        /*0e50*/                   IMAD.MOV.U32 R3, RZ, RZ, 0x3bbb989d ;
        /*0e60*/                   FADD R0, R0, -R11 ;
        /*0e70*/                   MOV R7, 0x437c0000 ;
        /*0e80*/                   MOV R13, c[0x0][0x17c] ;
        /*0e90*/                   FFMA.SAT R2, R0, R3, 0.5 ;
        /*0ea0*/                   FFMA.RM R2, R2, R7, 12582913 ;
        /*0eb0*/                   IMAD.WIDE R18, R13, 0x4, R18 ;
        /*0ec0*/                   FADD R3, R2.reuse, -12583039 ;
        /*0ed0*/                   IMAD.SHL.U32 R2, R2, 0x800000, RZ ;
        /*0ee0*/                   FFMA R3, R0, 1.4426950216293334961, -R3 ;
        /*0ef0*/                   FFMA R3, R0, 1.925963033500011079e-08, R3 ;
        /*0f00*/                   MUFU.EX2 R3, R3 ;
        /*0f10*/                   FMUL R7, R2, R3 ;
        /*0f20*/                   STG.E [R14.64], R7 ;
        /*0f30*/                   LDG.E R6, [R18.64] ;
        /*0f40*/                   MUFU.RCP R0, c[0x0][0x180] ;
        /*0f50*/                   IMAD.MOV.U32 R13, RZ, RZ, c[0x0][0x180] ;
        /*0f60*/                   BSSY B2, `(.L_x_153) ;
        /*0f70*/                   FADD R12, R7, R12 ;
        /*0f80*/                   FFMA R13, R0, -R13, 1 ;
        /*0f90*/                   FFMA R0, R0, R13, R0 ;
        /*0fa0*/                   FCHK P0, R6, c[0x0][0x180] ;
        /*0fb0*/                   FFMA R3, R0, R6, RZ ;
        /*0fc0*/                   FFMA R2, R3, -c[0x0][0x180], R6 ;
        /*0fd0*/                   FFMA R0, R0, R2, R3 ;
        /*0fe0*/              @!P0 BRA `(.L_x_154) ;
        /*0ff0*/                   MOV R3, R6 ;
        /*1000*/                   IMAD.MOV.U32 R0, RZ, RZ, c[0x0][0x180] ;
        /*1010*/                   MOV R2, 0x1030 ;
        /*1020*/                   CALL.REL.NOINC `($__internal_4_$__cuda_sm3x_div_rn_noftz_f32_slowpath) ;
.L_x_154:
        /*1030*/                   BSYNC B2 ;
.L_x_153:
        /*1040*/                   MOV R3, 0x3bbb989d ;
        /*1050*/                   FADD R0, R0, -R11 ;
        /*1060*/                   IMAD.MOV.U32 R7, RZ, RZ, 0x437c0000 ;
        /*1070*/                   MOV R13, c[0x0][0x17c] ;
        /*1080*/                   FFMA.SAT R2, R0, R3, 0.5 ;
        /*1090*/                   IMAD.WIDE R14, R13, 0x4, R14 ;
        /*10a0*/                   FFMA.RM R2, R2, R7, 12582913 ;
        /*10b0*/                   IMAD.WIDE R18, R13, 0x4, R18 ;
        /*10c0*/                   FADD R3, R2, -12583039 ;
        /*10d0*/                   IMAD.SHL.U32 R2, R2, 0x800000, RZ ;
        /*10e0*/                   FFMA R3, R0, 1.4426950216293334961, -R3 ;
        /*10f0*/                   FFMA R3, R0, 1.925963033500011079e-08, R3 ;
        /*1100*/                   MUFU.EX2 R3, R3 ;
        /*1110*/                   FMUL R7, R2, R3 ;
        /*1120*/                   STG.E [R14.64], R7 ;
        /*1130*/                   LDG.E R6, [R18.64] ;
        /*1140*/                   MUFU.RCP R0, c[0x0][0x180] ;
        /*1150*/                   MOV R13, c[0x0][0x180] ;
        /*1160*/                   BSSY B2, `(.L_x_155) ;
        /*1170*/                   FADD R12, R12, R7 ;
        /*1180*/                   FFMA R13, R0, -R13, 1 ;
        /*1190*/                   FFMA R0, R0, R13, R0 ;
        /*11a0*/                   FCHK P0, R6, c[0x0][0x180] ;
        /*11b0*/                   FFMA R3, R0, R6, RZ ;
        /*11c0*/                   FFMA R2, R3, -c[0x0][0x180], R6 ;
        /*11d0*/                   FFMA R0, R0, R2, R3 ;
        /*11e0*/              @!P0 BRA `(.L_x_156) ;
        /*11f0*/                   IMAD.MOV.U32 R3, RZ, RZ, R6 ;
        /*1200*/                   MOV R0, c[0x0][0x180] ;
        /*1210*/                   MOV R2, 0x1230 ;
        /*1220*/                   CALL.REL.NOINC `($__internal_4_$__cuda_sm3x_div_rn_noftz_f32_slowpath) ;
.L_x_156:
        /*1230*/                   BSYNC B2 ;
.L_x_155:
        /*1240*/                   IMAD.MOV.U32 R3, RZ, RZ, 0x3bbb989d ;
        /*1250*/                   FADD R0, R0, -R11 ;
        /*1260*/                   MOV R7, 0x437c0000 ;
        /*1270*/                   IMAD.MOV.U32 R13, RZ, RZ, c[0x0][0x17c] ;
        /*1280*/                   FFMA.SAT R2, R0, R3, 0.5 ;
        /*1290*/                   IMAD.WIDE R14, R13, 0x4, R14 ;
        /*12a0*/                   FFMA.RM R2, R2, R7, 12582913 ;
        /*12b0*/                   FADD R3, R2.reuse, -12583039 ;
        /*12c0*/                   SHF.L.U32 R2, R2, 0x17, RZ ;
        /*12d0*/                   FFMA R3, R0, 1.4426950216293334961, -R3 ;
        /*12e0*/                   FFMA R0, R0, 1.925963033500011079e-08, R3 ;
        /*12f0*/                   MUFU.EX2 R3, R0 ;
        /*1300*/                   FMUL R7, R2, R3 ;
        /*1310*/                   IMAD.WIDE R2, R13, 0x4, R18 ;
        /*1320*/                   STG.E [R14.64], R7 ;
        /*1330*/                   LDG.E R16, [R2.64] ;
        /*1340*/                   MUFU.RCP R6, c[0x0][0x180] ;
        /*1350*/                   IMAD.MOV.U32 R17, RZ, RZ, c[0x0][0x180] ;
        /*1360*/                   BSSY B2, `(.L_x_157) ;
        /*1370*/                   IMAD.WIDE R18, R13, 0x4, R2 ;
        /*1380*/                   FADD R12, R12, R7 ;
        /*1390*/                   FFMA R17, R6, -R17, 1 ;
        /*13a0*/                   FFMA R0, R6, R17, R6 ;
        /*13b0*/                   FCHK P0, R16, c[0x0][0x180] ;
        /*13c0*/                   FFMA R13, R0, R16, RZ ;
        /*13d0*/                   FFMA R6, R13, -c[0x0][0x180], R16 ;
        /*13e0*/                   FFMA R0, R0, R6, R13 ;
        /*13f0*/              @!P0 BRA `(.L_x_158) ;
        /*1400*/                   MOV R3, R16 ;
        /*1410*/                   IMAD.MOV.U32 R0, RZ, RZ, c[0x0][0x180] ;
        /*1420*/                   MOV R2, 0x1440 ;
        /*1430*/                   CALL.REL.NOINC `($__internal_4_$__cuda_sm3x_div_rn_noftz_f32_slowpath) ;
.L_x_158:
        /*1440*/                   BSYNC B2 ;
.L_x_157:
        /*1450*/                   MOV R3, 0x3bbb989d ;
        /*1460*/                   FADD R0, R0, -R11 ;
        /*1470*/                   IMAD.MOV.U32 R7, RZ, RZ, 0x437c0000 ;
        /*1480*/                   MOV R13, c[0x0][0x17c] ;
        /*1490*/                   FFMA.SAT R2, R0, R3, 0.5 ;
        /*14a0*/                   IADD3 R8, R8, -0x4, RZ ;
        /*14b0*/                   IMAD.WIDE R14, R13, 0x4, R14 ;
        /*14c0*/                   FFMA.RM R2, R2, R7, 12582913 ;
        /*14d0*/                   ISETP.NE.AND P0, PT, R8, RZ, PT ;
        /*14e0*/                   IADD3 R10, R10, 0x4, RZ ;
        /*14f0*/                   FADD R3, R2.reuse, -12583039 ;
        /*1500*/                   IMAD.SHL.U32 R2, R2, 0x800000, RZ ;
        /*1510*/                   FFMA R3, R0, 1.4426950216293334961, -R3 ;
        /*1520*/                   FFMA R0, R0, 1.925963033500011079e-08, R3 ;
        /*1530*/                   MUFU.EX2 R3, R0 ;
        /*1540*/                   FMUL R7, R2, R3 ;
        /*1550*/                   IMAD.WIDE R2, R13, 0x4, R14 ;
        /*1560*/                   FADD R12, R12, R7 ;
        /*1570*/                   STG.E [R14.64], R7 ;
        /*1580*/                   MOV R6, R2 ;
        /*1590*/                   IMAD.MOV.U32 R13, RZ, RZ, R3 ;
        /*15a0*/               @P0 BRA `(.L_x_159) ;
.L_x_150:
        /*15b0*/                   ISETP.NE.AND P0, PT, R9, RZ, PT ;
        /*15c0*/              @!P0 BRA `(.L_x_147) ;
        /*15d0*/                   IMAD R10, R10, c[0x0][0x17c], RZ ;
        /*15e0*/                   IADD3 R15, P0, R4, R10, RZ ;
        /*15f0*/                   SHF.L.U32 R14, R15.reuse, 0x2, RZ ;
        /*1600*/                   LEA.HI.X.SX32 R10, R10, R5, 0x1, P0 ;
        /*1610*/                   IADD3 R6, P0, R14.reuse, c[0x0][0x188], RZ ;
        /*1620*/                   SHF.L.U64.HI R15, R15, 0x2, R10 ;
        /*1630*/                   IADD3 R14, P1, R14, c[0x0][0x160], RZ ;
        /*1640*/                   IADD3.X R13, R15, c[0x0][0x18c], RZ, P0, !PT ;
        /*1650*/                   IADD3.X R15, R15, c[0x0][0x164], RZ, P1, !PT ;
.L_x_162:
        /*1660*/                   LDG.E R8, [R14.64] ;
        /*1670*/                   MUFU.RCP R0, c[0x0][0x180] ;
        /*1680*/                   IMAD.MOV.U32 R3, RZ, RZ, c[0x0][0x180] ;
        /*1690*/                   BSSY B2, `(.L_x_160) ;
        /*16a0*/                   MOV R18, R6 ;
        /*16b0*/                   IMAD.MOV.U32 R19, RZ, RZ, R13 ;
        /*16c0*/                   FFMA R3, R0, -R3, 1 ;
        /*16d0*/                   FFMA R0, R0, R3, R0 ;
        /*16e0*/                   FCHK P0, R8, c[0x0][0x180] ;
        /*16f0*/                   FFMA R3, R0, R8, RZ ;
        /*1700*/                   FFMA R2, R3, -c[0x0][0x180], R8 ;
        /*1710*/                   FFMA R0, R0, R2, R3 ;
        /*1720*/              @!P0 BRA `(.L_x_161) ;
        /*1730*/                   MOV R3, R8 ;
        /*1740*/                   IMAD.MOV.U32 R0, RZ, RZ, c[0x0][0x180] ;
        /*1750*/                   MOV R2, 0x1770 ;
        /*1760*/                   CALL.REL.NOINC `($__internal_4_$__cuda_sm3x_div_rn_noftz_f32_slowpath) ;
.L_x_161:
        /*1770*/                   BSYNC B2 ;
.L_x_160:
        /*1780*/                   MOV R3, 0x3bbb989d ;
        /*1790*/                   FADD R0, R0, -R11 ;
        /*17a0*/                   IMAD.MOV.U32 R7, RZ, RZ, 0x437c0000 ;
        /*17b0*/                   IADD3 R9, R9, -0x1, RZ ;
        /*17c0*/                   IMAD.MOV.U32 R13, RZ, RZ, c[0x0][0x17c] ;
        /*17d0*/                   FFMA.SAT R2, R0, R3, 0.5 ;
        /*17e0*/                   ISETP.NE.AND P0, PT, R9, RZ, PT ;
        /*17f0*/                   IMAD.WIDE R14, R13, 0x4, R14 ;
        /*1800*/                   FFMA.RM R2, R2, R7, 12582913 ;
        /*1810*/                   FADD R3, R2.reuse, -12583039 ;
        /*1820*/                   SHF.L.U32 R2, R2, 0x17, RZ ;
        /*1830*/                   FFMA R3, R0, 1.4426950216293334961, -R3 ;
        /*1840*/                   FFMA R0, R0, 1.925963033500011079e-08, R3 ;
        /*1850*/                   MUFU.EX2 R3, R0 ;
        /*1860*/                   FMUL R7, R2, R3 ;
        /*1870*/                   IMAD.WIDE R2, R13, 0x4, R18 ;
        /*1880*/                   FADD R12, R7, R12 ;
        /*1890*/                   STG.E [R18.64], R7 ;
        /*18a0*/                   MOV R6, R2 ;
        /*18b0*/                   IMAD.MOV.U32 R13, RZ, RZ, R3 ;
        /*18c0*/               @P0 BRA `(.L_x_162) ;
.L_x_147:
        /*18d0*/              @!P2 EXIT ;
        /*18e0*/                   MOV R11, c[0x0][0x168] ;
        /*18f0*/                   IMAD.MOV.U32 R10, RZ, RZ, RZ ;
        /*1900*/                   IADD3 R0, R11.reuse, -0x1, RZ ;
        /*1910*/                   LOP3.LUT R11, R11, 0x3, RZ, 0xc0, !PT ;
        /*1920*/                   ISETP.GE.U32.AND P0, PT, R0, 0x3, PT ;
        /*1930*/              @!P0 BRA `(.L_x_163) ;
        /*1940*/                   LEA R14, P0, R4.reuse, c[0x0][0x188], 0x2 ;
        /*1950*/                   IADD3 R15, -R11, c[0x0][0x168], RZ ;
        /*1960*/                   MOV R10, RZ ;
        /*1970*/                   LEA.HI.X R19, R4, c[0x0][0x18c], R5, 0x2, P0 ;
.L_x_172:
        /*1980*/                   IMAD.MOV.U32 R18, RZ, RZ, R14 ;
        /*1990*/                   LDG.E R3, [R18.64] ;
        /*19a0*/                   MUFU.RCP R7, R12 ;
        /*19b0*/                   IADD3 R15, R15, -0x4, RZ ;
        /*19c0*/                   BSSY B2, `(.L_x_164) ;
        /*19d0*/                   ISETP.NE.AND P2, PT, R15, RZ, PT ;
        /*19e0*/                   FFMA R0, R7, -R12, 1 ;
        /*19f0*/                   FFMA R0, R7, R0, R7 ;
        /*1a00*/                   FCHK P0, R3, R12 ;
        /*1a10*/                   FFMA R7, R3, R0, RZ ;
        /*1a20*/                   FFMA R2, R7, -R12, R3 ;
        /*1a30*/                   FFMA R7, R0, R2, R7 ;
        /*1a40*/              @!P0 BRA `(.L_x_165) ;
        /*1a50*/                   MOV R0, R12 ;
        /*1a60*/                   MOV R2, 0x1a80 ;
        /*1a70*/                   CALL.REL.NOINC `($__internal_4_$__cuda_sm3x_div_rn_noftz_f32_slowpath) ;
        /*1a80*/                   IMAD.MOV.U32 R7, RZ, RZ, R0 ;
.L_x_165:
        /*1a90*/                   BSYNC B2 ;
.L_x_164:
        /*1aa0*/                   MOV R9, c[0x0][0x17c] ;
        /*1ab0*/                   STG.E [R18.64], R7 ;
        /*1ac0*/                   IMAD.WIDE R8, R9, 0x4, R18 ;
        /*1ad0*/                   LDG.E R6, [R8.64] ;
        /*1ae0*/                   MUFU.RCP R3, R12 ;
        /*1af0*/                   BSSY B2, `(.L_x_166) ;
        /*1b00*/                   FFMA R0, R3, -R12, 1 ;
        /*1b10*/                   FFMA R0, R3, R0, R3 ;
        /*1b20*/                   FCHK P0, R6, R12 ;
        /*1b30*/                   FFMA R3, R0, R6, RZ ;
        /*1b40*/                   FFMA R2, R3, -R12, R6 ;
        /*1b50*/                   FFMA R3, R0, R2, R3 ;
        /*1b60*/              @!P0 BRA `(.L_x_167) ;
        /*1b70*/                   IMAD.MOV.U32 R3, RZ, RZ, R6 ;
        /*1b80*/                   MOV R0, R12 ;
        /*1b90*/                   MOV R2, 0x1bb0 ;
        /*1ba0*/                   CALL.REL.NOINC `($__internal_4_$__cuda_sm3x_div_rn_noftz_f32_slowpath) ;
        /*1bb0*/                   IMAD.MOV.U32 R3, RZ, RZ, R0 ;
.L_x_167:
        /*1bc0*/                   BSYNC B2 ;
.L_x_166:
        /*1bd0*/                   MOV R23, c[0x0][0x17c] ;
        /*1be0*/                   STG.E [R8.64], R3 ;
        /*1bf0*/                   IMAD.WIDE R22, R23, 0x4, R8 ;
        /*1c00*/                   LDG.E R6, [R22.64] ;
        /*1c10*/                   MUFU.RCP R7, R12 ;
        /*1c20*/                   BSSY B2, `(.L_x_168) ;
        /*1c30*/                   FFMA R0, R7, -R12, 1 ;
        /*1c40*/                   FFMA R0, R7, R0, R7 ;
        /*1c50*/                   FCHK P0, R6, R12 ;
        /*1c60*/                   FFMA R7, R0, R6, RZ ;
        /*1c70*/                   FFMA R2, R7, -R12, R6 ;
        /*1c80*/                   FFMA R7, R0, R2, R7 ;
        /*1c90*/              @!P0 BRA `(.L_x_169) ;
        /*1ca0*/                   IMAD.MOV.U32 R3, RZ, RZ, R6 ;
        /*1cb0*/                   MOV R0, R12 ;
        /*1cc0*/                   MOV R2, 0x1ce0 ;
        /*1cd0*/                   CALL.REL.NOINC `($__internal_4_$__cuda_sm3x_div_rn_noftz_f32_slowpath) ;
        /*1ce0*/                   IMAD.MOV.U32 R7, RZ, RZ, R0 ;
.L_x_169:
        /*1cf0*/                   BSYNC B2 ;
.L_x_168:
        /*1d00*/                   MOV R19, c[0x0][0x17c] ;
        /*1d10*/                   STG.E [R22.64], R7 ;
        /*1d20*/                   IMAD.WIDE R8, R19, 0x4, R22 ;
        /*1d30*/                   LDG.E R6, [R8.64] ;
        /*1d40*/                   MUFU.RCP R3, R12 ;
        /*1d50*/                   IMAD.WIDE R18, R19, 0x4, R8 ;
        /*1d60*/                   BSSY B2, `(.L_x_170) ;
        /*1d70*/                   IMAD.MOV.U32 R14, RZ, RZ, R18 ;
        /*1d80*/                   FFMA R0, R3, -R12, 1 ;
        /*1d90*/                   FFMA R0, R3, R0, R3 ;
        /*1da0*/                   FCHK P0, R6, R12 ;
        /*1db0*/                   FFMA R3, R0, R6, RZ ;
        /*1dc0*/                   FFMA R2, R3, -R12, R6 ;
        /*1dd0*/                   FFMA R0, R0, R2, R3 ;
        /*1de0*/              @!P0 BRA `(.L_x_171) ;
        /*1df0*/                   MOV R3, R6 ;
        /*1e00*/                   IMAD.MOV.U32 R0, RZ, RZ, R12 ;
        /*1e10*/                   MOV R2, 0x1e30 ;
        /*1e20*/                   CALL.REL.NOINC `($__internal_4_$__cuda_sm3x_div_rn_noftz_f32_slowpath) ;
.L_x_171:
        /*1e30*/                   BSYNC B2 ;
.L_x_170:
        /*1e40*/                   STG.E [R8.64], R0 ;
        /*1e50*/                   IADD3 R10, R10, 0x4, RZ ;
        /*1e60*/               @P2 BRA `(.L_x_172) ;
.L_x_163:
        /*1e70*/                   ISETP.NE.AND P0, PT, R11, RZ, PT ;
        /*1e80*/              @!P0 EXIT ;
        /*1e90*/                   IMAD R10, R10, c[0x0][0x17c], RZ ;
        /*1ea0*/                   IADD3 R3, P0, R4, R10, RZ ;
        /*1eb0*/                   LEA R2, P1, R3, c[0x0][0x188], 0x2 ;
        /*1ec0*/                   LEA.HI.X.SX32 R10, R10, R5, 0x1, P0 ;
        /*1ed0*/                   LEA.HI.X R3, R3, c[0x0][0x18c], R10, 0x2, P1 ;
.L_x_175:
        /*1ee0*/                   MOV R4, R2 ;
        /*1ef0*/                   IMAD.MOV.U32 R5, RZ, RZ, R3 ;
        /*1f00*/                   LDG.E R6, [R4.64] ;
        /*1f10*/                   MUFU.RCP R3, R12 ;
        /*1f20*/                   BSSY B2, `(.L_x_173) ;
        /*1f30*/                   FFMA R0, R3, -R12, 1 ;
        /*1f40*/                   FFMA R0, R3, R0, R3 ;
        /*1f50*/                   FCHK P0, R6, R12 ;
        /*1f60*/                   FFMA R3, R0, R6, RZ ;
        /*1f70*/                   FFMA R2, R3, -R12, R6 ;
        /*1f80*/                   FFMA R0, R0, R2, R3 ;
        /*1f90*/              @!P0 BRA `(.L_x_174) ;
        /*1fa0*/                   MOV R3, R6 ;
        /*1fb0*/                   IMAD.MOV.U32 R0, RZ, RZ, R12 ;
        /*1fc0*/                   MOV R2, 0x1fe0 ;
        /*1fd0*/                   CALL.REL.NOINC `($__internal_4_$__cuda_sm3x_div_rn_noftz_f32_slowpath) ;
.L_x_174:
        /*1fe0*/                   BSYNC B2 ;
.L_x_173:
        /*1ff0*/                   STG.E [R4.64], R0 ;
        /*2000*/                   IADD3 R11, R11, -0x1, RZ ;
        /*2010*/                   MOV R3, c[0x0][0x17c] ;
        /*2020*/                   ISETP.NE.AND P0, PT, R11, RZ, PT ;
        /*2030*/                   IMAD.WIDE R2, R3, 0x4, R4 ;
        /*2040*/               @P0 BRA `(.L_x_175) ;
        /*2050*/                   EXIT ;
        .weak           $__internal_4_$__cuda_sm3x_div_rn_noftz_f32_slowpath
        .type           $__internal_4_$__cuda_sm3x_div_rn_noftz_f32_slowpath,@function
        .size           $__internal_4_$__cuda_sm3x_div_rn_noftz_f32_slowpath,(.L_x_437 - $__internal_4_$__cuda_sm3x_div_rn_noftz_f32_slowpath)
$__internal_4_$__cuda_sm3x_div_rn_noftz_f32_slowpath:
        /*2060*/                   SHF.R.U32.HI R6, RZ, 0x17, R0 ;
        /*2070*/                   BSSY B0, `(.L_x_176) ;
        /*2080*/                   SHF.R.U32.HI R13, RZ, 0x17, R3 ;
        /*2090*/                   LOP3.LUT R6, R6, 0xff, RZ, 0xc0, !PT ;
        /*20a0*/                   LOP3.LUT R13, R13, 0xff, RZ, 0xc0, !PT ;
        /*20b0*/                   IADD3 R16, R6, -0x1, RZ ;
        /*20c0*/                   IADD3 R17, R13, -0x1, RZ ;
        /*20d0*/                   ISETP.GT.U32.AND P0, PT, R16, 0xfd, PT ;
        /*20e0*/                   ISETP.GT.U32.OR P0, PT, R17, 0xfd, P0 ;
        /*20f0*/              @!P0 IMAD.MOV.U32 R7, RZ, RZ, RZ ;
        /*2100*/              @!P0 BRA `(.L_x_177) ;
        /*2110*/                   FSETP.GTU.FTZ.AND P0, PT, |R3|, +INF , PT ;
        /*2120*/                   FSETP.GTU.FTZ.AND P1, PT, |R0|, +INF , PT ;
        /*2130*/                   PLOP3.LUT P0, PT, P0, P1, PT, 0xa8, 0x0 ;
        /*2140*/               @P0 BRA `(.L_x_178) ;
        /*2150*/                   LOP3.LUT P0, RZ, R0, 0x7fffffff, R3, 0xc8, !PT ;
        /*2160*/              @!P0 BRA `(.L_x_179) ;
        /*2170*/                   FSETP.NEU.FTZ.AND P3, PT, |R3|.reuse, +INF , PT ;
        /*2180*/                   FSETP.NEU.FTZ.AND P1, PT, |R0|, +INF , PT ;
        /*2190*/                   FSETP.NEU.FTZ.AND P0, PT, |R3|, +INF , PT ;
        /*21a0*/              @!P1 BRA !P3, `(.L_x_179) ;
        /*21b0*/                   LOP3.LUT P3, RZ, R3, 0x7fffffff, RZ, 0xc0, !PT ;
        /*21c0*/                   PLOP3.LUT P1, PT, P1, P3, PT, 0x2a, 0x0 ;
        /*21d0*/               @P1 BRA `(.L_x_180) ;
        /*21e0*/                   LOP3.LUT P1, RZ, R0, 0x7fffffff, RZ, 0xc0, !PT ;
        /*21f0*/                   PLOP3.LUT P0, PT, P0, P1, PT, 0x2a, 0x0 ;
        /*2200*/               @P0 BRA `(.L_x_181) ;
        /*2210*/                   ISETP.GE.AND P0, PT, R17, RZ, PT ;
        /*2220*/                   ISETP.GE.AND P1, PT, R16, RZ, PT ;
        /*2230*/               @P0 MOV R7, RZ ;
        /*2240*/              @!P0 IMAD.MOV.U32 R7, RZ, RZ, -0x40 ;
        /*2250*/              @!P0 FFMA R3, R3, 1.84467440737095516160e+19, RZ ;
        /*2260*/              @!P1 FFMA R0, R0, 1.84467440737095516160e+19, RZ ;
        /*2270*/              @!P1 IADD3 R7, R7, 0x40, RZ ;
.L_x_177:
        /*2280*/                   LEA R17, R6, 0xc0800000, 0x17 ;
        /*2290*/                   BSSY B1, `(.L_x_182) ;
        /*22a0*/                   IADD3 R13, R13, -0x7f, RZ ;
        /*22b0*/                   IADD3 R20, -R17, R0, RZ ;
        /*22c0*/                   IADD3 R6, R13.reuse, 0x7f, -R6 ;
        /*22d0*/                   IMAD R0, R13, -0x800000, R3 ;
        /*22e0*/                   MUFU.RCP R16, R20 ;
        /*22f0*/                   FADD.FTZ R17, -R20, -RZ ;
        /*2300*/                   IMAD.IADD R7, R6, 0x1, R7 ;
        /*2310*/                   FFMA R21, R16, R17, 1 ;
        /*2320*/                   FFMA R21, R16, R21, R16 ;
        /*2330*/                   FFMA R16, R0, R21, RZ ;
        /*2340*/                   FFMA R3, R17, R16, R0 ;
        /*2350*/                   FFMA R16, R21, R3, R16 ;
        /*2360*/                   FFMA R17, R17, R16, R0 ;
        /*2370*/                   FFMA R0, R21, R17, R16 ;
        /*2380*/                   SHF.R.U32.HI R3, RZ, 0x17, R0 ;
        /*2390*/                   LOP3.LUT R6, R3, 0xff, RZ, 0xc0, !PT ;
        /*23a0*/                   IADD3 R3, R6, R7, RZ ;
        /*23b0*/                   IADD3 R6, R3, -0x1, RZ ;
        /*23c0*/                   ISETP.GE.U32.AND P0, PT, R6, 0xfe, PT ;
        /*23d0*/              @!P0 BRA `(.L_x_183) ;
        /*23e0*/                   ISETP.GT.AND P0, PT, R3, 0xfe, PT ;
        /*23f0*/               @P0 BRA `(.L_x_184) ;
        /*2400*/                   ISETP.GE.AND P0, PT, R3, 0x1, PT ;
        /*2410*/               @P0 BRA `(.L_x_185) ;
        /*2420*/                   ISETP.GE.AND P0, PT, R3, -0x18, PT ;
        /*2430*/                   LOP3.LUT R0, R0, 0x80000000, RZ, 0xc0, !PT ;
        /*2440*/              @!P0 BRA `(.L_x_185) ;
        /*2450*/                   FFMA.RZ R6, R21, R17.reuse, R16.reuse ;
        /*2460*/                   IADD3 R13, R3, 0x20, RZ ;
        /*2470*/                   FFMA.RP R7, R21, R17.reuse, R16.reuse ;
        /*2480*/                   ISETP.NE.AND P3, PT, R3, RZ, PT ;
        /*2490*/                   FFMA.RM R16, R21, R17, R16 ;
        /*24a0*/                   LOP3.LUT R6, R6, 0x7fffff, RZ, 0xc0, !PT ;
        /*24b0*/                   ISETP.NE.AND P1, PT, R3, RZ, PT ;
        /*24c0*/                   IMAD.MOV R3, RZ, RZ, -R3 ;
        /*24d0*/                   LOP3.LUT R6, R6, 0x800000, RZ, 0xfc, !PT ;
        /*24e0*/                   FSETP.NEU.FTZ.AND P0, PT, R7, R16, PT ;
        /*24f0*/                   SHF.L.U32 R13, R6, R13, RZ ;
        /*2500*/                   SEL R3, R3, RZ, P3 ;
        /*2510*/                   ISETP.NE.AND P1, PT, R13, RZ, P1 ;
        /*2520*/                   SHF.R.U32.HI R16, RZ, R3, R6 ;
        /*2530*/                   PLOP3.LUT P0, PT, P0, P1, PT, 0xa8, 0x0 ;
        /*2540*/                   SHF.R.U32.HI R6, RZ, 0x1, R16 ;
        /*2550*/                   SEL R3, RZ, 0x1, !P0 ;
        /*2560*/                   LOP3.LUT R3, R3, 0x1, R6, 0xf8, !PT ;
        /*2570*/                   LOP3.LUT R3, R3, R16, RZ, 0xc0, !PT ;
        /*2580*/                   IADD3 R3, R6, R3, RZ ;
        /*2590*/                   LOP3.LUT R0, R3, R0, RZ, 0xfc, !PT ;
        /*25a0*/                   BRA `(.L_x_185) ;
.L_x_184:
        /*25b0*/                   LOP3.LUT R0, R0, 0x80000000, RZ, 0xc0, !PT ;
        /*25c0*/                   LOP3.LUT R0, R0, 0x7f800000, RZ, 0xfc, !PT ;
        /*25d0*/                   BRA `(.L_x_185) ;
.L_x_183:
        /*25e0*/                   IMAD R0, R7, 0x800000, R0 ;
.L_x_185:
        /*25f0*/                   BSYNC B1 ;
.L_x_182:
        /*2600*/                   BRA `(.L_x_186) ;
.L_x_181:
        /*2610*/                   LOP3.LUT R0, R0, 0x80000000, R3, 0x48, !PT ;
        /*2620*/                   LOP3.LUT R0, R0, 0x7f800000, RZ, 0xfc, !PT ;
        /*2630*/                   BRA `(.L_x_186) ;
.L_x_180:
        /*2640*/                   LOP3.LUT R0, R0, 0x80000000, R3, 0x48, !PT ;
        /*2650*/                   BRA `(.L_x_186) ;
.L_x_179:
        /*2660*/                   MUFU.RSQ R0, -QNAN  ;
        /*2670*/                   BRA `(.L_x_186) ;
.L_x_178:
        /*2680*/                   FADD.FTZ R0, R3, R0 ;
.L_x_186:
        /*2690*/                   BSYNC B0 ;
.L_x_176:
        /*26a0*/                   MOV R3, 0x0 ;
        /*26b0*/                   RET.REL.NODEC R2 `(softmax_kernel) ;
.L_x_187:
        /*26c0*/                   BRA `(.L_x_187);
        /*26d0*/                   NOP;
        /*26e0*/                   NOP;
        /*26f0*/                   NOP;
        /*2700*/                   NOP;
        /*2710*/                   NOP;
        /*2720*/                   NOP;
        /*2730*/                   NOP;
        /*2740*/                   NOP;
        /*2750*/                   NOP;
        /*2760*/                   NOP;
        /*2770*/                   NOP;
.L_x_437:


//--------------------- .text.normalize_delta_kernel --------------------------
	.section	.text.normalize_delta_kernel,"ax",@progbits
	.sectioninfo	@"SHI_REGISTERS=21"
	.align	128
        .global         normalize_delta_kernel
        .type           normalize_delta_kernel,@function
        .size           normalize_delta_kernel,(.L_x_439 - normalize_delta_kernel)
        .other          normalize_delta_kernel,@"STO_CUDA_ENTRY STV_DEFAULT"
normalize_delta_kernel:
.text.normalize_delta_kernel:
        /*0000*/                   IMAD.MOV.U32 R1, RZ, RZ, c[0x0][0x28] ;
        /*0010*/                   S2R R2, SR_CTAID.X ;
        /*0020*/                   S2R R3, SR_TID.X ;
        /*0030*/                   IMAD R2, R2, c[0x0][0x0], R3 ;
        /*0040*/                   ISETP.GE.AND P0, PT, R2, c[0x0][0x160], PT ;
        /*0050*/               @P0 EXIT ;
        /*0060*/                   IABS R8, c[0x0][0x198] ;
        /*0070*/                   ULDC.64 UR6, c[0x0][0x118] ;
        /*0080*/                   IABS R6, R2 ;
        /*0090*/                   I2F.RP R0, R8 ;
        /*00a0*/                   IABS R7, c[0x0][0x194] ;
        /*00b0*/                   MUFU.RCP R0, R0 ;
        /*00c0*/                   IADD3 R4, R0, 0xffffffe, RZ ;
        /*00d0*/                   F2I.FTZ.U32.TRUNC.NTZ R5, R4 ;
        /*00e0*/                   IMAD.MOV.U32 R4, RZ, RZ, RZ ;
        /*00f0*/                   IMAD.MOV R3, RZ, RZ, -R5 ;
        /*0100*/                   IMAD R3, R3, R8, RZ ;
        /*0110*/                   IMAD.HI.U32 R5, R5, R3, R4 ;
        /*0120*/                   IMAD.MOV.U32 R3, RZ, RZ, R6 ;
        /*0130*/                   I2F.RP R6, R7 ;
        /*0140*/                   IMAD.HI.U32 R0, R5, R3, RZ ;
        /*0150*/                   IADD3 R4, -R0, RZ, RZ ;
        /*0160*/                   IMAD R3, R8.reuse, R4, R3 ;
        /*0170*/                   MUFU.RCP R6, R6 ;
        /*0180*/                   ISETP.GT.U32.AND P2, PT, R8, R3, PT ;
        /*0190*/              @!P2 IMAD.IADD R3, R3, 0x1, -R8 ;
        /*01a0*/              @!P2 IADD3 R0, R0, 0x1, RZ ;
        /*01b0*/                   IADD3 R4, R6, 0xffffffe, RZ ;
        /*01c0*/                   ISETP.GE.U32.AND P0, PT, R3, R8, PT ;
        /*01d0*/                   F2I.FTZ.U32.TRUNC.NTZ R5, R4 ;
        /*01e0*/                   LOP3.LUT R3, R2, c[0x0][0x198], RZ, 0x3c, !PT ;
        /*01f0*/                   ISETP.NE.AND P2, PT, RZ, c[0x0][0x198], PT ;
        /*0200*/                   ISETP.GE.AND P1, PT, R3, RZ, PT ;
        /*0210*/                   MOV R4, RZ ;
        /*0220*/               @P0 IADD3 R0, R0, 0x1, RZ ;
        /*0230*/                   IMAD.MOV R6, RZ, RZ, -R5 ;
        /*0240*/              @!P1 IMAD.MOV R0, RZ, RZ, -R0 ;
        /*0250*/              @!P2 LOP3.LUT R0, RZ, c[0x0][0x198], RZ, 0x33, !PT ;
        /*0260*/                   IMAD R3, R6, R7, RZ ;
        /*0270*/                   IABS R6, R0 ;
        /*0280*/                   IMAD.HI.U32 R4, R5, R3, R4 ;
        /*0290*/                   ISETP.GE.AND P2, PT, R0, RZ, PT ;
        /*02a0*/                   IMAD.MOV.U32 R5, RZ, RZ, 0x4 ;
        /*02b0*/                   IMAD.HI.U32 R4, R4, R6, RZ ;
        /*02c0*/                   IMAD.MOV R4, RZ, RZ, -R4 ;
        /*02d0*/                   IMAD R6, R7, R4, R6 ;
        /*02e0*/                   ISETP.GT.U32.AND P0, PT, R7, R6, PT ;
        /*02f0*/              @!P0 IMAD.IADD R6, R6, 0x1, -R7 ;
        /*0300*/                   ISETP.NE.AND P0, PT, RZ, c[0x0][0x194], PT ;
        /*0310*/                   ISETP.GT.U32.AND P1, PT, R7, R6, PT ;
        /*0320*/              @!P1 IMAD.IADD R6, R6, 0x1, -R7 ;
        /*0330*/              @!P2 IADD3 R6, -R6, RZ, RZ ;
        /*0340*/              @!P0 LOP3.LUT R6, RZ, c[0x0][0x194], RZ, 0x33, !PT ;
        /*0350*/                   IMAD.WIDE R8, R6, R5, c[0x0][0x178] ;
        /*0360*/                   LDG.E R8, [R8.64] ;
        /*0370*/                   BSSY B0, `(.L_x_188) ;
        /*0380*/                   IMAD.WIDE R4, R2, R5, c[0x0][0x1a0] ;
        /*0390*/                   FADD R10, R8, 9.9999997473787516356e-06 ;
        /*03a0*/                   MUFU.RSQ R7, R10 ;
        /*03b0*/                   IADD3 R0, R10, -0xd000000, RZ ;
        /*03c0*/                   ISETP.GT.U32.AND P0, PT, R0, 0x727fffff, PT ;
        /*03d0*/              @!P0 BRA `(.L_x_189) ;
        /*03e0*/                   MOV R11, 0x400 ;
        /*03f0*/                   CALL.REL.NOINC `($__internal_5_$__cuda_sm20_sqrt_rn_f32_slowpath) ;
        /*0400*/                   BRA `(.L_x_190) ;
.L_x_189:
        /*0410*/                   FMUL.FTZ R3, R10, R7 ;
        /*0420*/                   FMUL.FTZ R7, R7, 0.5 ;
        /*0430*/                   FFMA R0, -R3, R3, R10 ;
        /*0440*/                   FFMA R3, R0, R7, R3 ;
.L_x_190:
        /*0450*/                   BSYNC B0 ;
.L_x_188:
        /*0460*/                   LDG.E R0, [R4.64] ;
        /*0470*/                   MUFU.RCP R8, R3 ;
        /*0480*/                   BSSY B0, `(.L_x_191) ;
        /*0490*/                   FFMA R7, R8, -R3, 1 ;
        /*04a0*/                   FFMA R7, R8, R7, R8 ;
        /*04b0*/                   FCHK P0, R0, R3 ;
        /*04c0*/                   FFMA R8, R0, R7, RZ ;
        /*04d0*/                   FFMA R9, R8, -R3, R0 ;
        /*04e0*/                   FFMA R7, R7, R9, R8 ;
        /*04f0*/              @!P0 BRA `(.L_x_192) ;
        /*0500*/                   MOV R8, 0x520 ;
        /*0510*/                   CALL.REL.NOINC `($__internal_6_$__cuda_sm3x_div_rn_noftz_f32_slowpath) ;
        /*0520*/                   IMAD.MOV.U32 R7, RZ, RZ, R11 ;
.L_x_192:
        /*0530*/                   BSYNC B0 ;
.L_x_191:
        /*0540*/                   IMAD.MOV.U32 R9, RZ, RZ, 0x4 ;
        /*0550*/                   IMAD.WIDE R10, R2, R9, c[0x0][0x168] ;
        /*0560*/                   IMAD.WIDE R12, R6.reuse, R9.reuse, c[0x0][0x170] ;
        /*0570*/                   LDG.E R11, [R10.64] ;
        /*0580*/                   IMAD.WIDE R8, R6, R9, c[0x0][0x188] ;
        /*0590*/                   LDG.E R12, [R12.64] ;
        /*05a0*/                   LDG.E R8, [R8.64] ;
        /*05b0*/                   ULDC UR4, c[0x0][0x198] ;
        /*05c0*/                   ULDC UR5, c[0x0][0x190] ;
        /*05d0*/                   UIMAD UR4, UR4, UR5, URZ ;
        /*05e0*/                   I2FP.F32.S32 R3, UR4 ;
        /*05f0*/                   MUFU.RCP R2, R3 ;
        /*0600*/                   BSSY B0, `(.L_x_193) ;
        /*0610*/                   FFMA R17, -R3, R2, 1 ;
        /*0620*/                   FFMA R17, R2, R17, R2 ;
        /*0630*/                   FADD R15, -R12, R11 ;
        /*0640*/                   FADD R0, R8, R8 ;
        /*0650*/                   FMUL R0, R0, R15 ;
        /*0660*/                   FCHK P0, R0, R3 ;
        /*0670*/                   FFMA R2, R0, R17, RZ ;
        /*0680*/                   FFMA R8, -R3, R2, R0 ;
        /*0690*/                   FFMA R2, R17, R8, R2 ;
        /*06a0*/              @!P0 BRA `(.L_x_194) ;
        /*06b0*/                   MOV R8, 0x6d0 ;
        /*06c0*/                   CALL.REL.NOINC `($__internal_6_$__cuda_sm3x_div_rn_noftz_f32_slowpath) ;
        /*06d0*/                   MOV R2, R11 ;
.L_x_194:
        /*06e0*/                   BSYNC B0 ;
.L_x_193:
        /*06f0*/                   IMAD.MOV.U32 R9, RZ, RZ, 0x4 ;
        /*0700*/                   IMAD.WIDE R8, R6, R9, c[0x0][0x180] ;
        /*0710*/                   LDG.E R8, [R8.64] ;
        /*0720*/                   MUFU.RCP R0, R3 ;
        /*0730*/                   BSSY B0, `(.L_x_195) ;
        /*0740*/                   FADD R7, R2, R7 ;
        /*0750*/                   FFMA R11, -R3, R0, 1 ;
        /*0760*/                   FFMA R0, R0, R11, R0 ;
        /*0770*/                   FCHK P0, R8, R3 ;
        /*0780*/                   FFMA R6, R0, R8, RZ ;
        /*0790*/                   FFMA R11, -R3, R6, R8 ;
        /*07a0*/                   FFMA R0, R0, R11, R6 ;
        /*07b0*/              @!P0 BRA `(.L_x_196) ;
        /*07c0*/                   IMAD.MOV.U32 R0, RZ, RZ, R8 ;
        /*07d0*/                   MOV R8, 0x7f0 ;
        /*07e0*/                   CALL.REL.NOINC `($__internal_6_$__cuda_sm3x_div_rn_noftz_f32_slowpath) ;
        /*07f0*/                   IMAD.MOV.U32 R0, RZ, RZ, R11 ;
.L_x_196:
        /*0800*/                   BSYNC B0 ;
.L_x_195:
        /*0810*/                   FADD R7, R7, R0 ;
        /*0820*/                   STG.E [R4.64], R7 ;
        /*0830*/                   EXIT ;
        .weak           $__internal_5_$__cuda_sm20_sqrt_rn_f32_slowpath
        .type           $__internal_5_$__cuda_sm20_sqrt_rn_f32_slowpath,@function
        .size           $__internal_5_$__cuda_sm20_sqrt_rn_f32_slowpath,($__internal_6_$__cuda_sm3x_div_rn_noftz_f32_slowpath - $__internal_5_$__cuda_sm20_sqrt_rn_f32_slowpath)
$__internal_5_$__cuda_sm20_sqrt_rn_f32_slowpath:
        /*0840*/                   LOP3.LUT P0, RZ, R10, 0x7fffffff, RZ, 0xc0, !PT ;
        /*0850*/              @!P0 MOV R3, R10 ;
        /*0860*/              @!P0 BRA `(.L_x_197) ;
        /*0870*/                   FSETP.GEU.FTZ.AND P0, PT, R10, RZ, PT ;
        /*0880*/                   IMAD.MOV.U32 R0, RZ, RZ, R10 ;
        /*0890*/              @!P0 IMAD.MOV.U32 R3, RZ, RZ, 0x7fffffff ;
        /*08a0*/              @!P0 BRA `(.L_x_197) ;
        /*08b0*/                   FSETP.GTU.FTZ.AND P0, PT, |R0|, +INF , PT ;
        /*08c0*/               @P0 FADD.FTZ R3, R0, 1 ;
        /*08d0*/               @P0 BRA `(.L_x_197) ;
        /*08e0*/                   FSETP.NEU.FTZ.AND P0, PT, |R0|, +INF , PT ;
        /*08f0*/               @P0 FFMA R7, R0, 1.84467440737095516160e+19, RZ ;
        /*0900*/               @P0 MUFU.RSQ R8, R7 ;
        /*0910*/               @P0 FMUL.FTZ R10, R7, R8 ;
        /*0920*/               @P0 FMUL.FTZ R8, R8, 0.5 ;
        /*0930*/               @P0 FADD.FTZ R3, -R10, -RZ ;
        /*0940*/               @P0 FFMA R9, R10, R3, R7 ;
        /*0950*/              @!P0 IMAD.MOV.U32 R3, RZ, RZ, R0 ;
        /*0960*/               @P0 FFMA R8, R9, R8, R10 ;
        /*0970*/               @P0 FMUL.FTZ R3, R8, 2.3283064365386962891e-10 ;
.L_x_197:
        /*0980*/                   MOV R8, R11 ;
        /*0990*/                   IMAD.MOV.U32 R9, RZ, RZ, 0x0 ;
        /*09a0*/                   RET.REL.NODEC R8 `(normalize_delta_kernel) ;
        .weak           $__internal_6_$__cuda_sm3x_div_rn_noftz_f32_slowpath
        .type           $__internal_6_$__cuda_sm3x_div_rn_noftz_f32_slowpath,@function
        .size           $__internal_6_$__cuda_sm3x_div_rn_noftz_f32_slowpath,(.L_x_439 - $__internal_6_$__cuda_sm3x_div_rn_noftz_f32_slowpath)
$__internal_6_$__cuda_sm3x_div_rn_noftz_f32_slowpath:
        /*09b0*/                   SHF.R.U32.HI R10, RZ, 0x17, R3.reuse ;
        /*09c0*/                   BSSY B1, `(.L_x_198) ;
        /*09d0*/                   SHF.R.U32.HI R9, RZ, 0x17, R0 ;
        /*09e0*/                   LOP3.LUT R16, R10, 0xff, RZ, 0xc0, !PT ;
        /*09f0*/                   LOP3.LUT R14, R9, 0xff, RZ, 0xc0, !PT ;
        /*0a00*/                   IMAD.MOV.U32 R9, RZ, RZ, R3 ;
        /*0a10*/                   IADD3 R12, R16, -0x1, RZ ;
        /*0a20*/                   IADD3 R11, R14, -0x1, RZ ;
        /*0a30*/                   ISETP.GT.U32.AND P0, PT, R12, 0xfd, PT ;
        /*0a40*/                   ISETP.GT.U32.OR P0, PT, R11, 0xfd, P0 ;
        /*0a50*/              @!P0 IMAD.MOV.U32 R10, RZ, RZ, RZ ;
        /*0a60*/              @!P0 BRA `(.L_x_199) ;
        /*0a70*/                   FSETP.GTU.FTZ.AND P0, PT, |R0|, +INF , PT ;
        /*0a80*/                   FSETP.GTU.FTZ.AND P1, PT, |R3|, +INF , PT ;
        /*0a90*/                   PLOP3.LUT P0, PT, P0, P1, PT, 0xa8, 0x0 ;
        /*0aa0*/               @P0 BRA `(.L_x_200) ;
        /*0ab0*/                   LOP3.LUT P0, RZ, R9, 0x7fffffff, R0, 0xc8, !PT ;
        /*0ac0*/              @!P0 BRA `(.L_x_201) ;
        /*0ad0*/                   FSETP.NEU.FTZ.AND P2, PT, |R0|.reuse, +INF , PT ;
        /*0ae0*/                   FSETP.NEU.FTZ.AND P1, PT, |R3|, +INF , PT ;
        /*0af0*/                   FSETP.NEU.FTZ.AND P0, PT, |R0|, +INF , PT ;
        /*0b00*/              @!P1 BRA !P2, `(.L_x_201) ;
        /*0b10*/                   LOP3.LUT P2, RZ, R0, 0x7fffffff, RZ, 0xc0, !PT ;
        /*0b20*/                   PLOP3.LUT P1, PT, P1, P2, PT, 0x2a, 0x0 ;
        /*0b30*/               @P1 BRA `(.L_x_202) ;
        /*0b40*/                   LOP3.LUT P1, RZ, R9, 0x7fffffff, RZ, 0xc0, !PT ;
        /*0b50*/                   PLOP3.LUT P0, PT, P0, P1, PT, 0x2a, 0x0 ;
        /*0b60*/               @P0 BRA `(.L_x_203) ;
        /*0b70*/                   ISETP.GE.AND P0, PT, R11, RZ, PT ;
        /*0b80*/                   ISETP.GE.AND P1, PT, R12, RZ, PT ;
        /*0b90*/               @P0 MOV R10, RZ ;
        /*0ba0*/              @!P0 IMAD.MOV.U32 R10, RZ, RZ, -0x40 ;
        /*0bb0*/              @!P0 FFMA R0, R0, 1.84467440737095516160e+19, RZ ;
        /*0bc0*/              @!P1 FFMA R9, R3, 1.84467440737095516160e+19, RZ ;
        /*0bd0*/              @!P1 IADD3 R10, R10, 0x40, RZ ;
.L_x_199:
        /*0be0*/                   LEA R12, R16, 0xc0800000, 0x17 ;
        /*0bf0*/                   BSSY B2, `(.L_x_204) ;
        /*0c00*/                   IMAD.IADD R12, R9, 0x1, -R12 ;
        /*0c10*/                   IADD3 R9, R14, -0x7f, RZ ;
        /*0c20*/                   MUFU.RCP R11, R12 ;
        /*0c30*/                   FADD.FTZ R13, -R12, -RZ ;
        /*0c40*/                   IMAD R0, R9.reuse, -0x800000, R0 ;
        /*0c50*/                   IADD3 R9, R9, 0x7f, -R16 ;
        /*0c60*/                   IMAD.IADD R9, R9, 0x1, R10 ;
        /*0c70*/                   FFMA R14, R11, R13, 1 ;
        /*0c80*/                   FFMA R18, R11, R14, R11 ;
        /*0c90*/                   FFMA R11, R0, R18, RZ ;
        /*0ca0*/                   FFMA R14, R13, R11, R0 ;
        /*0cb0*/                   FFMA R15, R18, R14, R11 ;
        /*0cc0*/                   FFMA R14, R13, R15, R0 ;
        /*0cd0*/                   FFMA R11, R18, R14, R15 ;
        /*0ce0*/                   SHF.R.U32.HI R0, RZ, 0x17, R11 ;
        /*0cf0*/                   LOP3.LUT R0, R0, 0xff, RZ, 0xc0, !PT ;
        /*0d00*/                   IADD3 R12, R0, R9, RZ ;
        /*0d10*/                   IADD3 R0, R12, -0x1, RZ ;
        /*0d20*/                   ISETP.GE.U32.AND P0, PT, R0, 0xfe, PT ;
        /*0d30*/              @!P0 BRA `(.L_x_205) ;
        /*0d40*/                   ISETP.GT.AND P0, PT, R12, 0xfe, PT ;
        /*0d50*/               @P0 BRA `(.L_x_206) ;
        /*0d60*/                   ISETP.GE.AND P0, PT, R12, 0x1, PT ;
        /*0d70*/               @P0 BRA `(.L_x_207) ;
        /*0d80*/                   ISETP.GE.AND P0, PT, R12, -0x18, PT ;
        /*0d90*/                   LOP3.LUT R11, R11, 0x80000000, RZ, 0xc0, !PT ;
        /*0da0*/              @!P0 BRA `(.L_x_207) ;
        /*0db0*/                   FFMA.RZ R0, R18, R14.reuse, R15.reuse ;
        /*0dc0*/                   IADD3 R13, R12, 0x20, RZ ;
        /*0dd0*/                   FFMA.RM R9, R18, R14.reuse, R15.reuse ;
        /*0de0*/                   ISETP.NE.AND P2, PT, R12, RZ, PT ;
        /*0df0*/                   LOP3.LUT R10, R0, 0x7fffff, RZ, 0xc0, !PT ;
        /*0e00*/                   FFMA.RP R0, R18, R14, R15 ;
        /*0e10*/                   ISETP.NE.AND P1, PT, R12, RZ, PT ;
        /*0e20*/                   IMAD.MOV R12, RZ, RZ, -R12 ;
        /*0e30*/                   LOP3.LUT R10, R10, 0x800000, RZ, 0xfc, !PT ;
        /*0e40*/                   FSETP.NEU.FTZ.AND P0, PT, R0, R9, PT ;
        /*0e50*/                   SHF.L.U32 R13, R10, R13, RZ ;
        /*0e60*/                   SEL R9, R12, RZ, P2 ;
        /*0e70*/                   ISETP.NE.AND P1, PT, R13, RZ, P1 ;
        /*0e80*/                   SHF.R.U32.HI R9, RZ, R9, R10 ;
        /*0e90*/                   PLOP3.LUT P0, PT, P0, P1, PT, 0xa8, 0x0 ;
        /*0ea0*/                   SHF.R.U32.HI R13, RZ, 0x1, R9 ;
        /*0eb0*/                   SEL R0, RZ, 0x1, !P0 ;
        /*0ec0*/                   LOP3.LUT R0, R0, 0x1, R13, 0xf8, !PT ;
        /*0ed0*/                   LOP3.LUT R0, R0, R9, RZ, 0xc0, !PT ;
        /*0ee0*/                   IMAD.IADD R0, R13, 0x1, R0 ;
        /*0ef0*/                   LOP3.LUT R11, R0, R11, RZ, 0xfc, !PT ;
        /*0f00*/                   BRA `(.L_x_207) ;
.L_x_206:
        /*0f10*/                   LOP3.LUT R11, R11, 0x80000000, RZ, 0xc0, !PT ;
        /*0f20*/                   LOP3.LUT R11, R11, 0x7f800000, RZ, 0xfc, !PT ;
        /*0f30*/                   BRA `(.L_x_207) ;
.L_x_205:
        /*0f40*/                   LEA R11, R9, R11, 0x17 ;
.L_x_207:
        /*0f50*/                   BSYNC B2 ;
.L_x_204:
        /*0f60*/                   BRA `(.L_x_208) ;
.L_x_203:
        /*0f70*/                   LOP3.LUT R0, R9, 0x80000000, R0, 0x48, !PT ;
        /*0f80*/                   LOP3.LUT R11, R0, 0x7f800000, RZ, 0xfc, !PT ;
        /*0f90*/                   BRA `(.L_x_208) ;
.L_x_202:
        /*0fa0*/                   LOP3.LUT R11, R9, 0x80000000, R0, 0x48, !PT ;
        /*0fb0*/                   BRA `(.L_x_208) ;
.L_x_201:
        /*0fc0*/                   MUFU.RSQ R11, -QNAN  ;
        /*0fd0*/                   BRA `(.L_x_208) ;
.L_x_200:
        /*0fe0*/                   FADD.FTZ R11, R0, R3 ;
.L_x_208:
        /*0ff0*/                   BSYNC B1 ;
.L_x_198:
        /*1000*/                   IMAD.MOV.U32 R9, RZ, RZ, 0x0 ;
        /*1010*/                   RET.REL.NODEC R8 `(normalize_delta_kernel) ;
.L_x_209:
        /*1020*/                   BRA `(.L_x_209);
        /*1030*/                   NOP;
        /*1040*/                   NOP;
        /*1050*/                   NOP;
        /*1060*/                   NOP;
        /*1070*/                   NOP;
        /*1080*/                   NOP;
        /*1090*/                   NOP;
        /*10a0*/                   NOP;
        /*10b0*/                   NOP;
        /*10c0*/                   NOP;
        /*10d0*/                   NOP;
        /*10e0*/                   NOP;
        /*10f0*/                   NOP;
.L_x_439:


//--------------------- .text.fast_variance_delta_kernel --------------------------
	.section	.text.fast_variance_delta_kernel,"ax",@progbits
	.sectionflags	@"SHF_BARRIERS=1"
	.sectioninfo	@"SHI_REGISTERS=40"
	.align	128
        .global         fast_variance_delta_kernel
        .type           fast_variance_delta_kernel,@function
        .size           fast_variance_delta_kernel,(.L_x_464 - fast_variance_delta_kernel)
        .other          fast_variance_delta_kernel,@"STO_CUDA_ENTRY STV_DEFAULT"
fast_variance_delta_kernel:
.text.fast_variance_delta_kernel:
        /*0000*/                   MOV R1, c[0x0][0x28] ;
        /*0010*/                   S2R R0, SR_CTAID.X ;
        /*0020*/                   ISETP.LT.AND P0, PT, RZ, c[0x0][0x180], PT ;
        /*0030*/                   ULDC.64 UR4, c[0x0][0x118] ;
        /*0040*/              @!P0 MOV R21, RZ ;
        /*0050*/                   SHF.R.S32.HI R7, RZ, 0x1f, R0 ;
        /*0060*/              @!P0 BRA `(.L_x_210) ;
        /*0070*/                   MOV R3, 0x4 ;
        /*0080*/                   IMAD.WIDE R2, R0, R3, c[0x0][0x170] ;
        /*0090*/                   LDG.E R6, [R2.64] ;
        /*00a0*/                   MOV R21, RZ ;
        /*00b0*/                   MOV R11, RZ ;
        /*00c0*/                   S2R R8, SR_TID.X ;
        /*00d0*/                   LOP3.LUT R10, RZ, R8, RZ, 0x33, !PT ;
        /*00e0*/                   IADD3 R12, R8, 0x100, RZ ;
        /*00f0*/                   IADD3 R10, R10, c[0x0][0x188], RZ ;
        /*0100*/                   IADD3 R13, R8, 0x200, RZ ;
        /*0110*/                   LEA.HI R15, R10, 0x1, RZ, 0x18 ;
        /*0120*/                   IADD3 R14, R8, 0x300, RZ ;
        /*0130*/                   LOP3.LUT R15, R15, 0x3, RZ, 0xc0, !PT ;
.L_x_220:
        /*0140*/                   ISETP.GE.AND P0, PT, R8, c[0x0][0x188], PT ;
        /*0150*/                   BSSY B0, `(.L_x_211) ;
        /*0160*/               @P0 BRA `(.L_x_212) ;
        /*0170*/                   ISETP.NE.AND P0, PT, R15, RZ, PT ;
        /*0180*/                   BSSY B1, `(.L_x_213) ;
        /*0190*/                   ISETP.GE.U32.AND P1, PT, R10, 0x300, PT ;
        /*01a0*/                   IMAD R23, R11, c[0x0][0x184], R0 ;
        /*01b0*/                   MOV R20, R8 ;
        /*01c0*/              @!P0 BRA `(.L_x_214) ;
        /*01d0*/                   MOV R5, 0x4 ;
        /*01e0*/                   IMAD R4, R23, c[0x0][0x188], R8 ;
        /*01f0*/                   IMAD.WIDE R2, R4, R5, c[0x0][0x160] ;
        /*0200*/                   IMAD.WIDE R4, R4, R5, c[0x0][0x168] ;
        /*0210*/                   LDG.E R9, [R2.64] ;
        /*0220*/                   LDG.E R17, [R4.64] ;
        /*0230*/                   ISETP.NE.AND P0, PT, R15, 0x1, PT ;
        /*0240*/                   MOV R20, R12 ;
        /*0250*/                   FADD R16, -R6, R9 ;
        /*0260*/                   FFMA R21, R16, R17, R21 ;
        /*0270*/              @!P0 BRA `(.L_x_214) ;
        /*0280*/                   ISETP.NE.AND P0, PT, R15, 0x2, PT ;
        /*0290*/                   LDG.E R9, [R2.64+0x400] ;
        /*02a0*/                   LDG.E R17, [R4.64+0x400] ;
        /*02b0*/               @P0 LDG.E R19, [R2.64+0x800] ;
        /*02c0*/               @P0 LDG.E R18, [R4.64+0x800] ;
        /*02d0*/                   MOV R20, R13 ;
        /*02e0*/               @P0 MOV R20, R14 ;
        /*02f0*/                   FADD R16, -R6, R9 ;
        /*0300*/                   FFMA R21, R16, R17, R21 ;
        /*0310*/               @P0 FADD R16, -R6, R19 ;
        /*0320*/               @P0 FFMA R21, R16, R18, R21 ;
.L_x_214:
        /*0330*/                   BSYNC B1 ;
.L_x_213:
        /*0340*/              @!P1 BRA `(.L_x_212) ;
        /*0350*/                   IADD3 R2, -R20, c[0x0][0x188], RZ ;
        /*0360*/                   BSSY B1, `(.L_x_215) ;
        /*0370*/                   IMAD R17, R23, c[0x0][0x188], R20 ;
        /*0380*/                   PLOP3.LUT P0, PT, PT, PT, PT, 0x80, 0x0 ;
        /*0390*/                   ISETP.GT.AND P1, PT, R2, 0xc00, PT ;
        /*03a0*/                   MOV R16, c[0x0][0x168] ;
        /*03b0*/                   MOV R19, c[0x0][0x16c] ;
        /*03c0*/                   MOV R18, c[0x0][0x160] ;
        /*03d0*/                   MOV R9, c[0x0][0x164] ;
        /*03e0*/              @!P1 BRA `(.L_x_216) ;
        /*03f0*/                   MOV R23, c[0x0][0x188] ;
        /*0400*/                   PLOP3.LUT P0, PT, PT, PT, PT, 0x8, 0x0 ;
        /*0410*/                   IADD3 R23, R23, -0xc00, RZ ;
.L_x_217:
        /*0420*/                   MOV R2, R18 ;
        /*0430*/                   MOV R3, R9 ;
        /*0440*/                   MOV R4, R16 ;
        /*0450*/                   MOV R5, R19 ;
        /*0460*/                   IMAD.WIDE R2, R17, 0x4, R2 ;
        /*0470*/                   IMAD.WIDE R4, R17, 0x4, R4 ;
        /*0480*/                   LDG.E R29, [R2.64] ;
        /*0490*/                   LDG.E R28, [R4.64] ;
        /*04a0*/                   LDG.E R31, [R2.64+0x400] ;
        /*04b0*/                   LDG.E R30, [R4.64+0x400] ;
        /*04c0*/                   LDG.E R25, [R2.64+0x800] ;
        /*04d0*/                   LDG.E R22, [R4.64+0x800] ;
        /*04e0*/                   LDG.E R27, [R2.64+0xc00] ;
        /*04f0*/                   LDG.E R24, [R4.64+0xc00] ;
        /*0500*/                   LDG.E R33, [R2.64+0x1800] ;
        /*0510*/                   LDG.E R35, [R2.64+0x1c00] ;
        /*0520*/                   FADD R26, -R6, R29 ;
        /*0530*/                   LDG.E R29, [R2.64+0x1000] ;
        /*0540*/                   FFMA R28, R26, R28, R21 ;
        /*0550*/                   LDG.E R26, [R4.64+0x1000] ;
        /*0560*/                   FADD R21, -R6, R31 ;
        /*0570*/                   LDG.E R31, [R2.64+0x1400] ;
        /*0580*/                   FFMA R21, R21, R30, R28 ;
        /*0590*/                   LDG.E R28, [R4.64+0x1400] ;
        /*05a0*/                   FADD R30, -R6, R25 ;
        /*05b0*/                   LDG.E R25, [R2.64+0x2000] ;
        /*05c0*/                   FFMA R37, R30, R22, R21 ;
        /*05d0*/                   LDG.E R30, [R4.64+0x1800] ;
        /*05e0*/                   LDG.E R21, [R4.64+0x1c00] ;
        /*05f0*/                   LDG.E R22, [R4.64+0x2000] ;
        /*0600*/                   FADD R32, -R6, R27 ;
        /*0610*/                   LDG.E R27, [R2.64+0x2400] ;
        /*0620*/                   FFMA R37, R32, R24, R37 ;
        /*0630*/                   FADD R35, -R6.reuse, R35 ;
        /*0640*/                   LDG.E R32, [R4.64+0x3c00] ;
        /*0650*/                   FADD R24, -R6, R29 ;
        /*0660*/                   LDG.E R29, [R2.64+0x2800] ;
        /*0670*/                   FFMA R37, R24, R26, R37 ;
        /*0680*/                   FADD R24, -R6.reuse, R31 ;
        /*0690*/                   FADD R26, -R6, R33 ;
        /*06a0*/                   LDG.E R31, [R2.64+0x2c00] ;
        /*06b0*/                   FFMA R37, R24, R28, R37 ;
        /*06c0*/                   LDG.E R24, [R4.64+0x2400] ;
        /*06d0*/                   LDG.E R33, [R2.64+0x3800] ;
        /*06e0*/                   FFMA R30, R26, R30, R37 ;
        /*06f0*/                   LDG.E R26, [R4.64+0x2800] ;
        /*0700*/                   FADD R28, -R6, R25 ;
        /*0710*/                   FFMA R35, R35, R21, R30 ;
        /*0720*/                   LDG.E R21, [R4.64+0x2c00] ;
        /*0730*/                   LDG.E R25, [R2.64+0x3000] ;
        /*0740*/                   FFMA R34, R28, R22, R35 ;
        /*0750*/                   LDG.E R30, [R4.64+0x3000] ;
        /*0760*/                   LDG.E R35, [R2.64+0x3400] ;
        /*0770*/                   LDG.E R28, [R4.64+0x3400] ;
        /*0780*/                   LDG.E R22, [R4.64+0x3800] ;
        /*0790*/                   LDG.E R37, [R2.64+0x3c00] ;
        /*07a0*/                   FADD R27, -R6, R27 ;
        /*07b0*/                   IADD3 R20, R20, 0x1000, RZ ;
        /*07c0*/                   ISETP.GE.AND P1, PT, R20, R23, PT ;
        /*07d0*/                   IADD3 R18, P2, R18, 0x4000, RZ ;
        /*07e0*/                   IADD3 R16, P3, R16, 0x4000, RZ ;
        /*07f0*/                   IADD3.X R9, RZ, R9, RZ, P2, !PT ;
        /*0800*/                   IADD3.X R19, RZ, R19, RZ, P3, !PT ;
        /*0810*/                   FFMA R27, R27, R24, R34 ;
        /*0820*/                   FADD R24, -R6.reuse, R29 ;
        /*0830*/                   FADD R31, -R6, R31 ;
        /*0840*/                   FFMA R24, R24, R26, R27 ;
        /*0850*/                   FFMA R21, R31, R21, R24 ;
        /*0860*/                   FADD R24, -R6, R25 ;
        /*0870*/                   FFMA R21, R24, R30, R21 ;
        /*0880*/                   FADD R24, -R6.reuse, R35 ;
        /*0890*/                   FADD R2, -R6, R33 ;
        /*08a0*/                   FFMA R21, R24, R28, R21 ;
        /*08b0*/                   FFMA R21, R2, R22, R21 ;
        /*08c0*/                   FADD R2, -R6, R37 ;
        /*08d0*/                   FFMA R21, R2, R32, R21 ;
        /*08e0*/              @!P1 BRA `(.L_x_217) ;
.L_x_216:
        /*08f0*/                   BSYNC B1 ;
.L_x_215:
        /*0900*/                   IADD3 R2, -R20, c[0x0][0x188], RZ ;
        /*0910*/                   BSSY B1, `(.L_x_218) ;
        /*0920*/                   ISETP.GT.AND P1, PT, R2, 0x400, PT ;
        /*0930*/              @!P1 BRA `(.L_x_219) ;
        /*0940*/                   MOV R2, R18 ;
        /*0950*/                   MOV R3, R9 ;
        /*0960*/                   MOV R4, R16 ;
        /*0970*/                   MOV R5, R19 ;
        /*0980*/                   IMAD.WIDE R2, R17, 0x4, R2 ;
        /*0990*/                   IMAD.WIDE R4, R17, 0x4, R4 ;
        /*09a0*/                   LDG.E R37, [R2.64] ;
        /*09b0*/                   LDG.E R30, [R4.64] ;
        /*09c0*/                   LDG.E R33, [R2.64+0x400] ;
        /*09d0*/                   LDG.E R28, [R4.64+0x400] ;
        /*09e0*/                   LDG.E R31, [R2.64+0x800] ;
        /*09f0*/                   LDG.E R26, [R4.64+0x800] ;
        /*0a00*/                   LDG.E R29, [R2.64+0xc00] ;
        /*0a10*/                   LDG.E R24, [R4.64+0xc00] ;
        /*0a20*/                   LDG.E R27, [R2.64+0x1000] ;
        /*0a30*/                   LDG.E R22, [R4.64+0x1000] ;
        /*0a40*/                   LDG.E R25, [R2.64+0x1400] ;
        /*0a50*/                   LDG.E R34, [R4.64+0x1400] ;
        /*0a60*/                   LDG.E R23, [R2.64+0x1800] ;
        /*0a70*/                   LDG.E R32, [R4.64+0x1800] ;
        /*0a80*/                   LDG.E R35, [R2.64+0x1c00] ;
        /*0a90*/                   LDG.E R36, [R4.64+0x1c00] ;
        /*0aa0*/                   IADD3 R18, P1, R18, 0x2000, RZ ;
        /*0ab0*/                   IADD3 R16, P2, R16, 0x2000, RZ ;
        /*0ac0*/                   PLOP3.LUT P0, PT, PT, PT, PT, 0x8, 0x0 ;
        /*0ad0*/                   IADD3 R20, R20, 0x800, RZ ;
        /*0ae0*/                   IADD3.X R9, RZ, R9, RZ, P1, !PT ;
        /*0af0*/                   IADD3.X R19, RZ, R19, RZ, P2, !PT ;
        /*0b00*/                   FADD R37, -R6, R37 ;
        /*0b10*/                   FFMA R37, R37, R30, R21 ;
        /*0b20*/                   FADD R30, -R6, R33 ;
        /*0b30*/                   FFMA R37, R30, R28, R37 ;
        /*0b40*/                   FADD R28, -R6, R31 ;
        /*0b50*/                   FFMA R37, R28, R26, R37 ;
        /*0b60*/                   FADD R26, -R6, R29 ;
        /*0b70*/                   FFMA R37, R26, R24, R37 ;
        /*0b80*/                   FADD R2, -R6, R27 ;
        /*0b90*/                   FFMA R37, R2, R22, R37 ;
        /*0ba0*/                   FADD R2, -R6, R25 ;
        /*0bb0*/                   FFMA R37, R2, R34, R37 ;
        /*0bc0*/                   FADD R2, -R6, R23 ;
        /*0bd0*/                   FFMA R37, R2, R32, R37 ;
        /*0be0*/                   FADD R2, -R6, R35 ;
        /*0bf0*/                   FFMA R21, R2, R36, R37 ;
.L_x_219:
        /*0c00*/                   BSYNC B1 ;
.L_x_218:
        /*0c10*/                   ISETP.LT.OR P0, PT, R20, c[0x0][0x188], P0 ;
        /*0c20*/                   MOV R5, R19 ;
        /*0c30*/                   MOV R4, R16 ;
        /*0c40*/                   MOV R19, R9 ;
        /*0c50*/              @!P0 BRA `(.L_x_212) ;
        /*0c60*/                   IMAD.WIDE R2, R17, 0x4, R18 ;
        /*0c70*/                   IMAD.WIDE R4, R17, 0x4, R4 ;
        /*0c80*/                   LDG.E R9, [R2.64] ;
        /*0c90*/                   LDG.E R17, [R4.64] ;
        /*0ca0*/                   LDG.E R19, [R2.64+0x400] ;
        /*0cb0*/                   LDG.E R18, [R4.64+0x400] ;
        /*0cc0*/                   LDG.E R23, [R2.64+0x800] ;
        /*0cd0*/                   LDG.E R25, [R2.64+0xc00] ;
        /*0ce0*/                   LDG.E R20, [R4.64+0x800] ;
        /*0cf0*/                   LDG.E R22, [R4.64+0xc00] ;
        /*0d00*/                   FADD R16, -R6, R9 ;
        /*0d10*/                   FFMA R16, R16, R17, R21 ;
        /*0d20*/                   FADD R19, -R6, R19 ;
        /*0d30*/                   FFMA R16, R19, R18, R16 ;
        /*0d40*/                   FADD R23, -R6.reuse, R23 ;
        /*0d50*/                   FADD R25, -R6, R25 ;
        /*0d60*/                   FFMA R16, R23, R20, R16 ;
        /*0d70*/                   FFMA R21, R25, R22, R16 ;
.L_x_212:
        /*0d80*/                   BSYNC B0 ;
.L_x_211:
        /*0d90*/                   IADD3 R11, R11, 0x1, RZ ;
        /*0da0*/                   ISETP.GE.AND P0, PT, R11, c[0x0][0x180], PT ;
        /*0db0*/              @!P0 BRA `(.L_x_220) ;
.L_x_210:
        /*0dc0*/                   S2R R9, SR_TID.X ;
        /*0dd0*/                   STS [R9.X4], R21 ;
        /*0de0*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*0df0*/                   ISETP.GT.AND P0, PT, R9.reuse, 0x7f, PT ;
        /*0e00*/                   ISETP.GT.AND P1, PT, R9, 0x3f, PT ;
        /*0e10*/              @!P0 LDS R2, [R9.X4] ;
        /*0e20*/              @!P0 LDS R3, [R9.X4+0x200] ;
        /*0e30*/              @!P0 FADD R2, R2, R3 ;
        /*0e40*/              @!P0 STS [R9.X4], R2 ;
        /*0e50*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*0e60*/                   ISETP.GT.AND P0, PT, R9, 0x1f, PT ;
        /*0e70*/              @!P1 LDS R3, [R9.X4] ;
        /*0e80*/              @!P1 LDS R4, [R9.X4+0x100] ;
        /*0e90*/              @!P1 FADD R3, R3, R4 ;
        /*0ea0*/              @!P1 STS [R9.X4], R3 ;
        /*0eb0*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*0ec0*/                   ISETP.GT.AND P1, PT, R9, 0xf, PT ;
        /*0ed0*/              @!P0 LDS R4, [R9.X4] ;
        /*0ee0*/              @!P0 LDS R5, [R9.X4+0x80] ;
        /*0ef0*/              @!P0 FADD R4, R4, R5 ;
        /*0f00*/              @!P0 STS [R9.X4], R4 ;
        /*0f10*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*0f20*/                   ISETP.GT.AND P0, PT, R9, 0x7, PT ;
        /*0f30*/              @!P1 LDS R2, [R9.X4] ;
        /*0f40*/              @!P1 LDS R5, [R9.X4+0x40] ;
        /*0f50*/              @!P1 FADD R2, R2, R5 ;
        /*0f60*/              @!P1 STS [R9.X4], R2 ;
        /*0f70*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*0f80*/                   ISETP.GT.AND P1, PT, R9, 0x3, PT ;
        /*0f90*/              @!P0 LDS R3, [R9.X4] ;
        /*0fa0*/              @!P0 LDS R6, [R9.X4+0x20] ;
        /*0fb0*/              @!P0 FADD R3, R3, R6 ;
        /*0fc0*/              @!P0 STS [R9.X4], R3 ;
        /*0fd0*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*0fe0*/                   ISETP.GT.AND P0, PT, R9, 0x1, PT ;
        /*0ff0*/              @!P1 LDS R4, [R9.X4] ;
        /*1000*/              @!P1 LDS R5, [R9.X4+0x10] ;
        /*1010*/              @!P1 FADD R4, R4, R5 ;
        /*1020*/              @!P1 STS [R9.X4], R4 ;
        /*1030*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*1040*/                   ISETP.GT.AND P1, PT, R9, RZ, PT ;
        /*1050*/              @!P0 LDS R2, [R9.X4] ;
        /*1060*/              @!P0 LDS R5, [R9.X4+0x8] ;
        /*1070*/              @!P0 FADD R2, R2, R5 ;
        /*1080*/              @!P0 STS [R9.X4], R2 ;
        /*1090*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*10a0*/                   ISETP.NE.AND P0, PT, R9, RZ, PT ;
        /*10b0*/              @!P1 LDS R3, [R9.X4] ;
        /*10c0*/              @!P1 LDS R6, [R9.X4+0x4] ;
        /*10d0*/              @!P1 FADD R3, R3, R6 ;
        /*10e0*/              @!P1 STS [R9.X4], R3 ;
        /*10f0*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*1100*/               @P0 EXIT ;
        /*1110*/                   SHF.L.U32 R2, R0.reuse, 0x2, RZ ;
        /*1120*/                   SHF.L.U64.HI R7, R0, 0x2, R7 ;
        /*1130*/                   IADD3 R4, P0, R2, c[0x0][0x178], RZ ;
        /*1140*/                   LDS R0, [RZ] ;
        /*1150*/                   IADD3.X R5, R7, c[0x0][0x17c], RZ, P0, !PT ;
        /*1160*/                   LDG.E R3, [R4.64] ;
        /*1170*/                   MOV R8, 0x3f800000 ;
        /*1180*/                   FADD R6, R3, 9.9999997473787516356e-06 ;
        /*1190*/                   FSETP.NEU.AND P0, PT, R6, 1, PT ;
        /*11a0*/              @!P0 BRA `(.L_x_221) ;
        /*11b0*/                   FSETP.GTU.AND P0, PT, |R6|, +INF , PT ;
        /*11c0*/               @P0 BRA `(.L_x_222) ;
        /*11d0*/                   FSETP.NEU.AND P0, PT, |R6|, +INF , PT ;
        /*11e0*/                   FSETP.EQ.OR P0, PT, R6, RZ, !P0 ;
        /*11f0*/               @P0 BRA `(.L_x_223) ;
        /*1200*/                   FMUL R5, |R6|.reuse, 16777216 ;
        /*1210*/                   FSETP.GEU.AND P0, PT, |R6|, 1.175494350822287508e-38, PT ;
        /*1220*/                   MOV R12, 0x3a2c32e4 ;
        /*1230*/                   FSEL R5, R5, |R6|, !P0 ;
        /*1240*/                   FSETP.GEU.AND P2, PT, R3, -9.9999997473787516356e-06, PT ;
        /*1250*/                   IADD3 R4, R5, -0x3f3504f3, RZ ;
        /*1260*/                   LOP3.LUT R4, R4, 0xff800000, RZ, 0xc0, !PT ;
        /*1270*/                   IADD3 R5, R5, -R4.reuse, RZ ;
        /*1280*/                   I2FP.F32.S32 R4, R4 ;
        /*1290*/                   FADD R8, R5.reuse, 1 ;
        /*12a0*/                   FADD R6, R5, -1 ;
        /*12b0*/                   FSEL R5, RZ, -24, P0 ;
        /*12c0*/                   FADD R9, R6, R6 ;
        /*12d0*/                   MUFU.RCP R8, R8 ;
        /*12e0*/                   FFMA R4, R4, 1.1920928955078125e-07, R5 ;
        /*12f0*/                   FMUL R9, R8, R9 ;
        /*1300*/                   FADD R10, R6, -R9 ;
        /*1310*/                   FMUL R5, R9.reuse, R9.reuse ;
        /*1320*/                   FFMA R13, R9, 1.4426950216293334961, R4 ;
        /*1330*/                   FADD R11, R10, R10 ;
        /*1340*/                   FFMA R10, R5.reuse, R12, 0.0032181653659790754318 ;
        /*1350*/                   FADD R4, R4, -R13 ;
        /*1360*/                   FFMA R11, R6, -R9, R11 ;
        /*1370*/                   FFMA R10, R5, R10, 0.018033718690276145935 ;
        /*1380*/                   FFMA R4, R9, 1.4426950216293334961, R4 ;
        /*1390*/                   FMUL R11, R8, R11 ;
        /*13a0*/                   FFMA R10, R5, R10, 0.12022458761930465698 ;
        /*13b0*/                   FFMA R4, R11, 1.4426950216293334961, R4 ;
        /*13c0*/                   FMUL R10, R5, R10 ;
        /*13d0*/                   FFMA R6, R9, 1.9251366722983220825e-08, R4 ;
        /*13e0*/                   FMUL R4, R10, 3 ;
        /*13f0*/                   FFMA R11, R11, R4, R6 ;
        /*1400*/                   FFMA R10, R9, R10, R11 ;
        /*1410*/                   MOV R9, 0x391fcb8e ;
        /*1420*/                   FADD R4, R13, R10 ;
        /*1430*/                   FMUL R5, R4, -1.5 ;
        /*1440*/                   FADD R13, -R13, R4 ;
        /*1450*/                   FRND R6, R5 ;
        /*1460*/                   FADD R13, R10, -R13 ;
        /*1470*/                   FFMA R4, R4, -1.5, -R5 ;
        /*1480*/                   FSETP.GT.AND P1, PT, |R5|, 152, PT ;
        /*1490*/                   FFMA R13, R13, -1.5, R4 ;
        /*14a0*/                   FADD R4, R5, -R6 ;
        /*14b0*/                   FSETP.GT.AND P0, PT, R6, RZ, PT ;
        /*14c0*/                   FADD R4, R4, R13 ;
        /*14d0*/                   SEL R6, RZ, 0x83000000, P0 ;
        /*14e0*/                   FSETP.GEU.AND P0, PT, R5, RZ, PT ;
        /*14f0*/                   FFMA R9, R4, R9, 0.0013391353422775864601 ;
        /*1500*/                   IADD3 R10, R6, 0x7f000000, RZ ;
        /*1510*/                   FSEL R8, RZ, +INF , !P0 ;
        /*1520*/                   FFMA R11, R4.reuse, R9, 0.0096188392490148544312 ;
        /*1530*/                   F2I.NTZ R9, R5 ;
        /*1540*/                   FFMA R11, R4, R11, 0.055503588169813156128 ;
        /*1550*/                   FFMA R11, R4, R11, 0.24022644758224487305 ;
        /*1560*/                   FFMA R11, R4, R11, 0.69314718246459960938 ;
        /*1570*/                   FFMA R11, R4, R11, 1 ;
        /*1580*/                   LEA R9, R9, -R6, 0x17 ;
        /*1590*/                   FMUL R10, R10, R11 ;
        /*15a0*/              @!P1 FMUL R8, R9, R10 ;
        /*15b0*/               @P2 BRA `(.L_x_221) ;
        /*15c0*/                   MOV R8, 0x7fffffff ;
        /*15d0*/                   BRA `(.L_x_221) ;
.L_x_223:
        /*15e0*/                   FADD R6, R6, R6 ;
        /*15f0*/                   LOP3.LUT R6, R6, 0x7f800000, RZ, 0x3c, !PT ;
        /*1600*/                   LOP3.LUT R8, R6, 0x7fffffff, RZ, 0xc0, !PT ;
        /*1610*/                   BRA `(.L_x_221) ;
.L_x_222:
        /*1620*/                   FADD R8, R6, -1.5 ;
.L_x_221:
        /*1630*/                   IADD3 R2, P0, R2, c[0x0][0x190], RZ ;
        /*1640*/                   FMUL R5, R0, -0.5 ;
        /*1650*/                   IADD3.X R3, R7, c[0x0][0x194], RZ, P0, !PT ;
        /*1660*/                   FMUL R5, R5, R8 ;
        /*1670*/                   STG.E [R2.64], R5 ;
        /*1680*/                   EXIT ;
.L_x_224:
        /*1690*/                   BRA `(.L_x_224);
        /*16a0*/                   NOP;
        /*16b0*/                   NOP;
        /*16c0*/                   NOP;
        /*16d0*/                   NOP;
        /*16e0*/                   NOP;
        /*16f0*/                   NOP;
        /*1700*/                   NOP;
        /*1710*/                   NOP;
        /*1720*/                   NOP;
        /*1730*/                   NOP;
        /*1740*/                   NOP;
        /*1750*/                   NOP;
        /*1760*/                   NOP;
        /*1770*/                   NOP;
.L_x_464:


//--------------------- .text.fast_mean_delta_kernel --------------------------
	.section	.text.fast_mean_delta_kernel,"ax",@progbits
	.sectionflags	@"SHF_BARRIERS=1"
	.sectioninfo	@"SHI_REGISTERS=39"
	.align	128
        .global         fast_mean_delta_kernel
        .type           fast_mean_delta_kernel,@function
        .size           fast_mean_delta_kernel,(.L_x_441 - fast_mean_delta_kernel)
        .other          fast_mean_delta_kernel,@"STO_CUDA_ENTRY STV_DEFAULT"
fast_mean_delta_kernel:
.text.fast_mean_delta_kernel:
        /*0000*/                   IMAD.MOV.U32 R1, RZ, RZ, c[0x0][0x28] ;
        /*0010*/                   S2R R2, SR_CTAID.X ;
        /*0020*/                   ISETP.LT.AND P0, PT, RZ, c[0x0][0x170], PT ;
        /*0030*/                   ULDC.64 UR4, c[0x0][0x118] ;
        /*0040*/              @!P0 IMAD.MOV.U32 R10, RZ, RZ, RZ ;
        /*0050*/              @!P0 BRA `(.L_x_225) ;
        /*0060*/                   S2R R0, SR_TID.X ;
        /*0070*/                   MOV R10, RZ ;
        /*0080*/                   IMAD.MOV.U32 R7, RZ, RZ, RZ ;
        /*0090*/                   LOP3.LUT R3, RZ, R0, RZ, 0x33, !PT ;
        /*00a0*/                   IADD3 R6, R0.reuse, 0x100, RZ ;
        /*00b0*/                   IADD3 R3, R3, c[0x0][0x178], RZ ;
        /*00c0*/                   IADD3 R8, R0, 0x200, RZ ;
        /*00d0*/                   LEA.HI R9, R3, 0x1, RZ, 0x18 ;
        /*00e0*/                   IADD3 R20, R0, 0x300, RZ ;
        /*00f0*/                   LOP3.LUT R9, R9, 0x3, RZ, 0xc0, !PT ;
.L_x_235:
        /*0100*/                   ISETP.GE.AND P0, PT, R0, c[0x0][0x178], PT ;
        /*0110*/                   BSSY B0, `(.L_x_226) ;
        /*0120*/               @P0 BRA `(.L_x_227) ;
        /*0130*/                   ISETP.NE.AND P1, PT, R9, RZ, PT ;
        /*0140*/                   BSSY B1, `(.L_x_228) ;
        /*0150*/                   ISETP.GE.U32.AND P0, PT, R3, 0x300, PT ;
        /*0160*/                   IMAD R12, R7, c[0x0][0x174], R2 ;
        /*0170*/                   IMAD.MOV.U32 R11, RZ, RZ, R0 ;
        /*0180*/              @!P1 BRA `(.L_x_229) ;
        /*0190*/                   MOV R5, 0x4 ;
        /*01a0*/                   IMAD R4, R12, c[0x0][0x178], R0 ;
        /*01b0*/                   IMAD.WIDE R4, R4, R5, c[0x0][0x160] ;
        /*01c0*/                   LDG.E R13, [R4.64] ;
        /*01d0*/                   ISETP.NE.AND P1, PT, R9, 0x1, PT ;
        /*01e0*/                   IMAD.MOV.U32 R11, RZ, RZ, R6 ;
        /*01f0*/                   FADD R10, R10, R13 ;
        /*0200*/              @!P1 BRA `(.L_x_229) ;
        /*0210*/                   ISETP.NE.AND P1, PT, R9, 0x2, PT ;
        /*0220*/                   LDG.E R13, [R4.64+0x400] ;
        /*0230*/               @P1 LDG.E R15, [R4.64+0x800] ;
        /*0240*/                   IMAD.MOV.U32 R11, RZ, RZ, R8 ;
        /*0250*/               @P1 MOV R11, R20 ;
        /*0260*/                   FADD R10, R10, R13 ;
        /*0270*/               @P1 FADD R10, R10, R15 ;
.L_x_229:
        /*0280*/                   BSYNC B1 ;
.L_x_228:
        /*0290*/              @!P0 BRA `(.L_x_227) ;
        /*02a0*/                   IADD3 R4, -R11, c[0x0][0x178], RZ ;
        /*02b0*/                   IMAD.MOV.U32 R5, RZ, RZ, 0x4 ;
        /*02c0*/                   BSSY B1, `(.L_x_230) ;
        /*02d0*/                   PLOP3.LUT P0, PT, PT, PT, PT, 0x80, 0x0 ;
        /*02e0*/                   ISETP.GT.AND P1, PT, R4, 0xc00, PT ;
        /*02f0*/                   IMAD R4, R12, c[0x0][0x178], R11 ;
        /*0300*/                   IMAD.WIDE R4, R4, R5, c[0x0][0x160] ;
        /*0310*/              @!P1 BRA `(.L_x_231) ;
        /*0320*/                   IMAD.MOV.U32 R14, RZ, RZ, c[0x0][0x178] ;
        /*0330*/                   PLOP3.LUT P0, PT, PT, PT, PT, 0x8, 0x0 ;
        /*0340*/                   IADD3 R14, R14, -0xc00, RZ ;
.L_x_232:
        /*0350*/                   LDG.E R21, [R4.64] ;
        /*0360*/                   LDG.E R22, [R4.64+0x400] ;
        /*0370*/                   LDG.E R24, [R4.64+0x800] ;
        /*0380*/                   LDG.E R26, [R4.64+0xc00] ;
        /*0390*/                   LDG.E R28, [R4.64+0x1000] ;
        /*03a0*/                   LDG.E R30, [R4.64+0x1400] ;
        /*03b0*/                   LDG.E R32, [R4.64+0x1800] ;
        /*03c0*/                   LDG.E R34, [R4.64+0x1c00] ;
        /*03d0*/                   LDG.E R36, [R4.64+0x2000] ;
        /*03e0*/                   LDG.E R19, [R4.64+0x2400] ;
        /*03f0*/                   LDG.E R18, [R4.64+0x2800] ;
        /*0400*/                   LDG.E R17, [R4.64+0x2c00] ;
        /*0410*/                   LDG.E R16, [R4.64+0x3000] ;
        /*0420*/                   LDG.E R13, [R4.64+0x3400] ;
        /*0430*/                   LDG.E R15, [R4.64+0x3800] ;
        /*0440*/                   LDG.E R12, [R4.64+0x3c00] ;
        /*0450*/                   IADD3 R11, R11, 0x1000, RZ ;
        /*0460*/                   ISETP.GE.AND P1, PT, R11, R14, PT ;
        /*0470*/                   IADD3 R4, P2, R4, 0x4000, RZ ;
        /*0480*/                   IADD3.X R5, RZ, R5, RZ, P2, !PT ;
        /*0490*/                   FADD R21, R21, R10 ;
        /*04a0*/                   FADD R21, R21, R22 ;
        /*04b0*/                   FADD R21, R21, R24 ;
        /*04c0*/                   FADD R21, R21, R26 ;
        /*04d0*/                   FADD R21, R21, R28 ;
        /*04e0*/                   FADD R21, R21, R30 ;
        /*04f0*/                   FADD R21, R21, R32 ;
        /*0500*/                   FADD R21, R21, R34 ;
        /*0510*/                   FADD R36, R21, R36 ;
        /*0520*/                   FADD R19, R36, R19 ;
        /*0530*/                   FADD R18, R19, R18 ;
        /*0540*/                   FADD R17, R18, R17 ;
        /*0550*/                   FADD R16, R17, R16 ;
        /*0560*/                   FADD R16, R16, R13 ;
        /*0570*/                   FADD R15, R16, R15 ;
        /*0580*/                   FADD R10, R15, R12 ;
        /*0590*/              @!P1 BRA `(.L_x_232) ;
.L_x_231:
        /*05a0*/                   BSYNC B1 ;
.L_x_230:
        /*05b0*/                   IADD3 R12, -R11, c[0x0][0x178], RZ ;
        /*05c0*/                   BSSY B1, `(.L_x_233) ;
        /*05d0*/                   ISETP.GT.AND P1, PT, R12, 0x400, PT ;
        /*05e0*/              @!P1 BRA `(.L_x_234) ;
        /*05f0*/                   LDG.E R13, [R4.64] ;
        /*0600*/                   LDG.E R12, [R4.64+0x400] ;
        /*0610*/                   LDG.E R15, [R4.64+0x800] ;
        /*0620*/                   LDG.E R17, [R4.64+0xc00] ;
        /*0630*/                   LDG.E R19, [R4.64+0x1000] ;
        /*0640*/                   LDG.E R21, [R4.64+0x1400] ;
        /*0650*/                   LDG.E R23, [R4.64+0x1800] ;
        /*0660*/                   LDG.E R25, [R4.64+0x1c00] ;
        /*0670*/                   PLOP3.LUT P0, PT, PT, PT, PT, 0x8, 0x0 ;
        /*0680*/                   IADD3 R11, R11, 0x800, RZ ;
        /*0690*/                   FADD R13, R10, R13 ;
        /*06a0*/                   FADD R12, R13, R12 ;
        /*06b0*/                   IADD3 R13, P1, R4, 0x2000, RZ ;
        /*06c0*/                   FADD R12, R12, R15 ;
        /*06d0*/                   IMAD.X R14, RZ, RZ, R5, P1 ;
        /*06e0*/                   FADD R12, R12, R17 ;
        /*06f0*/                   IMAD.MOV.U32 R4, RZ, RZ, R13 ;
        /*0700*/                   MOV R5, R14 ;
        /*0710*/                   FADD R12, R12, R19 ;
        /*0720*/                   FADD R12, R12, R21 ;
        /*0730*/                   FADD R12, R12, R23 ;
        /*0740*/                   FADD R10, R12, R25 ;
.L_x_234:
        /*0750*/                   BSYNC B1 ;
.L_x_233:
        /*0760*/                   ISETP.LT.OR P0, PT, R11, c[0x0][0x178], P0 ;
        /*0770*/              @!P0 BRA `(.L_x_227) ;
        /*0780*/                   LDG.E R11, [R4.64] ;
        /*0790*/                   LDG.E R12, [R4.64+0x400] ;
        /*07a0*/                   LDG.E R14, [R4.64+0x800] ;
        /*07b0*/                   LDG.E R16, [R4.64+0xc00] ;
        /*07c0*/                   FADD R11, R10, R11 ;
        /*07d0*/                   FADD R11, R11, R12 ;
        /*07e0*/                   FADD R11, R11, R14 ;
        /*07f0*/                   FADD R10, R11, R16 ;
.L_x_227:
        /*0800*/                   BSYNC B0 ;
.L_x_226:
        /*0810*/                   IADD3 R7, R7, 0x1, RZ ;
        /*0820*/                   ISETP.GE.AND P0, PT, R7, c[0x0][0x170], PT ;
        /*0830*/              @!P0 BRA `(.L_x_235) ;
.L_x_225:
        /*0840*/                   S2R R7, SR_TID.X ;
        /*0850*/                   STS [R7.X4], R10 ;
        /*0860*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*0870*/                   ISETP.GT.AND P0, PT, R7.reuse, 0x7f, PT ;
        /*0880*/                   ISETP.GT.AND P1, PT, R7, 0x3f, PT ;
        /*0890*/              @!P0 LDS R0, [R7.X4] ;
        /*08a0*/              @!P0 LDS R3, [R7.X4+0x200] ;
        /*08b0*/              @!P0 FADD R0, R0, R3 ;
        /*08c0*/              @!P0 STS [R7.X4], R0 ;
        /*08d0*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*08e0*/                   ISETP.GT.AND P0, PT, R7, 0x1f, PT ;
        /*08f0*/              @!P1 LDS R3, [R7.X4] ;
        /*0900*/              @!P1 LDS R4, [R7.X4+0x100] ;
        /*0910*/              @!P1 FADD R3, R3, R4 ;
        /*0920*/              @!P1 STS [R7.X4], R3 ;
        /*0930*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*0940*/                   ISETP.GT.AND P1, PT, R7, 0xf, PT ;
        /*0950*/              @!P0 LDS R4, [R7.X4] ;
        /*0960*/              @!P0 LDS R5, [R7.X4+0x80] ;
        /*0970*/              @!P0 FADD R4, R4, R5 ;
        /*0980*/              @!P0 STS [R7.X4], R4 ;
        /*0990*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*09a0*/                   ISETP.GT.AND P0, PT, R7, 0x7, PT ;
        /*09b0*/              @!P1 LDS R0, [R7.X4] ;
        /*09c0*/              @!P1 LDS R5, [R7.X4+0x40] ;
        /*09d0*/              @!P1 FADD R0, R0, R5 ;
        /*09e0*/              @!P1 STS [R7.X4], R0 ;
        /*09f0*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*0a00*/                   ISETP.GT.AND P1, PT, R7, 0x3, PT ;
        /*0a10*/              @!P0 LDS R3, [R7.X4] ;
        /*0a20*/              @!P0 LDS R6, [R7.X4+0x20] ;
        /*0a30*/              @!P0 FADD R3, R3, R6 ;
        /*0a40*/              @!P0 STS [R7.X4], R3 ;
        /*0a50*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*0a60*/                   ISETP.GT.AND P0, PT, R7, 0x1, PT ;
        /*0a70*/              @!P1 LDS R4, [R7.X4] ;
        /*0a80*/              @!P1 LDS R5, [R7.X4+0x10] ;
        /*0a90*/              @!P1 FADD R4, R4, R5 ;
        /*0aa0*/              @!P1 STS [R7.X4], R4 ;
        /*0ab0*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*0ac0*/                   ISETP.GT.AND P1, PT, R7, RZ, PT ;
        /*0ad0*/              @!P0 LDS R0, [R7.X4] ;
        /*0ae0*/              @!P0 LDS R5, [R7.X4+0x8] ;
        /*0af0*/              @!P0 FADD R0, R0, R5 ;
        /*0b00*/              @!P0 STS [R7.X4], R0 ;
        /*0b10*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*0b20*/                   ISETP.NE.AND P0, PT, R7, RZ, PT ;
        /*0b30*/              @!P1 LDS R3, [R7.X4] ;
        /*0b40*/              @!P1 LDS R6, [R7.X4+0x4] ;
        /*0b50*/              @!P1 FADD R3, R3, R6 ;
        /*0b60*/              @!P1 STS [R7.X4], R3 ;
        /*0b70*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*0b80*/               @P0 EXIT ;
        /*0b90*/                   IMAD.MOV.U32 R5, RZ, RZ, 0x4 ;
        /*0ba0*/                   LDS R3, [RZ] ;
        /*0bb0*/                   IMAD.WIDE R4, R2, R5, c[0x0][0x168] ;
        /*0bc0*/                   LDG.E R4, [R4.64] ;
        /*0bd0*/                   FADD R0, R4, 9.9999997473787516356e-06 ;
        /*0be0*/                   MUFU.RSQ R7, R0 ;
        /*0bf0*/                   IADD3 R6, R0, -0xd000000, RZ ;
        /*0c00*/                   ISETP.GT.U32.AND P0, PT, R6, 0x727fffff, PT ;
        /*0c10*/              @!P0 BRA `(.L_x_236) ;
        /*0c20*/                   MOV R6, 0xc40 ;
        /*0c30*/                   CALL.REL.NOINC `($__internal_7_$__cuda_sm20_sqrt_rn_f32_slowpath) ;
        /*0c40*/                   IMAD.MOV.U32 R4, RZ, RZ, R0 ;
        /*0c50*/                   BRA `(.L_x_237) ;
.L_x_236:
        /*0c60*/                   FMUL.FTZ R5, R0, R7 ;
        /*0c70*/                   FMUL.FTZ R4, R7, 0.5 ;
        /*0c80*/                   FFMA R0, -R5, R5, R0 ;
        /*0c90*/                   FFMA R4, R0, R4, R5 ;
.L_x_237:
        /*0ca0*/                   MUFU.RCP R5, R4 ;
        /*0cb0*/                   UMOV UR6, 0x3f800000 ;
        /*0cc0*/                   MOV R7, UR6 ;
        /*0cd0*/                   FCHK P0, -R7, R4 ;
        /*0ce0*/                   FFMA R0, R5, -R4, 1 ;
        /*0cf0*/                   FFMA R0, R5, R0, R5 ;
        /*0d00*/                   FFMA R5, R0, -1, RZ ;
        /*0d10*/                   FFMA R6, R5, -R4, -1 ;
        /*0d20*/                   FFMA R0, R0, R6, R5 ;
        /*0d30*/              @!P0 BRA `(.L_x_238) ;
        /*0d40*/                   IMAD.MOV.U32 R0, RZ, RZ, R4 ;
        /*0d50*/                   MOV R4, 0xd70 ;
        /*0d60*/                   CALL.REL.NOINC `($__internal_8_$__cuda_sm3x_div_rn_noftz_f32_slowpath) ;
        /*0d70*/                   IMAD.MOV.U32 R0, RZ, RZ, R8 ;
.L_x_238:
        /*0d80*/                   MOV R7, 0x4 ;
        /*0d90*/                   FMUL R5, R3, R0 ;
        /*0da0*/                   IMAD.WIDE R2, R2, R7, c[0x0][0x180] ;
        /*0db0*/                   STG.E [R2.64], R5 ;
        /*0dc0*/                   EXIT ;
        .weak           $__internal_7_$__cuda_sm20_sqrt_rn_f32_slowpath
        .type           $__internal_7_$__cuda_sm20_sqrt_rn_f32_slowpath,@function
        .size           $__internal_7_$__cuda_sm20_sqrt_rn_f32_slowpath,($__internal_8_$__cuda_sm3x_div_rn_noftz_f32_slowpath - $__internal_7_$__cuda_sm20_sqrt_rn_f32_slowpath)
$__internal_7_$__cuda_sm20_sqrt_rn_f32_slowpath:
        /*0dd0*/                   LOP3.LUT P0, RZ, R0, 0x7fffffff, RZ, 0xc0, !PT ;
        /*0de0*/              @!P0 IMAD.MOV.U32 R4, RZ, RZ, R0 ;
        /*0df0*/              @!P0 BRA `(.L_x_239) ;
        /*0e00*/                   FSETP.GEU.FTZ.AND P0, PT, R0, RZ, PT ;
        /*0e10*/              @!P0 IMAD.MOV.U32 R4, RZ, RZ, 0x7fffffff ;
        /*0e20*/              @!P0 BRA `(.L_x_239) ;
        /*0e30*/                   FSETP.GTU.FTZ.AND P0, PT, |R0|, +INF , PT ;
        /*0e40*/               @P0 FADD.FTZ R4, R0, 1 ;
        /*0e50*/               @P0 BRA `(.L_x_239) ;
        /*0e60*/                   FSETP.NEU.FTZ.AND P0, PT, |R0|, +INF , PT ;
        /*0e70*/              @!P0 MOV R4, R0 ;
        /*0e80*/              @!P0 BRA `(.L_x_239) ;
        /*0e90*/                   FFMA R0, R0, 1.84467440737095516160e+19, RZ ;
        /*0ea0*/                   MUFU.RSQ R5, R0 ;
        /*0eb0*/                   FMUL.FTZ R7, R0, R5 ;
        /*0ec0*/                   FMUL.FTZ R5, R5, 0.5 ;
        /*0ed0*/                   FADD.FTZ R4, -R7, -RZ ;
        /*0ee0*/                   FFMA R4, R7, R4, R0 ;
        /*0ef0*/                   FFMA R4, R4, R5, R7 ;
        /*0f00*/                   FMUL.FTZ R4, R4, 2.3283064365386962891e-10 ;
.L_x_239:
        /*0f10*/                   IMAD.MOV.U32 R0, RZ, RZ, R4 ;
        /*0f20*/                   MOV R4, R6 ;
        /*0f30*/                   IMAD.MOV.U32 R5, RZ, RZ, 0x0 ;
        /*0f40*/                   RET.REL.NODEC R4 `(fast_mean_delta_kernel) ;
        .weak           $__internal_8_$__cuda_sm3x_div_rn_noftz_f32_slowpath
        .type           $__internal_8_$__cuda_sm3x_div_rn_noftz_f32_slowpath,@function
        .size           $__internal_8_$__cuda_sm3x_div_rn_noftz_f32_slowpath,(.L_x_441 - $__internal_8_$__cuda_sm3x_div_rn_noftz_f32_slowpath)
$__internal_8_$__cuda_sm3x_div_rn_noftz_f32_slowpath:
        /*0f50*/                   SHF.R.U32.HI R5, RZ, 0x17, R0 ;
        /*0f60*/                   LOP3.LUT R10, R5, 0xff, RZ, 0xc0, !PT ;
        /*0f70*/                   IADD3 R6, R10, -0x1, RZ ;
        /*0f80*/                   ISETP.GT.U32.AND P0, PT, R6, 0xfd, PT ;
        /*0f90*/              @!P0 MOV R5, RZ ;
        /*0fa0*/              @!P0 BRA `(.L_x_240) ;
        /*0fb0*/                   FSETP.GTU.FTZ.AND P0, PT, |R0|, +INF , PT ;
        /*0fc0*/               @P0 BRA `(.L_x_241) ;
        /*0fd0*/                   IMAD.MOV.U32 R5, RZ, RZ, -0x40800000 ;
        /*0fe0*/                   LOP3.LUT P0, RZ, R0, 0x7fffffff, R5, 0xc8, !PT ;
        /*0ff0*/              @!P0 BRA `(.L_x_242) ;
        /*1000*/                   FSETP.NEU.FTZ.AND P0, PT, |R0|, +INF , PT ;
        /*1010*/                   LOP3.LUT P1, RZ, R5, 0x7fffffff, RZ, 0xc0, !PT ;
        /*1020*/                   PLOP3.LUT P0, PT, P0, P1, PT, 0x2a, 0x0 ;
        /*1030*/               @P0 BRA `(.L_x_243) ;
        /*1040*/                   LOP3.LUT P0, RZ, R0, 0x7fffffff, RZ, 0xc0, !PT ;
        /*1050*/              @!P0 BRA `(.L_x_244) ;
        /*1060*/                   ISETP.GE.AND P0, PT, R6, RZ, PT ;
        /*1070*/                   MOV R5, RZ ;
        /*1080*/              @!P0 FFMA R0, R0, 1.84467440737095516160e+19, RZ ;
        /*1090*/              @!P0 IADD3 R5, R5, 0x40, RZ ;
.L_x_240:
        /*10a0*/                   LEA R7, R10, 0xc0800000, 0x17 ;
        /*10b0*/                   UMOV UR6, 0xbf800000 ;
        /*10c0*/                   IADD3 R5, R5, 0x7f, -R10 ;
        /*10d0*/                   IMAD.IADD R7, R0, 0x1, -R7 ;
        /*10e0*/                   MUFU.RCP R0, R7 ;
        /*10f0*/                   FADD.FTZ R9, -R7, -RZ ;
        /*1100*/                   FFMA R11, R0, R9, 1 ;
        /*1110*/                   FFMA R0, R0, R11, R0 ;
        /*1120*/                   FFMA R6, R0, UR6, RZ ;
        /*1130*/                   FFMA R11, R9, R6, UR6 ;
        /*1140*/                   FFMA R11, R0, R11, R6 ;
        /*1150*/                   FFMA R12, R9, R11, UR6 ;
        /*1160*/                   FFMA R8, R0, R12, R11 ;
        /*1170*/                   SHF.R.U32.HI R6, RZ, 0x17, R8 ;
        /*1180*/                   LOP3.LUT R6, R6, 0xff, RZ, 0xc0, !PT ;
        /*1190*/                   IADD3 R9, R6, R5, RZ ;
        /*11a0*/                   IADD3 R6, R9, -0x1, RZ ;
        /*11b0*/                   ISETP.GE.U32.AND P0, PT, R6, 0xfe, PT ;
        /*11c0*/              @!P0 BRA `(.L_x_245) ;
        /*11d0*/                   ISETP.GT.AND P0, PT, R9, 0xfe, PT ;
        /*11e0*/               @P0 BRA `(.L_x_246) ;
        /*11f0*/                   ISETP.GE.AND P0, PT, R9, 0x1, PT ;
        /*1200*/               @P0 BRA `(.L_x_247) ;
        /*1210*/                   ISETP.GE.AND P0, PT, R9, -0x18, PT ;
        /*1220*/                   LOP3.LUT R8, R8, 0x80000000, RZ, 0xc0, !PT ;
        /*1230*/              @!P0 BRA `(.L_x_247) ;
        /*1240*/                   FFMA.RZ R5, R0.reuse, R12.reuse, R11.reuse ;
        /*1250*/                   IADD3 R7, R9.reuse, 0x20, RZ ;
        /*1260*/                   ISETP.NE.AND P2, PT, R9, RZ, PT ;
        /*1270*/                   LOP3.LUT R6, R5, 0x7fffff, RZ, 0xc0, !PT ;
        /*1280*/                   FFMA.RP R5, R0.reuse, R12.reuse, R11.reuse ;
        /*1290*/                   FFMA.RM R0, R0, R12, R11 ;
        /*12a0*/                   ISETP.NE.AND P1, PT, R9, RZ, PT ;
        /*12b0*/                   IMAD.MOV R9, RZ, RZ, -R9 ;
        /*12c0*/                   LOP3.LUT R6, R6, 0x800000, RZ, 0xfc, !PT ;
        /*12d0*/                   FSETP.NEU.FTZ.AND P0, PT, R5, R0, PT ;
        /*12e0*/                   SHF.L.U32 R7, R6, R7, RZ ;
        /*12f0*/                   SEL R5, R9, RZ, P2 ;
        /*1300*/                   ISETP.NE.AND P1, PT, R7, RZ, P1 ;
        /*1310*/                   SHF.R.U32.HI R5, RZ, R5, R6 ;
        /*1320*/                   PLOP3.LUT P0, PT, P0, P1, PT, 0xa8, 0x0 ;
        /*1330*/                   SHF.R.U32.HI R7, RZ, 0x1, R5 ;
        /*1340*/                   SEL R0, RZ, 0x1, !P0 ;
        /*1350*/                   LOP3.LUT R0, R0, 0x1, R7, 0xf8, !PT ;
        /*1360*/                   LOP3.LUT R0, R0, R5, RZ, 0xc0, !PT ;
        /*1370*/                   IADD3 R7, R7, R0, RZ ;
        /*1380*/                   LOP3.LUT R8, R7, R8, RZ, 0xfc, !PT ;
        /*1390*/                   BRA `(.L_x_247) ;
.L_x_246:
        /*13a0*/                   LOP3.LUT R8, R8, 0x80000000, RZ, 0xc0, !PT ;
        /*13b0*/                   LOP3.LUT R8, R8, 0x7f800000, RZ, 0xfc, !PT ;
        /*13c0*/                   BRA `(.L_x_247) ;
.L_x_245:
        /*13d0*/                   IMAD R8, R5, 0x800000, R8 ;
        /*13e0*/                   BRA `(.L_x_247) ;
.L_x_244:
        /*13f0*/                   LOP3.LUT R0, R0, 0x80000000, R5, 0x48, !PT ;
        /*1400*/                   LOP3.LUT R8, R0, 0x7f800000, RZ, 0xfc, !PT ;
        /*1410*/                   BRA `(.L_x_247) ;
.L_x_243:
        /*1420*/                   LOP3.LUT R8, R0, 0x80000000, R5, 0x48, !PT ;
        /*1430*/                   BRA `(.L_x_247) ;
.L_x_242:
        /*1440*/                   MUFU.RSQ R8, -QNAN  ;
        /*1450*/                   BRA `(.L_x_247) ;
.L_x_241:
        /*1460*/                   FADD.FTZ R8, R0, -1 ;
.L_x_247:
        /*1470*/                   MOV R5, 0x0 ;
        /*1480*/                   RET.REL.NODEC R4 `(fast_mean_delta_kernel) ;
.L_x_248:
        /*1490*/                   BRA `(.L_x_248);
        /*14a0*/                   NOP;
        /*14b0*/                   NOP;
        /*14c0*/                   NOP;
        /*14d0*/                   NOP;
        /*14e0*/                   NOP;
        /*14f0*/                   NOP;
        /*1500*/                   NOP;
        /*1510*/                   NOP;
        /*1520*/                   NOP;
        /*1530*/                   NOP;
        /*1540*/                   NOP;
        /*1550*/                   NOP;
        /*1560*/                   NOP;
        /*1570*/                   NOP;
.L_x_441:


//--------------------- .text.normalize_kernel    --------------------------
	.section	.text.normalize_kernel,"ax",@progbits
	.sectioninfo	@"SHI_REGISTERS=16"
	.align	128
        .global         normalize_kernel
        .type           normalize_kernel,@function
        .size           normalize_kernel,(.L_x_443 - normalize_kernel)
        .other          normalize_kernel,@"STO_CUDA_ENTRY STV_DEFAULT"
normalize_kernel:
.text.normalize_kernel:
        /*0000*/                   IMAD.MOV.U32 R1, RZ, RZ, c[0x0][0x28] ;
        /*0010*/                   S2R R4, SR_CTAID.X ;
        /*0020*/                   S2R R3, SR_TID.X ;
        /*0030*/                   IMAD R4, R4, c[0x0][0x0], R3 ;
        /*0040*/                   ISETP.GE.AND P0, PT, R4, c[0x0][0x160], PT ;
        /*0050*/               @P0 EXIT ;
        /*0060*/                   IABS R7, c[0x0][0x188] ;
        /*0070*/                   ULDC.64 UR4, c[0x0][0x118] ;
        /*0080*/                   IABS R9, c[0x0][0x184] ;
        /*0090*/                   I2F.RP R0, R7 ;
        /*00a0*/                   MUFU.RCP R0, R0 ;
        /*00b0*/                   IADD3 R2, R0, 0xffffffe, RZ ;
        /*00c0*/                   F2I.FTZ.U32.TRUNC.NTZ R3, R2 ;
        /*00d0*/                   IMAD.MOV.U32 R2, RZ, RZ, RZ ;
        /*00e0*/                   IMAD.MOV R6, RZ, RZ, -R3 ;
        /*00f0*/                   IMAD R5, R6, R7, RZ ;
        /*0100*/                   IABS R6, R4 ;
        /*0110*/                   IMAD.HI.U32 R3, R3, R5, R2 ;
        /*0120*/                   I2F.RP R5, R9 ;
        /*0130*/                   IMAD.HI.U32 R0, R3, R6, RZ ;
        /*0140*/                   IMAD.MOV R2, RZ, RZ, -R0 ;
        /*0150*/                   IMAD R2, R7.reuse, R2, R6 ;
        /*0160*/                   MUFU.RCP R5, R5 ;
        /*0170*/                   ISETP.GT.U32.AND P2, PT, R7, R2, PT ;
        /*0180*/              @!P2 IMAD.IADD R2, R2, 0x1, -R7 ;
        /*0190*/              @!P2 IADD3 R0, R0, 0x1, RZ ;
        /*01a0*/                   IADD3 R3, R5, 0xffffffe, RZ ;
        /*01b0*/                   ISETP.GE.U32.AND P0, PT, R2, R7, PT ;
        /*01c0*/                   LOP3.LUT R2, R4, c[0x0][0x188], RZ, 0x3c, !PT ;
        /*01d0*/                   F2I.FTZ.U32.TRUNC.NTZ R3, R3 ;
        /*01e0*/                   ISETP.NE.AND P2, PT, RZ, c[0x0][0x188], PT ;
        /*01f0*/                   ISETP.GE.AND P1, PT, R2, RZ, PT ;
        /*0200*/               @P0 IADD3 R0, R0, 0x1, RZ ;
        /*0210*/                   IMAD.MOV R2, RZ, RZ, -R3 ;
        /*0220*/              @!P1 IMAD.MOV R0, RZ, RZ, -R0 ;
        /*0230*/              @!P2 LOP3.LUT R0, RZ, c[0x0][0x188], RZ, 0x33, !PT ;
        /*0240*/                   IMAD R5, R2, R9, RZ ;
        /*0250*/                   IMAD.MOV.U32 R2, RZ, RZ, RZ ;
        /*0260*/                   IABS R6, R0 ;
        /*0270*/                   ISETP.GE.AND P2, PT, R0, RZ, PT ;
        /*0280*/                   IMAD.HI.U32 R2, R3, R5, R2 ;
        /*0290*/                   IMAD.MOV.U32 R3, RZ, RZ, R6 ;
        /*02a0*/                   IMAD.HI.U32 R2, R2, R3, RZ ;
        /*02b0*/                   IMAD.MOV R2, RZ, RZ, -R2 ;
        /*02c0*/                   IMAD R2, R9, R2, R3 ;
        /*02d0*/                   IMAD.MOV.U32 R3, RZ, RZ, 0x4 ;
        /*02e0*/                   ISETP.GT.U32.AND P0, PT, R9, R2, PT ;
        /*02f0*/              @!P0 IMAD.IADD R2, R2, 0x1, -R9 ;
        /*0300*/                   ISETP.NE.AND P0, PT, RZ, c[0x0][0x184], PT ;
        /*0310*/                   ISETP.GT.U32.AND P1, PT, R9, R2, PT ;
        /*0320*/              @!P1 IMAD.IADD R2, R2, 0x1, -R9 ;
        /*0330*/              @!P2 IMAD.MOV R2, RZ, RZ, -R2 ;
        /*0340*/              @!P0 LOP3.LUT R2, RZ, c[0x0][0x184], RZ, 0x33, !PT ;
        /*0350*/                   IMAD.WIDE R6, R2, R3, c[0x0][0x178] ;
        /*0360*/                   LDG.E R7, [R6.64] ;
        /*0370*/                   IMAD.WIDE R4, R4, R3, c[0x0][0x168] ;
        /*0380*/                   IMAD.WIDE R2, R2, R3, c[0x0][0x170] ;
        /*0390*/                   LDG.E R9, [R4.64] ;
        /*03a0*/                   LDG.E R0, [R2.64] ;
        /*03b0*/                   BSSY B0, `(.L_x_249) ;
        /*03c0*/                   IADD3 R8, R7, -0xd000000, RZ ;
        /*03d0*/                   MUFU.RSQ R10, R7 ;
        /*03e0*/                   ISETP.GT.U32.AND P0, PT, R8, 0x727fffff, PT ;
        /*03f0*/                   FADD R0, -R0, R9 ;
        /*0400*/              @!P0 BRA `(.L_x_250) ;
        /*0410*/                   MOV R10, 0x430 ;
        /*0420*/                   CALL.REL.NOINC `($__internal_9_$__cuda_sm20_sqrt_rn_f32_slowpath) ;
        /*0430*/                   IMAD.MOV.U32 R2, RZ, RZ, R6 ;
        /*0440*/                   BRA `(.L_x_251) ;
.L_x_250:
        /*0450*/                   FMUL.FTZ R2, R7, R10 ;
        /*0460*/                   FMUL.FTZ R6, R10, 0.5 ;
        /*0470*/                   FFMA R3, -R2, R2, R7 ;
        /*0480*/                   FFMA R2, R3, R6, R2 ;
.L_x_251:
        /*0490*/                   BSYNC B0 ;
.L_x_249:
        /*04a0*/                   FADD R7, R2, 9.9999999747524270788e-07 ;
        /*04b0*/                   BSSY B0, `(.L_x_252) ;
        /*04c0*/                   MUFU.RCP R2, R7 ;
        /*04d0*/                   FCHK P0, R0, R7 ;
        /*04e0*/                   FFMA R3, -R7, R2, 1 ;
        /*04f0*/                   FFMA R3, R2, R3, R2 ;
        /*0500*/                   FFMA R2, R0, R3, RZ ;
        /*0510*/                   FFMA R6, -R7, R2, R0 ;
        /*0520*/                   FFMA R3, R3, R6, R2 ;
        /*0530*/              @!P0 BRA `(.L_x_253) ;
        /*0540*/                   MOV R2, 0x560 ;
        /*0550*/                   CALL.REL.NOINC `($__internal_10_$__cuda_sm3x_div_rn_noftz_f32_slowpath) ;
        /*0560*/                   IMAD.MOV.U32 R3, RZ, RZ, R6 ;
.L_x_253:
        /*0570*/                   BSYNC B0 ;
.L_x_252:
        /*0580*/                   STG.E [R4.64], R3 ;
        /*0590*/                   EXIT ;
        .weak           $__internal_9_$__cuda_sm20_sqrt_rn_f32_slowpath
        .type           $__internal_9_$__cuda_sm20_sqrt_rn_f32_slowpath,@function
        .size           $__internal_9_$__cuda_sm20_sqrt_rn_f32_slowpath,($__internal_10_$__cuda_sm3x_div_rn_noftz_f32_slowpath - $__internal_9_$__cuda_sm20_sqrt_rn_f32_slowpath)
$__internal_9_$__cuda_sm20_sqrt_rn_f32_slowpath:
        /*05a0*/                   LOP3.LUT P0, RZ, R7, 0x7fffffff, RZ, 0xc0, !PT ;
        /*05b0*/              @!P0 IMAD.MOV.U32 R3, RZ, RZ, R7 ;
        /*05c0*/              @!P0 BRA `(.L_x_254) ;
        /*05d0*/                   FSETP.GEU.FTZ.AND P0, PT, R7, RZ, PT ;
        /*05e0*/                   IMAD.MOV.U32 R2, RZ, RZ, R7 ;
        /*05f0*/              @!P0 IMAD.MOV.U32 R3, RZ, RZ, 0x7fffffff ;
        /*0600*/              @!P0 BRA `(.L_x_254) ;
        /*0610*/                   FSETP.GTU.FTZ.AND P0, PT, |R2|, +INF , PT ;
        /*0620*/               @P0 FADD.FTZ R3, R2, 1 ;
        /*0630*/               @P0 BRA `(.L_x_254) ;
        /*0640*/                   FSETP.NEU.FTZ.AND P0, PT, |R2|, +INF , PT ;
        /*0650*/               @P0 FFMA R6, R2, 1.84467440737095516160e+19, RZ ;
        /*0660*/               @P0 MUFU.RSQ R3, R6 ;
        /*0670*/               @P0 FMUL.FTZ R7, R6, R3 ;
        /*0680*/               @P0 FMUL.FTZ R9, R3, 0.5 ;
        /*0690*/              @!P0 IMAD.MOV.U32 R3, RZ, RZ, R2 ;
        /*06a0*/               @P0 FADD.FTZ R8, -R7, -RZ ;
        /*06b0*/               @P0 FFMA R8, R7, R8, R6 ;
        /*06c0*/               @P0 FFMA R8, R8, R9, R7 ;
        /*06d0*/               @P0 FMUL.FTZ R3, R8, 2.3283064365386962891e-10 ;
.L_x_254:
        /*06e0*/                   IMAD.MOV.U32 R6, RZ, RZ, R3 ;
        /*06f0*/                   IMAD.MOV.U32 R2, RZ, RZ, R10 ;
        /*0700*/                   IMAD.MOV.U32 R3, RZ, RZ, 0x0 ;
        /*0710*/                   RET.REL.NODEC R2 `(normalize_kernel) ;
        .weak           $__internal_10_$__cuda_sm3x_div_rn_noftz_f32_slowpath
        .type           $__internal_10_$__cuda_sm3x_div_rn_noftz_f32_slowpath,@function
        .size           $__internal_10_$__cuda_sm3x_div_rn_noftz_f32_slowpath,(.L_x_443 - $__internal_10_$__cuda_sm3x_div_rn_noftz_f32_slowpath)
$__internal_10_$__cuda_sm3x_div_rn_noftz_f32_slowpath:
        /*0720*/                   SHF.R.U32.HI R6, RZ, 0x17, R7 ;
        /*0730*/                   BSSY B1, `(.L_x_255) ;
        /*0740*/                   SHF.R.U32.HI R3, RZ, 0x17, R0.reuse ;
        /*0750*/                   LOP3.LUT R12, R6, 0xff, RZ, 0xc0, !PT ;
        /*0760*/                   IMAD.MOV.U32 R6, RZ, RZ, R0 ;
        /*0770*/                   LOP3.LUT R10, R3, 0xff, RZ, 0xc0, !PT ;
        /*0780*/                   IADD3 R11, R12, -0x1, RZ ;
        /*0790*/                   IADD3 R9, R10, -0x1, RZ ;
        /*07a0*/                   ISETP.GT.U32.AND P0, PT, R11, 0xfd, PT ;
        /*07b0*/                   ISETP.GT.U32.OR P0, PT, R9, 0xfd, P0 ;
        /*07c0*/              @!P0 IMAD.MOV.U32 R8, RZ, RZ, RZ ;
        /*07d0*/              @!P0 BRA `(.L_x_256) ;
        /*07e0*/                   FSETP.GTU.FTZ.AND P0, PT, |R0|, +INF , PT ;
        /*07f0*/                   IMAD.MOV.U32 R3, RZ, RZ, R7 ;
        /*0800*/                   FSETP.GTU.FTZ.AND P1, PT, |R7|, +INF , PT ;
        /*0810*/                   PLOP3.LUT P0, PT, P0, P1, PT, 0xa8, 0x0 ;
        /*0820*/               @P0 BRA `(.L_x_257) ;
        /*0830*/                   LOP3.LUT P0, RZ, R7, 0x7fffffff, R6, 0xc8, !PT ;
        /*0840*/              @!P0 BRA `(.L_x_258) ;
        /*0850*/                   FSETP.NEU.FTZ.AND P2, PT, |R0|.reuse, +INF , PT ;
        /*0860*/                   FSETP.NEU.FTZ.AND P1, PT, |R3|, +INF , PT ;
        /*0870*/                   FSETP.NEU.FTZ.AND P0, PT, |R0|, +INF , PT ;
        /*0880*/              @!P1 BRA !P2, `(.L_x_258) ;
        /*0890*/                   LOP3.LUT P2, RZ, R6, 0x7fffffff, RZ, 0xc0, !PT ;
        /*08a0*/                   PLOP3.LUT P1, PT, P1, P2, PT, 0x2a, 0x0 ;
        /*08b0*/               @P1 BRA `(.L_x_259) ;
        /*08c0*/                   LOP3.LUT P1, RZ, R7, 0x7fffffff, RZ, 0xc0, !PT ;
        /*08d0*/                   PLOP3.LUT P0, PT, P0, P1, PT, 0x2a, 0x0 ;
        /*08e0*/               @P0 BRA `(.L_x_260) ;
        /*08f0*/                   ISETP.GE.AND P0, PT, R9, RZ, PT ;
        /*0900*/                   ISETP.GE.AND P1, PT, R11, RZ, PT ;
        /*0910*/               @P0 IMAD.MOV.U32 R8, RZ, RZ, RZ ;
        /*0920*/              @!P0 FFMA R6, R0, 1.84467440737095516160e+19, RZ ;
        /*0930*/              @!P0 IMAD.MOV.U32 R8, RZ, RZ, -0x40 ;
        /*0940*/              @!P1 FFMA R7, R3, 1.84467440737095516160e+19, RZ ;
        /*0950*/              @!P1 IADD3 R8, R8, 0x40, RZ ;
.L_x_256:
        /*0960*/                   LEA R0, R12, 0xc0800000, 0x17 ;
        /*0970*/                   BSSY B2, `(.L_x_261) ;
        /*0980*/                   IADD3 R3, R10, -0x7f, RZ ;
        /*0990*/                   IMAD.IADD R7, R7, 0x1, -R0 ;
        /*09a0*/                   IMAD R0, R3.reuse, -0x800000, R6 ;
        /*09b0*/                   IADD3 R3, R3, 0x7f, -R12 ;
        /*09c0*/                   MUFU.RCP R9, R7 ;
        /*09d0*/                   FADD.FTZ R11, -R7, -RZ ;
        /*09e0*/                   IMAD.IADD R3, R3, 0x1, R8 ;
        /*09f0*/                   FFMA R10, R9, R11, 1 ;
        /*0a00*/                   FFMA R13, R9, R10, R9 ;
        /*0a10*/                   FFMA R6, R0, R13, RZ ;
        /*0a20*/                   FFMA R9, R11, R6, R0 ;
        /*0a30*/                   FFMA R10, R13, R9, R6 ;
        /*0a40*/                   FFMA R11, R11, R10, R0 ;
        /*0a50*/                   FFMA R6, R13, R11, R10 ;
        /*0a60*/                   SHF.R.U32.HI R0, RZ, 0x17, R6 ;
        /*0a70*/                   LOP3.LUT R0, R0, 0xff, RZ, 0xc0, !PT ;
        /*0a80*/                   IMAD.IADD R9, R0, 0x1, R3 ;
        /*0a90*/                   IADD3 R0, R9, -0x1, RZ ;
        /*0aa0*/                   ISETP.GE.U32.AND P0, PT, R0, 0xfe, PT ;
        /*0ab0*/              @!P0 BRA `(.L_x_262) ;
        /*0ac0*/                   ISETP.GT.AND P0, PT, R9, 0xfe, PT ;
        /*0ad0*/               @P0 BRA `(.L_x_263) ;
        /*0ae0*/                   ISETP.GE.AND P0, PT, R9, 0x1, PT ;
        /*0af0*/               @P0 BRA `(.L_x_264) ;
        /*0b00*/                   ISETP.GE.AND P0, PT, R9, -0x18, PT ;
        /*0b10*/                   LOP3.LUT R6, R6, 0x80000000, RZ, 0xc0, !PT ;
        /*0b20*/              @!P0 BRA `(.L_x_264) ;
        /*0b30*/                   FFMA.RZ R0, R13, R11.reuse, R10.reuse ;
        /*0b40*/                   IADD3 R8, R9, 0x20, RZ ;
        /*0b50*/                   FFMA.RM R3, R13, R11.reuse, R10.reuse ;
        /*0b60*/                   ISETP.NE.AND P2, PT, R9, RZ, PT ;
        /*0b70*/                   LOP3.LUT R7, R0, 0x7fffff, RZ, 0xc0, !PT ;
        /*0b80*/                   FFMA.RP R0, R13, R11, R10 ;
        /*0b90*/                   ISETP.NE.AND P1, PT, R9, RZ, PT ;
        /*0ba0*/                   IMAD.MOV R9, RZ, RZ, -R9 ;
        /*0bb0*/                   LOP3.LUT R7, R7, 0x800000, RZ, 0xfc, !PT ;
        /*0bc0*/                   FSETP.NEU.FTZ.AND P0, PT, R0, R3, PT ;
        /*0bd0*/                   SHF.L.U32 R8, R7, R8, RZ ;
        /*0be0*/                   SEL R0, R9, RZ, P2 ;
        /*0bf0*/                   ISETP.NE.AND P1, PT, R8, RZ, P1 ;
        /*0c00*/                   SHF.R.U32.HI R0, RZ, R0, R7 ;
        /*0c10*/                   PLOP3.LUT P0, PT, P0, P1, PT, 0xa8, 0x0 ;
        /*0c20*/                   SHF.R.U32.HI R8, RZ, 0x1, R0 ;
        /*0c30*/                   SEL R3, RZ, 0x1, !P0 ;
        /*0c40*/                   LOP3.LUT R3, R3, 0x1, R8, 0xf8, !PT ;
        /*0c50*/                   LOP3.LUT R3, R3, R0, RZ, 0xc0, !PT ;
        /*0c60*/                   IMAD.IADD R3, R8, 0x1, R3 ;
        /*0c70*/                   LOP3.LUT R6, R3, R6, RZ, 0xfc, !PT ;
        /*0c80*/                   BRA `(.L_x_264) ;
.L_x_263:
        /*0c90*/                   LOP3.LUT R6, R6, 0x80000000, RZ, 0xc0, !PT ;
        /*0ca0*/                   LOP3.LUT R6, R6, 0x7f800000, RZ, 0xfc, !PT ;
        /*0cb0*/                   BRA `(.L_x_264) ;
.L_x_262:
        /*0cc0*/                   IMAD R6, R3, 0x800000, R6 ;
.L_x_264:
        /*0cd0*/                   BSYNC B2 ;
.L_x_261:
        /*0ce0*/                   BRA `(.L_x_265) ;
.L_x_260:
        /*0cf0*/                   LOP3.LUT R6, R7, 0x80000000, R6, 0x48, !PT ;
        /*0d00*/                   LOP3.LUT R6, R6, 0x7f800000, RZ, 0xfc, !PT ;
        /*0d10*/                   BRA `(.L_x_265) ;
.L_x_259:
        /*0d20*/                   LOP3.LUT R6, R7, 0x80000000, R6, 0x48, !PT ;
        /*0d30*/                   BRA `(.L_x_265) ;
.L_x_258:
        /*0d40*/                   MUFU.RSQ R6, -QNAN  ;
        /*0d50*/                   BRA `(.L_x_265) ;
.L_x_257:
        /*0d60*/                   FADD.FTZ R6, R0, R3 ;
.L_x_265:
        /*0d70*/                   BSYNC B1 ;
.L_x_255:
        /*0d80*/                   IMAD.MOV.U32 R3, RZ, RZ, 0x0 ;
        /*0d90*/                   RET.REL.NODEC R2 `(normalize_kernel) ;
.L_x_266:
        /*0da0*/                   BRA `(.L_x_266);
        /*0db0*/                   NOP;
        /*0dc0*/                   NOP;
        /*0dd0*/                   NOP;
        /*0de0*/                   NOP;
        /*0df0*/                   NOP;
        /*0e00*/                   NOP;
        /*0e10*/                   NOP;
        /*0e20*/                   NOP;
        /*0e30*/                   NOP;
        /*0e40*/                   NOP;
        /*0e50*/                   NOP;
        /*0e60*/                   NOP;
        /*0e70*/                   NOP;
.L_x_443:


//--------------------- .text.fast_variance_kernel --------------------------
	.section	.text.fast_variance_kernel,"ax",@progbits
	.sectionflags	@"SHF_BARRIERS=1"
	.sectioninfo	@"SHI_REGISTERS=40"
	.align	128
        .global         fast_variance_kernel
        .type           fast_variance_kernel,@function
        .size           fast_variance_kernel,(.L_x_444 - fast_variance_kernel)
        .other          fast_variance_kernel,@"STO_CUDA_ENTRY STV_DEFAULT"
fast_variance_kernel:
.text.fast_variance_kernel:
        /*0000*/                   IMAD.MOV.U32 R1, RZ, RZ, c[0x0][0x28] ;
        /*0010*/                   S2R R5, SR_CTAID.X ;
        /*0020*/                   ISETP.LT.AND P0, PT, RZ, c[0x0][0x170], PT ;
        /*0030*/                   ULDC.64 UR6, c[0x0][0x118] ;
        /*0040*/              @!P0 MOV R7, RZ ;
        /*0050*/                   SHF.R.S32.HI R4, RZ, 0x1f, R5 ;
        /*0060*/              @!P0 BRA `(.L_x_267) ;
        /*0070*/                   IMAD.MOV.U32 R2, RZ, RZ, 0x4 ;
        /*0080*/                   IMAD.WIDE R2, R5, R2, c[0x0][0x168] ;
        /*0090*/                   LDG.E R0, [R2.64] ;
        /*00a0*/                   MOV R7, RZ ;
        /*00b0*/                   IMAD.MOV.U32 R10, RZ, RZ, RZ ;
        /*00c0*/                   S2R R6, SR_TID.X ;
        /*00d0*/                   LOP3.LUT R8, RZ, R6, RZ, 0x33, !PT ;
        /*00e0*/                   IADD3 R9, R6, 0x100, RZ ;
        /*00f0*/                   IADD3 R8, R8, c[0x0][0x178], RZ ;
        /*0100*/                   IADD3 R11, R6, 0x200, RZ ;
        /*0110*/                   LEA.HI R13, R8, 0x1, RZ, 0x18 ;
        /*0120*/                   IADD3 R12, R6, 0x300, RZ ;
        /*0130*/                   LOP3.LUT R13, R13, 0x3, RZ, 0xc0, !PT ;
.L_x_277:
        /*0140*/                   ISETP.GE.AND P0, PT, R6, c[0x0][0x178], PT ;
        /*0150*/                   BSSY B0, `(.L_x_268) ;
        /*0160*/               @P0 BRA `(.L_x_269) ;
        /*0170*/                   ISETP.NE.AND P1, PT, R13, RZ, PT ;
        /*0180*/                   BSSY B1, `(.L_x_270) ;
        /*0190*/                   ISETP.GE.U32.AND P0, PT, R8, 0x300, PT ;
        /*01a0*/                   IMAD R19, R10, c[0x0][0x174], R5 ;
        /*01b0*/                   MOV R14, R6 ;
        /*01c0*/              @!P1 BRA `(.L_x_271) ;
        /*01d0*/                   IMAD.MOV.U32 R3, RZ, RZ, 0x4 ;
        /*01e0*/                   IMAD R2, R19, c[0x0][0x178], R6 ;
        /*01f0*/                   IMAD.WIDE R2, R2, R3, c[0x0][0x160] ;
        /*0200*/                   LDG.E R15, [R2.64] ;
        /*0210*/                   ISETP.NE.AND P1, PT, R13, 0x1, PT ;
        /*0220*/                   MOV R14, R9 ;
        /*0230*/                   FADD R16, -R0, R15 ;
        /*0240*/                   FFMA R7, R16, R16, R7 ;
        /*0250*/              @!P1 BRA `(.L_x_271) ;
        /*0260*/                   ISETP.NE.AND P1, PT, R13, 0x2, PT ;
        /*0270*/                   LDG.E R15, [R2.64+0x400] ;
        /*0280*/               @P1 LDG.E R17, [R2.64+0x800] ;
        /*0290*/                   IMAD.MOV.U32 R14, RZ, RZ, R11 ;
        /*02a0*/               @P1 MOV R14, R12 ;
        /*02b0*/                   FADD R16, -R0, R15 ;
        /*02c0*/                   FFMA R7, R16, R16, R7 ;
        /*02d0*/               @P1 FADD R16, -R0, R17 ;
        /*02e0*/               @P1 FFMA R7, R16, R16, R7 ;
.L_x_271:
        /*02f0*/                   BSYNC B1 ;
.L_x_270:
        /*0300*/              @!P0 BRA `(.L_x_269) ;
        /*0310*/                   IADD3 R2, -R14, c[0x0][0x178], RZ ;
        /*0320*/                   IMAD.MOV.U32 R3, RZ, RZ, 0x4 ;
        /*0330*/                   BSSY B1, `(.L_x_272) ;
        /*0340*/                   PLOP3.LUT P0, PT, PT, PT, PT, 0x80, 0x0 ;
        /*0350*/                   ISETP.GT.AND P1, PT, R2, 0xc00, PT ;
        /*0360*/                   IMAD R2, R19, c[0x0][0x178], R14 ;
        /*0370*/                   IMAD.WIDE R2, R2, R3, c[0x0][0x160] ;
        /*0380*/              @!P1 BRA `(.L_x_273) ;
        /*0390*/                   MOV R19, c[0x0][0x178] ;
        /*03a0*/                   PLOP3.LUT P0, PT, PT, PT, PT, 0x8, 0x0 ;
        /*03b0*/                   IADD3 R19, R19, -0xc00, RZ ;
.L_x_274:
        /*03c0*/                   LDG.E R18, [R2.64] ;
        /*03d0*/                   LDG.E R20, [R2.64+0x400] ;
        /*03e0*/                   LDG.E R22, [R2.64+0x800] ;
        /*03f0*/                   LDG.E R24, [R2.64+0xc00] ;
        /*0400*/                   LDG.E R16, [R2.64+0x1000] ;
        /*0410*/                   LDG.E R37, [R2.64+0x1400] ;
        /*0420*/                   LDG.E R35, [R2.64+0x1800] ;
        /*0430*/                   LDG.E R33, [R2.64+0x1c00] ;
        /*0440*/                   LDG.E R31, [R2.64+0x2000] ;
        /*0450*/                   LDG.E R29, [R2.64+0x2400] ;
        /*0460*/                   LDG.E R27, [R2.64+0x2800] ;
        /*0470*/                   LDG.E R25, [R2.64+0x2c00] ;
        /*0480*/                   LDG.E R23, [R2.64+0x3000] ;
        /*0490*/                   LDG.E R21, [R2.64+0x3400] ;
        /*04a0*/                   LDG.E R17, [R2.64+0x3800] ;
        /*04b0*/                   LDG.E R15, [R2.64+0x3c00] ;
        /*04c0*/                   IADD3 R14, R14, 0x1000, RZ ;
        /*04d0*/                   ISETP.GE.AND P1, PT, R14, R19, PT ;
        /*04e0*/                   FADD R18, -R0, R18 ;
        /*04f0*/                   FFMA R7, R18, R18, R7 ;
        /*0500*/                   FADD R20, -R0.reuse, R20 ;
        /*0510*/                   FADD R22, -R0, R22 ;
        /*0520*/                   FFMA R7, R20, R20, R7 ;
        /*0530*/                   FADD R24, -R0, R24 ;
        /*0540*/                   FFMA R7, R22, R22, R7 ;
        /*0550*/                   FADD R16, -R0, R16 ;
        /*0560*/                   FFMA R7, R24, R24, R7 ;
        /*0570*/                   FFMA R7, R16, R16, R7 ;
        /*0580*/                   FADD R16, -R0, R37 ;
        /*0590*/                   FFMA R7, R16, R16, R7 ;
        /*05a0*/                   FADD R16, -R0, R35 ;
        /*05b0*/                   FFMA R7, R16, R16, R7 ;
        /*05c0*/                   FADD R16, -R0, R33 ;
        /*05d0*/                   FFMA R7, R16, R16, R7 ;
        /*05e0*/                   FADD R16, -R0, R31 ;
        /*05f0*/                   FFMA R7, R16, R16, R7 ;
        /*0600*/                   FADD R16, -R0, R29 ;
        /*0610*/                   FFMA R7, R16, R16, R7 ;
        /*0620*/                   FADD R16, -R0, R27 ;
        /*0630*/                   FFMA R7, R16, R16, R7 ;
        /*0640*/                   FADD R16, -R0, R25 ;
        /*0650*/                   FFMA R7, R16, R16, R7 ;
        /*0660*/                   FADD R16, -R0, R23 ;
        /*0670*/                   FFMA R7, R16, R16, R7 ;
        /*0680*/                   FADD R16, -R0, R21 ;
        /*0690*/                   FFMA R7, R16, R16, R7 ;
        /*06a0*/                   FADD R16, -R0, R17 ;
        /*06b0*/                   IADD3 R17, P2, R2, 0x4000, RZ ;
        /*06c0*/                   FADD R2, -R0, R15 ;
        /*06d0*/                   FFMA R7, R16, R16, R7 ;
        /*06e0*/                   IMAD.X R3, RZ, RZ, R3, P2 ;
        /*06f0*/                   FFMA R7, R2, R2, R7 ;
        /*0700*/                   MOV R2, R17 ;
        /*0710*/              @!P1 BRA `(.L_x_274) ;
.L_x_273:
        /*0720*/                   BSYNC B1 ;
.L_x_272:
        /*0730*/                   IADD3 R15, -R14, c[0x0][0x178], RZ ;
        /*0740*/                   BSSY B1, `(.L_x_275) ;
        /*0750*/                   ISETP.GT.AND P1, PT, R15, 0x400, PT ;
        /*0760*/              @!P1 BRA `(.L_x_276) ;
        /*0770*/                   LDG.E R15, [R2.64] ;
        /*0780*/                   LDG.E R17, [R2.64+0x400] ;
        /*0790*/                   LDG.E R19, [R2.64+0x800] ;
        /*07a0*/                   LDG.E R21, [R2.64+0xc00] ;
        /*07b0*/                   LDG.E R23, [R2.64+0x1000] ;
        /*07c0*/                   LDG.E R25, [R2.64+0x1400] ;
        /*07d0*/                   LDG.E R27, [R2.64+0x1800] ;
        /*07e0*/                   LDG.E R29, [R2.64+0x1c00] ;
        /*07f0*/                   PLOP3.LUT P0, PT, PT, PT, PT, 0x8, 0x0 ;
        /*0800*/                   IADD3 R14, R14, 0x800, RZ ;
        /*0810*/                   FADD R16, -R0, R15 ;
        /*0820*/                   IADD3 R15, P1, R2, 0x2000, RZ ;
        /*0830*/                   FFMA R7, R16, R16, R7 ;
        /*0840*/                   FADD R16, -R0, R17 ;
        /*0850*/                   IMAD.X R3, RZ, RZ, R3, P1 ;
        /*0860*/                   FFMA R7, R16, R16, R7 ;
        /*0870*/                   FADD R16, -R0, R19 ;
        /*0880*/                   FFMA R7, R16, R16, R7 ;
        /*0890*/                   FADD R16, -R0, R21 ;
        /*08a0*/                   FFMA R7, R16, R16, R7 ;
        /*08b0*/                   FADD R16, -R0, R23 ;
        /*08c0*/                   FFMA R7, R16, R16, R7 ;
        /*08d0*/                   FADD R16, -R0.reuse, R25 ;
        /*08e0*/                   FADD R18, -R0.reuse, R27 ;
        /*08f0*/                   FADD R2, -R0, R29 ;
        /*0900*/                   FFMA R7, R16, R16, R7 ;
        /*0910*/                   FFMA R7, R18, R18, R7 ;
        /*0920*/                   FFMA R7, R2, R2, R7 ;
        /*0930*/                   MOV R2, R15 ;
.L_x_276:
        /*0940*/                   BSYNC B1 ;
.L_x_275:
        /*0950*/                   ISETP.LT.OR P0, PT, R14, c[0x0][0x178], P0 ;
        /*0960*/              @!P0 BRA `(.L_x_269) ;
        /*0970*/                   LDG.E R15, [R2.64] ;
        /*0980*/                   LDG.E R17, [R2.64+0x400] ;
        /*0990*/                   LDG.E R19, [R2.64+0x800] ;
        /*09a0*/                   LDG.E R21, [R2.64+0xc00] ;
        /*09b0*/                   FADD R14, -R0, R15 ;
        /*09c0*/                   FFMA R7, R14, R14, R7 ;
        /*09d0*/                   FADD R14, -R0.reuse, R17 ;
        /*09e0*/                   FADD R16, -R0, R19 ;
        /*09f0*/                   FFMA R7, R14, R14, R7 ;
        /*0a00*/                   FADD R14, -R0, R21 ;
        /*0a10*/                   FFMA R7, R16, R16, R7 ;
        /*0a20*/                   FFMA R7, R14, R14, R7 ;
.L_x_269:
        /*0a30*/                   BSYNC B0 ;
.L_x_268:
        /*0a40*/                   IADD3 R10, R10, 0x1, RZ ;
        /*0a50*/                   ISETP.GE.AND P0, PT, R10, c[0x0][0x170], PT ;
        /*0a60*/              @!P0 BRA `(.L_x_277) ;
.L_x_267:
        /*0a70*/                   S2R R9, SR_TID.X ;
        /*0a80*/                   STS [R9.X4], R7 ;
        /*0a90*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*0aa0*/                   ISETP.GT.AND P0, PT, R9.reuse, 0x7f, PT ;
        /*0ab0*/                   ISETP.GT.AND P1, PT, R9, 0x3f, PT ;
        /*0ac0*/              @!P0 LDS R0, [R9.X4] ;
        /*0ad0*/              @!P0 LDS R3, [R9.X4+0x200] ;
        /*0ae0*/              @!P0 FADD R0, R0, R3 ;
        /*0af0*/              @!P0 STS [R9.X4], R0 ;
        /*0b00*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*0b10*/                   ISETP.GT.AND P0, PT, R9, 0x1f, PT ;
        /*0b20*/              @!P1 LDS R2, [R9.X4] ;
        /*0b30*/              @!P1 LDS R3, [R9.X4+0x100] ;
        /*0b40*/              @!P1 FADD R2, R2, R3 ;
        /*0b50*/              @!P1 STS [R9.X4], R2 ;
        /*0b60*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*0b70*/                   ISETP.GT.AND P1, PT, R9, 0xf, PT ;
        /*0b80*/              @!P0 LDS R3, [R9.X4] ;
        /*0b90*/              @!P0 LDS R6, [R9.X4+0x80] ;
        /*0ba0*/              @!P0 FADD R3, R3, R6 ;
        /*0bb0*/              @!P0 STS [R9.X4], R3 ;
        /*0bc0*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*0bd0*/                   ISETP.GT.AND P0, PT, R9, 0x7, PT ;
        /*0be0*/              @!P1 LDS R0, [R9.X4] ;
        /*0bf0*/              @!P1 LDS R7, [R9.X4+0x40] ;
        /*0c00*/              @!P1 FADD R0, R0, R7 ;
        /*0c10*/              @!P1 STS [R9.X4], R0 ;
        /*0c20*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*0c30*/                   ISETP.GT.AND P1, PT, R9, 0x3, PT ;
        /*0c40*/              @!P0 LDS R2, [R9.X4] ;
        /*0c50*/              @!P0 LDS R7, [R9.X4+0x20] ;
        /*0c60*/              @!P0 FADD R2, R2, R7 ;
        /*0c70*/              @!P0 STS [R9.X4], R2 ;
        /*0c80*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*0c90*/                   ISETP.GT.AND P0, PT, R9, 0x1, PT ;
        /*0ca0*/              @!P1 LDS R3, [R9.X4] ;
        /*0cb0*/              @!P1 LDS R6, [R9.X4+0x10] ;
        /*0cc0*/              @!P1 FADD R3, R3, R6 ;
        /*0cd0*/              @!P1 STS [R9.X4], R3 ;
        /*0ce0*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*0cf0*/                   ISETP.GT.AND P1, PT, R9, RZ, PT ;
        /*0d00*/              @!P0 LDS R0, [R9.X4] ;
        /*0d10*/              @!P0 LDS R7, [R9.X4+0x8] ;
        /*0d20*/              @!P0 FADD R0, R0, R7 ;
        /*0d30*/              @!P0 STS [R9.X4], R0 ;
        /*0d40*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*0d50*/                   ISETP.NE.AND P0, PT, R9, RZ, PT ;
        /*0d60*/              @!P1 LDS R2, [R9.X4] ;
        /*0d70*/              @!P1 LDS R7, [R9.X4+0x4] ;
        /*0d80*/              @!P1 FADD R2, R2, R7 ;
        /*0d90*/              @!P1 STS [R9.X4], R2 ;
        /*0da0*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*0db0*/               @P0 EXIT ;
        /*0dc0*/                   LDS R0, [RZ] ;
        /*0dd0*/                   ULDC UR5, c[0x0][0x178] ;
        /*0de0*/                   ULDC UR4, c[0x0][0x170] ;
        /*0df0*/                   UIMAD UR4, UR5, UR4, -0x1 ;
        /*0e00*/                   I2FP.F32.S32 R3, UR4 ;
        /*0e10*/                   MUFU.RCP R2, R3 ;
        /*0e20*/                   FFMA R7, -R3, R2, 1 ;
        /*0e30*/                   FFMA R7, R2, R7, R2 ;
        /*0e40*/                   FCHK P0, R0, R3 ;
        /*0e50*/                   FFMA R2, R0, R7, RZ ;
        /*0e60*/                   FFMA R6, -R3, R2, R0 ;
        /*0e70*/                   FFMA R7, R7, R6, R2 ;
        /*0e80*/              @!P0 BRA `(.L_x_278) ;
        /*0e90*/                   MOV R2, 0xeb0 ;
        /*0ea0*/                   CALL.REL.NOINC `($__internal_11_$__cuda_sm3x_div_rn_noftz_f32_slowpath) ;
.L_x_278:
        /*0eb0*/                   LEA R2, P0, R5, c[0x0][0x180], 0x2 ;
        /*0ec0*/                   LEA.HI.X R3, R5, c[0x0][0x184], R4, 0x2, P0 ;
        /*0ed0*/                   STG.E [R2.64], R7 ;
        /*0ee0*/                   EXIT ;
        .weak           $__internal_11_$__cuda_sm3x_div_rn_noftz_f32_slowpath
        .type           $__internal_11_$__cuda_sm3x_div_rn_noftz_f32_slowpath,@function
        .size           $__internal_11_$__cuda_sm3x_div_rn_noftz_f32_slowpath,(.L_x_444 - $__internal_11_$__cuda_sm3x_div_rn_noftz_f32_slowpath)
$__internal_11_$__cuda_sm3x_div_rn_noftz_f32_slowpath:
        /*0ef0*/                   SHF.R.U32.HI R7, RZ, 0x17, R3 ;
        /*0f00*/                   IMAD.MOV.U32 R8, RZ, RZ, R0.reuse ;
        /*0f10*/                   SHF.R.U32.HI R6, RZ, 0x17, R0 ;
        /*0f20*/                   LOP3.LUT R7, R7, 0xff, RZ, 0xc0, !PT ;
        /*0f30*/                   LOP3.LUT R6, R6, 0xff, RZ, 0xc0, !PT ;
        /*0f40*/                   IADD3 R12, R7, -0x1, RZ ;
        /*0f50*/                   IADD3 R11, R6, -0x1, RZ ;
        /*0f60*/                   ISETP.GT.U32.AND P0, PT, R12, 0xfd, PT ;
        /*0f70*/                   MOV R9, R3 ;
        /*0f80*/                   ISETP.GT.U32.OR P0, PT, R11, 0xfd, P0 ;
        /*0f90*/              @!P0 IMAD.MOV.U32 R10, RZ, RZ, RZ ;
        /*0fa0*/              @!P0 BRA `(.L_x_279) ;
        /*0fb0*/                   FSETP.GTU.FTZ.AND P0, PT, |R0|, +INF , PT ;
        /*0fc0*/                   FSETP.GTU.FTZ.AND P1, PT, |R3|, +INF , PT ;
        /*0fd0*/                   PLOP3.LUT P0, PT, P0, P1, PT, 0xa8, 0x0 ;
        /*0fe0*/               @P0 BRA `(.L_x_280) ;
        /*0ff0*/                   LOP3.LUT P0, RZ, R9, 0x7fffffff, R8, 0xc8, !PT ;
        /*1000*/              @!P0 BRA `(.L_x_281) ;
        /*1010*/                   FSETP.NEU.FTZ.AND P2, PT, |R0|.reuse, +INF , PT ;
        /*1020*/                   FSETP.NEU.FTZ.AND P1, PT, |R3|, +INF , PT ;
        /*1030*/                   FSETP.NEU.FTZ.AND P0, PT, |R0|, +INF , PT ;
        /*1040*/              @!P1 BRA !P2, `(.L_x_281) ;
        /*1050*/                   LOP3.LUT P2, RZ, R8, 0x7fffffff, RZ, 0xc0, !PT ;
        /*1060*/                   PLOP3.LUT P1, PT, P1, P2, PT, 0x2a, 0x0 ;
        /*1070*/               @P1 BRA `(.L_x_282) ;
        /*1080*/                   LOP3.LUT P1, RZ, R9, 0x7fffffff, RZ, 0xc0, !PT ;
        /*1090*/                   PLOP3.LUT P0, PT, P0, P1, PT, 0x2a, 0x0 ;
        /*10a0*/               @P0 BRA `(.L_x_283) ;
        /*10b0*/                   ISETP.GE.AND P0, PT, R11, RZ, PT ;
        /*10c0*/                   ISETP.GE.AND P1, PT, R12, RZ, PT ;
        /*10d0*/               @P0 MOV R10, RZ ;
        /*10e0*/              @!P0 IMAD.MOV.U32 R10, RZ, RZ, -0x40 ;
        /*10f0*/              @!P0 FFMA R8, R0, 1.84467440737095516160e+19, RZ ;
        /*1100*/              @!P1 FFMA R9, R3, 1.84467440737095516160e+19, RZ ;
        /*1110*/              @!P1 IADD3 R10, R10, 0x40, RZ ;
.L_x_279:
        /*1120*/                   LEA R0, R7, 0xc0800000, 0x17 ;
        /*1130*/                   IADD3 R6, R6, -0x7f, RZ ;
        /*1140*/                   IADD3 R9, -R0, R9, RZ ;
        /*1150*/                   IADD3 R7, R6.reuse, 0x7f, -R7 ;
        /*1160*/                   IMAD R0, R6, -0x800000, R8 ;
        /*1170*/                   MUFU.RCP R3, R9 ;
        /*1180*/                   FADD.FTZ R11, -R9, -RZ ;
        /*1190*/                   IMAD.IADD R7, R7, 0x1, R10 ;
        /*11a0*/                   FFMA R12, R3, R11, 1 ;
        /*11b0*/                   FFMA R12, R3, R12, R3 ;
        /*11c0*/                   FFMA R3, R0, R12, RZ ;
        /*11d0*/                   FFMA R8, R11, R3, R0 ;
        /*11e0*/                   FFMA R13, R12, R8, R3 ;
        /*11f0*/                   FFMA R8, R11, R13, R0 ;
        /*1200*/                   FFMA R3, R12, R8, R13 ;
        /*1210*/                   SHF.R.U32.HI R0, RZ, 0x17, R3 ;
        /*1220*/                   LOP3.LUT R0, R0, 0xff, RZ, 0xc0, !PT ;
        /*1230*/                   IADD3 R10, R0, R7, RZ ;
        /*1240*/                   IADD3 R0, R10, -0x1, RZ ;
        /*1250*/                   ISETP.GE.U32.AND P0, PT, R0, 0xfe, PT ;
        /*1260*/              @!P0 BRA `(.L_x_284) ;
        /*1270*/                   ISETP.GT.AND P0, PT, R10, 0xfe, PT ;
        /*1280*/               @P0 BRA `(.L_x_285) ;
        /*1290*/                   ISETP.GE.AND P0, PT, R10, 0x1, PT ;
        /*12a0*/               @P0 BRA `(.L_x_286) ;
        /*12b0*/                   ISETP.GE.AND P0, PT, R10, -0x18, PT ;
        /*12c0*/                   LOP3.LUT R3, R3, 0x80000000, RZ, 0xc0, !PT ;
        /*12d0*/              @!P0 BRA `(.L_x_286) ;
        /*12e0*/                   FFMA.RZ R0, R12, R8.reuse, R13.reuse ;
        /*12f0*/                   IADD3 R9, R10, 0x20, RZ ;
        /*1300*/                   FFMA.RM R7, R12, R8.reuse, R13.reuse ;
        /*1310*/                   ISETP.NE.AND P2, PT, R10, RZ, PT ;
        /*1320*/                   LOP3.LUT R6, R0, 0x7fffff, RZ, 0xc0, !PT ;
        /*1330*/                   FFMA.RP R0, R12, R8, R13 ;
        /*1340*/                   IMAD.MOV R8, RZ, RZ, -R10 ;
        /*1350*/                   ISETP.NE.AND P1, PT, R10, RZ, PT ;
        /*1360*/                   LOP3.LUT R6, R6, 0x800000, RZ, 0xfc, !PT ;
        /*1370*/                   FSETP.NEU.FTZ.AND P0, PT, R0, R7, PT ;
        /*1380*/                   SHF.L.U32 R9, R6, R9, RZ ;
        /*1390*/                   SEL R7, R8, RZ, P2 ;
        /*13a0*/                   ISETP.NE.AND P1, PT, R9, RZ, P1 ;
        /*13b0*/                   SHF.R.U32.HI R7, RZ, R7, R6 ;
        /*13c0*/                   PLOP3.LUT P0, PT, P0, P1, PT, 0xa8, 0x0 ;
        /*13d0*/                   SHF.R.U32.HI R9, RZ, 0x1, R7 ;
        /*13e0*/                   SEL R0, RZ, 0x1, !P0 ;
        /*13f0*/                   LOP3.LUT R0, R0, 0x1, R9, 0xf8, !PT ;
        /*1400*/                   LOP3.LUT R0, R0, R7, RZ, 0xc0, !PT ;
        /*1410*/                   IADD3 R0, R9, R0, RZ ;
        /*1420*/                   LOP3.LUT R3, R0, R3, RZ, 0xfc, !PT ;
        /*1430*/                   BRA `(.L_x_286) ;
.L_x_285:
        /*1440*/                   LOP3.LUT R3, R3, 0x80000000, RZ, 0xc0, !PT ;
        /*1450*/                   LOP3.LUT R3, R3, 0x7f800000, RZ, 0xfc, !PT ;
        /*1460*/                   BRA `(.L_x_286) ;
.L_x_284:
        /*1470*/                   IMAD R3, R7, 0x800000, R3 ;
        /*1480*/                   BRA `(.L_x_286) ;
.L_x_283:
        /*1490*/                   LOP3.LUT R3, R9, 0x80000000, R8, 0x48, !PT ;
        /*14a0*/                   LOP3.LUT R3, R3, 0x7f800000, RZ, 0xfc, !PT ;
        /*14b0*/                   BRA `(.L_x_286) ;
.L_x_282:
        /*14c0*/                   LOP3.LUT R3, R9, 0x80000000, R8, 0x48, !PT ;
        /*14d0*/                   BRA `(.L_x_286) ;
.L_x_281:
        /*14e0*/                   MUFU.RSQ R3, -QNAN  ;
        /*14f0*/                   BRA `(.L_x_286) ;
.L_x_280:
        /*1500*/                   FADD.FTZ R3, R0, R3 ;
.L_x_286:
        /*1510*/                   MOV R7, R3 ;
        /*1520*/                   IMAD.MOV.U32 R3, RZ, RZ, 0x0 ;
        /*1530*/                   RET.REL.NODEC R2 `(fast_variance_kernel) ;
.L_x_287:
        /*1540*/                   BRA `(.L_x_287);
        /*1550*/                   NOP;
        /*1560*/                   NOP;
        /*1570*/                   NOP;
        /*1580*/                   NOP;
        /*1590*/                   NOP;
        /*15a0*/                   NOP;
        /*15b0*/                   NOP;
        /*15c0*/                   NOP;
        /*15d0*/                   NOP;
        /*15e0*/                   NOP;
        /*15f0*/                   NOP;
.L_x_444:


//--------------------- .text.fast_mean_kernel    --------------------------
	.section	.text.fast_mean_kernel,"ax",@progbits
	.sectionflags	@"SHF_BARRIERS=1"
	.sectioninfo	@"SHI_REGISTERS=39"
	.align	128
        .global         fast_mean_kernel
        .type           fast_mean_kernel,@function
        .size           fast_mean_kernel,(.L_x_445 - fast_mean_kernel)
        .other          fast_mean_kernel,@"STO_CUDA_ENTRY STV_DEFAULT"
fast_mean_kernel:
.text.fast_mean_kernel:
        /*0000*/                   IMAD.MOV.U32 R1, RZ, RZ, c[0x0][0x28] ;
        /*0010*/                   S2R R4, SR_CTAID.X ;
        /*0020*/                   ISETP.LT.AND P0, PT, RZ, c[0x0][0x168], PT ;
        /*0030*/                   ULDC.64 UR6, c[0x0][0x118] ;
        /*0040*/              @!P0 IMAD.MOV.U32 R10, RZ, RZ, RZ ;
        /*0050*/              @!P0 BRA `(.L_x_288) ;
        /*0060*/                   S2R R0, SR_TID.X ;
        /*0070*/                   IMAD.MOV.U32 R10, RZ, RZ, RZ ;
        /*0080*/                   IMAD.MOV.U32 R7, RZ, RZ, RZ ;
        /*0090*/                   LOP3.LUT R5, RZ, R0, RZ, 0x33, !PT ;
        /*00a0*/                   IADD3 R6, R0.reuse, 0x100, RZ ;
        /*00b0*/                   IADD3 R5, R5, c[0x0][0x170], RZ ;
        /*00c0*/                   IADD3 R8, R0, 0x200, RZ ;
        /*00d0*/                   LEA.HI R9, R5, 0x1, RZ, 0x18 ;
        /*00e0*/                   IADD3 R20, R0, 0x300, RZ ;
        /*00f0*/                   LOP3.LUT R9, R9, 0x3, RZ, 0xc0, !PT ;
.L_x_298:
        /*0100*/                   ISETP.GE.AND P0, PT, R0, c[0x0][0x170], PT ;
        /*0110*/                   BSSY B0, `(.L_x_289) ;
        /*0120*/               @P0 BRA `(.L_x_290) ;
        /*0130*/                   ISETP.NE.AND P1, PT, R9, RZ, PT ;
        /*0140*/                   BSSY B1, `(.L_x_291) ;
        /*0150*/                   ISETP.GE.U32.AND P0, PT, R5, 0x300, PT ;
        /*0160*/                   IMAD R12, R7, c[0x0][0x16c], R4 ;
        /*0170*/                   IMAD.MOV.U32 R11, RZ, RZ, R0 ;
        /*0180*/              @!P1 BRA `(.L_x_292) ;
        /*0190*/                   IMAD.MOV.U32 R3, RZ, RZ, 0x4 ;
        /*01a0*/                   IMAD R2, R12, c[0x0][0x170], R0 ;
        /*01b0*/                   IMAD.WIDE R2, R2, R3, c[0x0][0x160] ;
        /*01c0*/                   LDG.E R13, [R2.64] ;
        /*01d0*/                   ISETP.NE.AND P1, PT, R9, 0x1, PT ;
        /*01e0*/                   IMAD.MOV.U32 R11, RZ, RZ, R6 ;
        /*01f0*/                   FADD R10, R10, R13 ;
        /*0200*/              @!P1 BRA `(.L_x_292) ;
        /*0210*/                   ISETP.NE.AND P1, PT, R9, 0x2, PT ;
        /*0220*/                   LDG.E R13, [R2.64+0x400] ;
        /*0230*/               @P1 LDG.E R15, [R2.64+0x800] ;
        /*0240*/                   IMAD.MOV.U32 R11, RZ, RZ, R8 ;
        /*0250*/               @P1 IMAD.MOV.U32 R11, RZ, RZ, R20 ;
        /*0260*/                   FADD R10, R10, R13 ;
        /*0270*/               @P1 FADD R10, R10, R15 ;
.L_x_292:
        /*0280*/                   BSYNC B1 ;
.L_x_291:
        /*0290*/              @!P0 BRA `(.L_x_290) ;
        /*02a0*/                   IADD3 R2, -R11, c[0x0][0x170], RZ ;
        /*02b0*/                   IMAD.MOV.U32 R3, RZ, RZ, 0x4 ;
        /*02c0*/                   BSSY B1, `(.L_x_293) ;
        /*02d0*/                   PLOP3.LUT P0, PT, PT, PT, PT, 0x80, 0x0 ;
        /*02e0*/                   ISETP.GT.AND P1, PT, R2, 0xc00, PT ;
        /*02f0*/                   IMAD R2, R12, c[0x0][0x170], R11 ;
        /*0300*/                   IMAD.WIDE R2, R2, R3, c[0x0][0x160] ;
        /*0310*/              @!P1 BRA `(.L_x_294) ;
        /*0320*/                   IMAD.MOV.U32 R14, RZ, RZ, c[0x0][0x170] ;
        /*0330*/                   PLOP3.LUT P0, PT, PT, PT, PT, 0x8, 0x0 ;
        /*0340*/                   IADD3 R14, R14, -0xc00, RZ ;
.L_x_295:
        /*0350*/                   LDG.E R21, [R2.64] ;
        /*0360*/                   LDG.E R22, [R2.64+0x400] ;
        /*0370*/                   LDG.E R24, [R2.64+0x800] ;
        /*0380*/                   LDG.E R26, [R2.64+0xc00] ;
        /*0390*/                   LDG.E R28, [R2.64+0x1000] ;
        /*03a0*/                   LDG.E R30, [R2.64+0x1400] ;
        /*03b0*/                   LDG.E R32, [R2.64+0x1800] ;
        /*03c0*/                   LDG.E R34, [R2.64+0x1c00] ;
        /*03d0*/                   LDG.E R36, [R2.64+0x2000] ;
        /*03e0*/                   LDG.E R19, [R2.64+0x2400] ;
        /*03f0*/                   LDG.E R18, [R2.64+0x2800] ;
        /*0400*/                   LDG.E R17, [R2.64+0x2c00] ;
        /*0410*/                   LDG.E R16, [R2.64+0x3000] ;
        /*0420*/                   LDG.E R13, [R2.64+0x3400] ;
        /*0430*/                   LDG.E R15, [R2.64+0x3800] ;
        /*0440*/                   LDG.E R12, [R2.64+0x3c00] ;
        /*0450*/                   IADD3 R11, R11, 0x1000, RZ ;
        /*0460*/                   ISETP.GE.AND P1, PT, R11, R14, PT ;
        /*0470*/                   IADD3 R2, P2, R2, 0x4000, RZ ;
        /*0480*/                   IMAD.X R3, RZ, RZ, R3, P2 ;
        /*0490*/                   FADD R21, R21, R10 ;
        /*04a0*/                   FADD R21, R21, R22 ;
        /*04b0*/                   FADD R21, R21, R24 ;
        /*04c0*/                   FADD R21, R21, R26 ;
        /*04d0*/                   FADD R21, R21, R28 ;
        /*04e0*/                   FADD R21, R21, R30 ;
        /*04f0*/                   FADD R21, R21, R32 ;
        /*0500*/                   FADD R21, R21, R34 ;
        /*0510*/                   FADD R36, R21, R36 ;
        /*0520*/                   FADD R19, R36, R19 ;
        /*0530*/                   FADD R18, R19, R18 ;
        /*0540*/                   FADD R17, R18, R17 ;
        /*0550*/                   FADD R16, R17, R16 ;
        /*0560*/                   FADD R16, R16, R13 ;
        /*0570*/                   FADD R15, R16, R15 ;
        /*0580*/                   FADD R10, R15, R12 ;
        /*0590*/              @!P1 BRA `(.L_x_295) ;
.L_x_294:
        /*05a0*/                   BSYNC B1 ;
.L_x_293:
        /*05b0*/                   IADD3 R12, -R11, c[0x0][0x170], RZ ;
        /*05c0*/                   BSSY B1, `(.L_x_296) ;
        /*05d0*/                   ISETP.GT.AND P1, PT, R12, 0x400, PT ;
        /*05e0*/              @!P1 BRA `(.L_x_297) ;
        /*05f0*/                   LDG.E R13, [R2.64] ;
        /*0600*/                   LDG.E R12, [R2.64+0x400] ;
        /*0610*/                   LDG.E R15, [R2.64+0x800] ;
        /*0620*/                   LDG.E R17, [R2.64+0xc00] ;
        /*0630*/                   LDG.E R19, [R2.64+0x1000] ;
        /*0640*/                   LDG.E R21, [R2.64+0x1400] ;
        /*0650*/                   LDG.E R23, [R2.64+0x1800] ;
        /*0660*/                   LDG.E R25, [R2.64+0x1c00] ;
        /*0670*/                   PLOP3.LUT P0, PT, PT, PT, PT, 0x8, 0x0 ;
        /*0680*/                   IADD3 R11, R11, 0x800, RZ ;
        /*0690*/                   FADD R13, R10, R13 ;
        /*06a0*/                   FADD R12, R13, R12 ;
        /*06b0*/                   IADD3 R13, P1, R2, 0x2000, RZ ;
        /*06c0*/                   FADD R12, R12, R15 ;
        /*06d0*/                   IMAD.X R14, RZ, RZ, R3, P1 ;
        /*06e0*/                   FADD R12, R12, R17 ;
        /*06f0*/                   IMAD.MOV.U32 R2, RZ, RZ, R13 ;
        /*0700*/                   IMAD.MOV.U32 R3, RZ, RZ, R14 ;
        /*0710*/                   FADD R12, R12, R19 ;
        /*0720*/                   FADD R12, R12, R21 ;
        /*0730*/                   FADD R12, R12, R23 ;
        /*0740*/                   FADD R10, R12, R25 ;
.L_x_297:
        /*0750*/                   BSYNC B1 ;
.L_x_296:
        /*0760*/                   ISETP.LT.OR P0, PT, R11, c[0x0][0x170], P0 ;
        /*0770*/              @!P0 BRA `(.L_x_290) ;
        /*0780*/                   LDG.E R11, [R2.64] ;
        /*0790*/                   LDG.E R12, [R2.64+0x400] ;
        /*07a0*/                   LDG.E R14, [R2.64+0x800] ;
        /*07b0*/                   LDG.E R16, [R2.64+0xc00] ;
        /*07c0*/                   FADD R11, R10, R11 ;
        /*07d0*/                   FADD R11, R11, R12 ;
        /*07e0*/                   FADD R11, R11, R14 ;
        /*07f0*/                   FADD R10, R11, R16 ;
.L_x_290:
        /*0800*/                   BSYNC B0 ;
.L_x_289:
        /*0810*/                   IADD3 R7, R7, 0x1, RZ ;
        /*0820*/                   ISETP.GE.AND P0, PT, R7, c[0x0][0x168], PT ;
        /*0830*/              @!P0 BRA `(.L_x_298) ;
.L_x_288:
        /*0840*/                   S2R R7, SR_TID.X ;
        /*0850*/                   STS [R7.X4], R10 ;
        /*0860*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*0870*/                   ISETP.GT.AND P0, PT, R7.reuse, 0x7f, PT ;
        /*0880*/                   ISETP.GT.AND P1, PT, R7, 0x3f, PT ;
        /*0890*/              @!P0 LDS R0, [R7.X4] ;
        /*08a0*/              @!P0 LDS R3, [R7.X4+0x200] ;
        /*08b0*/              @!P0 FADD R0, R0, R3 ;
        /*08c0*/              @!P0 STS [R7.X4], R0 ;
        /*08d0*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*08e0*/                   ISETP.GT.AND P0, PT, R7, 0x1f, PT ;
        /*08f0*/              @!P1 LDS R2, [R7.X4] ;
        /*0900*/              @!P1 LDS R3, [R7.X4+0x100] ;
        /*0910*/              @!P1 FADD R2, R2, R3 ;
        /*0920*/              @!P1 STS [R7.X4], R2 ;
        /*0930*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*0940*/                   ISETP.GT.AND P1, PT, R7, 0xf, PT ;
        /*0950*/              @!P0 LDS R3, [R7.X4] ;
        /*0960*/              @!P0 LDS R6, [R7.X4+0x80] ;
        /*0970*/              @!P0 FADD R3, R3, R6 ;
        /*0980*/              @!P0 STS [R7.X4], R3 ;
        /*0990*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*09a0*/                   ISETP.GT.AND P0, PT, R7, 0x7, PT ;
        /*09b0*/              @!P1 LDS R0, [R7.X4] ;
        /*09c0*/              @!P1 LDS R5, [R7.X4+0x40] ;
        /*09d0*/              @!P1 FADD R0, R0, R5 ;
        /*09e0*/              @!P1 STS [R7.X4], R0 ;
        /*09f0*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*0a00*/                   ISETP.GT.AND P1, PT, R7, 0x3, PT ;
        /*0a10*/              @!P0 LDS R2, [R7.X4] ;
        /*0a20*/              @!P0 LDS R5, [R7.X4+0x20] ;
        /*0a30*/              @!P0 FADD R2, R2, R5 ;
        /*0a40*/              @!P0 STS [R7.X4], R2 ;
        /*0a50*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*0a60*/                   ISETP.GT.AND P0, PT, R7, 0x1, PT ;
        /*0a70*/              @!P1 LDS R3, [R7.X4] ;
        /*0a80*/              @!P1 LDS R6, [R7.X4+0x10] ;
        /*0a90*/              @!P1 FADD R3, R3, R6 ;
        /*0aa0*/              @!P1 STS [R7.X4], R3 ;
        /*0ab0*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*0ac0*/                   ISETP.GT.AND P1, PT, R7, RZ, PT ;
        /*0ad0*/              @!P0 LDS R0, [R7.X4] ;
        /*0ae0*/              @!P0 LDS R5, [R7.X4+0x8] ;
        /*0af0*/              @!P0 FADD R0, R0, R5 ;
        /*0b00*/              @!P0 STS [R7.X4], R0 ;
        /*0b10*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*0b20*/                   ISETP.NE.AND P0, PT, R7, RZ, PT ;
        /*0b30*/              @!P1 LDS R2, [R7.X4] ;
        /*0b40*/              @!P1 LDS R5, [R7.X4+0x4] ;
        /*0b50*/              @!P1 FADD R2, R2, R5 ;
        /*0b60*/              @!P1 STS [R7.X4], R2 ;
        /*0b70*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*0b80*/               @P0 EXIT ;
        /*0b90*/                   LDS R0, [RZ] ;
        /*0ba0*/                   ULDC UR4, c[0x0][0x170] ;
        /*0bb0*/                   ULDC UR5, c[0x0][0x168] ;
        /*0bc0*/                   UIMAD UR4, UR4, UR5, URZ ;
        /*0bd0*/                   I2FP.F32.S32 R3, UR4 ;
        /*0be0*/                   MUFU.RCP R2, R3 ;
        /*0bf0*/                   FFMA R5, -R3, R2, 1 ;
        /*0c00*/                   FFMA R5, R2, R5, R2 ;
        /*0c10*/                   FCHK P0, R0, R3 ;
        /*0c20*/                   FFMA R2, R0, R5, RZ ;
        /*0c30*/                   FFMA R6, -R3, R2, R0 ;
        /*0c40*/                   FFMA R7, R5, R6, R2 ;
        /*0c50*/              @!P0 BRA `(.L_x_299) ;
        /*0c60*/                   MOV R2, 0xc80 ;
        /*0c70*/                   CALL.REL.NOINC `($__internal_12_$__cuda_sm3x_div_rn_noftz_f32_slowpath) ;
.L_x_299:
        /*0c80*/                   IMAD.MOV.U32 R5, RZ, RZ, 0x4 ;
        /*0c90*/                   IMAD.WIDE R4, R4, R5, c[0x0][0x178] ;
        /*0ca0*/                   STG.E [R4.64], R7 ;
        /*0cb0*/                   EXIT ;
        .weak           $__internal_12_$__cuda_sm3x_div_rn_noftz_f32_slowpath
        .type           $__internal_12_$__cuda_sm3x_div_rn_noftz_f32_slowpath,@function
        .size           $__internal_12_$__cuda_sm3x_div_rn_noftz_f32_slowpath,(.L_x_445 - $__internal_12_$__cuda_sm3x_div_rn_noftz_f32_slowpath)
$__internal_12_$__cuda_sm3x_div_rn_noftz_f32_slowpath:
        /*0cc0*/                   SHF.R.U32.HI R6, RZ, 0x17, R3.reuse ;
        /*0cd0*/                   IMAD.MOV.U32 R7, RZ, RZ, R0.reuse ;
        /*0ce0*/                   SHF.R.U32.HI R5, RZ, 0x17, R0 ;
        /*0cf0*/                   IMAD.MOV.U32 R8, RZ, RZ, R3 ;
        /*0d00*/                   LOP3.LUT R6, R6, 0xff, RZ, 0xc0, !PT ;
        /*0d10*/                   LOP3.LUT R5, R5, 0xff, RZ, 0xc0, !PT ;
        /*0d20*/                   IADD3 R11, R6, -0x1, RZ ;
        /*0d30*/                   IADD3 R10, R5, -0x1, RZ ;
        /*0d40*/                   ISETP.GT.U32.AND P0, PT, R11, 0xfd, PT ;
        /*0d50*/                   ISETP.GT.U32.OR P0, PT, R10, 0xfd, P0 ;
        /*0d60*/              @!P0 IMAD.MOV.U32 R9, RZ, RZ, RZ ;
        /*0d70*/              @!P0 BRA `(.L_x_300) ;
        /*0d80*/                   FSETP.GTU.FTZ.AND P0, PT, |R0|, +INF , PT ;
        /*0d90*/                   FSETP.GTU.FTZ.AND P1, PT, |R3|, +INF , PT ;
        /*0da0*/                   PLOP3.LUT P0, PT, P0, P1, PT, 0xa8, 0x0 ;
        /*0db0*/               @P0 BRA `(.L_x_301) ;
        /*0dc0*/                   LOP3.LUT P0, RZ, R8, 0x7fffffff, R7, 0xc8, !PT ;
        /*0dd0*/              @!P0 BRA `(.L_x_302) ;
        /*0de0*/                   FSETP.NEU.FTZ.AND P2, PT, |R0|.reuse, +INF , PT ;
        /*0df0*/                   FSETP.NEU.FTZ.AND P1, PT, |R3|, +INF , PT ;
        /*0e00*/                   FSETP.NEU.FTZ.AND P0, PT, |R0|, +INF , PT ;
        /*0e10*/              @!P1 BRA !P2, `(.L_x_302) ;
        /*0e20*/                   LOP3.LUT P2, RZ, R7, 0x7fffffff, RZ, 0xc0, !PT ;
        /*0e30*/                   PLOP3.LUT P1, PT, P1, P2, PT, 0x2a, 0x0 ;
        /*0e40*/               @P1 BRA `(.L_x_303) ;
        /*0e50*/                   LOP3.LUT P1, RZ, R8, 0x7fffffff, RZ, 0xc0, !PT ;
        /*0e60*/                   PLOP3.LUT P0, PT, P0, P1, PT, 0x2a, 0x0 ;
        /*0e70*/               @P0 BRA `(.L_x_304) ;
        /*0e80*/                   ISETP.GE.AND P0, PT, R10, RZ, PT ;
        /*0e90*/                   ISETP.GE.AND P1, PT, R11, RZ, PT ;
        /*0ea0*/               @P0 IMAD.MOV.U32 R9, RZ, RZ, RZ ;
        /*0eb0*/              @!P0 FFMA R7, R0, 1.84467440737095516160e+19, RZ ;
        /*0ec0*/              @!P0 IMAD.MOV.U32 R9, RZ, RZ, -0x40 ;
        /*0ed0*/              @!P1 FFMA R8, R3, 1.84467440737095516160e+19, RZ ;
        /*0ee0*/              @!P1 IADD3 R9, R9, 0x40, RZ ;
.L_x_300:
        /*0ef0*/                   LEA R3, R6, 0xc0800000, 0x17 ;
        /*0f00*/                   IADD3 R5, R5, -0x7f, RZ ;
        /*0f10*/                   IMAD.IADD R3, R8, 0x1, -R3 ;
        /*0f20*/                   IADD3 R6, R5.reuse, 0x7f, -R6 ;
        /*0f30*/                   IMAD R0, R5, -0x800000, R7 ;
        /*0f40*/                   MUFU.RCP R8, R3 ;
        /*0f50*/                   FADD.FTZ R11, -R3, -RZ ;
        /*0f60*/                   IMAD.IADD R6, R6, 0x1, R9 ;
        /*0f70*/                   FFMA R13, R8, R11, 1 ;
        /*0f80*/                   FFMA R10, R8, R13, R8 ;
        /*0f90*/                   FFMA R7, R0, R10, RZ ;
        /*0fa0*/                   FFMA R8, R11, R7, R0 ;
        /*0fb0*/                   FFMA R13, R10, R8, R7 ;
        /*0fc0*/                   FFMA R8, R11, R13, R0 ;
        /*0fd0*/                   FFMA R7, R10, R8, R13 ;
        /*0fe0*/                   SHF.R.U32.HI R0, RZ, 0x17, R7 ;
        /*0ff0*/                   LOP3.LUT R0, R0, 0xff, RZ, 0xc0, !PT ;
        /*1000*/                   IMAD.IADD R9, R0, 0x1, R6 ;
        /*1010*/                   IADD3 R0, R9, -0x1, RZ ;
        /*1020*/                   ISETP.GE.U32.AND P0, PT, R0, 0xfe, PT ;
        /*1030*/              @!P0 BRA `(.L_x_305) ;
        /*1040*/                   ISETP.GT.AND P0, PT, R9, 0xfe, PT ;
        /*1050*/               @P0 BRA `(.L_x_306) ;
        /*1060*/                   ISETP.GE.AND P0, PT, R9, 0x1, PT ;
        /*1070*/               @P0 BRA `(.L_x_307) ;
        /*1080*/                   ISETP.GE.AND P0, PT, R9, -0x18, PT ;
        /*1090*/                   LOP3.LUT R7, R7, 0x80000000, RZ, 0xc0, !PT ;
        /*10a0*/              @!P0 BRA `(.L_x_307) ;
        /*10b0*/                   FFMA.RZ R0, R10.reuse, R8.reuse, R13.reuse ;
        /*10c0*/                   IADD3 R6, R9.reuse, 0x20, RZ ;
        /*10d0*/                   FFMA.RM R3, R10, R8.reuse, R13.reuse ;
        /*10e0*/                   ISETP.NE.AND P2, PT, R9.reuse, RZ, PT ;
        /*10f0*/                   LOP3.LUT R5, R0, 0x7fffff, RZ, 0xc0, !PT ;
        /*1100*/                   FFMA.RP R0, R10, R8, R13 ;
        /*1110*/                   IMAD.MOV R8, RZ, RZ, -R9 ;
        /*1120*/                   ISETP.NE.AND P1, PT, R9, RZ, PT ;
        /*1130*/                   LOP3.LUT R5, R5, 0x800000, RZ, 0xfc, !PT ;
        /*1140*/                   FSETP.NEU.FTZ.AND P0, PT, R0, R3, PT ;
        /*1150*/                   SHF.L.U32 R6, R5, R6, RZ ;
        /*1160*/                   SEL R0, R8, RZ, P2 ;
        /*1170*/                   ISETP.NE.AND P1, PT, R6, RZ, P1 ;
        /*1180*/                   SHF.R.U32.HI R0, RZ, R0, R5 ;
        /*1190*/                   PLOP3.LUT P0, PT, P0, P1, PT, 0xa8, 0x0 ;
        /*11a0*/                   SHF.R.U32.HI R6, RZ, 0x1, R0 ;
        /*11b0*/                   SEL R3, RZ, 0x1, !P0 ;
        /*11c0*/                   LOP3.LUT R3, R3, 0x1, R6, 0xf8, !PT ;
        /*11d0*/                   LOP3.LUT R3, R3, R0, RZ, 0xc0, !PT ;
        /*11e0*/                   IMAD.IADD R6, R6, 0x1, R3 ;
        /*11f0*/                   LOP3.LUT R7, R6, R7, RZ, 0xfc, !PT ;
        /*1200*/                   BRA `(.L_x_307) ;
.L_x_306:
        /*1210*/                   LOP3.LUT R7, R7, 0x80000000, RZ, 0xc0, !PT ;
        /*1220*/                   LOP3.LUT R7, R7, 0x7f800000, RZ, 0xfc, !PT ;
        /*1230*/                   BRA `(.L_x_307) ;
.L_x_305:
        /*1240*/                   IMAD R7, R6, 0x800000, R7 ;
        /*1250*/                   BRA `(.L_x_307) ;
.L_x_304:
        /*1260*/                   LOP3.LUT R7, R8, 0x80000000, R7, 0x48, !PT ;
        /*1270*/                   LOP3.LUT R7, R7, 0x7f800000, RZ, 0xfc, !PT ;
        /*1280*/                   BRA `(.L_x_307) ;
.L_x_303:
        /*1290*/                   LOP3.LUT R7, R8, 0x80000000, R7, 0x48, !PT ;
        /*12a0*/                   BRA `(.L_x_307) ;
.L_x_302:
        /*12b0*/                   MUFU.RSQ R7, -QNAN  ;
        /*12c0*/                   BRA `(.L_x_307) ;
.L_x_301:
        /*12d0*/                   FADD.FTZ R7, R0, R3 ;
.L_x_307:
        /*12e0*/                   IMAD.MOV.U32 R3, RZ, RZ, 0x0 ;
        /*12f0*/                   RET.REL.NODEC R2 `(fast_mean_kernel) ;
.L_x_308:
        /*1300*/                   BRA `(.L_x_308);
        /*1310*/                   NOP;
        /*1320*/                   NOP;
        /*1330*/                   NOP;
        /*1340*/                   NOP;
        /*1350*/                   NOP;
        /*1360*/                   NOP;
        /*1370*/                   NOP;
        /*1380*/                   NOP;
        /*1390*/                   NOP;
        /*13a0*/                   NOP;
        /*13b0*/                   NOP;
        /*13c0*/                   NOP;
        /*13d0*/                   NOP;
        /*13e0*/                   NOP;
        /*13f0*/                   NOP;
.L_x_445:


//--------------------- .text.backward_scale_kernel --------------------------
	.section	.text.backward_scale_kernel,"ax",@progbits
	.sectionflags	@"SHF_BARRIERS=1"
	.sectioninfo	@"SHI_REGISTERS=40"
	.align	128
        .global         backward_scale_kernel
        .type           backward_scale_kernel,@function
        .size           backward_scale_kernel,(.L_x_469 - backward_scale_kernel)
        .other          backward_scale_kernel,@"STO_CUDA_ENTRY STV_DEFAULT"
backward_scale_kernel:
.text.backward_scale_kernel:
        /*0000*/                   MOV R1, c[0x0][0x28] ;
        /*0010*/                   S2R R0, SR_CTAID.X ;
        /*0020*/                   ISETP.LT.AND P0, PT, RZ, c[0x0][0x170], PT ;
        /*0030*/                   ULDC.64 UR4, c[0x0][0x118] ;
        /*0040*/              @!P0 MOV R19, RZ ;
        /*0050*/              @!P0 BRA `(.L_x_309) ;
        /*0060*/                   S2R R7, SR_TID.X ;
        /*0070*/                   IMAD.MOV.U32 R19, RZ, RZ, RZ ;
        /*0080*/                   MOV R9, RZ ;
        /*0090*/                   LOP3.LUT R8, RZ, R7, RZ, 0x33, !PT ;
        /*00a0*/                   IADD3 R10, R7.reuse, 0x100, RZ ;
        /*00b0*/                   IADD3 R8, R8, c[0x0][0x178], RZ ;
        /*00c0*/                   IADD3 R11, R7, 0x200, RZ ;
        /*00d0*/                   LEA.HI R12, R8, 0x1, RZ, 0x18 ;
        /*00e0*/                   IADD3 R31, R7, 0x300, RZ ;
        /*00f0*/                   LOP3.LUT R12, R12, 0x3, RZ, 0xc0, !PT ;
.L_x_319:
        /*0100*/                   ISETP.GE.AND P0, PT, R7, c[0x0][0x178], PT ;
        /*0110*/                   BSSY B0, `(.L_x_310) ;
        /*0120*/               @P0 BRA `(.L_x_311) ;
        /*0130*/                   ISETP.NE.AND P0, PT, R12, RZ, PT ;
        /*0140*/                   BSSY B1, `(.L_x_312) ;
        /*0150*/                   ISETP.GE.U32.AND P1, PT, R8, 0x300, PT ;
        /*0160*/                   IMAD R17, R9, c[0x0][0x174], R0 ;
        /*0170*/                   MOV R6, R7 ;
        /*0180*/              @!P0 BRA `(.L_x_313) ;
        /*0190*/                   IMAD.MOV.U32 R5, RZ, RZ, 0x4 ;
        /*01a0*/                   IMAD R4, R17, c[0x0][0x178], R7 ;
        /*01b0*/                   IMAD.WIDE R2, R4, R5, c[0x0][0x160] ;
        /*01c0*/                   IMAD.WIDE R4, R4, R5, c[0x0][0x168] ;
        /*01d0*/                   LDG.E R14, [R2.64] ;
        /*01e0*/                   LDG.E R13, [R4.64] ;
        /*01f0*/                   ISETP.NE.AND P0, PT, R12, 0x1, PT ;
        /*0200*/                   MOV R6, R10 ;
        /*0210*/                   FFMA R19, R14, R13, R19 ;
        /*0220*/              @!P0 BRA `(.L_x_313) ;
        /*0230*/                   ISETP.NE.AND P0, PT, R12, 0x2, PT ;
        /*0240*/                   LDG.E R14, [R2.64+0x400] ;
        /*0250*/                   LDG.E R13, [R4.64+0x400] ;
        /*0260*/               @P0 LDG.E R16, [R2.64+0x800] ;
        /*0270*/               @P0 LDG.E R15, [R4.64+0x800] ;
        /*0280*/                   MOV R6, R11 ;
        /*0290*/               @P0 IMAD.MOV.U32 R6, RZ, RZ, R31 ;
        /*02a0*/                   FFMA R19, R14, R13, R19 ;
        /*02b0*/               @P0 FFMA R19, R16, R15, R19 ;
.L_x_313:
        /*02c0*/                   BSYNC B1 ;
.L_x_312:
        /*02d0*/              @!P1 BRA `(.L_x_311) ;
        /*02e0*/                   IADD3 R2, -R6, c[0x0][0x178], RZ ;
        /*02f0*/                   BSSY B1, `(.L_x_314) ;
        /*0300*/                   IMAD R14, R17, c[0x0][0x178], R6 ;
        /*0310*/                   PLOP3.LUT P0, PT, PT, PT, PT, 0x80, 0x0 ;
        /*0320*/                   IMAD.MOV.U32 R16, RZ, RZ, c[0x0][0x160] ;
        /*0330*/                   ISETP.GT.AND P1, PT, R2, 0xc00, PT ;
        /*0340*/                   MOV R18, c[0x0][0x168] ;
        /*0350*/                   MOV R15, c[0x0][0x16c] ;
        /*0360*/                   MOV R13, c[0x0][0x164] ;
        /*0370*/              @!P1 BRA `(.L_x_315) ;
        /*0380*/                   MOV R17, c[0x0][0x178] ;
        /*0390*/                   PLOP3.LUT P0, PT, PT, PT, PT, 0x8, 0x0 ;
        /*03a0*/                   IADD3 R17, R17, -0xc00, RZ ;
.L_x_316:
        /*03b0*/                   MOV R3, R15 ;
        /*03c0*/                   IMAD.MOV.U32 R2, RZ, RZ, R18 ;
        /*03d0*/                   MOV R4, R16 ;
        /*03e0*/                   IMAD.MOV.U32 R5, RZ, RZ, R13 ;
        /*03f0*/                   IMAD.WIDE R2, R14, 0x4, R2 ;
        /*0400*/                   IMAD.WIDE R4, R14, 0x4, R4 ;
        /*0410*/                   LDG.E R21, [R2.64] ;
        /*0420*/                   LDG.E R20, [R4.64] ;
        /*0430*/                   LDG.E R34, [R2.64+0x400] ;
        /*0440*/                   LDG.E R33, [R4.64+0x400] ;
        /*0450*/                   LDG.E R25, [R4.64+0x800] ;
        /*0460*/                   LDG.E R26, [R2.64+0x800] ;
        /*0470*/                   LDG.E R27, [R4.64+0xc00] ;
        /*0480*/                   LDG.E R28, [R2.64+0xc00] ;
        /*0490*/                   LDG.E R29, [R4.64+0x1000] ;
        /*04a0*/                   LDG.E R30, [R2.64+0x1000] ;
        /*04b0*/                   LDG.E R23, [R4.64+0x1400] ;
        /*04c0*/                   LDG.E R24, [R2.64+0x1400] ;
        /*04d0*/                   LDG.E R22, [R2.64+0x1c00] ;
        /*04e0*/                   LDG.E R35, [R2.64+0x3c00] ;
        /*04f0*/                   FFMA R32, R20, R21, R19 ;
        /*0500*/                   LDG.E R19, [R4.64+0x1800] ;
        /*0510*/                   LDG.E R20, [R2.64+0x1800] ;
        /*0520*/                   LDG.E R21, [R4.64+0x1c00] ;
        /*0530*/                   FFMA R32, R33, R34, R32 ;
        /*0540*/                   LDG.E R33, [R2.64+0x3400] ;
        /*0550*/                   FFMA R32, R25, R26, R32 ;
        /*0560*/                   LDG.E R26, [R4.64+0x2000] ;
        /*0570*/                   LDG.E R25, [R2.64+0x2000] ;
        /*0580*/                   FFMA R32, R27, R28, R32 ;
        /*0590*/                   LDG.E R27, [R4.64+0x2400] ;
        /*05a0*/                   LDG.E R28, [R2.64+0x2400] ;
        /*05b0*/                   FFMA R32, R29, R30, R32 ;
        /*05c0*/                   LDG.E R29, [R4.64+0x2800] ;
        /*05d0*/                   LDG.E R30, [R2.64+0x2800] ;
        /*05e0*/                   FFMA R32, R23, R24, R32 ;
        /*05f0*/                   LDG.E R23, [R4.64+0x2c00] ;
        /*0600*/                   LDG.E R24, [R2.64+0x2c00] ;
        /*0610*/                   LDG.E R34, [R4.64+0x3c00] ;
        /*0620*/                   FFMA R32, R19, R20, R32 ;
        /*0630*/                   LDG.E R19, [R4.64+0x3000] ;
        /*0640*/                   LDG.E R20, [R2.64+0x3000] ;
        /*0650*/                   FFMA R37, R21, R22, R32 ;
        /*0660*/                   LDG.E R32, [R4.64+0x3400] ;
        /*0670*/                   LDG.E R21, [R4.64+0x3800] ;
        /*0680*/                   LDG.E R22, [R2.64+0x3800] ;
        /*0690*/                   FFMA R26, R26, R25, R37 ;
        /*06a0*/                   FFMA R26, R27, R28, R26 ;
        /*06b0*/                   IADD3 R6, R6, 0x1000, RZ ;
        /*06c0*/                   FFMA R26, R29, R30, R26 ;
        /*06d0*/                   ISETP.GE.AND P1, PT, R6, R17, PT ;
        /*06e0*/                   FFMA R24, R23, R24, R26 ;
        /*06f0*/                   IADD3 R16, P2, R16, 0x4000, RZ ;
        /*0700*/                   IADD3 R18, P3, R18, 0x4000, RZ ;
        /*0710*/                   IADD3.X R13, RZ, R13, RZ, P2, !PT ;
        /*0720*/                   IADD3.X R15, RZ, R15, RZ, P3, !PT ;
        /*0730*/                   FFMA R19, R19, R20, R24 ;
        /*0740*/                   FFMA R32, R32, R33, R19 ;
        /*0750*/                   FFMA R21, R21, R22, R32 ;
        /*0760*/                   FFMA R19, R34, R35, R21 ;
        /*0770*/              @!P1 BRA `(.L_x_316) ;
.L_x_315:
        /*0780*/                   BSYNC B1 ;
.L_x_314:
        /*0790*/                   IADD3 R2, -R6, c[0x0][0x178], RZ ;
        /*07a0*/                   BSSY B1, `(.L_x_317) ;
        /*07b0*/                   ISETP.GT.AND P1, PT, R2, 0x400, PT ;
        /*07c0*/              @!P1 BRA `(.L_x_318) ;
        /*07d0*/                   MOV R2, R18 ;
        /*07e0*/                   IMAD.MOV.U32 R3, RZ, RZ, R15 ;
        /*07f0*/                   MOV R17, R13 ;
        /*0800*/                   IMAD.WIDE R2, R14, 0x4, R2 ;
        /*0810*/                   IMAD.WIDE R4, R14, 0x4, R16 ;
        /*0820*/                   LDG.E R29, [R2.64] ;
        /*0830*/                   LDG.E R30, [R4.64] ;
        /*0840*/                   LDG.E R33, [R2.64+0x400] ;
        /*0850*/                   LDG.E R32, [R4.64+0x400] ;
        /*0860*/                   LDG.E R34, [R4.64+0x800] ;
        /*0870*/                   LDG.E R35, [R2.64+0x800] ;
        /*0880*/                   LDG.E R25, [R4.64+0xc00] ;
        /*0890*/                   LDG.E R26, [R2.64+0xc00] ;
        /*08a0*/                   LDG.E R23, [R4.64+0x1000] ;
        /*08b0*/                   LDG.E R24, [R2.64+0x1000] ;
        /*08c0*/                   LDG.E R21, [R4.64+0x1400] ;
        /*08d0*/                   LDG.E R22, [R2.64+0x1400] ;
        /*08e0*/                   LDG.E R17, [R4.64+0x1800] ;
        /*08f0*/                   LDG.E R20, [R2.64+0x1800] ;
        /*0900*/                   LDG.E R27, [R4.64+0x1c00] ;
        /*0910*/                   LDG.E R28, [R2.64+0x1c00] ;
        /*0920*/                   IADD3 R16, P1, R16, 0x2000, RZ ;
        /*0930*/                   IADD3 R18, P2, R18, 0x2000, RZ ;
        /*0940*/                   PLOP3.LUT P0, PT, PT, PT, PT, 0x8, 0x0 ;
        /*0950*/                   IADD3 R6, R6, 0x800, RZ ;
        /*0960*/                   IADD3.X R13, RZ, R13, RZ, P1, !PT ;
        /*0970*/                   IADD3.X R15, RZ, R15, RZ, P2, !PT ;
        /*0980*/                   FFMA R29, R30, R29, R19 ;
        /*0990*/                   FFMA R29, R32, R33, R29 ;
        /*09a0*/                   FFMA R34, R34, R35, R29 ;
        /*09b0*/                   FFMA R26, R25, R26, R34 ;
        /*09c0*/                   FFMA R24, R23, R24, R26 ;
        /*09d0*/                   FFMA R22, R21, R22, R24 ;
        /*09e0*/                   FFMA R20, R17, R20, R22 ;
        /*09f0*/                   FFMA R19, R27, R28, R20 ;
.L_x_318:
        /*0a00*/                   BSYNC B1 ;
.L_x_317:
        /*0a10*/                   ISETP.LT.OR P0, PT, R6, c[0x0][0x178], P0 ;
        /*0a20*/                   IMAD.MOV.U32 R4, RZ, RZ, R18 ;
        /*0a30*/                   MOV R5, R15 ;
        /*0a40*/                   MOV R17, R13 ;
        /*0a50*/              @!P0 BRA `(.L_x_311) ;
        /*0a60*/                   IMAD.WIDE R2, R14, 0x4, R16 ;
        /*0a70*/                   IMAD.WIDE R14, R14, 0x4, R4 ;
        /*0a80*/                   LDG.E R13, [R2.64+0x400] ;
        /*0a90*/                   LDG.E R4, [R2.64] ;
        /*0aa0*/                   LDG.E R5, [R14.64] ;
        /*0ab0*/                   LDG.E R6, [R14.64+0x400] ;
        /*0ac0*/                   LDG.E R17, [R2.64+0x800] ;
        /*0ad0*/                   LDG.E R16, [R14.64+0x800] ;
        /*0ae0*/                   LDG.E R21, [R2.64+0xc00] ;
        /*0af0*/                   LDG.E R18, [R14.64+0xc00] ;
        /*0b00*/                   FFMA R4, R4, R5, R19 ;
        /*0b10*/                   FFMA R4, R13, R6, R4 ;
        /*0b20*/                   FFMA R4, R17, R16, R4 ;
        /*0b30*/                   FFMA R19, R21, R18, R4 ;
.L_x_311:
        /*0b40*/                   BSYNC B0 ;
.L_x_310:
        /*0b50*/                   IADD3 R9, R9, 0x1, RZ ;
        /*0b60*/                   ISETP.GE.AND P0, PT, R9, c[0x0][0x170], PT ;
        /*0b70*/              @!P0 BRA `(.L_x_319) ;
.L_x_309:
        /*0b80*/                   S2R R7, SR_TID.X ;
        /*0b90*/                   STS [R7.X4], R19 ;
        /*0ba0*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*0bb0*/                   ISETP.GT.AND P0, PT, R7.reuse, 0x7f, PT ;
        /*0bc0*/                   ISETP.GT.AND P1, PT, R7, 0x3f, PT ;
        /*0bd0*/              @!P0 LDS R2, [R7.X4] ;
        /*0be0*/              @!P0 LDS R3, [R7.X4+0x200] ;
        /*0bf0*/              @!P0 FADD R2, R2, R3 ;
        /*0c00*/              @!P0 STS [R7.X4], R2 ;
        /*0c10*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*0c20*/                   ISETP.GT.AND P0, PT, R7, 0x1f, PT ;
        /*0c30*/              @!P1 LDS R3, [R7.X4] ;
        /*0c40*/              @!P1 LDS R4, [R7.X4+0x100] ;
        /*0c50*/              @!P1 FADD R3, R3, R4 ;
        /*0c60*/              @!P1 STS [R7.X4], R3 ;
        /*0c70*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*0c80*/                   ISETP.GT.AND P1, PT, R7, 0xf, PT ;
        /*0c90*/              @!P0 LDS R4, [R7.X4] ;
        /*0ca0*/              @!P0 LDS R5, [R7.X4+0x80] ;
        /*0cb0*/              @!P0 FADD R4, R4, R5 ;
        /*0cc0*/              @!P0 STS [R7.X4], R4 ;
        /*0cd0*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*0ce0*/                   ISETP.GT.AND P0, PT, R7, 0x7, PT ;
        /*0cf0*/              @!P1 LDS R2, [R7.X4] ;
        /*0d00*/              @!P1 LDS R5, [R7.X4+0x40] ;
        /*0d10*/              @!P1 FADD R2, R2, R5 ;
        /*0d20*/              @!P1 STS [R7.X4], R2 ;
        /*0d30*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*0d40*/                   ISETP.GT.AND P1, PT, R7, 0x3, PT ;
        /*0d50*/              @!P0 LDS R3, [R7.X4] ;
        /*0d60*/              @!P0 LDS R6, [R7.X4+0x20] ;
        /*0d70*/              @!P0 FADD R3, R3, R6 ;
        /*0d80*/              @!P0 STS [R7.X4], R3 ;
        /*0d90*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*0da0*/                   ISETP.GT.AND P0, PT, R7, 0x1, PT ;
        /*0db0*/              @!P1 LDS R4, [R7.X4] ;
        /*0dc0*/              @!P1 LDS R5, [R7.X4+0x10] ;
        /*0dd0*/              @!P1 FADD R4, R4, R5 ;
        /*0de0*/              @!P1 STS [R7.X4], R4 ;
        /*0df0*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*0e00*/                   ISETP.GT.AND P1, PT, R7, RZ, PT ;
        /*0e10*/              @!P0 LDS R2, [R7.X4] ;
        /*0e20*/              @!P0 LDS R5, [R7.X4+0x8] ;
        /*0e30*/              @!P0 FADD R2, R2, R5 ;
        /*0e40*/              @!P0 STS [R7.X4], R2 ;
        /*0e50*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*0e60*/                   ISETP.NE.AND P0, PT, R7, RZ, PT ;
        /*0e70*/              @!P1 LDS R3, [R7.X4] ;
        /*0e80*/              @!P1 LDS R6, [R7.X4+0x4] ;
        /*0e90*/              @!P1 FADD R3, R3, R6 ;
        /*0ea0*/              @!P1 STS [R7.X4], R3 ;
        /*0eb0*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*0ec0*/               @P0 EXIT ;
        /*0ed0*/                   MOV R3, 0x4 ;
        /*0ee0*/                   IMAD.WIDE R2, R0, R3, c[0x0][0x180] ;
        /*0ef0*/                   LDS R0, [RZ] ;
        /*0f00*/                   LDG.E R5, [R2.64] ;
        /*0f10*/                   FADD R5, R0, R5 ;
        /*0f20*/                   STG.E [R2.64], R5 ;
        /*0f30*/                   EXIT ;
.L_x_320:
        /*0f40*/                   BRA `(.L_x_320);
        /*0f50*/                   NOP;
        /*0f60*/                   NOP;
        /*0f70*/                   NOP;
        /*0f80*/                   NOP;
        /*0f90*/                   NOP;
        /*0fa0*/                   NOP;
        /*0fb0*/                   NOP;
        /*0fc0*/                   NOP;
        /*0fd0*/                   NOP;
        /*0fe0*/                   NOP;
        /*0ff0*/                   NOP;
.L_x_469:


//--------------------- .text.backward_bias_conn_kernel --------------------------
	.section	.text.backward_bias_conn_kernel,"ax",@progbits
	.sectioninfo	@"SHI_REGISTERS=40"
	.align	128
        .global         backward_bias_conn_kernel
        .type           backward_bias_conn_kernel,@function
        .size           backward_bias_conn_kernel,(.L_x_470 - backward_bias_conn_kernel)
        .other          backward_bias_conn_kernel,@"STO_CUDA_ENTRY STV_DEFAULT"
backward_bias_conn_kernel:
.text.backward_bias_conn_kernel:
        /*0000*/                   MOV R1, c[0x0][0x28] ;
        /*0010*/                   S2R R0, SR_CTAID.X ;
        /*0020*/                   S2R R3, SR_TID.X ;
        /*0030*/                   IMAD R0, R0, c[0x0][0x0], R3 ;
        /*0040*/                   ISETP.GE.AND P0, PT, R0, c[0x0][0x174], PT ;
        /*0050*/               @P0 EXIT ;
        /*0060*/                   MOV R12, c[0x0][0x170] ;
        /*0070*/                   ULDC.64 UR4, c[0x0][0x118] ;
        /*0080*/                   MOV R13, RZ ;
        /*0090*/                   ISETP.GE.AND P0, PT, R12, 0x1, PT ;
        /*00a0*/              @!P0 BRA `(.L_x_321) ;
        /*00b0*/                   IADD3 R2, R12.reuse, -0x1, RZ ;
        /*00c0*/                   LOP3.LUT R12, R12, 0x3, RZ, 0xc0, !PT ;
        /*00d0*/                   ISETP.GE.U32.AND P0, PT, R2, 0x3, PT ;
        /*00e0*/                   MOV R13, RZ ;
        /*00f0*/                   MOV R17, RZ ;
        /*0100*/              @!P0 BRA `(.L_x_322) ;
        /*0110*/                   IADD3 R14, -R12, c[0x0][0x170], RZ ;
        /*0120*/                   MOV R15, 0x4 ;
        /*0130*/                   ISETP.GT.AND P0, PT, R14, RZ, PT ;
        /*0140*/                   MOV R13, RZ ;
        /*0150*/                   IMAD.WIDE R4, R0, R15, c[0x0][0x168] ;
        /*0160*/                   MOV R17, RZ ;
        /*0170*/              @!P0 BRA `(.L_x_323) ;
        /*0180*/                   ISETP.GT.AND P1, PT, R14, 0xc, PT ;
        /*0190*/                   PLOP3.LUT P0, PT, PT, PT, PT, 0x80, 0x0 ;
        /*01a0*/              @!P1 BRA `(.L_x_324) ;
        /*01b0*/                   PLOP3.LUT P0, PT, PT, PT, PT, 0x8, 0x0 ;
.L_x_325:
        /*01c0*/                   IMAD.WIDE R22, R15.reuse, c[0x0][0x174], R4 ;
        /*01d0*/                   LDG.E R16, [R4.64] ;
        /*01e0*/                   LDG.E R18, [R22.64] ;
        /*01f0*/                   IMAD.WIDE R34, R15, c[0x0][0x174], R22 ;
        /*0200*/                   LDG.E R19, [R34.64] ;
        /*0210*/                   IMAD.WIDE R36, R15, c[0x0][0x174], R34 ;
        /*0220*/                   LDG.E R20, [R36.64] ;
        /*0230*/                   IMAD.WIDE R24, R15, c[0x0][0x174], R36 ;
        /*0240*/                   LDG.E R21, [R24.64] ;
        /*0250*/                   IMAD.WIDE R26, R15, c[0x0][0x174], R24 ;
        /*0260*/                   LDG.E R28, [R26.64] ;
        /*0270*/                   IMAD.WIDE R32, R15, c[0x0][0x174], R26 ;
        /*0280*/                   LDG.E R29, [R32.64] ;
        /*0290*/                   IMAD.WIDE R10, R15, c[0x0][0x174], R32 ;
        /*02a0*/                   LDG.E R30, [R10.64] ;
        /*02b0*/                   IMAD.WIDE R6, R15, c[0x0][0x174], R10 ;
        /*02c0*/                   IMAD.WIDE R8, R15.reuse, c[0x0][0x174], R6 ;
        /*02d0*/                   LDG.E R6, [R6.64] ;
        /*02e0*/                   IMAD.WIDE R2, R15.reuse, c[0x0][0x174], R8 ;
        /*02f0*/                   LDG.E R8, [R8.64] ;
        /*0300*/                   IMAD.WIDE R4, R15, c[0x0][0x174], R2 ;
        /*0310*/                   LDG.E R2, [R2.64] ;
        /*0320*/                   IMAD.WIDE R22, R15.reuse, c[0x0][0x174], R4 ;
        /*0330*/                   LDG.E R4, [R4.64] ;
        /*0340*/                   IMAD.WIDE R24, R15, c[0x0][0x174], R22 ;
        /*0350*/                   LDG.E R22, [R22.64] ;
        /*0360*/                   IMAD.WIDE R26, R15.reuse, c[0x0][0x174], R24 ;
        /*0370*/                   LDG.E R24, [R24.64] ;
        /*0380*/                   IMAD.WIDE R10, R15, c[0x0][0x174], R26 ;
        /*0390*/                   LDG.E R26, [R26.64] ;
        /*03a0*/                   LDG.E R7, [R10.64] ;
        /*03b0*/                   IADD3 R14, R14, -0x10, RZ ;
        /*03c0*/                   ISETP.GT.AND P1, PT, R14, 0xc, PT ;
        /*03d0*/                   IADD3 R17, R17, 0x10, RZ ;
        /*03e0*/                   FADD R13, R16, R13 ;
        /*03f0*/                   FADD R18, R13, R18 ;
        /*0400*/                   FADD R19, R18, R19 ;
        /*0410*/                   FADD R20, R19, R20 ;
        /*0420*/                   FADD R21, R20, R21 ;
        /*0430*/                   FADD R28, R21, R28 ;
        /*0440*/                   FADD R29, R28, R29 ;
        /*0450*/                   FADD R29, R29, R30 ;
        /*0460*/                   FADD R29, R29, R6 ;
        /*0470*/                   FADD R29, R29, R8 ;
        /*0480*/                   FADD R29, R29, R2 ;
        /*0490*/                   FADD R29, R29, R4 ;
        /*04a0*/                   FADD R29, R29, R22 ;
        /*04b0*/                   FADD R29, R29, R24 ;
        /*04c0*/                   IMAD.WIDE R4, R15, c[0x0][0x174], R10 ;
        /*04d0*/                   FADD R26, R29, R26 ;
        /*04e0*/                   FADD R13, R26, R7 ;
        /*04f0*/               @P1 BRA `(.L_x_325) ;
.L_x_324:
        /*0500*/                   ISETP.GT.AND P1, PT, R14, 0x4, PT ;
        /*0510*/              @!P1 BRA `(.L_x_326) ;
        /*0520*/                   IMAD.WIDE R6, R15.reuse, c[0x0][0x174], R4 ;
        /*0530*/                   LDG.E R4, [R4.64] ;
        /*0540*/                   IMAD.WIDE R8, R15.reuse, c[0x0][0x174], R6 ;
        /*0550*/                   LDG.E R7, [R6.64] ;
        /*0560*/                   IMAD.WIDE R10, R15, c[0x0][0x174], R8 ;
        /*0570*/                   LDG.E R9, [R8.64] ;
        /*0580*/                   IMAD.WIDE R18, R15.reuse, c[0x0][0x174], R10 ;
        /*0590*/                   LDG.E R11, [R10.64] ;
        /*05a0*/                   IMAD.WIDE R20, R15, c[0x0][0x174], R18 ;
        /*05b0*/                   LDG.E R19, [R18.64] ;
        /*05c0*/                   IMAD.WIDE R22, R15.reuse, c[0x0][0x174], R20 ;
        /*05d0*/                   LDG.E R21, [R20.64] ;
        /*05e0*/                   IMAD.WIDE R2, R15, c[0x0][0x174], R22 ;
        /*05f0*/                   LDG.E R23, [R22.64] ;
        /*0600*/                   LDG.E R5, [R2.64] ;
        /*0610*/                   PLOP3.LUT P0, PT, PT, PT, PT, 0x8, 0x0 ;
        /*0620*/                   IADD3 R17, R17, 0x8, RZ ;
        /*0630*/                   IADD3 R14, R14, -0x8, RZ ;
        /*0640*/                   FADD R4, R13, R4 ;
        /*0650*/                   FADD R4, R4, R7 ;
        /*0660*/                   FADD R4, R4, R9 ;
        /*0670*/                   FADD R4, R4, R11 ;
        /*0680*/                   FADD R4, R4, R19 ;
        /*0690*/                   FADD R4, R4, R21 ;
        /*06a0*/                   FADD R4, R4, R23 ;
        /*06b0*/                   FADD R13, R4, R5 ;
        /*06c0*/                   IMAD.WIDE R4, R15, c[0x0][0x174], R2 ;
.L_x_326:
        /*06d0*/                   ISETP.NE.OR P0, PT, R14, RZ, P0 ;
        /*06e0*/              @!P0 BRA `(.L_x_322) ;
.L_x_323:
        /*06f0*/                   IMAD.WIDE R2, R15.reuse, c[0x0][0x174], R4 ;
        /*0700*/                   LDG.E R4, [R4.64] ;
        /*0710*/                   IMAD.WIDE R6, R15.reuse, c[0x0][0x174], R2 ;
        /*0720*/                   LDG.E R2, [R2.64] ;
        /*0730*/                   IMAD.WIDE R8, R15, c[0x0][0x174], R6 ;
        /*0740*/                   LDG.E R6, [R6.64] ;
        /*0750*/                   LDG.E R10, [R8.64] ;
        /*0760*/                   IADD3 R14, R14, -0x4, RZ ;
        /*0770*/                   IADD3 R17, R17, 0x4, RZ ;
        /*0780*/                   ISETP.NE.AND P0, PT, R14, RZ, PT ;
        /*0790*/                   FADD R13, R4, R13 ;
        /*07a0*/                   IMAD.WIDE R4, R15, c[0x0][0x174], R8 ;
        /*07b0*/                   FADD R13, R13, R2 ;
        /*07c0*/                   FADD R13, R13, R6 ;
        /*07d0*/                   FADD R13, R13, R10 ;
        /*07e0*/               @P0 BRA `(.L_x_323) ;
.L_x_322:
        /*07f0*/                   ISETP.NE.AND P0, PT, R12, RZ, PT ;
        /*0800*/              @!P0 BRA `(.L_x_321) ;
        /*0810*/                   MOV R5, 0x4 ;
        /*0820*/                   IMAD R2, R17, c[0x0][0x174], R0 ;
        /*0830*/                   IMAD.WIDE R2, R2, R5, c[0x0][0x168] ;
.L_x_327:
        /*0840*/                   LDG.E R4, [R2.64] ;
        /*0850*/                   IADD3 R12, R12, -0x1, RZ ;
        /*0860*/                   ISETP.NE.AND P0, PT, R12, RZ, PT ;
        /*0870*/                   IMAD.WIDE R2, R5, c[0x0][0x174], R2 ;
        /*0880*/                   FADD R13, R4, R13 ;
        /*0890*/               @P0 BRA `(.L_x_327) ;
.L_x_321:
        /*08a0*/                   MOV R3, 0x4 ;
        /*08b0*/                   IMAD.WIDE R2, R0, R3, c[0x0][0x160] ;
        /*08c0*/                   LDG.E R0, [R2.64] ;
        /*08d0*/                   FADD R13, R0, R13 ;
        /*08e0*/                   STG.E [R2.64], R13 ;
        /*08f0*/                   EXIT ;
.L_x_328:
        /*0900*/                   BRA `(.L_x_328);
        /*0910*/                   NOP;
        /*0920*/                   NOP;
        /*0930*/                   NOP;
        /*0940*/                   NOP;
        /*0950*/                   NOP;
        /*0960*/                   NOP;
        /*0970*/                   NOP;
        /*0980*/                   NOP;
        /*0990*/                   NOP;
        /*09a0*/                   NOP;
        /*09b0*/                   NOP;
        /*09c0*/                   NOP;
        /*09d0*/                   NOP;
        /*09e0*/                   NOP;
        /*09f0*/                   NOP;
.L_x_470:


//--------------------- .text.backward_bias_kernel --------------------------
	.section	.text.backward_bias_kernel,"ax",@progbits
	.sectionflags	@"SHF_BARRIERS=1"
	.sectioninfo	@"SHI_REGISTERS=39"
	.align	128
        .global         backward_bias_kernel
        .type           backward_bias_kernel,@function
        .size           backward_bias_kernel,(.L_x_471 - backward_bias_kernel)
        .other          backward_bias_kernel,@"STO_CUDA_ENTRY STV_DEFAULT"
backward_bias_kernel:
.text.backward_bias_kernel:
        /*0000*/                   MOV R1, c[0x0][0x28] ;
        /*0010*/                   S2R R0, SR_CTAID.X ;
        /*0020*/                   ISETP.LT.AND P0, PT, RZ, c[0x0][0x170], PT ;
        /*0030*/                   ULDC.64 UR4, c[0x0][0x118] ;
        /*0040*/              @!P0 MOV R10, RZ ;
        /*0050*/              @!P0 BRA `(.L_x_329) ;
        /*0060*/                   S2R R4, SR_TID.X ;
        /*0070*/                   MOV R10, RZ ;
        /*0080*/                   IMAD.MOV.U32 R7, RZ, RZ, RZ ;
        /*0090*/                   LOP3.LUT R5, RZ, R4, RZ, 0x33, !PT ;
        /*00a0*/                   IADD3 R6, R4.reuse, 0x100, RZ ;
        /*00b0*/                   IADD3 R5, R5, c[0x0][0x178], RZ ;
        /*00c0*/                   IADD3 R8, R4, 0x200, RZ ;
        /*00d0*/                   LEA.HI R9, R5, 0x1, RZ, 0x18 ;
        /*00e0*/                   IADD3 R20, R4, 0x300, RZ ;
        /*00f0*/                   LOP3.LUT R9, R9, 0x3, RZ, 0xc0, !PT ;
.L_x_339:
        /*0100*/                   ISETP.GE.AND P0, PT, R4, c[0x0][0x178], PT ;
        /*0110*/                   BSSY B0, `(.L_x_330) ;
        /*0120*/               @P0 BRA `(.L_x_331) ;
        /*0130*/                   ISETP.NE.AND P1, PT, R9, RZ, PT ;
        /*0140*/                   BSSY B1, `(.L_x_332) ;
        /*0150*/                   ISETP.GE.U32.AND P0, PT, R5, 0x300, PT ;
        /*0160*/                   IMAD R12, R7, c[0x0][0x174], R0 ;
        /*0170*/                   MOV R11, R4 ;
        /*0180*/              @!P1 BRA `(.L_x_333) ;
        /*0190*/                   MOV R3, 0x4 ;
        /*01a0*/                   IMAD R2, R12, c[0x0][0x178], R4 ;
        /*01b0*/                   IMAD.WIDE R2, R2, R3, c[0x0][0x168] ;
        /*01c0*/                   LDG.E R13, [R2.64] ;
        /*01d0*/                   ISETP.NE.AND P1, PT, R9, 0x1, PT ;
        /*01e0*/                   IMAD.MOV.U32 R11, RZ, RZ, R6 ;
        /*01f0*/                   FADD R10, R10, R13 ;
        /*0200*/              @!P1 BRA `(.L_x_333) ;
        /*0210*/                   ISETP.NE.AND P1, PT, R9, 0x2, PT ;
        /*0220*/                   LDG.E R13, [R2.64+0x400] ;
        /*0230*/               @P1 LDG.E R15, [R2.64+0x800] ;
        /*0240*/                   MOV R11, R8 ;
        /*0250*/               @P1 MOV R11, R20 ;
        /*0260*/                   FADD R10, R10, R13 ;
        /*0270*/               @P1 FADD R10, R10, R15 ;
.L_x_333:
        /*0280*/                   BSYNC B1 ;
.L_x_332:
        /*0290*/              @!P0 BRA `(.L_x_331) ;
        /*02a0*/                   IADD3 R2, -R11, c[0x0][0x178], RZ ;
        /*02b0*/                   IMAD.MOV.U32 R3, RZ, RZ, 0x4 ;
        /*02c0*/                   BSSY B1, `(.L_x_334) ;
        /*02d0*/                   PLOP3.LUT P0, PT, PT, PT, PT, 0x80, 0x0 ;
        /*02e0*/                   ISETP.GT.AND P1, PT, R2, 0xc00, PT ;
        /*02f0*/                   IMAD R2, R12, c[0x0][0x178], R11 ;
        /*0300*/                   IMAD.WIDE R2, R2, R3, c[0x0][0x168] ;
        /*0310*/              @!P1 BRA `(.L_x_335) ;
        /*0320*/                   MOV R14, c[0x0][0x178] ;
        /*0330*/                   PLOP3.LUT P0, PT, PT, PT, PT, 0x8, 0x0 ;
        /*0340*/                   IADD3 R14, R14, -0xc00, RZ ;
.L_x_336:
        /*0350*/                   LDG.E R21, [R2.64] ;
        /*0360*/                   LDG.E R22, [R2.64+0x400] ;
        /*0370*/                   LDG.E R24, [R2.64+0x800] ;
        /*0380*/                   LDG.E R26, [R2.64+0xc00] ;
        /*0390*/                   LDG.E R28, [R2.64+0x1000] ;
        /*03a0*/                   LDG.E R30, [R2.64+0x1400] ;
        /*03b0*/                   LDG.E R32, [R2.64+0x1800] ;
        /*03c0*/                   LDG.E R34, [R2.64+0x1c00] ;
        /*03d0*/                   LDG.E R36, [R2.64+0x2000] ;
        /*03e0*/                   LDG.E R19, [R2.64+0x2400] ;
        /*03f0*/                   LDG.E R18, [R2.64+0x2800] ;
        /*0400*/                   LDG.E R17, [R2.64+0x2c00] ;
        /*0410*/                   LDG.E R16, [R2.64+0x3000] ;
        /*0420*/                   LDG.E R13, [R2.64+0x3400] ;
        /*0430*/                   LDG.E R15, [R2.64+0x3800] ;
        /*0440*/                   LDG.E R12, [R2.64+0x3c00] ;
        /*0450*/                   IADD3 R11, R11, 0x1000, RZ ;
        /*0460*/                   ISETP.GE.AND P1, PT, R11, R14, PT ;
        /*0470*/                   IADD3 R2, P2, R2, 0x4000, RZ ;
        /*0480*/                   IADD3.X R3, RZ, R3, RZ, P2, !PT ;
        /*0490*/                   FADD R21, R21, R10 ;
        /*04a0*/                   FADD R21, R21, R22 ;
        /*04b0*/                   FADD R21, R21, R24 ;
        /*04c0*/                   FADD R21, R21, R26 ;
        /*04d0*/                   FADD R21, R21, R28 ;
        /*04e0*/                   FADD R21, R21, R30 ;
        /*04f0*/                   FADD R21, R21, R32 ;
        /*0500*/                   FADD R21, R21, R34 ;
        /*0510*/                   FADD R36, R21, R36 ;
        /*0520*/                   FADD R19, R36, R19 ;
        /*0530*/                   FADD R18, R19, R18 ;
        /*0540*/                   FADD R17, R18, R17 ;
        /*0550*/                   FADD R16, R17, R16 ;
        /*0560*/                   FADD R16, R16, R13 ;
        /*0570*/                   FADD R15, R16, R15 ;
        /*0580*/                   FADD R10, R15, R12 ;
        /*0590*/              @!P1 BRA `(.L_x_336) ;
.L_x_335:
        /*05a0*/                   BSYNC B1 ;
.L_x_334:
        /*05b0*/                   IADD3 R12, -R11, c[0x0][0x178], RZ ;
        /*05c0*/                   BSSY B1, `(.L_x_337) ;
        /*05d0*/                   ISETP.GT.AND P1, PT, R12, 0x400, PT ;
        /*05e0*/              @!P1 BRA `(.L_x_338) ;
        /*05f0*/                   LDG.E R13, [R2.64] ;
        /*0600*/                   LDG.E R12, [R2.64+0x400] ;
        /*0610*/                   LDG.E R15, [R2.64+0x800] ;
        /*0620*/                   LDG.E R17, [R2.64+0xc00] ;
        /*0630*/                   LDG.E R19, [R2.64+0x1000] ;
        /*0640*/                   LDG.E R21, [R2.64+0x1400] ;
        /*0650*/                   LDG.E R23, [R2.64+0x1800] ;
        /*0660*/                   LDG.E R25, [R2.64+0x1c00] ;
        /*0670*/                   PLOP3.LUT P0, PT, PT, PT, PT, 0x8, 0x0 ;
        /*0680*/                   IADD3 R11, R11, 0x800, RZ ;
        /*0690*/                   FADD R13, R10, R13 ;
        /*06a0*/                   FADD R12, R13, R12 ;
        /*06b0*/                   IADD3 R13, P1, R2, 0x2000, RZ ;
        /*06c0*/                   FADD R12, R12, R15 ;
        /*06d0*/                   MOV R2, R13 ;
        /*06e0*/                   IMAD.X R14, RZ, RZ, R3, P1 ;
        /*06f0*/                   FADD R12, R12, R17 ;
        /*0700*/                   MOV R3, R14 ;
        /*0710*/                   FADD R12, R12, R19 ;
        /*0720*/                   FADD R12, R12, R21 ;
        /*0730*/                   FADD R12, R12, R23 ;
        /*0740*/                   FADD R10, R12, R25 ;
.L_x_338:
        /*0750*/                   BSYNC B1 ;
.L_x_337:
        /*0760*/                   ISETP.LT.OR P0, PT, R11, c[0x0][0x178], P0 ;
        /*0770*/              @!P0 BRA `(.L_x_331) ;
        /*0780*/                   LDG.E R11, [R2.64] ;
        /*0790*/                   LDG.E R12, [R2.64+0x400] ;
        /*07a0*/                   LDG.E R14, [R2.64+0x800] ;
        /*07b0*/                   LDG.E R16, [R2.64+0xc00] ;
        /*07c0*/                   FADD R11, R10, R11 ;
        /*07d0*/                   FADD R11, R11, R12 ;
        /*07e0*/                   FADD R11, R11, R14 ;
        /*07f0*/                   FADD R10, R11, R16 ;
.L_x_331:
        /*0800*/                   BSYNC B0 ;
.L_x_330:
        /*0810*/                   IADD3 R7, R7, 0x1, RZ ;
        /*0820*/                   ISETP.GE.AND P0, PT, R7, c[0x0][0x170], PT ;
        /*0830*/              @!P0 BRA `(.L_x_339) ;
.L_x_329:
        /*0840*/                   S2R R7, SR_TID.X ;
        /*0850*/                   STS [R7.X4], R10 ;
        /*0860*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*0870*/                   ISETP.GT.AND P0, PT, R7.reuse, 0x7f, PT ;
        /*0880*/                   ISETP.GT.AND P1, PT, R7, 0x3f, PT ;
        /*0890*/              @!P0 LDS R2, [R7.X4] ;
        /*08a0*/              @!P0 LDS R3, [R7.X4+0x200] ;
        /*08b0*/              @!P0 FADD R2, R2, R3 ;
        /*08c0*/              @!P0 STS [R7.X4], R2 ;
        /*08d0*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*08e0*/                   ISETP.GT.AND P0, PT, R7, 0x1f, PT ;
        /*08f0*/              @!P1 LDS R3, [R7.X4] ;
        /*0900*/              @!P1 LDS R4, [R7.X4+0x100] ;
        /*0910*/              @!P1 FADD R3, R3, R4 ;
        /*0920*/              @!P1 STS [R7.X4], R3 ;
        /*0930*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*0940*/                   ISETP.GT.AND P1, PT, R7, 0xf, PT ;
        /*0950*/              @!P0 LDS R4, [R7.X4] ;
        /*0960*/              @!P0 LDS R5, [R7.X4+0x80] ;
        /*0970*/              @!P0 FADD R4, R4, R5 ;
        /*0980*/              @!P0 STS [R7.X4], R4 ;
        /*0990*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*09a0*/                   ISETP.GT.AND P0, PT, R7, 0x7, PT ;
        /*09b0*/              @!P1 LDS R2, [R7.X4] ;
        /*09c0*/              @!P1 LDS R5, [R7.X4+0x40] ;
        /*09d0*/              @!P1 FADD R2, R2, R5 ;
        /*09e0*/              @!P1 STS [R7.X4], R2 ;
        /*09f0*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*0a00*/                   ISETP.GT.AND P1, PT, R7, 0x3, PT ;
        /*0a10*/              @!P0 LDS R3, [R7.X4] ;
        /*0a20*/              @!P0 LDS R6, [R7.X4+0x20] ;
        /*0a30*/              @!P0 FADD R3, R3, R6 ;
        /*0a40*/              @!P0 STS [R7.X4], R3 ;
        /*0a50*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*0a60*/                   ISETP.GT.AND P0, PT, R7, 0x1, PT ;
        /*0a70*/              @!P1 LDS R4, [R7.X4] ;
        /*0a80*/              @!P1 LDS R5, [R7.X4+0x10] ;
        /*0a90*/              @!P1 FADD R4, R4, R5 ;
        /*0aa0*/              @!P1 STS [R7.X4], R4 ;
        /*0ab0*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*0ac0*/                   ISETP.GT.AND P1, PT, R7, RZ, PT ;
        /*0ad0*/              @!P0 LDS R2, [R7.X4] ;
        /*0ae0*/              @!P0 LDS R5, [R7.X4+0x8] ;
        /*0af0*/              @!P0 FADD R2, R2, R5 ;
        /*0b00*/              @!P0 STS [R7.X4], R2 ;
        /*0b10*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*0b20*/                   ISETP.NE.AND P0, PT, R7, RZ, PT ;
        /*0b30*/              @!P1 LDS R3, [R7.X4] ;
        /*0b40*/              @!P1 LDS R6, [R7.X4+0x4] ;
        /*0b50*/              @!P1 FADD R3, R3, R6 ;
        /*0b60*/              @!P1 STS [R7.X4], R3 ;
        /*0b70*/                   BAR.SYNC.DEFER_BLOCKING 0x0 ;
        /*0b80*/               @P0 EXIT ;
        /*0b90*/                   MOV R3, 0x4 ;
        /*0ba0*/                   IMAD.WIDE R2, R0, R3, c[0x0][0x160] ;
        /*0bb0*/                   LDS R0, [RZ] ;
        /*0bc0*/                   LDG.E R5, [R2.64] ;
        /*0bd0*/                   FADD R5, R0, R5 ;
        /*0be0*/                   STG.E [R2.64], R5 ;
        /*0bf0*/                   EXIT ;
.L_x_340:
        /*0c00*/                   BRA `(.L_x_340);
        /*0c10*/                   NOP;
        /*0c20*/                   NOP;
        /*0c30*/                   NOP;
        /*0c40*/                   NOP;
        /*0c50*/                   NOP;
        /*0c60*/                   NOP;
        /*0c70*/                   NOP;
        /*0c80*/                   NOP;
        /*0c90*/                   NOP;
        /*0ca0*/                   NOP;
        /*0cb0*/                   NOP;
        /*0cc0*/                   NOP;
        /*0cd0*/                   NOP;
        /*0ce0*/                   NOP;
        /*0cf0*/                   NOP;
.L_x_471:


//--------------------- .text.scale_bias_kernel   --------------------------
	.section	.text.scale_bias_kernel,"ax",@progbits
	.sectioninfo	@"SHI_REGISTERS=12"
	.align	128
        .global         scale_bias_kernel
        .type           scale_bias_kernel,@function
        .size           scale_bias_kernel,(.L_x_472 - scale_bias_kernel)
        .other          scale_bias_kernel,@"STO_CUDA_ENTRY STV_DEFAULT"
scale_bias_kernel:
.text.scale_bias_kernel:
        /*0000*/                   IMAD.MOV.U32 R1, RZ, RZ, c[0x0][0x28] ;
        /*0010*/                   S2R R0, SR_CTAID.X ;
        /*0020*/                   ULDC.64 UR4, c[0x0][0x170] ;
        /*0030*/                   UIMAD UR4, UR5, UR4, URZ ;
        /*0040*/                   S2R R3, SR_TID.X ;
        /*0050*/                   ULDC UR5, c[0x0][0x178] ;
        /*0060*/                   UIMAD UR4, UR4, UR5, URZ ;
        /*0070*/                   IMAD R0, R0, c[0x0][0x0], R3 ;
        /*0080*/                   ISETP.GE.AND P0, PT, R0, UR4, PT ;
        /*0090*/               @P0 EXIT ;
        /*00a0*/                   IABS R8, c[0x0][0x178] ;
        /*00b0*/                   ULDC.64 UR4, c[0x0][0x118] ;
        /*00c0*/                   IABS R7, c[0x0][0x174] ;
        /*00d0*/                   I2F.RP R4, R8 ;
        /*00e0*/                   MUFU.RCP R4, R4 ;
        /*00f0*/                   IADD3 R2, R4, 0xffffffe, RZ ;
        /*0100*/                   IABS R4, R0 ;
        /*0110*/                   F2I.FTZ.U32.TRUNC.NTZ R3, R2 ;
        /*0120*/                   MOV R2, RZ ;
        /*0130*/                   IMAD.MOV R5, RZ, RZ, -R3 ;
        /*0140*/                   IMAD R5, R5, R8, RZ ;
        /*0150*/                   IMAD.HI.U32 R3, R3, R5, R2 ;
        /*0160*/                   I2F.RP R5, R7 ;
        /*0170*/                   IMAD.HI.U32 R2, R3, R4, RZ ;
        /*0180*/                   IMAD.MOV R3, RZ, RZ, -R2 ;
        /*0190*/                   IMAD R3, R8, R3, R4 ;
        /*01a0*/                   LOP3.LUT R4, R0, c[0x0][0x178], RZ, 0x3c, !PT ;
        /*01b0*/                   MUFU.RCP R5, R5 ;
        /*01c0*/                   ISETP.GT.U32.AND P2, PT, R8, R3, PT ;
        /*01d0*/                   ISETP.GE.AND P1, PT, R4, RZ, PT ;
        /*01e0*/              @!P2 IMAD.IADD R3, R3, 0x1, -R8 ;
        /*01f0*/              @!P2 IADD3 R2, R2, 0x1, RZ ;
        /*0200*/                   IADD3 R6, R5, 0xffffffe, RZ ;
        /*0210*/                   ISETP.GE.U32.AND P0, PT, R3, R8, PT ;
        /*0220*/                   F2I.FTZ.U32.TRUNC.NTZ R3, R6 ;
        /*0230*/                   ISETP.NE.AND P2, PT, RZ, c[0x0][0x178], PT ;
        /*0240*/               @P0 IADD3 R2, R2, 0x1, RZ ;
        /*0250*/                   MOV R9, R2 ;
        /*0260*/                   IMAD.MOV R2, RZ, RZ, -R3 ;
        /*0270*/              @!P1 IMAD.MOV R9, RZ, RZ, -R9 ;
        /*0280*/              @!P2 LOP3.LUT R9, RZ, c[0x0][0x178], RZ, 0x33, !PT ;
        /*0290*/                   IMAD R5, R2, R7, RZ ;
        /*02a0*/                   MOV R2, RZ ;
        /*02b0*/                   IABS R4, R9 ;
        /*02c0*/                   ISETP.GE.AND P2, PT, R9, RZ, PT ;
        /*02d0*/                   IMAD.HI.U32 R2, R3, R5, R2 ;
        /*02e0*/                   IMAD.MOV.U32 R3, RZ, RZ, R4 ;
        /*02f0*/                   IMAD.HI.U32 R2, R2, R3, RZ ;
        /*0300*/                   IMAD.MOV R2, RZ, RZ, -R2 ;
        /*0310*/                   IMAD R2, R7, R2, R3 ;
        /*0320*/                   IADD3 R3, -R9, RZ, RZ ;
        /*0330*/                   ISETP.GT.U32.AND P0, PT, R7, R2, PT ;
        /*0340*/                   IMAD R0, R3, c[0x0][0x178], R0 ;
        /*0350*/                   MOV R3, 0x4 ;
        /*0360*/                   IMAD R0, R9, c[0x0][0x178], R0 ;
        /*0370*/                   IMAD.WIDE R4, R0, R3, c[0x0][0x160] ;
        /*0380*/              @!P0 IADD3 R2, R2, -R7, RZ ;
        /*0390*/                   LDG.E R0, [R4.64] ;
        /*03a0*/                   ISETP.NE.AND P0, PT, RZ, c[0x0][0x174], PT ;
        /*03b0*/                   ISETP.GT.U32.AND P1, PT, R7, R2, PT ;
        /*03c0*/              @!P1 IMAD.IADD R2, R2, 0x1, -R7 ;
        /*03d0*/              @!P2 IMAD.MOV R2, RZ, RZ, -R2 ;
        /*03e0*/              @!P0 LOP3.LUT R2, RZ, c[0x0][0x174], RZ, 0x33, !PT ;
        /*03f0*/                   IMAD.WIDE R2, R2, R3, c[0x0][0x168] ;
        /*0400*/                   LDG.E R3, [R2.64] ;
        /*0410*/                   FMUL R7, R0, R3 ;
        /*0420*/                   STG.E [R4.64], R7 ;
        /*0430*/                   EXIT ;
.L_x_341:
        /*0440*/                   BRA `(.L_x_341);
        /*0450*/                   NOP;
        /*0460*/                   NOP;
        /*0470*/                   NOP;
        /*0480*/                   NOP;
        /*0490*/                   NOP;
        /*04a0*/                   NOP;
        /*04b0*/                   NOP;
        /*04c0*/                   NOP;
        /*04d0*/                   NOP;
        /*04e0*/                   NOP;
        /*04f0*/                   NOP;
.L_x_472:


//--------------------- .text.add_bias_kernel     --------------------------
	.section	.text.add_bias_kernel,"ax",@progbits
	.sectioninfo	@"SHI_REGISTERS=12"
	.align	128
        .global         add_bias_kernel
        .type           add_bias_kernel,@function
        .size           add_bias_kernel,(.L_x_473 - add_bias_kernel)
        .other          add_bias_kernel,@"STO_CUDA_ENTRY STV_DEFAULT"
add_bias_kernel:
.text.add_bias_kernel:
        /*0000*/                   IMAD.MOV.U32 R1, RZ, RZ, c[0x0][0x28] ;
        /*0010*/                   S2R R0, SR_CTAID.X ;
        /*0020*/                   ULDC.64 UR4, c[0x0][0x170] ;
        /*0030*/                   UIMAD UR4, UR5, UR4, URZ ;
        /*0040*/                   S2R R3, SR_TID.X ;
        /*0050*/                   ULDC UR5, c[0x0][0x178] ;
        /*0060*/                   UIMAD UR4, UR4, UR5, URZ ;
        /*0070*/                   IMAD R0, R0, c[0x0][0x0], R3 ;
        /*0080*/                   ISETP.GE.AND P0, PT, R0, UR4, PT ;
        /*0090*/               @P0 EXIT ;
        /*00a0*/                   IABS R8, c[0x0][0x178] ;
        /*00b0*/                   ULDC.64 UR4, c[0x0][0x118] ;
        /*00c0*/                   IABS R7, c[0x0][0x174] ;
        /*00d0*/                   I2F.RP R4, R8 ;
        /*00e0*/                   MUFU.RCP R4, R4 ;
        /*00f0*/                   IADD3 R2, R4, 0xffffffe, RZ ;
        /*0100*/                   IABS R4, R0 ;
        /*0110*/                   F2I.FTZ.U32.TRUNC.NTZ R3, R2 ;
        /*0120*/                   MOV R2, RZ ;
        /*0130*/                   IMAD.MOV R5, RZ, RZ, -R3 ;
        /*0140*/                   IMAD R5, R5, R8, RZ ;
        /*0150*/                   IMAD.HI.U32 R3, R3, R5, R2 ;
        /*0160*/                   I2F.RP R5, R7 ;
        /*0170*/                   IMAD.HI.U32 R2, R3, R4, RZ ;
        /*0180*/                   IMAD.MOV R3, RZ, RZ, -R2 ;
        /*0190*/                   IMAD R3, R8, R3, R4 ;
        /*01a0*/                   LOP3.LUT R4, R0, c[0x0][0x178], RZ, 0x3c, !PT ;
        /*01b0*/                   MUFU.RCP R5, R5 ;
        /*01c0*/                   ISETP.GT.U32.AND P2, PT, R8, R3, PT ;
        /*01d0*/                   ISETP.GE.AND P1, PT, R4, RZ, PT ;
        /*01e0*/              @!P2 IMAD.IADD R3, R3, 0x1, -R8 ;
        /*01f0*/              @!P2 IADD3 R2, R2, 0x1, RZ ;
        /*0200*/                   IADD3 R6, R5, 0xffffffe, RZ ;
        /*0210*/                   ISETP.GE.U32.AND P0, PT, R3, R8, PT ;
        /*0220*/                   F2I.FTZ.U32.TRUNC.NTZ R3, R6 ;
        /*0230*/                   ISETP.NE.AND P2, PT, RZ, c[0x0][0x178], PT ;
        /*0240*/               @P0 IADD3 R2, R2, 0x1, RZ ;
        /*0250*/                   MOV R9, R2 ;
        /*0260*/                   IMAD.MOV R2, RZ, RZ, -R3 ;
        /*0270*/              @!P1 IMAD.MOV R9, RZ, RZ, -R9 ;
        /*0280*/              @!P2 LOP3.LUT R9, RZ, c[0x0][0x178], RZ, 0x33, !PT ;
        /*0290*/                   IMAD R5, R2, R7, RZ ;
        /*02a0*/                   MOV R2, RZ ;
        /*02b0*/                   IABS R4, R9 ;
        /*02c0*/                   ISETP.GE.AND P2, PT, R9, RZ, PT ;
        /*02d0*/                   IMAD.HI.U32 R2, R3, R5, R2 ;
        /*02e0*/                   IMAD.MOV.U32 R3, RZ, RZ, R4 ;
        /*02f0*/                   IMAD.HI.U32 R2, R2, R3, RZ ;
        /*0300*/                   IMAD.MOV R2, RZ, RZ, -R2 ;
        /*0310*/                   IMAD R2, R7, R2, R3 ;
        /*0320*/                   IADD3 R3, -R9, RZ, RZ ;
        /*0330*/                   ISETP.GT.U32.AND P0, PT, R7, R2, PT ;
        /*0340*/                   IMAD R0, R3, c[0x0][0x178], R0 ;
        /*0350*/                   MOV R3, 0x4 ;
        /*0360*/                   IMAD R0, R9, c[0x0][0x178], R0 ;
        /*0370*/                   IMAD.WIDE R4, R0, R3, c[0x0][0x160] ;
        /*0380*/              @!P0 IADD3 R2, R2, -R7, RZ ;
        /*0390*/                   LDG.E R0, [R4.64] ;
        /*03a0*/                   ISETP.NE.AND P0, PT, RZ, c[0x0][0x174], PT ;
        /*03b0*/                   ISETP.GT.U32.AND P1, PT, R7, R2, PT ;
        /*03c0*/              @!P1 IMAD.IADD R2, R2, 0x1, -R7 ;
        /*03d0*/              @!P2 IMAD.MOV R2, RZ, RZ, -R2 ;
        /*03e0*/              @!P0 LOP3.LUT R2, RZ, c[0x0][0x174], RZ, 0x33, !PT ;
        /*03f0*/                   IMAD.WIDE R2, R2, R3, c[0x0][0x168] ;
        /*0400*/                   LDG.E R3, [R2.64] ;
        /*0410*/                   FADD R7, R0, R3 ;
        /*0420*/                   STG.E [R4.64], R7 ;
        /*0430*/                   EXIT ;
.L_x_342:
        /*0440*/                   BRA `(.L_x_342);
        /*0450*/                   NOP;
        /*0460*/                   NOP;
        /*0470*/                   NOP;
        /*0480*/                   NOP;
        /*0490*/                   NOP;
        /*04a0*/                   NOP;
        /*04b0*/                   NOP;
        /*04c0*/                   NOP;
        /*04d0*/                   NOP;
        /*04e0*/                   NOP;
        /*04f0*/                   NOP;
.L_x_473:


//--------------------- .text.rand_uniform_kernel --------------------------
	.section	.text.rand_uniform_kernel,"ax",@progbits
	.sectioninfo	@"SHI_REGISTERS=8"
	.align	128
        .global         rand_uniform_kernel
        .type           rand_uniform_kernel,@function
        .size           rand_uniform_kernel,(.L_x_474 - rand_uniform_kernel)
        .other          rand_uniform_kernel,@"STO_CUDA_ENTRY STV_DEFAULT"
rand_uniform_kernel:
.text.rand_uniform_kernel:
        /*0000*/                   IMAD.MOV.U32 R1, RZ, RZ, c[0x0][0x28] ;
        /*0010*/                   S2R R2, SR_CTAID.X ;
        /*0020*/                   S2R R3, SR_TID.X ;
        /*0030*/                   IMAD R2, R2, c[0x0][0x0], R3 ;
        /*0040*/                   ISETP.GE.AND P0, PT, R2, c[0x0][0x160], PT ;
        /*0050*/               @P0 EXIT ;
        /*0060*/                   SHF.R.U32.HI R3, RZ, 0x10, R2 ;
        /*0070*/                   IMAD.MOV.U32 R5, RZ, RZ, 0x4 ;
        /*0080*/                   ULDC.64 UR4, c[0x0][0x118] ;
        /*0090*/                   LOP3.LUT R3, R3, R2, RZ, 0x3c, !PT ;
        /*00a0*/                   IMAD R3, R3, 0x7feb352d, RZ ;
        /*00b0*/                   SHF.R.U32.HI R0, RZ, 0xf, R3 ;
        /*00c0*/                   LOP3.LUT R0, R0, R3, RZ, 0x3c, !PT ;
        /*00d0*/                   IMAD R0, R0, -0x7b935975, RZ ;
        /*00e0*/                   SHF.R.U32.HI R3, RZ, 0x10, R0.reuse ;
        /*00f0*/                   LOP3.LUT R4, R0, c[0x0][0x170], RZ, 0x3c, !PT ;
        /*0100*/                   LOP3.LUT R3, R3, c[0x0][0x170], R0, 0x96, !PT ;
        /*0110*/                   SHF.R.U32.HI R4, RZ, 0x10, R4 ;
        /*0120*/                   LOP3.LUT R3, R4, R3, RZ, 0x3c, !PT ;
        /*0130*/                   IMAD R3, R3, 0x7feb352d, RZ ;
        /*0140*/                   SHF.R.U32.HI R0, RZ, 0xf, R3 ;
        /*0150*/                   LOP3.LUT R0, R0, R3, RZ, 0x3c, !PT ;
        /*0160*/                   IMAD R0, R0, -0x7b935975, RZ ;
        /*0170*/                   SHF.R.U32.HI R3, RZ, 0x10, R0 ;
        /*0180*/                   LOP3.LUT R3, R3, R0, RZ, 0x3c, !PT ;
        /*0190*/                   SHF.R.U32.HI R3, RZ, 0x8, R3 ;
        /*01a0*/                   I2FP.F32.U32 R0, R3 ;
        /*01b0*/                   IMAD.WIDE R2, R2, R5, c[0x0][0x168] ;
        /*01c0*/                   FMUL R5, R0, 5.9604644775390625e-08 ;
        /*01d0*/                   STG.E [R2.64], R5 ;
        /*01e0*/                   EXIT ;
.L_x_343:
        /*01f0*/                   BRA `(.L_x_343);
        /*0200*/                   NOP;
        /*0210*/                   NOP;
        /*0220*/                   NOP;
        /*0230*/                   NOP;
        /*0240*/                   NOP;
        /*0250*/                   NOP;
        /*0260*/                   NOP;
        /*0270*/                   NOP;
.L_x_474:


//--------------------- .text.constrain_kernel    --------------------------
	.section	.text.constrain_kernel,"ax",@progbits
	.sectioninfo	@"SHI_REGISTERS=8"
	.align	128
        .global         constrain_kernel
        .type           constrain_kernel,@function
        .size           constrain_kernel,(.L_x_475 - constrain_kernel)
        .other          constrain_kernel,@"STO_CUDA_ENTRY STV_DEFAULT"
constrain_kernel:
.text.constrain_kernel:
        /*0000*/                   IMAD.MOV.U32 R1, RZ, RZ, c[0x0][0x28] ;
        /*0010*/                   S2R R2, SR_CTAID.X ;
        /*0020*/                   S2R R3, SR_TID.X ;
        /*0030*/                   IMAD R2, R2, c[0x0][0x0], R3 ;
        /*0040*/                   ISETP.GE.AND P0, PT, R2, c[0x0][0x160], PT ;
        /*0050*/               @P0 EXIT ;
        /*0060*/                   MOV R3, 0x4 ;
        /*0070*/                   ULDC.64 UR4, c[0x0][0x118] ;
        /*0080*/                   IMAD.WIDE R2, R2, R3, c[0x0][0x168] ;
        /*0090*/                   LDG.E R0, [R2.64] ;
        /*00a0*/                   FMNMX R0, R0, -c[0x0][0x164], !PT ;
        /*00b0*/                   FMNMX R5, R0, c[0x0][0x164], PT ;
        /*00c0*/                   STG.E [R2.64], R5 ;
        /*00d0*/                   EXIT ;
.L_x_344:
        /*00e0*/                   BRA `(.L_x_344);
        /*00f0*/                   NOP;
        /*0100*/                   NOP;
        /*0110*/                   NOP;
        /*0120*/                   NOP;
        /*0130*/                   NOP;
        /*0140*/                   NOP;
        /*0150*/                   NOP;
        /*0160*/                   NOP;
        /*0170*/                   NOP;
.L_x_475:


//--------------------- .text.add_scalar_kernel   --------------------------
	.section	.text.add_scalar_kernel,"ax",@progbits
	.sectioninfo	@"SHI_REGISTERS=8"
	.align	128
        .global         add_scalar_kernel
        .type           add_scalar_kernel,@function
        .size           add_scalar_kernel,(.L_x_476 - add_scalar_kernel)
        .other          add_scalar_kernel,@"STO_CUDA_ENTRY STV_DEFAULT"
add_scalar_kernel:
.text.add_scalar_kernel:
        /*0000*/                   MOV R1, c[0x0][0x28] ;
        /*0010*/                   S2R R2, SR_CTAID.X ;
        /*0020*/                   S2R R3, SR_TID.X ;
        /*0030*/                   IMAD R2, R2, c[0x0][0x0], R3 ;
        /*0040*/                   ISETP.GE.AND P0, PT, R2, c[0x0][0x160], PT ;
        /*0050*/               @P0 EXIT ;
        /*0060*/                   MOV R3, 0x4 ;
        /*0070*/                   ULDC.64 UR4, c[0x0][0x118] ;
        /*0080*/                   IMAD.WIDE R2, R2, R3, c[0x0][0x168] ;
        /*0090*/                   LDG.E R0, [R2.64] ;
        /*00a0*/                   FADD R5, R0, c[0x0][0x164] ;
        /*00b0*/                   STG.E [R2.64], R5 ;
        /*00c0*/                   EXIT ;
.L_x_345:
        /*00d0*/                   BRA `(.L_x_345);
        /*00e0*/                   NOP;
        /*00f0*/                   NOP;
        /*0100*/                   NOP;
        /*0110*/                   NOP;
        /*0120*/                   NOP;
        /*0130*/                   NOP;
        /*0140*/                   NOP;
        /*0150*/                   NOP;
        /*0160*/                   NOP;
        /*0170*/                   NOP;
.L_x_476:


//--------------------- .text.mul_kernel          --------------------------
	.section	.text.mul_kernel,"ax",@progbits
	.sectioninfo	@"SHI_REGISTERS=10"
	.align	128
        .global         mul_kernel
        .type           mul_kernel,@function
        .size           mul_kernel,(.L_x_477 - mul_kernel)
        .other          mul_kernel,@"STO_CUDA_ENTRY STV_DEFAULT"
mul_kernel:
.text.mul_kernel:
        /*0000*/                   MOV R1, c[0x0][0x28] ;
        /*0010*/                   S2R R4, SR_CTAID.X ;
        /*0020*/                   S2R R3, SR_TID.X ;
        /*0030*/                   IMAD R4, R4, c[0x0][0x0], R3 ;
        /*0040*/                   ISETP.GE.AND P0, PT, R4, c[0x0][0x160], PT ;
        /*0050*/               @P0 EXIT ;
        /*0060*/                   MOV R5, 0x4 ;
        /*0070*/                   ULDC.64 UR4, c[0x0][0x118] ;
        /*0080*/                   IMAD.WIDE R2, R4, R5, c[0x0][0x168] ;
        /*0090*/                   IMAD.WIDE R4, R4, R5, c[0x0][0x170] ;
        /*00a0*/                   LDG.E R3, [R2.64] ;
        /*00b0*/                   LDG.E R0, [R4.64] ;
        /*00c0*/                   FMUL R7, R0, R3 ;
        /*00d0*/                   STG.E [R4.64], R7 ;
        /*00e0*/                   EXIT ;
.L_x_346:
        /*00f0*/                   BRA `(.L_x_346);
        /*0100*/                   NOP;
        /*0110*/                   NOP;
        /*0120*/                   NOP;
        /*0130*/                   NOP;
        /*0140*/                   NOP;
        /*0150*/                   NOP;
        /*0160*/                   NOP;
        /*0170*/                   NOP;
.L_x_477:


//--------------------- .text.scal_kernel         --------------------------
	.section	.text.scal_kernel,"ax",@progbits
	.sectioninfo	@"SHI_REGISTERS=8"
	.align	128
        .global         scal_kernel
        .type           scal_kernel,@function
        .size           scal_kernel,(.L_x_478 - scal_kernel)
        .other          scal_kernel,@"STO_CUDA_ENTRY STV_DEFAULT"
scal_kernel:
.text.scal_kernel:
        /*0000*/                   MOV R1, c[0x0][0x28] ;
        /*0010*/                   S2R R2, SR_CTAID.X ;
        /*0020*/                   S2R R3, SR_TID.X ;
        /*0030*/                   IMAD R2, R2, c[0x0][0x0], R3 ;
        /*0040*/                   ISETP.GE.AND P0, PT, R2, c[0x0][0x160], PT ;
        /*0050*/               @P0 EXIT ;
        /*0060*/                   MOV R3, 0x4 ;
        /*0070*/                   ULDC.64 UR4, c[0x0][0x118] ;
        /*0080*/                   IMAD.WIDE R2, R2, R3, c[0x0][0x168] ;
        /*0090*/                   LDG.E R0, [R2.64] ;
        /*00a0*/                   FMUL R5, R0, c[0x0][0x164] ;
        /*00b0*/                   STG.E [R2.64], R5 ;
        /*00c0*/                   EXIT ;
.L_x_347:
        /*00d0*/                   BRA `(.L_x_347);
        /*00e0*/                   NOP;
        /*00f0*/                   NOP;
        /*0100*/                   NOP;
        /*0110*/                   NOP;
        /*0120*/                   NOP;
        /*0130*/                   NOP;
        /*0140*/                   NOP;
        /*0150*/                   NOP;
        /*0160*/                   NOP;
        /*0170*/                   NOP;
.L_x_478:


//--------------------- .text.axpy_kernel         --------------------------
	.section	.text.axpy_kernel,"ax",@progbits
	.sectioninfo	@"SHI_REGISTERS=10"
	.align	128
        .global         axpy_kernel
        .type           axpy_kernel,@function
        .size           axpy_kernel,(.L_x_479 - axpy_kernel)
        .other          axpy_kernel,@"STO_CUDA_ENTRY STV_DEFAULT"
axpy_kernel:
.text.axpy_kernel:
        /*0000*/                   MOV R1, c[0x0][0x28] ;
        /*0010*/                   S2R R4, SR_CTAID.X ;
        /*0020*/                   S2R R3, SR_TID.X ;
        /*0030*/                   IMAD R4, R4, c[0x0][0x0], R3 ;
        /*0040*/                   ISETP.GE.AND P0, PT, R4, c[0x0][0x160], PT ;
        /*0050*/               @P0 EXIT ;
        /*0060*/                   MOV R5, 0x4 ;
        /*0070*/                   ULDC.64 UR4, c[0x0][0x118] ;
        /*0080*/                   IMAD.WIDE R2, R4, R5, c[0x0][0x168] ;
        /*0090*/                   IMAD.WIDE R4, R4, R5, c[0x0][0x170] ;
        /*00a0*/                   LDG.E R2, [R2.64] ;
        /*00b0*/                   LDG.E R7, [R4.64] ;
        /*00c0*/                   FFMA R7, R2, c[0x0][0x164], R7 ;
        /*00d0*/                   STG.E [R4.64], R7 ;
        /*00e0*/                   EXIT ;
.L_x_348:
        /*00f0*/                   BRA `(.L_x_348);
        /*0100*/                   NOP;
        /*0110*/                   NOP;
        /*0120*/                   NOP;
        /*0130*/                   NOP;
        /*0140*/                   NOP;
        /*0150*/                   NOP;
        /*0160*/                   NOP;
        /*0170*/                   NOP;
.L_x_479:


//--------------------- .text.copy_kernel         --------------------------
	.section	.text.copy_kernel,"ax",@progbits
	.sectioninfo	@"SHI_REGISTERS=8"
	.align	128
        .global         copy_kernel
        .type           copy_kernel,@function
        .size           copy_kernel,(.L_x_480 - copy_kernel)
        .other          copy_kernel,@"STO_CUDA_ENTRY STV_DEFAULT"
copy_kernel:
.text.copy_kernel:
        /*0000*/                   MOV R1, c[0x0][0x28] ;
        /*0010*/                   S2R R4, SR_CTAID.X ;
        /*0020*/                   S2R R3, SR_TID.X ;
        /*0030*/                   IMAD R4, R4, c[0x0][0x0], R3 ;
        /*0040*/                   ISETP.GE.AND P0, PT, R4, c[0x0][0x160], PT ;
        /*0050*/               @P0 EXIT ;
        /*0060*/                   MOV R5, 0x4 ;
        /*0070*/                   ULDC.64 UR4, c[0x0][0x118] ;
        /*0080*/                   IMAD.WIDE R2, R4, R5, c[0x0][0x168] ;
        /*0090*/                   LDG.E R3, [R2.64] ;
        /*00a0*/                   IMAD.WIDE R4, R4, R5, c[0x0][0x170] ;
        /*00b0*/                   STG.E [R4.64], R3 ;
        /*00c0*/                   EXIT ;
.L_x_349:
        /*00d0*/                   BRA `(.L_x_349);
        /*00e0*/                   NOP;
        /*00f0*/                   NOP;
        /*0100*/                   NOP;
        /*0110*/                   NOP;
        /*0120*/                   NOP;
        /*0130*/                   NOP;
        /*0140*/                   NOP;
        /*0150*/                   NOP;
        /*0160*/                   NOP;
        /*0170*/                   NOP;
.L_x_480:


//--------------------- .text.fill_kernel         --------------------------
	.section	.text.fill_kernel,"ax",@progbits
	.sectioninfo	@"SHI_REGISTERS=8"
	.align	128
        .global         fill_kernel
        .type           fill_kernel,@function
        .size           fill_kernel,(.L_x_481 - fill_kernel)
        .other          fill_kernel,@"STO_CUDA_ENTRY STV_DEFAULT"
fill_kernel:
.text.fill_kernel:
        /*0000*/                   MOV R1, c[0x0][0x28] ;
        /*0010*/                   S2R R2, SR_CTAID.X ;
        /*0020*/                   S2R R3, SR_TID.X ;
        /*0030*/                   IMAD R2, R2, c[0x0][0x0], R3 ;
        /*0040*/                   ISETP.GE.AND P0, PT, R2, c[0x0][0x160], PT ;
        /*0050*/               @P0 EXIT ;
        /*0060*/                   MOV R3, 0x4 ;
        /*0070*/                   ULDC.64 UR4, c[0x0][0x118] ;
        /*0080*/                   MOV R5, c[0x0][0x164] ;
        /*0090*/                   IMAD.WIDE R2, R2, R3, c[0x0][0x168] ;
        /*00a0*/                   STG.E [R2.64], R5 ;
        /*00b0*/                   EXIT ;
.L_x_350:
        /*00c0*/                   BRA `(.L_x_350);
        /*00d0*/                   NOP;
        /*00e0*/                   NOP;
        /*00f0*/                   NOP;
        /*0100*/                   NOP;
        /*0110*/                   NOP;
        /*0120*/                   NOP;
        /*0130*/                   NOP;
        /*0140*/                   NOP;
        /*0150*/                   NOP;
        /*0160*/                   NOP;
        /*0170*/                   NOP;
.L_x_481:


//--------------------- .text.gradient_array_kernel --------------------------
	.section	.text.gradient_array_kernel,"ax",@progbits
	.sectioninfo	@"SHI_REGISTERS=11"
	.align	128
        .global         gradient_array_kernel
        .type           gradient_array_kernel,@function
        .size           gradient_array_kernel,(.L_x_482 - gradient_array_kernel)
        .other          gradient_array_kernel,@"STO_CUDA_ENTRY STV_DEFAULT"
gradient_array_kernel:
.text.gradient_array_kernel:
        /*0000*/                   IMAD.MOV.U32 R1, RZ, RZ, c[0x0][0x28] ;
        /*0010*/                   S2R R0, SR_CTAID.X ;
        /*0020*/                   S2R R3, SR_TID.X ;
        /*0030*/                   IMAD R0, R0, c[0x0][0x0], R3 ;
        /*0040*/                   ISETP.GE.AND P0, PT, R0, c[0x0][0x168], PT ;
        /*0050*/               @P0 EXIT ;
        /*0060*/                   IMAD.MOV.U32 R7, RZ, RZ, c[0x0][0x16c] ;
        /*0070*/                   ULDC.64 UR4, c[0x0][0x118] ;
        /*0080*/                   IMAD.MOV.U32 R5, RZ, RZ, 0x4 ;
        /*0090*/                   ISETP.GT.AND P0, PT, R7, 0x6, PT ;
        /*00a0*/                   IMAD.WIDE R4, R0, R5, c[0x0][0x160] ;
        /*00b0*/                   SHF.R.S32.HI R3, RZ, 0x1f, R0 ;
        /*00c0*/                   LDG.E R2, [R4.64] ;
        /*00d0*/                   IMAD.MOV.U32 R8, RZ, RZ, 0x3f800000 ;
        /*00e0*/               @P0 BRA `(.L_x_351) ;
        /*00f0*/                   ISETP.GT.AND P0, PT, R7, 0x2, PT ;
        /*0100*/                   IMAD.MOV.U32 R6, RZ, RZ, 0x3f800000 ;
        /*0110*/               @P0 BRA `(.L_x_352) ;
        /*0120*/                   IMNMX.U32 R4, R7, 0x3, PT ;
        /*0130*/                   IMAD.SHL.U32 R6, R4, 0x4, RZ ;
        /*0140*/                   LDC R4, c[0x2][R6+0x18] ;
        /*0150*/                   SHF.R.S32.HI R5, RZ, 0x1f, R4 ;
.L_x_393:
        /*0160*/                   BRX R4 -0x170                                                            (*"BRANCH_TARGETS .L_x_394,.L_x_395,.L_x_396,.L_x_397"*);
.L_x_396:
        /*0170*/                   FSETP.GT.AND P0, PT, R2, RZ, PT ;
        /*0180*/                   FSEL R6, R8, 0.0099999997764825820923, P0 ;
        /*0190*/                   BRA `(.L_x_353) ;
.L_x_394:
        /*01a0*/                   FADD R5, -R2, 1 ;
        /*01b0*/                   FMUL R6, R2, R5 ;
        /*01c0*/                   BRA `(.L_x_353) ;
.L_x_395:
        /*01d0*/                   FSET.BF.GT.AND R6, R2, RZ, PT ;
        /*01e0*/                   BRA `(.L_x_353) ;
.L_x_352:
        /*01f0*/                   ISETP.GT.AND P0, PT, R7, 0x4, PT ;
        /*0200*/               @P0 BRA `(.L_x_354) ;
        /*0210*/                   IADD3 R4, R7, -0x3, RZ ;
        /*0220*/                   IMNMX.U32 R4, R4, 0x2, PT ;
        /*0230*/                   IMAD.SHL.U32 R7, R4, 0x4, RZ ;
        /*0240*/                   LDC R4, c[0x2][R7] ;
        /*0250*/                   SHF.R.S32.HI R5, RZ, 0x1f, R4 ;
.L_x_398:
        /*0260*/                   BRX R4 -0x270                                                            (*"BRANCH_TARGETS .L_x_353,.L_x_400,.L_x_397"*);
.L_x_400:
        /*0270*/                   IMAD.MOV.U32 R6, RZ, RZ, 0x3f8ccccd ;
        /*0280*/                   FSETP.GT.AND P0, PT, R2, RZ, PT ;
        /*0290*/                   FSEL R6, R6, 0.10000000149011611938, P0 ;
        /*02a0*/                   BRA `(.L_x_353) ;
.L_x_354:
        /*02b0*/                   IADD3 R4, R7, -0x5, RZ ;
        /*02c0*/                   IMNMX.U32 R4, R4, 0x2, PT ;
        /*02d0*/                   IMAD.SHL.U32 R6, R4, 0x4, RZ ;
        /*02e0*/                   LDC R4, c[0x2][R6+0x38] ;
        /*02f0*/                   SHF.R.S32.HI R5, RZ, 0x1f, R4 ;
.L_x_402:
        /*0300*/                   BRX R4 -0x310                                                            (*"BRANCH_TARGETS .L_x_403,.L_x_404,.L_x_397"*);
.L_x_404:
        /*0310*/                   FSETP.GT.AND P0, PT, R2, 1, PT ;
        /*0320*/                   IMAD.MOV.U32 R6, RZ, RZ, 0x3c23d70a ;
        /*0330*/                   FSETP.LT.OR P0, PT, R2, RZ, P0 ;
        /*0340*/                   FSEL R6, R6, 0.125, P0 ;
        /*0350*/                   BRA `(.L_x_353) ;
.L_x_403:
        /*0360*/                   FFMA R6, -R2, R2, 1 ;
        /*0370*/                   BRA `(.L_x_353) ;
.L_x_351:
        /*0380*/                   ISETP.GT.AND P0, PT, R7, 0x9, PT ;
        /*0390*/               @P0 BRA `(.L_x_355) ;
        /*03a0*/                   IADD3 R4, R7, -0x7, RZ ;
        /*03b0*/                   IMNMX.U32 R4, R4, 0x3, PT ;
        /*03c0*/                   IMAD.SHL.U32 R6, R4, 0x4, RZ ;
        /*03d0*/                   LDC R4, c[0x2][R6+0x28] ;
        /*03e0*/                   SHF.R.S32.HI R5, RZ, 0x1f, R4 ;
.L_x_406:
        /*03f0*/                   BRX R4 -0x400                                                            (*"BRANCH_TARGETS .L_x_407,.L_x_408,.L_x_409,.L_x_397"*);
.L_x_409:
        /*0400*/                   FADD R2, R2, 1 ;
        /*0410*/                   FMUL R2, R2, 0.5 ;
        /*0420*/                   FADD R4, -R2, 1 ;
        /*0430*/                   FADD R5, R4, R4 ;
        /*0440*/                   FMUL R6, R2, R5 ;
        /*0450*/                   BRA `(.L_x_353) ;
.L_x_407:
        /*0460*/                   FSETP.GT.AND P0, PT, R2, RZ, PT ;
        /*0470*/                   FSEL R6, R8, 0.10000000149011611938, P0 ;
        /*0480*/                   BRA `(.L_x_353) ;
.L_x_408:
        /*0490*/                   FSET.BF.GE.AND R6, R2.reuse, RZ, PT ;
        /*04a0*/                   FADD R7, R2.reuse, 1 ;
        /*04b0*/                   FSET.BF.LT.AND R5, R2, RZ, PT ;
        /*04c0*/                   FFMA R6, R7, R5, R6 ;
        /*04d0*/                   BRA `(.L_x_353) ;
.L_x_355:
        /*04e0*/                   ISETP.GT.AND P0, PT, R7, 0xb, PT ;
        /*04f0*/               @P0 BRA `(.L_x_356) ;
        /*0500*/                   IADD3 R4, R7, -0xa, RZ ;
        /*0510*/                   IMNMX.U32 R4, R4, 0x2, PT ;
        /*0520*/                   IMAD.SHL.U32 R6, R4, 0x4, RZ ;
        /*0530*/                   LDC R4, c[0x2][R6+0xc] ;
        /*0540*/                   SHF.R.S32.HI R5, RZ, 0x1f, R4 ;
.L_x_411:
        /*0550*/                   BRX R4 -0x560                                                            (*"BRANCH_TARGETS .L_x_412,.L_x_413,.L_x_397"*);
.L_x_413:
        /*0560*/                   FSETP.GEU.AND P0, PT, R2, 1, PT ;
        /*0570*/                   FSETP.GT.AND P0, PT, R2, -1, !P0 ;
        /*0580*/                   SEL R6, RZ, 0x1, !P0 ;
        /*0590*/                   I2FP.F32.U32 R6, R6 ;
        /*05a0*/                   BRA `(.L_x_353) ;
.L_x_412:
        /*05b0*/                   FRND.FLOOR R5, R2 ;
        /*05c0*/                   FSET.BF.NEU.AND R6, R5, R2, PT ;
        /*05d0*/                   BRA `(.L_x_353) ;
.L_x_356:
        /*05e0*/                   ISETP.NE.AND P0, PT, R7, 0xc, PT ;
        /*05f0*/              @!P0 BRA `(.L_x_357) ;
        /*0600*/                   ISETP.NE.AND P0, PT, R7, 0xd, PT ;
        /*0610*/              @!P0 FSET.BF.LT.AND R7, R2.reuse, RZ, PT ;
        /*0620*/              @!P0 FADD R4, R2.reuse, 1.7580311298370361328 ;
        /*0630*/              @!P0 FSET.BF.GE.AND R5, R2, RZ, PT ;
        /*0640*/              @!P0 FMUL R4, R4, R7 ;
        /*0650*/              @!P0 FFMA R6, R5, 1.0506999492645263672, R4 ;
        /*0660*/              @!P0 BRA `(.L_x_353) ;
.L_x_397:
        /*0670*/                   IMAD.MOV.U32 R6, RZ, RZ, RZ ;
        /*0680*/                   BRA `(.L_x_353) ;
.L_x_357:
        /*0690*/                   FSETP.GEU.AND P0, PT, R2, 1, PT ;
        /*06a0*/                   FSETP.GT.AND P0, PT, R2, RZ, !P0 ;
        /*06b0*/                   FSEL R6, R8, 0.0010000000474974513054, P0 ;
.L_x_353:
        /*06c0*/                   LEA R2, P0, R0, c[0x0][0x170], 0x2 ;
        /*06d0*/                   LEA.HI.X R3, R0, c[0x0][0x174], R3, 0x2, P0 ;
        /*06e0*/                   LDG.E R5, [R2.64] ;
        /*06f0*/                   FMUL R5, R5, R6 ;
        /*0700*/                   STG.E [R2.64], R5 ;
        /*0710*/                   EXIT ;
.L_x_358:
        /*0720*/                   BRA `(.L_x_358);
        /*0730*/                   NOP;
        /*0740*/                   NOP;
        /*0750*/                   NOP;
        /*0760*/                   NOP;
        /*0770*/                   NOP;
        /*0780*/                   NOP;
        /*0790*/                   NOP;
        /*07a0*/                   NOP;
        /*07b0*/                   NOP;
        /*07c0*/                   NOP;
        /*07d0*/                   NOP;
        /*07e0*/                   NOP;
        /*07f0*/                   NOP;
.L_x_482:


//--------------------- .text.activate_array_kernel --------------------------
	.section	.text.activate_array_kernel,"ax",@progbits
	.sectioninfo	@"SHI_REGISTERS=16"
	.align	128
        .global         activate_array_kernel
        .type           activate_array_kernel,@function
        .size           activate_array_kernel,(.L_x_447 - activate_array_kernel)
        .other          activate_array_kernel,@"STO_CUDA_ENTRY STV_DEFAULT"
activate_array_kernel:
.text.activate_array_kernel:
        /*0000*/                   IMAD.MOV.U32 R1, RZ, RZ, c[0x0][0x28] ;
        /*0010*/                   S2R R4, SR_CTAID.X ;
        /*0020*/                   S2R R3, SR_TID.X ;
        /*0030*/                   IMAD R4, R4, c[0x0][0x0], R3 ;
        /*0040*/                   ISETP.GE.AND P0, PT, R4, c[0x0][0x168], PT ;
        /*0050*/               @P0 EXIT ;
        /*0060*/                   IMAD.MOV.U32 R5, RZ, RZ, 0x4 ;
        /*0070*/                   ULDC.64 UR4, c[0x0][0x118] ;
        /*0080*/                   IMAD.WIDE R4, R4, R5, c[0x0][0x160] ;
        /*0090*/                   LDG.E R0, [R4.64] ;
        /*00a0*/                   IMAD.MOV.U32 R2, RZ, RZ, c[0x0][0x16c] ;
        /*00b0*/                   BSSY B0, `(.L_x_359) ;
        /*00c0*/                   IMAD.MOV.U32 R6, RZ, RZ, 0x40000000 ;
        /*00d0*/                   ISETP.GT.AND P0, PT, R2, 0x6, PT ;
        /*00e0*/               @P0 BRA `(.L_x_360) ;
        /*00f0*/                   ISETP.GT.AND P0, PT, R2, 0x2, PT ;
        /*0100*/               @P0 BRA `(.L_x_361) ;
        /*0110*/                   IMNMX.U32 R2, R2, 0x3, PT ;
        /*0120*/                   SHF.L.U32 R6, R2, 0x2, RZ ;
        /*0130*/                   LDC R2, c[0x2][R6+0xc] ;
        /*0140*/                   SHF.R.S32.HI R3, RZ, 0x1f, R2 ;
.L_x_415:
        /*0150*/                   BRX R2 -0x160                                                            (*"BRANCH_TARGETS .L_x_416,.L_x_417,.L_x_418,.L_x_367"*);
.L_x_418:
        /*0160*/                   FMUL R3, R0.reuse, 0.0099999997764825820923 ;
        /*0170*/                   FSETP.GT.AND P0, PT, R0, RZ, PT ;
        /*0180*/                   FSEL R3, R0, R3, P0 ;
        /*0190*/                   BRA `(.L_x_362) ;
.L_x_416:
        /*01a0*/                   IMAD.MOV.U32 R3, RZ, RZ, 0x3bbb989d ;
        /*01b0*/                   BSSY B1, `(.L_x_363) ;
        /*01c0*/                   IMAD.MOV.U32 R7, RZ, RZ, 0x437c0000 ;
        /*01d0*/                   FFMA.SAT R2, -R0, R3, 0.5 ;
        /*01e0*/                   FFMA.RM R2, R2, R7, 12582913 ;
        /*01f0*/                   FADD R3, R2.reuse, -12583039 ;
        /*0200*/                   IMAD.SHL.U32 R2, R2, 0x800000, RZ ;
        /*0210*/                   FFMA R3, -R0, 1.4426950216293334961, -R3 ;
        /*0220*/                   FFMA R3, -R0, 1.925963033500011079e-08, R3 ;
        /*0230*/                   MUFU.EX2 R3, R3 ;
        /*0240*/                   FFMA R0, R2, R3, 1 ;
        /*0250*/                   IADD3 R2, R0, 0x1800000, RZ ;
        /*0260*/                   LOP3.LUT R2, R2, 0x7f800000, RZ, 0xc0, !PT ;
        /*0270*/                   ISETP.GT.U32.AND P0, PT, R2, 0x1ffffff, PT ;
        /*0280*/               @P0 BRA `(.L_x_364) ;
        /*0290*/                   MOV R10, 0x2b0 ;
        /*02a0*/                   CALL.REL.NOINC `($__internal_13_$__cuda_sm20_rcp_rn_f32_slowpath) ;
        /*02b0*/                   IMAD.MOV.U32 R3, RZ, RZ, R0 ;
        /*02c0*/                   BRA `(.L_x_365) ;
.L_x_364:
        /*02d0*/                   MUFU.RCP R3, R0 ;
        /*02e0*/                   FFMA R2, R0, R3, -1 ;
        /*02f0*/                   FADD.FTZ R2, -R2, -RZ ;
        /*0300*/                   FFMA R3, R3, R2, R3 ;
.L_x_365:
        /*0310*/                   BSYNC B1 ;
.L_x_363:
        /*0320*/                   BRA `(.L_x_362) ;
.L_x_417:
        /*0330*/                   FSET.BF.GT.AND R3, R0, RZ, PT ;
        /*0340*/                   FMUL R3, R0, R3 ;
        /*0350*/                   BRA `(.L_x_362) ;
.L_x_361:
        /*0360*/                   ISETP.GT.AND P0, PT, R2, 0x4, PT ;
        /*0370*/               @P0 BRA `(.L_x_366) ;
        /*0380*/                   ISETP.NE.AND P0, PT, R2, 0x3, PT ;
        /*0390*/                   MOV R3, R0 ;
        /*03a0*/              @!P0 BRA `(.L_x_362) ;
        /*03b0*/                   ISETP.NE.AND P0, PT, R2, 0x4, PT ;
        /*03c0*/               @P0 BRA `(.L_x_367) ;
        /*03d0*/                   FSET.BF.GT.AND R3, R0, RZ, PT ;
        /*03e0*/                   FMUL R3, R0, R3 ;
        /*03f0*/                   FFMA R3, R0, 0.10000000149011611938, R3 ;
        /*0400*/                   BRA `(.L_x_362) ;
.L_x_366:
        /*0410*/                   IADD3 R2, R2, -0x5, RZ ;
        /*0420*/                   IMNMX.U32 R2, R2, 0x2, PT ;
        /*0430*/                   IMAD.SHL.U32 R7, R2, 0x4, RZ ;
        /*0440*/                   LDC R2, c[0x2][R7+0x2c] ;
        /*0450*/                   SHF.R.S32.HI R3, RZ, 0x1f, R2 ;
.L_x_420:
        /*0460*/                   BRX R2 -0x470                                                            (*"BRANCH_TARGETS .L_x_421,.L_x_422,.L_x_367"*);
.L_x_422:
        /*0470*/                   FSETP.GEU.AND P0, PT, R0, -4, PT ;
        /*0480*/              @!P0 BRA `(.L_x_368) ;
        /*0490*/                   FSETP.GT.AND P0, PT, R0, 4, PT ;
        /*04a0*/              @!P0 IMAD.MOV.U32 R3, RZ, RZ, 0x3e000000 ;
        /*04b0*/               @P0 FADD R2, R0.reuse, -4 ;
        /*04c0*/               @P0 IMAD.MOV.U32 R7, RZ, RZ, 0x3c23d70a ;
        /*04d0*/              @!P0 FFMA R3, R0, R3, 0.5 ;
        /*04e0*/               @P0 FFMA R3, R2, R7, 1 ;
        /*04f0*/                   BRA `(.L_x_362) ;
.L_x_368:
        /*0500*/                   FADD R0, R0, 4 ;
        /*0510*/                   FMUL R3, R0, 0.0099999997764825820923 ;
        /*0520*/                   BRA `(.L_x_362) ;
.L_x_421:
        /*0530*/                   IMAD.MOV.U32 R3, RZ, RZ, 0x3bbb989d ;
        /*0540*/                   FMUL R0, R0, -2 ;
        /*0550*/                   MOV R7, 0x437c0000 ;
        /*0560*/                   BSSY B1, `(.L_x_369) ;
        /*0570*/                   FFMA.SAT R2, R0, R3, 0.5 ;
        /*0580*/                   FFMA.RM R2, R2, R7, 12582913 ;
        /*0590*/                   FADD R3, R2.reuse, -12583039 ;
        /*05a0*/                   IMAD.SHL.U32 R2, R2, 0x800000, RZ ;
        /*05b0*/                   FFMA R3, R0, 1.4426950216293334961, -R3 ;
        /*05c0*/                   FFMA R3, R0, 1.925963033500011079e-08, R3 ;
        /*05d0*/                   MUFU.EX2 R3, R3 ;
        /*05e0*/                   FFMA R3, R2, R3, 1 ;
        /*05f0*/                   MUFU.RCP R0, R3 ;
        /*0600*/                   FCHK P0, R6, R3 ;
        /*0610*/                   FFMA R7, -R3, R0, 1 ;
        /*0620*/                   FFMA R0, R0, R7, R0 ;
        /*0630*/                   FFMA R2, R0, 2, RZ ;
        /*0640*/                   FFMA R7, -R3, R2, 2 ;
        /*0650*/                   FFMA R0, R0, R7, R2 ;
        /*0660*/              @!P0 BRA `(.L_x_370) ;
        /*0670*/                   MOV R2, 0x690 ;
        /*0680*/                   CALL.REL.NOINC `($__internal_14_$__cuda_sm3x_div_rn_noftz_f32_slowpath) ;
        /*0690*/                   IMAD.MOV.U32 R0, RZ, RZ, R7 ;
.L_x_370:
        /*06a0*/                   BSYNC B1 ;
.L_x_369:
        /*06b0*/                   FADD R3, R0, -1 ;
        /*06c0*/                   BRA `(.L_x_362) ;
.L_x_360:
        /*06d0*/                   ISETP.GT.AND P0, PT, R2, 0x9, PT ;
        /*06e0*/               @P0 BRA `(.L_x_371) ;
        /*06f0*/                   IADD3 R2, R2, -0x7, RZ ;
        /*0700*/                   IMNMX.U32 R2, R2, 0x3, PT ;
        /*0710*/                   IMAD.SHL.U32 R7, R2, 0x4, RZ ;
        /*0720*/                   LDC R2, c[0x2][R7+0x1c] ;
        /*0730*/                   SHF.R.S32.HI R3, RZ, 0x1f, R2 ;
.L_x_424:
        /*0740*/                   BRX R2 -0x750                                                            (*"BRANCH_TARGETS .L_x_425,.L_x_426,.L_x_427,.L_x_367"*);
.L_x_427:
        /*0750*/                   IMAD.MOV.U32 R3, RZ, RZ, 0x3bbb989d ;
        /*0760*/                   MOV R2, 0x437c0000 ;
        /*0770*/                   BSSY B1, `(.L_x_372) ;
        /*0780*/                   FFMA.SAT R3, -R0, R3, 0.5 ;
        /*0790*/                   FFMA.RM R2, R3, R2, 12582913 ;
        /*07a0*/                   FADD R3, R2.reuse, -12583039 ;
        /*07b0*/                   IMAD.SHL.U32 R2, R2, 0x800000, RZ ;
        /*07c0*/                   FFMA R3, -R0, 1.4426950216293334961, -R3 ;
        /*07d0*/                   FFMA R7, -R0, 1.925963033500011079e-08, R3 ;
        /*07e0*/                   MUFU.EX2 R7, R7 ;
        /*07f0*/                   FFMA R8, R2, R7, 1 ;
        /*0800*/                   MUFU.RCP R3, R8 ;
        /*0810*/                   FCHK P0, R6, R8 ;
        /*0820*/                   FFMA R0, -R8, R3, 1 ;
        /*0830*/                   FFMA R0, R0, R3, R3 ;
        /*0840*/                   FFMA R3, R0, 2, RZ ;
        /*0850*/                   FFMA R2, R3, -R8, 2 ;
        /*0860*/                   FFMA R3, R0, R2, R3 ;
        /*0870*/              @!P0 BRA `(.L_x_373) ;
        /*0880*/                   IMAD.MOV.U32 R3, RZ, RZ, R8 ;
        /*0890*/                   MOV R2, 0x8b0 ;
        /*08a0*/                   CALL.REL.NOINC `($__internal_14_$__cuda_sm3x_div_rn_noftz_f32_slowpath) ;
        /*08b0*/                   IMAD.MOV.U32 R3, RZ, RZ, R7 ;
.L_x_373:
        /*08c0*/                   BSYNC B1 ;
.L_x_372:
        /*08d0*/                   FADD R3, R3, -1 ;
        /*08e0*/                   BRA `(.L_x_362) ;
.L_x_425:
        /*08f0*/                   FMUL R3, R0.reuse, 0.10000000149011611938 ;
        /*0900*/                   FSETP.GT.AND P0, PT, R0, RZ, PT ;
        /*0910*/                   FSEL R3, R0, R3, P0 ;
        /*0920*/                   BRA `(.L_x_362) ;
.L_x_426:
        /*0930*/                   IMAD.MOV.U32 R3, RZ, RZ, 0x3bbb989d ;
        /*0940*/                   MOV R7, 0x437c0000 ;
        /*0950*/                   FFMA.SAT R2, R0, R3, 0.5 ;
        /*0960*/                   FFMA.RM R2, R2, R7, 12582913 ;
        /*0970*/                   FADD R3, R2, -12583039 ;
        /*0980*/                   FFMA R3, R0, 1.4426950216293334961, -R3 ;
        /*0990*/                   FFMA R6, R0, 1.925963033500011079e-08, R3 ;
        /*09a0*/                   IMAD.SHL.U32 R3, R2, 0x800000, RZ ;
        /*09b0*/                   FSET.BF.LT.AND R2, R0, RZ, PT ;
        /*09c0*/                   MUFU.EX2 R6, R6 ;
        /*09d0*/                   FFMA R7, R3, R6, -1 ;
        /*09e0*/                   FSET.BF.GE.AND R3, R0, RZ, PT ;
        /*09f0*/                   FMUL R7, R2, R7 ;
        /*0a00*/                   FFMA R3, R0, R3, R7 ;
        /*0a10*/                   BRA `(.L_x_362) ;
.L_x_371:
        /*0a20*/                   ISETP.GT.AND P0, PT, R2, 0xb, PT ;
        /*0a30*/               @P0 BRA `(.L_x_374) ;
        /*0a40*/                   IADD3 R2, R2, -0xa, RZ ;
        /*0a50*/                   IMNMX.U32 R2, R2, 0x2, PT ;
        /*0a60*/                   IMAD.SHL.U32 R6, R2, 0x4, RZ ;
        /*0a70*/                   LDC R2, c[0x2][R6] ;
        /*0a80*/                   SHF.R.S32.HI R3, RZ, 0x1f, R2 ;
.L_x_429:
        /*0a90*/                   BRX R2 -0xaa0                                                            (*"BRANCH_TARGETS .L_x_430,.L_x_431,.L_x_367"*);
.L_x_431:
        /*0aa0*/                   FSETP.GEU.AND P0, PT, R0, -1, PT ;
        /*0ab0*/                   IMAD.MOV.U32 R3, RZ, RZ, -0x40800000 ;
        /*0ac0*/              @!P0 BRA `(.L_x_362) ;
        /*0ad0*/                   FMNMX.NAN R3, R0, 1, PT ;
        /*0ae0*/                   BRA `(.L_x_362) ;
.L_x_430:
        /*0af0*/                   F2I.FLOOR.NTZ R2, R0 ;
        /*0b00*/                   FMUL R6, R0, 0.5 ;
        /*0b10*/                   FRND.FLOOR R6, R6 ;
        /*0b20*/                   LOP3.LUT R3, R2, 0x1, RZ, 0xc0, !PT ;
        /*0b30*/                   ISETP.NE.U32.AND P0, PT, R3, 0x1, PT ;
        /*0b40*/              @!P0 I2FP.F32.S32 R3, R2 ;
        /*0b50*/              @!P0 FADD R3, R0, -R3 ;
        /*0b60*/              @!P0 FADD R3, R3, R6.reuse ;
        /*0b70*/               @P0 IMAD.MOV.U32 R3, RZ, RZ, R6 ;
        /*0b80*/                   BRA `(.L_x_362) ;
.L_x_374:
        /*0b90*/                   ISETP.NE.AND P0, PT, R2, 0xc, PT ;
        /*0ba0*/              @!P0 BRA `(.L_x_375) ;
        /*0bb0*/                   ISETP.NE.AND P0, PT, R2, 0xd, PT ;
        /*0bc0*/               @P0 BRA `(.L_x_367) ;
        /*0bd0*/                   MOV R3, 0x3bbb989d ;
        /*0be0*/                   IMAD.MOV.U32 R2, RZ, RZ, 0x437c0000 ;
        /*0bf0*/                   FSETP.GEU.AND P1, PT, R0.reuse, RZ, PT ;
        /*0c00*/                   FSETP.GE.AND P0, PT, R0.reuse, RZ, PT ;
        /*0c10*/                   FFMA.SAT R3, R0, R3, 0.5 ;
        /*0c20*/                   FFMA.RM R2, R3, R2, 12582913 ;
        /*0c30*/                   FADD R3, R2, -12583039 ;
        /*0c40*/                   FFMA R3, R0, 1.4426950216293334961, -R3 ;
        /*0c50*/                   FFMA R6, R0, 1.925963033500011079e-08, R3 ;
        /*0c60*/                   IMAD.SHL.U32 R3, R2, 0x800000, RZ ;
        /*0c70*/                   FSEL R2, RZ, 1.7580311298370361328, P1 ;
        /*0c80*/                   MUFU.EX2 R6, R6 ;
        /*0c90*/                   FFMA R7, R3, R6, -1 ;
        /*0ca0*/                   FSEL R3, RZ, 1.0506999492645263672, !P0 ;
        /*0cb0*/                   FMUL R7, R2, R7 ;
        /*0cc0*/                   FFMA R3, R0, R3, R7 ;
        /*0cd0*/                   BRA `(.L_x_362) ;
.L_x_367:
        /*0ce0*/                   IMAD.MOV.U32 R3, RZ, RZ, RZ ;
        /*0cf0*/                   BRA `(.L_x_362) ;
.L_x_375:
        /*0d00*/                   FSETP.GEU.AND P0, PT, R0, RZ, PT ;
        /*0d10*/              @!P0 BRA `(.L_x_376) ;
        /*0d20*/                   FSETP.GT.AND P0, PT, R0, 1, PT ;
        /*0d30*/                   MOV R3, R0 ;
        /*0d40*/              @!P0 BRA `(.L_x_362) ;
        /*0d50*/                   IMAD.MOV.U32 R3, RZ, RZ, 0x3a83126f ;
        /*0d60*/                   FADD R0, R0, -1 ;
        /*0d70*/                   FFMA R3, R0, R3, 1 ;
        /*0d80*/                   BRA `(.L_x_362) ;
.L_x_376:
        /*0d90*/                   FMUL R3, R0, 0.0010000000474974513054 ;
.L_x_362:
        /*0da0*/                   BSYNC B0 ;
.L_x_359:
        /*0db0*/                   STG.E [R4.64], R3 ;
        /*0dc0*/                   EXIT ;
        .weak           $__internal_13_$__cuda_sm20_rcp_rn_f32_slowpath
        .type           $__internal_13_$__cuda_sm20_rcp_rn_f32_slowpath,@function
        .size           $__internal_13_$__cuda_sm20_rcp_rn_f32_slowpath,($__internal_14_$__cuda_sm3x_div_rn_noftz_f32_slowpath - $__internal_13_$__cuda_sm20_rcp_rn_f32_slowpath)
$__internal_13_$__cuda_sm20_rcp_rn_f32_slowpath:
        /*0dd0*/                   IMAD.SHL.U32 R2, R0, 0x2, RZ ;
        /*0de0*/                   BSSY B2, `(.L_x_377) ;
        /*0df0*/                   SHF.R.U32.HI R2, RZ, 0x18, R2 ;
        /*0e00*/                   ISETP.NE.U32.AND P0, PT, R2, RZ, PT ;
        /*0e10*/               @P0 BRA `(.L_x_378) ;
        /*0e20*/                   IMAD.SHL.U32 R2, R0, 0x2, RZ ;
        /*0e30*/                   ISETP.NE.AND P0, PT, R2, RZ, PT ;
        /*0e40*/               @P0 FFMA R6, R0, 1.84467440737095516160e+19, RZ ;
        /*0e50*/              @!P0 MUFU.RCP R3, R0 ;
        /*0e60*/               @P0 MUFU.RCP R7, R6 ;
        /*0e70*/               @P0 FFMA R2, R6, R7, -1 ;
        /*0e80*/               @P0 FADD.FTZ R2, -R2, -RZ ;
        /*0e90*/               @P0 FFMA R2, R7, R2, R7 ;
        /*0ea0*/               @P0 FFMA R3, R2, 1.84467440737095516160e+19, RZ ;
        /*0eb0*/                   BRA `(.L_x_379) ;
.L_x_378:
        /*0ec0*/                   IADD3 R3, R2, -0xfd, RZ ;
        /*0ed0*/                   ISETP.GT.U32.AND P0, PT, R3, 0x1, PT ;
        /*0ee0*/               @P0 BRA `(.L_x_380) ;
        /*0ef0*/                   LOP3.LUT R6, R0, 0x7fffff, RZ, 0xc0, !PT ;
        /*0f00*/                   MOV R12, 0x3 ;
        /*0f10*/                   LOP3.LUT R6, R6, 0x3f800000, RZ, 0xfc, !PT ;
        /*0f20*/                   SHF.L.U32 R11, R12, R3, RZ ;
        /*0f30*/                   MUFU.RCP R7, R6 ;
        /*0f40*/                   FFMA R8, R6, R7, -1 ;
        /*0f50*/                   FADD.FTZ R8, -R8, -RZ ;
        /*0f60*/                   FFMA.RM R9, R7.reuse, R8.reuse, R7.reuse ;
        /*0f70*/                   FFMA.RP R8, R7, R8, R7 ;
        /*0f80*/                   LOP3.LUT R7, R9.reuse, 0x7fffff, RZ, 0xc0, !PT ;
        /*0f90*/                   FSETP.NEU.FTZ.AND P0, PT, R9, R8, PT ;
        /*0fa0*/                   LOP3.LUT R8, R7, 0x800000, RZ, 0xfc, !PT ;
        /*0fb0*/                   SEL R7, RZ, 0xffffffff, !P0 ;
        /*0fc0*/                   LOP3.LUT R6, R11, R8, RZ, 0xc0, !PT ;
        /*0fd0*/                   IMAD.MOV R7, RZ, RZ, -R7 ;
        /*0fe0*/                   SHF.R.U32.HI R6, RZ, R3, R6 ;
        /*0ff0*/                   LOP3.LUT P1, RZ, R7, R3, R8, 0xf8, !PT ;
        /*1000*/                   LOP3.LUT P0, RZ, R6.reuse, 0x1, RZ, 0xc0, !PT ;
        /*1010*/                   LOP3.LUT P2, RZ, R6, 0x2, RZ, 0xc0, !PT ;
        /*1020*/                   PLOP3.LUT P0, PT, P0, P1, P2, 0xe0, 0x0 ;
        /*1030*/                   LOP3.LUT P1, RZ, R0, 0x7fffff, RZ, 0xc0, !PT ;
        /*1040*/                   SEL R3, RZ, 0x1, !P0 ;
        /*1050*/                   IMAD.MOV R3, RZ, RZ, -R3 ;
        /*1060*/                   ISETP.GE.AND P0, PT, R3, RZ, PT ;
        /*1070*/                   IADD3 R3, R2, -0xfc, RZ ;
        /*1080*/                   SHF.R.U32.HI R3, RZ, R3, R8 ;
        /*1090*/              @!P0 IADD3 R3, R3, 0x1, RZ ;
        /*10a0*/              @!P1 IMAD.SHL.U32 R3, R3, 0x2, RZ ;
        /*10b0*/                   LOP3.LUT R3, R3, 0x80000000, R0, 0xf8, !PT ;
        /*10c0*/                   BRA `(.L_x_379) ;
.L_x_380:
        /*10d0*/                   MUFU.RCP R3, R0 ;
.L_x_379:
        /*10e0*/                   BSYNC B2 ;
.L_x_377:
        /*10f0*/                   MOV R0, R3 ;
        /*1100*/                   IMAD.MOV.U32 R2, RZ, RZ, R10 ;
        /*1110*/                   IMAD.MOV.U32 R3, RZ, RZ, 0x0 ;
        /*1120*/                   RET.REL.NODEC R2 `(activate_array_kernel) ;
        .weak           $__internal_14_$__cuda_sm3x_div_rn_noftz_f32_slowpath
        .type           $__internal_14_$__cuda_sm3x_div_rn_noftz_f32_slowpath,@function
        .size           $__internal_14_$__cuda_sm3x_div_rn_noftz_f32_slowpath,(.L_x_447 - $__internal_14_$__cuda_sm3x_div_rn_noftz_f32_slowpath)
$__internal_14_$__cuda_sm3x_div_rn_noftz_f32_slowpath:
        /*1130*/                   SHF.R.U32.HI R0, RZ, 0x17, R3 ;
        /*1140*/                   BSSY B2, `(.L_x_381) ;
        /*1150*/                   SHF.R.U32.HI R6, RZ, 0x17, R6 ;
        /*1160*/                   IMAD.MOV.U32 R7, RZ, RZ, 0x40000000 ;
        /*1170*/                   LOP3.LUT R13, R0, 0xff, RZ, 0xc0, !PT ;
        /*1180*/                   LOP3.LUT R6, R6, 0xff, RZ, 0xc0, !PT ;
        /*1190*/                   IADD3 R10, R13, -0x1, RZ ;
        /*11a0*/                   IADD3 R9, R6, -0x1, RZ ;
        /*11b0*/                   ISETP.GT.U32.AND P0, PT, R10, 0xfd, PT ;
        /*11c0*/                   ISETP.GT.U32.OR P0, PT, R9, 0xfd, P0 ;
        /*11d0*/              @!P0 MOV R8, RZ ;
        /*11e0*/              @!P0 BRA `(.L_x_382) ;
        /*11f0*/                   IMAD.MOV.U32 R0, RZ, RZ, 0x40000000 ;
        /*1200*/                   FSETP.GTU.FTZ.AND P1, PT, |R3|, +INF , PT ;
        /*1210*/                   FSETP.GTU.FTZ.AND P0, PT, |R0|, +INF , PT ;
        /*1220*/                   PLOP3.LUT P0, PT, P0, P1, PT, 0xa8, 0x0 ;
        /*1230*/               @P0 BRA `(.L_x_383) ;
        /*1240*/                   LOP3.LUT P0, RZ, R3, 0x7fffffff, R7, 0xc8, !PT ;
        /*1250*/              @!P0 BRA `(.L_x_384) ;
        /*1260*/                   FSETP.NEU.FTZ.AND P2, PT, |R0|.reuse, +INF , PT ;
        /*1270*/                   FSETP.NEU.FTZ.AND P1, PT, |R3|, +INF , PT ;
        /*1280*/                   FSETP.NEU.FTZ.AND P0, PT, |R0|, +INF , PT ;
        /*1290*/              @!P1 BRA !P2, `(.L_x_384) ;
        /*12a0*/                   LOP3.LUT P2, RZ, R7, 0x7fffffff, RZ, 0xc0, !PT ;
        /*12b0*/                   PLOP3.LUT P1, PT, P1, P2, PT, 0x2a, 0x0 ;
        /*12c0*/               @P1 BRA `(.L_x_385) ;
        /*12d0*/                   LOP3.LUT P1, RZ, R3, 0x7fffffff, RZ, 0xc0, !PT ;
        /*12e0*/                   PLOP3.LUT P0, PT, P0, P1, PT, 0x2a, 0x0 ;
        /*12f0*/               @P0 BRA `(.L_x_386) ;
        /*1300*/                   ISETP.GE.AND P0, PT, R9, RZ, PT ;
        /*1310*/                   ISETP.GE.AND P1, PT, R10, RZ, PT ;
        /*1320*/               @P0 IMAD.MOV.U32 R8, RZ, RZ, RZ ;
        /*1330*/              @!P0 FFMA R7, R0, 1.84467440737095516160e+19, RZ ;
        /*1340*/              @!P0 IMAD.MOV.U32 R8, RZ, RZ, -0x40 ;
        /*1350*/              @!P1 FFMA R3, R3, 1.84467440737095516160e+19, RZ ;
        /*1360*/              @!P1 IADD3 R8, R8, 0x40, RZ ;
.L_x_382:
        /*1370*/                   LEA R0, R13, 0xc0800000, 0x17 ;
        /*1380*/                   BSSY B3, `(.L_x_387) ;
        /*1390*/                   IADD3 R6, R6, -0x7f, RZ ;
        /*13a0*/                   IADD3 R3, -R0, R3, RZ ;
        /*13b0*/                   IMAD R0, R6.reuse, -0x800000, R7 ;
        /*13c0*/                   MUFU.RCP R9, R3 ;
        /*13d0*/                   FADD.FTZ R11, -R3, -RZ ;
        /*13e0*/                   IADD3 R3, R6, 0x7f, -R13 ;
        /*13f0*/                   IMAD.IADD R3, R3, 0x1, R8 ;
        /*1400*/                   FFMA R10, R9, R11, 1 ;
        /*1410*/                   FFMA R12, R9, R10, R9 ;
        /*1420*/                   FFMA R7, R0, R12, RZ ;
        /*1430*/                   FFMA R10, R11, R7, R0 ;
        /*1440*/                   FFMA R9, R12, R10, R7 ;
        /*1450*/                   FFMA R10, R11, R9, R0 ;
        /*1460*/                   FFMA R7, R12, R10, R9 ;
        /*1470*/                   SHF.R.U32.HI R0, RZ, 0x17, R7 ;
        /*1480*/                   LOP3.LUT R0, R0, 0xff, RZ, 0xc0, !PT ;
        /*1490*/                   IMAD.IADD R8, R0, 0x1, R3 ;
        /*14a0*/                   IADD3 R0, R8, -0x1, RZ ;
        /*14b0*/                   ISETP.GE.U32.AND P0, PT, R0, 0xfe, PT ;
        /*14c0*/              @!P0 BRA `(.L_x_388) ;
        /*14d0*/                   ISETP.GT.AND P0, PT, R8, 0xfe, PT ;
        /*14e0*/               @P0 BRA `(.L_x_389) ;
        /*14f0*/                   ISETP.GE.AND P0, PT, R8, 0x1, PT ;
        /*1500*/               @P0 BRA `(.L_x_390) ;
        /*1510*/                   ISETP.GE.AND P0, PT, R8, -0x18, PT ;
        /*1520*/                   LOP3.LUT R7, R7, 0x80000000, RZ, 0xc0, !PT ;
        /*1530*/              @!P0 BRA `(.L_x_390) ;
        /*1540*/                   FFMA.RZ R0, R12.reuse, R10.reuse, R9.reuse ;
        /*1550*/                   FFMA.RM R3, R12, R10.reuse, R9.reuse ;
        /*1560*/                   ISETP.NE.AND P2, PT, R8.reuse, RZ, PT ;
        /*1570*/                   ISETP.NE.AND P1, PT, R8, RZ, PT ;
        /*1580*/                   LOP3.LUT R6, R0, 0x7fffff, RZ, 0xc0, !PT ;
        /*1590*/                   FFMA.RP R0, R12, R10, R9 ;
        /*15a0*/                   IADD3 R9, R8, 0x20, RZ ;
        /*15b0*/                   IMAD.MOV R8, RZ, RZ, -R8 ;
        /*15c0*/                   LOP3.LUT R6, R6, 0x800000, RZ, 0xfc, !PT ;
        /*15d0*/                   FSETP.NEU.FTZ.AND P0, PT, R0, R3, PT ;
        /*15e0*/                   SHF.L.U32 R9, R6, R9, RZ ;
        /*15f0*/                   SEL R3, R8, RZ, P2 ;
        /*1600*/                   ISETP.NE.AND P1, PT, R9, RZ, P1 ;
        /*1610*/                   SHF.R.U32.HI R3, RZ, R3, R6 ;
        /*1620*/                   PLOP3.LUT P0, PT, P0, P1, PT, 0xa8, 0x0 ;
        /*1630*/                   SHF.R.U32.HI R9, RZ, 0x1, R3 ;
        /*1640*/                   SEL R0, RZ, 0x1, !P0 ;
        /*1650*/                   LOP3.LUT R0, R0, 0x1, R9, 0xf8, !PT ;
        /*1660*/                   LOP3.LUT R0, R0, R3, RZ, 0xc0, !PT ;
        /*1670*/                   IADD3 R0, R9, R0, RZ ;
        /*1680*/                   LOP3.LUT R7, R0, R7, RZ, 0xfc, !PT ;
        /*1690*/                   BRA `(.L_x_390) ;
.L_x_389:
        /*16a0*/                   LOP3.LUT R7, R7, 0x80000000, RZ, 0xc0, !PT ;
        /*16b0*/                   LOP3.LUT R7, R7, 0x7f800000, RZ, 0xfc, !PT ;
        /*16c0*/                   BRA `(.L_x_390) ;
.L_x_388:
        /*16d0*/                   IMAD R7, R3, 0x800000, R7 ;
.L_x_390:
        /*16e0*/                   BSYNC B3 ;
.L_x_387:
        /*16f0*/                   BRA `(.L_x_391) ;
.L_x_386:
        /*1700*/                   LOP3.LUT R7, R3, 0x80000000, R7, 0x48, !PT ;
        /*1710*/                   LOP3.LUT R7, R7, 0x7f800000, RZ, 0xfc, !PT ;
        /*1720*/                   BRA `(.L_x_391) ;
.L_x_385:
        /*1730*/                   LOP3.LUT R7, R3, 0x80000000, R7, 0x48, !PT ;
        /*1740*/                   BRA `(.L_x_391) ;
.L_x_384:
        /*1750*/                   MUFU.RSQ R7, -QNAN  ;
        /*1760*/                   BRA `(.L_x_391) ;
.L_x_383:
        /*1770*/                   FADD.FTZ R7, R0, R3 ;
.L_x_391:
        /*1780*/                   BSYNC B2 ;
.L_x_381:
        /*1790*/                   IMAD.MOV.U32 R3, RZ, RZ, 0x0 ;
        /*17a0*/                   RET.REL.NODEC R2 `(activate_array_kernel) ;
.L_x_392:
        /*17b0*/                   BRA `(.L_x_392);
        /*17c0*/                   NOP;
        /*17d0*/                   NOP;
        /*17e0*/                   NOP;
        /*17f0*/                   NOP;
        /*1800*/                   NOP;
        /*1810*/                   NOP;
        /*1820*/                   NOP;
        /*1830*/                   NOP;
        /*1840*/                   NOP;
        /*1850*/                   NOP;
        /*1860*/                   NOP;
        /*1870*/                   NOP;
.L_x_447:
