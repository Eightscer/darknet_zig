	.amdgcn_target "amdgcn-amd-amdhsa--gfx1032"
	.amdhsa_code_object_version 6
	.text
	.protected	activate_array_kernel   ; -- Begin function activate_array_kernel
	.globl	activate_array_kernel
	.p2align	8
	.type	activate_array_kernel,@function
activate_array_kernel:                  ; @activate_array_kernel
; %bb.0:
	s_clause 0x1
	s_load_dword s2, s[4:5], 0x1c
	s_load_dwordx2 s[0:1], s[4:5], 0x8
	s_waitcnt lgkmcnt(0)
	s_and_b32 s2, s2, 0xffff
	v_mad_u64_u32 v[0:1], null, s6, s2, v[0:1]
	v_cmp_gt_i32_e32 vcc_lo, s0, v0
	s_and_saveexec_b32 s0, vcc_lo
	s_cbranch_execz .LBB0_79
; %bb.1:
	s_load_dwordx2 s[2:3], s[4:5], 0x0
	v_ashrrev_i32_e32 v1, 31, v0
	s_cmp_lt_i32 s1, 7
	v_lshlrev_b64 v[0:1], 2, v[0:1]
	s_waitcnt lgkmcnt(0)
	v_add_co_u32 v0, vcc_lo, s2, v0
	v_add_co_ci_u32_e64 v1, null, s3, v1, vcc_lo
	s_mov_b32 s2, 0
	global_load_dword v2, v[0:1], off
	s_cbranch_scc1 .LBB0_7
; %bb.2:
	s_cmp_gt_i32 s1, 9
	s_cbranch_scc0 .LBB0_8
; %bb.3:
	s_cmp_gt_i32 s1, 11
	s_cbranch_scc0 .LBB0_9
; %bb.4:
	s_cmp_gt_i32 s1, 12
	s_cbranch_scc0 .LBB0_10
; %bb.5:
	s_cmp_eq_u32 s1, 13
	s_cbranch_scc0 .LBB0_11
; %bb.6:
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v3, 0x3fb8aa3b, v2
	v_cmp_ngt_f32_e32 vcc_lo, 0xc2ce8ed0, v2
	s_mov_b32 s0, 0
	v_rndne_f32_e32 v4, v3
	v_fma_f32 v5, 0x3fb8aa3b, v2, -v3
	v_sub_f32_e32 v3, v3, v4
	v_fmamk_f32 v5, v2, 0x32a5705f, v5
	v_cvt_i32_f32_e32 v4, v4
	v_add_f32_e32 v3, v3, v5
	v_exp_f32_e32 v3, v3
	v_ldexp_f32 v3, v3, v4
	v_cndmask_b32_e32 v3, 0, v3, vcc_lo
	v_cmp_nlt_f32_e32 vcc_lo, 0x42b17218, v2
	v_cndmask_b32_e32 v3, 0x7f800000, v3, vcc_lo
	v_cmp_gt_f32_e32 vcc_lo, 0, v2
	v_add_f32_e32 v3, -1.0, v3
	v_cndmask_b32_e64 v4, 0, 0x3fe1072a, vcc_lo
	v_cmp_le_f32_e32 vcc_lo, 0, v2
	v_mul_f32_e32 v3, v3, v4
	v_cndmask_b32_e64 v5, 0, 0x3f867d56, vcc_lo
	v_fmac_f32_e32 v3, v2, v5
	s_branch .LBB0_12
.LBB0_7:
	s_mov_b32 s0, 0
                                        ; implicit-def: $vgpr3
	s_cbranch_execnz .LBB0_44
	s_branch .LBB0_74
.LBB0_8:
	s_mov_b32 s0, 0
                                        ; implicit-def: $vgpr3
	s_cbranch_execnz .LBB0_34
	s_branch .LBB0_43
.LBB0_9:
	s_mov_b32 s0, 0
                                        ; implicit-def: $vgpr3
	s_cbranch_execnz .LBB0_22
	s_branch .LBB0_33
.LBB0_10:
	s_mov_b32 s3, -1
	s_mov_b32 s0, 0
                                        ; implicit-def: $vgpr3
	s_branch .LBB0_13
.LBB0_11:
	s_mov_b32 s0, -1
                                        ; implicit-def: $vgpr3
.LBB0_12:
	s_mov_b32 s3, 0
.LBB0_13:
	s_and_b32 vcc_lo, exec_lo, s3
	s_cbranch_vccz .LBB0_21
; %bb.14:
	s_mov_b32 s3, exec_lo
                                        ; implicit-def: $vgpr3
	s_waitcnt vmcnt(0)
	v_cmpx_ngt_f32_e32 0, v2
	s_xor_b32 s3, exec_lo, s3
	s_cbranch_execz .LBB0_18
; %bb.15:
	v_mov_b32_e32 v3, v2
	s_mov_b32 s4, exec_lo
	v_cmpx_lt_f32_e32 1.0, v2
; %bb.16:
	v_add_f32_e32 v3, -1.0, v2
	v_mov_b32_e32 v4, 1.0
	v_fmamk_f32 v3, v3, 0x3a83126f, v4
; %bb.17:
	s_or_b32 exec_lo, exec_lo, s4
.LBB0_18:
	s_andn2_saveexec_b32 s3, s3
; %bb.19:
	v_mul_f32_e32 v3, 0x3a83126f, v2
; %bb.20:
	s_or_b32 exec_lo, exec_lo, s3
.LBB0_21:
	s_branch .LBB0_33
.LBB0_22:
	s_cmp_gt_i32 s1, 10
	s_cbranch_scc0 .LBB0_26
; %bb.23:
	v_mov_b32_e32 v3, -1.0
	s_mov_b32 s3, exec_lo
	s_waitcnt vmcnt(0)
	v_cmpx_ngt_f32_e32 -1.0, v2
; %bb.24:
	v_cmp_nlt_f32_e32 vcc_lo, 1.0, v2
	v_cndmask_b32_e32 v3, 1.0, v2, vcc_lo
; %bb.25:
	s_or_b32 exec_lo, exec_lo, s3
	s_mov_b32 s3, 0
	s_branch .LBB0_27
.LBB0_26:
	s_mov_b32 s3, -1
                                        ; implicit-def: $vgpr3
.LBB0_27:
	s_andn2_b32 vcc_lo, exec_lo, s3
	s_cbranch_vccnz .LBB0_33
; %bb.28:
	s_waitcnt vmcnt(0)
	v_floor_f32_e32 v3, v2
	v_mul_f32_e32 v4, 0.5, v2
	v_cvt_i32_f32_e32 v5, v3
	v_and_b32_e32 v3, 1, v5
	v_cmp_eq_u32_e32 vcc_lo, 1, v3
                                        ; implicit-def: $vgpr3
	s_and_saveexec_b32 s3, vcc_lo
	s_xor_b32 s3, exec_lo, s3
; %bb.29:
	v_cvt_f32_i32_e32 v3, v5
	v_floor_f32_e32 v4, v4
	v_sub_f32_e32 v3, v2, v3
	v_add_f32_e32 v3, v4, v3
                                        ; implicit-def: $vgpr4
; %bb.30:
	s_andn2_saveexec_b32 s3, s3
; %bb.31:
	v_floor_f32_e32 v3, v4
; %bb.32:
	s_or_b32 exec_lo, exec_lo, s3
.LBB0_33:
	s_branch .LBB0_43
.LBB0_34:
	s_cmp_lt_i32 s1, 8
	s_cbranch_scc1 .LBB0_37
; %bb.35:
	s_cmp_gt_i32 s1, 8
	s_cbranch_scc0 .LBB0_38
; %bb.36:
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v3, 0xbfb8aa3b, v2
	v_cmp_nlt_f32_e32 vcc_lo, 0x42ce8ed0, v2
	s_mov_b32 s3, 0
	v_rndne_f32_e32 v4, v3
	v_fma_f32 v5, 0xbfb8aa3b, v2, -v3
	v_sub_f32_e32 v3, v3, v4
	v_fmamk_f32 v5, v2, 0xb2a5705f, v5
	v_cvt_i32_f32_e32 v4, v4
	v_add_f32_e32 v3, v3, v5
	v_exp_f32_e32 v3, v3
	v_ldexp_f32 v3, v3, v4
	v_cndmask_b32_e32 v3, 0, v3, vcc_lo
	v_cmp_ngt_f32_e32 vcc_lo, 0xc2b17218, v2
	v_cndmask_b32_e32 v3, 0x7f800000, v3, vcc_lo
	v_add_f32_e32 v3, 1.0, v3
	v_div_scale_f32 v4, null, v3, v3, 2.0
	v_rcp_f32_e32 v5, v4
	v_fma_f32 v6, -v4, v5, 1.0
	v_fmac_f32_e32 v5, v6, v5
	v_div_scale_f32 v6, vcc_lo, 2.0, v3, 2.0
	v_mul_f32_e32 v7, v6, v5
	v_fma_f32 v8, -v4, v7, v6
	v_fmac_f32_e32 v7, v8, v5
	v_fma_f32 v4, -v4, v7, v6
	v_div_fmas_f32 v4, v4, v5, v7
	v_div_fixup_f32 v3, v4, v3, 2.0
	v_add_f32_e32 v3, -1.0, v3
	s_branch .LBB0_39
.LBB0_37:
                                        ; implicit-def: $vgpr3
	s_branch .LBB0_42
.LBB0_38:
	s_mov_b32 s3, -1
                                        ; implicit-def: $vgpr3
.LBB0_39:
	s_andn2_b32 vcc_lo, exec_lo, s3
	s_cbranch_vccnz .LBB0_41
; %bb.40:
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v3, 0x3fb8aa3b, v2
	v_cmp_ngt_f32_e32 vcc_lo, 0xc2ce8ed0, v2
	v_rndne_f32_e32 v4, v3
	v_fma_f32 v5, 0x3fb8aa3b, v2, -v3
	v_sub_f32_e32 v3, v3, v4
	v_fmamk_f32 v5, v2, 0x32a5705f, v5
	v_cvt_i32_f32_e32 v4, v4
	v_add_f32_e32 v3, v3, v5
	v_exp_f32_e32 v3, v3
	v_ldexp_f32 v3, v3, v4
	v_cndmask_b32_e32 v3, 0, v3, vcc_lo
	v_cmp_nlt_f32_e32 vcc_lo, 0x42b17218, v2
	v_cndmask_b32_e32 v3, 0x7f800000, v3, vcc_lo
	v_cmp_gt_f32_e32 vcc_lo, 0, v2
	v_add_f32_e32 v3, -1.0, v3
	v_cndmask_b32_e64 v4, 0, 1.0, vcc_lo
	v_cmp_le_f32_e32 vcc_lo, 0, v2
	v_mul_f32_e32 v3, v3, v4
	v_cndmask_b32_e64 v5, 0, 1.0, vcc_lo
	v_fmac_f32_e32 v3, v2, v5
.LBB0_41:
	s_cbranch_execnz .LBB0_43
.LBB0_42:
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v3, 0x3dcccccd, v2
	v_cmp_lt_f32_e32 vcc_lo, 0, v2
	v_cndmask_b32_e32 v3, v3, v2, vcc_lo
.LBB0_43:
	s_branch .LBB0_74
.LBB0_44:
	s_cmp_gt_i32 s1, 2
	s_cbranch_scc0 .LBB0_56
; %bb.45:
	s_cmp_lt_i32 s1, 5
	s_cbranch_scc1 .LBB0_57
; %bb.46:
	s_cmp_gt_i32 s1, 5
	s_cbranch_scc0 .LBB0_58
; %bb.47:
	s_mov_b32 s2, exec_lo
                                        ; implicit-def: $vgpr3
	s_waitcnt vmcnt(0)
	v_cmpx_ngt_f32_e32 -4.0, v2
	s_xor_b32 s2, exec_lo, s2
	s_cbranch_execz .LBB0_53
; %bb.48:
	s_mov_b32 s3, exec_lo
                                        ; implicit-def: $vgpr3
	v_cmpx_nlt_f32_e32 4.0, v2
	s_xor_b32 s3, exec_lo, s3
; %bb.49:
	v_mov_b32_e32 v3, 0.5
	v_fmamk_f32 v3, v2, 0x3e000000, v3
; %bb.50:
	s_andn2_saveexec_b32 s3, s3
; %bb.51:
	v_add_f32_e32 v3, -4.0, v2
	v_mov_b32_e32 v4, 1.0
	v_fmamk_f32 v3, v3, 0x3c23d70a, v4
; %bb.52:
	s_or_b32 exec_lo, exec_lo, s3
.LBB0_53:
	s_andn2_saveexec_b32 s2, s2
; %bb.54:
	v_add_f32_e32 v3, 4.0, v2
	v_mul_f32_e32 v3, 0x3c23d70a, v3
; %bb.55:
	s_or_b32 exec_lo, exec_lo, s2
	s_mov_b32 s2, 0
	s_branch .LBB0_59
.LBB0_56:
                                        ; implicit-def: $vgpr3
	s_mov_b32 s2, 0
	s_branch .LBB0_65
.LBB0_57:
                                        ; implicit-def: $vgpr3
	s_branch .LBB0_62
.LBB0_58:
	s_mov_b32 s2, -1
                                        ; implicit-def: $vgpr3
.LBB0_59:
	s_andn2_b32 vcc_lo, exec_lo, s2
	s_cbranch_vccnz .LBB0_61
; %bb.60:
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v3, -2.0, v2
	v_mul_f32_e32 v4, 0x3fb8aa3b, v3
	v_cmp_ngt_f32_e32 vcc_lo, 0xc2ce8ed0, v3
	v_fma_f32 v5, 0x3fb8aa3b, v3, -v4
	v_rndne_f32_e32 v6, v4
	v_fmamk_f32 v5, v3, 0x32a5705f, v5
	v_sub_f32_e32 v4, v4, v6
	v_add_f32_e32 v4, v4, v5
	v_cvt_i32_f32_e32 v5, v6
	v_exp_f32_e32 v4, v4
	v_ldexp_f32 v4, v4, v5
	v_cndmask_b32_e32 v4, 0, v4, vcc_lo
	v_cmp_nlt_f32_e32 vcc_lo, 0x42b17218, v3
	v_cndmask_b32_e32 v3, 0x7f800000, v4, vcc_lo
	v_add_f32_e32 v3, 1.0, v3
	v_div_scale_f32 v4, null, v3, v3, 2.0
	v_rcp_f32_e32 v5, v4
	v_fma_f32 v6, -v4, v5, 1.0
	v_fmac_f32_e32 v5, v6, v5
	v_div_scale_f32 v6, vcc_lo, 2.0, v3, 2.0
	v_mul_f32_e32 v7, v6, v5
	v_fma_f32 v8, -v4, v7, v6
	v_fmac_f32_e32 v7, v8, v5
	v_fma_f32 v4, -v4, v7, v6
	v_div_fmas_f32 v4, v4, v5, v7
	v_div_fixup_f32 v3, v4, v3, 2.0
	v_add_f32_e32 v3, -1.0, v3
.LBB0_61:
	s_cbranch_execnz .LBB0_64
.LBB0_62:
	s_waitcnt vmcnt(0)
	v_mov_b32_e32 v3, v2
	s_cmp_gt_i32 s1, 3
	s_cbranch_scc0 .LBB0_64
; %bb.63:
	v_cmp_lt_f32_e32 vcc_lo, 0, v2
	v_cndmask_b32_e64 v3, 0, 1.0, vcc_lo
	v_mul_f32_e32 v3, v2, v3
	v_fmamk_f32 v3, v2, 0x3dcccccd, v3
.LBB0_64:
	s_mov_b32 s2, 0
	s_cbranch_execnz .LBB0_74
.LBB0_65:
	s_cmp_gt_i32 s1, 0
	s_cbranch_scc0 .LBB0_68
; %bb.66:
	s_cmp_gt_i32 s1, 1
	s_waitcnt vmcnt(0)
	v_cmp_lt_f32_e32 vcc_lo, 0, v2
	s_cbranch_scc0 .LBB0_69
; %bb.67:
	v_mul_f32_e32 v3, 0x3c23d70a, v2
	s_mov_b32 s3, 0
	v_cndmask_b32_e32 v3, v3, v2, vcc_lo
	s_branch .LBB0_70
.LBB0_68:
                                        ; implicit-def: $vgpr3
	s_branch .LBB0_73
.LBB0_69:
	s_mov_b32 s3, -1
                                        ; implicit-def: $vgpr3
.LBB0_70:
	s_andn2_b32 vcc_lo, exec_lo, s3
	s_cbranch_vccnz .LBB0_72
; %bb.71:
	v_cmp_lt_f32_e32 vcc_lo, 0, v2
	v_cndmask_b32_e64 v3, 0, 1.0, vcc_lo
	v_mul_f32_e32 v3, v2, v3
.LBB0_72:
	s_cbranch_execnz .LBB0_74
.LBB0_73:
	s_cmp_lg_u32 s1, 0
	s_mov_b32 s2, -1
	s_cselect_b32 s0, -1, 0
.LBB0_74:
	s_and_b32 vcc_lo, exec_lo, s0
	s_cbranch_vccz .LBB0_76
; %bb.75:
	v_mov_b32_e32 v3, 0
	s_mov_b32 s2, 0
.LBB0_76:
	s_andn2_b32 vcc_lo, exec_lo, s2
	s_cbranch_vccnz .LBB0_78
; %bb.77:
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v3, 0xbfb8aa3b, v2
	v_cmp_nlt_f32_e32 vcc_lo, 0x42ce8ed0, v2
	v_rndne_f32_e32 v4, v3
	v_fma_f32 v5, 0xbfb8aa3b, v2, -v3
	v_sub_f32_e32 v3, v3, v4
	v_fmamk_f32 v5, v2, 0xb2a5705f, v5
	v_cvt_i32_f32_e32 v4, v4
	v_add_f32_e32 v3, v3, v5
	v_exp_f32_e32 v3, v3
	v_ldexp_f32 v3, v3, v4
	v_cndmask_b32_e32 v3, 0, v3, vcc_lo
	v_cmp_ngt_f32_e32 vcc_lo, 0xc2b17218, v2
	v_cndmask_b32_e32 v2, 0x7f800000, v3, vcc_lo
	v_add_f32_e32 v2, 1.0, v2
	v_div_scale_f32 v3, null, v2, v2, 1.0
	v_rcp_f32_e32 v4, v3
	v_fma_f32 v5, -v3, v4, 1.0
	v_fmac_f32_e32 v4, v5, v4
	v_div_scale_f32 v5, vcc_lo, 1.0, v2, 1.0
	v_mul_f32_e32 v6, v5, v4
	v_fma_f32 v7, -v3, v6, v5
	v_fmac_f32_e32 v6, v7, v4
	v_fma_f32 v3, -v3, v6, v5
	v_div_fmas_f32 v3, v3, v4, v6
	v_div_fixup_f32 v3, v3, v2, 1.0
.LBB0_78:
	global_store_dword v[0:1], v3, off
.LBB0_79:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel activate_array_kernel
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 272
		.amdhsa_user_sgpr_count 6
		.amdhsa_user_sgpr_private_segment_buffer 1
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_flat_scratch_init 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_wavefront_size32 1
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_system_sgpr_private_segment_wavefront_offset 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 9
		.amdhsa_next_free_sgpr 7
		.amdhsa_reserve_vcc 1
		.amdhsa_reserve_flat_scratch 0
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 3
		.amdhsa_float_denorm_mode_16_64 3
		.amdhsa_dx10_clamp 1
		.amdhsa_ieee_mode 1
		.amdhsa_fp16_overflow 0
		.amdhsa_workgroup_processor_mode 1
		.amdhsa_memory_ordered 1
		.amdhsa_forward_progress 1
		.amdhsa_shared_vgpr_count 0
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.text
.Lfunc_end0:
	.size	activate_array_kernel, .Lfunc_end0-activate_array_kernel
                                        ; -- End function
	.set activate_array_kernel.num_vgpr, 9
	.set activate_array_kernel.num_agpr, 0
	.set activate_array_kernel.numbered_sgpr, 7
	.set activate_array_kernel.num_named_barrier, 0
	.set activate_array_kernel.private_seg_size, 0
	.set activate_array_kernel.uses_vcc, 1
	.set activate_array_kernel.uses_flat_scratch, 0
	.set activate_array_kernel.has_dyn_sized_stack, 0
	.set activate_array_kernel.has_recursion, 0
	.set activate_array_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 1560
; TotalNumSgprs: 9
; NumVgprs: 9
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 0
; VGPRBlocks: 1
; NumSGPRsForWavesPerEU: 9
; NumVGPRsForWavesPerEU: 9
; Occupancy: 16
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 6
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
	.text
	.protected	gradient_array_kernel   ; -- Begin function gradient_array_kernel
	.globl	gradient_array_kernel
	.p2align	8
	.type	gradient_array_kernel,@function
gradient_array_kernel:                  ; @gradient_array_kernel
; %bb.0:
	s_clause 0x1
	s_load_dword s2, s[4:5], 0x24
	s_load_dwordx2 s[0:1], s[4:5], 0x8
	s_waitcnt lgkmcnt(0)
	s_and_b32 s2, s2, 0xffff
	v_mad_u64_u32 v[0:1], null, s6, s2, v[0:1]
	v_cmp_gt_i32_e32 vcc_lo, s0, v0
	s_and_saveexec_b32 s0, vcc_lo
	s_cbranch_execz .LBB1_59
; %bb.1:
	s_load_dwordx2 s[2:3], s[4:5], 0x0
	v_ashrrev_i32_e32 v1, 31, v0
	s_cmp_lt_i32 s1, 7
	v_lshlrev_b64 v[0:1], 2, v[0:1]
	s_waitcnt lgkmcnt(0)
	v_add_co_u32 v2, vcc_lo, s2, v0
	v_add_co_ci_u32_e64 v3, null, s3, v1, vcc_lo
	s_mov_b32 s3, 0
	global_load_dword v2, v[2:3], off
	s_cbranch_scc1 .LBB1_7
; %bb.2:
	s_cmp_gt_i32 s1, 9
	s_cbranch_scc0 .LBB1_8
; %bb.3:
	s_cmp_gt_i32 s1, 11
	s_cbranch_scc0 .LBB1_9
; %bb.4:
	s_cmp_gt_i32 s1, 12
	s_cbranch_scc0 .LBB1_10
; %bb.5:
	s_cmp_eq_u32 s1, 13
	s_cbranch_scc0 .LBB1_11
; %bb.6:
	s_waitcnt vmcnt(0)
	v_cmp_gt_f32_e32 vcc_lo, 0, v2
	v_add_f32_e32 v4, 0x3fe1072a, v2
	s_mov_b32 s2, 0
	v_cndmask_b32_e64 v3, 0, 1.0, vcc_lo
	v_cmp_le_f32_e32 vcc_lo, 0, v2
	v_mul_f32_e32 v3, v4, v3
	v_cndmask_b32_e64 v5, 0, 1.0, vcc_lo
	v_fmamk_f32 v3, v5, 0x3f867d56, v3
	s_branch .LBB1_12
.LBB1_7:
	s_mov_b32 s2, 0
                                        ; implicit-def: $vgpr3
	s_cbranch_execnz .LBB1_32
	s_branch .LBB1_54
.LBB1_8:
	s_mov_b32 s2, 0
                                        ; implicit-def: $vgpr3
	s_cbranch_execnz .LBB1_22
	s_branch .LBB1_31
.LBB1_9:
	s_mov_b32 s2, 0
                                        ; implicit-def: $vgpr3
	s_cbranch_execnz .LBB1_16
	s_branch .LBB1_21
.LBB1_10:
	s_mov_b32 s0, -1
	s_mov_b32 s2, 0
                                        ; implicit-def: $vgpr3
	s_branch .LBB1_13
.LBB1_11:
	s_mov_b32 s2, -1
                                        ; implicit-def: $vgpr3
.LBB1_12:
	s_mov_b32 s0, 0
.LBB1_13:
	s_and_b32 vcc_lo, exec_lo, s0
	s_cbranch_vccz .LBB1_15
; %bb.14:
	s_waitcnt vmcnt(0)
	v_cmp_lt_f32_e32 vcc_lo, 0, v2
	v_cmp_gt_f32_e64 s0, 1.0, v2
	s_and_b32 s0, vcc_lo, s0
	v_cndmask_b32_e64 v3, 0x3a83126f, 1.0, s0
.LBB1_15:
	s_branch .LBB1_21
.LBB1_16:
	s_cmp_gt_i32 s1, 10
	s_cbranch_scc0 .LBB1_18
; %bb.17:
	s_waitcnt vmcnt(0)
	v_cmp_lt_f32_e64 s0, |v2|, 1.0
	v_cndmask_b32_e64 v3, 0, 1.0, s0
	s_mov_b32 s0, 0
	s_branch .LBB1_19
.LBB1_18:
	s_mov_b32 s0, -1
                                        ; implicit-def: $vgpr3
.LBB1_19:
	s_andn2_b32 vcc_lo, exec_lo, s0
	s_cbranch_vccnz .LBB1_21
; %bb.20:
	s_waitcnt vmcnt(0)
	v_floor_f32_e32 v3, v2
	v_cmp_neq_f32_e32 vcc_lo, v3, v2
	v_cndmask_b32_e64 v3, 0, 1.0, vcc_lo
.LBB1_21:
	s_branch .LBB1_31
.LBB1_22:
	s_cmp_lt_i32 s1, 8
	s_cbranch_scc1 .LBB1_25
; %bb.23:
	s_waitcnt vmcnt(0)
	v_add_f32_e32 v4, 1.0, v2
	s_cmp_gt_i32 s1, 8
	s_cbranch_scc0 .LBB1_26
; %bb.24:
	v_fma_f32 v3, v4, -0.5, 1.0
	v_mul_f32_e32 v5, 0.5, v4
	s_mov_b32 s0, 0
	v_add_f32_e32 v3, v3, v3
	v_mul_f32_e32 v3, v5, v3
	s_branch .LBB1_27
.LBB1_25:
                                        ; implicit-def: $vgpr3
	s_branch .LBB1_30
.LBB1_26:
	s_mov_b32 s0, -1
                                        ; implicit-def: $vgpr3
.LBB1_27:
	s_andn2_b32 vcc_lo, exec_lo, s0
	s_cbranch_vccnz .LBB1_29
; %bb.28:
	v_cmp_le_f32_e32 vcc_lo, 0, v2
	v_cndmask_b32_e64 v3, 0, 1.0, vcc_lo
	v_cmp_gt_f32_e32 vcc_lo, 0, v2
	v_cndmask_b32_e64 v5, 0, 1.0, vcc_lo
	v_fmac_f32_e32 v3, v4, v5
.LBB1_29:
	s_cbranch_execnz .LBB1_31
.LBB1_30:
	s_waitcnt vmcnt(0)
	v_cmp_lt_f32_e32 vcc_lo, 0, v2
	v_cndmask_b32_e64 v3, 0x3dcccccd, 1.0, vcc_lo
.LBB1_31:
	s_branch .LBB1_54
.LBB1_32:
	s_cmp_gt_i32 s1, 2
	s_cbranch_scc0 .LBB1_36
; %bb.33:
	s_cmp_lt_i32 s1, 5
	s_cbranch_scc1 .LBB1_37
; %bb.34:
	s_cmp_gt_i32 s1, 5
	s_cbranch_scc0 .LBB1_38
; %bb.35:
	s_waitcnt vmcnt(0)
	v_cmp_gt_f32_e32 vcc_lo, 0, v2
	v_cmp_lt_f32_e64 s0, 1.0, v2
	v_mov_b32_e32 v3, 0x3c23d70a
	s_or_b32 vcc_lo, vcc_lo, s0
	s_mov_b32 s0, 0
	v_cndmask_b32_e32 v3, 0x3e000000, v3, vcc_lo
	s_branch .LBB1_39
.LBB1_36:
                                        ; implicit-def: $vgpr3
	s_branch .LBB1_45
.LBB1_37:
                                        ; implicit-def: $vgpr3
	s_branch .LBB1_42
.LBB1_38:
	s_mov_b32 s0, -1
                                        ; implicit-def: $vgpr3
.LBB1_39:
	s_andn2_b32 vcc_lo, exec_lo, s0
	s_cbranch_vccnz .LBB1_41
; %bb.40:
	s_waitcnt vmcnt(0)
	v_fma_f32 v3, -v2, v2, 1.0
.LBB1_41:
	s_cbranch_execnz .LBB1_44
.LBB1_42:
	v_mov_b32_e32 v3, 1.0
	s_cmp_gt_i32 s1, 3
	s_cbranch_scc0 .LBB1_44
; %bb.43:
	v_mov_b32_e32 v3, 0x3f8ccccd
	s_waitcnt vmcnt(0)
	v_cmp_lt_f32_e32 vcc_lo, 0, v2
	v_cndmask_b32_e32 v3, 0x3dcccccd, v3, vcc_lo
.LBB1_44:
	s_cbranch_execnz .LBB1_54
.LBB1_45:
	s_cmp_gt_i32 s1, 0
	s_cbranch_scc0 .LBB1_48
; %bb.46:
	s_cmp_gt_i32 s1, 1
	s_waitcnt vmcnt(0)
	v_cmp_lt_f32_e32 vcc_lo, 0, v2
	s_cbranch_scc0 .LBB1_49
; %bb.47:
	v_cndmask_b32_e64 v3, 0x3c23d70a, 1.0, vcc_lo
	s_mov_b32 s0, 0
	s_branch .LBB1_50
.LBB1_48:
                                        ; implicit-def: $vgpr3
	s_branch .LBB1_53
.LBB1_49:
	s_mov_b32 s0, -1
                                        ; implicit-def: $vgpr3
.LBB1_50:
	s_andn2_b32 vcc_lo, exec_lo, s0
	s_cbranch_vccnz .LBB1_52
; %bb.51:
	v_cmp_lt_f32_e32 vcc_lo, 0, v2
	v_cndmask_b32_e64 v3, 0, 1.0, vcc_lo
.LBB1_52:
	s_cbranch_execnz .LBB1_54
.LBB1_53:
	s_cmp_lg_u32 s1, 0
	s_mov_b32 s3, -1
	s_cselect_b32 s2, -1, 0
.LBB1_54:
	s_and_b32 vcc_lo, exec_lo, s2
	s_cbranch_vccz .LBB1_56
; %bb.55:
	v_mov_b32_e32 v3, 0
	s_mov_b32 s3, 0
.LBB1_56:
	s_andn2_b32 vcc_lo, exec_lo, s3
	s_cbranch_vccnz .LBB1_58
; %bb.57:
	s_waitcnt vmcnt(0)
	v_sub_f32_e32 v3, 1.0, v2
	v_mul_f32_e32 v3, v2, v3
.LBB1_58:
	s_load_dwordx2 s[0:1], s[4:5], 0x10
	s_waitcnt lgkmcnt(0)
	v_add_co_u32 v0, vcc_lo, s0, v0
	v_add_co_ci_u32_e64 v1, null, s1, v1, vcc_lo
	global_load_dword v2, v[0:1], off
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v2, v3, v2
	global_store_dword v[0:1], v2, off
.LBB1_59:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel gradient_array_kernel
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 280
		.amdhsa_user_sgpr_count 6
		.amdhsa_user_sgpr_private_segment_buffer 1
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_flat_scratch_init 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_wavefront_size32 1
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_system_sgpr_private_segment_wavefront_offset 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 6
		.amdhsa_next_free_sgpr 7
		.amdhsa_reserve_vcc 1
		.amdhsa_reserve_flat_scratch 0
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 3
		.amdhsa_float_denorm_mode_16_64 3
		.amdhsa_dx10_clamp 1
		.amdhsa_ieee_mode 1
		.amdhsa_fp16_overflow 0
		.amdhsa_workgroup_processor_mode 1
		.amdhsa_memory_ordered 1
		.amdhsa_forward_progress 1
		.amdhsa_shared_vgpr_count 0
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.text
.Lfunc_end1:
	.size	gradient_array_kernel, .Lfunc_end1-gradient_array_kernel
                                        ; -- End function
	.set gradient_array_kernel.num_vgpr, 6
	.set gradient_array_kernel.num_agpr, 0
	.set gradient_array_kernel.numbered_sgpr, 7
	.set gradient_array_kernel.num_named_barrier, 0
	.set gradient_array_kernel.private_seg_size, 0
	.set gradient_array_kernel.uses_vcc, 1
	.set gradient_array_kernel.uses_flat_scratch, 0
	.set gradient_array_kernel.has_dyn_sized_stack, 0
	.set gradient_array_kernel.has_recursion, 0
	.set gradient_array_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 820
; TotalNumSgprs: 9
; NumVgprs: 6
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 0
; VGPRBlocks: 0
; NumSGPRsForWavesPerEU: 9
; NumVGPRsForWavesPerEU: 6
; Occupancy: 16
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 6
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
	.text
	.protected	fill_kernel             ; -- Begin function fill_kernel
	.globl	fill_kernel
	.p2align	8
	.type	fill_kernel,@function
fill_kernel:                            ; @fill_kernel
; %bb.0:
	s_clause 0x1
	s_load_dword s2, s[4:5], 0x1c
	s_load_dwordx2 s[0:1], s[4:5], 0x0
	s_waitcnt lgkmcnt(0)
	s_and_b32 s2, s2, 0xffff
	v_mad_u64_u32 v[0:1], null, s6, s2, v[0:1]
	v_cmp_gt_i32_e32 vcc_lo, s0, v0
	s_and_saveexec_b32 s0, vcc_lo
	s_cbranch_execz .LBB2_2
; %bb.1:
	s_load_dwordx2 s[2:3], s[4:5], 0x8
	v_ashrrev_i32_e32 v1, 31, v0
	v_mov_b32_e32 v2, s1
	v_lshlrev_b64 v[0:1], 2, v[0:1]
	s_waitcnt lgkmcnt(0)
	v_add_co_u32 v0, vcc_lo, s2, v0
	v_add_co_ci_u32_e64 v1, null, s3, v1, vcc_lo
	global_store_dword v[0:1], v2, off
.LBB2_2:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel fill_kernel
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 272
		.amdhsa_user_sgpr_count 6
		.amdhsa_user_sgpr_private_segment_buffer 1
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_flat_scratch_init 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_wavefront_size32 1
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_system_sgpr_private_segment_wavefront_offset 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 3
		.amdhsa_next_free_sgpr 7
		.amdhsa_reserve_vcc 1
		.amdhsa_reserve_flat_scratch 0
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 3
		.amdhsa_float_denorm_mode_16_64 3
		.amdhsa_dx10_clamp 1
		.amdhsa_ieee_mode 1
		.amdhsa_fp16_overflow 0
		.amdhsa_workgroup_processor_mode 1
		.amdhsa_memory_ordered 1
		.amdhsa_forward_progress 1
		.amdhsa_shared_vgpr_count 0
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.text
.Lfunc_end2:
	.size	fill_kernel, .Lfunc_end2-fill_kernel
                                        ; -- End function
	.set fill_kernel.num_vgpr, 3
	.set fill_kernel.num_agpr, 0
	.set fill_kernel.numbered_sgpr, 7
	.set fill_kernel.num_named_barrier, 0
	.set fill_kernel.private_seg_size, 0
	.set fill_kernel.uses_vcc, 1
	.set fill_kernel.uses_flat_scratch, 0
	.set fill_kernel.has_dyn_sized_stack, 0
	.set fill_kernel.has_recursion, 0
	.set fill_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 108
; TotalNumSgprs: 9
; NumVgprs: 3
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 0
; VGPRBlocks: 0
; NumSGPRsForWavesPerEU: 9
; NumVGPRsForWavesPerEU: 3
; Occupancy: 16
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 6
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
	.text
	.protected	copy_kernel             ; -- Begin function copy_kernel
	.globl	copy_kernel
	.p2align	8
	.type	copy_kernel,@function
copy_kernel:                            ; @copy_kernel
; %bb.0:
	s_clause 0x1
	s_load_dword s0, s[4:5], 0x24
	s_load_dword s1, s[4:5], 0x0
	s_waitcnt lgkmcnt(0)
	s_and_b32 s0, s0, 0xffff
	v_mad_u64_u32 v[0:1], null, s6, s0, v[0:1]
	s_mov_b32 s0, exec_lo
	v_cmpx_gt_i32_e64 s1, v0
	s_cbranch_execz .LBB3_2
; %bb.1:
	s_load_dwordx4 s[0:3], s[4:5], 0x8
	v_ashrrev_i32_e32 v1, 31, v0
	v_lshlrev_b64 v[0:1], 2, v[0:1]
	s_waitcnt lgkmcnt(0)
	v_add_co_u32 v2, vcc_lo, s0, v0
	v_add_co_ci_u32_e64 v3, null, s1, v1, vcc_lo
	v_add_co_u32 v0, vcc_lo, s2, v0
	v_add_co_ci_u32_e64 v1, null, s3, v1, vcc_lo
	global_load_dword v2, v[2:3], off
	s_waitcnt vmcnt(0)
	global_store_dword v[0:1], v2, off
.LBB3_2:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel copy_kernel
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 280
		.amdhsa_user_sgpr_count 6
		.amdhsa_user_sgpr_private_segment_buffer 1
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_flat_scratch_init 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_wavefront_size32 1
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_system_sgpr_private_segment_wavefront_offset 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 4
		.amdhsa_next_free_sgpr 7
		.amdhsa_reserve_vcc 1
		.amdhsa_reserve_flat_scratch 0
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 3
		.amdhsa_float_denorm_mode_16_64 3
		.amdhsa_dx10_clamp 1
		.amdhsa_ieee_mode 1
		.amdhsa_fp16_overflow 0
		.amdhsa_workgroup_processor_mode 1
		.amdhsa_memory_ordered 1
		.amdhsa_forward_progress 1
		.amdhsa_shared_vgpr_count 0
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.text
.Lfunc_end3:
	.size	copy_kernel, .Lfunc_end3-copy_kernel
                                        ; -- End function
	.set copy_kernel.num_vgpr, 4
	.set copy_kernel.num_agpr, 0
	.set copy_kernel.numbered_sgpr, 7
	.set copy_kernel.num_named_barrier, 0
	.set copy_kernel.private_seg_size, 0
	.set copy_kernel.uses_vcc, 1
	.set copy_kernel.uses_flat_scratch, 0
	.set copy_kernel.has_dyn_sized_stack, 0
	.set copy_kernel.has_recursion, 0
	.set copy_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 136
; TotalNumSgprs: 9
; NumVgprs: 4
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 0
; VGPRBlocks: 0
; NumSGPRsForWavesPerEU: 9
; NumVGPRsForWavesPerEU: 4
; Occupancy: 16
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 6
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
	.text
	.protected	axpy_kernel             ; -- Begin function axpy_kernel
	.globl	axpy_kernel
	.p2align	8
	.type	axpy_kernel,@function
axpy_kernel:                            ; @axpy_kernel
; %bb.0:
	s_clause 0x1
	s_load_dword s2, s[4:5], 0x24
	s_load_dwordx2 s[0:1], s[4:5], 0x0
	s_waitcnt lgkmcnt(0)
	s_and_b32 s2, s2, 0xffff
	v_mad_u64_u32 v[0:1], null, s6, s2, v[0:1]
	v_cmp_gt_i32_e32 vcc_lo, s0, v0
	s_and_saveexec_b32 s0, vcc_lo
	s_cbranch_execz .LBB4_2
; %bb.1:
	s_load_dwordx4 s[4:7], s[4:5], 0x8
	v_ashrrev_i32_e32 v1, 31, v0
	v_lshlrev_b64 v[0:1], 2, v[0:1]
	s_waitcnt lgkmcnt(0)
	v_add_co_u32 v2, vcc_lo, s4, v0
	v_add_co_ci_u32_e64 v3, null, s5, v1, vcc_lo
	v_add_co_u32 v0, vcc_lo, s6, v0
	v_add_co_ci_u32_e64 v1, null, s7, v1, vcc_lo
	global_load_dword v2, v[2:3], off
	global_load_dword v3, v[0:1], off
	s_waitcnt vmcnt(0)
	v_fmac_f32_e32 v3, s1, v2
	global_store_dword v[0:1], v3, off
.LBB4_2:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel axpy_kernel
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 280
		.amdhsa_user_sgpr_count 6
		.amdhsa_user_sgpr_private_segment_buffer 1
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_flat_scratch_init 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_wavefront_size32 1
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_system_sgpr_private_segment_wavefront_offset 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 4
		.amdhsa_next_free_sgpr 8
		.amdhsa_reserve_vcc 1
		.amdhsa_reserve_flat_scratch 0
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 3
		.amdhsa_float_denorm_mode_16_64 3
		.amdhsa_dx10_clamp 1
		.amdhsa_ieee_mode 1
		.amdhsa_fp16_overflow 0
		.amdhsa_workgroup_processor_mode 1
		.amdhsa_memory_ordered 1
		.amdhsa_forward_progress 1
		.amdhsa_shared_vgpr_count 0
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.text
.Lfunc_end4:
	.size	axpy_kernel, .Lfunc_end4-axpy_kernel
                                        ; -- End function
	.set axpy_kernel.num_vgpr, 4
	.set axpy_kernel.num_agpr, 0
	.set axpy_kernel.numbered_sgpr, 8
	.set axpy_kernel.num_named_barrier, 0
	.set axpy_kernel.private_seg_size, 0
	.set axpy_kernel.uses_vcc, 1
	.set axpy_kernel.uses_flat_scratch, 0
	.set axpy_kernel.has_dyn_sized_stack, 0
	.set axpy_kernel.has_recursion, 0
	.set axpy_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 144
; TotalNumSgprs: 10
; NumVgprs: 4
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 0
; VGPRBlocks: 0
; NumSGPRsForWavesPerEU: 10
; NumVGPRsForWavesPerEU: 4
; Occupancy: 16
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 6
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
	.text
	.protected	scal_kernel             ; -- Begin function scal_kernel
	.globl	scal_kernel
	.p2align	8
	.type	scal_kernel,@function
scal_kernel:                            ; @scal_kernel
; %bb.0:
	s_clause 0x1
	s_load_dword s2, s[4:5], 0x1c
	s_load_dwordx2 s[0:1], s[4:5], 0x0
	s_waitcnt lgkmcnt(0)
	s_and_b32 s2, s2, 0xffff
	v_mad_u64_u32 v[0:1], null, s6, s2, v[0:1]
	v_cmp_gt_i32_e32 vcc_lo, s0, v0
	s_and_saveexec_b32 s0, vcc_lo
	s_cbranch_execz .LBB5_2
; %bb.1:
	s_load_dwordx2 s[2:3], s[4:5], 0x8
	v_ashrrev_i32_e32 v1, 31, v0
	v_lshlrev_b64 v[0:1], 2, v[0:1]
	s_waitcnt lgkmcnt(0)
	v_add_co_u32 v0, vcc_lo, s2, v0
	v_add_co_ci_u32_e64 v1, null, s3, v1, vcc_lo
	global_load_dword v2, v[0:1], off
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v2, s1, v2
	global_store_dword v[0:1], v2, off
.LBB5_2:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel scal_kernel
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 272
		.amdhsa_user_sgpr_count 6
		.amdhsa_user_sgpr_private_segment_buffer 1
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_flat_scratch_init 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_wavefront_size32 1
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_system_sgpr_private_segment_wavefront_offset 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 3
		.amdhsa_next_free_sgpr 7
		.amdhsa_reserve_vcc 1
		.amdhsa_reserve_flat_scratch 0
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 3
		.amdhsa_float_denorm_mode_16_64 3
		.amdhsa_dx10_clamp 1
		.amdhsa_ieee_mode 1
		.amdhsa_fp16_overflow 0
		.amdhsa_workgroup_processor_mode 1
		.amdhsa_memory_ordered 1
		.amdhsa_forward_progress 1
		.amdhsa_shared_vgpr_count 0
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.text
.Lfunc_end5:
	.size	scal_kernel, .Lfunc_end5-scal_kernel
                                        ; -- End function
	.set scal_kernel.num_vgpr, 3
	.set scal_kernel.num_agpr, 0
	.set scal_kernel.numbered_sgpr, 7
	.set scal_kernel.num_named_barrier, 0
	.set scal_kernel.private_seg_size, 0
	.set scal_kernel.uses_vcc, 1
	.set scal_kernel.uses_flat_scratch, 0
	.set scal_kernel.has_dyn_sized_stack, 0
	.set scal_kernel.has_recursion, 0
	.set scal_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 120
; TotalNumSgprs: 9
; NumVgprs: 3
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 0
; VGPRBlocks: 0
; NumSGPRsForWavesPerEU: 9
; NumVGPRsForWavesPerEU: 3
; Occupancy: 16
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 6
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
	.text
	.protected	mul_kernel              ; -- Begin function mul_kernel
	.globl	mul_kernel
	.p2align	8
	.type	mul_kernel,@function
mul_kernel:                             ; @mul_kernel
; %bb.0:
	s_clause 0x1
	s_load_dword s0, s[4:5], 0x24
	s_load_dword s1, s[4:5], 0x0
	s_waitcnt lgkmcnt(0)
	s_and_b32 s0, s0, 0xffff
	v_mad_u64_u32 v[0:1], null, s6, s0, v[0:1]
	s_mov_b32 s0, exec_lo
	v_cmpx_gt_i32_e64 s1, v0
	s_cbranch_execz .LBB6_2
; %bb.1:
	s_load_dwordx4 s[0:3], s[4:5], 0x8
	v_ashrrev_i32_e32 v1, 31, v0
	v_lshlrev_b64 v[0:1], 2, v[0:1]
	s_waitcnt lgkmcnt(0)
	v_add_co_u32 v2, vcc_lo, s0, v0
	v_add_co_ci_u32_e64 v3, null, s1, v1, vcc_lo
	v_add_co_u32 v0, vcc_lo, s2, v0
	v_add_co_ci_u32_e64 v1, null, s3, v1, vcc_lo
	global_load_dword v2, v[2:3], off
	global_load_dword v3, v[0:1], off
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v2, v2, v3
	global_store_dword v[0:1], v2, off
.LBB6_2:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel mul_kernel
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 280
		.amdhsa_user_sgpr_count 6
		.amdhsa_user_sgpr_private_segment_buffer 1
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_flat_scratch_init 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_wavefront_size32 1
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_system_sgpr_private_segment_wavefront_offset 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 4
		.amdhsa_next_free_sgpr 7
		.amdhsa_reserve_vcc 1
		.amdhsa_reserve_flat_scratch 0
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 3
		.amdhsa_float_denorm_mode_16_64 3
		.amdhsa_dx10_clamp 1
		.amdhsa_ieee_mode 1
		.amdhsa_fp16_overflow 0
		.amdhsa_workgroup_processor_mode 1
		.amdhsa_memory_ordered 1
		.amdhsa_forward_progress 1
		.amdhsa_shared_vgpr_count 0
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.text
.Lfunc_end6:
	.size	mul_kernel, .Lfunc_end6-mul_kernel
                                        ; -- End function
	.set mul_kernel.num_vgpr, 4
	.set mul_kernel.num_agpr, 0
	.set mul_kernel.numbered_sgpr, 7
	.set mul_kernel.num_named_barrier, 0
	.set mul_kernel.private_seg_size, 0
	.set mul_kernel.uses_vcc, 1
	.set mul_kernel.uses_flat_scratch, 0
	.set mul_kernel.has_dyn_sized_stack, 0
	.set mul_kernel.has_recursion, 0
	.set mul_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 148
; TotalNumSgprs: 9
; NumVgprs: 4
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 0
; VGPRBlocks: 0
; NumSGPRsForWavesPerEU: 9
; NumVGPRsForWavesPerEU: 4
; Occupancy: 16
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 6
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
	.text
	.protected	add_scalar_kernel       ; -- Begin function add_scalar_kernel
	.globl	add_scalar_kernel
	.p2align	8
	.type	add_scalar_kernel,@function
add_scalar_kernel:                      ; @add_scalar_kernel
; %bb.0:
	s_clause 0x1
	s_load_dword s2, s[4:5], 0x1c
	s_load_dwordx2 s[0:1], s[4:5], 0x0
	s_waitcnt lgkmcnt(0)
	s_and_b32 s2, s2, 0xffff
	v_mad_u64_u32 v[0:1], null, s6, s2, v[0:1]
	v_cmp_gt_i32_e32 vcc_lo, s0, v0
	s_and_saveexec_b32 s0, vcc_lo
	s_cbranch_execz .LBB7_2
; %bb.1:
	s_load_dwordx2 s[2:3], s[4:5], 0x8
	v_ashrrev_i32_e32 v1, 31, v0
	v_lshlrev_b64 v[0:1], 2, v[0:1]
	s_waitcnt lgkmcnt(0)
	v_add_co_u32 v0, vcc_lo, s2, v0
	v_add_co_ci_u32_e64 v1, null, s3, v1, vcc_lo
	global_load_dword v2, v[0:1], off
	s_waitcnt vmcnt(0)
	v_add_f32_e32 v2, s1, v2
	global_store_dword v[0:1], v2, off
.LBB7_2:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel add_scalar_kernel
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 272
		.amdhsa_user_sgpr_count 6
		.amdhsa_user_sgpr_private_segment_buffer 1
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_flat_scratch_init 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_wavefront_size32 1
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_system_sgpr_private_segment_wavefront_offset 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 3
		.amdhsa_next_free_sgpr 7
		.amdhsa_reserve_vcc 1
		.amdhsa_reserve_flat_scratch 0
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 3
		.amdhsa_float_denorm_mode_16_64 3
		.amdhsa_dx10_clamp 1
		.amdhsa_ieee_mode 1
		.amdhsa_fp16_overflow 0
		.amdhsa_workgroup_processor_mode 1
		.amdhsa_memory_ordered 1
		.amdhsa_forward_progress 1
		.amdhsa_shared_vgpr_count 0
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.text
.Lfunc_end7:
	.size	add_scalar_kernel, .Lfunc_end7-add_scalar_kernel
                                        ; -- End function
	.set add_scalar_kernel.num_vgpr, 3
	.set add_scalar_kernel.num_agpr, 0
	.set add_scalar_kernel.numbered_sgpr, 7
	.set add_scalar_kernel.num_named_barrier, 0
	.set add_scalar_kernel.private_seg_size, 0
	.set add_scalar_kernel.uses_vcc, 1
	.set add_scalar_kernel.uses_flat_scratch, 0
	.set add_scalar_kernel.has_dyn_sized_stack, 0
	.set add_scalar_kernel.has_recursion, 0
	.set add_scalar_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 120
; TotalNumSgprs: 9
; NumVgprs: 3
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 0
; VGPRBlocks: 0
; NumSGPRsForWavesPerEU: 9
; NumVGPRsForWavesPerEU: 3
; Occupancy: 16
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 6
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
	.text
	.protected	constrain_kernel        ; -- Begin function constrain_kernel
	.globl	constrain_kernel
	.p2align	8
	.type	constrain_kernel,@function
constrain_kernel:                       ; @constrain_kernel
; %bb.0:
	s_clause 0x1
	s_load_dword s2, s[4:5], 0x1c
	s_load_dwordx2 s[0:1], s[4:5], 0x0
	s_waitcnt lgkmcnt(0)
	s_and_b32 s2, s2, 0xffff
	v_mad_u64_u32 v[0:1], null, s6, s2, v[0:1]
	v_cmp_gt_i32_e32 vcc_lo, s0, v0
	s_and_saveexec_b32 s0, vcc_lo
	s_cbranch_execz .LBB8_2
; %bb.1:
	s_load_dwordx2 s[2:3], s[4:5], 0x8
	v_ashrrev_i32_e32 v1, 31, v0
	v_max_f32_e64 v3, -s1, -s1
	v_lshlrev_b64 v[0:1], 2, v[0:1]
	s_waitcnt lgkmcnt(0)
	v_add_co_u32 v0, vcc_lo, s2, v0
	v_add_co_ci_u32_e64 v1, null, s3, v1, vcc_lo
	global_load_dword v2, v[0:1], off
	s_waitcnt vmcnt(0)
	v_max_f32_e32 v2, v2, v2
	v_max_f32_e32 v2, v3, v2
	v_max_f32_e64 v3, s1, s1
	v_min_f32_e32 v2, v3, v2
	global_store_dword v[0:1], v2, off
.LBB8_2:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel constrain_kernel
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 272
		.amdhsa_user_sgpr_count 6
		.amdhsa_user_sgpr_private_segment_buffer 1
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_flat_scratch_init 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_wavefront_size32 1
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_system_sgpr_private_segment_wavefront_offset 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 4
		.amdhsa_next_free_sgpr 7
		.amdhsa_reserve_vcc 1
		.amdhsa_reserve_flat_scratch 0
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 3
		.amdhsa_float_denorm_mode_16_64 3
		.amdhsa_dx10_clamp 1
		.amdhsa_ieee_mode 1
		.amdhsa_fp16_overflow 0
		.amdhsa_workgroup_processor_mode 1
		.amdhsa_memory_ordered 1
		.amdhsa_forward_progress 1
		.amdhsa_shared_vgpr_count 0
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.text
.Lfunc_end8:
	.size	constrain_kernel, .Lfunc_end8-constrain_kernel
                                        ; -- End function
	.set constrain_kernel.num_vgpr, 4
	.set constrain_kernel.num_agpr, 0
	.set constrain_kernel.numbered_sgpr, 7
	.set constrain_kernel.num_named_barrier, 0
	.set constrain_kernel.private_seg_size, 0
	.set constrain_kernel.uses_vcc, 1
	.set constrain_kernel.uses_flat_scratch, 0
	.set constrain_kernel.has_dyn_sized_stack, 0
	.set constrain_kernel.has_recursion, 0
	.set constrain_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 144
; TotalNumSgprs: 9
; NumVgprs: 4
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 0
; VGPRBlocks: 0
; NumSGPRsForWavesPerEU: 9
; NumVGPRsForWavesPerEU: 4
; Occupancy: 16
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 6
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
	.text
	.protected	rand_uniform_kernel     ; -- Begin function rand_uniform_kernel
	.globl	rand_uniform_kernel
	.p2align	8
	.type	rand_uniform_kernel,@function
rand_uniform_kernel:                    ; @rand_uniform_kernel
; %bb.0:
	s_clause 0x1
	s_load_dword s0, s[4:5], 0x24
	s_load_dword s1, s[4:5], 0x0
	s_waitcnt lgkmcnt(0)
	s_and_b32 s0, s0, 0xffff
	v_mad_u64_u32 v[0:1], null, s6, s0, v[0:1]
	s_mov_b32 s0, exec_lo
	v_cmpx_gt_i32_e64 s1, v0
	s_cbranch_execz .LBB9_2
; %bb.1:
	v_xor_b32_sdwa v1, v0, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	s_load_dword s0, s[4:5], 0x10
	v_mul_lo_u32 v1, 0x7feb352d, v1
	v_lshrrev_b32_e32 v2, 15, v1
	v_xor_b32_e32 v1, v2, v1
	v_mul_lo_u32 v1, 0x846ca68b, v1
	v_lshrrev_b32_e32 v2, 16, v1
	s_waitcnt lgkmcnt(0)
	v_xor3_b32 v1, s0, v2, v1
	s_load_dwordx2 s[0:1], s[4:5], 0x8
	v_xor_b32_sdwa v1, v1, v1 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	v_mul_lo_u32 v1, 0x7feb352d, v1
	v_lshrrev_b32_e32 v2, 15, v1
	v_xor_b32_e32 v1, v2, v1
	v_mul_lo_u32 v1, 0x846ca68b, v1
	v_lshrrev_b32_e32 v2, 8, v1
	v_xor_b32_sdwa v2, v1, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_3 src1_sel:DWORD
	v_ashrrev_i32_e32 v1, 31, v0
	v_cvt_f32_u32_e32 v2, v2
	v_lshlrev_b64 v[0:1], 2, v[0:1]
	v_mul_f32_e32 v2, 0x33800000, v2
	s_waitcnt lgkmcnt(0)
	v_add_co_u32 v0, vcc_lo, s0, v0
	v_add_co_ci_u32_e64 v1, null, s1, v1, vcc_lo
	global_store_dword v[0:1], v2, off
.LBB9_2:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel rand_uniform_kernel
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 280
		.amdhsa_user_sgpr_count 6
		.amdhsa_user_sgpr_private_segment_buffer 1
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_flat_scratch_init 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_wavefront_size32 1
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_system_sgpr_private_segment_wavefront_offset 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 3
		.amdhsa_next_free_sgpr 7
		.amdhsa_reserve_vcc 1
		.amdhsa_reserve_flat_scratch 0
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 3
		.amdhsa_float_denorm_mode_16_64 3
		.amdhsa_dx10_clamp 1
		.amdhsa_ieee_mode 1
		.amdhsa_fp16_overflow 0
		.amdhsa_workgroup_processor_mode 1
		.amdhsa_memory_ordered 1
		.amdhsa_forward_progress 1
		.amdhsa_shared_vgpr_count 0
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.text
.Lfunc_end9:
	.size	rand_uniform_kernel, .Lfunc_end9-rand_uniform_kernel
                                        ; -- End function
	.set rand_uniform_kernel.num_vgpr, 3
	.set rand_uniform_kernel.num_agpr, 0
	.set rand_uniform_kernel.numbered_sgpr, 7
	.set rand_uniform_kernel.num_named_barrier, 0
	.set rand_uniform_kernel.private_seg_size, 0
	.set rand_uniform_kernel.uses_vcc, 1
	.set rand_uniform_kernel.uses_flat_scratch, 0
	.set rand_uniform_kernel.has_dyn_sized_stack, 0
	.set rand_uniform_kernel.has_recursion, 0
	.set rand_uniform_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 236
; TotalNumSgprs: 9
; NumVgprs: 3
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 0
; VGPRBlocks: 0
; NumSGPRsForWavesPerEU: 9
; NumVGPRsForWavesPerEU: 3
; Occupancy: 16
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 6
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
	.text
	.protected	add_bias_kernel         ; -- Begin function add_bias_kernel
	.globl	add_bias_kernel
	.p2align	8
	.type	add_bias_kernel,@function
add_bias_kernel:                        ; @add_bias_kernel
; %bb.0:
	s_clause 0x1
	s_load_dword s7, s[4:5], 0x2c
	s_load_dwordx4 s[0:3], s[4:5], 0x10
	s_waitcnt lgkmcnt(0)
	s_and_b32 s3, s7, 0xffff
	s_mul_i32 s0, s1, s0
	v_mad_u64_u32 v[0:1], null, s6, s3, v[0:1]
	s_mul_i32 s0, s0, s2
	v_cmp_gt_i32_e32 vcc_lo, s0, v0
	s_and_saveexec_b32 s0, vcc_lo
	s_cbranch_execz .LBB10_2
; %bb.1:
	s_abs_i32 s0, s2
	v_sub_nc_u32_e32 v3, 0, v0
	v_cvt_f32_u32_e32 v1, s0
	s_sub_i32 s3, 0, s0
	s_abs_i32 s1, s1
	v_max_i32_e32 v3, v0, v3
	v_rcp_iflag_f32_e32 v1, v1
	v_cvt_f32_u32_e32 v4, s1
	v_rcp_iflag_f32_e32 v4, v4
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	v_mul_f32_e32 v4, 0x4f7ffffe, v4
	v_mul_lo_u32 v2, s3, v1
	v_cvt_u32_f32_e32 v4, v4
	v_mul_hi_u32 v2, v1, v2
	v_add_nc_u32_e32 v1, v1, v2
	v_mul_hi_u32 v1, v3, v1
	v_mul_lo_u32 v2, v1, s0
	v_sub_nc_u32_e32 v2, v3, v2
	v_add_nc_u32_e32 v3, 1, v1
	v_subrev_nc_u32_e32 v5, s0, v2
	v_cmp_le_u32_e32 vcc_lo, s0, v2
	v_cndmask_b32_e32 v1, v1, v3, vcc_lo
	v_cndmask_b32_e32 v2, v2, v5, vcc_lo
	v_xor_b32_e32 v3, s2, v0
	v_add_nc_u32_e32 v5, 1, v1
	v_cmp_le_u32_e32 vcc_lo, s0, v2
	v_ashrrev_i32_e32 v3, 31, v3
	s_sub_i32 s0, 0, s1
	v_mul_lo_u32 v2, s0, v4
	v_cndmask_b32_e32 v1, v1, v5, vcc_lo
	v_xor_b32_e32 v1, v1, v3
	v_mul_hi_u32 v2, v4, v2
	v_sub_nc_u32_e32 v1, v1, v3
	v_add_nc_u32_e32 v2, v4, v2
	v_sub_nc_u32_e32 v3, 0, v1
	v_max_i32_e32 v3, v1, v3
	v_ashrrev_i32_e32 v1, 31, v1
	v_mul_hi_u32 v2, v3, v2
	v_mul_lo_u32 v2, v2, s1
	v_sub_nc_u32_e32 v2, v3, v2
	v_subrev_nc_u32_e32 v3, s1, v2
	v_cmp_le_u32_e32 vcc_lo, s1, v2
	v_cndmask_b32_e32 v2, v2, v3, vcc_lo
	v_subrev_nc_u32_e32 v3, s1, v2
	v_cmp_le_u32_e32 vcc_lo, s1, v2
	s_load_dwordx4 s[0:3], s[4:5], 0x0
	v_cndmask_b32_e32 v2, v2, v3, vcc_lo
	v_xor_b32_e32 v2, v2, v1
	v_sub_nc_u32_e32 v2, v2, v1
	v_ashrrev_i32_e32 v1, 31, v0
	v_ashrrev_i32_e32 v3, 31, v2
	v_lshlrev_b64 v[0:1], 2, v[0:1]
	v_lshlrev_b64 v[2:3], 2, v[2:3]
	s_waitcnt lgkmcnt(0)
	v_add_co_u32 v2, vcc_lo, s2, v2
	v_add_co_ci_u32_e64 v3, null, s3, v3, vcc_lo
	v_add_co_u32 v0, vcc_lo, s0, v0
	v_add_co_ci_u32_e64 v1, null, s1, v1, vcc_lo
	global_load_dword v2, v[2:3], off
	global_load_dword v3, v[0:1], off
	s_waitcnt vmcnt(0)
	v_add_f32_e32 v2, v2, v3
	global_store_dword v[0:1], v2, off
.LBB10_2:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel add_bias_kernel
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 288
		.amdhsa_user_sgpr_count 6
		.amdhsa_user_sgpr_private_segment_buffer 1
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_flat_scratch_init 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_wavefront_size32 1
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_system_sgpr_private_segment_wavefront_offset 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 6
		.amdhsa_next_free_sgpr 8
		.amdhsa_reserve_vcc 1
		.amdhsa_reserve_flat_scratch 0
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 3
		.amdhsa_float_denorm_mode_16_64 3
		.amdhsa_dx10_clamp 1
		.amdhsa_ieee_mode 1
		.amdhsa_fp16_overflow 0
		.amdhsa_workgroup_processor_mode 1
		.amdhsa_memory_ordered 1
		.amdhsa_forward_progress 1
		.amdhsa_shared_vgpr_count 0
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.text
.Lfunc_end10:
	.size	add_bias_kernel, .Lfunc_end10-add_bias_kernel
                                        ; -- End function
	.set add_bias_kernel.num_vgpr, 6
	.set add_bias_kernel.num_agpr, 0
	.set add_bias_kernel.numbered_sgpr, 8
	.set add_bias_kernel.num_named_barrier, 0
	.set add_bias_kernel.private_seg_size, 0
	.set add_bias_kernel.uses_vcc, 1
	.set add_bias_kernel.uses_flat_scratch, 0
	.set add_bias_kernel.has_dyn_sized_stack, 0
	.set add_bias_kernel.has_recursion, 0
	.set add_bias_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 400
; TotalNumSgprs: 10
; NumVgprs: 6
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 0
; VGPRBlocks: 0
; NumSGPRsForWavesPerEU: 10
; NumVGPRsForWavesPerEU: 6
; Occupancy: 16
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 6
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
	.text
	.protected	scale_bias_kernel       ; -- Begin function scale_bias_kernel
	.globl	scale_bias_kernel
	.p2align	8
	.type	scale_bias_kernel,@function
scale_bias_kernel:                      ; @scale_bias_kernel
; %bb.0:
	s_clause 0x1
	s_load_dword s7, s[4:5], 0x2c
	s_load_dwordx4 s[0:3], s[4:5], 0x10
	s_waitcnt lgkmcnt(0)
	s_and_b32 s3, s7, 0xffff
	s_mul_i32 s0, s1, s0
	v_mad_u64_u32 v[0:1], null, s6, s3, v[0:1]
	s_mul_i32 s0, s0, s2
	v_cmp_gt_i32_e32 vcc_lo, s0, v0
	s_and_saveexec_b32 s0, vcc_lo
	s_cbranch_execz .LBB11_2
; %bb.1:
	s_abs_i32 s0, s2
	v_sub_nc_u32_e32 v3, 0, v0
	v_cvt_f32_u32_e32 v1, s0
	s_sub_i32 s3, 0, s0
	s_abs_i32 s1, s1
	v_max_i32_e32 v3, v0, v3
	v_rcp_iflag_f32_e32 v1, v1
	v_cvt_f32_u32_e32 v4, s1
	v_rcp_iflag_f32_e32 v4, v4
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	v_mul_f32_e32 v4, 0x4f7ffffe, v4
	v_mul_lo_u32 v2, s3, v1
	v_cvt_u32_f32_e32 v4, v4
	v_mul_hi_u32 v2, v1, v2
	v_add_nc_u32_e32 v1, v1, v2
	v_mul_hi_u32 v1, v3, v1
	v_mul_lo_u32 v2, v1, s0
	v_sub_nc_u32_e32 v2, v3, v2
	v_add_nc_u32_e32 v3, 1, v1
	v_subrev_nc_u32_e32 v5, s0, v2
	v_cmp_le_u32_e32 vcc_lo, s0, v2
	v_cndmask_b32_e32 v1, v1, v3, vcc_lo
	v_cndmask_b32_e32 v2, v2, v5, vcc_lo
	v_xor_b32_e32 v3, s2, v0
	v_add_nc_u32_e32 v5, 1, v1
	v_cmp_le_u32_e32 vcc_lo, s0, v2
	v_ashrrev_i32_e32 v3, 31, v3
	s_sub_i32 s0, 0, s1
	v_mul_lo_u32 v2, s0, v4
	v_cndmask_b32_e32 v1, v1, v5, vcc_lo
	v_xor_b32_e32 v1, v1, v3
	v_mul_hi_u32 v2, v4, v2
	v_sub_nc_u32_e32 v1, v1, v3
	v_add_nc_u32_e32 v2, v4, v2
	v_sub_nc_u32_e32 v3, 0, v1
	v_max_i32_e32 v3, v1, v3
	v_ashrrev_i32_e32 v1, 31, v1
	v_mul_hi_u32 v2, v3, v2
	v_mul_lo_u32 v2, v2, s1
	v_sub_nc_u32_e32 v2, v3, v2
	v_subrev_nc_u32_e32 v3, s1, v2
	v_cmp_le_u32_e32 vcc_lo, s1, v2
	v_cndmask_b32_e32 v2, v2, v3, vcc_lo
	v_subrev_nc_u32_e32 v3, s1, v2
	v_cmp_le_u32_e32 vcc_lo, s1, v2
	s_load_dwordx4 s[0:3], s[4:5], 0x0
	v_cndmask_b32_e32 v2, v2, v3, vcc_lo
	v_xor_b32_e32 v2, v2, v1
	v_sub_nc_u32_e32 v2, v2, v1
	v_ashrrev_i32_e32 v1, 31, v0
	v_ashrrev_i32_e32 v3, 31, v2
	v_lshlrev_b64 v[0:1], 2, v[0:1]
	v_lshlrev_b64 v[2:3], 2, v[2:3]
	s_waitcnt lgkmcnt(0)
	v_add_co_u32 v2, vcc_lo, s2, v2
	v_add_co_ci_u32_e64 v3, null, s3, v3, vcc_lo
	v_add_co_u32 v0, vcc_lo, s0, v0
	v_add_co_ci_u32_e64 v1, null, s1, v1, vcc_lo
	global_load_dword v2, v[2:3], off
	global_load_dword v3, v[0:1], off
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v2, v2, v3
	global_store_dword v[0:1], v2, off
.LBB11_2:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel scale_bias_kernel
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 288
		.amdhsa_user_sgpr_count 6
		.amdhsa_user_sgpr_private_segment_buffer 1
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_flat_scratch_init 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_wavefront_size32 1
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_system_sgpr_private_segment_wavefront_offset 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 6
		.amdhsa_next_free_sgpr 8
		.amdhsa_reserve_vcc 1
		.amdhsa_reserve_flat_scratch 0
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 3
		.amdhsa_float_denorm_mode_16_64 3
		.amdhsa_dx10_clamp 1
		.amdhsa_ieee_mode 1
		.amdhsa_fp16_overflow 0
		.amdhsa_workgroup_processor_mode 1
		.amdhsa_memory_ordered 1
		.amdhsa_forward_progress 1
		.amdhsa_shared_vgpr_count 0
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.text
.Lfunc_end11:
	.size	scale_bias_kernel, .Lfunc_end11-scale_bias_kernel
                                        ; -- End function
	.set scale_bias_kernel.num_vgpr, 6
	.set scale_bias_kernel.num_agpr, 0
	.set scale_bias_kernel.numbered_sgpr, 8
	.set scale_bias_kernel.num_named_barrier, 0
	.set scale_bias_kernel.private_seg_size, 0
	.set scale_bias_kernel.uses_vcc, 1
	.set scale_bias_kernel.uses_flat_scratch, 0
	.set scale_bias_kernel.has_dyn_sized_stack, 0
	.set scale_bias_kernel.has_recursion, 0
	.set scale_bias_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 400
; TotalNumSgprs: 10
; NumVgprs: 6
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 0
; VGPRBlocks: 0
; NumSGPRsForWavesPerEU: 10
; NumVGPRsForWavesPerEU: 6
; Occupancy: 16
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 6
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
	.text
	.protected	backward_bias_kernel    ; -- Begin function backward_bias_kernel
	.globl	backward_bias_kernel
	.p2align	8
	.type	backward_bias_kernel,@function
backward_bias_kernel:                   ; @backward_bias_kernel
; %bb.0:
	s_load_dwordx8 s[8:15], s[4:5], 0x0
	s_waitcnt lgkmcnt(0)
	s_cmp_lt_i32 s12, 1
	s_cbranch_scc1 .LBB12_7
; %bb.1:
	v_mad_u64_u32 v[1:2], null, s6, s14, v[0:1]
	v_mov_b32_e32 v4, 0
	s_mul_i32 s2, s14, s13
	s_mov_b32 s3, 0
	v_cmp_gt_i32_e32 vcc_lo, s14, v0
	s_inst_prefetch 0x1
	s_branch .LBB12_3
	.p2align	6
.LBB12_2:                               ;   in Loop: Header=BB12_3 Depth=1
	s_or_b32 exec_lo, exec_lo, s4
	v_add_nc_u32_e32 v1, s2, v1
	s_add_i32 s3, s3, 1
	s_cmp_eq_u32 s3, s12
	s_cbranch_scc1 .LBB12_8
.LBB12_3:                               ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB12_5 Depth 2
	s_and_saveexec_b32 s4, vcc_lo
	s_cbranch_execz .LBB12_2
; %bb.4:                                ;   in Loop: Header=BB12_3 Depth=1
	v_ashrrev_i32_e32 v2, 31, v1
	v_mov_b32_e32 v5, v0
	s_mov_b32 s5, 0
	v_lshlrev_b64 v[2:3], 2, v[1:2]
	v_add_co_u32 v2, s0, s10, v2
	v_add_co_ci_u32_e64 v3, null, s11, v3, s0
.LBB12_5:                               ;   Parent Loop BB12_3 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	global_load_dword v6, v[2:3], off
	v_add_nc_u32_e32 v5, 0x100, v5
	v_add_co_u32 v2, s0, 0x400, v2
	v_add_co_ci_u32_e64 v3, null, 0, v3, s0
	v_cmp_le_i32_e64 s1, s14, v5
	s_or_b32 s5, s1, s5
	s_waitcnt vmcnt(0)
	v_add_f32_e32 v4, v4, v6
	s_andn2_b32 exec_lo, exec_lo, s5
	s_cbranch_execnz .LBB12_5
; %bb.6:                                ;   in Loop: Header=BB12_3 Depth=1
	s_or_b32 exec_lo, exec_lo, s5
	s_branch .LBB12_2
.LBB12_7:
	v_mov_b32_e32 v4, 0
.LBB12_8:
	s_inst_prefetch 0x2
	v_lshlrev_b32_e32 v1, 2, v0
	s_mov_b32 s0, exec_lo
	ds_write_b32 v1, v4
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	v_cmpx_gt_u32_e32 0x80, v0
	s_cbranch_execz .LBB12_10
; %bb.9:
	ds_read2st64_b32 v[2:3], v1 offset1:2
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v3, v2
	ds_write_b32 v1, v2
.LBB12_10:
	s_or_b32 exec_lo, exec_lo, s0
	s_mov_b32 s0, exec_lo
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	v_cmpx_gt_u32_e32 64, v0
	s_cbranch_execz .LBB12_12
; %bb.11:
	ds_read2st64_b32 v[2:3], v1 offset1:1
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v3, v2
	ds_write_b32 v1, v2
.LBB12_12:
	s_or_b32 exec_lo, exec_lo, s0
	s_mov_b32 s0, exec_lo
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	v_cmpx_gt_u32_e32 32, v0
	s_cbranch_execz .LBB12_14
; %bb.13:
	ds_read2_b32 v[2:3], v1 offset1:32
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v3, v2
	ds_write_b32 v1, v2
.LBB12_14:
	s_or_b32 exec_lo, exec_lo, s0
	s_mov_b32 s0, exec_lo
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	v_cmpx_gt_u32_e32 16, v0
	s_cbranch_execz .LBB12_16
; %bb.15:
	ds_read2_b32 v[2:3], v1 offset1:16
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v3, v2
	ds_write_b32 v1, v2
.LBB12_16:
	s_or_b32 exec_lo, exec_lo, s0
	s_mov_b32 s0, exec_lo
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	v_cmpx_gt_u32_e32 8, v0
	s_cbranch_execz .LBB12_18
; %bb.17:
	ds_read2_b32 v[2:3], v1 offset1:8
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v3, v2
	ds_write_b32 v1, v2
.LBB12_18:
	s_or_b32 exec_lo, exec_lo, s0
	s_mov_b32 s0, exec_lo
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	v_cmpx_gt_u32_e32 4, v0
	s_cbranch_execz .LBB12_20
; %bb.19:
	ds_read2_b32 v[2:3], v1 offset1:4
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v3, v2
	ds_write_b32 v1, v2
.LBB12_20:
	s_or_b32 exec_lo, exec_lo, s0
	s_mov_b32 s0, exec_lo
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	v_cmpx_gt_u32_e32 2, v0
	s_cbranch_execz .LBB12_22
; %bb.21:
	ds_read2_b32 v[2:3], v1 offset1:2
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v3, v2
	ds_write_b32 v1, v2
.LBB12_22:
	s_or_b32 exec_lo, exec_lo, s0
	v_cmp_eq_u32_e32 vcc_lo, 0, v0
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	s_and_saveexec_b32 s0, vcc_lo
	s_cbranch_execz .LBB12_24
; %bb.23:
	v_mov_b32_e32 v0, 0
	ds_read_b32 v0, v0 offset:4
	ds_read_b32 v2, v1
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v0, v0, v2
	ds_write_b32 v1, v0
.LBB12_24:
	s_or_b32 exec_lo, exec_lo, s0
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	s_and_saveexec_b32 s0, vcc_lo
	s_cbranch_execz .LBB12_26
; %bb.25:
	s_ashr_i32 s7, s6, 31
	v_mov_b32_e32 v0, 0
	s_lshl_b64 s[0:1], s[6:7], 2
	s_add_u32 s0, s8, s0
	s_addc_u32 s1, s9, s1
	ds_read_b32 v1, v0
	s_load_dword s2, s[0:1], 0x0
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v1, s2, v1
	global_store_dword v0, v1, s[0:1]
.LBB12_26:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel backward_bias_kernel
		.amdhsa_group_segment_fixed_size 1024
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 28
		.amdhsa_user_sgpr_count 6
		.amdhsa_user_sgpr_private_segment_buffer 1
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_flat_scratch_init 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_wavefront_size32 1
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_system_sgpr_private_segment_wavefront_offset 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 7
		.amdhsa_next_free_sgpr 16
		.amdhsa_reserve_vcc 1
		.amdhsa_reserve_flat_scratch 0
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 3
		.amdhsa_float_denorm_mode_16_64 3
		.amdhsa_dx10_clamp 1
		.amdhsa_ieee_mode 1
		.amdhsa_fp16_overflow 0
		.amdhsa_workgroup_processor_mode 1
		.amdhsa_memory_ordered 1
		.amdhsa_forward_progress 1
		.amdhsa_shared_vgpr_count 0
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.text
.Lfunc_end12:
	.size	backward_bias_kernel, .Lfunc_end12-backward_bias_kernel
                                        ; -- End function
	.set backward_bias_kernel.num_vgpr, 7
	.set backward_bias_kernel.num_agpr, 0
	.set backward_bias_kernel.numbered_sgpr, 16
	.set backward_bias_kernel.num_named_barrier, 0
	.set backward_bias_kernel.private_seg_size, 0
	.set backward_bias_kernel.uses_vcc, 1
	.set backward_bias_kernel.uses_flat_scratch, 0
	.set backward_bias_kernel.has_dyn_sized_stack, 0
	.set backward_bias_kernel.has_recursion, 0
	.set backward_bias_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 764
; TotalNumSgprs: 18
; NumVgprs: 7
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 1024 bytes/workgroup (compile time only)
; SGPRBlocks: 0
; VGPRBlocks: 0
; NumSGPRsForWavesPerEU: 18
; NumVGPRsForWavesPerEU: 7
; Occupancy: 16
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 6
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
	.text
	.protected	backward_bias_conn_kernel ; -- Begin function backward_bias_conn_kernel
	.globl	backward_bias_conn_kernel
	.p2align	8
	.type	backward_bias_conn_kernel,@function
backward_bias_conn_kernel:              ; @backward_bias_conn_kernel
; %bb.0:
	s_clause 0x1
	s_load_dword s0, s[4:5], 0x24
	s_load_dwordx2 s[8:9], s[4:5], 0x10
	s_waitcnt lgkmcnt(0)
	s_and_b32 s0, s0, 0xffff
	v_mad_u64_u32 v[0:1], null, s6, s0, v[0:1]
	s_mov_b32 s0, exec_lo
	v_cmpx_gt_i32_e64 s9, v0
	s_cbranch_execz .LBB13_5
; %bb.1:
	s_load_dwordx4 s[0:3], s[4:5], 0x0
	v_mov_b32_e32 v3, 0
	s_cmp_lt_i32 s8, 1
	s_cbranch_scc1 .LBB13_4
; %bb.2:
	v_mov_b32_e32 v1, v0
.LBB13_3:                               ; =>This Inner Loop Header: Depth=1
	v_ashrrev_i32_e32 v2, 31, v1
	s_add_i32 s8, s8, -1
	s_cmp_eq_u32 s8, 0
	v_lshlrev_b64 v[4:5], 2, v[1:2]
	v_add_nc_u32_e32 v1, s9, v1
	s_waitcnt lgkmcnt(0)
	v_add_co_u32 v4, vcc_lo, s2, v4
	v_add_co_ci_u32_e64 v5, null, s3, v5, vcc_lo
	global_load_dword v2, v[4:5], off
	s_waitcnt vmcnt(0)
	v_add_f32_e32 v3, v3, v2
	s_cbranch_scc0 .LBB13_3
.LBB13_4:
	v_ashrrev_i32_e32 v1, 31, v0
	v_lshlrev_b64 v[0:1], 2, v[0:1]
	s_waitcnt lgkmcnt(0)
	v_add_co_u32 v0, vcc_lo, s0, v0
	v_add_co_ci_u32_e64 v1, null, s1, v1, vcc_lo
	global_load_dword v2, v[0:1], off
	s_waitcnt vmcnt(0)
	v_add_f32_e32 v2, v3, v2
	global_store_dword v[0:1], v2, off
.LBB13_5:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel backward_bias_conn_kernel
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 280
		.amdhsa_user_sgpr_count 6
		.amdhsa_user_sgpr_private_segment_buffer 1
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_flat_scratch_init 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_wavefront_size32 1
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_system_sgpr_private_segment_wavefront_offset 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 6
		.amdhsa_next_free_sgpr 10
		.amdhsa_reserve_vcc 1
		.amdhsa_reserve_flat_scratch 0
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 3
		.amdhsa_float_denorm_mode_16_64 3
		.amdhsa_dx10_clamp 1
		.amdhsa_ieee_mode 1
		.amdhsa_fp16_overflow 0
		.amdhsa_workgroup_processor_mode 1
		.amdhsa_memory_ordered 1
		.amdhsa_forward_progress 1
		.amdhsa_shared_vgpr_count 0
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.text
.Lfunc_end13:
	.size	backward_bias_conn_kernel, .Lfunc_end13-backward_bias_conn_kernel
                                        ; -- End function
	.set backward_bias_conn_kernel.num_vgpr, 6
	.set backward_bias_conn_kernel.num_agpr, 0
	.set backward_bias_conn_kernel.numbered_sgpr, 10
	.set backward_bias_conn_kernel.num_named_barrier, 0
	.set backward_bias_conn_kernel.private_seg_size, 0
	.set backward_bias_conn_kernel.uses_vcc, 1
	.set backward_bias_conn_kernel.uses_flat_scratch, 0
	.set backward_bias_conn_kernel.has_dyn_sized_stack, 0
	.set backward_bias_conn_kernel.has_recursion, 0
	.set backward_bias_conn_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 204
; TotalNumSgprs: 12
; NumVgprs: 6
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 0
; VGPRBlocks: 0
; NumSGPRsForWavesPerEU: 12
; NumVGPRsForWavesPerEU: 6
; Occupancy: 16
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 6
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
	.text
	.protected	backward_scale_kernel   ; -- Begin function backward_scale_kernel
	.globl	backward_scale_kernel
	.p2align	8
	.type	backward_scale_kernel,@function
backward_scale_kernel:                  ; @backward_scale_kernel
; %bb.0:
	s_load_dwordx4 s[8:11], s[4:5], 0x10
	s_waitcnt lgkmcnt(0)
	s_cmp_lt_i32 s8, 1
	s_cbranch_scc1 .LBB14_7
; %bb.1:
	s_load_dwordx4 s[12:15], s[4:5], 0x0
	v_mad_u64_u32 v[1:2], null, s6, s10, v[0:1]
	v_mov_b32_e32 v6, 0
	s_mul_i32 s2, s10, s9
	s_mov_b32 s3, 0
	v_cmp_gt_i32_e32 vcc_lo, s10, v0
	s_inst_prefetch 0x1
	s_branch .LBB14_3
	.p2align	6
.LBB14_2:                               ;   in Loop: Header=BB14_3 Depth=1
	s_or_b32 exec_lo, exec_lo, s7
	v_add_nc_u32_e32 v1, s2, v1
	s_add_i32 s3, s3, 1
	s_cmp_eq_u32 s3, s8
	s_cbranch_scc1 .LBB14_8
.LBB14_3:                               ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB14_5 Depth 2
	s_and_saveexec_b32 s7, vcc_lo
	s_cbranch_execz .LBB14_2
; %bb.4:                                ;   in Loop: Header=BB14_3 Depth=1
	v_ashrrev_i32_e32 v2, 31, v1
	v_mov_b32_e32 v7, v0
	s_mov_b32 s9, 0
	v_lshlrev_b64 v[4:5], 2, v[1:2]
	s_waitcnt lgkmcnt(0)
	v_add_co_u32 v2, s0, s14, v4
	v_add_co_ci_u32_e64 v3, null, s15, v5, s0
	v_add_co_u32 v4, s0, s12, v4
	v_add_co_ci_u32_e64 v5, null, s13, v5, s0
	.p2align	6
.LBB14_5:                               ;   Parent Loop BB14_3 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	global_load_dword v8, v[2:3], off
	global_load_dword v9, v[4:5], off
	v_add_nc_u32_e32 v7, 0x100, v7
	v_add_co_u32 v2, s0, 0x400, v2
	v_add_co_ci_u32_e64 v3, null, 0, v3, s0
	v_add_co_u32 v4, s0, 0x400, v4
	v_cmp_le_i32_e64 s1, s10, v7
	v_add_co_ci_u32_e64 v5, null, 0, v5, s0
	s_or_b32 s9, s1, s9
	s_waitcnt vmcnt(0)
	v_fmac_f32_e32 v6, v8, v9
	s_andn2_b32 exec_lo, exec_lo, s9
	s_cbranch_execnz .LBB14_5
; %bb.6:                                ;   in Loop: Header=BB14_3 Depth=1
	s_or_b32 exec_lo, exec_lo, s9
	s_branch .LBB14_2
.LBB14_7:
	v_mov_b32_e32 v6, 0
.LBB14_8:
	s_inst_prefetch 0x2
	v_lshlrev_b32_e32 v1, 2, v0
	s_mov_b32 s0, exec_lo
	ds_write_b32 v1, v6
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	v_cmpx_gt_u32_e32 0x80, v0
	s_cbranch_execz .LBB14_10
; %bb.9:
	ds_read2st64_b32 v[2:3], v1 offset1:2
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v3, v2
	ds_write_b32 v1, v2
.LBB14_10:
	s_or_b32 exec_lo, exec_lo, s0
	s_mov_b32 s0, exec_lo
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	v_cmpx_gt_u32_e32 64, v0
	s_cbranch_execz .LBB14_12
; %bb.11:
	ds_read2st64_b32 v[2:3], v1 offset1:1
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v3, v2
	ds_write_b32 v1, v2
.LBB14_12:
	s_or_b32 exec_lo, exec_lo, s0
	s_mov_b32 s0, exec_lo
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	v_cmpx_gt_u32_e32 32, v0
	s_cbranch_execz .LBB14_14
; %bb.13:
	ds_read2_b32 v[2:3], v1 offset1:32
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v3, v2
	ds_write_b32 v1, v2
.LBB14_14:
	s_or_b32 exec_lo, exec_lo, s0
	s_mov_b32 s0, exec_lo
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	v_cmpx_gt_u32_e32 16, v0
	s_cbranch_execz .LBB14_16
; %bb.15:
	ds_read2_b32 v[2:3], v1 offset1:16
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v3, v2
	ds_write_b32 v1, v2
.LBB14_16:
	s_or_b32 exec_lo, exec_lo, s0
	s_mov_b32 s0, exec_lo
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	v_cmpx_gt_u32_e32 8, v0
	s_cbranch_execz .LBB14_18
; %bb.17:
	ds_read2_b32 v[2:3], v1 offset1:8
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v3, v2
	ds_write_b32 v1, v2
.LBB14_18:
	s_or_b32 exec_lo, exec_lo, s0
	s_mov_b32 s0, exec_lo
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	v_cmpx_gt_u32_e32 4, v0
	s_cbranch_execz .LBB14_20
; %bb.19:
	ds_read2_b32 v[2:3], v1 offset1:4
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v3, v2
	ds_write_b32 v1, v2
.LBB14_20:
	s_or_b32 exec_lo, exec_lo, s0
	s_mov_b32 s0, exec_lo
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	v_cmpx_gt_u32_e32 2, v0
	s_cbranch_execz .LBB14_22
; %bb.21:
	ds_read2_b32 v[2:3], v1 offset1:2
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v3, v2
	ds_write_b32 v1, v2
.LBB14_22:
	s_or_b32 exec_lo, exec_lo, s0
	v_cmp_eq_u32_e32 vcc_lo, 0, v0
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	s_and_saveexec_b32 s0, vcc_lo
	s_cbranch_execz .LBB14_24
; %bb.23:
	v_mov_b32_e32 v0, 0
	ds_read_b32 v0, v0 offset:4
	ds_read_b32 v2, v1
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v0, v0, v2
	ds_write_b32 v1, v0
.LBB14_24:
	s_or_b32 exec_lo, exec_lo, s0
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	s_and_saveexec_b32 s0, vcc_lo
	s_cbranch_execz .LBB14_26
; %bb.25:
	s_load_dwordx2 s[0:1], s[4:5], 0x20
	s_ashr_i32 s7, s6, 31
	v_mov_b32_e32 v0, 0
	s_lshl_b64 s[2:3], s[6:7], 2
	ds_read_b32 v1, v0
	s_waitcnt lgkmcnt(0)
	s_add_u32 s0, s0, s2
	s_addc_u32 s1, s1, s3
	s_load_dword s2, s[0:1], 0x0
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v1, s2, v1
	global_store_dword v0, v1, s[0:1]
.LBB14_26:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel backward_scale_kernel
		.amdhsa_group_segment_fixed_size 1024
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 40
		.amdhsa_user_sgpr_count 6
		.amdhsa_user_sgpr_private_segment_buffer 1
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_flat_scratch_init 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_wavefront_size32 1
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_system_sgpr_private_segment_wavefront_offset 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 10
		.amdhsa_next_free_sgpr 16
		.amdhsa_reserve_vcc 1
		.amdhsa_reserve_flat_scratch 0
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 3
		.amdhsa_float_denorm_mode_16_64 3
		.amdhsa_dx10_clamp 1
		.amdhsa_ieee_mode 1
		.amdhsa_fp16_overflow 0
		.amdhsa_workgroup_processor_mode 1
		.amdhsa_memory_ordered 1
		.amdhsa_forward_progress 1
		.amdhsa_shared_vgpr_count 0
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.text
.Lfunc_end14:
	.size	backward_scale_kernel, .Lfunc_end14-backward_scale_kernel
                                        ; -- End function
	.set backward_scale_kernel.num_vgpr, 10
	.set backward_scale_kernel.num_agpr, 0
	.set backward_scale_kernel.numbered_sgpr, 16
	.set backward_scale_kernel.num_named_barrier, 0
	.set backward_scale_kernel.private_seg_size, 0
	.set backward_scale_kernel.uses_vcc, 1
	.set backward_scale_kernel.uses_flat_scratch, 0
	.set backward_scale_kernel.has_dyn_sized_stack, 0
	.set backward_scale_kernel.has_recursion, 0
	.set backward_scale_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 868
; TotalNumSgprs: 18
; NumVgprs: 10
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 1024 bytes/workgroup (compile time only)
; SGPRBlocks: 0
; VGPRBlocks: 1
; NumSGPRsForWavesPerEU: 18
; NumVGPRsForWavesPerEU: 10
; Occupancy: 16
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 6
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
	.text
	.protected	fast_mean_kernel        ; -- Begin function fast_mean_kernel
	.globl	fast_mean_kernel
	.p2align	8
	.type	fast_mean_kernel,@function
fast_mean_kernel:                       ; @fast_mean_kernel
; %bb.0:
	s_load_dwordx4 s[8:11], s[4:5], 0x8
	s_waitcnt lgkmcnt(0)
	s_cmp_lt_i32 s8, 1
	s_cbranch_scc1 .LBB15_7
; %bb.1:
	s_load_dwordx2 s[2:3], s[4:5], 0x0
	v_mov_b32_e32 v2, 0
	s_mul_i32 s1, s6, s10
	s_mul_i32 s7, s10, s9
	s_mov_b32 s9, 0
	v_cmp_gt_i32_e32 vcc_lo, s10, v0
	s_inst_prefetch 0x1
	s_branch .LBB15_3
	.p2align	6
.LBB15_2:                               ;   in Loop: Header=BB15_3 Depth=1
	s_or_b32 exec_lo, exec_lo, s11
	s_add_i32 s9, s9, 1
	s_add_i32 s1, s1, s7
	s_cmp_eq_u32 s9, s8
	s_cbranch_scc1 .LBB15_8
.LBB15_3:                               ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB15_5 Depth 2
	s_and_saveexec_b32 s11, vcc_lo
	s_cbranch_execz .LBB15_2
; %bb.4:                                ;   in Loop: Header=BB15_3 Depth=1
	v_mov_b32_e32 v1, v0
	s_mov_b32 s12, 0
	.p2align	6
.LBB15_5:                               ;   Parent Loop BB15_3 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	v_add_nc_u32_e32 v3, s1, v1
	v_add_nc_u32_e32 v1, 0x100, v1
	v_ashrrev_i32_e32 v4, 31, v3
	v_lshlrev_b64 v[3:4], 2, v[3:4]
	s_waitcnt lgkmcnt(0)
	v_add_co_u32 v3, s0, s2, v3
	v_add_co_ci_u32_e64 v4, null, s3, v4, s0
	v_cmp_le_i32_e64 s0, s10, v1
	global_load_dword v3, v[3:4], off
	s_or_b32 s12, s0, s12
	s_waitcnt vmcnt(0)
	v_add_f32_e32 v2, v2, v3
	s_andn2_b32 exec_lo, exec_lo, s12
	s_cbranch_execnz .LBB15_5
; %bb.6:                                ;   in Loop: Header=BB15_3 Depth=1
	s_or_b32 exec_lo, exec_lo, s12
	s_branch .LBB15_2
.LBB15_7:
	v_mov_b32_e32 v2, 0
.LBB15_8:
	s_inst_prefetch 0x2
	v_lshlrev_b32_e32 v1, 2, v0
	s_mov_b32 s0, exec_lo
	ds_write_b32 v1, v2
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	v_cmpx_gt_u32_e32 0x80, v0
	s_cbranch_execz .LBB15_10
; %bb.9:
	ds_read2st64_b32 v[2:3], v1 offset1:2
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v3, v2
	ds_write_b32 v1, v2
.LBB15_10:
	s_or_b32 exec_lo, exec_lo, s0
	s_mov_b32 s0, exec_lo
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	v_cmpx_gt_u32_e32 64, v0
	s_cbranch_execz .LBB15_12
; %bb.11:
	ds_read2st64_b32 v[2:3], v1 offset1:1
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v3, v2
	ds_write_b32 v1, v2
.LBB15_12:
	s_or_b32 exec_lo, exec_lo, s0
	s_mov_b32 s0, exec_lo
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	v_cmpx_gt_u32_e32 32, v0
	s_cbranch_execz .LBB15_14
; %bb.13:
	ds_read2_b32 v[2:3], v1 offset1:32
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v3, v2
	ds_write_b32 v1, v2
.LBB15_14:
	s_or_b32 exec_lo, exec_lo, s0
	s_mov_b32 s0, exec_lo
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	v_cmpx_gt_u32_e32 16, v0
	s_cbranch_execz .LBB15_16
; %bb.15:
	ds_read2_b32 v[2:3], v1 offset1:16
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v3, v2
	ds_write_b32 v1, v2
.LBB15_16:
	s_or_b32 exec_lo, exec_lo, s0
	s_mov_b32 s0, exec_lo
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	v_cmpx_gt_u32_e32 8, v0
	s_cbranch_execz .LBB15_18
; %bb.17:
	ds_read2_b32 v[2:3], v1 offset1:8
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v3, v2
	ds_write_b32 v1, v2
.LBB15_18:
	s_or_b32 exec_lo, exec_lo, s0
	s_mov_b32 s0, exec_lo
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	v_cmpx_gt_u32_e32 4, v0
	s_cbranch_execz .LBB15_20
; %bb.19:
	ds_read2_b32 v[2:3], v1 offset1:4
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v3, v2
	ds_write_b32 v1, v2
.LBB15_20:
	s_or_b32 exec_lo, exec_lo, s0
	s_mov_b32 s0, exec_lo
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	v_cmpx_gt_u32_e32 2, v0
	s_cbranch_execz .LBB15_22
; %bb.21:
	ds_read2_b32 v[2:3], v1 offset1:2
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v3, v2
	ds_write_b32 v1, v2
.LBB15_22:
	s_or_b32 exec_lo, exec_lo, s0
	v_cmp_eq_u32_e32 vcc_lo, 0, v0
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	s_and_saveexec_b32 s0, vcc_lo
	s_cbranch_execz .LBB15_24
; %bb.23:
	v_mov_b32_e32 v0, 0
	ds_read_b32 v0, v0 offset:4
	ds_read_b32 v2, v1
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v0, v0, v2
	ds_write_b32 v1, v0
.LBB15_24:
	s_or_b32 exec_lo, exec_lo, s0
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	s_and_saveexec_b32 s0, vcc_lo
	s_cbranch_execz .LBB15_26
; %bb.25:
	v_mov_b32_e32 v0, 0
	s_mul_i32 s0, s10, s8
	s_ashr_i32 s7, s6, 31
	v_cvt_f32_i32_e32 v2, s0
	s_load_dwordx2 s[0:1], s[4:5], 0x18
	ds_read_b32 v1, v0
	s_lshl_b64 s[2:3], s[6:7], 2
	s_waitcnt lgkmcnt(0)
	s_add_u32 s0, s0, s2
	v_div_scale_f32 v3, null, v2, v2, v1
	v_div_scale_f32 v6, vcc_lo, v1, v2, v1
	s_addc_u32 s1, s1, s3
	v_rcp_f32_e32 v4, v3
	v_fma_f32 v5, -v3, v4, 1.0
	v_fmac_f32_e32 v4, v5, v4
	v_mul_f32_e32 v5, v6, v4
	v_fma_f32 v7, -v3, v5, v6
	v_fmac_f32_e32 v5, v7, v4
	v_fma_f32 v3, -v3, v5, v6
	v_div_fmas_f32 v3, v3, v4, v5
	v_div_fixup_f32 v1, v3, v2, v1
	global_store_dword v0, v1, s[0:1]
.LBB15_26:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel fast_mean_kernel
		.amdhsa_group_segment_fixed_size 1024
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 32
		.amdhsa_user_sgpr_count 6
		.amdhsa_user_sgpr_private_segment_buffer 1
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_flat_scratch_init 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_wavefront_size32 1
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_system_sgpr_private_segment_wavefront_offset 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 8
		.amdhsa_next_free_sgpr 13
		.amdhsa_reserve_vcc 1
		.amdhsa_reserve_flat_scratch 0
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 3
		.amdhsa_float_denorm_mode_16_64 3
		.amdhsa_dx10_clamp 1
		.amdhsa_ieee_mode 1
		.amdhsa_fp16_overflow 0
		.amdhsa_workgroup_processor_mode 1
		.amdhsa_memory_ordered 1
		.amdhsa_forward_progress 1
		.amdhsa_shared_vgpr_count 0
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.text
.Lfunc_end15:
	.size	fast_mean_kernel, .Lfunc_end15-fast_mean_kernel
                                        ; -- End function
	.set fast_mean_kernel.num_vgpr, 8
	.set fast_mean_kernel.num_agpr, 0
	.set fast_mean_kernel.numbered_sgpr, 13
	.set fast_mean_kernel.num_named_barrier, 0
	.set fast_mean_kernel.private_seg_size, 0
	.set fast_mean_kernel.uses_vcc, 1
	.set fast_mean_kernel.uses_flat_scratch, 0
	.set fast_mean_kernel.has_dyn_sized_stack, 0
	.set fast_mean_kernel.has_recursion, 0
	.set fast_mean_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 856
; TotalNumSgprs: 15
; NumVgprs: 8
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 1024 bytes/workgroup (compile time only)
; SGPRBlocks: 0
; VGPRBlocks: 0
; NumSGPRsForWavesPerEU: 15
; NumVGPRsForWavesPerEU: 8
; Occupancy: 16
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 6
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
	.text
	.protected	fast_variance_kernel    ; -- Begin function fast_variance_kernel
	.globl	fast_variance_kernel
	.p2align	8
	.type	fast_variance_kernel,@function
fast_variance_kernel:                   ; @fast_variance_kernel
; %bb.0:
	s_load_dwordx4 s[8:11], s[4:5], 0x10
	s_ashr_i32 s7, s6, 31
	s_waitcnt lgkmcnt(0)
	s_cmp_lt_i32 s8, 1
	s_cbranch_scc1 .LBB16_7
; %bb.1:
	s_load_dwordx4 s[12:15], s[4:5], 0x0
	s_lshl_b64 s[0:1], s[6:7], 2
	v_mov_b32_e32 v2, 0
	s_mul_i32 s2, s6, s10
	s_mul_i32 s3, s10, s9
	s_mov_b32 s9, 0
	v_cmp_gt_i32_e32 vcc_lo, s10, v0
	s_waitcnt lgkmcnt(0)
	s_add_u32 s0, s14, s0
	s_addc_u32 s1, s15, s1
	s_load_dword s1, s[0:1], 0x0
	s_inst_prefetch 0x1
	s_branch .LBB16_3
	.p2align	6
.LBB16_2:                               ;   in Loop: Header=BB16_3 Depth=1
	s_or_b32 exec_lo, exec_lo, s11
	s_add_i32 s9, s9, 1
	s_add_i32 s2, s2, s3
	s_cmp_eq_u32 s9, s8
	s_cbranch_scc1 .LBB16_8
.LBB16_3:                               ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB16_5 Depth 2
	s_and_saveexec_b32 s11, vcc_lo
	s_cbranch_execz .LBB16_2
; %bb.4:                                ;   in Loop: Header=BB16_3 Depth=1
	v_mov_b32_e32 v1, v0
	s_mov_b32 s14, 0
	.p2align	6
.LBB16_5:                               ;   Parent Loop BB16_3 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	v_add_nc_u32_e32 v3, s2, v1
	v_add_nc_u32_e32 v1, 0x100, v1
	v_ashrrev_i32_e32 v4, 31, v3
	v_lshlrev_b64 v[3:4], 2, v[3:4]
	v_add_co_u32 v3, s0, s12, v3
	v_add_co_ci_u32_e64 v4, null, s13, v4, s0
	v_cmp_le_i32_e64 s0, s10, v1
	global_load_dword v3, v[3:4], off
	s_or_b32 s14, s0, s14
	s_waitcnt vmcnt(0) lgkmcnt(0)
	v_subrev_f32_e32 v3, s1, v3
	v_fmac_f32_e32 v2, v3, v3
	s_andn2_b32 exec_lo, exec_lo, s14
	s_cbranch_execnz .LBB16_5
; %bb.6:                                ;   in Loop: Header=BB16_3 Depth=1
	s_or_b32 exec_lo, exec_lo, s14
	s_branch .LBB16_2
.LBB16_7:
	v_mov_b32_e32 v2, 0
.LBB16_8:
	s_inst_prefetch 0x2
	v_lshlrev_b32_e32 v1, 2, v0
	s_mov_b32 s0, exec_lo
	ds_write_b32 v1, v2
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	v_cmpx_gt_u32_e32 0x80, v0
	s_cbranch_execz .LBB16_10
; %bb.9:
	ds_read2st64_b32 v[2:3], v1 offset1:2
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v3, v2
	ds_write_b32 v1, v2
.LBB16_10:
	s_or_b32 exec_lo, exec_lo, s0
	s_mov_b32 s0, exec_lo
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	v_cmpx_gt_u32_e32 64, v0
	s_cbranch_execz .LBB16_12
; %bb.11:
	ds_read2st64_b32 v[2:3], v1 offset1:1
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v3, v2
	ds_write_b32 v1, v2
.LBB16_12:
	s_or_b32 exec_lo, exec_lo, s0
	s_mov_b32 s0, exec_lo
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	v_cmpx_gt_u32_e32 32, v0
	s_cbranch_execz .LBB16_14
; %bb.13:
	ds_read2_b32 v[2:3], v1 offset1:32
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v3, v2
	ds_write_b32 v1, v2
.LBB16_14:
	s_or_b32 exec_lo, exec_lo, s0
	s_mov_b32 s0, exec_lo
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	v_cmpx_gt_u32_e32 16, v0
	s_cbranch_execz .LBB16_16
; %bb.15:
	ds_read2_b32 v[2:3], v1 offset1:16
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v3, v2
	ds_write_b32 v1, v2
.LBB16_16:
	s_or_b32 exec_lo, exec_lo, s0
	s_mov_b32 s0, exec_lo
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	v_cmpx_gt_u32_e32 8, v0
	s_cbranch_execz .LBB16_18
; %bb.17:
	ds_read2_b32 v[2:3], v1 offset1:8
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v3, v2
	ds_write_b32 v1, v2
.LBB16_18:
	s_or_b32 exec_lo, exec_lo, s0
	s_mov_b32 s0, exec_lo
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	v_cmpx_gt_u32_e32 4, v0
	s_cbranch_execz .LBB16_20
; %bb.19:
	ds_read2_b32 v[2:3], v1 offset1:4
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v3, v2
	ds_write_b32 v1, v2
.LBB16_20:
	s_or_b32 exec_lo, exec_lo, s0
	s_mov_b32 s0, exec_lo
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	v_cmpx_gt_u32_e32 2, v0
	s_cbranch_execz .LBB16_22
; %bb.21:
	ds_read2_b32 v[2:3], v1 offset1:2
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v3, v2
	ds_write_b32 v1, v2
.LBB16_22:
	s_or_b32 exec_lo, exec_lo, s0
	v_cmp_eq_u32_e32 vcc_lo, 0, v0
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	s_and_saveexec_b32 s0, vcc_lo
	s_cbranch_execz .LBB16_24
; %bb.23:
	v_mov_b32_e32 v0, 0
	ds_read_b32 v0, v0 offset:4
	ds_read_b32 v2, v1
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v0, v0, v2
	ds_write_b32 v1, v0
.LBB16_24:
	s_or_b32 exec_lo, exec_lo, s0
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	s_and_saveexec_b32 s0, vcc_lo
	s_cbranch_execz .LBB16_26
; %bb.25:
	v_mov_b32_e32 v0, 0
	s_mul_i32 s0, s10, s8
	s_lshl_b64 s[2:3], s[6:7], 2
	s_add_i32 s0, s0, -1
	v_cvt_f32_i32_e32 v2, s0
	ds_read_b32 v1, v0
	s_load_dwordx2 s[0:1], s[4:5], 0x20
	s_waitcnt lgkmcnt(0)
	v_div_scale_f32 v3, null, v2, v2, v1
	v_div_scale_f32 v6, vcc_lo, v1, v2, v1
	s_add_u32 s0, s0, s2
	v_rcp_f32_e32 v4, v3
	s_addc_u32 s1, s1, s3
	v_fma_f32 v5, -v3, v4, 1.0
	v_fmac_f32_e32 v4, v5, v4
	v_mul_f32_e32 v5, v6, v4
	v_fma_f32 v7, -v3, v5, v6
	v_fmac_f32_e32 v5, v7, v4
	v_fma_f32 v3, -v3, v5, v6
	v_div_fmas_f32 v3, v3, v4, v5
	v_div_fixup_f32 v1, v3, v2, v1
	global_store_dword v0, v1, s[0:1]
.LBB16_26:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel fast_variance_kernel
		.amdhsa_group_segment_fixed_size 1024
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 40
		.amdhsa_user_sgpr_count 6
		.amdhsa_user_sgpr_private_segment_buffer 1
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_flat_scratch_init 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_wavefront_size32 1
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_system_sgpr_private_segment_wavefront_offset 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 8
		.amdhsa_next_free_sgpr 16
		.amdhsa_reserve_vcc 1
		.amdhsa_reserve_flat_scratch 0
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 3
		.amdhsa_float_denorm_mode_16_64 3
		.amdhsa_dx10_clamp 1
		.amdhsa_ieee_mode 1
		.amdhsa_fp16_overflow 0
		.amdhsa_workgroup_processor_mode 1
		.amdhsa_memory_ordered 1
		.amdhsa_forward_progress 1
		.amdhsa_shared_vgpr_count 0
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.text
.Lfunc_end16:
	.size	fast_variance_kernel, .Lfunc_end16-fast_variance_kernel
                                        ; -- End function
	.set fast_variance_kernel.num_vgpr, 8
	.set fast_variance_kernel.num_agpr, 0
	.set fast_variance_kernel.numbered_sgpr, 16
	.set fast_variance_kernel.num_named_barrier, 0
	.set fast_variance_kernel.private_seg_size, 0
	.set fast_variance_kernel.uses_vcc, 1
	.set fast_variance_kernel.uses_flat_scratch, 0
	.set fast_variance_kernel.has_dyn_sized_stack, 0
	.set fast_variance_kernel.has_recursion, 0
	.set fast_variance_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 920
; TotalNumSgprs: 18
; NumVgprs: 8
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 1024 bytes/workgroup (compile time only)
; SGPRBlocks: 0
; VGPRBlocks: 0
; NumSGPRsForWavesPerEU: 18
; NumVGPRsForWavesPerEU: 8
; Occupancy: 16
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 6
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
	.text
	.protected	normalize_kernel        ; -- Begin function normalize_kernel
	.globl	normalize_kernel
	.p2align	8
	.type	normalize_kernel,@function
normalize_kernel:                       ; @normalize_kernel
; %bb.0:
	s_clause 0x1
	s_load_dword s0, s[4:5], 0x3c
	s_load_dword s1, s[4:5], 0x0
	s_waitcnt lgkmcnt(0)
	s_and_b32 s0, s0, 0xffff
	v_mad_u64_u32 v[0:1], null, s6, s0, v[0:1]
	s_mov_b32 s0, exec_lo
	v_cmpx_gt_i32_e64 s1, v0
	s_cbranch_execz .LBB17_2
; %bb.1:
	s_load_dwordx2 s[0:1], s[4:5], 0x24
	v_sub_nc_u32_e32 v3, 0, v0
	v_max_i32_e32 v3, v0, v3
	s_waitcnt lgkmcnt(0)
	s_abs_i32 s2, s1
	s_abs_i32 s0, s0
	v_cvt_f32_u32_e32 v1, s2
	s_sub_i32 s3, 0, s2
	v_cvt_f32_u32_e32 v4, s0
	v_rcp_iflag_f32_e32 v1, v1
	v_rcp_iflag_f32_e32 v4, v4
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_mul_f32_e32 v4, 0x4f7ffffe, v4
	v_cvt_u32_f32_e32 v1, v1
	v_cvt_u32_f32_e32 v4, v4
	v_mul_lo_u32 v2, s3, v1
	v_mul_hi_u32 v2, v1, v2
	v_add_nc_u32_e32 v1, v1, v2
	v_mul_hi_u32 v1, v3, v1
	v_mul_lo_u32 v2, v1, s2
	v_sub_nc_u32_e32 v2, v3, v2
	v_add_nc_u32_e32 v3, 1, v1
	v_subrev_nc_u32_e32 v5, s2, v2
	v_cmp_le_u32_e32 vcc_lo, s2, v2
	v_cndmask_b32_e32 v1, v1, v3, vcc_lo
	v_cndmask_b32_e32 v2, v2, v5, vcc_lo
	v_xor_b32_e32 v3, s1, v0
	s_sub_i32 s1, 0, s0
	v_add_nc_u32_e32 v5, 1, v1
	v_cmp_le_u32_e32 vcc_lo, s2, v2
	v_ashrrev_i32_e32 v3, 31, v3
	v_mul_lo_u32 v2, s1, v4
	v_cndmask_b32_e32 v1, v1, v5, vcc_lo
	v_mul_hi_u32 v2, v4, v2
	v_xor_b32_e32 v1, v1, v3
	v_sub_nc_u32_e32 v1, v1, v3
	v_add_nc_u32_e32 v2, v4, v2
	v_sub_nc_u32_e32 v3, 0, v1
	v_max_i32_e32 v3, v1, v3
	v_ashrrev_i32_e32 v1, 31, v1
	v_mul_hi_u32 v2, v3, v2
	v_mul_lo_u32 v2, v2, s0
	v_sub_nc_u32_e32 v2, v3, v2
	v_subrev_nc_u32_e32 v3, s0, v2
	v_cmp_le_u32_e32 vcc_lo, s0, v2
	v_cndmask_b32_e32 v2, v2, v3, vcc_lo
	v_subrev_nc_u32_e32 v3, s0, v2
	v_cmp_le_u32_e32 vcc_lo, s0, v2
	s_load_dwordx2 s[0:1], s[4:5], 0x18
	v_cndmask_b32_e32 v2, v2, v3, vcc_lo
	v_xor_b32_e32 v2, v2, v1
	v_sub_nc_u32_e32 v1, v2, v1
	v_ashrrev_i32_e32 v2, 31, v1
	v_lshlrev_b64 v[2:3], 2, v[1:2]
	v_ashrrev_i32_e32 v1, 31, v0
	s_waitcnt lgkmcnt(0)
	v_add_co_u32 v4, vcc_lo, s0, v2
	v_add_co_ci_u32_e64 v5, null, s1, v3, vcc_lo
	s_load_dwordx4 s[0:3], s[4:5], 0x8
	v_lshlrev_b64 v[0:1], 2, v[0:1]
	global_load_dword v4, v[4:5], off
	s_waitcnt lgkmcnt(0)
	v_add_co_u32 v0, vcc_lo, s0, v0
	v_add_co_ci_u32_e64 v1, null, s1, v1, vcc_lo
	v_add_co_u32 v2, vcc_lo, s2, v2
	v_add_co_ci_u32_e64 v3, null, s3, v3, vcc_lo
	global_load_dword v5, v[0:1], off
	global_load_dword v2, v[2:3], off
	s_waitcnt vmcnt(2)
	v_mul_f32_e32 v3, 0x4f800000, v4
	v_cmp_gt_f32_e32 vcc_lo, 0xf800000, v4
	v_cndmask_b32_e32 v3, v4, v3, vcc_lo
	v_sqrt_f32_e32 v4, v3
	v_add_nc_u32_e32 v6, -1, v4
	v_add_nc_u32_e32 v7, 1, v4
	v_fma_f32 v8, -v6, v4, v3
	v_fma_f32 v9, -v7, v4, v3
	s_waitcnt vmcnt(0)
	v_sub_f32_e32 v2, v5, v2
	v_cmp_ge_f32_e64 s0, 0, v8
	v_cndmask_b32_e64 v4, v4, v6, s0
	v_cmp_lt_f32_e64 s0, 0, v9
	v_cndmask_b32_e64 v4, v4, v7, s0
	v_mul_f32_e32 v6, 0x37800000, v4
	v_cndmask_b32_e32 v4, v4, v6, vcc_lo
	v_cmp_class_f32_e64 vcc_lo, v3, 0x260
	v_cndmask_b32_e32 v3, v4, v3, vcc_lo
	v_add_f32_e32 v3, 0x358637bd, v3
	v_div_scale_f32 v4, null, v3, v3, v2
	v_rcp_f32_e32 v5, v4
	v_fma_f32 v6, -v4, v5, 1.0
	v_fmac_f32_e32 v5, v6, v5
	v_div_scale_f32 v6, vcc_lo, v2, v3, v2
	v_mul_f32_e32 v7, v6, v5
	v_fma_f32 v8, -v4, v7, v6
	v_fmac_f32_e32 v7, v8, v5
	v_fma_f32 v4, -v4, v7, v6
	v_div_fmas_f32 v4, v4, v5, v7
	v_div_fixup_f32 v2, v4, v3, v2
	global_store_dword v[0:1], v2, off
.LBB17_2:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel normalize_kernel
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 304
		.amdhsa_user_sgpr_count 6
		.amdhsa_user_sgpr_private_segment_buffer 1
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_flat_scratch_init 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_wavefront_size32 1
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_system_sgpr_private_segment_wavefront_offset 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 10
		.amdhsa_next_free_sgpr 7
		.amdhsa_reserve_vcc 1
		.amdhsa_reserve_flat_scratch 0
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 3
		.amdhsa_float_denorm_mode_16_64 3
		.amdhsa_dx10_clamp 1
		.amdhsa_ieee_mode 1
		.amdhsa_fp16_overflow 0
		.amdhsa_workgroup_processor_mode 1
		.amdhsa_memory_ordered 1
		.amdhsa_forward_progress 1
		.amdhsa_shared_vgpr_count 0
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.text
.Lfunc_end17:
	.size	normalize_kernel, .Lfunc_end17-normalize_kernel
                                        ; -- End function
	.set normalize_kernel.num_vgpr, 10
	.set normalize_kernel.num_agpr, 0
	.set normalize_kernel.numbered_sgpr, 7
	.set normalize_kernel.num_named_barrier, 0
	.set normalize_kernel.private_seg_size, 0
	.set normalize_kernel.uses_vcc, 1
	.set normalize_kernel.uses_flat_scratch, 0
	.set normalize_kernel.has_dyn_sized_stack, 0
	.set normalize_kernel.has_recursion, 0
	.set normalize_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 636
; TotalNumSgprs: 9
; NumVgprs: 10
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 0
; VGPRBlocks: 1
; NumSGPRsForWavesPerEU: 9
; NumVGPRsForWavesPerEU: 10
; Occupancy: 16
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 6
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
	.text
	.protected	fast_mean_delta_kernel  ; -- Begin function fast_mean_delta_kernel
	.globl	fast_mean_delta_kernel
	.p2align	8
	.type	fast_mean_delta_kernel,@function
fast_mean_delta_kernel:                 ; @fast_mean_delta_kernel
; %bb.0:
	s_load_dwordx8 s[8:15], s[4:5], 0x0
	s_waitcnt lgkmcnt(0)
	s_cmp_lt_i32 s12, 1
	s_cbranch_scc1 .LBB18_7
; %bb.1:
	v_mov_b32_e32 v2, 0
	s_mul_i32 s1, s6, s14
	s_mul_i32 s2, s14, s13
	s_mov_b32 s3, 0
	v_cmp_gt_i32_e32 vcc_lo, s14, v0
	s_inst_prefetch 0x1
	s_branch .LBB18_3
	.p2align	6
.LBB18_2:                               ;   in Loop: Header=BB18_3 Depth=1
	s_or_b32 exec_lo, exec_lo, s7
	s_add_i32 s3, s3, 1
	s_add_i32 s1, s1, s2
	s_cmp_eq_u32 s3, s12
	s_cbranch_scc1 .LBB18_8
.LBB18_3:                               ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB18_5 Depth 2
	s_and_saveexec_b32 s7, vcc_lo
	s_cbranch_execz .LBB18_2
; %bb.4:                                ;   in Loop: Header=BB18_3 Depth=1
	v_mov_b32_e32 v1, v0
	s_mov_b32 s13, 0
	.p2align	6
.LBB18_5:                               ;   Parent Loop BB18_3 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	v_add_nc_u32_e32 v3, s1, v1
	v_add_nc_u32_e32 v1, 0x100, v1
	v_ashrrev_i32_e32 v4, 31, v3
	v_lshlrev_b64 v[3:4], 2, v[3:4]
	v_add_co_u32 v3, s0, s8, v3
	v_add_co_ci_u32_e64 v4, null, s9, v4, s0
	v_cmp_le_i32_e64 s0, s14, v1
	global_load_dword v3, v[3:4], off
	s_or_b32 s13, s0, s13
	s_waitcnt vmcnt(0)
	v_add_f32_e32 v2, v2, v3
	s_andn2_b32 exec_lo, exec_lo, s13
	s_cbranch_execnz .LBB18_5
; %bb.6:                                ;   in Loop: Header=BB18_3 Depth=1
	s_or_b32 exec_lo, exec_lo, s13
	s_branch .LBB18_2
.LBB18_7:
	v_mov_b32_e32 v2, 0
.LBB18_8:
	s_inst_prefetch 0x2
	v_lshlrev_b32_e32 v1, 2, v0
	s_mov_b32 s0, exec_lo
	ds_write_b32 v1, v2
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	v_cmpx_gt_u32_e32 0x80, v0
	s_cbranch_execz .LBB18_10
; %bb.9:
	ds_read2st64_b32 v[2:3], v1 offset1:2
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v3, v2
	ds_write_b32 v1, v2
.LBB18_10:
	s_or_b32 exec_lo, exec_lo, s0
	s_mov_b32 s0, exec_lo
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	v_cmpx_gt_u32_e32 64, v0
	s_cbranch_execz .LBB18_12
; %bb.11:
	ds_read2st64_b32 v[2:3], v1 offset1:1
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v3, v2
	ds_write_b32 v1, v2
.LBB18_12:
	s_or_b32 exec_lo, exec_lo, s0
	s_mov_b32 s0, exec_lo
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	v_cmpx_gt_u32_e32 32, v0
	s_cbranch_execz .LBB18_14
; %bb.13:
	ds_read2_b32 v[2:3], v1 offset1:32
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v3, v2
	ds_write_b32 v1, v2
.LBB18_14:
	s_or_b32 exec_lo, exec_lo, s0
	s_mov_b32 s0, exec_lo
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	v_cmpx_gt_u32_e32 16, v0
	s_cbranch_execz .LBB18_16
; %bb.15:
	ds_read2_b32 v[2:3], v1 offset1:16
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v3, v2
	ds_write_b32 v1, v2
.LBB18_16:
	s_or_b32 exec_lo, exec_lo, s0
	s_mov_b32 s0, exec_lo
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	v_cmpx_gt_u32_e32 8, v0
	s_cbranch_execz .LBB18_18
; %bb.17:
	ds_read2_b32 v[2:3], v1 offset1:8
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v3, v2
	ds_write_b32 v1, v2
.LBB18_18:
	s_or_b32 exec_lo, exec_lo, s0
	s_mov_b32 s0, exec_lo
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	v_cmpx_gt_u32_e32 4, v0
	s_cbranch_execz .LBB18_20
; %bb.19:
	ds_read2_b32 v[2:3], v1 offset1:4
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v3, v2
	ds_write_b32 v1, v2
.LBB18_20:
	s_or_b32 exec_lo, exec_lo, s0
	s_mov_b32 s0, exec_lo
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	v_cmpx_gt_u32_e32 2, v0
	s_cbranch_execz .LBB18_22
; %bb.21:
	ds_read2_b32 v[2:3], v1 offset1:2
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v3, v2
	ds_write_b32 v1, v2
.LBB18_22:
	s_or_b32 exec_lo, exec_lo, s0
	v_cmp_eq_u32_e32 vcc_lo, 0, v0
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	s_and_saveexec_b32 s0, vcc_lo
	s_cbranch_execz .LBB18_24
; %bb.23:
	v_mov_b32_e32 v0, 0
	ds_read_b32 v0, v0 offset:4
	ds_read_b32 v2, v1
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v0, v0, v2
	ds_write_b32 v1, v0
.LBB18_24:
	s_or_b32 exec_lo, exec_lo, s0
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	s_and_saveexec_b32 s0, vcc_lo
	s_cbranch_execz .LBB18_26
; %bb.25:
	s_ashr_i32 s7, s6, 31
	s_lshl_b64 s[2:3], s[6:7], 2
	s_add_u32 s0, s10, s2
	s_addc_u32 s1, s11, s3
	s_load_dword s0, s[0:1], 0x0
	s_waitcnt lgkmcnt(0)
	v_add_f32_e64 v0, 0x3727c5ac, s0
	v_mul_f32_e32 v1, 0x4f800000, v0
	v_cmp_gt_f32_e32 vcc_lo, 0xf800000, v0
	v_cndmask_b32_e32 v0, v0, v1, vcc_lo
	v_sqrt_f32_e32 v1, v0
	v_add_nc_u32_e32 v2, -1, v1
	v_add_nc_u32_e32 v3, 1, v1
	v_fma_f32 v4, -v2, v1, v0
	v_fma_f32 v5, -v3, v1, v0
	v_cmp_ge_f32_e64 s0, 0, v4
	v_cndmask_b32_e64 v1, v1, v2, s0
	v_cmp_lt_f32_e64 s0, 0, v5
	v_mov_b32_e32 v5, 0
	v_cndmask_b32_e64 v1, v1, v3, s0
	ds_read_b32 v7, v5
	s_load_dwordx2 s[0:1], s[4:5], 0x20
	v_mul_f32_e32 v2, 0x37800000, v1
	v_cndmask_b32_e32 v1, v1, v2, vcc_lo
	v_cmp_class_f32_e64 vcc_lo, v0, 0x260
	v_cndmask_b32_e32 v0, v1, v0, vcc_lo
	v_div_scale_f32 v1, null, v0, v0, -1.0
	s_waitcnt lgkmcnt(0)
	s_add_u32 s0, s0, s2
	s_addc_u32 s1, s1, s3
	v_rcp_f32_e32 v2, v1
	v_fma_f32 v3, -v1, v2, 1.0
	v_fmac_f32_e32 v2, v3, v2
	v_div_scale_f32 v3, vcc_lo, -1.0, v0, -1.0
	v_mul_f32_e32 v4, v3, v2
	v_fma_f32 v6, -v1, v4, v3
	v_fmac_f32_e32 v4, v6, v2
	v_fma_f32 v1, -v1, v4, v3
	v_div_fmas_f32 v1, v1, v2, v4
	v_div_fixup_f32 v0, v1, v0, -1.0
	v_mul_f32_e32 v0, v7, v0
	global_store_dword v5, v0, s[0:1]
.LBB18_26:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel fast_mean_delta_kernel
		.amdhsa_group_segment_fixed_size 1024
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 40
		.amdhsa_user_sgpr_count 6
		.amdhsa_user_sgpr_private_segment_buffer 1
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_flat_scratch_init 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_wavefront_size32 1
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_system_sgpr_private_segment_wavefront_offset 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 8
		.amdhsa_next_free_sgpr 16
		.amdhsa_reserve_vcc 1
		.amdhsa_reserve_flat_scratch 0
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 3
		.amdhsa_float_denorm_mode_16_64 3
		.amdhsa_dx10_clamp 1
		.amdhsa_ieee_mode 1
		.amdhsa_fp16_overflow 0
		.amdhsa_workgroup_processor_mode 1
		.amdhsa_memory_ordered 1
		.amdhsa_forward_progress 1
		.amdhsa_shared_vgpr_count 0
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.text
.Lfunc_end18:
	.size	fast_mean_delta_kernel, .Lfunc_end18-fast_mean_delta_kernel
                                        ; -- End function
	.set fast_mean_delta_kernel.num_vgpr, 8
	.set fast_mean_delta_kernel.num_agpr, 0
	.set fast_mean_delta_kernel.numbered_sgpr, 16
	.set fast_mean_delta_kernel.num_named_barrier, 0
	.set fast_mean_delta_kernel.private_seg_size, 0
	.set fast_mean_delta_kernel.uses_vcc, 1
	.set fast_mean_delta_kernel.uses_flat_scratch, 0
	.set fast_mean_delta_kernel.has_dyn_sized_stack, 0
	.set fast_mean_delta_kernel.has_recursion, 0
	.set fast_mean_delta_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 988
; TotalNumSgprs: 18
; NumVgprs: 8
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 1024 bytes/workgroup (compile time only)
; SGPRBlocks: 0
; VGPRBlocks: 0
; NumSGPRsForWavesPerEU: 18
; NumVGPRsForWavesPerEU: 8
; Occupancy: 16
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 6
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
	.text
	.protected	fast_variance_delta_kernel ; -- Begin function fast_variance_delta_kernel
	.globl	fast_variance_delta_kernel
	.p2align	8
	.type	fast_variance_delta_kernel,@function
fast_variance_delta_kernel:             ; @fast_variance_delta_kernel
; %bb.0:
	s_clause 0x1
	s_load_dwordx4 s[16:19], s[4:5], 0x20
	s_load_dwordx8 s[8:15], s[4:5], 0x0
	s_ashr_i32 s7, s6, 31
	s_waitcnt lgkmcnt(0)
	s_cmp_lt_i32 s16, 1
	s_cbranch_scc1 .LBB19_7
; %bb.1:
	s_lshl_b64 s[0:1], s[6:7], 2
	v_mov_b32_e32 v2, 0
	s_add_u32 s0, s12, s0
	s_addc_u32 s1, s13, s1
	s_mul_i32 s2, s6, s18
	s_load_dword s1, s[0:1], 0x0
	s_mul_i32 s3, s18, s17
	s_mov_b32 s12, 0
	v_cmp_gt_i32_e32 vcc_lo, s18, v0
	s_inst_prefetch 0x1
	s_branch .LBB19_3
	.p2align	6
.LBB19_2:                               ;   in Loop: Header=BB19_3 Depth=1
	s_or_b32 exec_lo, exec_lo, s13
	s_add_i32 s12, s12, 1
	s_add_i32 s2, s2, s3
	s_cmp_eq_u32 s12, s16
	s_cbranch_scc1 .LBB19_8
.LBB19_3:                               ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB19_5 Depth 2
	s_and_saveexec_b32 s13, vcc_lo
	s_cbranch_execz .LBB19_2
; %bb.4:                                ;   in Loop: Header=BB19_3 Depth=1
	v_mov_b32_e32 v1, v0
	s_mov_b32 s17, 0
	.p2align	6
.LBB19_5:                               ;   Parent Loop BB19_3 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	v_add_nc_u32_e32 v3, s2, v1
	v_add_nc_u32_e32 v1, 0x100, v1
	v_ashrrev_i32_e32 v4, 31, v3
	v_lshlrev_b64 v[3:4], 2, v[3:4]
	v_add_co_u32 v5, s0, s8, v3
	v_add_co_ci_u32_e64 v6, null, s9, v4, s0
	v_add_co_u32 v3, s0, s10, v3
	v_add_co_ci_u32_e64 v4, null, s11, v4, s0
	global_load_dword v5, v[5:6], off
	global_load_dword v3, v[3:4], off
	v_cmp_le_i32_e64 s0, s18, v1
	s_or_b32 s17, s0, s17
	s_waitcnt vmcnt(1) lgkmcnt(0)
	v_subrev_f32_e32 v4, s1, v5
	s_waitcnt vmcnt(0)
	v_fmac_f32_e32 v2, v3, v4
	s_andn2_b32 exec_lo, exec_lo, s17
	s_cbranch_execnz .LBB19_5
; %bb.6:                                ;   in Loop: Header=BB19_3 Depth=1
	s_or_b32 exec_lo, exec_lo, s17
	s_branch .LBB19_2
.LBB19_7:
	v_mov_b32_e32 v2, 0
.LBB19_8:
	s_inst_prefetch 0x2
	v_lshlrev_b32_e32 v1, 2, v0
	s_mov_b32 s0, exec_lo
	ds_write_b32 v1, v2
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	v_cmpx_gt_u32_e32 0x80, v0
	s_cbranch_execz .LBB19_10
; %bb.9:
	ds_read2st64_b32 v[2:3], v1 offset1:2
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v3, v2
	ds_write_b32 v1, v2
.LBB19_10:
	s_or_b32 exec_lo, exec_lo, s0
	s_mov_b32 s0, exec_lo
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	v_cmpx_gt_u32_e32 64, v0
	s_cbranch_execz .LBB19_12
; %bb.11:
	ds_read2st64_b32 v[2:3], v1 offset1:1
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v3, v2
	ds_write_b32 v1, v2
.LBB19_12:
	s_or_b32 exec_lo, exec_lo, s0
	s_mov_b32 s0, exec_lo
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	v_cmpx_gt_u32_e32 32, v0
	s_cbranch_execz .LBB19_14
; %bb.13:
	ds_read2_b32 v[2:3], v1 offset1:32
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v3, v2
	ds_write_b32 v1, v2
.LBB19_14:
	s_or_b32 exec_lo, exec_lo, s0
	s_mov_b32 s0, exec_lo
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	v_cmpx_gt_u32_e32 16, v0
	s_cbranch_execz .LBB19_16
; %bb.15:
	ds_read2_b32 v[2:3], v1 offset1:16
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v3, v2
	ds_write_b32 v1, v2
.LBB19_16:
	s_or_b32 exec_lo, exec_lo, s0
	s_mov_b32 s0, exec_lo
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	v_cmpx_gt_u32_e32 8, v0
	s_cbranch_execz .LBB19_18
; %bb.17:
	ds_read2_b32 v[2:3], v1 offset1:8
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v3, v2
	ds_write_b32 v1, v2
.LBB19_18:
	s_or_b32 exec_lo, exec_lo, s0
	s_mov_b32 s0, exec_lo
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	v_cmpx_gt_u32_e32 4, v0
	s_cbranch_execz .LBB19_20
; %bb.19:
	ds_read2_b32 v[2:3], v1 offset1:4
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v3, v2
	ds_write_b32 v1, v2
.LBB19_20:
	s_or_b32 exec_lo, exec_lo, s0
	s_mov_b32 s0, exec_lo
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	v_cmpx_gt_u32_e32 2, v0
	s_cbranch_execz .LBB19_22
; %bb.21:
	ds_read2_b32 v[2:3], v1 offset1:2
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v3, v2
	ds_write_b32 v1, v2
.LBB19_22:
	s_or_b32 exec_lo, exec_lo, s0
	v_cmp_eq_u32_e32 vcc_lo, 0, v0
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	s_and_saveexec_b32 s0, vcc_lo
	s_cbranch_execz .LBB19_24
; %bb.23:
	v_mov_b32_e32 v0, 0
	ds_read_b32 v0, v0 offset:4
	ds_read_b32 v2, v1
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v0, v0, v2
	ds_write_b32 v1, v0
.LBB19_24:
	s_or_b32 exec_lo, exec_lo, s0
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	s_and_saveexec_b32 s0, vcc_lo
	s_cbranch_execz .LBB19_26
; %bb.25:
	s_lshl_b64 s[6:7], s[6:7], 2
	s_add_u32 s0, s14, s6
	s_addc_u32 s1, s15, s7
	s_load_dword s0, s[0:1], 0x0
	s_waitcnt lgkmcnt(0)
	v_add_f32_e64 v2, 0x3727c5ac, s0
	s_mov_b32 s0, 0x3e76c4e1
	v_frexp_mant_f32_e64 v0, |v2|
	v_cmp_gt_f32_e32 vcc_lo, 0x3f2aaaab, v0
	v_cndmask_b32_e64 v1, 1.0, 2.0, vcc_lo
	v_mul_f32_e32 v0, v0, v1
	v_add_f32_e32 v1, 1.0, v0
	v_add_f32_e32 v4, -1.0, v0
	v_rcp_f32_e32 v3, v1
	v_add_f32_e32 v6, -1.0, v1
	v_sub_f32_e32 v0, v0, v6
	v_mul_f32_e32 v5, v4, v3
	v_mul_f32_e32 v7, v1, v5
	v_fma_f32 v1, v5, v1, -v7
	v_fmac_f32_e32 v1, v5, v0
	v_add_f32_e32 v0, v7, v1
	v_sub_f32_e32 v6, v4, v0
	v_sub_f32_e32 v7, v0, v7
	v_sub_f32_e32 v4, v4, v6
	v_sub_f32_e32 v1, v7, v1
	v_sub_f32_e32 v0, v4, v0
	v_add_f32_e32 v0, v1, v0
	v_add_f32_e32 v0, v6, v0
	v_mul_f32_e32 v0, v3, v0
	v_add_f32_e32 v3, v5, v0
	v_sub_f32_e32 v1, v3, v5
	v_mul_f32_e32 v4, v3, v3
	v_sub_f32_e32 v5, v0, v1
	v_fma_f32 v0, v3, v3, -v4
	v_add_f32_e32 v1, v5, v5
	v_fmac_f32_e32 v0, v3, v1
	v_add_f32_e32 v6, v4, v0
	v_fmaak_f32 v1, s0, v6, 0x3e91f4c4
	v_sub_f32_e32 v4, v6, v4
	v_mul_f32_e32 v11, v3, v6
	v_fmaak_f32 v1, v6, v1, 0x3ecccdef
	v_sub_f32_e32 v4, v0, v4
	v_fma_f32 v12, v6, v3, -v11
	v_mul_f32_e32 v7, v6, v1
	v_fmac_f32_e32 v12, v6, v5
	v_ldexp_f32 v5, v5, 1
	v_fma_f32 v8, v6, v1, -v7
	v_fmac_f32_e32 v12, v4, v3
	v_fmac_f32_e32 v8, v4, v1
	v_cvt_f64_f32_e64 v[0:1], |v2|
	v_add_f32_e32 v9, v7, v8
	v_sub_f32_e32 v7, v9, v7
	v_add_f32_e32 v10, 0x3f2aaaaa, v9
	v_sub_f32_e32 v7, v8, v7
	v_add_f32_e32 v8, 0xbf2aaaaa, v10
	v_add_f32_e32 v7, 0x31739010, v7
	v_sub_f32_e32 v8, v9, v8
	v_frexp_exp_i32_f64_e32 v0, v[0:1]
	v_add_f32_e32 v6, v7, v8
	v_add_f32_e32 v7, v11, v12
	v_add_f32_e32 v4, v10, v6
	v_sub_f32_e32 v9, v7, v11
	v_sub_f32_e32 v1, v10, v4
	v_mul_f32_e32 v8, v7, v4
	v_sub_f32_e32 v9, v12, v9
	v_add_f32_e32 v1, v6, v1
	v_fma_f32 v6, v7, v4, -v8
	v_subrev_co_ci_u32_e64 v0, null, 0, v0, vcc_lo
	v_fmac_f32_e32 v6, v7, v1
	v_ldexp_f32 v1, v3, 1
	v_cmp_eq_f32_e32 vcc_lo, 1.0, v2
	v_cvt_f32_i32_e32 v0, v0
	v_fmac_f32_e32 v6, v9, v4
	v_add_f32_e32 v3, v8, v6
	v_add_f32_e32 v4, v1, v3
	v_sub_f32_e32 v7, v3, v8
	v_mul_f32_e32 v8, 0x3f317218, v0
	v_sub_f32_e32 v1, v4, v1
	v_sub_f32_e32 v6, v6, v7
	v_fma_f32 v7, 0x3f317218, v0, -v8
	v_sub_f32_e32 v1, v3, v1
	v_add_f32_e32 v3, v5, v6
	v_fmamk_f32 v0, v0, 0xb102e308, v7
	v_add_f32_e32 v1, v3, v1
	v_add_f32_e32 v3, v8, v0
	v_add_f32_e32 v5, v4, v1
	v_sub_f32_e32 v8, v3, v8
	v_add_f32_e32 v6, v3, v5
	v_sub_f32_e32 v4, v5, v4
	v_sub_f32_e32 v0, v0, v8
	v_sub_f32_e32 v7, v6, v3
	v_sub_f32_e32 v1, v1, v4
	v_sub_f32_e32 v9, v6, v7
	v_sub_f32_e32 v4, v5, v7
	v_add_f32_e32 v5, v0, v1
	v_sub_f32_e32 v3, v3, v9
	v_add_f32_e32 v3, v4, v3
	v_sub_f32_e32 v4, v5, v0
	v_add_f32_e32 v3, v5, v3
	v_sub_f32_e32 v5, v5, v4
	v_sub_f32_e32 v1, v1, v4
	v_add_f32_e32 v7, v6, v3
	v_sub_f32_e32 v0, v0, v5
	v_sub_f32_e32 v4, v7, v6
	v_add_f32_e32 v0, v1, v0
	v_sub_f32_e32 v1, v3, v4
	v_cndmask_b32_e64 v3, 0xbfc00000, 1.0, vcc_lo
	v_add_f32_e32 v0, v0, v1
	v_cmp_gt_f32_e64 s2, 0, v3
	v_add_f32_e32 v1, v7, v0
	v_sub_f32_e32 v4, v1, v7
	v_mul_f32_e32 v5, v3, v1
	v_sub_f32_e32 v0, v0, v4
	v_fma_f32 v1, v3, v1, -v5
	v_cmp_class_f32_e64 vcc_lo, v5, 0x204
	v_fmac_f32_e32 v1, v3, v0
	v_add_f32_e32 v0, v5, v1
	v_cndmask_b32_e32 v4, v0, v5, vcc_lo
	v_sub_f32_e32 v0, v0, v5
	v_cmp_eq_f32_e32 vcc_lo, 0x42b17218, v4
	v_sub_f32_e32 v0, v1, v0
	v_cndmask_b32_e64 v6, 0, 0x37000000, vcc_lo
	v_cmp_neq_f32_e64 vcc_lo, 0x7f800000, |v4|
	v_sub_f32_e32 v7, v4, v6
	v_cndmask_b32_e32 v0, 0, v0, vcc_lo
	v_trunc_f32_e32 v4, v3
	v_mul_f32_e32 v8, 0x3fb8aa3b, v7
	v_cmp_ngt_f32_e32 vcc_lo, 0xc2ce8ed0, v7
	v_add_f32_e32 v0, v6, v0
	v_fma_f32 v9, 0x3fb8aa3b, v7, -v8
	v_rndne_f32_e32 v10, v8
	v_fmamk_f32 v9, v7, 0x32a5705f, v9
	v_sub_f32_e32 v8, v8, v10
	v_cvt_i32_f32_e32 v5, v10
	v_add_f32_e32 v8, v8, v9
	v_exp_f32_e32 v8, v8
	v_ldexp_f32 v1, v8, v5
	v_mul_f32_e32 v5, 0.5, v3
	v_cndmask_b32_e32 v1, 0, v1, vcc_lo
	v_cmp_nlt_f32_e32 vcc_lo, 0x42b17218, v7
	v_trunc_f32_e32 v8, v5
	v_cndmask_b32_e32 v1, 0x7f800000, v1, vcc_lo
	v_cmp_eq_f32_e32 vcc_lo, v4, v3
	v_cmp_neq_f32_e64 s0, v8, v5
	v_mov_b32_e32 v4, 0
	v_fma_f32 v0, v1, v0, v1
	v_cmp_class_f32_e64 s1, v1, 0x204
	s_and_b32 s0, vcc_lo, s0
	v_cndmask_b32_e64 v5, 1.0, v2, s0
	v_cndmask_b32_e64 v6, 0, v2, s0
	v_cndmask_b32_e64 v0, v0, v1, s1
	v_cmp_eq_f32_e64 s1, 0, v2
	ds_read_b32 v1, v4
	v_cmp_class_f32_e64 s0, v2, 0x204
	v_bfi_b32 v0, 0x7fffffff, v0, v5
	s_xor_b32 s2, s1, s2
	v_cndmask_b32_e64 v3, 0x7f800000, 0, s2
	s_load_dwordx2 s[2:3], s[4:5], 0x30
	v_cndmask_b32_e32 v5, 0x7fc00000, v0, vcc_lo
	v_cmp_gt_f32_e32 vcc_lo, 0, v2
	v_bfi_b32 v3, 0x7fffffff, v3, v6
	v_cndmask_b32_e32 v0, v0, v5, vcc_lo
	s_or_b32 vcc_lo, s1, s0
	v_cndmask_b32_e32 v0, v0, v3, vcc_lo
	v_cmp_o_f32_e32 vcc_lo, v2, v2
	s_waitcnt lgkmcnt(0)
	v_mul_f32_e32 v1, -0.5, v1
	v_cndmask_b32_e32 v0, 0x7fc00000, v0, vcc_lo
	s_add_u32 s0, s2, s6
	s_addc_u32 s1, s3, s7
	v_mul_f32_e32 v0, v1, v0
	global_store_dword v4, v0, s[0:1]
.LBB19_26:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel fast_variance_delta_kernel
		.amdhsa_group_segment_fixed_size 1024
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 56
		.amdhsa_user_sgpr_count 6
		.amdhsa_user_sgpr_private_segment_buffer 1
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_flat_scratch_init 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_wavefront_size32 1
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_system_sgpr_private_segment_wavefront_offset 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 13
		.amdhsa_next_free_sgpr 20
		.amdhsa_reserve_vcc 1
		.amdhsa_reserve_flat_scratch 0
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 3
		.amdhsa_float_denorm_mode_16_64 3
		.amdhsa_dx10_clamp 1
		.amdhsa_ieee_mode 1
		.amdhsa_fp16_overflow 0
		.amdhsa_workgroup_processor_mode 1
		.amdhsa_memory_ordered 1
		.amdhsa_forward_progress 1
		.amdhsa_shared_vgpr_count 0
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.text
.Lfunc_end19:
	.size	fast_variance_delta_kernel, .Lfunc_end19-fast_variance_delta_kernel
                                        ; -- End function
	.set fast_variance_delta_kernel.num_vgpr, 13
	.set fast_variance_delta_kernel.num_agpr, 0
	.set fast_variance_delta_kernel.numbered_sgpr, 20
	.set fast_variance_delta_kernel.num_named_barrier, 0
	.set fast_variance_delta_kernel.private_seg_size, 0
	.set fast_variance_delta_kernel.uses_vcc, 1
	.set fast_variance_delta_kernel.uses_flat_scratch, 0
	.set fast_variance_delta_kernel.has_dyn_sized_stack, 0
	.set fast_variance_delta_kernel.has_recursion, 0
	.set fast_variance_delta_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 1768
; TotalNumSgprs: 22
; NumVgprs: 13
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 1024 bytes/workgroup (compile time only)
; SGPRBlocks: 0
; VGPRBlocks: 1
; NumSGPRsForWavesPerEU: 22
; NumVGPRsForWavesPerEU: 13
; Occupancy: 16
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 6
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
	.text
	.protected	normalize_delta_kernel  ; -- Begin function normalize_delta_kernel
	.globl	normalize_delta_kernel
	.p2align	8
	.type	normalize_delta_kernel,@function
normalize_delta_kernel:                 ; @normalize_delta_kernel
; %bb.0:
	s_clause 0x1
	s_load_dword s0, s[4:5], 0x54
	s_load_dword s1, s[4:5], 0x0
	s_waitcnt lgkmcnt(0)
	s_and_b32 s0, s0, 0xffff
	v_mad_u64_u32 v[0:1], null, s6, s0, v[0:1]
	s_mov_b32 s0, exec_lo
	v_cmpx_gt_i32_e64 s1, v0
	s_cbranch_execz .LBB20_2
; %bb.1:
	s_load_dwordx4 s[16:19], s[4:5], 0x30
	v_sub_nc_u32_e32 v3, 0, v0
	s_clause 0x1
	s_load_dwordx8 s[8:15], s[4:5], 0x8
	s_load_dwordx2 s[2:3], s[4:5], 0x40
	v_max_i32_e32 v3, v0, v3
	s_waitcnt lgkmcnt(0)
	s_abs_i32 s0, s18
	v_cvt_f32_u32_e32 v1, s0
	s_sub_i32 s1, 0, s0
	v_rcp_iflag_f32_e32 v1, v1
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	v_mul_lo_u32 v2, s1, v1
	s_abs_i32 s1, s17
	v_cvt_f32_u32_e32 v4, s1
	v_mul_hi_u32 v2, v1, v2
	v_rcp_iflag_f32_e32 v4, v4
	v_add_nc_u32_e32 v1, v1, v2
	v_mul_f32_e32 v4, 0x4f7ffffe, v4
	v_mul_hi_u32 v1, v3, v1
	v_cvt_u32_f32_e32 v4, v4
	v_mul_lo_u32 v2, v1, s0
	v_sub_nc_u32_e32 v2, v3, v2
	v_add_nc_u32_e32 v3, 1, v1
	v_subrev_nc_u32_e32 v5, s0, v2
	v_cmp_le_u32_e32 vcc_lo, s0, v2
	v_cndmask_b32_e32 v1, v1, v3, vcc_lo
	v_cndmask_b32_e32 v2, v2, v5, vcc_lo
	v_xor_b32_e32 v3, s18, v0
	v_add_nc_u32_e32 v5, 1, v1
	v_cmp_le_u32_e32 vcc_lo, s0, v2
	v_ashrrev_i32_e32 v3, 31, v3
	s_sub_i32 s0, 0, s1
	v_mul_lo_u32 v2, s0, v4
	v_cndmask_b32_e32 v1, v1, v5, vcc_lo
	v_xor_b32_e32 v1, v1, v3
	v_mul_hi_u32 v2, v4, v2
	v_sub_nc_u32_e32 v1, v1, v3
	v_sub_nc_u32_e32 v3, 0, v1
	v_add_nc_u32_e32 v2, v4, v2
	v_max_i32_e32 v3, v1, v3
	v_ashrrev_i32_e32 v1, 31, v1
	v_mul_hi_u32 v2, v3, v2
	v_mul_lo_u32 v2, v2, s1
	v_sub_nc_u32_e32 v2, v3, v2
	v_subrev_nc_u32_e32 v3, s1, v2
	v_cmp_le_u32_e32 vcc_lo, s1, v2
	v_cndmask_b32_e32 v2, v2, v3, vcc_lo
	v_subrev_nc_u32_e32 v3, s1, v2
	v_cmp_le_u32_e32 vcc_lo, s1, v2
	s_load_dwordx2 s[0:1], s[4:5], 0x28
	v_cndmask_b32_e32 v2, v2, v3, vcc_lo
	v_xor_b32_e32 v2, v2, v1
	v_sub_nc_u32_e32 v1, v2, v1
	v_ashrrev_i32_e32 v2, 31, v1
	v_lshlrev_b64 v[2:3], 2, v[1:2]
	v_ashrrev_i32_e32 v1, 31, v0
	v_add_co_u32 v4, vcc_lo, s12, v2
	v_add_co_ci_u32_e64 v5, null, s13, v3, vcc_lo
	v_lshlrev_b64 v[0:1], 2, v[0:1]
	global_load_dword v10, v[4:5], off
	v_add_co_u32 v4, vcc_lo, s8, v0
	v_add_co_ci_u32_e64 v5, null, s9, v1, vcc_lo
	s_waitcnt lgkmcnt(0)
	v_add_co_u32 v6, vcc_lo, s0, v2
	v_add_co_ci_u32_e64 v7, null, s1, v3, vcc_lo
	v_add_co_u32 v8, vcc_lo, s10, v2
	v_add_co_ci_u32_e64 v9, null, s11, v3, vcc_lo
	v_add_co_u32 v0, vcc_lo, s2, v0
	v_add_co_ci_u32_e64 v1, null, s3, v1, vcc_lo
	global_load_dword v4, v[4:5], off
	global_load_dword v5, v[6:7], off
	global_load_dword v6, v[8:9], off
	global_load_dword v7, v[0:1], off
	v_add_co_u32 v2, vcc_lo, s14, v2
	v_add_co_ci_u32_e64 v3, null, s15, v3, vcc_lo
	global_load_dword v2, v[2:3], off
	s_waitcnt vmcnt(5)
	v_add_f32_e32 v3, 0x3727c5ac, v10
	v_mul_f32_e32 v8, 0x4f800000, v3
	v_cmp_gt_f32_e32 vcc_lo, 0xf800000, v3
	v_cndmask_b32_e32 v3, v3, v8, vcc_lo
	v_sqrt_f32_e32 v8, v3
	s_waitcnt vmcnt(3)
	v_add_f32_e32 v5, v5, v5
	s_waitcnt vmcnt(2)
	v_sub_f32_e32 v4, v4, v6
	v_mul_f32_e32 v4, v5, v4
	v_add_nc_u32_e32 v9, -1, v8
	v_add_nc_u32_e32 v10, 1, v8
	v_fma_f32 v11, -v9, v8, v3
	v_fma_f32 v12, -v10, v8, v3
	v_cmp_ge_f32_e64 s0, 0, v11
	v_cndmask_b32_e64 v8, v8, v9, s0
	v_cmp_lt_f32_e64 s0, 0, v12
	v_cndmask_b32_e64 v8, v8, v10, s0
	s_mul_i32 s0, s18, s16
	v_cvt_f32_i32_e32 v6, s0
	v_mul_f32_e32 v9, 0x37800000, v8
	s_waitcnt vmcnt(0)
	v_div_scale_f32 v10, null, v6, v6, v2
	v_cndmask_b32_e32 v8, v8, v9, vcc_lo
	v_cmp_class_f32_e64 vcc_lo, v3, 0x260
	v_div_scale_f32 v14, s0, v4, v6, v4
	v_rcp_f32_e32 v12, v10
	v_cndmask_b32_e32 v3, v8, v3, vcc_lo
	v_div_scale_f32 v8, null, v6, v6, v4
	v_div_scale_f32 v5, null, v3, v3, v7
	v_rcp_f32_e32 v11, v8
	v_div_scale_f32 v16, vcc_lo, v7, v3, v7
	v_rcp_f32_e32 v9, v5
	v_fma_f32 v15, -v8, v11, 1.0
	v_fma_f32 v13, -v5, v9, 1.0
	v_fmac_f32_e32 v11, v15, v11
	v_div_scale_f32 v15, s1, v2, v6, v2
	v_fmac_f32_e32 v9, v13, v9
	v_fma_f32 v13, -v10, v12, 1.0
	v_mul_f32_e32 v17, v16, v9
	v_fmac_f32_e32 v12, v13, v12
	v_mul_f32_e32 v13, v14, v11
	v_fma_f32 v18, -v5, v17, v16
	v_mul_f32_e32 v19, v15, v12
	v_fma_f32 v20, -v8, v13, v14
	v_fmac_f32_e32 v17, v18, v9
	v_fma_f32 v18, -v10, v19, v15
	v_fmac_f32_e32 v13, v20, v11
	v_fma_f32 v5, -v5, v17, v16
	v_fmac_f32_e32 v19, v18, v12
	v_fma_f32 v8, -v8, v13, v14
	v_div_fmas_f32 v5, v5, v9, v17
	s_mov_b32 vcc_lo, s0
	v_fma_f32 v9, -v10, v19, v15
	v_div_fmas_f32 v8, v8, v11, v13
	s_mov_b32 vcc_lo, s1
	v_div_fixup_f32 v3, v5, v3, v7
	v_div_fmas_f32 v5, v9, v12, v19
	v_div_fixup_f32 v4, v8, v6, v4
	v_div_fixup_f32 v2, v5, v6, v2
	v_add_f32_e32 v3, v3, v4
	v_add_f32_e32 v2, v2, v3
	global_store_dword v[0:1], v2, off
.LBB20_2:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel normalize_delta_kernel
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 328
		.amdhsa_user_sgpr_count 6
		.amdhsa_user_sgpr_private_segment_buffer 1
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_flat_scratch_init 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_wavefront_size32 1
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_system_sgpr_private_segment_wavefront_offset 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 21
		.amdhsa_next_free_sgpr 20
		.amdhsa_reserve_vcc 1
		.amdhsa_reserve_flat_scratch 0
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 3
		.amdhsa_float_denorm_mode_16_64 3
		.amdhsa_dx10_clamp 1
		.amdhsa_ieee_mode 1
		.amdhsa_fp16_overflow 0
		.amdhsa_workgroup_processor_mode 1
		.amdhsa_memory_ordered 1
		.amdhsa_forward_progress 1
		.amdhsa_shared_vgpr_count 0
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.text
.Lfunc_end20:
	.size	normalize_delta_kernel, .Lfunc_end20-normalize_delta_kernel
                                        ; -- End function
	.set normalize_delta_kernel.num_vgpr, 21
	.set normalize_delta_kernel.num_agpr, 0
	.set normalize_delta_kernel.numbered_sgpr, 20
	.set normalize_delta_kernel.num_named_barrier, 0
	.set normalize_delta_kernel.private_seg_size, 0
	.set normalize_delta_kernel.uses_vcc, 1
	.set normalize_delta_kernel.uses_flat_scratch, 0
	.set normalize_delta_kernel.has_dyn_sized_stack, 0
	.set normalize_delta_kernel.has_recursion, 0
	.set normalize_delta_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 900
; TotalNumSgprs: 22
; NumVgprs: 21
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 0
; VGPRBlocks: 2
; NumSGPRsForWavesPerEU: 22
; NumVGPRsForWavesPerEU: 21
; Occupancy: 16
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 6
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
	.text
	.protected	softmax_kernel          ; -- Begin function softmax_kernel
	.globl	softmax_kernel
	.p2align	8
	.type	softmax_kernel,@function
softmax_kernel:                         ; @softmax_kernel
; %bb.0:
	s_clause 0x1
	s_load_dword s0, s[4:5], 0x3c
	s_load_dwordx4 s[8:11], s[4:5], 0x8
	s_waitcnt lgkmcnt(0)
	s_and_b32 s0, s0, 0xffff
	v_mad_u64_u32 v[0:1], null, s6, s0, v[0:1]
	s_mul_i32 s0, s11, s9
	v_cmp_gt_i32_e32 vcc_lo, s0, v0
	s_and_saveexec_b32 s0, vcc_lo
	s_cbranch_execz .LBB21_8
; %bb.1:
	s_load_dwordx4 s[0:3], s[4:5], 0x18
	s_cmp_lt_i32 s8, 1
	s_cbranch_scc1 .LBB21_8
; %bb.2:
	s_waitcnt lgkmcnt(0)
	s_abs_i32 s3, s11
	v_sub_nc_u32_e32 v3, 0, v0
	v_cvt_f32_u32_e32 v1, s3
	s_sub_i32 s6, 0, s3
	v_mov_b32_e32 v6, 0xff800000
	s_ashr_i32 s7, s1, 31
	v_max_i32_e32 v3, v0, v3
	v_rcp_iflag_f32_e32 v1, v1
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	v_mul_lo_u32 v2, s6, v1
	s_ashr_i32 s6, s11, 31
	v_mul_hi_u32 v2, v1, v2
	v_add_nc_u32_e32 v1, v1, v2
	v_mad_u64_u32 v[1:2], null, v3, v1, 0
	v_mul_lo_u32 v1, v2, s3
	v_sub_nc_u32_e32 v1, v3, v1
	v_add_nc_u32_e32 v3, 1, v2
	v_subrev_nc_u32_e32 v4, s3, v1
	v_cmp_le_u32_e32 vcc_lo, s3, v1
	v_cndmask_b32_e32 v2, v2, v3, vcc_lo
	v_cndmask_b32_e32 v1, v1, v4, vcc_lo
	v_ashrrev_i32_e32 v3, 31, v0
	v_add_nc_u32_e32 v4, 1, v2
	v_cmp_le_u32_e32 vcc_lo, s3, v1
	v_xor_b32_e32 v3, s6, v3
	s_mov_b32 s6, s1
	s_lshl_b64 s[6:7], s[6:7], 2
	v_cndmask_b32_e32 v1, v2, v4, vcc_lo
	v_xor_b32_e32 v1, v1, v3
	v_sub_nc_u32_e32 v1, v1, v3
	v_mul_lo_u32 v2, v1, s11
	v_mul_lo_u32 v1, v1, s10
	s_load_dwordx2 s[10:11], s[4:5], 0x0
	v_sub_nc_u32_e32 v0, v0, v2
	v_mad_u64_u32 v[0:1], null, v0, s0, v[1:2]
	s_mov_b32 s0, s8
	v_ashrrev_i32_e32 v1, 31, v0
	v_lshlrev_b64 v[2:3], 2, v[0:1]
	s_waitcnt lgkmcnt(0)
	v_add_co_u32 v4, vcc_lo, s10, v2
	v_add_co_ci_u32_e64 v5, null, s11, v3, vcc_lo
.LBB21_3:                               ; =>This Inner Loop Header: Depth=1
	global_load_dword v7, v[4:5], off
	v_max_f32_e32 v6, v6, v6
	v_add_co_u32 v4, vcc_lo, v4, s6
	v_add_co_ci_u32_e64 v5, null, s7, v5, vcc_lo
	s_add_i32 s0, s0, -1
	s_cmp_eq_u32 s0, 0
	s_waitcnt vmcnt(0)
	v_max_f32_e32 v7, v7, v7
	v_max_f32_e32 v6, v6, v7
	s_cbranch_scc0 .LBB21_3
; %bb.4:
	v_div_scale_f32 v4, null, s2, s2, v6
	v_div_scale_f32 v8, vcc_lo, v6, s2, v6
	s_load_dwordx2 s[4:5], s[4:5], 0x28
	v_rcp_f32_e32 v5, v4
	s_mov_b32 s1, s8
	v_fma_f32 v7, -v4, v5, 1.0
	v_fmac_f32_e32 v5, v7, v5
	v_mul_f32_e32 v7, v8, v5
	v_fma_f32 v9, -v4, v7, v8
	v_fmac_f32_e32 v7, v9, v5
	v_fma_f32 v4, -v4, v7, v8
	v_div_fmas_f32 v4, v4, v5, v7
	v_div_fixup_f32 v5, v4, s2, v6
	v_mov_b32_e32 v4, 0
.LBB21_5:                               ; =>This Inner Loop Header: Depth=1
	v_add_co_u32 v6, vcc_lo, s10, v2
	v_add_co_ci_u32_e64 v7, null, s11, v3, vcc_lo
	s_add_i32 s1, s1, -1
	s_cmp_lg_u32 s1, 0
	global_load_dword v6, v[6:7], off
	s_waitcnt vmcnt(0)
	v_div_scale_f32 v7, null, s2, s2, v6
	v_div_scale_f32 v10, vcc_lo, v6, s2, v6
	v_rcp_f32_e32 v8, v7
	v_fma_f32 v9, -v7, v8, 1.0
	v_fmac_f32_e32 v8, v9, v8
	v_mul_f32_e32 v9, v10, v8
	v_fma_f32 v11, -v7, v9, v10
	v_fmac_f32_e32 v9, v11, v8
	v_fma_f32 v7, -v7, v9, v10
	v_div_fmas_f32 v7, v7, v8, v9
	v_div_fixup_f32 v6, v7, s2, v6
	v_sub_f32_e32 v8, v6, v5
	v_mul_f32_e32 v6, 0x3fb8aa3b, v8
	v_cmp_ngt_f32_e64 s0, 0xc2ce8ed0, v8
	v_fma_f32 v7, 0x3fb8aa3b, v8, -v6
	v_rndne_f32_e32 v9, v6
	v_fmac_f32_e32 v7, 0x32a5705f, v8
	v_sub_f32_e32 v6, v6, v9
	v_add_f32_e32 v6, v6, v7
	v_cvt_i32_f32_e32 v7, v9
	v_exp_f32_e32 v6, v6
	v_ldexp_f32 v7, v6, v7
	s_waitcnt lgkmcnt(0)
	v_add_co_u32 v6, vcc_lo, s4, v2
	v_cndmask_b32_e64 v9, 0, v7, s0
	v_add_co_ci_u32_e64 v7, null, s5, v3, vcc_lo
	v_cmp_nlt_f32_e32 vcc_lo, 0x42b17218, v8
	v_cndmask_b32_e32 v8, 0x7f800000, v9, vcc_lo
	v_add_co_u32 v2, vcc_lo, v2, s6
	v_add_co_ci_u32_e64 v3, null, s7, v3, vcc_lo
	v_add_f32_e32 v4, v4, v8
	global_store_dword v[6:7], v8, off
	s_cbranch_scc1 .LBB21_5
; %bb.6:
	v_lshlrev_b64 v[0:1], 2, v[0:1]
	v_add_co_u32 v0, vcc_lo, s4, v0
	v_add_co_ci_u32_e64 v1, null, s5, v1, vcc_lo
	.p2align	6
.LBB21_7:                               ; =>This Inner Loop Header: Depth=1
	global_load_dword v2, v[0:1], off
	s_add_i32 s8, s8, -1
	s_cmp_lg_u32 s8, 0
	s_waitcnt vmcnt(0)
	v_div_scale_f32 v3, null, v4, v4, v2
	v_div_scale_f32 v7, vcc_lo, v2, v4, v2
	v_rcp_f32_e32 v5, v3
	v_fma_f32 v6, -v3, v5, 1.0
	v_fmac_f32_e32 v5, v6, v5
	v_mul_f32_e32 v6, v7, v5
	v_fma_f32 v8, -v3, v6, v7
	v_fmac_f32_e32 v6, v8, v5
	v_fma_f32 v3, -v3, v6, v7
	v_div_fmas_f32 v3, v3, v5, v6
	v_div_fixup_f32 v2, v3, v4, v2
	global_store_dword v[0:1], v2, off
	v_add_co_u32 v0, vcc_lo, v0, s6
	v_add_co_ci_u32_e64 v1, null, s7, v1, vcc_lo
	s_cbranch_scc1 .LBB21_7
.LBB21_8:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel softmax_kernel
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 304
		.amdhsa_user_sgpr_count 6
		.amdhsa_user_sgpr_private_segment_buffer 1
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_flat_scratch_init 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_wavefront_size32 1
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_system_sgpr_private_segment_wavefront_offset 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 12
		.amdhsa_next_free_sgpr 12
		.amdhsa_reserve_vcc 1
		.amdhsa_reserve_flat_scratch 0
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 3
		.amdhsa_float_denorm_mode_16_64 3
		.amdhsa_dx10_clamp 1
		.amdhsa_ieee_mode 1
		.amdhsa_fp16_overflow 0
		.amdhsa_workgroup_processor_mode 1
		.amdhsa_memory_ordered 1
		.amdhsa_forward_progress 1
		.amdhsa_shared_vgpr_count 0
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.text
.Lfunc_end21:
	.size	softmax_kernel, .Lfunc_end21-softmax_kernel
                                        ; -- End function
	.set softmax_kernel.num_vgpr, 12
	.set softmax_kernel.num_agpr, 0
	.set softmax_kernel.numbered_sgpr, 12
	.set softmax_kernel.num_named_barrier, 0
	.set softmax_kernel.private_seg_size, 0
	.set softmax_kernel.uses_vcc, 1
	.set softmax_kernel.uses_flat_scratch, 0
	.set softmax_kernel.has_dyn_sized_stack, 0
	.set softmax_kernel.has_recursion, 0
	.set softmax_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 892
; TotalNumSgprs: 14
; NumVgprs: 12
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 0
; VGPRBlocks: 1
; NumSGPRsForWavesPerEU: 14
; NumVGPRsForWavesPerEU: 12
; Occupancy: 16
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 6
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
	.text
	.protected	softmax_x_ent_kernel    ; -- Begin function softmax_x_ent_kernel
	.globl	softmax_x_ent_kernel
	.p2align	8
	.type	softmax_x_ent_kernel,@function
softmax_x_ent_kernel:                   ; @softmax_x_ent_kernel
; %bb.0:
	s_clause 0x1
	s_load_dword s0, s[4:5], 0x34
	s_load_dword s1, s[4:5], 0x0
	s_waitcnt lgkmcnt(0)
	s_and_b32 s0, s0, 0xffff
	v_mad_u64_u32 v[0:1], null, s6, s0, v[0:1]
	s_mov_b32 s0, exec_lo
	v_cmpx_gt_i32_e64 s1, v0
	s_cbranch_execz .LBB22_2
; %bb.1:
	s_load_dwordx8 s[0:7], s[4:5], 0x8
	v_ashrrev_i32_e32 v1, 31, v0
	v_lshlrev_b64 v[0:1], 2, v[0:1]
	s_waitcnt lgkmcnt(0)
	v_add_co_u32 v2, vcc_lo, s0, v0
	v_add_co_ci_u32_e64 v3, null, s1, v1, vcc_lo
	global_load_dword v4, v[2:3], off
	v_add_co_u32 v2, vcc_lo, s2, v0
	v_add_co_ci_u32_e64 v3, null, s3, v1, vcc_lo
	global_load_dword v5, v[2:3], off
	s_waitcnt vmcnt(1)
	v_max_f32_e32 v2, v4, v4
	v_max_f32_e32 v2, 0x1e3ce508, v2
	s_waitcnt vmcnt(0)
	v_sub_f32_e32 v4, v5, v4
	v_cmp_gt_f32_e32 vcc_lo, 0x800000, v2
	v_cndmask_b32_e64 v3, 0, 32, vcc_lo
	v_cndmask_b32_e64 v6, 0, 0x41b17218, vcc_lo
	v_ldexp_f32 v2, v2, v3
	v_log_f32_e32 v2, v2
	v_mul_f32_e32 v3, 0x3f317217, v2
	v_cmp_gt_f32_e64 vcc_lo, 0x7f800000, |v2|
	v_fma_f32 v3, 0x3f317217, v2, -v3
	v_fmamk_f32 v3, v2, 0x3377d1cf, v3
	v_fmac_f32_e32 v3, 0x3f317217, v2
	v_cndmask_b32_e32 v7, v2, v3, vcc_lo
	v_add_co_u32 v2, vcc_lo, s6, v0
	v_add_co_ci_u32_e64 v3, null, s7, v1, vcc_lo
	v_add_co_u32 v0, vcc_lo, s4, v0
	v_sub_f32_e32 v6, v7, v6
	v_add_co_ci_u32_e64 v1, null, s5, v1, vcc_lo
	v_cmp_neq_f32_e32 vcc_lo, 0, v5
	v_cndmask_b32_e64 v6, 0, -v6, vcc_lo
	global_store_dword v[2:3], v6, off
	global_store_dword v[0:1], v4, off
.LBB22_2:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel softmax_x_ent_kernel
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 296
		.amdhsa_user_sgpr_count 6
		.amdhsa_user_sgpr_private_segment_buffer 1
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_flat_scratch_init 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_wavefront_size32 1
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_system_sgpr_private_segment_wavefront_offset 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 8
		.amdhsa_next_free_sgpr 8
		.amdhsa_reserve_vcc 1
		.amdhsa_reserve_flat_scratch 0
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 3
		.amdhsa_float_denorm_mode_16_64 3
		.amdhsa_dx10_clamp 1
		.amdhsa_ieee_mode 1
		.amdhsa_fp16_overflow 0
		.amdhsa_workgroup_processor_mode 1
		.amdhsa_memory_ordered 1
		.amdhsa_forward_progress 1
		.amdhsa_shared_vgpr_count 0
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.text
.Lfunc_end22:
	.size	softmax_x_ent_kernel, .Lfunc_end22-softmax_x_ent_kernel
                                        ; -- End function
	.set softmax_x_ent_kernel.num_vgpr, 8
	.set softmax_x_ent_kernel.num_agpr, 0
	.set softmax_x_ent_kernel.numbered_sgpr, 8
	.set softmax_x_ent_kernel.num_named_barrier, 0
	.set softmax_x_ent_kernel.private_seg_size, 0
	.set softmax_x_ent_kernel.uses_vcc, 1
	.set softmax_x_ent_kernel.uses_flat_scratch, 0
	.set softmax_x_ent_kernel.has_dyn_sized_stack, 0
	.set softmax_x_ent_kernel.has_recursion, 0
	.set softmax_x_ent_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 312
; TotalNumSgprs: 10
; NumVgprs: 8
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 0
; VGPRBlocks: 0
; NumSGPRsForWavesPerEU: 10
; NumVGPRsForWavesPerEU: 8
; Occupancy: 16
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 6
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
	.text
	.protected	l2_kernel               ; -- Begin function l2_kernel
	.globl	l2_kernel
	.p2align	8
	.type	l2_kernel,@function
l2_kernel:                              ; @l2_kernel
; %bb.0:
	s_clause 0x1
	s_load_dword s0, s[4:5], 0x34
	s_load_dword s1, s[4:5], 0x0
	s_waitcnt lgkmcnt(0)
	s_and_b32 s0, s0, 0xffff
	v_mad_u64_u32 v[0:1], null, s6, s0, v[0:1]
	s_mov_b32 s0, exec_lo
	v_cmpx_gt_i32_e64 s1, v0
	s_cbranch_execz .LBB23_2
; %bb.1:
	s_load_dwordx8 s[0:7], s[4:5], 0x8
	v_ashrrev_i32_e32 v1, 31, v0
	v_lshlrev_b64 v[0:1], 2, v[0:1]
	s_waitcnt lgkmcnt(0)
	v_add_co_u32 v2, vcc_lo, s2, v0
	v_add_co_ci_u32_e64 v3, null, s3, v1, vcc_lo
	v_add_co_u32 v4, vcc_lo, s0, v0
	v_add_co_ci_u32_e64 v5, null, s1, v1, vcc_lo
	global_load_dword v2, v[2:3], off
	global_load_dword v3, v[4:5], off
	s_waitcnt vmcnt(0)
	v_sub_f32_e32 v4, v2, v3
	v_add_co_u32 v2, vcc_lo, s6, v0
	v_add_co_ci_u32_e64 v3, null, s7, v1, vcc_lo
	v_add_co_u32 v0, vcc_lo, s4, v0
	v_mul_f32_e32 v5, v4, v4
	v_add_co_ci_u32_e64 v1, null, s5, v1, vcc_lo
	global_store_dword v[2:3], v5, off
	global_store_dword v[0:1], v4, off
.LBB23_2:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel l2_kernel
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 296
		.amdhsa_user_sgpr_count 6
		.amdhsa_user_sgpr_private_segment_buffer 1
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_flat_scratch_init 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_wavefront_size32 1
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_system_sgpr_private_segment_wavefront_offset 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 6
		.amdhsa_next_free_sgpr 8
		.amdhsa_reserve_vcc 1
		.amdhsa_reserve_flat_scratch 0
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 3
		.amdhsa_float_denorm_mode_16_64 3
		.amdhsa_dx10_clamp 1
		.amdhsa_ieee_mode 1
		.amdhsa_fp16_overflow 0
		.amdhsa_workgroup_processor_mode 1
		.amdhsa_memory_ordered 1
		.amdhsa_forward_progress 1
		.amdhsa_shared_vgpr_count 0
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.text
.Lfunc_end23:
	.size	l2_kernel, .Lfunc_end23-l2_kernel
                                        ; -- End function
	.set l2_kernel.num_vgpr, 6
	.set l2_kernel.num_agpr, 0
	.set l2_kernel.numbered_sgpr, 8
	.set l2_kernel.num_named_barrier, 0
	.set l2_kernel.private_seg_size, 0
	.set l2_kernel.uses_vcc, 1
	.set l2_kernel.uses_flat_scratch, 0
	.set l2_kernel.has_dyn_sized_stack, 0
	.set l2_kernel.has_recursion, 0
	.set l2_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 192
; TotalNumSgprs: 10
; NumVgprs: 6
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 0
; VGPRBlocks: 0
; NumSGPRsForWavesPerEU: 10
; NumVGPRsForWavesPerEU: 6
; Occupancy: 16
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 6
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
	.text
	.protected	l1_kernel               ; -- Begin function l1_kernel
	.globl	l1_kernel
	.p2align	8
	.type	l1_kernel,@function
l1_kernel:                              ; @l1_kernel
; %bb.0:
	s_clause 0x1
	s_load_dword s0, s[4:5], 0x34
	s_load_dword s1, s[4:5], 0x0
	s_waitcnt lgkmcnt(0)
	s_and_b32 s0, s0, 0xffff
	v_mad_u64_u32 v[0:1], null, s6, s0, v[0:1]
	s_mov_b32 s0, exec_lo
	v_cmpx_gt_i32_e64 s1, v0
	s_cbranch_execz .LBB24_2
; %bb.1:
	s_load_dwordx8 s[0:7], s[4:5], 0x8
	v_ashrrev_i32_e32 v1, 31, v0
	v_lshlrev_b64 v[0:1], 2, v[0:1]
	s_waitcnt lgkmcnt(0)
	v_add_co_u32 v2, vcc_lo, s2, v0
	v_add_co_ci_u32_e64 v3, null, s3, v1, vcc_lo
	v_add_co_u32 v4, vcc_lo, s0, v0
	v_add_co_ci_u32_e64 v5, null, s1, v1, vcc_lo
	global_load_dword v6, v[2:3], off
	global_load_dword v4, v[4:5], off
	v_add_co_u32 v2, vcc_lo, s6, v0
	v_add_co_ci_u32_e64 v3, null, s7, v1, vcc_lo
	v_add_co_u32 v0, vcc_lo, s4, v0
	v_add_co_ci_u32_e64 v1, null, s5, v1, vcc_lo
	s_waitcnt vmcnt(0)
	v_sub_f32_e32 v4, v6, v4
	v_cmp_lt_f32_e32 vcc_lo, 0, v4
	v_and_b32_e32 v5, 0x7fffffff, v4
	v_cndmask_b32_e64 v4, -1.0, 1.0, vcc_lo
	global_store_dword v[2:3], v5, off
	global_store_dword v[0:1], v4, off
.LBB24_2:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel l1_kernel
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 296
		.amdhsa_user_sgpr_count 6
		.amdhsa_user_sgpr_private_segment_buffer 1
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_flat_scratch_init 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_wavefront_size32 1
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_system_sgpr_private_segment_wavefront_offset 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 7
		.amdhsa_next_free_sgpr 8
		.amdhsa_reserve_vcc 1
		.amdhsa_reserve_flat_scratch 0
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 3
		.amdhsa_float_denorm_mode_16_64 3
		.amdhsa_dx10_clamp 1
		.amdhsa_ieee_mode 1
		.amdhsa_fp16_overflow 0
		.amdhsa_workgroup_processor_mode 1
		.amdhsa_memory_ordered 1
		.amdhsa_forward_progress 1
		.amdhsa_shared_vgpr_count 0
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.text
.Lfunc_end24:
	.size	l1_kernel, .Lfunc_end24-l1_kernel
                                        ; -- End function
	.set l1_kernel.num_vgpr, 7
	.set l1_kernel.num_agpr, 0
	.set l1_kernel.numbered_sgpr, 8
	.set l1_kernel.num_named_barrier, 0
	.set l1_kernel.private_seg_size, 0
	.set l1_kernel.uses_vcc, 1
	.set l1_kernel.uses_flat_scratch, 0
	.set l1_kernel.has_dyn_sized_stack, 0
	.set l1_kernel.has_recursion, 0
	.set l1_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 208
; TotalNumSgprs: 10
; NumVgprs: 7
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 0
; VGPRBlocks: 0
; NumSGPRsForWavesPerEU: 10
; NumVGPRsForWavesPerEU: 7
; Occupancy: 16
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 6
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
	.text
	.protected	smooth_l1_kernel        ; -- Begin function smooth_l1_kernel
	.globl	smooth_l1_kernel
	.p2align	8
	.type	smooth_l1_kernel,@function
smooth_l1_kernel:                       ; @smooth_l1_kernel
; %bb.0:
	s_clause 0x1
	s_load_dword s0, s[4:5], 0x34
	s_load_dword s1, s[4:5], 0x0
	s_waitcnt lgkmcnt(0)
	s_and_b32 s0, s0, 0xffff
	v_mad_u64_u32 v[0:1], null, s6, s0, v[0:1]
	s_mov_b32 s0, exec_lo
	v_cmpx_gt_i32_e64 s1, v0
	s_cbranch_execz .LBB25_6
; %bb.1:
	s_load_dwordx8 s[0:7], s[4:5], 0x8
	v_ashrrev_i32_e32 v1, 31, v0
	v_lshlrev_b64 v[0:1], 2, v[0:1]
	s_waitcnt lgkmcnt(0)
	v_add_co_u32 v2, vcc_lo, s2, v0
	v_add_co_ci_u32_e64 v3, null, s3, v1, vcc_lo
	v_add_co_u32 v4, vcc_lo, s0, v0
	v_add_co_ci_u32_e64 v5, null, s1, v1, vcc_lo
	global_load_dword v2, v[2:3], off
	global_load_dword v3, v[4:5], off
	s_waitcnt vmcnt(0)
	v_sub_f32_e32 v2, v2, v3
	v_cmp_nlt_f32_e64 s0, |v2|, 1.0
	s_and_saveexec_b32 s1, s0
	s_xor_b32 s0, exec_lo, s1
	s_cbranch_execz .LBB25_3
; %bb.2:
	v_add_co_u32 v3, vcc_lo, s6, v0
	v_fma_f32 v5, |v2|, 2.0, -1.0
	v_add_co_ci_u32_e64 v4, null, s7, v1, vcc_lo
	v_cmp_gt_f32_e32 vcc_lo, 0, v2
	global_store_dword v[3:4], v5, off
	v_cndmask_b32_e64 v2, -1.0, 1.0, vcc_lo
.LBB25_3:
	s_andn2_saveexec_b32 s0, s0
	s_cbranch_execz .LBB25_5
; %bb.4:
	v_add_co_u32 v3, vcc_lo, s6, v0
	v_mul_f32_e32 v5, v2, v2
	v_add_co_ci_u32_e64 v4, null, s7, v1, vcc_lo
	global_store_dword v[3:4], v5, off
.LBB25_5:
	s_or_b32 exec_lo, exec_lo, s0
	v_add_co_u32 v0, vcc_lo, s4, v0
	v_add_co_ci_u32_e64 v1, null, s5, v1, vcc_lo
	global_store_dword v[0:1], v2, off
.LBB25_6:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel smooth_l1_kernel
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 296
		.amdhsa_user_sgpr_count 6
		.amdhsa_user_sgpr_private_segment_buffer 1
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_flat_scratch_init 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_wavefront_size32 1
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_system_sgpr_private_segment_wavefront_offset 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 6
		.amdhsa_next_free_sgpr 8
		.amdhsa_reserve_vcc 1
		.amdhsa_reserve_flat_scratch 0
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 3
		.amdhsa_float_denorm_mode_16_64 3
		.amdhsa_dx10_clamp 1
		.amdhsa_ieee_mode 1
		.amdhsa_fp16_overflow 0
		.amdhsa_workgroup_processor_mode 1
		.amdhsa_memory_ordered 1
		.amdhsa_forward_progress 1
		.amdhsa_shared_vgpr_count 0
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.text
.Lfunc_end25:
	.size	smooth_l1_kernel, .Lfunc_end25-smooth_l1_kernel
                                        ; -- End function
	.set smooth_l1_kernel.num_vgpr, 6
	.set smooth_l1_kernel.num_agpr, 0
	.set smooth_l1_kernel.numbered_sgpr, 8
	.set smooth_l1_kernel.num_named_barrier, 0
	.set smooth_l1_kernel.private_seg_size, 0
	.set smooth_l1_kernel.uses_vcc, 1
	.set smooth_l1_kernel.uses_flat_scratch, 0
	.set smooth_l1_kernel.has_dyn_sized_stack, 0
	.set smooth_l1_kernel.has_recursion, 0
	.set smooth_l1_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 268
; TotalNumSgprs: 10
; NumVgprs: 6
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 0
; VGPRBlocks: 0
; NumSGPRsForWavesPerEU: 10
; NumVGPRsForWavesPerEU: 6
; Occupancy: 16
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 6
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
	.text
	.protected	im2col_kernel           ; -- Begin function im2col_kernel
	.globl	im2col_kernel
	.p2align	8
	.type	im2col_kernel,@function
im2col_kernel:                          ; @im2col_kernel
; %bb.0:
	s_clause 0x1
	s_load_dword s2, s[4:5], 0x44
	s_load_dword s3, s[4:5], 0x0
	s_add_u32 s0, s4, 56
	s_addc_u32 s1, s5, 0
	s_waitcnt lgkmcnt(0)
	s_and_b32 s2, s2, 0xffff
	v_mad_u64_u32 v[0:1], null, s6, s2, v[0:1]
	s_mov_b32 s6, exec_lo
	v_cmpx_gt_i32_e64 s3, v0
	s_cbranch_execz .LBB26_10
; %bb.1:
	s_load_dwordx8 s[8:15], s[4:5], 0x10
	s_load_dword s21, s[0:1], 0x0
	s_clause 0x1
	s_load_dwordx2 s[6:7], s[4:5], 0x8
	s_load_dwordx2 s[4:5], s[4:5], 0x30
	s_mov_b32 s20, 0
	s_waitcnt lgkmcnt(0)
	s_cmp_gt_i32 s10, 0
	s_mul_i32 s22, s10, s13
	s_cselect_b32 s15, -1, 0
	s_abs_i32 s18, s14
	s_abs_i32 s19, s13
	v_cvt_f32_u32_e32 v1, s18
	v_cvt_f32_u32_e32 v2, s19
	s_sub_i32 s0, 0, s18
	s_sub_i32 s1, 0, s19
	s_mul_i32 s21, s21, s2
	v_rcp_iflag_f32_e32 v1, v1
	v_rcp_iflag_f32_e32 v2, v2
	s_mul_i32 s22, s22, s10
	s_ashr_i32 s23, s14, 31
	s_ashr_i32 s24, s13, 31
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_mul_f32_e32 v2, 0x4f7ffffe, v2
	v_cvt_u32_f32_e32 v1, v1
	v_cvt_u32_f32_e32 v2, v2
	v_mul_lo_u32 v3, s0, v1
	v_mul_lo_u32 v4, s1, v2
	s_mul_i32 s0, s14, s13
	s_ashr_i32 s1, s0, 31
	s_lshl_b64 s[16:17], s[0:1], 2
	v_mul_hi_u32 v3, v1, v3
	v_mul_hi_u32 v4, v2, v4
	v_add_nc_u32_e32 v5, v1, v3
	v_add_nc_u32_e32 v6, v2, v4
	s_branch .LBB26_3
.LBB26_2:                               ;   in Loop: Header=BB26_3 Depth=1
	s_inst_prefetch 0x2
	v_add_nc_u32_e32 v0, s21, v0
	v_cmp_le_i32_e32 vcc_lo, s3, v0
	s_or_b32 s20, vcc_lo, s20
	s_andn2_b32 exec_lo, exec_lo, s20
	s_cbranch_execz .LBB26_10
.LBB26_3:                               ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB26_6 Depth 2
                                        ;       Child Loop BB26_8 Depth 3
	s_andn2_b32 vcc_lo, exec_lo, s15
	s_cbranch_vccnz .LBB26_2
; %bb.4:                                ;   in Loop: Header=BB26_3 Depth=1
	v_sub_nc_u32_e32 v1, 0, v0
	s_mov_b32 s25, 0
	s_mov_b32 s26, 0
	v_max_i32_e32 v1, v0, v1
	v_mul_hi_u32 v2, v1, v5
	v_mul_lo_u32 v3, v2, s18
	v_sub_nc_u32_e32 v1, v1, v3
	v_add_nc_u32_e32 v3, 1, v2
	v_subrev_nc_u32_e32 v4, s18, v1
	v_cmp_le_u32_e32 vcc_lo, s18, v1
	v_cndmask_b32_e32 v2, v2, v3, vcc_lo
	v_cndmask_b32_e32 v1, v1, v4, vcc_lo
	v_ashrrev_i32_e32 v3, 31, v0
	v_add_nc_u32_e32 v4, 1, v2
	v_cmp_le_u32_e32 vcc_lo, s18, v1
	v_xor_b32_e32 v3, s23, v3
	v_cndmask_b32_e32 v1, v2, v4, vcc_lo
	v_xor_b32_e32 v1, v1, v3
	v_sub_nc_u32_e32 v1, v1, v3
	v_sub_nc_u32_e32 v2, 0, v1
	v_max_i32_e32 v2, v1, v2
	v_mul_hi_u32 v3, v2, v6
	v_mul_lo_u32 v4, v3, s19
	v_sub_nc_u32_e32 v2, v2, v4
	v_add_nc_u32_e32 v4, 1, v3
	v_subrev_nc_u32_e32 v7, s19, v2
	v_cmp_le_u32_e32 vcc_lo, s19, v2
	v_cndmask_b32_e32 v3, v3, v4, vcc_lo
	v_cndmask_b32_e32 v2, v2, v7, vcc_lo
	v_ashrrev_i32_e32 v4, 31, v1
	v_add_nc_u32_e32 v7, 1, v3
	v_cmp_le_u32_e32 vcc_lo, s19, v2
	v_xor_b32_e32 v4, s24, v4
	v_cndmask_b32_e32 v2, v3, v7, vcc_lo
	v_mul_lo_u32 v7, v1, s14
	v_xor_b32_e32 v2, v2, v4
	v_sub_nc_u32_e32 v7, v0, v7
	v_sub_nc_u32_e32 v8, v2, v4
	v_mul_lo_u32 v2, v8, s13
	v_sub_nc_u32_e32 v2, v1, v2
	v_mul_lo_u32 v3, v2, s12
	v_subrev_nc_u32_e32 v1, s11, v3
	v_mad_u64_u32 v[3:4], null, v8, s8, v[1:2]
	v_mad_u64_u32 v[8:9], null, s22, v8, v[2:3]
	v_mul_lo_u32 v2, v7, s12
	v_mul_lo_u32 v9, v3, s9
	v_mul_lo_u32 v11, v8, s14
	v_ashrrev_i32_e32 v8, 31, v7
	v_subrev_nc_u32_e32 v2, s11, v2
	v_ashrrev_i32_e32 v10, 31, v9
	v_lshlrev_b64 v[13:14], 2, v[7:8]
	v_ashrrev_i32_e32 v3, 31, v2
	v_ashrrev_i32_e32 v12, 31, v11
	v_lshlrev_b64 v[9:10], 2, v[9:10]
	v_lshlrev_b64 v[3:4], 2, v[2:3]
	v_lshlrev_b64 v[7:8], 2, v[11:12]
	v_add_co_u32 v9, vcc_lo, s6, v9
	v_add_co_ci_u32_e64 v10, null, s7, v10, vcc_lo
	v_add_co_u32 v11, vcc_lo, s4, v7
	v_add_co_ci_u32_e64 v12, null, s5, v8, vcc_lo
	v_add_co_u32 v7, vcc_lo, v9, v3
	v_add_co_ci_u32_e64 v8, null, v10, v4, vcc_lo
	v_add_co_u32 v3, vcc_lo, v11, v13
	v_add_co_ci_u32_e64 v4, null, v12, v14, vcc_lo
	s_inst_prefetch 0x1
	s_branch .LBB26_6
	.p2align	6
.LBB26_5:                               ;   in Loop: Header=BB26_6 Depth=2
	s_add_i32 s26, s26, 1
	s_add_i32 s25, s25, s9
	s_cmp_eq_u32 s26, s10
	s_cbranch_scc1 .LBB26_2
.LBB26_6:                               ;   Parent Loop BB26_3 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB26_8 Depth 3
	v_add_nc_u32_e32 v9, s26, v1
	s_mov_b32 s27, 0
	v_cmp_gt_i32_e64 s0, s8, v9
	v_cmp_lt_i32_e32 vcc_lo, -1, v9
	s_branch .LBB26_8
	.p2align	6
.LBB26_7:                               ;   in Loop: Header=BB26_8 Depth=3
	s_or_b32 exec_lo, exec_lo, s2
	s_waitcnt vmcnt(0)
	global_store_dword v[3:4], v9, off
	v_add_co_u32 v3, s1, v3, s16
	v_add_co_ci_u32_e64 v4, null, s17, v4, s1
	s_add_i32 s27, s27, 1
	s_cmp_eq_u32 s10, s27
	s_cbranch_scc1 .LBB26_5
.LBB26_8:                               ;   Parent Loop BB26_3 Depth=1
                                        ;     Parent Loop BB26_6 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	v_add_nc_u32_e32 v9, s27, v2
	v_cmp_lt_i32_e64 s1, -1, v9
	v_cmp_gt_i32_e64 s2, s9, v9
	v_mov_b32_e32 v9, 0
	s_and_b32 s1, vcc_lo, s1
	s_and_b32 s1, s0, s1
	s_and_b32 s1, s1, s2
	s_and_saveexec_b32 s2, s1
	s_cbranch_execz .LBB26_7
; %bb.9:                                ;   in Loop: Header=BB26_8 Depth=3
	s_add_i32 s28, s25, s27
	s_ashr_i32 s29, s28, 31
	s_lshl_b64 s[28:29], s[28:29], 2
	v_add_co_u32 v9, s1, v7, s28
	v_add_co_ci_u32_e64 v10, null, s29, v8, s1
	global_load_dword v9, v[9:10], off
	s_branch .LBB26_7
.LBB26_10:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel im2col_kernel
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 312
		.amdhsa_user_sgpr_count 6
		.amdhsa_user_sgpr_private_segment_buffer 1
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_flat_scratch_init 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_wavefront_size32 1
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_system_sgpr_private_segment_wavefront_offset 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 15
		.amdhsa_next_free_sgpr 30
		.amdhsa_reserve_vcc 1
		.amdhsa_reserve_flat_scratch 0
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 3
		.amdhsa_float_denorm_mode_16_64 3
		.amdhsa_dx10_clamp 1
		.amdhsa_ieee_mode 1
		.amdhsa_fp16_overflow 0
		.amdhsa_workgroup_processor_mode 1
		.amdhsa_memory_ordered 1
		.amdhsa_forward_progress 1
		.amdhsa_shared_vgpr_count 0
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.text
.Lfunc_end26:
	.size	im2col_kernel, .Lfunc_end26-im2col_kernel
                                        ; -- End function
	.set im2col_kernel.num_vgpr, 15
	.set im2col_kernel.num_agpr, 0
	.set im2col_kernel.numbered_sgpr, 30
	.set im2col_kernel.num_named_barrier, 0
	.set im2col_kernel.private_seg_size, 0
	.set im2col_kernel.uses_vcc, 1
	.set im2col_kernel.uses_flat_scratch, 0
	.set im2col_kernel.has_dyn_sized_stack, 0
	.set im2col_kernel.has_recursion, 0
	.set im2col_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 836
; TotalNumSgprs: 32
; NumVgprs: 15
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 0
; VGPRBlocks: 1
; NumSGPRsForWavesPerEU: 32
; NumVGPRsForWavesPerEU: 15
; Occupancy: 16
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 6
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
	.text
	.protected	col2im_kernel           ; -- Begin function col2im_kernel
	.globl	col2im_kernel
	.p2align	8
	.type	col2im_kernel,@function
col2im_kernel:                          ; @col2im_kernel
; %bb.0:
	s_clause 0x1
	s_load_dword s2, s[4:5], 0x44
	s_load_dword s7, s[4:5], 0x0
	s_add_u32 s0, s4, 56
	s_addc_u32 s1, s5, 0
	s_waitcnt lgkmcnt(0)
	s_and_b32 s17, s2, 0xffff
	s_mov_b32 s2, exec_lo
	v_mad_u64_u32 v[0:1], null, s6, s17, v[0:1]
	v_cmpx_gt_i32_e64 s7, v0
	s_cbranch_execz .LBB27_15
; %bb.1:
	s_clause 0x2
	s_load_dwordx8 s[8:15], s[4:5], 0x10
	s_load_dwordx2 s[2:3], s[4:5], 0x8
	s_load_dwordx2 s[4:5], s[4:5], 0x30
	s_load_dword s0, s[0:1], 0x0
	s_mov_b32 s1, 0
	s_waitcnt lgkmcnt(0)
	s_mul_i32 s21, s9, s8
	s_abs_i32 s6, s9
	s_abs_i32 s8, s8
	s_abs_i32 s15, s12
	s_abs_i32 s16, s21
	v_cvt_f32_u32_e32 v1, s6
	v_cvt_f32_u32_e32 v2, s8
	v_cvt_f32_u32_e32 v3, s16
	v_cvt_f32_u32_e32 v4, s15
	s_sub_i32 s18, 0, s6
	v_rcp_iflag_f32_e32 v1, v1
	v_rcp_iflag_f32_e32 v2, v2
	v_rcp_iflag_f32_e32 v3, v3
	v_rcp_iflag_f32_e32 v4, v4
	s_sub_i32 s19, 0, s8
	s_sub_i32 s20, 0, s15
	s_sub_i32 s22, 0, s16
	s_mul_i32 s17, s0, s17
	s_ashr_i32 s21, s21, 31
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_mul_f32_e32 v2, 0x4f7ffffe, v2
	v_mul_f32_e32 v3, 0x4f7ffffe, v3
	v_mul_f32_e32 v4, 0x4f7ffffe, v4
	v_cvt_u32_f32_e32 v1, v1
	v_cvt_u32_f32_e32 v2, v2
	v_cvt_u32_f32_e32 v3, v3
	v_cvt_u32_f32_e32 v4, v4
	v_mul_lo_u32 v5, s18, v1
	v_mul_lo_u32 v6, s19, v2
	v_mul_lo_u32 v7, s22, v3
	v_mul_lo_u32 v8, s20, v4
	s_mul_i32 s20, s13, s10
	s_mul_i32 s19, s13, s14
	s_mul_i32 s20, s20, s12
	s_mul_i32 s0, s19, s12
	v_mul_hi_u32 v5, v1, v5
	v_mul_hi_u32 v6, v2, v6
	v_mul_hi_u32 v7, v3, v7
	v_mul_hi_u32 v8, v4, v8
	s_sub_i32 s19, 1, s20
	s_ashr_i32 s18, s9, 31
	s_sub_i32 s20, 1, s0
	s_ashr_i32 s12, s12, 31
	v_add_nc_u32_e32 v5, v1, v5
	v_add_nc_u32_e32 v6, v2, v6
	v_add_nc_u32_e32 v7, v3, v7
	v_add_nc_u32_e32 v8, v4, v8
	s_mul_i32 s22, s14, s19
	s_branch .LBB27_4
.LBB27_2:                               ;   in Loop: Header=BB27_4 Depth=1
	s_inst_prefetch 0x2
	s_or_b32 exec_lo, exec_lo, s24
.LBB27_3:                               ;   in Loop: Header=BB27_4 Depth=1
	s_or_b32 exec_lo, exec_lo, s23
	v_lshlrev_b64 v[1:2], 2, v[0:1]
	v_add_nc_u32_e32 v0, s17, v0
	v_add_co_u32 v1, vcc_lo, s4, v1
	v_add_co_ci_u32_e64 v2, null, s5, v2, vcc_lo
	v_cmp_le_i32_e32 vcc_lo, s7, v0
	global_load_dword v3, v[1:2], off
	s_or_b32 s1, vcc_lo, s1
	s_waitcnt vmcnt(0)
	v_add_f32_e32 v3, v11, v3
	global_store_dword v[1:2], v3, off
	s_andn2_b32 exec_lo, exec_lo, s1
	s_cbranch_execz .LBB27_15
.LBB27_4:                               ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB27_11 Depth 2
                                        ;       Child Loop BB27_13 Depth 3
	v_sub_nc_u32_e32 v1, 0, v0
	s_mov_b32 s0, exec_lo
	v_max_i32_e32 v12, v0, v1
	v_mul_hi_u32 v1, v12, v5
	v_mul_lo_u32 v2, v1, s6
	v_add_nc_u32_e32 v3, 1, v1
	v_sub_nc_u32_e32 v2, v12, v2
	v_subrev_nc_u32_e32 v4, s6, v2
	v_cmp_le_u32_e32 vcc_lo, s6, v2
	v_cndmask_b32_e32 v3, v1, v3, vcc_lo
	v_cndmask_b32_e32 v2, v2, v4, vcc_lo
	v_ashrrev_i32_e32 v1, 31, v0
	v_add_nc_u32_e32 v4, 1, v3
	v_cmp_le_u32_e32 vcc_lo, s6, v2
	v_xor_b32_e32 v9, s18, v1
	v_cndmask_b32_e32 v2, v3, v4, vcc_lo
	v_xor_b32_e32 v2, v2, v9
	v_sub_nc_u32_e32 v2, v2, v9
	v_mov_b32_e32 v9, 0
	v_mul_lo_u32 v3, v2, s9
	v_sub_nc_u32_e32 v4, v0, v3
	v_add_nc_u32_e32 v4, s11, v4
	v_cmpx_le_i32_e64 s10, v4
	s_cbranch_execz .LBB27_6
; %bb.5:                                ;   in Loop: Header=BB27_4 Depth=1
	v_subrev_nc_u32_e32 v9, s10, v4
	v_mul_hi_u32 v10, v9, v8
	v_mul_lo_u32 v11, v10, s15
	v_sub_nc_u32_e32 v9, v9, v11
	v_add_nc_u32_e32 v11, 1, v10
	v_subrev_nc_u32_e32 v13, s15, v9
	v_cmp_le_u32_e32 vcc_lo, s15, v9
	v_cndmask_b32_e32 v10, v10, v11, vcc_lo
	v_cndmask_b32_e32 v9, v9, v13, vcc_lo
	v_add_nc_u32_e32 v11, 1, v10
	v_cmp_le_u32_e32 vcc_lo, s15, v9
	v_cndmask_b32_e32 v9, v10, v11, vcc_lo
	v_xor_b32_e32 v9, s12, v9
	v_subrev_nc_u32_e32 v9, s12, v9
	v_add_nc_u32_e32 v9, 1, v9
.LBB27_6:                               ;   in Loop: Header=BB27_4 Depth=1
	s_or_b32 exec_lo, exec_lo, s0
	v_sub_nc_u32_e32 v10, 0, v2
	s_mov_b32 s0, exec_lo
	v_max_i32_e32 v10, v2, v10
	v_ashrrev_i32_e32 v2, 31, v2
	v_mul_hi_u32 v11, v10, v6
	v_mul_lo_u32 v11, v11, s8
	v_sub_nc_u32_e32 v10, v10, v11
	v_subrev_nc_u32_e32 v11, s8, v10
	v_cmp_le_u32_e32 vcc_lo, s8, v10
	v_cndmask_b32_e32 v10, v10, v11, vcc_lo
	v_subrev_nc_u32_e32 v11, s8, v10
	v_cmp_le_u32_e32 vcc_lo, s8, v10
	v_cndmask_b32_e32 v10, v10, v11, vcc_lo
	v_mov_b32_e32 v11, 0
	v_xor_b32_e32 v10, v10, v2
	v_sub_nc_u32_e32 v2, v10, v2
	v_mov_b32_e32 v10, 0
	v_add_nc_u32_e32 v2, s11, v2
	v_cmpx_le_i32_e64 s10, v2
	s_cbranch_execz .LBB27_8
; %bb.7:                                ;   in Loop: Header=BB27_4 Depth=1
	v_subrev_nc_u32_e32 v10, s10, v2
	v_mul_hi_u32 v13, v10, v8
	v_mul_lo_u32 v14, v13, s15
	v_sub_nc_u32_e32 v10, v10, v14
	v_add_nc_u32_e32 v14, 1, v13
	v_subrev_nc_u32_e32 v15, s15, v10
	v_cmp_le_u32_e32 vcc_lo, s15, v10
	v_cndmask_b32_e32 v13, v13, v14, vcc_lo
	v_cndmask_b32_e32 v10, v10, v15, vcc_lo
	v_add_nc_u32_e32 v14, 1, v13
	v_cmp_le_u32_e32 vcc_lo, s15, v10
	v_cndmask_b32_e32 v10, v13, v14, vcc_lo
	v_xor_b32_e32 v10, s12, v10
	v_subrev_nc_u32_e32 v10, s12, v10
	v_add_nc_u32_e32 v10, 1, v10
.LBB27_8:                               ;   in Loop: Header=BB27_4 Depth=1
	s_or_b32 exec_lo, exec_lo, s0
	v_sub_nc_u32_e32 v13, 0, v2
	s_mov_b32 s23, exec_lo
	v_max_i32_e32 v13, v2, v13
	v_mul_hi_u32 v14, v13, v8
	v_mul_lo_u32 v15, v14, s15
	v_sub_nc_u32_e32 v13, v13, v15
	v_add_nc_u32_e32 v15, 1, v14
	v_subrev_nc_u32_e32 v16, s15, v13
	v_cmp_le_u32_e32 vcc_lo, s15, v13
	v_cndmask_b32_e32 v14, v14, v15, vcc_lo
	v_cndmask_b32_e32 v13, v13, v16, vcc_lo
	v_ashrrev_i32_e32 v15, 31, v2
	v_add_nc_u32_e32 v16, 1, v14
	v_cmp_le_u32_e32 vcc_lo, s15, v13
	v_xor_b32_e32 v15, s12, v15
	v_cndmask_b32_e32 v13, v14, v16, vcc_lo
	v_xor_b32_e32 v13, v13, v15
	v_sub_nc_u32_e32 v13, v13, v15
	v_add_nc_u32_e32 v13, 1, v13
	v_min_i32_e32 v13, s13, v13
	v_cmpx_lt_i32_e64 v10, v13
	s_cbranch_execz .LBB27_3
; %bb.9:                                ;   in Loop: Header=BB27_4 Depth=1
	v_mul_hi_u32 v11, v12, v7
	v_sub_nc_u32_e32 v15, 0, v4
	v_xor_b32_e32 v17, s21, v1
	s_mov_b32 s24, 0
	v_max_i32_e32 v15, v4, v15
	v_mul_lo_u32 v14, v11, s16
	v_mul_hi_u32 v16, v15, v8
	v_sub_nc_u32_e32 v12, v12, v14
	v_add_nc_u32_e32 v14, 1, v11
	v_mul_lo_u32 v18, v16, s15
	v_cmp_le_u32_e32 vcc_lo, s16, v12
	v_cndmask_b32_e32 v11, v11, v14, vcc_lo
	v_subrev_nc_u32_e32 v14, s16, v12
	v_cndmask_b32_e32 v12, v12, v14, vcc_lo
	v_add_nc_u32_e32 v14, 1, v11
	v_cmp_le_u32_e32 vcc_lo, s16, v12
	v_add_nc_u32_e32 v12, 1, v16
	v_cndmask_b32_e32 v11, v11, v14, vcc_lo
	v_sub_nc_u32_e32 v14, v15, v18
	v_xor_b32_e32 v11, v11, v17
	v_cmp_le_u32_e32 vcc_lo, s15, v14
	v_sub_nc_u32_e32 v11, v11, v17
	v_cndmask_b32_e32 v15, v16, v12, vcc_lo
	v_subrev_nc_u32_e32 v16, s15, v14
	v_mad_u64_u32 v[11:12], null, v11, s10, v[2:3]
	v_ashrrev_i32_e32 v2, 31, v4
	v_cndmask_b32_e32 v4, v14, v16, vcc_lo
	v_add_nc_u32_e32 v12, 1, v15
	v_xor_b32_e32 v14, s12, v2
	v_mul_lo_u32 v2, v11, s10
	v_cmp_le_u32_e32 vcc_lo, s15, v4
	v_cndmask_b32_e32 v4, v15, v12, vcc_lo
	v_add3_u32 v11, s11, v0, v2
	v_mul_lo_u32 v2, s19, v10
	v_xor_b32_e32 v4, v4, v14
	v_sub_nc_u32_e32 v3, v11, v3
	v_mov_b32_e32 v11, 0
	v_sub_nc_u32_e32 v4, v4, v14
	v_mad_u64_u32 v[2:3], null, s13, v3, v[2:3]
	v_mul_lo_u32 v3, s20, v9
	v_add_nc_u32_e32 v4, 1, v4
	v_min_i32_e32 v12, s14, v4
	v_mad_u64_u32 v[2:3], null, s14, v2, v[3:4]
	v_cmp_lt_i32_e32 vcc_lo, v9, v12
	s_inst_prefetch 0x1
	s_branch .LBB27_11
	.p2align	6
.LBB27_10:                              ;   in Loop: Header=BB27_11 Depth=2
	s_or_b32 exec_lo, exec_lo, s25
	v_add_nc_u32_e32 v10, 1, v10
	v_add_nc_u32_e32 v2, s22, v2
	v_cmp_ge_i32_e64 s0, v10, v13
	s_or_b32 s24, s0, s24
	s_andn2_b32 exec_lo, exec_lo, s24
	s_cbranch_execz .LBB27_2
.LBB27_11:                              ;   Parent Loop BB27_4 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB27_13 Depth 3
	s_and_saveexec_b32 s25, vcc_lo
	s_cbranch_execz .LBB27_10
; %bb.12:                               ;   in Loop: Header=BB27_11 Depth=2
	v_mov_b32_e32 v3, v2
	v_mov_b32_e32 v14, v9
	s_mov_b32 s26, 0
	.p2align	6
.LBB27_13:                              ;   Parent Loop BB27_4 Depth=1
                                        ;     Parent Loop BB27_11 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	v_ashrrev_i32_e32 v4, 31, v3
	v_add_nc_u32_e32 v14, 1, v14
	v_lshlrev_b64 v[15:16], 2, v[3:4]
	v_add_nc_u32_e32 v3, s20, v3
	v_add_co_u32 v15, s0, s2, v15
	v_add_co_ci_u32_e64 v16, null, s3, v16, s0
	v_cmp_ge_i32_e64 s0, v14, v12
	global_load_dword v4, v[15:16], off
	s_or_b32 s26, s0, s26
	s_waitcnt vmcnt(0)
	v_add_f32_e32 v11, v11, v4
	s_andn2_b32 exec_lo, exec_lo, s26
	s_cbranch_execnz .LBB27_13
; %bb.14:                               ;   in Loop: Header=BB27_11 Depth=2
	s_or_b32 exec_lo, exec_lo, s26
	s_branch .LBB27_10
.LBB27_15:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel col2im_kernel
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 312
		.amdhsa_user_sgpr_count 6
		.amdhsa_user_sgpr_private_segment_buffer 1
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_flat_scratch_init 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_wavefront_size32 1
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_system_sgpr_private_segment_wavefront_offset 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 19
		.amdhsa_next_free_sgpr 27
		.amdhsa_reserve_vcc 1
		.amdhsa_reserve_flat_scratch 0
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 3
		.amdhsa_float_denorm_mode_16_64 3
		.amdhsa_dx10_clamp 1
		.amdhsa_ieee_mode 1
		.amdhsa_fp16_overflow 0
		.amdhsa_workgroup_processor_mode 1
		.amdhsa_memory_ordered 1
		.amdhsa_forward_progress 1
		.amdhsa_shared_vgpr_count 0
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.text
.Lfunc_end27:
	.size	col2im_kernel, .Lfunc_end27-col2im_kernel
                                        ; -- End function
	.set col2im_kernel.num_vgpr, 19
	.set col2im_kernel.num_agpr, 0
	.set col2im_kernel.numbered_sgpr, 27
	.set col2im_kernel.num_named_barrier, 0
	.set col2im_kernel.private_seg_size, 0
	.set col2im_kernel.uses_vcc, 1
	.set col2im_kernel.uses_flat_scratch, 0
	.set col2im_kernel.has_dyn_sized_stack, 0
	.set col2im_kernel.has_recursion, 0
	.set col2im_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 1300
; TotalNumSgprs: 29
; NumVgprs: 19
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 0
; VGPRBlocks: 2
; NumSGPRsForWavesPerEU: 29
; NumVGPRsForWavesPerEU: 19
; Occupancy: 16
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 6
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
	.text
	.protected	forward_maxpool_kernel  ; -- Begin function forward_maxpool_kernel
	.globl	forward_maxpool_kernel
	.p2align	8
	.type	forward_maxpool_kernel,@function
forward_maxpool_kernel:                 ; @forward_maxpool_kernel
; %bb.0:
	s_clause 0x1
	s_load_dword s0, s[4:5], 0x44
	s_load_dwordx4 s[16:19], s[4:5], 0x0
	s_waitcnt lgkmcnt(0)
	s_and_b32 s0, s0, 0xffff
	v_mad_u64_u32 v[0:1], null, s6, s0, v[0:1]
	s_mov_b32 s0, exec_lo
	v_cmpx_gt_i32_e64 s16, v0
	s_cbranch_execz .LBB28_12
; %bb.1:
	s_load_dwordx8 s[8:15], s[4:5], 0x10
	v_sub_nc_u32_e32 v3, 0, v0
	s_load_dwordx2 s[4:5], s[4:5], 0x30
	v_max_i32_e32 v3, v0, v3
	s_waitcnt lgkmcnt(0)
	s_abs_i32 s0, s8
	s_sub_i32 s3, s18, s9
	v_cvt_f32_u32_e32 v1, s0
	s_sub_i32 s2, 0, s0
	s_add_i32 s3, s3, s10
	s_abs_i32 s6, s3
	v_rcp_iflag_f32_e32 v1, v1
	s_ashr_i32 s3, s3, 31
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	v_readfirstlane_b32 s1, v1
	s_mul_i32 s2, s2, s1
	s_mul_hi_u32 s2, s1, s2
	s_add_i32 s1, s1, s2
	s_ashr_i32 s2, s8, 31
	s_mul_hi_u32 s7, s6, s1
	s_xor_b32 s3, s3, s2
	s_mul_i32 s11, s7, s0
	s_sub_i32 s6, s6, s11
	s_add_i32 s11, s7, 1
	s_sub_i32 s16, s6, s0
	s_cmp_ge_u32 s6, s0
	s_cselect_b32 s7, s11, s7
	s_cselect_b32 s6, s16, s6
	s_add_i32 s11, s7, 1
	s_cmp_ge_u32 s6, s0
	s_cselect_b32 s7, s11, s7
	s_sub_i32 s6, s17, s9
	s_xor_b32 s7, s7, s3
	s_add_i32 s6, s6, s10
	s_abs_i32 s11, s6
	s_mul_hi_u32 s16, s11, s1
	s_sub_i32 s1, s7, s3
	s_mul_i32 s3, s16, s0
	s_add_i32 s1, s1, 1
	s_sub_i32 s3, s11, s3
	s_add_i32 s7, s16, 1
	s_sub_i32 s11, s3, s0
	s_cmp_ge_u32 s3, s0
	s_cselect_b32 s7, s7, s16
	s_cselect_b32 s3, s11, s3
	s_add_i32 s11, s7, 1
	s_cmp_ge_u32 s3, s0
	s_cselect_b32 s7, s11, s7
	s_abs_i32 s3, s1
	v_cvt_f32_u32_e32 v1, s3
	s_sub_i32 s0, 0, s3
	s_cmp_lt_i32 s9, 1
	v_rcp_iflag_f32_e32 v1, v1
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	v_mul_lo_u32 v2, s0, v1
	v_mul_hi_u32 v2, v1, v2
	v_add_nc_u32_e32 v1, v1, v2
	v_mul_hi_u32 v1, v3, v1
	v_mul_lo_u32 v2, v1, s3
	v_sub_nc_u32_e32 v2, v3, v2
	v_subrev_nc_u32_e32 v3, s3, v2
	v_cmp_le_u32_e64 s0, s3, v2
	v_cndmask_b32_e64 v2, v2, v3, s0
	v_cmp_le_u32_e32 vcc_lo, s3, v2
	s_mov_b32 s3, 0
	s_cbranch_scc1 .LBB28_10
; %bb.2:
	s_ashr_i32 s6, s6, 31
	v_add_nc_u32_e32 v3, 1, v1
	s_xor_b32 s2, s6, s2
	s_xor_b32 s6, s7, s2
	v_cndmask_b32_e64 v1, v1, v3, s0
	s_sub_i32 s2, s6, s2
	v_xor_b32_e32 v3, s1, v0
	s_add_i32 s2, s2, 1
	s_abs_i32 s6, s2
	v_add_nc_u32_e32 v4, 1, v1
	v_cvt_f32_u32_e32 v2, s6
	v_ashrrev_i32_e32 v3, 31, v3
	s_sub_i32 s0, 0, s6
	v_cndmask_b32_e32 v1, v1, v4, vcc_lo
	v_rcp_iflag_f32_e32 v2, v2
	v_xor_b32_e32 v1, v1, v3
	v_sub_nc_u32_e32 v3, v1, v3
	v_mul_f32_e32 v2, 0x4f7ffffe, v2
	v_cvt_u32_f32_e32 v2, v2
	v_mul_lo_u32 v4, s0, v2
	s_ashr_i32 s0, s2, 31
	v_mul_hi_u32 v1, v2, v4
	v_sub_nc_u32_e32 v4, 0, v3
	v_max_i32_e32 v4, v3, v4
	v_add_nc_u32_e32 v1, v2, v1
	v_mad_u64_u32 v[1:2], null, v4, v1, 0
	v_mul_lo_u32 v1, v2, s6
	v_sub_nc_u32_e32 v1, v4, v1
	v_add_nc_u32_e32 v4, 1, v2
	v_subrev_nc_u32_e32 v5, s6, v1
	v_cmp_le_u32_e32 vcc_lo, s6, v1
	v_cndmask_b32_e32 v2, v2, v4, vcc_lo
	v_cndmask_b32_e32 v1, v1, v5, vcc_lo
	v_ashrrev_i32_e32 v4, 31, v3
	v_add_nc_u32_e32 v5, 1, v2
	v_cmp_le_u32_e32 vcc_lo, s6, v1
	v_xor_b32_e32 v4, s0, v4
	s_lshr_b32 s0, s10, 31
	s_add_i32 s0, s10, s0
	v_cndmask_b32_e32 v1, v2, v5, vcc_lo
	s_ashr_i32 s0, s0, 1
	v_mov_b32_e32 v5, 0xff800000
	v_xor_b32_e32 v1, v1, v4
	v_sub_nc_u32_e32 v2, v1, v4
	v_mul_lo_u32 v1, v2, s2
	v_sub_nc_u32_e32 v1, v3, v1
	v_mul_lo_u32 v3, v3, s1
	v_mul_lo_u32 v1, v1, s8
	v_sub_nc_u32_e32 v4, v0, v3
	v_subrev_nc_u32_e32 v1, s0, v1
	v_mad_u64_u32 v[2:3], null, v2, s17, v[1:2]
	v_mul_lo_u32 v3, v4, s8
	v_mov_b32_e32 v4, -1
	v_mul_lo_u32 v6, s18, v2
	v_subrev_nc_u32_e32 v7, s0, v3
	s_inst_prefetch 0x1
	s_branch .LBB28_4
	.p2align	6
.LBB28_3:                               ;   in Loop: Header=BB28_4 Depth=1
	v_add_nc_u32_e32 v6, s18, v6
	s_add_i32 s3, s3, 1
	s_cmp_eq_u32 s3, s9
	s_cbranch_scc1 .LBB28_11
.LBB28_4:                               ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB28_7 Depth 2
	v_add_nc_u32_e32 v2, s3, v1
	v_mov_b32_e32 v8, v7
	s_mov_b32 s6, s9
	v_cmp_gt_i32_e64 s0, s17, v2
	v_cmp_lt_i32_e32 vcc_lo, -1, v2
	s_branch .LBB28_7
	.p2align	6
.LBB28_5:                               ;   in Loop: Header=BB28_7 Depth=2
	s_or_b32 exec_lo, exec_lo, s2
.LBB28_6:                               ;   in Loop: Header=BB28_7 Depth=2
	s_or_b32 exec_lo, exec_lo, s7
	s_waitcnt vmcnt(0)
	v_cmp_gt_f32_e64 s1, v3, v5
	v_add_nc_u32_e32 v8, 1, v8
	s_add_i32 s6, s6, -1
	s_cmp_eq_u32 s6, 0
	v_cndmask_b32_e64 v4, v4, v2, s1
	v_cndmask_b32_e64 v5, v5, v3, s1
	s_cbranch_scc1 .LBB28_3
.LBB28_7:                               ;   Parent Loop BB28_4 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	v_add_nc_u32_e32 v2, v6, v8
	v_mov_b32_e32 v3, 0xff800000
	s_and_saveexec_b32 s7, vcc_lo
	s_cbranch_execz .LBB28_6
; %bb.8:                                ;   in Loop: Header=BB28_7 Depth=2
	v_cmp_lt_i32_e64 s1, -1, v8
	v_cmp_gt_i32_e64 s2, s18, v8
	v_mov_b32_e32 v3, 0xff800000
	s_and_b32 s1, s1, s2
	s_and_b32 s1, s0, s1
	s_and_saveexec_b32 s2, s1
	s_cbranch_execz .LBB28_5
; %bb.9:                                ;   in Loop: Header=BB28_7 Depth=2
	v_ashrrev_i32_e32 v3, 31, v2
	v_lshlrev_b64 v[9:10], 2, v[2:3]
	v_add_co_u32 v9, s1, s12, v9
	v_add_co_ci_u32_e64 v10, null, s13, v10, s1
	global_load_dword v3, v[9:10], off
	s_branch .LBB28_5
.LBB28_10:
	v_mov_b32_e32 v4, -1
	v_mov_b32_e32 v5, 0xff800000
.LBB28_11:
	s_inst_prefetch 0x2
	v_ashrrev_i32_e32 v1, 31, v0
	v_lshlrev_b64 v[0:1], 2, v[0:1]
	v_add_co_u32 v2, vcc_lo, s14, v0
	v_add_co_ci_u32_e64 v3, null, s15, v1, vcc_lo
	v_add_co_u32 v0, vcc_lo, s4, v0
	v_add_co_ci_u32_e64 v1, null, s5, v1, vcc_lo
	global_store_dword v[2:3], v5, off
	global_store_dword v[0:1], v4, off
.LBB28_12:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel forward_maxpool_kernel
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 312
		.amdhsa_user_sgpr_count 6
		.amdhsa_user_sgpr_private_segment_buffer 1
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_flat_scratch_init 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_wavefront_size32 1
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_system_sgpr_private_segment_wavefront_offset 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 11
		.amdhsa_next_free_sgpr 20
		.amdhsa_reserve_vcc 1
		.amdhsa_reserve_flat_scratch 0
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 3
		.amdhsa_float_denorm_mode_16_64 3
		.amdhsa_dx10_clamp 1
		.amdhsa_ieee_mode 1
		.amdhsa_fp16_overflow 0
		.amdhsa_workgroup_processor_mode 1
		.amdhsa_memory_ordered 1
		.amdhsa_forward_progress 1
		.amdhsa_shared_vgpr_count 0
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.text
.Lfunc_end28:
	.size	forward_maxpool_kernel, .Lfunc_end28-forward_maxpool_kernel
                                        ; -- End function
	.set forward_maxpool_kernel.num_vgpr, 11
	.set forward_maxpool_kernel.num_agpr, 0
	.set forward_maxpool_kernel.numbered_sgpr, 20
	.set forward_maxpool_kernel.num_named_barrier, 0
	.set forward_maxpool_kernel.private_seg_size, 0
	.set forward_maxpool_kernel.uses_vcc, 1
	.set forward_maxpool_kernel.uses_flat_scratch, 0
	.set forward_maxpool_kernel.has_dyn_sized_stack, 0
	.set forward_maxpool_kernel.has_recursion, 0
	.set forward_maxpool_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 1000
; TotalNumSgprs: 22
; NumVgprs: 11
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 0
; VGPRBlocks: 1
; NumSGPRsForWavesPerEU: 22
; NumVGPRsForWavesPerEU: 11
; Occupancy: 16
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 6
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
	.text
	.protected	backward_maxpool_kernel ; -- Begin function backward_maxpool_kernel
	.globl	backward_maxpool_kernel
	.p2align	8
	.type	backward_maxpool_kernel,@function
backward_maxpool_kernel:                ; @backward_maxpool_kernel
; %bb.0:
	s_clause 0x1
	s_load_dwordx8 s[8:15], s[4:5], 0x0
	s_load_dword s1, s[4:5], 0x44
	s_waitcnt lgkmcnt(0)
	s_abs_i32 s0, s12
	s_and_b32 s1, s1, 0xffff
	v_cvt_f32_u32_e32 v1, s0
	v_rcp_iflag_f32_e32 v1, v1
	v_mul_f32_e32 v2, 0x4f7ffffe, v1
	v_mad_u64_u32 v[0:1], null, s6, s1, v[0:1]
	s_mov_b32 s1, exec_lo
	v_cvt_u32_f32_e32 v1, v2
	v_readfirstlane_b32 s11, v1
	v_cmpx_gt_i32_e64 s8, v0
	s_cbranch_execz .LBB29_12
; %bb.1:
	s_sub_i32 s1, 0, s0
	s_add_i32 s2, s13, -1
	s_mul_i32 s1, s1, s11
	s_abs_i32 s8, s2
	s_mul_hi_u32 s1, s11, s1
	s_ashr_i32 s7, s12, 31
	s_add_i32 s11, s11, s1
	s_ashr_i32 s1, s2, 31
	s_mul_hi_u32 s12, s8, s11
	s_clause 0x1
	s_load_dwordx4 s[16:19], s[4:5], 0x20
	s_load_dwordx2 s[2:3], s[4:5], 0x30
	s_mul_i32 s4, s12, s0
	s_xor_b32 s6, s1, s7
	s_sub_i32 s1, s8, s4
	s_add_i32 s4, s12, 1
	s_sub_i32 s5, s1, s0
	s_cmp_ge_u32 s1, s0
	v_mov_b32_e32 v3, 0
	s_cselect_b32 s4, s4, s12
	s_cselect_b32 s1, s5, s1
	s_add_i32 s5, s4, 1
	s_cmp_ge_u32 s1, s0
	s_cselect_b32 s1, s5, s4
	s_xor_b32 s8, s1, s6
	s_sub_i32 s1, s8, s6
	s_cmp_lt_i32 s1, 0
	s_cbranch_scc1 .LBB29_11
; %bb.2:
	s_sub_i32 s4, s9, s13
	s_sub_i32 s5, s10, s13
	s_add_i32 s4, s4, s14
	s_add_i32 s5, s5, s14
	s_abs_i32 s12, s4
	s_ashr_i32 s20, s5, 31
	s_mul_hi_u32 s15, s12, s11
	s_abs_i32 s21, s5
	s_mul_i32 s5, s15, s0
	s_ashr_i32 s13, s4, 31
	s_sub_i32 s5, s12, s5
	s_sub_i32 s4, 0, s1
	s_xor_b32 s13, s13, s7
	s_add_i32 s12, s15, 1
	s_sub_i32 s22, s5, s0
	s_cmp_ge_u32 s5, s0
	v_sub_nc_u32_e32 v3, 0, v0
	s_cselect_b32 s12, s12, s15
	s_cselect_b32 s5, s22, s5
	s_add_i32 s15, s12, 1
	s_cmp_ge_u32 s5, s0
	v_max_i32_e32 v3, v0, v3
	s_cselect_b32 s5, s15, s12
	s_mul_hi_u32 s12, s21, s11
	s_xor_b32 s5, s5, s13
	s_mul_i32 s15, s12, s0
	s_sub_i32 s5, s5, s13
	s_sub_i32 s15, s21, s15
	s_xor_b32 s13, s20, s7
	s_add_i32 s20, s12, 1
	s_sub_i32 s21, s15, s0
	s_cmp_ge_u32 s15, s0
	s_cselect_b32 s12, s20, s12
	s_cselect_b32 s15, s21, s15
	s_add_i32 s20, s12, 1
	s_cmp_ge_u32 s15, s0
	s_cselect_b32 s12, s20, s12
	s_abs_i32 s15, s10
	v_cvt_f32_u32_e32 v1, s15
	s_sub_i32 s20, 0, s15
	v_rcp_iflag_f32_e32 v1, v1
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	v_mul_lo_u32 v2, s20, v1
	s_abs_i32 s20, s9
	v_cvt_f32_u32_e32 v4, s20
	v_mul_hi_u32 v2, v1, v2
	v_rcp_iflag_f32_e32 v4, v4
	v_add_nc_u32_e32 v1, v1, v2
	v_mul_f32_e32 v4, 0x4f7ffffe, v4
	v_mul_hi_u32 v1, v3, v1
	v_cvt_u32_f32_e32 v4, v4
	v_mul_lo_u32 v2, v1, s15
	v_sub_nc_u32_e32 v2, v3, v2
	v_add_nc_u32_e32 v3, 1, v1
	v_subrev_nc_u32_e32 v5, s15, v2
	v_cmp_le_u32_e32 vcc_lo, s15, v2
	v_cndmask_b32_e32 v1, v1, v3, vcc_lo
	v_cndmask_b32_e32 v2, v2, v5, vcc_lo
	v_xor_b32_e32 v3, s10, v0
	v_add_nc_u32_e32 v5, 1, v1
	v_cmp_le_u32_e32 vcc_lo, s15, v2
	v_ashrrev_i32_e32 v3, 31, v3
	s_sub_i32 s15, 0, s20
	v_mul_lo_u32 v2, s15, v4
	v_cndmask_b32_e32 v1, v1, v5, vcc_lo
	v_xor_b32_e32 v1, v1, v3
	v_sub_nc_u32_e32 v3, v1, v3
	v_mul_hi_u32 v1, v4, v2
	v_sub_nc_u32_e32 v2, 0, v3
	v_add_nc_u32_e32 v1, v4, v1
	v_max_i32_e32 v2, v3, v2
	v_mul_hi_u32 v1, v2, v1
	v_mul_lo_u32 v4, v1, s20
	v_sub_nc_u32_e32 v2, v2, v4
	v_add_nc_u32_e32 v4, 1, v1
	v_subrev_nc_u32_e32 v5, s20, v2
	v_cmp_le_u32_e32 vcc_lo, s20, v2
	v_cndmask_b32_e32 v1, v1, v4, vcc_lo
	v_cndmask_b32_e32 v2, v2, v5, vcc_lo
	v_xor_b32_e32 v4, s9, v3
	v_add_nc_u32_e32 v5, 1, v1
	v_cmp_le_u32_e32 vcc_lo, s20, v2
	v_ashrrev_i32_e32 v4, 31, v4
	v_cndmask_b32_e32 v1, v1, v5, vcc_lo
	v_xor_b32_e32 v1, v1, v4
	v_sub_nc_u32_e32 v1, v1, v4
	v_mul_lo_u32 v4, v3, s10
	v_mul_lo_u32 v2, v1, s9
	s_lshr_b32 s9, s14, 31
	s_add_i32 s9, s14, s9
	s_ashr_i32 s9, s9, 1
	v_sub_nc_u32_e32 v2, v3, v2
	v_sub_nc_u32_e32 v3, v0, v4
	v_add_nc_u32_e32 v2, s9, v2
	v_add_nc_u32_e32 v3, s9, v3
	v_sub_nc_u32_e32 v4, 0, v2
	v_sub_nc_u32_e32 v5, 0, v3
	v_ashrrev_i32_e32 v11, 31, v2
	v_max_i32_e32 v4, v2, v4
	v_max_i32_e32 v5, v3, v5
	v_mad_u64_u32 v[1:2], null, v1, s5, v[1:2]
	v_xor_b32_e32 v2, s7, v11
	v_mul_hi_u32 v6, v4, s11
	v_mul_hi_u32 v7, v5, s11
	v_ashrrev_i32_e32 v3, 31, v3
	v_xor_b32_e32 v3, s7, v3
	v_mul_lo_u32 v8, v6, s0
	v_mul_lo_u32 v9, v7, s0
	v_sub_nc_u32_e32 v4, v4, v8
	v_add_nc_u32_e32 v8, 1, v6
	v_sub_nc_u32_e32 v5, v5, v9
	v_subrev_nc_u32_e32 v9, s0, v4
	v_cmp_le_u32_e32 vcc_lo, s0, v4
	v_subrev_nc_u32_e32 v10, s0, v5
	v_cndmask_b32_e32 v6, v6, v8, vcc_lo
	v_cndmask_b32_e32 v4, v4, v9, vcc_lo
	v_add_nc_u32_e32 v8, 1, v7
	v_add_nc_u32_e32 v9, 1, v6
	v_cmp_le_u32_e32 vcc_lo, s0, v4
	v_cndmask_b32_e32 v4, v6, v9, vcc_lo
	v_cmp_le_u32_e32 vcc_lo, s0, v5
	v_xor_b32_e32 v4, v4, v2
	v_cndmask_b32_e32 v6, v7, v8, vcc_lo
	v_cndmask_b32_e32 v5, v5, v10, vcc_lo
	v_add3_u32 v1, v4, s6, v1
	v_add_nc_u32_e32 v7, 1, v6
	v_cmp_le_u32_e32 vcc_lo, s0, v5
	s_xor_b32 s0, s12, s13
	v_sub_nc_u32_e32 v4, v4, v2
	v_subrev_nc_u32_e32 v1, s8, v1
	s_sub_i32 s7, s0, s13
	v_cndmask_b32_e32 v5, v6, v7, vcc_lo
	s_add_i32 s9, s7, 1
	s_lshl_b32 s0, s8, 1
	v_sub_nc_u32_e32 v1, v1, v2
	v_xad_u32 v5, v5, v3, s6
	s_lshl_b32 s6, s6, 1
	s_sub_i32 s0, s0, s6
	v_subrev_nc_u32_e32 v6, s8, v5
	v_mul_lo_u32 v5, v1, s9
	s_or_b32 s6, s0, 1
	v_sub_nc_u32_e32 v6, v6, v3
	v_mov_b32_e32 v3, 0
.LBB29_3:                               ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB29_6 Depth 2
	v_add_nc_u32_e32 v1, s4, v4
	v_mov_b32_e32 v7, v6
	s_mov_b32 s10, s6
	v_cmp_lt_i32_e32 vcc_lo, -1, v1
	v_cmp_ge_i32_e64 s0, s5, v1
	s_and_b32 s8, vcc_lo, s0
	s_inst_prefetch 0x1
	s_branch .LBB29_6
	.p2align	6
.LBB29_4:                               ;   in Loop: Header=BB29_6 Depth=2
	s_or_b32 exec_lo, exec_lo, s11
.LBB29_5:                               ;   in Loop: Header=BB29_6 Depth=2
	s_or_b32 exec_lo, exec_lo, s0
	s_waitcnt vmcnt(0)
	v_add_f32_e32 v3, v3, v8
	v_add_nc_u32_e32 v7, 1, v7
	s_add_i32 s10, s10, -1
	s_cmp_eq_u32 s10, 0
	s_cbranch_scc1 .LBB29_9
.LBB29_6:                               ;   Parent Loop BB29_3 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	v_cmp_lt_i32_e32 vcc_lo, -1, v7
	v_cmp_ge_i32_e64 s0, s7, v7
	v_mov_b32_e32 v8, 0
	s_and_b32 s0, vcc_lo, s0
	s_and_b32 s11, s0, s8
	s_and_saveexec_b32 s0, s11
	s_cbranch_execz .LBB29_5
; %bb.7:                                ;   in Loop: Header=BB29_6 Depth=2
	v_add_nc_u32_e32 v1, v5, v7
	v_ashrrev_i32_e32 v2, 31, v1
	v_lshlrev_b64 v[1:2], 2, v[1:2]
	s_waitcnt lgkmcnt(0)
	v_add_co_u32 v8, vcc_lo, s2, v1
	v_add_co_ci_u32_e64 v9, null, s3, v2, vcc_lo
	global_load_dword v8, v[8:9], off
	s_waitcnt vmcnt(0)
	v_cmp_eq_u32_e32 vcc_lo, v8, v0
	v_mov_b32_e32 v8, 0
	s_and_saveexec_b32 s11, vcc_lo
	s_cbranch_execz .LBB29_4
; %bb.8:                                ;   in Loop: Header=BB29_6 Depth=2
	v_add_co_u32 v1, vcc_lo, s16, v1
	v_add_co_ci_u32_e64 v2, null, s17, v2, vcc_lo
	global_load_dword v8, v[1:2], off
	s_branch .LBB29_4
.LBB29_9:                               ;   in Loop: Header=BB29_3 Depth=1
	s_inst_prefetch 0x2
	v_add_nc_u32_e32 v5, s9, v5
	s_add_i32 s0, s4, 1
	s_cmp_eq_u32 s4, s1
	s_cbranch_scc1 .LBB29_11
; %bb.10:                               ;   in Loop: Header=BB29_3 Depth=1
	s_mov_b32 s4, s0
	s_branch .LBB29_3
.LBB29_11:
	v_ashrrev_i32_e32 v1, 31, v0
	v_lshlrev_b64 v[0:1], 2, v[0:1]
	s_waitcnt lgkmcnt(0)
	v_add_co_u32 v0, vcc_lo, s18, v0
	v_add_co_ci_u32_e64 v1, null, s19, v1, vcc_lo
	global_load_dword v2, v[0:1], off
	s_waitcnt vmcnt(0)
	v_add_f32_e32 v2, v3, v2
	global_store_dword v[0:1], v2, off
.LBB29_12:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel backward_maxpool_kernel
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 312
		.amdhsa_user_sgpr_count 6
		.amdhsa_user_sgpr_private_segment_buffer 1
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_flat_scratch_init 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_wavefront_size32 1
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_system_sgpr_private_segment_wavefront_offset 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 12
		.amdhsa_next_free_sgpr 23
		.amdhsa_reserve_vcc 1
		.amdhsa_reserve_flat_scratch 0
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 3
		.amdhsa_float_denorm_mode_16_64 3
		.amdhsa_dx10_clamp 1
		.amdhsa_ieee_mode 1
		.amdhsa_fp16_overflow 0
		.amdhsa_workgroup_processor_mode 1
		.amdhsa_memory_ordered 1
		.amdhsa_forward_progress 1
		.amdhsa_shared_vgpr_count 0
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.text
.Lfunc_end29:
	.size	backward_maxpool_kernel, .Lfunc_end29-backward_maxpool_kernel
                                        ; -- End function
	.set backward_maxpool_kernel.num_vgpr, 12
	.set backward_maxpool_kernel.num_agpr, 0
	.set backward_maxpool_kernel.numbered_sgpr, 23
	.set backward_maxpool_kernel.num_named_barrier, 0
	.set backward_maxpool_kernel.private_seg_size, 0
	.set backward_maxpool_kernel.uses_vcc, 1
	.set backward_maxpool_kernel.uses_flat_scratch, 0
	.set backward_maxpool_kernel.has_dyn_sized_stack, 0
	.set backward_maxpool_kernel.has_recursion, 0
	.set backward_maxpool_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 1140
; TotalNumSgprs: 25
; NumVgprs: 12
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 0
; VGPRBlocks: 1
; NumSGPRsForWavesPerEU: 25
; NumVGPRsForWavesPerEU: 12
; Occupancy: 16
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 6
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
	.text
	.protected	forward_avgpool_kernel  ; -- Begin function forward_avgpool_kernel
	.globl	forward_avgpool_kernel
	.p2align	8
	.type	forward_avgpool_kernel,@function
forward_avgpool_kernel:                 ; @forward_avgpool_kernel
; %bb.0:
	s_clause 0x1
	s_load_dword s0, s[4:5], 0x2c
	s_load_dwordx4 s[8:11], s[4:5], 0x0
	s_waitcnt lgkmcnt(0)
	s_and_b32 s0, s0, 0xffff
	v_mad_u64_u32 v[0:1], null, s6, s0, v[0:1]
	s_mov_b32 s0, exec_lo
	v_cmpx_gt_i32_e64 s8, v0
	s_cbranch_execz .LBB30_6
; %bb.1:
	s_load_dwordx4 s[0:3], s[4:5], 0x10
	s_mul_i32 s4, s10, s9
	s_cmp_lt_i32 s4, 1
	s_cbranch_scc1 .LBB30_4
; %bb.2:
	v_mul_lo_u32 v1, v0, s4
	v_mov_b32_e32 v3, 0
	v_ashrrev_i32_e32 v2, 31, v1
	v_lshlrev_b64 v[1:2], 2, v[1:2]
	s_waitcnt lgkmcnt(0)
	v_add_co_u32 v1, vcc_lo, s0, v1
	v_add_co_ci_u32_e64 v2, null, s1, v2, vcc_lo
	s_mov_b32 s0, s4
.LBB30_3:                               ; =>This Inner Loop Header: Depth=1
	global_load_dword v4, v[1:2], off
	v_add_co_u32 v1, vcc_lo, v1, 4
	v_add_co_ci_u32_e64 v2, null, 0, v2, vcc_lo
	s_add_i32 s0, s0, -1
	s_cmp_eq_u32 s0, 0
	s_waitcnt vmcnt(0)
	v_add_f32_e32 v3, v3, v4
	s_cbranch_scc0 .LBB30_3
	s_branch .LBB30_5
.LBB30_4:
	v_mov_b32_e32 v3, 0
.LBB30_5:
	v_cvt_f32_i32_e32 v2, s4
	v_div_scale_f32 v1, null, v2, v2, v3
	v_div_scale_f32 v6, vcc_lo, v3, v2, v3
	v_rcp_f32_e32 v4, v1
	v_fma_f32 v5, -v1, v4, 1.0
	v_fmac_f32_e32 v4, v5, v4
	v_mul_f32_e32 v5, v6, v4
	v_fma_f32 v7, -v1, v5, v6
	v_fmac_f32_e32 v5, v7, v4
	v_fma_f32 v6, -v1, v5, v6
	v_ashrrev_i32_e32 v1, 31, v0
	v_div_fmas_f32 v4, v6, v4, v5
	v_lshlrev_b64 v[0:1], 2, v[0:1]
	v_div_fixup_f32 v2, v4, v2, v3
	s_waitcnt lgkmcnt(0)
	v_add_co_u32 v0, vcc_lo, s2, v0
	v_add_co_ci_u32_e64 v1, null, s3, v1, vcc_lo
	global_store_dword v[0:1], v2, off
.LBB30_6:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel forward_avgpool_kernel
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 288
		.amdhsa_user_sgpr_count 6
		.amdhsa_user_sgpr_private_segment_buffer 1
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_flat_scratch_init 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_wavefront_size32 1
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_system_sgpr_private_segment_wavefront_offset 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 8
		.amdhsa_next_free_sgpr 12
		.amdhsa_reserve_vcc 1
		.amdhsa_reserve_flat_scratch 0
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 3
		.amdhsa_float_denorm_mode_16_64 3
		.amdhsa_dx10_clamp 1
		.amdhsa_ieee_mode 1
		.amdhsa_fp16_overflow 0
		.amdhsa_workgroup_processor_mode 1
		.amdhsa_memory_ordered 1
		.amdhsa_forward_progress 1
		.amdhsa_shared_vgpr_count 0
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.text
.Lfunc_end30:
	.size	forward_avgpool_kernel, .Lfunc_end30-forward_avgpool_kernel
                                        ; -- End function
	.set forward_avgpool_kernel.num_vgpr, 8
	.set forward_avgpool_kernel.num_agpr, 0
	.set forward_avgpool_kernel.numbered_sgpr, 12
	.set forward_avgpool_kernel.num_named_barrier, 0
	.set forward_avgpool_kernel.private_seg_size, 0
	.set forward_avgpool_kernel.uses_vcc, 1
	.set forward_avgpool_kernel.uses_flat_scratch, 0
	.set forward_avgpool_kernel.has_dyn_sized_stack, 0
	.set forward_avgpool_kernel.has_recursion, 0
	.set forward_avgpool_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 296
; TotalNumSgprs: 14
; NumVgprs: 8
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 0
; VGPRBlocks: 0
; NumSGPRsForWavesPerEU: 14
; NumVGPRsForWavesPerEU: 8
; Occupancy: 16
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 6
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
	.text
	.protected	backward_avgpool_kernel ; -- Begin function backward_avgpool_kernel
	.globl	backward_avgpool_kernel
	.p2align	8
	.type	backward_avgpool_kernel,@function
backward_avgpool_kernel:                ; @backward_avgpool_kernel
; %bb.0:
	s_clause 0x1
	s_load_dword s7, s[4:5], 0x2c
	s_load_dwordx4 s[0:3], s[4:5], 0x0
	s_waitcnt lgkmcnt(0)
	s_and_b32 s3, s7, 0xffff
	v_mad_u64_u32 v[0:1], null, s6, s3, v[0:1]
	v_cmp_gt_i32_e32 vcc_lo, s0, v0
	s_and_saveexec_b32 s0, vcc_lo
	s_cbranch_execz .LBB31_4
; %bb.1:
	s_mul_i32 s0, s2, s1
	s_cmp_lt_i32 s0, 1
	s_cbranch_scc1 .LBB31_4
; %bb.2:
	s_load_dwordx4 s[4:7], s[4:5], 0x10
	v_ashrrev_i32_e32 v1, 31, v0
	v_cvt_f32_i32_e32 v3, s0
	v_lshlrev_b64 v[1:2], 2, v[0:1]
	v_mul_lo_u32 v0, v0, s0
	s_waitcnt lgkmcnt(0)
	v_add_co_u32 v1, vcc_lo, s6, v1
	v_add_co_ci_u32_e64 v2, null, s7, v2, vcc_lo
	global_load_dword v2, v[1:2], off
	s_waitcnt vmcnt(0)
	v_div_scale_f32 v1, null, v3, v3, v2
	v_div_scale_f32 v6, vcc_lo, v2, v3, v2
	v_rcp_f32_e32 v4, v1
	v_fma_f32 v5, -v1, v4, 1.0
	v_fmac_f32_e32 v4, v5, v4
	v_mul_f32_e32 v5, v6, v4
	v_fma_f32 v7, -v1, v5, v6
	v_fmac_f32_e32 v5, v7, v4
	v_fma_f32 v6, -v1, v5, v6
	v_ashrrev_i32_e32 v1, 31, v0
	v_div_fmas_f32 v4, v6, v4, v5
	v_lshlrev_b64 v[0:1], 2, v[0:1]
	v_div_fixup_f32 v2, v4, v3, v2
	v_add_co_u32 v0, vcc_lo, s4, v0
	v_add_co_ci_u32_e64 v1, null, s5, v1, vcc_lo
.LBB31_3:                               ; =>This Inner Loop Header: Depth=1
	global_load_dword v3, v[0:1], off
	s_add_i32 s0, s0, -1
	s_cmp_lg_u32 s0, 0
	s_waitcnt vmcnt(0)
	v_add_f32_e32 v3, v2, v3
	global_store_dword v[0:1], v3, off
	v_add_co_u32 v0, vcc_lo, v0, 4
	v_add_co_ci_u32_e64 v1, null, 0, v1, vcc_lo
	s_cbranch_scc1 .LBB31_3
.LBB31_4:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel backward_avgpool_kernel
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 288
		.amdhsa_user_sgpr_count 6
		.amdhsa_user_sgpr_private_segment_buffer 1
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_flat_scratch_init 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_wavefront_size32 1
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_system_sgpr_private_segment_wavefront_offset 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 8
		.amdhsa_next_free_sgpr 8
		.amdhsa_reserve_vcc 1
		.amdhsa_reserve_flat_scratch 0
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 3
		.amdhsa_float_denorm_mode_16_64 3
		.amdhsa_dx10_clamp 1
		.amdhsa_ieee_mode 1
		.amdhsa_fp16_overflow 0
		.amdhsa_workgroup_processor_mode 1
		.amdhsa_memory_ordered 1
		.amdhsa_forward_progress 1
		.amdhsa_shared_vgpr_count 0
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.text
.Lfunc_end31:
	.size	backward_avgpool_kernel, .Lfunc_end31-backward_avgpool_kernel
                                        ; -- End function
	.set backward_avgpool_kernel.num_vgpr, 8
	.set backward_avgpool_kernel.num_agpr, 0
	.set backward_avgpool_kernel.numbered_sgpr, 8
	.set backward_avgpool_kernel.num_named_barrier, 0
	.set backward_avgpool_kernel.private_seg_size, 0
	.set backward_avgpool_kernel.uses_vcc, 1
	.set backward_avgpool_kernel.uses_flat_scratch, 0
	.set backward_avgpool_kernel.has_dyn_sized_stack, 0
	.set backward_avgpool_kernel.has_recursion, 0
	.set backward_avgpool_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 284
; TotalNumSgprs: 10
; NumVgprs: 8
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 0
; VGPRBlocks: 0
; NumSGPRsForWavesPerEU: 10
; NumVGPRsForWavesPerEU: 8
; Occupancy: 16
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 6
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
	.text
	.protected	dropout_kernel          ; -- Begin function dropout_kernel
	.globl	dropout_kernel
	.p2align	8
	.type	dropout_kernel,@function
dropout_kernel:                         ; @dropout_kernel
; %bb.0:
	s_clause 0x1
	s_load_dword s0, s[4:5], 0x2c
	s_load_dword s1, s[4:5], 0x8
	s_waitcnt lgkmcnt(0)
	s_and_b32 s0, s0, 0xffff
	v_mad_u64_u32 v[0:1], null, s6, s0, v[0:1]
	s_mov_b32 s0, exec_lo
	v_cmpx_gt_i32_e64 s1, v0
	s_cbranch_execz .LBB32_4
; %bb.1:
	s_load_dwordx4 s[0:3], s[4:5], 0x10
	v_ashrrev_i32_e32 v1, 31, v0
	v_lshlrev_b64 v[0:1], 2, v[0:1]
	s_waitcnt lgkmcnt(0)
	v_add_co_u32 v2, vcc_lo, s0, v0
	v_add_co_ci_u32_e64 v3, null, s1, v1, vcc_lo
	s_load_dwordx2 s[0:1], s[4:5], 0x0
	global_load_dword v2, v[2:3], off
	s_waitcnt vmcnt(0)
	v_cmp_ngt_f32_e32 vcc_lo, s2, v2
	v_mov_b32_e32 v2, 0
	s_and_saveexec_b32 s2, vcc_lo
	s_cbranch_execz .LBB32_3
; %bb.2:
	s_waitcnt lgkmcnt(0)
	v_add_co_u32 v2, vcc_lo, s0, v0
	v_add_co_ci_u32_e64 v3, null, s1, v1, vcc_lo
	global_load_dword v2, v[2:3], off
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v2, s3, v2
.LBB32_3:
	s_or_b32 exec_lo, exec_lo, s2
	s_waitcnt lgkmcnt(0)
	v_add_co_u32 v0, vcc_lo, s0, v0
	v_add_co_ci_u32_e64 v1, null, s1, v1, vcc_lo
	global_store_dword v[0:1], v2, off
.LBB32_4:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel dropout_kernel
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 288
		.amdhsa_user_sgpr_count 6
		.amdhsa_user_sgpr_private_segment_buffer 1
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_flat_scratch_init 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_wavefront_size32 1
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_system_sgpr_private_segment_wavefront_offset 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 4
		.amdhsa_next_free_sgpr 7
		.amdhsa_reserve_vcc 1
		.amdhsa_reserve_flat_scratch 0
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 3
		.amdhsa_float_denorm_mode_16_64 3
		.amdhsa_dx10_clamp 1
		.amdhsa_ieee_mode 1
		.amdhsa_fp16_overflow 0
		.amdhsa_workgroup_processor_mode 1
		.amdhsa_memory_ordered 1
		.amdhsa_forward_progress 1
		.amdhsa_shared_vgpr_count 0
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.text
.Lfunc_end32:
	.size	dropout_kernel, .Lfunc_end32-dropout_kernel
                                        ; -- End function
	.set dropout_kernel.num_vgpr, 4
	.set dropout_kernel.num_agpr, 0
	.set dropout_kernel.numbered_sgpr, 7
	.set dropout_kernel.num_named_barrier, 0
	.set dropout_kernel.private_seg_size, 0
	.set dropout_kernel.uses_vcc, 1
	.set dropout_kernel.uses_flat_scratch, 0
	.set dropout_kernel.has_dyn_sized_stack, 0
	.set dropout_kernel.has_recursion, 0
	.set dropout_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 204
; TotalNumSgprs: 9
; NumVgprs: 4
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 0
; VGPRBlocks: 0
; NumSGPRsForWavesPerEU: 9
; NumVGPRsForWavesPerEU: 4
; Occupancy: 16
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 6
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
	.text
	.protected	shortcut_kernel         ; -- Begin function shortcut_kernel
	.globl	shortcut_kernel
	.p2align	8
	.type	shortcut_kernel,@function
shortcut_kernel:                        ; @shortcut_kernel
; %bb.0:
	s_clause 0x1
	s_load_dword s0, s[4:5], 0x5c
	s_load_dwordx8 s[8:15], s[4:5], 0x0
	s_waitcnt lgkmcnt(0)
	s_and_b32 s0, s0, 0xffff
	v_mad_u64_u32 v[0:1], null, s6, s0, v[0:1]
	s_mov_b32 s0, exec_lo
	v_cmpx_gt_i32_e64 s8, v0
	s_cbranch_execz .LBB33_2
; %bb.1:
	s_abs_i32 s0, s9
	v_sub_nc_u32_e32 v3, 0, v0
	v_cvt_f32_u32_e32 v1, s0
	s_sub_i32 s1, 0, s0
	s_load_dwordx8 s[16:23], s[4:5], 0x20
	v_max_i32_e32 v3, v0, v3
	v_rcp_iflag_f32_e32 v1, v1
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	v_mul_lo_u32 v2, s1, v1
	s_abs_i32 s1, s10
	v_cvt_f32_u32_e32 v4, s1
	v_rcp_iflag_f32_e32 v4, v4
	v_mul_hi_u32 v2, v1, v2
	v_add_nc_u32_e32 v1, v1, v2
	v_mul_f32_e32 v4, 0x4f7ffffe, v4
	v_mul_hi_u32 v1, v3, v1
	v_cvt_u32_f32_e32 v4, v4
	v_mul_lo_u32 v2, v1, s0
	v_sub_nc_u32_e32 v2, v3, v2
	v_add_nc_u32_e32 v3, 1, v1
	v_subrev_nc_u32_e32 v5, s0, v2
	v_cmp_le_u32_e32 vcc_lo, s0, v2
	v_cndmask_b32_e32 v1, v1, v3, vcc_lo
	v_cndmask_b32_e32 v2, v2, v5, vcc_lo
	v_xor_b32_e32 v3, s9, v0
	v_add_nc_u32_e32 v5, 1, v1
	v_cmp_le_u32_e32 vcc_lo, s0, v2
	v_ashrrev_i32_e32 v3, 31, v3
	s_sub_i32 s0, 0, s1
	v_mul_lo_u32 v2, s0, v4
	v_cndmask_b32_e32 v1, v1, v5, vcc_lo
	s_abs_i32 s0, s11
	v_cvt_f32_u32_e32 v5, s0
	v_xor_b32_e32 v1, v1, v3
	v_mul_hi_u32 v2, v4, v2
	v_rcp_iflag_f32_e32 v5, v5
	v_sub_nc_u32_e32 v1, v1, v3
	v_add_nc_u32_e32 v2, v4, v2
	v_sub_nc_u32_e32 v3, 0, v1
	v_max_i32_e32 v3, v1, v3
	v_mul_hi_u32 v2, v3, v2
	v_mul_lo_u32 v4, v2, s1
	v_sub_nc_u32_e32 v3, v3, v4
	v_add_nc_u32_e32 v4, 1, v2
	v_subrev_nc_u32_e32 v6, s1, v3
	v_cmp_le_u32_e32 vcc_lo, s1, v3
	v_cndmask_b32_e32 v2, v2, v4, vcc_lo
	v_cndmask_b32_e32 v3, v3, v6, vcc_lo
	v_mul_f32_e32 v4, 0x4f7ffffe, v5
	v_xor_b32_e32 v5, s10, v1
	v_add_nc_u32_e32 v6, 1, v2
	v_cmp_le_u32_e32 vcc_lo, s1, v3
	v_cvt_u32_f32_e32 v4, v4
	v_ashrrev_i32_e32 v5, 31, v5
	s_sub_i32 s1, 0, s0
	v_cndmask_b32_e32 v2, v2, v6, vcc_lo
	v_mul_lo_u32 v3, s1, v4
	s_abs_i32 s1, s14
	v_cvt_f32_u32_e32 v6, s1
	v_xor_b32_e32 v2, v2, v5
	v_mul_hi_u32 v3, v4, v3
	v_sub_nc_u32_e32 v2, v2, v5
	v_rcp_iflag_f32_e32 v6, v6
	v_sub_nc_u32_e32 v5, 0, v2
	v_add_nc_u32_e32 v3, v4, v3
	v_max_i32_e32 v4, v2, v5
	v_mul_hi_u32 v3, v4, v3
	v_mul_lo_u32 v5, v3, s0
	v_sub_nc_u32_e32 v4, v4, v5
	v_add_nc_u32_e32 v5, 1, v3
	v_subrev_nc_u32_e32 v7, s0, v4
	v_cmp_le_u32_e32 vcc_lo, s0, v4
	v_cndmask_b32_e32 v3, v3, v5, vcc_lo
	v_cndmask_b32_e32 v4, v4, v7, vcc_lo
	v_mul_f32_e32 v5, 0x4f7ffffe, v6
	v_xor_b32_e32 v6, s11, v2
	v_add_nc_u32_e32 v7, 1, v3
	v_cmp_le_u32_e32 vcc_lo, s0, v4
	v_cvt_u32_f32_e32 v5, v5
	v_ashrrev_i32_e32 v6, 31, v6
	s_sub_i32 s0, 0, s1
	v_cndmask_b32_e32 v3, v3, v7, vcc_lo
	v_mul_lo_u32 v4, s0, v5
	v_xor_b32_e32 v3, v3, v6
	v_mul_hi_u32 v4, v5, v4
	v_sub_nc_u32_e32 v3, v3, v6
	v_sub_nc_u32_e32 v6, 0, v3
	v_ashrrev_i32_e32 v7, 31, v3
	v_add_nc_u32_e32 v4, v5, v4
	v_max_i32_e32 v5, v3, v6
	v_mul_lo_u32 v6, v2, s10
	v_mul_lo_u32 v3, v3, s11
	v_mul_hi_u32 v4, v5, v4
	v_sub_nc_u32_e32 v6, v1, v6
	v_mul_lo_u32 v4, v4, s1
	v_sub_nc_u32_e32 v4, v5, v4
	v_subrev_nc_u32_e32 v5, s1, v4
	v_cmp_le_u32_e32 vcc_lo, s1, v4
	v_cndmask_b32_e32 v4, v4, v5, vcc_lo
	v_subrev_nc_u32_e32 v5, s1, v4
	v_cmp_le_u32_e32 vcc_lo, s1, v4
	s_load_dwordx2 s[0:1], s[4:5], 0x48
	v_cndmask_b32_e32 v4, v4, v5, vcc_lo
	v_mul_lo_u32 v5, v1, s9
	v_sub_nc_u32_e32 v1, v2, v3
	v_mul_lo_u32 v2, v6, s12
	v_xor_b32_e32 v4, v4, v7
	v_sub_nc_u32_e32 v8, v0, v5
	v_sub_nc_u32_e32 v7, v4, v7
	v_mul_lo_u32 v0, v6, s13
	s_waitcnt lgkmcnt(0)
	v_mad_u64_u32 v[3:4], null, v7, s17, v[1:2]
	v_mad_u64_u32 v[4:5], null, v7, s22, v[1:2]
	v_mul_lo_u32 v1, v8, s12
	v_mad_u64_u32 v[2:3], null, v3, s16, v[2:3]
	v_mul_lo_u32 v3, v8, s13
	v_mad_u64_u32 v[4:5], null, v4, s21, v[0:1]
	v_mad_u64_u32 v[0:1], null, v2, s15, v[1:2]
	v_mad_u64_u32 v[2:3], null, v4, s20, v[3:4]
	v_ashrrev_i32_e32 v1, 31, v0
	v_ashrrev_i32_e32 v3, 31, v2
	v_lshlrev_b64 v[0:1], 2, v[0:1]
	v_lshlrev_b64 v[2:3], 2, v[2:3]
	v_add_co_u32 v0, vcc_lo, s18, v0
	v_add_co_ci_u32_e64 v1, null, s19, v1, vcc_lo
	v_add_co_u32 v2, vcc_lo, s0, v2
	v_add_co_ci_u32_e64 v3, null, s1, v3, vcc_lo
	global_load_dword v0, v[0:1], off
	global_load_dword v1, v[2:3], off
	s_load_dword s0, s[4:5], 0x40
	s_waitcnt vmcnt(1) lgkmcnt(0)
	v_mul_f32_e32 v0, s0, v0
	s_waitcnt vmcnt(0)
	v_fmac_f32_e32 v0, s23, v1
	global_store_dword v[2:3], v0, off
.LBB33_2:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel shortcut_kernel
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 336
		.amdhsa_user_sgpr_count 6
		.amdhsa_user_sgpr_private_segment_buffer 1
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_flat_scratch_init 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_wavefront_size32 1
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_system_sgpr_private_segment_wavefront_offset 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 9
		.amdhsa_next_free_sgpr 24
		.amdhsa_reserve_vcc 1
		.amdhsa_reserve_flat_scratch 0
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 3
		.amdhsa_float_denorm_mode_16_64 3
		.amdhsa_dx10_clamp 1
		.amdhsa_ieee_mode 1
		.amdhsa_fp16_overflow 0
		.amdhsa_workgroup_processor_mode 1
		.amdhsa_memory_ordered 1
		.amdhsa_forward_progress 1
		.amdhsa_shared_vgpr_count 0
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.text
.Lfunc_end33:
	.size	shortcut_kernel, .Lfunc_end33-shortcut_kernel
                                        ; -- End function
	.set shortcut_kernel.num_vgpr, 9
	.set shortcut_kernel.num_agpr, 0
	.set shortcut_kernel.numbered_sgpr, 24
	.set shortcut_kernel.num_named_barrier, 0
	.set shortcut_kernel.private_seg_size, 0
	.set shortcut_kernel.uses_vcc, 1
	.set shortcut_kernel.uses_flat_scratch, 0
	.set shortcut_kernel.has_dyn_sized_stack, 0
	.set shortcut_kernel.has_recursion, 0
	.set shortcut_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 784
; TotalNumSgprs: 26
; NumVgprs: 9
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 0
; VGPRBlocks: 1
; NumSGPRsForWavesPerEU: 26
; NumVGPRsForWavesPerEU: 9
; Occupancy: 16
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 6
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
	.text
	.protected	adam_kernel             ; -- Begin function adam_kernel
	.globl	adam_kernel
	.p2align	8
	.type	adam_kernel,@function
adam_kernel:                            ; @adam_kernel
; %bb.0:
	s_clause 0x1
	s_load_dword s0, s[4:5], 0x44
	s_load_dword s1, s[4:5], 0x0
	s_waitcnt lgkmcnt(0)
	s_and_b32 s0, s0, 0xffff
	v_mad_u64_u32 v[0:1], null, s6, s0, v[0:1]
	s_mov_b32 s0, exec_lo
	v_cmpx_gt_i32_e64 s1, v0
	s_cbranch_execz .LBB34_2
; %bb.1:
	s_clause 0x3
	s_load_dword s0, s[4:5], 0x30
	s_load_dwordx4 s[8:11], s[4:5], 0x20
	s_load_dwordx4 s[12:15], s[4:5], 0x8
	s_load_dwordx2 s[2:3], s[4:5], 0x18
	s_waitcnt lgkmcnt(0)
	v_cvt_f32_i32_e32 v1, s0
	v_cmp_neq_f32_e64 vcc_lo, s8, 1.0
	v_cndmask_b32_e32 v2, 1.0, v1, vcc_lo
	v_cmp_neq_f32_e64 vcc_lo, s9, 1.0
	v_cndmask_b32_e32 v7, 1.0, v1, vcc_lo
	v_cmp_neq_f32_e32 vcc_lo, 0, v2
	v_cndmask_b32_e64 v3, 1.0, s8, vcc_lo
	v_cmp_neq_f32_e32 vcc_lo, 0, v7
	v_frexp_mant_f32_e64 v1, |v3|
	v_cndmask_b32_e64 v4, 1.0, s9, vcc_lo
	v_cmp_class_f32_e64 s7, v3, 0x204
	v_cmp_gt_f32_e32 vcc_lo, 0x3f2aaaab, v1
	v_frexp_mant_f32_e64 v5, |v4|
	v_cmp_eq_f32_e64 s4, 0, v4
	v_cndmask_b32_e64 v6, 1.0, 2.0, vcc_lo
	v_cmp_gt_f32_e64 s0, 0x3f2aaaab, v5
	v_mul_f32_e32 v1, v1, v6
	v_cndmask_b32_e64 v8, 1.0, 2.0, s0
	v_add_f32_e32 v6, 1.0, v1
	v_mul_f32_e32 v5, v5, v8
	v_add_f32_e32 v11, -1.0, v1
	v_rcp_f32_e32 v9, v6
	v_add_f32_e32 v8, 1.0, v5
	v_add_f32_e32 v12, -1.0, v5
	v_add_f32_e32 v15, -1.0, v6
	v_rcp_f32_e32 v10, v8
	v_add_f32_e32 v16, -1.0, v8
	v_sub_f32_e32 v1, v1, v15
	v_mul_f32_e32 v13, v11, v9
	v_sub_f32_e32 v5, v5, v16
	v_mul_f32_e32 v17, v6, v13
	v_mul_f32_e32 v14, v12, v10
	v_fma_f32 v6, v13, v6, -v17
	v_mul_f32_e32 v18, v8, v14
	v_fmac_f32_e32 v6, v13, v1
	v_fma_f32 v8, v14, v8, -v18
	v_add_f32_e32 v1, v17, v6
	v_fmac_f32_e32 v8, v14, v5
	v_sub_f32_e32 v15, v11, v1
	v_add_f32_e32 v5, v18, v8
	v_sub_f32_e32 v17, v1, v17
	v_sub_f32_e32 v11, v11, v15
	v_sub_f32_e32 v16, v12, v5
	v_sub_f32_e32 v18, v5, v18
	v_sub_f32_e32 v6, v17, v6
	v_sub_f32_e32 v11, v11, v1
	v_sub_f32_e32 v12, v12, v16
	v_sub_f32_e32 v8, v18, v8
	v_ashrrev_i32_e32 v1, 31, v0
	v_add_f32_e32 v6, v6, v11
	v_sub_f32_e32 v5, v12, v5
	v_lshlrev_b64 v[0:1], 2, v[0:1]
	v_add_f32_e32 v5, v8, v5
	v_add_f32_e32 v8, v15, v6
	v_add_f32_e32 v11, v16, v5
	v_mul_f32_e32 v12, v9, v8
	v_add_co_u32 v5, s1, s14, v0
	v_add_co_ci_u32_e64 v6, null, s15, v1, s1
	v_add_co_u32 v8, s1, s2, v0
	v_mul_f32_e32 v10, v10, v11
	v_add_co_ci_u32_e64 v9, null, s3, v1, s1
	v_add_f32_e32 v15, v13, v12
	global_load_dword v5, v[5:6], off
	v_add_f32_e32 v16, v14, v10
	global_load_dword v6, v[8:9], off
	s_mov_b32 s1, 0x3e76c4e1
	v_sub_f32_e32 v8, v15, v13
	v_mul_f32_e32 v13, v15, v15
	v_sub_f32_e32 v9, v16, v14
	v_mul_f32_e32 v14, v16, v16
	v_cmp_eq_f32_e64 s2, 0, v3
	v_sub_f32_e32 v12, v12, v8
	v_fma_f32 v18, v15, v15, -v13
	v_sub_f32_e32 v17, v10, v9
	v_fma_f32 v19, v16, v16, -v14
	v_cvt_f64_f32_e64 v[10:11], |v4|
	v_add_f32_e32 v8, v12, v12
	v_add_f32_e32 v9, v17, v17
	v_fmac_f32_e32 v18, v15, v8
	v_fmac_f32_e32 v19, v16, v9
	v_cvt_f64_f32_e64 v[8:9], |v3|
	v_add_f32_e32 v20, v13, v18
	v_add_f32_e32 v21, v14, v19
	v_fmaak_f32 v22, s1, v20, 0x3e91f4c4
	v_sub_f32_e32 v13, v20, v13
	v_fmaak_f32 v23, s1, v21, 0x3e91f4c4
	v_sub_f32_e32 v14, v21, v14
	v_fmaak_f32 v22, v20, v22, 0x3ecccdef
	v_sub_f32_e32 v13, v18, v13
	v_fmaak_f32 v23, v21, v23, 0x3ecccdef
	v_sub_f32_e32 v14, v19, v14
	v_frexp_exp_i32_f64_e32 v10, v[10:11]
	v_mul_f32_e32 v24, v20, v22
	v_mul_f32_e32 v11, v16, v21
	v_mul_f32_e32 v25, v21, v23
	v_fma_f32 v18, v20, v22, -v24
	v_frexp_exp_i32_f64_e32 v8, v[8:9]
	v_fma_f32 v19, v21, v23, -v25
	v_mul_f32_e32 v9, v15, v20
	v_fma_f32 v28, v21, v16, -v11
	v_fmac_f32_e32 v18, v13, v22
	v_fmac_f32_e32 v19, v14, v23
	v_fma_f32 v26, v20, v15, -v9
	v_fmac_f32_e32 v28, v21, v17
	v_add_f32_e32 v22, v24, v18
	v_ldexp_f32 v17, v17, 1
	v_add_f32_e32 v23, v25, v19
	v_fmac_f32_e32 v26, v20, v12
	v_fmac_f32_e32 v28, v14, v16
	v_sub_f32_e32 v24, v22, v24
	v_add_f32_e32 v27, 0x3f2aaaaa, v22
	v_sub_f32_e32 v25, v23, v25
	v_add_f32_e32 v29, 0x3f2aaaaa, v23
	v_fmac_f32_e32 v26, v13, v15
	v_sub_f32_e32 v18, v18, v24
	v_add_f32_e32 v24, 0xbf2aaaaa, v27
	v_sub_f32_e32 v19, v19, v25
	v_add_f32_e32 v20, 0xbf2aaaaa, v29
	v_add_f32_e32 v14, v9, v26
	v_add_f32_e32 v18, 0x31739010, v18
	v_sub_f32_e32 v22, v22, v24
	v_add_f32_e32 v13, 0x31739010, v19
	v_sub_f32_e32 v19, v23, v20
	v_add_f32_e32 v21, v11, v28
	v_sub_f32_e32 v9, v14, v9
	v_add_f32_e32 v18, v18, v22
	v_subrev_co_ci_u32_e64 v8, null, 0, v8, vcc_lo
	v_add_f32_e32 v13, v13, v19
	v_sub_f32_e32 v11, v21, v11
	v_add_f32_e32 v19, v27, v18
	v_sub_f32_e32 v9, v26, v9
	v_subrev_co_ci_u32_e64 v10, null, 0, v10, s0
	v_add_f32_e32 v20, v29, v13
	v_sub_f32_e32 v22, v27, v19
	v_mul_f32_e32 v23, v14, v19
	v_sub_f32_e32 v11, v28, v11
	v_cvt_f32_i32_e32 v8, v8
	v_sub_f32_e32 v24, v29, v20
	v_mul_f32_e32 v25, v21, v20
	v_add_f32_e32 v18, v18, v22
	v_fma_f32 v22, v14, v19, -v23
	v_ldexp_f32 v16, v16, 1
	v_add_f32_e32 v13, v13, v24
	v_fma_f32 v24, v21, v20, -v25
	v_ldexp_f32 v12, v12, 1
	v_fmac_f32_e32 v22, v14, v18
	v_add_co_u32 v0, vcc_lo, s12, v0
	v_fmac_f32_e32 v24, v21, v13
	v_add_co_ci_u32_e64 v1, null, s13, v1, vcc_lo
	v_fmac_f32_e32 v22, v9, v19
	v_cvt_f32_i32_e32 v9, v10
	v_fmac_f32_e32 v24, v11, v20
	v_ldexp_f32 v11, v15, 1
	v_mul_f32_e32 v10, 0x3f317218, v8
	v_add_f32_e32 v13, v23, v22
	v_mul_f32_e32 v14, 0x3f317218, v9
	v_add_f32_e32 v18, v25, v24
	v_fma_f32 v15, 0x3f317218, v8, -v10
	v_add_f32_e32 v19, v11, v13
	v_sub_f32_e32 v20, v13, v23
	v_sub_f32_e32 v21, v18, v25
	v_add_f32_e32 v23, v16, v18
	v_fmac_f32_e32 v15, 0xb102e308, v8
	v_sub_f32_e32 v11, v19, v11
	v_sub_f32_e32 v20, v22, v20
	v_sub_f32_e32 v21, v24, v21
	v_sub_f32_e32 v16, v23, v16
	v_sub_f32_e32 v11, v13, v11
	v_add_f32_e32 v12, v12, v20
	v_fma_f32 v13, 0x3f317218, v9, -v14
	v_sub_f32_e32 v8, v18, v16
	v_add_f32_e32 v16, v17, v21
	v_add_f32_e32 v11, v12, v11
	v_fmac_f32_e32 v13, 0xb102e308, v9
	v_add_f32_e32 v9, v10, v15
	v_add_f32_e32 v8, v16, v8
	v_add_f32_e32 v12, v19, v11
	v_add_f32_e32 v16, v14, v13
	v_sub_f32_e32 v10, v9, v10
	v_add_f32_e32 v17, v23, v8
	v_add_f32_e32 v18, v9, v12
	v_sub_f32_e32 v14, v16, v14
	v_sub_f32_e32 v10, v15, v10
	v_add_f32_e32 v20, v16, v17
	v_sub_f32_e32 v15, v12, v19
	v_sub_f32_e32 v21, v18, v9
	v_sub_f32_e32 v13, v13, v14
	v_sub_f32_e32 v22, v17, v23
	v_sub_f32_e32 v14, v20, v16
	v_sub_f32_e32 v11, v11, v15
	v_sub_f32_e32 v19, v18, v21
	v_sub_f32_e32 v12, v12, v21
	v_sub_f32_e32 v8, v8, v22
	v_sub_f32_e32 v15, v20, v14
	v_sub_f32_e32 v14, v17, v14
	v_sub_f32_e32 v9, v9, v19
	v_add_f32_e32 v19, v10, v11
	v_mul_f32_e32 v23, 0.5, v7
	v_sub_f32_e32 v15, v16, v15
	global_load_dword v16, v[0:1], off
	v_add_f32_e32 v9, v12, v9
	v_add_f32_e32 v12, v13, v8
	v_trunc_f32_e32 v28, v23
	v_add_f32_e32 v14, v14, v15
	v_sub_f32_e32 v15, v19, v10
	v_add_f32_e32 v9, v19, v9
	v_sub_f32_e32 v17, v12, v13
	v_add_f32_e32 v14, v12, v14
	v_sub_f32_e32 v19, v19, v15
	v_add_f32_e32 v21, v18, v9
	v_sub_f32_e32 v11, v11, v15
	v_sub_f32_e32 v12, v12, v17
	v_add_f32_e32 v15, v20, v14
	v_sub_f32_e32 v10, v10, v19
	v_sub_f32_e32 v18, v21, v18
	v_sub_f32_e32 v8, v8, v17
	v_sub_f32_e32 v12, v13, v12
	v_sub_f32_e32 v13, v15, v20
	v_add_f32_e32 v10, v11, v10
	v_sub_f32_e32 v9, v9, v18
	v_mul_f32_e32 v18, 0.5, v2
	v_add_f32_e32 v8, v8, v12
	v_sub_f32_e32 v11, v14, v13
	v_add_f32_e32 v9, v10, v9
	v_add_f32_e32 v8, v8, v11
	v_add_f32_e32 v10, v21, v9
	v_add_f32_e32 v11, v15, v8
	v_sub_f32_e32 v12, v10, v21
	v_mul_f32_e32 v13, v2, v10
	v_trunc_f32_e32 v21, v7
	v_sub_f32_e32 v14, v11, v15
	v_mul_f32_e32 v15, v7, v11
	v_sub_f32_e32 v9, v9, v12
	v_fma_f32 v10, v2, v10, -v13
	v_cmp_class_f32_e64 vcc_lo, v13, 0x204
	v_sub_f32_e32 v8, v8, v14
	v_fma_f32 v11, v7, v11, -v15
	v_trunc_f32_e32 v14, v2
	v_fmac_f32_e32 v10, v2, v9
	v_cmp_eq_f32_e64 s3, v21, v7
	v_fmac_f32_e32 v11, v7, v8
	v_cmp_eq_f32_e64 s1, v14, v2
	v_add_f32_e32 v8, v13, v10
	v_trunc_f32_e32 v14, v18
	v_add_f32_e32 v9, v15, v11
	v_cndmask_b32_e32 v12, v8, v13, vcc_lo
	v_cmp_class_f32_e64 vcc_lo, v15, 0x204
	v_sub_f32_e32 v8, v8, v13
	v_cmp_neq_f32_e64 s5, v14, v18
	v_cndmask_b32_e32 v17, v9, v15, vcc_lo
	v_cmp_eq_f32_e32 vcc_lo, 0x42b17218, v12
	v_sub_f32_e32 v9, v9, v15
	v_sub_f32_e32 v8, v10, v8
	s_and_b32 s5, s1, s5
	v_cmp_eq_f32_e64 s0, 0x42b17218, v17
	v_cndmask_b32_e64 v19, 0, 0x37000000, vcc_lo
	v_cmp_gt_f32_e32 vcc_lo, 0, v2
	v_sub_f32_e32 v9, v11, v9
	v_cndmask_b32_e64 v20, 0, 0x37000000, s0
	v_sub_f32_e32 v22, v12, v19
	v_cmp_gt_f32_e64 s0, 0, v7
	s_xor_b32 s6, vcc_lo, s2
	v_cmp_neq_f32_e64 vcc_lo, 0x7f800000, |v12|
	v_sub_f32_e32 v24, v17, v20
	v_mul_f32_e32 v2, 0x3fb8aa3b, v22
	v_cndmask_b32_e64 v13, 0x7f800000, 0, s6
	s_xor_b32 s0, s0, s4
	v_cndmask_b32_e32 v8, 0, v8, vcc_lo
	v_mul_f32_e32 v25, 0x3fb8aa3b, v24
	v_fma_f32 v26, 0x3fb8aa3b, v22, -v2
	v_rndne_f32_e32 v27, v2
	v_cmp_neq_f32_e64 vcc_lo, 0x7f800000, |v17|
	v_add_f32_e32 v8, v19, v8
	v_fma_f32 v7, 0x3fb8aa3b, v24, -v25
	v_rndne_f32_e32 v21, v25
	v_fmac_f32_e32 v26, 0x32a5705f, v22
	v_sub_f32_e32 v2, v2, v27
	v_cvt_i32_f32_e32 v10, v27
	v_fmac_f32_e32 v7, 0x32a5705f, v24
	v_sub_f32_e32 v25, v25, v21
	v_cvt_i32_f32_e32 v11, v21
	v_add_f32_e32 v2, v2, v26
	v_cndmask_b32_e32 v9, 0, v9, vcc_lo
	v_cmp_ngt_f32_e32 vcc_lo, 0xc2ce8ed0, v22
	v_add_f32_e32 v7, v25, v7
	v_exp_f32_e32 v2, v2
	v_add_f32_e32 v9, v20, v9
	v_exp_f32_e32 v7, v7
	v_ldexp_f32 v2, v2, v10
	v_cndmask_b32_e64 v10, 1.0, v3, s5
	v_ldexp_f32 v7, v7, v11
	v_cndmask_b32_e32 v2, 0, v2, vcc_lo
	v_cmp_ngt_f32_e32 vcc_lo, 0xc2ce8ed0, v24
	v_cndmask_b32_e32 v7, 0, v7, vcc_lo
	v_cmp_nlt_f32_e32 vcc_lo, 0x42b17218, v22
	v_cndmask_b32_e32 v2, 0x7f800000, v2, vcc_lo
	v_cmp_nlt_f32_e32 vcc_lo, 0x42b17218, v24
	v_fma_f32 v8, v2, v8, v2
	v_cndmask_b32_e32 v7, 0x7f800000, v7, vcc_lo
	v_cmp_class_f32_e64 s6, v2, 0x204
	v_cmp_neq_f32_e32 vcc_lo, v28, v23
	v_fma_f32 v9, v7, v9, v7
	v_cndmask_b32_e64 v2, v8, v2, s6
	v_cmp_class_f32_e64 s6, v7, 0x204
	s_and_b32 vcc_lo, s3, vcc_lo
	v_cndmask_b32_e64 v8, 0x7f800000, 0, s0
	v_cndmask_b32_e32 v11, 1.0, v4, vcc_lo
	v_bfi_b32 v2, 0x7fffffff, v2, v10
	v_cndmask_b32_e64 v7, v9, v7, s6
	v_cndmask_b32_e32 v10, 0, v4, vcc_lo
	v_cmp_gt_f32_e32 vcc_lo, 0, v3
	v_cndmask_b32_e64 v9, 0, v3, s5
	v_cmp_class_f32_e64 s0, v4, 0x204
	v_bfi_b32 v7, 0x7fffffff, v7, v11
	v_cndmask_b32_e64 v11, 0x7fc00000, v2, s1
	v_bfi_b32 v8, 0x7fffffff, v8, v10
	v_bfi_b32 v9, 0x7fffffff, v13, v9
	v_cndmask_b32_e64 v12, 0x7fc00000, v7, s3
	v_cndmask_b32_e32 v2, v2, v11, vcc_lo
	v_cmp_gt_f32_e32 vcc_lo, 0, v4
	v_cndmask_b32_e32 v7, v7, v12, vcc_lo
	s_or_b32 vcc_lo, s2, s7
	v_cndmask_b32_e32 v2, v2, v9, vcc_lo
	s_or_b32 vcc_lo, s4, s0
	v_cndmask_b32_e32 v7, v7, v8, vcc_lo
	v_cmp_o_f32_e32 vcc_lo, v3, v3
	v_sub_f32_e32 v2, 1.0, v2
	v_sub_f32_e32 v7, 1.0, v7
	v_cndmask_b32_e32 v2, 0x7fc00000, v2, vcc_lo
	v_cmp_o_f32_e32 vcc_lo, v4, v4
	s_waitcnt vmcnt(2)
	v_div_scale_f32 v4, null, v2, v2, v5
	v_cndmask_b32_e32 v3, 0x7fc00000, v7, vcc_lo
	v_div_scale_f32 v12, vcc_lo, v5, v2, v5
	v_rcp_f32_e32 v8, v4
	s_waitcnt vmcnt(1)
	v_div_scale_f32 v7, null, v3, v3, v6
	v_rcp_f32_e32 v9, v7
	v_fma_f32 v10, -v4, v8, 1.0
	v_fmac_f32_e32 v8, v10, v8
	v_div_scale_f32 v10, s0, v6, v3, v6
	v_fma_f32 v11, -v7, v9, 1.0
	v_fmac_f32_e32 v9, v11, v9
	v_mul_f32_e32 v11, v12, v8
	v_mul_f32_e32 v13, v10, v9
	v_fma_f32 v14, -v4, v11, v12
	v_fma_f32 v15, -v7, v13, v10
	v_fmac_f32_e32 v11, v14, v8
	v_fmac_f32_e32 v13, v15, v9
	v_fma_f32 v4, -v4, v11, v12
	v_fma_f32 v7, -v7, v13, v10
	v_div_fmas_f32 v4, v4, v8, v11
	s_mov_b32 vcc_lo, s0
	v_div_fmas_f32 v7, v7, v9, v13
	v_div_fixup_f32 v2, v4, v2, v5
	v_div_fixup_f32 v3, v7, v3, v6
	v_mul_f32_e32 v2, s10, v2
	v_mul_f32_e32 v6, 0x4f800000, v3
	v_cmp_gt_f32_e32 vcc_lo, 0xf800000, v3
	v_cndmask_b32_e32 v3, v3, v6, vcc_lo
	v_sqrt_f32_e32 v6, v3
	v_add_nc_u32_e32 v7, -1, v6
	v_add_nc_u32_e32 v8, 1, v6
	v_fma_f32 v9, -v7, v6, v3
	v_fma_f32 v10, -v8, v6, v3
	v_cmp_ge_f32_e64 s0, 0, v9
	v_cndmask_b32_e64 v6, v6, v7, s0
	v_cmp_lt_f32_e64 s0, 0, v10
	v_cndmask_b32_e64 v6, v6, v8, s0
	v_mul_f32_e32 v7, 0x37800000, v6
	v_cndmask_b32_e32 v6, v6, v7, vcc_lo
	v_cmp_class_f32_e64 vcc_lo, v3, 0x260
	v_cndmask_b32_e32 v3, v6, v3, vcc_lo
	v_add_f32_e32 v3, s11, v3
	v_div_scale_f32 v4, null, v3, v3, v2
	v_rcp_f32_e32 v5, v4
	v_fma_f32 v6, -v4, v5, 1.0
	v_fmac_f32_e32 v5, v6, v5
	v_div_scale_f32 v6, vcc_lo, v2, v3, v2
	v_mul_f32_e32 v7, v6, v5
	v_fma_f32 v8, -v4, v7, v6
	v_fmac_f32_e32 v7, v8, v5
	v_fma_f32 v4, -v4, v7, v6
	v_div_fmas_f32 v4, v4, v5, v7
	v_div_fixup_f32 v2, v4, v3, v2
	s_waitcnt vmcnt(0)
	v_add_f32_e32 v2, v16, v2
	global_store_dword v[0:1], v2, off
.LBB34_2:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel adam_kernel
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 312
		.amdhsa_user_sgpr_count 6
		.amdhsa_user_sgpr_private_segment_buffer 1
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_flat_scratch_init 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_wavefront_size32 1
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_system_sgpr_private_segment_wavefront_offset 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 30
		.amdhsa_next_free_sgpr 16
		.amdhsa_reserve_vcc 1
		.amdhsa_reserve_flat_scratch 0
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 3
		.amdhsa_float_denorm_mode_16_64 3
		.amdhsa_dx10_clamp 1
		.amdhsa_ieee_mode 1
		.amdhsa_fp16_overflow 0
		.amdhsa_workgroup_processor_mode 1
		.amdhsa_memory_ordered 1
		.amdhsa_forward_progress 1
		.amdhsa_shared_vgpr_count 0
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.text
.Lfunc_end34:
	.size	adam_kernel, .Lfunc_end34-adam_kernel
                                        ; -- End function
	.set adam_kernel.num_vgpr, 30
	.set adam_kernel.num_agpr, 0
	.set adam_kernel.numbered_sgpr, 16
	.set adam_kernel.num_named_barrier, 0
	.set adam_kernel.private_seg_size, 0
	.set adam_kernel.uses_vcc, 1
	.set adam_kernel.uses_flat_scratch, 0
	.set adam_kernel.has_dyn_sized_stack, 0
	.set adam_kernel.has_recursion, 0
	.set adam_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 2300
; TotalNumSgprs: 18
; NumVgprs: 30
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 0
; VGPRBlocks: 3
; NumSGPRsForWavesPerEU: 18
; NumVGPRsForWavesPerEU: 30
; Occupancy: 16
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 6
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
	.text
	.protected	gemm_kernel             ; -- Begin function gemm_kernel
	.globl	gemm_kernel
	.p2align	8
	.type	gemm_kernel,@function
gemm_kernel:                            ; @gemm_kernel
; %bb.0:
	s_clause 0x2
	s_load_dwordx4 s[8:11], s[4:5], 0x0
	s_load_dwordx2 s[14:15], s[4:5], 0x10
	s_load_dwordx2 s[12:13], s[4:5], 0x30
	v_lshl_add_u32 v2, s6, 4, v0
	v_lshl_add_u32 v3, s7, 4, v1
	s_waitcnt lgkmcnt(0)
	v_cmp_gt_i32_e64 s0, s11, v2
	s_cmp_lt_i32 s14, 1
	v_cmp_gt_i32_e32 vcc_lo, s10, v3
	s_cbranch_scc1 .LBB35_7
; %bb.1:
	s_clause 0x2
	s_load_dwordx2 s[6:7], s[4:5], 0x18
	s_load_dword s18, s[4:5], 0x20
	s_load_dwordx2 s[16:17], s[4:5], 0x28
	v_lshlrev_b32_e32 v4, 2, v0
	v_lshlrev_b32_e32 v5, 6, v1
	s_add_i32 s1, s14, 15
	s_lshr_b32 s19, s1, 4
	v_add_nc_u32_e32 v6, 0x400, v4
	s_cmp_eq_u32 s8, 0
	v_add_nc_u32_e32 v7, v5, v4
	v_mov_b32_e32 v4, 0
	s_cselect_b32 s1, -1, 0
	v_add_nc_u32_e32 v8, v6, v5
	s_cmp_eq_u32 s9, 0
	s_cselect_b32 s2, -1, 0
	s_branch .LBB35_3
.LBB35_2:                               ;   in Loop: Header=BB35_3 Depth=1
	s_or_b32 exec_lo, exec_lo, s8
	s_waitcnt vmcnt(0)
	ds_write_b32 v8, v10
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	ds_read_b128 v[9:12], v5
	ds_read2_b32 v[17:18], v6 offset1:16
	ds_read2_b32 v[19:20], v6 offset0:32 offset1:48
	ds_read_b128 v[13:16], v5 offset:16
	ds_read2_b32 v[21:22], v6 offset0:64 offset1:80
	v_add_nc_u32_e32 v0, 16, v0
	v_add_nc_u32_e32 v1, 16, v1
	s_add_i32 s19, s19, -1
	s_cmp_eq_u32 s19, 0
	s_waitcnt lgkmcnt(3)
	v_fmac_f32_e32 v4, v9, v17
	v_fmac_f32_e32 v4, v10, v18
	ds_read2_b32 v[17:18], v6 offset0:96 offset1:112
	s_waitcnt lgkmcnt(3)
	v_fmac_f32_e32 v4, v11, v19
	v_fmac_f32_e32 v4, v12, v20
	ds_read_b128 v[9:12], v5 offset:32
	ds_read2_b32 v[19:20], v6 offset0:128 offset1:144
	s_waitcnt lgkmcnt(3)
	v_fmac_f32_e32 v4, v13, v21
	v_fmac_f32_e32 v4, v14, v22
	ds_read2_b32 v[21:22], v6 offset0:160 offset1:176
	s_waitcnt lgkmcnt(3)
	v_fmac_f32_e32 v4, v15, v17
	v_fmac_f32_e32 v4, v16, v18
	ds_read_b128 v[13:16], v5 offset:48
	ds_read2_b32 v[17:18], v6 offset0:192 offset1:208
	s_waitcnt lgkmcnt(3)
	v_fmac_f32_e32 v4, v9, v19
	v_fmac_f32_e32 v4, v10, v20
	ds_read2_b32 v[9:10], v6 offset0:224 offset1:240
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	v_fmac_f32_e32 v4, v11, v21
	v_fmac_f32_e32 v4, v12, v22
	v_fmac_f32_e32 v4, v13, v17
	v_fmac_f32_e32 v4, v14, v18
	v_fmac_f32_e32 v4, v15, v9
	v_fmac_f32_e32 v4, v16, v10
	s_cbranch_scc1 .LBB35_8
.LBB35_3:                               ; =>This Inner Loop Header: Depth=1
	v_cmp_gt_i32_e64 s3, s14, v0
	v_mov_b32_e32 v9, 0
	s_and_b32 s3, vcc_lo, s3
	s_and_saveexec_b32 s8, s3
	s_cbranch_execz .LBB35_5
; %bb.4:                                ;   in Loop: Header=BB35_3 Depth=1
	v_cndmask_b32_e64 v10, v0, v3, s1
	v_cndmask_b32_e64 v9, v3, v0, s1
	s_waitcnt lgkmcnt(0)
	v_mad_u64_u32 v[9:10], null, v10, s18, v[9:10]
	v_ashrrev_i32_e32 v10, 31, v9
	v_lshlrev_b64 v[9:10], 2, v[9:10]
	v_add_co_u32 v9, s3, s6, v9
	v_add_co_ci_u32_e64 v10, null, s7, v10, s3
	global_load_dword v9, v[9:10], off
.LBB35_5:                               ;   in Loop: Header=BB35_3 Depth=1
	s_or_b32 exec_lo, exec_lo, s8
	v_cmp_gt_i32_e64 s3, s14, v1
	v_mov_b32_e32 v10, 0
	s_waitcnt vmcnt(0)
	ds_write_b32 v7, v9
	s_and_b32 s3, s0, s3
	s_and_saveexec_b32 s8, s3
	s_cbranch_execz .LBB35_2
; %bb.6:                                ;   in Loop: Header=BB35_3 Depth=1
	v_cndmask_b32_e64 v10, v2, v1, s2
	v_cndmask_b32_e64 v9, v1, v2, s2
	v_mad_u64_u32 v[9:10], null, v10, s12, v[9:10]
	v_ashrrev_i32_e32 v10, 31, v9
	v_lshlrev_b64 v[9:10], 2, v[9:10]
	s_waitcnt lgkmcnt(0)
	v_add_co_u32 v9, s3, s16, v9
	v_add_co_ci_u32_e64 v10, null, s17, v10, s3
	global_load_dword v10, v[9:10], off
	s_branch .LBB35_2
.LBB35_7:
	v_mov_b32_e32 v4, 0
.LBB35_8:
	v_cmp_gt_i32_e32 vcc_lo, s10, v3
	v_cmp_gt_i32_e64 s0, s11, v2
	s_and_b32 s0, vcc_lo, s0
	s_and_saveexec_b32 s1, s0
	s_cbranch_execz .LBB35_12
; %bb.9:
	s_clause 0x1
	s_load_dword s2, s[4:5], 0x40
	s_load_dwordx2 s[0:1], s[4:5], 0x38
	s_waitcnt lgkmcnt(0)
	v_mad_u64_u32 v[0:1], null, s2, v3, v[2:3]
	v_cmp_eq_f32_e64 s2, s13, 0
	v_mul_f32_e32 v2, s15, v4
	s_and_b32 vcc_lo, exec_lo, s2
	v_ashrrev_i32_e32 v1, 31, v0
	v_lshlrev_b64 v[0:1], 2, v[0:1]
	s_cbranch_vccnz .LBB35_11
; %bb.10:
	v_add_co_u32 v3, vcc_lo, s0, v0
	v_add_co_ci_u32_e64 v4, null, s1, v1, vcc_lo
	global_load_dword v3, v[3:4], off
	s_waitcnt vmcnt(0)
	v_fmac_f32_e32 v2, s13, v3
.LBB35_11:
	v_add_co_u32 v0, vcc_lo, s0, v0
	v_add_co_ci_u32_e64 v1, null, s1, v1, vcc_lo
	global_store_dword v[0:1], v2, off
.LBB35_12:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel gemm_kernel
		.amdhsa_group_segment_fixed_size 2048
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 68
		.amdhsa_user_sgpr_count 6
		.amdhsa_user_sgpr_private_segment_buffer 1
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_flat_scratch_init 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_wavefront_size32 1
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_system_sgpr_private_segment_wavefront_offset 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 1
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 1
		.amdhsa_next_free_vgpr 23
		.amdhsa_next_free_sgpr 20
		.amdhsa_reserve_vcc 1
		.amdhsa_reserve_flat_scratch 0
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 3
		.amdhsa_float_denorm_mode_16_64 3
		.amdhsa_dx10_clamp 1
		.amdhsa_ieee_mode 1
		.amdhsa_fp16_overflow 0
		.amdhsa_workgroup_processor_mode 1
		.amdhsa_memory_ordered 1
		.amdhsa_forward_progress 1
		.amdhsa_shared_vgpr_count 0
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.text
.Lfunc_end35:
	.size	gemm_kernel, .Lfunc_end35-gemm_kernel
                                        ; -- End function
	.set gemm_kernel.num_vgpr, 23
	.set gemm_kernel.num_agpr, 0
	.set gemm_kernel.numbered_sgpr, 20
	.set gemm_kernel.num_named_barrier, 0
	.set gemm_kernel.private_seg_size, 0
	.set gemm_kernel.uses_vcc, 1
	.set gemm_kernel.uses_flat_scratch, 0
	.set gemm_kernel.has_dyn_sized_stack, 0
	.set gemm_kernel.has_recursion, 0
	.set gemm_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 748
; TotalNumSgprs: 22
; NumVgprs: 23
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 2048 bytes/workgroup (compile time only)
; SGPRBlocks: 0
; VGPRBlocks: 2
; NumSGPRsForWavesPerEU: 22
; NumVGPRsForWavesPerEU: 23
; Occupancy: 16
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 6
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 1
	.text
	.p2alignl 6, 3214868480
	.fill 48, 4, 3214868480
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.text
	.type	__hip_cuid_576f7fed6bfa0e27,@object ; @__hip_cuid_576f7fed6bfa0e27
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_576f7fed6bfa0e27
__hip_cuid_576f7fed6bfa0e27:
	.byte	0                               ; 0x0
	.size	__hip_cuid_576f7fed6bfa0e27, 1

	.ident	"nixpkgs-AMD clang version 22.0.0 (https://github.com/ROCm/llvm-project/tree/rocm-7.2.3 rocm-7.2.3)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __hip_cuid_576f7fed6bfa0e27
	.amdgpu_metadata
---
amdhsa.kernels:
  - .args:
      - .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .offset:         8
        .size:           4
        .value_kind:     by_value
      - .offset:         12
        .size:           4
        .value_kind:     by_value
      - .offset:         16
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         20
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         24
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         28
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         30
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         32
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         34
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         36
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         38
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         56
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         64
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         72
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         80
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 272
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 1024
    .name:           activate_array_kernel
    .private_segment_fixed_size: 0
    .sgpr_count:     9
    .sgpr_spill_count: 0
    .symbol:         activate_array_kernel.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     9
    .vgpr_spill_count: 0
    .wavefront_size: 32
    .workgroup_processor_mode: 1
  - .args:
      - .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .offset:         8
        .size:           4
        .value_kind:     by_value
      - .offset:         12
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         16
        .size:           8
        .value_kind:     global_buffer
      - .offset:         24
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         28
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         32
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         36
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         38
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         40
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         42
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         44
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         46
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         64
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         72
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         80
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         88
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 280
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 1024
    .name:           gradient_array_kernel
    .private_segment_fixed_size: 0
    .sgpr_count:     9
    .sgpr_spill_count: 0
    .symbol:         gradient_array_kernel.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     6
    .vgpr_spill_count: 0
    .wavefront_size: 32
    .workgroup_processor_mode: 1
  - .args:
      - .offset:         0
        .size:           4
        .value_kind:     by_value
      - .offset:         4
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .offset:         16
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         20
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         24
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         28
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         30
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         32
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         34
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         36
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         38
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         56
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         64
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         72
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         80
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 272
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 1024
    .name:           fill_kernel
    .private_segment_fixed_size: 0
    .sgpr_count:     9
    .sgpr_spill_count: 0
    .symbol:         fill_kernel.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     3
    .vgpr_spill_count: 0
    .wavefront_size: 32
    .workgroup_processor_mode: 1
  - .args:
      - .offset:         0
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         16
        .size:           8
        .value_kind:     global_buffer
      - .offset:         24
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         28
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         32
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         36
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         38
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         40
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         42
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         44
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         46
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         64
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         72
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         80
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         88
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 280
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 1024
    .name:           copy_kernel
    .private_segment_fixed_size: 0
    .sgpr_count:     9
    .sgpr_spill_count: 0
    .symbol:         copy_kernel.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     4
    .vgpr_spill_count: 0
    .wavefront_size: 32
    .workgroup_processor_mode: 1
  - .args:
      - .offset:         0
        .size:           4
        .value_kind:     by_value
      - .offset:         4
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         16
        .size:           8
        .value_kind:     global_buffer
      - .offset:         24
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         28
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         32
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         36
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         38
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         40
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         42
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         44
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         46
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         64
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         72
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         80
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         88
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 280
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 1024
    .name:           axpy_kernel
    .private_segment_fixed_size: 0
    .sgpr_count:     10
    .sgpr_spill_count: 0
    .symbol:         axpy_kernel.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     4
    .vgpr_spill_count: 0
    .wavefront_size: 32
    .workgroup_processor_mode: 1
  - .args:
      - .offset:         0
        .size:           4
        .value_kind:     by_value
      - .offset:         4
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .offset:         16
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         20
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         24
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         28
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         30
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         32
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         34
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         36
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         38
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         56
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         64
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         72
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         80
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 272
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 1024
    .name:           scal_kernel
    .private_segment_fixed_size: 0
    .sgpr_count:     9
    .sgpr_spill_count: 0
    .symbol:         scal_kernel.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     3
    .vgpr_spill_count: 0
    .wavefront_size: 32
    .workgroup_processor_mode: 1
  - .args:
      - .offset:         0
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         16
        .size:           8
        .value_kind:     global_buffer
      - .offset:         24
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         28
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         32
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         36
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         38
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         40
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         42
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         44
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         46
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         64
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         72
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         80
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         88
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 280
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 1024
    .name:           mul_kernel
    .private_segment_fixed_size: 0
    .sgpr_count:     9
    .sgpr_spill_count: 0
    .symbol:         mul_kernel.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     4
    .vgpr_spill_count: 0
    .wavefront_size: 32
    .workgroup_processor_mode: 1
  - .args:
      - .offset:         0
        .size:           4
        .value_kind:     by_value
      - .offset:         4
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .offset:         16
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         20
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         24
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         28
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         30
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         32
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         34
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         36
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         38
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         56
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         64
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         72
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         80
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 272
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 1024
    .name:           add_scalar_kernel
    .private_segment_fixed_size: 0
    .sgpr_count:     9
    .sgpr_spill_count: 0
    .symbol:         add_scalar_kernel.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     3
    .vgpr_spill_count: 0
    .wavefront_size: 32
    .workgroup_processor_mode: 1
  - .args:
      - .offset:         0
        .size:           4
        .value_kind:     by_value
      - .offset:         4
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .offset:         16
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         20
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         24
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         28
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         30
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         32
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         34
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         36
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         38
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         56
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         64
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         72
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         80
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 272
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 1024
    .name:           constrain_kernel
    .private_segment_fixed_size: 0
    .sgpr_count:     9
    .sgpr_spill_count: 0
    .symbol:         constrain_kernel.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     4
    .vgpr_spill_count: 0
    .wavefront_size: 32
    .workgroup_processor_mode: 1
  - .args:
      - .offset:         0
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .offset:         16
        .size:           4
        .value_kind:     by_value
      - .offset:         24
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         28
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         32
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         36
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         38
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         40
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         42
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         44
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         46
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         64
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         72
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         80
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         88
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 280
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 1024
    .name:           rand_uniform_kernel
    .private_segment_fixed_size: 0
    .sgpr_count:     9
    .sgpr_spill_count: 0
    .symbol:         rand_uniform_kernel.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     3
    .vgpr_spill_count: 0
    .wavefront_size: 32
    .workgroup_processor_mode: 1
  - .args:
      - .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .offset:         16
        .size:           4
        .value_kind:     by_value
      - .offset:         20
        .size:           4
        .value_kind:     by_value
      - .offset:         24
        .size:           4
        .value_kind:     by_value
      - .offset:         32
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         36
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         40
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         44
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         46
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         48
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         50
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         52
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         54
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         72
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         80
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         88
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         96
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 288
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 1024
    .name:           add_bias_kernel
    .private_segment_fixed_size: 0
    .sgpr_count:     10
    .sgpr_spill_count: 0
    .symbol:         add_bias_kernel.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     6
    .vgpr_spill_count: 0
    .wavefront_size: 32
    .workgroup_processor_mode: 1
  - .args:
      - .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .offset:         16
        .size:           4
        .value_kind:     by_value
      - .offset:         20
        .size:           4
        .value_kind:     by_value
      - .offset:         24
        .size:           4
        .value_kind:     by_value
      - .offset:         32
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         36
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         40
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         44
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         46
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         48
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         50
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         52
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         54
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         72
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         80
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         88
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         96
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 288
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 1024
    .name:           scale_bias_kernel
    .private_segment_fixed_size: 0
    .sgpr_count:     10
    .sgpr_spill_count: 0
    .symbol:         scale_bias_kernel.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     6
    .vgpr_spill_count: 0
    .wavefront_size: 32
    .workgroup_processor_mode: 1
  - .args:
      - .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .offset:         16
        .size:           4
        .value_kind:     by_value
      - .offset:         20
        .size:           4
        .value_kind:     by_value
      - .offset:         24
        .size:           4
        .value_kind:     by_value
    .group_segment_fixed_size: 1024
    .kernarg_segment_align: 8
    .kernarg_segment_size: 28
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 1024
    .name:           backward_bias_kernel
    .private_segment_fixed_size: 0
    .sgpr_count:     18
    .sgpr_spill_count: 0
    .symbol:         backward_bias_kernel.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     7
    .vgpr_spill_count: 0
    .wavefront_size: 32
    .workgroup_processor_mode: 1
  - .args:
      - .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .offset:         16
        .size:           4
        .value_kind:     by_value
      - .offset:         20
        .size:           4
        .value_kind:     by_value
      - .offset:         24
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         28
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         32
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         36
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         38
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         40
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         42
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         44
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         46
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         64
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         72
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         80
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         88
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 280
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 1024
    .name:           backward_bias_conn_kernel
    .private_segment_fixed_size: 0
    .sgpr_count:     12
    .sgpr_spill_count: 0
    .symbol:         backward_bias_conn_kernel.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     6
    .vgpr_spill_count: 0
    .wavefront_size: 32
    .workgroup_processor_mode: 1
  - .args:
      - .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .offset:         16
        .size:           4
        .value_kind:     by_value
      - .offset:         20
        .size:           4
        .value_kind:     by_value
      - .offset:         24
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         32
        .size:           8
        .value_kind:     global_buffer
    .group_segment_fixed_size: 1024
    .kernarg_segment_align: 8
    .kernarg_segment_size: 40
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 1024
    .name:           backward_scale_kernel
    .private_segment_fixed_size: 0
    .sgpr_count:     18
    .sgpr_spill_count: 0
    .symbol:         backward_scale_kernel.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     10
    .vgpr_spill_count: 0
    .wavefront_size: 32
    .workgroup_processor_mode: 1
  - .args:
      - .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .offset:         8
        .size:           4
        .value_kind:     by_value
      - .offset:         12
        .size:           4
        .value_kind:     by_value
      - .offset:         16
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         24
        .size:           8
        .value_kind:     global_buffer
    .group_segment_fixed_size: 1024
    .kernarg_segment_align: 8
    .kernarg_segment_size: 32
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 1024
    .name:           fast_mean_kernel
    .private_segment_fixed_size: 0
    .sgpr_count:     15
    .sgpr_spill_count: 0
    .symbol:         fast_mean_kernel.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     8
    .vgpr_spill_count: 0
    .wavefront_size: 32
    .workgroup_processor_mode: 1
  - .args:
      - .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .offset:         16
        .size:           4
        .value_kind:     by_value
      - .offset:         20
        .size:           4
        .value_kind:     by_value
      - .offset:         24
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         32
        .size:           8
        .value_kind:     global_buffer
    .group_segment_fixed_size: 1024
    .kernarg_segment_align: 8
    .kernarg_segment_size: 40
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 1024
    .name:           fast_variance_kernel
    .private_segment_fixed_size: 0
    .sgpr_count:     18
    .sgpr_spill_count: 0
    .symbol:         fast_variance_kernel.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     8
    .vgpr_spill_count: 0
    .wavefront_size: 32
    .workgroup_processor_mode: 1
  - .args:
      - .offset:         0
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         16
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         24
        .size:           8
        .value_kind:     global_buffer
      - .offset:         32
        .size:           4
        .value_kind:     by_value
      - .offset:         36
        .size:           4
        .value_kind:     by_value
      - .offset:         40
        .size:           4
        .value_kind:     by_value
      - .offset:         48
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         52
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         56
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         60
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         62
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         64
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         66
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         68
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         70
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         88
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         96
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         104
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         112
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 304
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 1024
    .name:           normalize_kernel
    .private_segment_fixed_size: 0
    .sgpr_count:     9
    .sgpr_spill_count: 0
    .symbol:         normalize_kernel.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     10
    .vgpr_spill_count: 0
    .wavefront_size: 32
    .workgroup_processor_mode: 1
  - .args:
      - .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .offset:         16
        .size:           4
        .value_kind:     by_value
      - .offset:         20
        .size:           4
        .value_kind:     by_value
      - .offset:         24
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         32
        .size:           8
        .value_kind:     global_buffer
    .group_segment_fixed_size: 1024
    .kernarg_segment_align: 8
    .kernarg_segment_size: 40
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 1024
    .name:           fast_mean_delta_kernel
    .private_segment_fixed_size: 0
    .sgpr_count:     18
    .sgpr_spill_count: 0
    .symbol:         fast_mean_delta_kernel.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     8
    .vgpr_spill_count: 0
    .wavefront_size: 32
    .workgroup_processor_mode: 1
  - .args:
      - .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         16
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         24
        .size:           8
        .value_kind:     global_buffer
      - .offset:         32
        .size:           4
        .value_kind:     by_value
      - .offset:         36
        .size:           4
        .value_kind:     by_value
      - .offset:         40
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         48
        .size:           8
        .value_kind:     global_buffer
    .group_segment_fixed_size: 1024
    .kernarg_segment_align: 8
    .kernarg_segment_size: 56
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 1024
    .name:           fast_variance_delta_kernel
    .private_segment_fixed_size: 0
    .sgpr_count:     22
    .sgpr_spill_count: 0
    .symbol:         fast_variance_delta_kernel.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     13
    .vgpr_spill_count: 0
    .wavefront_size: 32
    .workgroup_processor_mode: 1
  - .args:
      - .offset:         0
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         16
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         24
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         32
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         40
        .size:           8
        .value_kind:     global_buffer
      - .offset:         48
        .size:           4
        .value_kind:     by_value
      - .offset:         52
        .size:           4
        .value_kind:     by_value
      - .offset:         56
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         64
        .size:           8
        .value_kind:     global_buffer
      - .offset:         72
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         76
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         80
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         84
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         86
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         88
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         90
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         92
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         94
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         112
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         120
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         128
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         136
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 328
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 1024
    .name:           normalize_delta_kernel
    .private_segment_fixed_size: 0
    .sgpr_count:     22
    .sgpr_spill_count: 0
    .symbol:         normalize_delta_kernel.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     21
    .vgpr_spill_count: 0
    .wavefront_size: 32
    .workgroup_processor_mode: 1
  - .args:
      - .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .offset:         8
        .size:           4
        .value_kind:     by_value
      - .offset:         12
        .size:           4
        .value_kind:     by_value
      - .offset:         16
        .size:           4
        .value_kind:     by_value
      - .offset:         20
        .size:           4
        .value_kind:     by_value
      - .offset:         24
        .size:           4
        .value_kind:     by_value
      - .offset:         28
        .size:           4
        .value_kind:     by_value
      - .offset:         32
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         40
        .size:           8
        .value_kind:     global_buffer
      - .offset:         48
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         52
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         56
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         60
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         62
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         64
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         66
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         68
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         70
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         88
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         96
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         104
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         112
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 304
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 1024
    .name:           softmax_kernel
    .private_segment_fixed_size: 0
    .sgpr_count:     14
    .sgpr_spill_count: 0
    .symbol:         softmax_kernel.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     12
    .vgpr_spill_count: 0
    .wavefront_size: 32
    .workgroup_processor_mode: 1
  - .args:
      - .offset:         0
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         16
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         24
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         32
        .size:           8
        .value_kind:     global_buffer
      - .offset:         40
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         44
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         48
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         52
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         54
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         56
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         58
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         60
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         62
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         80
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         88
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         96
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         104
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 296
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 1024
    .name:           softmax_x_ent_kernel
    .private_segment_fixed_size: 0
    .sgpr_count:     10
    .sgpr_spill_count: 0
    .symbol:         softmax_x_ent_kernel.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     8
    .vgpr_spill_count: 0
    .wavefront_size: 32
    .workgroup_processor_mode: 1
  - .args:
      - .offset:         0
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         16
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         24
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         32
        .size:           8
        .value_kind:     global_buffer
      - .offset:         40
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         44
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         48
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         52
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         54
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         56
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         58
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         60
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         62
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         80
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         88
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         96
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         104
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 296
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 1024
    .name:           l2_kernel
    .private_segment_fixed_size: 0
    .sgpr_count:     10
    .sgpr_spill_count: 0
    .symbol:         l2_kernel.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     6
    .vgpr_spill_count: 0
    .wavefront_size: 32
    .workgroup_processor_mode: 1
  - .args:
      - .offset:         0
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         16
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         24
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         32
        .size:           8
        .value_kind:     global_buffer
      - .offset:         40
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         44
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         48
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         52
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         54
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         56
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         58
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         60
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         62
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         80
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         88
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         96
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         104
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 296
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 1024
    .name:           l1_kernel
    .private_segment_fixed_size: 0
    .sgpr_count:     10
    .sgpr_spill_count: 0
    .symbol:         l1_kernel.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     7
    .vgpr_spill_count: 0
    .wavefront_size: 32
    .workgroup_processor_mode: 1
  - .args:
      - .offset:         0
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         16
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         24
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         32
        .size:           8
        .value_kind:     global_buffer
      - .offset:         40
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         44
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         48
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         52
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         54
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         56
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         58
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         60
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         62
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         80
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         88
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         96
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         104
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 296
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 1024
    .name:           smooth_l1_kernel
    .private_segment_fixed_size: 0
    .sgpr_count:     10
    .sgpr_spill_count: 0
    .symbol:         smooth_l1_kernel.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     6
    .vgpr_spill_count: 0
    .wavefront_size: 32
    .workgroup_processor_mode: 1
  - .args:
      - .offset:         0
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .offset:         16
        .size:           4
        .value_kind:     by_value
      - .offset:         20
        .size:           4
        .value_kind:     by_value
      - .offset:         24
        .size:           4
        .value_kind:     by_value
      - .offset:         28
        .size:           4
        .value_kind:     by_value
      - .offset:         32
        .size:           4
        .value_kind:     by_value
      - .offset:         36
        .size:           4
        .value_kind:     by_value
      - .offset:         40
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         48
        .size:           8
        .value_kind:     global_buffer
      - .offset:         56
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         60
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         64
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         68
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         70
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         72
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         74
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         76
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         78
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         96
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         104
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         112
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         120
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 312
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 1024
    .name:           im2col_kernel
    .private_segment_fixed_size: 0
    .sgpr_count:     32
    .sgpr_spill_count: 0
    .symbol:         im2col_kernel.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     15
    .vgpr_spill_count: 0
    .wavefront_size: 32
    .workgroup_processor_mode: 1
  - .args:
      - .offset:         0
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .offset:         16
        .size:           4
        .value_kind:     by_value
      - .offset:         20
        .size:           4
        .value_kind:     by_value
      - .offset:         24
        .size:           4
        .value_kind:     by_value
      - .offset:         28
        .size:           4
        .value_kind:     by_value
      - .offset:         32
        .size:           4
        .value_kind:     by_value
      - .offset:         36
        .size:           4
        .value_kind:     by_value
      - .offset:         40
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         48
        .size:           8
        .value_kind:     global_buffer
      - .offset:         56
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         60
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         64
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         68
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         70
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         72
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         74
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         76
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         78
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         96
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         104
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         112
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         120
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 312
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 1024
    .name:           col2im_kernel
    .private_segment_fixed_size: 0
    .sgpr_count:     29
    .sgpr_spill_count: 0
    .symbol:         col2im_kernel.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     19
    .vgpr_spill_count: 0
    .wavefront_size: 32
    .workgroup_processor_mode: 1
  - .args:
      - .offset:         0
        .size:           4
        .value_kind:     by_value
      - .offset:         4
        .size:           4
        .value_kind:     by_value
      - .offset:         8
        .size:           4
        .value_kind:     by_value
      - .offset:         12
        .size:           4
        .value_kind:     by_value
      - .offset:         16
        .size:           4
        .value_kind:     by_value
      - .offset:         20
        .size:           4
        .value_kind:     by_value
      - .offset:         24
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         32
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         40
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         48
        .size:           8
        .value_kind:     global_buffer
      - .offset:         56
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         60
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         64
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         68
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         70
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         72
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         74
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         76
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         78
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         96
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         104
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         112
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         120
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 312
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 1024
    .name:           forward_maxpool_kernel
    .private_segment_fixed_size: 0
    .sgpr_count:     22
    .sgpr_spill_count: 0
    .symbol:         forward_maxpool_kernel.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     11
    .vgpr_spill_count: 0
    .wavefront_size: 32
    .workgroup_processor_mode: 1
  - .args:
      - .offset:         0
        .size:           4
        .value_kind:     by_value
      - .offset:         4
        .size:           4
        .value_kind:     by_value
      - .offset:         8
        .size:           4
        .value_kind:     by_value
      - .offset:         12
        .size:           4
        .value_kind:     by_value
      - .offset:         16
        .size:           4
        .value_kind:     by_value
      - .offset:         20
        .size:           4
        .value_kind:     by_value
      - .offset:         24
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         32
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         40
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         48
        .size:           8
        .value_kind:     global_buffer
      - .offset:         56
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         60
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         64
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         68
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         70
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         72
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         74
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         76
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         78
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         96
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         104
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         112
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         120
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 312
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 1024
    .name:           backward_maxpool_kernel
    .private_segment_fixed_size: 0
    .sgpr_count:     25
    .sgpr_spill_count: 0
    .symbol:         backward_maxpool_kernel.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     12
    .vgpr_spill_count: 0
    .wavefront_size: 32
    .workgroup_processor_mode: 1
  - .args:
      - .offset:         0
        .size:           4
        .value_kind:     by_value
      - .offset:         4
        .size:           4
        .value_kind:     by_value
      - .offset:         8
        .size:           4
        .value_kind:     by_value
      - .offset:         12
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         16
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         24
        .size:           8
        .value_kind:     global_buffer
      - .offset:         32
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         36
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         40
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         44
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         46
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         48
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         50
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         52
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         54
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         72
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         80
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         88
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         96
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 288
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 1024
    .name:           forward_avgpool_kernel
    .private_segment_fixed_size: 0
    .sgpr_count:     14
    .sgpr_spill_count: 0
    .symbol:         forward_avgpool_kernel.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     8
    .vgpr_spill_count: 0
    .wavefront_size: 32
    .workgroup_processor_mode: 1
  - .args:
      - .offset:         0
        .size:           4
        .value_kind:     by_value
      - .offset:         4
        .size:           4
        .value_kind:     by_value
      - .offset:         8
        .size:           4
        .value_kind:     by_value
      - .offset:         12
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         16
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         24
        .size:           8
        .value_kind:     global_buffer
      - .offset:         32
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         36
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         40
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         44
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         46
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         48
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         50
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         52
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         54
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         72
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         80
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         88
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         96
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 288
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 1024
    .name:           backward_avgpool_kernel
    .private_segment_fixed_size: 0
    .sgpr_count:     10
    .sgpr_spill_count: 0
    .symbol:         backward_avgpool_kernel.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     8
    .vgpr_spill_count: 0
    .wavefront_size: 32
    .workgroup_processor_mode: 1
  - .args:
      - .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .offset:         8
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         16
        .size:           8
        .value_kind:     global_buffer
      - .offset:         24
        .size:           4
        .value_kind:     by_value
      - .offset:         28
        .size:           4
        .value_kind:     by_value
      - .offset:         32
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         36
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         40
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         44
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         46
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         48
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         50
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         52
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         54
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         72
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         80
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         88
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         96
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 288
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 1024
    .name:           dropout_kernel
    .private_segment_fixed_size: 0
    .sgpr_count:     9
    .sgpr_spill_count: 0
    .symbol:         dropout_kernel.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     4
    .vgpr_spill_count: 0
    .wavefront_size: 32
    .workgroup_processor_mode: 1
  - .args:
      - .offset:         0
        .size:           4
        .value_kind:     by_value
      - .offset:         4
        .size:           4
        .value_kind:     by_value
      - .offset:         8
        .size:           4
        .value_kind:     by_value
      - .offset:         12
        .size:           4
        .value_kind:     by_value
      - .offset:         16
        .size:           4
        .value_kind:     by_value
      - .offset:         20
        .size:           4
        .value_kind:     by_value
      - .offset:         24
        .size:           4
        .value_kind:     by_value
      - .offset:         28
        .size:           4
        .value_kind:     by_value
      - .offset:         32
        .size:           4
        .value_kind:     by_value
      - .offset:         36
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         40
        .size:           8
        .value_kind:     global_buffer
      - .offset:         48
        .size:           4
        .value_kind:     by_value
      - .offset:         52
        .size:           4
        .value_kind:     by_value
      - .offset:         56
        .size:           4
        .value_kind:     by_value
      - .offset:         60
        .size:           4
        .value_kind:     by_value
      - .offset:         64
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         72
        .size:           8
        .value_kind:     global_buffer
      - .offset:         80
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         84
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         88
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         92
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         94
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         96
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         98
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         100
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         102
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         120
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         128
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         136
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         144
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 336
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 1024
    .name:           shortcut_kernel
    .private_segment_fixed_size: 0
    .sgpr_count:     26
    .sgpr_spill_count: 0
    .symbol:         shortcut_kernel.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     9
    .vgpr_spill_count: 0
    .wavefront_size: 32
    .workgroup_processor_mode: 1
  - .args:
      - .offset:         0
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         16
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         24
        .size:           8
        .value_kind:     global_buffer
      - .offset:         32
        .size:           4
        .value_kind:     by_value
      - .offset:         36
        .size:           4
        .value_kind:     by_value
      - .offset:         40
        .size:           4
        .value_kind:     by_value
      - .offset:         44
        .size:           4
        .value_kind:     by_value
      - .offset:         48
        .size:           4
        .value_kind:     by_value
      - .offset:         56
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         60
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         64
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         68
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         70
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         72
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         74
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         76
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         78
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         96
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         104
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         112
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         120
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 312
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 1024
    .name:           adam_kernel
    .private_segment_fixed_size: 0
    .sgpr_count:     18
    .sgpr_spill_count: 0
    .symbol:         adam_kernel.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     30
    .vgpr_spill_count: 0
    .wavefront_size: 32
    .workgroup_processor_mode: 1
  - .args:
      - .offset:         0
        .size:           4
        .value_kind:     by_value
      - .offset:         4
        .size:           4
        .value_kind:     by_value
      - .offset:         8
        .size:           4
        .value_kind:     by_value
      - .offset:         12
        .size:           4
        .value_kind:     by_value
      - .offset:         16
        .size:           4
        .value_kind:     by_value
      - .offset:         20
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         24
        .size:           8
        .value_kind:     global_buffer
      - .offset:         32
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         40
        .size:           8
        .value_kind:     global_buffer
      - .offset:         48
        .size:           4
        .value_kind:     by_value
      - .offset:         52
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         56
        .size:           8
        .value_kind:     global_buffer
      - .offset:         64
        .size:           4
        .value_kind:     by_value
    .group_segment_fixed_size: 2048
    .kernarg_segment_align: 8
    .kernarg_segment_size: 68
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 1024
    .name:           gemm_kernel
    .private_segment_fixed_size: 0
    .sgpr_count:     22
    .sgpr_spill_count: 0
    .symbol:         gemm_kernel.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     23
    .vgpr_spill_count: 0
    .wavefront_size: 32
    .workgroup_processor_mode: 1
amdhsa.target:   amdgcn-amd-amdhsa--gfx1032
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
