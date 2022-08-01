// File         : dpath_adc_wrap.v
// Author       : Lei Ding <lei.ding@cirrus.com>
// Created      : Aug. 3, 2006
//-------------------------------------------------------------------------
//
// Description:
// This module is from Ray Charles. It is a wrapper around dpath_adc.
//-------------------------------------------------------------------------
// The following is Cirrus Logic Confidential Information.
// Copyright (c) 2006.
// Cirrus Logic, Inc., all rights reserved. This program is 
// protected as an unpublished work under Copyright Act of 
// 1976 and the Computer Software Act of 1980. This program is
// also considered a trade secret. It is not to be disclosed or
// used by parties who have not received written authorization
// from Cirrus Logic, Inc.
//-------------------------------------------------------------------------

module dpath_adc_allrates_wrap #(
  parameter SUPPORT_RARE_RATE_COMBOS    = 0 ,
  parameter MOD_INSIZE                  = 5 ,
  parameter BITWIDTHGROWTH              = 0 , // if need to decimate input by 2 from 6M to 3M, then make this value 3 >>> then would need mods down in dpath blocks
  parameter VMON_GAIN_INPUT_WIDTH       = 8 ,
  parameter VMON_OFFSET_INPUT_WIDTH     = 8,
  parameter IMON_GAIN_INPUT_WIDTH       = 8 ,
  parameter IMON_OFFSET_INPUT_WIDTH     = 10,
  parameter SUPP_MULT_COEFF_WIDTH       = 10,
  parameter SUPP_INPUT_WIDTH            = 11
  ) (
  // Clocks & resets
  input        mclk, 
  input        rsb_mclk,
  input        mclk_rda, 
  input        rsb_mclk_rda,
  input        mclk_adc_vmon, 
  input        rsb_mclk_adc_vmon,
  input        mclk_adc_imon, 
  input        rsb_mclk_adc_imon,
  input        mclk_dec, 
  input        rsb_mclk_dec,
  input        mclk_adc_dec_vmon, 
  input        rsb_mclk_adc_dec_vmon,
  input        mclk_adc_dec_imon, 
  input        rsb_mclk_adc_dec_imon,
  input        mclk_cal,
  input        rsb_mclk_cal,
  input        mclk_imon_afecal,
  input        rsb_mclk_imon_afecal,

  input        tock_1ms_6mhz,
  input        tick_1us_6mhz,
     
  //---------------------------------------------------------
  input                   enable_vmon, 
  input                   enable_imon,
  input             [1:0] sample_edge_sel_vimon,
  input  [MOD_INSIZE-1:0] mod_out_vmon, 
  input  [MOD_INSIZE-1:0] mod_out_imon,
  input             [1:0] freq_data_in_vimon,
  // Raw Data Access test mode
  input                   enable_rda,
  input                   sync_master_sel_rx_rda,
  input                   mod_out_dig_from_rx_rda,
  input                   enable_rx_rda,
  input                   enable_tx_rda,
  input             [2:0] data_in_rx_rda,
  output            [2:0] data_out_tx_rda,
  // Visibility
  input              [2:0] filter_out_stage,
  input              [4:0] enable_filter_stages,   
  input                    vis_data_en_vbst,
  input                    enable_vis,
  input              [5:0] addr_vis,
  input             [44:0] visbus_from_vimon_top,
  output            [31:0] data_out_vis,
  //---------------------------------------------------------
  input             [1:0] mclk_rate,
  input             [4:0] asp_rate,
  input                   response_type,
  input                   free_running,
  input                   fs_local_pulse,
  input                   force_dp_sync_rst_vimon,
  input             [7:0] shift_rslt_valid_amt_r1,
  input             [7:0] shift_rslt_valid_amt_r2,
  input                   data_out_clip_off_vimon,
  input                   alu_out_clip_off_vimon,
  input                   alu_mlt_clip_off_vimon,
  input                   vol_mute_gt_m102,
  input                   vol_disable_vmon,
  input                   vol_disable_imon,
  input             [1:0] dig_offset_vimon,
  input             [3:0] channel_mux_sel,
  input                   invert_vmon, 
  input                   invert_imon,
  input            [10:0] vol_cntl_vmon, 
  input            [10:0] vol_cntl_imon,
  input            [15:0] r1_lpf1_coeff_vmon, r2_lpf1_coeff_vmon,
  input            [15:0] r1_lpf2_coeff_vmon, r2_lpf2_coeff_vmon,
  input            [15:0] r1_lpf3_coeff_vmon, r2_lpf3_coeff_vmon,
  input            [15:0] r1_lpf4_coeff_vmon, r2_lpf4_coeff_vmon,
  input            [15:0] r1_lpf5_coeff_vmon, r2_lpf5_coeff_vmon,
  input            [15:0] r1_lpf6_coeff_vmon, r2_lpf6_coeff_vmon,
  input            [15:0] r1_lpf7_coeff_vmon, r2_lpf7_coeff_vmon,
  input            [15:0] r1_lpf8_coeff_vmon, r2_lpf8_coeff_vmon,
  input            [15:0] r1_lpf9_coeff_vmon, r2_lpf9_coeff_vmon,
  input            [15:0] r1_pc1_coeff_vmon , r2_pc1_coeff_vmon,
  input            [15:0] r1_pc2_coeff_vmon , r2_pc2_coeff_vmon,
  input            [15:0] r1_pc3_coeff_vmon , r2_pc3_coeff_vmon,
  input            [15:0] r1_pc4_coeff_vmon , r2_pc4_coeff_vmon,
  input            [15:0] r1_mc1a_double_coeff_vmon,
  input            [15:0] r1_mc1b_double_coeff_vmon,
  input            [15:0] r1_mc2a_double_coeff_vmon,
  input            [15:0] r1_mc2b_double_coeff_vmon,
  input            [15:0] r1_mc3a_double_coeff_vmon,
  input            [15:0] r1_mc3b_double_coeff_vmon,
  input            [15:0] r1_mcgn_double_coeff_vmon,
  input            [15:0] r1_mc1a_coeff_vmon,
  input            [15:0] r1_mc1b_coeff_vmon,
  input            [15:0] r1_mc2a_coeff_vmon,
  input            [15:0] r1_mc2b_coeff_vmon,
  input            [15:0] r1_mc3a_coeff_vmon,
  input            [15:0] r1_mc3b_coeff_vmon,
  input            [15:0] r1_mcgn_coeff_vmon,
  input            [15:0] r2_mc1a_quad_coeff_vmon,
  input            [15:0] r2_mc1b_quad_coeff_vmon,
  input            [15:0] r2_mc2a_quad_coeff_vmon,
  input            [15:0] r2_mc2b_quad_coeff_vmon,
  input            [15:0] r2_mc3a_quad_coeff_vmon,
  input            [15:0] r2_mc3b_quad_coeff_vmon,
  input            [15:0] r2_mcgn_quad_coeff_vmon,
  input            [15:0] r2_mc1a_coeff_vmon,
  input            [15:0] r2_mc1b_coeff_vmon,
  input            [15:0] r2_mc2a_coeff_vmon,
  input            [15:0] r2_mc2b_coeff_vmon,
  input            [15:0] r2_mc3a_coeff_vmon,
  input            [15:0] r2_mc3b_coeff_vmon,
  input            [15:0] r2_mcgn_coeff_vmon,
  input            [15:0] r1_lpf1_coeff_imon, r2_lpf1_coeff_imon,
  input            [15:0] r1_lpf2_coeff_imon, r2_lpf2_coeff_imon,
  input            [15:0] r1_lpf3_coeff_imon, r2_lpf3_coeff_imon,
  input            [15:0] r1_lpf4_coeff_imon, r2_lpf4_coeff_imon,
  input            [15:0] r1_lpf5_coeff_imon, r2_lpf5_coeff_imon,
  input            [15:0] r1_lpf6_coeff_imon, r2_lpf6_coeff_imon,
  input            [15:0] r1_lpf7_coeff_imon, r2_lpf7_coeff_imon,
  input            [15:0] r1_lpf8_coeff_imon, r2_lpf8_coeff_imon,
  input            [15:0] r1_lpf9_coeff_imon, r2_lpf9_coeff_imon,
  input            [15:0] r1_pc1_coeff_imon , r2_pc1_coeff_imon,
  input            [15:0] r1_pc2_coeff_imon , r2_pc2_coeff_imon,
  input            [15:0] r1_pc3_coeff_imon , r2_pc3_coeff_imon,
  input            [15:0] r1_pc4_coeff_imon , r2_pc4_coeff_imon,
  input            [15:0] r1_mc1a_double_coeff_imon,
  input            [15:0] r1_mc1b_double_coeff_imon,
  input            [15:0] r1_mc2a_double_coeff_imon,
  input            [15:0] r1_mc2b_double_coeff_imon,
  input            [15:0] r1_mc3a_double_coeff_imon,
  input            [15:0] r1_mc3b_double_coeff_imon,
  input            [15:0] r1_mcgn_double_coeff_imon,
  input            [15:0] r1_mc1a_coeff_imon,
  input            [15:0] r1_mc1b_coeff_imon,
  input            [15:0] r1_mc2a_coeff_imon,
  input            [15:0] r1_mc2b_coeff_imon,
  input            [15:0] r1_mc3a_coeff_imon,
  input            [15:0] r1_mc3b_coeff_imon,
  input            [15:0] r1_mcgn_coeff_imon,
  input            [15:0] r2_mc1a_quad_coeff_imon,
  input            [15:0] r2_mc1b_quad_coeff_imon,
  input            [15:0] r2_mc2a_quad_coeff_imon,
  input            [15:0] r2_mc2b_quad_coeff_imon,
  input            [15:0] r2_mc3a_quad_coeff_imon,
  input            [15:0] r2_mc3b_quad_coeff_imon,
  input            [15:0] r2_mcgn_quad_coeff_imon,
  input            [15:0] r2_mc1a_coeff_imon,
  input            [15:0] r2_mc1b_coeff_imon,
  input            [15:0] r2_mc2a_coeff_imon,
  input            [15:0] r2_mc2b_coeff_imon,
  input            [15:0] r2_mc3a_coeff_imon,
  input            [15:0] r2_mc3b_coeff_imon,
  input            [15:0] r2_mcgn_coeff_imon,
  input                   r1_mcxx_coeff_ovrd_en_imon, r2_mcxx_coeff_ovrd_en_imon,
  input            [15:0] r1_mc1a_coeff_ovrd_imon, r2_mc1a_coeff_ovrd_imon,
  input            [15:0] r1_mc1b_coeff_ovrd_imon, r2_mc1b_coeff_ovrd_imon,
  input            [15:0] r1_mc2a_coeff_ovrd_imon, r2_mc2a_coeff_ovrd_imon,
  input            [15:0] r1_mc2b_coeff_ovrd_imon, r2_mc2b_coeff_ovrd_imon,
  input            [15:0] r1_mc3a_coeff_ovrd_imon, r2_mc3a_coeff_ovrd_imon,
  input            [15:0] r1_mc3b_coeff_ovrd_imon, r2_mc3b_coeff_ovrd_imon,
  input            [15:0] r1_mcgn_coeff_ovrd_imon, r2_mcgn_coeff_ovrd_imon,
  input                   input_delay_disable_vmon,
  input             [5:0] input_delay_cntl_vmon,
  input                   input_delay_disable_imon,
  input             [5:0] input_delay_cntl_imon,
  input                   dec_data_offset_uncal_vimon,
  input                   dec_data_vbst_offset_uncal_imon,
  input                          [1:0] data_in_avg_sel_vbst,
  input                                data_in_enabled_vbst,
  input         [SUPP_INPUT_WIDTH-1:0] data_in_vbst,
  input                                data_in_valid_toggle_vbst,

  input         [SUPP_INPUT_WIDTH-1:0] otpcal_code_zoffs_otp_val_imon,
  input    [SUPP_MULT_COEFF_WIDTH-1:0] otpcal_mult_coeff_otp_val_imon,
  input                          [1:0] otpcal_scale_offset_sel_imon,
  input                   imon_tempco_a_sign_otp_val,
  input             [5:0] imon_tempco_a_otp_val,
  input                   imon_tempco_b_sign_otp_val,
  input             [5:0] imon_tempco_b_otp_val,
  input             [8:0] vimon_temperature_reference,
  input                   temp_valid,
  input             [8:0] temp_val,
  input                   filtered_temp_valid,
  input                   otpcal_cm_gain_s_otp_val_vimon,
  input             [9:0] otpcal_cm_gain_otp_val_vimon,
  input             [3:0] cm_gain_adder_vimon,         
  input             [  VMON_GAIN_INPUT_WIDTH-1:0] otpcal_gain_otp_val_vmon,
  input             [VMON_OFFSET_INPUT_WIDTH-1:0] otpcal_offset_otp_val_vmon,
  input             [  IMON_GAIN_INPUT_WIDTH-1:0] otpcal_gain_otp_val_imon,
  input             [IMON_OFFSET_INPUT_WIDTH-1:0] otpcal_offset_otp_val_imon,

  input                   cal_const_updated,   
  input                   supply_is_valid,  
  input                   supply_latency_bypass,   
  input                   supply_latency_cntl_ovrd_en,   
  input             [2:0] supply_latency_cntl_ovrd,
  input                   vimon_cal_temp_calcs_ungated      ,
  input                   vimon_cal_const_calcs_ungated     ,
  input                   vimon_cal_scale_ovrd_en     ,
  input            [15:0] cal_scale_ovrd_vmon  ,
  input            [15:0] cal_oneby_scale_ovrd_vmon ,
  input            [15:0] cal_scale_ovrd_imon  ,
  input            [15:0] cal_oneby_scale_ovrd_imon ,
  input             [5:0] vmon_tempco_a_otp_val ,
  input             [5:0] vmon_tempco_b_otp_val ,
  input                   vmon_tempco_a_sign_otp_val ,   
  input                   vmon_tempco_b_sign_otp_val ,   
  input [SUPP_MULT_COEFF_WIDTH-1:0] otpcal_mult_coeff_otp_val_vmon ,

  input                   cp_imon_rcal_pol,
  input                   cp_imon_rcal_mute,
  input [2:0]             cp_imon_rcal_code_diff_thres,
  input                   cp_drv_adj_en,
  input                   cp_disable_cm_iso_during_rcal,     
  input                   cp_force_drv_adj,
  input signed [13:0]     cp_leak_res_constant_dc,
  input signed [13:0]     cp_leak_res_constant_ac,     
  input                   cp_imon_data_source_sel,
  input                   cp_imon_rcal_revert_code,
  input  [5:0]            cp_imon_rcal_revertcode_diffmargin,
  input                   cp_imon_rcal_roundtozero,
  input  [2:0]            cp_imon_rcal_roundzero_intrcnt_thres,
  input [14:0]            cp_imon_rcal_roundtozero_thres,

// Input for AFE RCAL
  input        imon_pup_cal_req,
  input        dac_msm_imon_pupcal_en,
  input        dhl_run_hlsync,		     
   
  // VPMON Inputs for AFE RCAL
  input  [11:0]           vp_scaled_datacode_filt_avg8,
  input  [11:0]           vp_scaled_datacode_filt_avg4,
  input  [11:0]           vp_scaled_datacode_filt_avg2,
  input  [10:0]           vp_scaled_datacode_filt_byp,
  input  [2:0]            cp_vpmon_inpsel_rcal,
  input  [10:0]           cp_vpmon_inp_data,
		          
  input [1:0] 	          cp_vpmon_inpsel_bypass_hys,
  input [10:0]            cp_vpmon_bypass_hys_h_level,
  input [10:0]            cp_vpmon_bypass_hys_l_level,
  input                   cp_imon_bypass_ovrde,
  input                   cp_imon_bypass_ovrde_val,
     
  input                   cp_cal_method,
  input                   cp_drv_option,
  input [2:0]             cp_max_iteration_posbank,
  input [2:0]             cp_max_iteration_negbank,
  input                   cp_imon_rcal_early_terminate,
  input                   cp_imon_rcal_early_terminate0,
  input [2:0]             cp_imon_rcal_earlyterm_intrcnt_thres,     
  input [1:0]             cp_stl_cnt_adj [7:0],
  input [7:0]             cp_start_code_posbank,
  input [7:0]             cp_start_code_negbank,
  input [7:0]             cp_otp_code_posbank,
  input [7:0]             cp_otp_code_negbank,
  input                   cp_initial_code_is_otp,
  input [25:0]            cp_rcal_gain_adj_dc,
  input [25:0]            cp_rcal_gain_adj_ac,
  input                   cp_rcal_adj_code,
  input [9:0]             cp_rcal_ac_period_thres,
  input                   cp_imon_pupcal_dacmsm_en_ovde_en,
  input                   cp_imon_rcal_pos_itercnt_disable,
  input                   cp_imon_rcal_neg_itercnt_disable,
  input                   cp_imon_rcal_posbank_en,
  input 	          cp_imon_rcal_negbank_en,      

  input                   cp_imon_rcal_add_minusb,
  input                   cp_imon_afe_rcal_prog_override,
  input                   cp_imon_afe_rcal_prog_val,
  input                   cp_imon_rnn_switch_off_override,
  input                   cp_imon_rnn_switch_off_val,
  input                   cp_imon_rnp_switch_off_override,
  input                   cp_imon_rnp_switch_off_val,
  input [7:0]             cp_max_filtp_delay_cnt,
  input [3:0]             cp_trim_cnt_thres,
  input [5:0]             cp_dly_cnt_thres,
  input [1:0]             cp_lpf_fc_sel,
  input                   cp_lpf_coef_ovrde,
  input [22:0]            cp_lpf_coef_ovrde_val,
  input                   cp_fir_6tap_3tapb,
  input                   cp_fir_bypass,
  input [2:0]             cp_mvgavg_sample_size,
  input [9:0]             cp_filt_stl_smp,
  input                   cp_no_fc_stl_adj,
  input                   cp_force_fsm_st,
  input [3:0]             cp_force_fsm_st_val,
  input                   cp_force_drvfsm_st,
  input [3:0]             cp_force_drvfsm_st_val,
  input                   cp_imon_afecal_drv_ovde_en,
  input                   cp_imon_pupcal_ov_en_ovde,
  input                   cp_imon_tbridge_force_pch_hizb_ovde,
  input                   cp_imon_tbridge_force_mch_hizb_ovde,
  input                   cp_imon_tbridge_force_pch_pull_gndp_ovde,
  input                   cp_imon_tbridge_force_mch_pull_gndp_ovde,
  input                   cp_imon_quantout_p_ovde,
  input                   cp_imon_quantout_m_ovde,     
  input                   cp_force_afe_rcal_clock_on,
  input                   cp_keep_afe_rcal_fsm_on,
  input [3:0]             cp_rcal_asp_data_sel,
  input                   cp_otp_posbank_ovrd,
  input                   cp_otp_negbank_ovrd,
  input                   cp_clear_cal_code_valid,
  input                   cp_enable_force_filter,
  input                   cp_enable_force_filter_sel,
  input    	          cp_vpmon_sample_en,
  input  [1:0] 	          cp_vpmon_sample_regval,
  input  [7:0] 	          cp_vpmon_sample_interval,
  input                   cp_pdnb_dly_sel,
     
   
  // inputs to adc_fsm
  input                    ng_pdn_ana,
  input                    ng_active_vmon,
  input                    afe_ready_vmon,
  input                    adc_ready1_vmon,
  input                    adc_ready2_vmon,
  input                    ng_active_imon,
  input                    afe_ready_imon,
  input                    adc_ready1_imon,
  input                    adc_ready2_imon,

  input                    force_ng_vmon,
  input                    forced_ng_vmon,
  input                    force_adc_state_vmon,
  input              [2:0] forced_adc_state_vmon,
  input                    force_adc_outputs_vmon,
  input                    forced_powered_dn_vmon,
  input                    forced_afe_pdnb_vmon,
  input                    forced_adc_pdnb_vmon,
  input                    forced_adc_rstb_vmon,
  input                    forced_powered_up_vmon,
  input                    force_ng_imon,
  input                    forced_ng_imon,
  input                    force_adc_state_imon,
  input              [2:0] forced_adc_state_imon,
  input                    force_adc_outputs_imon,
  input                    forced_powered_dn_imon,
  input                    forced_powered_up_imon,
  input                    forced_adc_pdnb_imon,
  input                    forced_adc_rstb_imon,
  input                    forced_afe_pdnb1_imon,
  input                    forced_afe_pdnb2_imon,
  input                    forced_afe_pdnb3_imon,
  input                    forced_afe_pdnb4_imon,        
  input                    forced_afe_pdnb_imon,
  input             [10:0] cp_prog_poweron_pulse_cnt,
  input                    cp_imon_ng_independent,

  // outputs from adc_fsm
  output                   enabled_rda,
  output                   enabled_vimon,
  output                   has_needs_vimon,
  output                   active,
  output                   powered_dn_vmon,
  output                   afe_pdnb_vmon,
  output                   adc_pdnb_vmon,
  output                   adc_rstb_vmon,
  output                   powered_up_vmon,

  output                   powered_dn_imon,
  output                   afe_pdnb1_imon,
  output                   afe_pdnb2_imon,
  output                   afe_pdnb3_imon,
  output                   afe_pdnb4_imon,		     
  output                   powered_up_imon,
  output                   afe_pdnb_imon,
  output                   adc_pdnb_imon,
  output                   adc_rstb_imon,
  // Outputs

  // AFE RCAL Interrupts/Status     
  output            imon_pupcal_done,
  output            imon_rcal_code_diff_above_thres,
  output            imon_rcal_code_saturation,
  output            imon_rcal_code_changed_by_lt_2,
  output            imon_rcal_drv_msm_err,

     
// Outputs from AFE RCAL to analog 
  output                   pdnb_imon_afecal,		      
  output [7:0]             ds_imon_afe_rinp_trim,
  output [7:0]             ds_imon_afe_rinn_trim,
  output                   ds_imon_afe_rinn_switch_off,
  output                   ds_imon_afe_rinp_switch_off,		     
  output                   dd_imon_afe_rcal_prog,
  output [31:0]            imon_rcal_asp_data,

  output                   ds_imon_afe_vddhv_bypass_pdnb,     

     // Outputs from AFE RCAL to Driver controls in DAC
  output                   imon_pupcal_ov_en,
  output                   imon_tbridge_force_pch_hizb,
  output                   imon_tbridge_force_mch_hizb,
  output                   imon_tbridge_force_pch_pull_gndp,
  output                   imon_tbridge_force_mch_pull_gndp,
  output                   imon_quantout_p,
  output                   imon_quantout_m,
     
  output                   imon_rcal_resync,
  output                   imon_rcal_cfg_override,
     
  output reg [7:0]         ao_code_posbank,
  output reg [7:0]         ao_code_negbank,
  output reg [14:0]        hist_code_posbank [7:0],
  output reg [14:0]        hist_code_negbank [7:0],
  output     [3:0]         imon_rcal_fsm_state,
  output     [3:0]         imon_rcal_drv_fsm_state,
  output     [8:0]         ao_temp_val_rcal_saved,

     
  // Outputs Datapath
  output       wire        cic_tv_out_msb_vmon,
  output       wire        cic_tv_out_msb_imon,
  output       wire        cic2_out_msb_vmon,
  output       wire        cic2_out_msb_imon,
  output       wire  [MOD_INSIZE-1:0] mod_out_sampled_vmon,
  output       wire  [MOD_INSIZE-1:0] mod_out_sampled_imon,
  output       reg  [26:0] dec_out_raw_vmon, 
  output       reg  [26:0] dec_out_raw_imon,
  output       wire        clip_flag_vmon, 
  output       wire        clip_flag_imon,
  output       wire [23:0] dec_out_data_vmon, 
  output       wire [23:0] dec_out_data_imon,
  output       wire  [3:0] dem_data_in_from_rx_rda_vmon,
  output       wire  [3:0] dem_data_in_from_rx_rda_imon,
  output       wire        dec_out_valid_vmon,
  output       wire        dec_out_valid_imon
);

  // *******************************
  // Internal Signals
  // *******************************

  wire  [MOD_INSIZE-1:0] rda_rx_mod_out_vmon,   rda_rx_mod_out_imon;
  wire  [MOD_INSIZE-1:0] rda_rx_mod_out_pdmmon;


  wire  [MOD_INSIZE-1:0] mod_out_delayed_vmon,  mod_out_delayed_imon;

  wire  [MOD_INSIZE-1:0] mod_out_selected_vmon, mod_out_selected_imon;

  wire                   rda_rx_data_extra_out;
  wire                   use_rda_rx_mod_out;

  wire                   sample_now_pulse_vmon;
  wire                   sample_now_pulse_imon;
  wire                   sample_now_pulse_common;

  reg  [99:0] visbus_from_dpath_wrap;

  wire                   afe_prog_poweron_pulse_imon;
   


  //
  // ENHANCEME : change sample_gen & cic & mac engine use case when mod input sample rate is not at 3MHz (1.5MHz and 750kHz options)
  //           :   current design supports bringing data out through RDA at 1p5M or 750k rates so can be built in fpga / emulated
  //           :   if evaluation of slower rates is needed
  //
  wire   mod_out_at_3MHz;
  wire   mod_out_at_1p5MHz;
  wire   mod_out_at_750kHz;

  assign mod_out_at_3MHz   = (freq_data_in_vimon == 2'b00); // ENHANCEME needs hooks in the cic inputs / mac engine
  assign mod_out_at_1p5MHz = (freq_data_in_vimon == 2'b01); //   if you want these rates non-nominal rates to be decimated correctly
  assign mod_out_at_750kHz = (freq_data_in_vimon == 2'b10); //   otherwise, currently, just setup to pipe ana mod_data out through rda


  // note no _pdmmon channel items here
  always_comb begin
    visbus_from_dpath_wrap = {5'b0,
                              enable_imon,enable_vmon,enabled_vimon,has_needs_vimon,active,
                              1'b0,powered_dn_imon,1'b0,adc_pdnb_imon,powered_up_imon,
                              1'b0,powered_dn_vmon,afe_pdnb_vmon,adc_pdnb_vmon,powered_up_vmon,
                              3'b0,adc_pdnb_imon,adc_rstb_imon,
                              1'b0,afe_pdnb_vmon,1'b0,adc_pdnb_vmon,adc_rstb_vmon,
                              afe_pdnb_imon, afe_pdnb1_imon, afe_pdnb2_imon, afe_pdnb3_imon, afe_pdnb4_imon,
                              5'b0,
                              5'b0,
                              5'b0,
                              mod_out_imon[4:0],
                              sample_now_pulse_imon,mod_out_sampled_imon[4:1],
                              sample_now_pulse_imon,mod_out_delayed_imon[4:1],
                              sample_now_pulse_imon,mod_out_selected_imon[4:1],
                              mod_out_vmon[4:0],
                              sample_now_pulse_vmon,mod_out_sampled_vmon[4:1],
                              sample_now_pulse_vmon,mod_out_delayed_vmon[4:1],
                              sample_now_pulse_vmon,mod_out_selected_vmon[4:1],
                              enabled_rda,1'b0,data_in_rx_rda[2:0],
                              enabled_rda,1'b0,data_out_tx_rda[2:0]
                             };
  end



   
   // VPMON LDO bypass Hystersis block

    logic [10:0] vpmon_data_bypass_hys_mux;
      
   always_comb begin
      case(cp_vpmon_inpsel_bypass_hys)
	2'b00: vpmon_data_bypass_hys_mux = vp_scaled_datacode_filt_byp;
	2'b01: vpmon_data_bypass_hys_mux = vp_scaled_datacode_filt_avg2[11:1];
	2'b10: vpmon_data_bypass_hys_mux = vp_scaled_datacode_filt_avg4[11:1];
	2'b11: vpmon_data_bypass_hys_mux = vp_scaled_datacode_filt_avg8[11:1];
	default: vpmon_data_bypass_hys_mux = vp_scaled_datacode_filt_byp;
      endcase // case (cp_vpmon_inpsel_bypass_hys)
   end
   
   logic imon_bypass_pdnb;

   // imon_afe_vddhv_bypass_pdnb hystersis block.
   // Runs off of always on mclk so the signal has same timing as the rest of the adc_fsm signals.
   vimon_vp_bypass_hys #(
			 .IN_WIDTH (11),
			 .DELTA_WIDTH (0),
			 .UP_DN_B_DEF (0),
			 .CNT_UP_EN (0),
			 .CNT_DN_EN (0),
			 .CNT_WIDTH (1)
			 ) u_vimon_vp_bypass_hys 
     (
      // inputs
      .clk  (mclk),
      .rstb (rsb_mclk),

      .en (supply_is_valid & afe_pdnb1_imon),
      .in (vpmon_data_bypass_hys_mux),
      .in_vld (supply_is_valid),

      .h_level (cp_vpmon_bypass_hys_h_level),
      .l_level (cp_vpmon_bypass_hys_l_level),

      .cp_cnt_up_max (1'b0),
      .cp_cnt_dn_max (1'b0),

      // outputs
      .up_dn_b (imon_bypass_pdnb)
      );

   assign ds_imon_afe_vddhv_bypass_pdnb = cp_imon_bypass_ovrde ?  // synopsys infer_mux_override
					  cp_imon_bypass_ovrde_val : imon_bypass_pdnb;  
   
   
   
   
  adc_fsm adc_fsm (
  // inputs
  .clk                                 ( mclk                            ),
  .rsb                                 ( rsb_mclk                        ),
  .enable_vmon                         ( enable_vmon                     ),
  .enable_imon                         ( enable_imon                     ),
  .enable_rda                          ( enable_rda                      ),
  .ng_pdn_ana                          ( ng_pdn_ana                      ),
  .ng_active_vmon                      ( ng_active_vmon                  ),
  .afe_ready_vmon                      ( afe_ready_vmon                  ),
  .adc_ready1_vmon                     ( adc_ready1_vmon                 ),
  .adc_ready2_vmon                     ( adc_ready2_vmon                 ),
  .ng_active_imon                      ( ng_active_imon                  ),
  .afe_ready_imon                      ( afe_ready_imon                  ),
  .adc_ready1_imon                     ( adc_ready1_imon                 ),
  .adc_ready2_imon                     ( adc_ready2_imon                 ),
  .force_ng_vmon                       ( force_ng_vmon                   ),
  .forced_ng_vmon                      ( forced_ng_vmon                  ),
  .force_adc_state_vmon                ( force_adc_state_vmon            ),
  .forced_adc_state_vmon               ( forced_adc_state_vmon           ),
  .force_adc_outputs_vmon              ( force_adc_outputs_vmon          ),
  .forced_powered_dn_vmon              ( forced_powered_dn_vmon          ),
  .forced_afe_pdnb_vmon                ( forced_afe_pdnb_vmon            ),
  .forced_adc_pdnb_vmon                ( forced_adc_pdnb_vmon            ),
  .forced_adc_rstb_vmon                ( forced_adc_rstb_vmon            ),
  .forced_powered_up_vmon              ( forced_powered_up_vmon          ),
  .force_ng_imon                       ( force_ng_imon                   ),
  .forced_ng_imon                      ( forced_ng_imon                  ),
  .force_adc_state_imon                ( force_adc_state_imon            ),
  .forced_adc_state_imon               ( forced_adc_state_imon           ),
  .force_adc_outputs_imon              ( force_adc_outputs_imon          ),
  .forced_powered_dn_imon              ( forced_powered_dn_imon          ),
  .forced_powered_up_imon              ( forced_powered_up_imon          ),
  .forced_afe_pdnb1_imon               ( forced_afe_pdnb1_imon           ),
  .forced_afe_pdnb2_imon               ( forced_afe_pdnb2_imon           ),
  .forced_afe_pdnb3_imon               ( forced_afe_pdnb3_imon           ),
  .forced_afe_pdnb4_imon               ( forced_afe_pdnb4_imon           ),		   
  .forced_afe_pdnb_imon                ( forced_afe_pdnb_imon            ),
  .forced_adc_pdnb_imon                ( forced_adc_pdnb_imon            ),
  .forced_adc_rstb_imon                ( forced_adc_rstb_imon            ),
  .cp_prog_poweron_pulse_cnt           ( cp_prog_poweron_pulse_cnt       ),
  .cp_imon_ng_independent              ( cp_imon_ng_independent          ),
  .cp_pdnb_dly_sel                     ( cp_pdnb_dly_sel                 ), 		   

  // outputs
  .enabled_rda                         ( enabled_rda                     ),
  .enabled_vimon                       ( enabled_vimon                   ),
  .has_needs_vimon                     ( has_needs_vimon                 ),
  .active                              ( active                          ),
  .powered_dn_vmon                     ( powered_dn_vmon                 ),
  .afe_pdnb_vmon                       ( afe_pdnb_vmon                   ),
  .adc_pdnb_vmon                       ( adc_pdnb_vmon                   ),
  .adc_rstb_vmon                       ( adc_rstb_vmon                   ),
  .powered_up_vmon                     ( powered_up_vmon                 ),
  .afe_prog_poweron_pulse_vmon         ( /* NC */                        ),
  .powered_dn_imon                     ( powered_dn_imon                 ),
  .afe_pdnb1_imon                      ( afe_pdnb1_imon                  ), 
  .afe_pdnb2_imon                      ( afe_pdnb2_imon                  ),
  .afe_pdnb3_imon                      ( afe_pdnb3_imon                  ),
  .afe_pdnb4_imon                      ( afe_pdnb4_imon                  ),
  .afe_pdnb_imon                       ( afe_pdnb_imon                   ),
  .adc_pdnb_imon                       ( adc_pdnb_imon                   ),
  .adc_rstb_imon                       ( adc_rstb_imon                   ),
  .afe_prog_poweron_pulse_imon         ( afe_prog_poweron_pulse_imon     ),
  .powered_up_imon                     ( powered_up_imon                 )
  );

  dpath_adc_allrates_rda_tx_rx dpath_adc_rda_tx_rx (
    // inputs
    .clk                                  (mclk_rda                         ),
    .resetb                               (rsb_mclk_rda                     ),
    .tx_enable                            (enable_tx_rda                    ),
    .rx_enable                            (enable_rx_rda                    ),
    .rx_sync_master_sel                   (sync_master_sel_rx_rda           ), // 0 = rx_sync input used for rx_data (only when tx disabled), 1 = tx_sync used to align rx_data
    // 
    // RX SIDE
    //
    // inputs
    .rx_sync                              (data_in_rx_rda[2]                ),
    .rx_data1_to_receive                  (data_in_rx_rda[1]                ),
    .rx_data0_to_receive                  (data_in_rx_rda[0]                ),
    // outputs
    .rx_data1                             (rda_rx_mod_out_vmon              ), // {5'hVMON}
    .rx_data0                             (rda_rx_mod_out_imon              ), // {5'hIMON}
    .rx_data_extra                        ({rda_rx_data_extra_out,rda_rx_mod_out_pdmmon}), // {1'bx,5'hPDMMON} 
    //
    // TX SIDE
    //
    // inputs
    .latch_enable                         (sample_now_pulse_common          ), // At least one clk cycle wide (12M to 24M in this block, pulse gen on fe inside block)
    .tx_data_to_send                      ({1'b0,
                                            5'b0,
                                            mod_out_sampled_imon,
                                            mod_out_sampled_vmon}           ), // {1'bx,5'hPDMMON,5'hIMON,5'hVMON}
    // outputs
    .tx_sync                              (data_out_tx_rda[2]               ),
    .tx_data1                             (data_out_tx_rda[1]               ),
    .tx_data0                             (data_out_tx_rda[0]               )
   );

  dpath_adc_allrates_sample_gen #(
     .MOD_INSIZE         (MOD_INSIZE               ) 
     ) dpath_adc_sample_gen_vmon (
     // inputs
     .ck_sample          (mclk_adc_vmon            ),
     .rsb_ck_sample      (rsb_mclk_adc_vmon        ),
     .ck_dec             (mclk_adc_dec_vmon        ),
     .rsb_ck_dec         (rsb_mclk_adc_dec_vmon    ),
     .enable             (powered_up_vmon          ),
     .sample_sel         (sample_edge_sel_vimon    ),
     .mod_out_at_3MHz    (mod_out_at_3MHz          ),
     .mod_out_at_1p5MHz  (mod_out_at_1p5MHz        ),
     .mod_out_at_750kHz  (mod_out_at_750kHz        ),
     .mod_out            (mod_out_vmon             ),
     // outputs
     .mod_out_sampled    (mod_out_sampled_vmon     ),
     .sample_now_pulse   (sample_now_pulse_vmon    )
    );

  dpath_adc_allrates_sample_gen #(
     .MOD_INSIZE         (MOD_INSIZE               ) 
     ) dpath_adc_sample_gen_imon (
     // inputs
     .ck_sample          (mclk_adc_imon            ),
     .rsb_ck_sample      (rsb_mclk_adc_imon        ),
     .ck_dec             (mclk_adc_dec_imon        ),
     .rsb_ck_dec         (rsb_mclk_adc_dec_imon    ),
     .enable             (powered_up_imon          ),
     .sample_sel         (sample_edge_sel_vimon    ),
     .mod_out_at_3MHz    (mod_out_at_3MHz          ),
     .mod_out_at_1p5MHz  (mod_out_at_1p5MHz        ),
     .mod_out_at_750kHz  (mod_out_at_750kHz        ),
     .mod_out            (mod_out_imon             ),
     // outputs
     .mod_out_sampled    (mod_out_sampled_imon     ),
     .sample_now_pulse   (sample_now_pulse_imon    )
    );


  assign sample_now_pulse_common = powered_up_vmon   ? sample_now_pulse_vmon   :
                                   powered_up_imon   ? sample_now_pulse_imon   : 1'b0;

  assign use_rda_rx_mod_out = (enabled_rda & enable_rx_rda & mod_out_dig_from_rx_rda);

  assign dem_data_in_from_rx_rda_vmon = rda_rx_mod_out_vmon[4:1];
  assign dem_data_in_from_rx_rda_imon = rda_rx_mod_out_imon[4:1];

  dpath_adc_allrates_prog_latency #(
    .BITWIDTH       ( 5                            ),
    .MAX_DELAY      ( 64                           )
    ) dpath_adc_prog_latency_vmon (
    // inputs
    .clk            (mclk_adc_dec_vmon             ),
    .resetb         (rsb_mclk_adc_dec_vmon         ),
    .enable         (powered_up_vmon               ),
    .din            (mod_out_sampled_vmon          ),
    .shift_en       (sample_now_pulse_vmon         ),
    .latency_bypass (input_delay_disable_vmon      ),
    .latency_cntl   (input_delay_cntl_vmon         ),
    // outputs
    .dout           (mod_out_delayed_vmon          )
    );
  
  dpath_adc_allrates_prog_latency #(
    .BITWIDTH       ( 5                            ),
    .MAX_DELAY      ( 64                           )
    ) dpath_adc_prog_latency_imon (
    // inputs
    .clk            (mclk_adc_dec_imon             ),
    .resetb         (rsb_mclk_adc_dec_imon         ),
    .enable         (powered_up_imon               ),
    .din            (mod_out_sampled_imon          ),
    .shift_en       (sample_now_pulse_imon         ),
    .latency_bypass (input_delay_disable_imon      ),
    .latency_cntl   (input_delay_cntl_imon         ),
    // outputs
    .dout           (mod_out_delayed_imon          )
    );



  dpath_adc_allrates_input_sel dpath_adc_input_sel (
    // inputs
    .enable_vmon                  (powered_up_vmon           ),
    .enable_imon                  (powered_up_imon           ), 
    .enable_pdmmon                (1'b0                      ), 
    .mod_out_vmon                 (mod_out_delayed_vmon      ),
    .mod_out_imon                 (mod_out_delayed_imon      ),
    .mod_out_pdmmon               (5'b0                      ),
    .mod_out_rda_vmon             (rda_rx_mod_out_vmon       ),
    .mod_out_rda_imon             (rda_rx_mod_out_imon       ),
    .mod_out_rda_pdmmon           (5'b0                      ),
    .use_rda_rx_mod_out           (use_rda_rx_mod_out        ),
    .invert_vmon                  (invert_vmon               ),
    .invert_imon                  (invert_imon               ),
    .invert_pdmmon                (1'b1                      ), // hook up in previous 1 bit block where pdmmon is sampled initially
    .enable_out                   (1'b1                      ),
    .channel_mux_sel              (channel_mux_sel           ),  // invert / channel swap / copy (final manipulation)
    // outputs
    .mod_out_final_pdmmon         (   ),
    .mod_out_final_vmon           (mod_out_selected_vmon     ),
    .mod_out_final_imon           (mod_out_selected_imon     )
   );

  dpath_adc_allrates_top #(
    .SUPPORT_RARE_RATE_COMBOS              (SUPPORT_RARE_RATE_COMBOS        ),
    .MOD_INSIZE                            (MOD_INSIZE + BITWIDTHGROWTH     ),
    .VMON_GAIN_INPUT_WIDTH                 (VMON_GAIN_INPUT_WIDTH           ),
    .VMON_OFFSET_INPUT_WIDTH               (VMON_OFFSET_INPUT_WIDTH         ),
    .IMON_GAIN_INPUT_WIDTH                 (IMON_GAIN_INPUT_WIDTH           ),
    .IMON_OFFSET_INPUT_WIDTH               (IMON_OFFSET_INPUT_WIDTH         ),
    .SUPP_MULT_COEFF_WIDTH                 (SUPP_MULT_COEFF_WIDTH           ),
    .SUPP_INPUT_WIDTH                      (SUPP_INPUT_WIDTH                )

    ) dpath_adc_top (
    // inputs
    .mclk                                  ( mclk                           ),
    .rsb_mclk                              ( rsb_mclk                       ),
    .mclk_dec                              (mclk_dec                        ),
    .rsb_mclk_dec                          (rsb_mclk_dec                    ), 
    .mclk_adc_dec_vmon                     (mclk_adc_dec_vmon               ),
    .rsb_mclk_adc_dec_vmon                 (rsb_mclk_adc_dec_vmon           ), 
    .mclk_adc_dec_imon                     (mclk_adc_dec_imon               ),
    .rsb_mclk_adc_dec_imon                 (rsb_mclk_adc_dec_imon           ),
    .mclk_cal                              (mclk_cal                        ),
    .rsb_mclk_cal                          (rsb_mclk_cal                    ),
    .mclk_imon_afecal                      (mclk_imon_afecal                ),
    .rsb_mclk_imon_afecal                  (rsb_mclk_imon_afecal            ),

    .tock_1ms_6mhz                         (tock_1ms_6mhz                   ),
    .tick_1us_6mhz                         (tick_1us_6mhz                   ),
		     
    .powered_up_vmon                       (powered_up_vmon                 ),
    .powered_up_imon                       (powered_up_imon                 ),
    .afe_prog_poweron_pulse_imon           (afe_prog_poweron_pulse_imon     ),     		     
    .mclk_rate                             (mclk_rate                       ),
    .asp_rate                              (asp_rate                        ),
    .resp2_resp1b                          (response_type                   ),
    .free_running                          (free_running                    ),
    .fs_local_pulse                        (fs_local_pulse                  ),
    .force_dp_sync_rst_vimon               (force_dp_sync_rst_vimon         ),
    .shift_rslt_valid_amt_r1               (shift_rslt_valid_amt_r1         ),
    .shift_rslt_valid_amt_r2               (shift_rslt_valid_amt_r2         ),
    .mod_out_vmon                          (mod_out_selected_vmon           ), 
    .mod_out_imon                          (mod_out_selected_imon           ),
    .data_out_clip_off_vimon               (data_out_clip_off_vimon         ), 
    .alu_out_clip_off_vimon                (alu_out_clip_off_vimon          ), 
    .alu_mlt_clip_off_vimon                (alu_mlt_clip_off_vimon          ), 
    .vol_mute_gt_m102                      (vol_mute_gt_m102                ), 
    .vol_disable_vmon                      (vol_disable_vmon                ), 
    .vol_disable_imon                      (vol_disable_imon                ), 
    .dig_offset_vimon                      (dig_offset_vimon                ), 
    .vol_cntl_vmon                         (vol_cntl_vmon                   ),
    .vol_cntl_imon                         (vol_cntl_imon                   ), 
    .filter_out_stage                      (filter_out_stage                ),
    .enable_filter_stages                  (enable_filter_stages            ),
    .enable_vis                            (enable_vis                      ),
    .addr_vis                              (addr_vis                        ),
    .vis_data_en_vbst                      (vis_data_en_vbst                ),
    .visbus_from_vimon_top                 (visbus_from_vimon_top           ),
    .visbus_from_dpath_wrap                (visbus_from_dpath_wrap          ),
    .data_out_vis                          (data_out_vis                    ),
    // for otp_cal
    .invert_vmon                           (invert_vmon                     ),
    .invert_imon                           (invert_imon                     ),
    .r1_lpf1_coeff_vmon                    (r1_lpf1_coeff_vmon              ),
    .r1_lpf2_coeff_vmon                    (r1_lpf2_coeff_vmon              ),
    .r1_lpf3_coeff_vmon                    (r1_lpf3_coeff_vmon              ),
    .r1_lpf4_coeff_vmon                    (r1_lpf4_coeff_vmon              ),
    .r1_lpf5_coeff_vmon                    (r1_lpf5_coeff_vmon              ),
    .r1_lpf6_coeff_vmon                    (r1_lpf6_coeff_vmon              ),
    .r1_lpf7_coeff_vmon                    (r1_lpf7_coeff_vmon              ),
    .r1_lpf8_coeff_vmon                    (r1_lpf8_coeff_vmon              ),
    .r1_lpf9_coeff_vmon                    (r1_lpf9_coeff_vmon              ),
    .r1_pc1_coeff_vmon                     (r1_pc1_coeff_vmon               ),
    .r1_pc2_coeff_vmon                     (r1_pc2_coeff_vmon               ),
    .r1_pc3_coeff_vmon                     (r1_pc3_coeff_vmon               ),
    .r1_pc4_coeff_vmon                     (r1_pc4_coeff_vmon               ),
    .r1_mc1a_double_coeff_vmon             (r1_mc1a_double_coeff_vmon       ),
    .r1_mc1b_double_coeff_vmon             (r1_mc1b_double_coeff_vmon       ),
    .r1_mc2a_double_coeff_vmon             (r1_mc2a_double_coeff_vmon       ),
    .r1_mc2b_double_coeff_vmon             (r1_mc2b_double_coeff_vmon       ),
    .r1_mc3a_double_coeff_vmon             (r1_mc3a_double_coeff_vmon       ),
    .r1_mc3b_double_coeff_vmon             (r1_mc3b_double_coeff_vmon       ),
    .r1_mcgn_double_coeff_vmon             (r1_mcgn_double_coeff_vmon       ),
    .r1_mc1a_coeff_vmon                    (r1_mc1a_coeff_vmon              ),
    .r1_mc1b_coeff_vmon                    (r1_mc1b_coeff_vmon              ),
    .r1_mc2a_coeff_vmon                    (r1_mc2a_coeff_vmon              ),
    .r1_mc2b_coeff_vmon                    (r1_mc2b_coeff_vmon              ),
    .r1_mc3a_coeff_vmon                    (r1_mc3a_coeff_vmon              ),
    .r1_mc3b_coeff_vmon                    (r1_mc3b_coeff_vmon              ),
    .r1_mcgn_coeff_vmon                    (r1_mcgn_coeff_vmon              ),
    .r2_lpf1_coeff_vmon                    (r2_lpf1_coeff_vmon              ),
    .r2_lpf2_coeff_vmon                    (r2_lpf2_coeff_vmon              ),
    .r2_lpf3_coeff_vmon                    (r2_lpf3_coeff_vmon              ),
    .r2_lpf4_coeff_vmon                    (r2_lpf4_coeff_vmon              ),
    .r2_lpf5_coeff_vmon                    (r2_lpf5_coeff_vmon              ),
    .r2_lpf6_coeff_vmon                    (r2_lpf6_coeff_vmon              ),
    .r2_lpf7_coeff_vmon                    (r2_lpf7_coeff_vmon              ),
    .r2_lpf8_coeff_vmon                    (r2_lpf8_coeff_vmon              ),
    .r2_lpf9_coeff_vmon                    (r2_lpf9_coeff_vmon              ),
    .r2_pc1_coeff_vmon                     (r2_pc1_coeff_vmon               ),
    .r2_pc2_coeff_vmon                     (r2_pc2_coeff_vmon               ),
    .r2_pc3_coeff_vmon                     (r2_pc3_coeff_vmon               ),
    .r2_pc4_coeff_vmon                     (r2_pc4_coeff_vmon               ),
    .r2_mc1a_quad_coeff_vmon               (r2_mc1a_quad_coeff_vmon         ),
    .r2_mc1b_quad_coeff_vmon               (r2_mc1b_quad_coeff_vmon         ),
    .r2_mc2a_quad_coeff_vmon               (r2_mc2a_quad_coeff_vmon         ),
    .r2_mc2b_quad_coeff_vmon               (r2_mc2b_quad_coeff_vmon         ),
    .r2_mc3a_quad_coeff_vmon               (r2_mc3a_quad_coeff_vmon         ),
    .r2_mc3b_quad_coeff_vmon               (r2_mc3b_quad_coeff_vmon         ),
    .r2_mcgn_quad_coeff_vmon               (r2_mcgn_quad_coeff_vmon         ),
    .r2_mc1a_coeff_vmon                    (r2_mc1a_coeff_vmon              ),
    .r2_mc1b_coeff_vmon                    (r2_mc1b_coeff_vmon              ),
    .r2_mc2a_coeff_vmon                    (r2_mc2a_coeff_vmon              ),
    .r2_mc2b_coeff_vmon                    (r2_mc2b_coeff_vmon              ),
    .r2_mc3a_coeff_vmon                    (r2_mc3a_coeff_vmon              ),
    .r2_mc3b_coeff_vmon                    (r2_mc3b_coeff_vmon              ),
    .r2_mcgn_coeff_vmon                    (r2_mcgn_coeff_vmon              ),
    .r1_lpf1_coeff_imon                    (r1_lpf1_coeff_imon              ),
    .r1_lpf2_coeff_imon                    (r1_lpf2_coeff_imon              ),
    .r1_lpf3_coeff_imon                    (r1_lpf3_coeff_imon              ),
    .r1_lpf4_coeff_imon                    (r1_lpf4_coeff_imon              ),
    .r1_lpf5_coeff_imon                    (r1_lpf5_coeff_imon              ),
    .r1_lpf6_coeff_imon                    (r1_lpf6_coeff_imon              ),
    .r1_lpf7_coeff_imon                    (r1_lpf7_coeff_imon              ),
    .r1_lpf8_coeff_imon                    (r1_lpf8_coeff_imon              ),
    .r1_lpf9_coeff_imon                    (r1_lpf9_coeff_imon              ),
    .r1_pc1_coeff_imon                     (r1_pc1_coeff_imon               ),
    .r1_pc2_coeff_imon                     (r1_pc2_coeff_imon               ),
    .r1_pc3_coeff_imon                     (r1_pc3_coeff_imon               ),
    .r1_pc4_coeff_imon                     (r1_pc4_coeff_imon               ),
    .r1_mc1a_double_coeff_imon             (r1_mc1a_double_coeff_imon       ),
    .r1_mc1b_double_coeff_imon             (r1_mc1b_double_coeff_imon       ),
    .r1_mc2a_double_coeff_imon             (r1_mc2a_double_coeff_imon       ),
    .r1_mc2b_double_coeff_imon             (r1_mc2b_double_coeff_imon       ),
    .r1_mc3a_double_coeff_imon             (r1_mc3a_double_coeff_imon       ),
    .r1_mc3b_double_coeff_imon             (r1_mc3b_double_coeff_imon       ),
    .r1_mcgn_double_coeff_imon             (r1_mcgn_double_coeff_imon       ),
    .r1_mc1a_coeff_imon                    (r1_mc1a_coeff_imon              ),
    .r1_mc1b_coeff_imon                    (r1_mc1b_coeff_imon              ),
    .r1_mc2a_coeff_imon                    (r1_mc2a_coeff_imon              ),
    .r1_mc2b_coeff_imon                    (r1_mc2b_coeff_imon              ),
    .r1_mc3a_coeff_imon                    (r1_mc3a_coeff_imon              ),
    .r1_mc3b_coeff_imon                    (r1_mc3b_coeff_imon              ),
    .r1_mcgn_coeff_imon                    (r1_mcgn_coeff_imon              ),
    .r2_lpf1_coeff_imon                    (r2_lpf1_coeff_imon              ),
    .r2_lpf2_coeff_imon                    (r2_lpf2_coeff_imon              ),
    .r2_lpf3_coeff_imon                    (r2_lpf3_coeff_imon              ),
    .r2_lpf4_coeff_imon                    (r2_lpf4_coeff_imon              ),
    .r2_lpf5_coeff_imon                    (r2_lpf5_coeff_imon              ),
    .r2_lpf6_coeff_imon                    (r2_lpf6_coeff_imon              ),
    .r2_lpf7_coeff_imon                    (r2_lpf7_coeff_imon              ),
    .r2_lpf8_coeff_imon                    (r2_lpf8_coeff_imon              ),
    .r2_lpf9_coeff_imon                    (r2_lpf9_coeff_imon              ),
    .r2_pc1_coeff_imon                     (r2_pc1_coeff_imon               ),
    .r2_pc2_coeff_imon                     (r2_pc2_coeff_imon               ),
    .r2_pc3_coeff_imon                     (r2_pc3_coeff_imon               ),
    .r2_pc4_coeff_imon                     (r2_pc4_coeff_imon               ),
    .r2_mc1a_quad_coeff_imon               (r2_mc1a_quad_coeff_imon         ),
    .r2_mc1b_quad_coeff_imon               (r2_mc1b_quad_coeff_imon         ),
    .r2_mc2a_quad_coeff_imon               (r2_mc2a_quad_coeff_imon         ),
    .r2_mc2b_quad_coeff_imon               (r2_mc2b_quad_coeff_imon         ),
    .r2_mc3a_quad_coeff_imon               (r2_mc3a_quad_coeff_imon         ),
    .r2_mc3b_quad_coeff_imon               (r2_mc3b_quad_coeff_imon         ),
    .r2_mcgn_quad_coeff_imon               (r2_mcgn_quad_coeff_imon         ),
    .r2_mc1a_coeff_imon                    (r2_mc1a_coeff_imon              ),
    .r2_mc1b_coeff_imon                    (r2_mc1b_coeff_imon              ),
    .r2_mc2a_coeff_imon                    (r2_mc2a_coeff_imon              ),
    .r2_mc2b_coeff_imon                    (r2_mc2b_coeff_imon              ),
    .r2_mc3a_coeff_imon                    (r2_mc3a_coeff_imon              ),
    .r2_mc3b_coeff_imon                    (r2_mc3b_coeff_imon              ),
    .r2_mcgn_coeff_imon                    (r2_mcgn_coeff_imon              ),
    .r1_mcxx_coeff_ovrd_en_imon            (r1_mcxx_coeff_ovrd_en_imon      ),
    .r1_mc1a_coeff_ovrd_imon               (r1_mc1a_coeff_ovrd_imon         ),
    .r1_mc1b_coeff_ovrd_imon               (r1_mc1b_coeff_ovrd_imon         ),
    .r1_mc2a_coeff_ovrd_imon               (r1_mc2a_coeff_ovrd_imon         ),
    .r1_mc2b_coeff_ovrd_imon               (r1_mc2b_coeff_ovrd_imon         ),
    .r1_mc3a_coeff_ovrd_imon               (r1_mc3a_coeff_ovrd_imon         ),
    .r1_mc3b_coeff_ovrd_imon               (r1_mc3b_coeff_ovrd_imon         ),
    .r1_mcgn_coeff_ovrd_imon               (r1_mcgn_coeff_ovrd_imon         ),
    .r2_mcxx_coeff_ovrd_en_imon            (r2_mcxx_coeff_ovrd_en_imon      ),
    .r2_mc1a_coeff_ovrd_imon               (r2_mc1a_coeff_ovrd_imon         ),
    .r2_mc1b_coeff_ovrd_imon               (r2_mc1b_coeff_ovrd_imon         ),
    .r2_mc2a_coeff_ovrd_imon               (r2_mc2a_coeff_ovrd_imon         ),
    .r2_mc2b_coeff_ovrd_imon               (r2_mc2b_coeff_ovrd_imon         ),
    .r2_mc3a_coeff_ovrd_imon               (r2_mc3a_coeff_ovrd_imon         ),
    .r2_mc3b_coeff_ovrd_imon               (r2_mc3b_coeff_ovrd_imon         ),
    .r2_mcgn_coeff_ovrd_imon               (r2_mcgn_coeff_ovrd_imon         ),
    .dec_data_offset_uncal_vimon           (dec_data_offset_uncal_vimon     ),
    .dec_data_vbst_offset_uncal_imon       (dec_data_vbst_offset_uncal_imon ),
    .data_in_avg_sel_vbst                  (data_in_avg_sel_vbst            ),
    .data_in_enabled_vbst                  (data_in_enabled_vbst            ),
    .data_in_vbst                          (data_in_vbst                    ),
    .data_in_valid_toggle_vbst             (data_in_valid_toggle_vbst       ),

    .otpcal_code_zoffs_otp_val_imon        (otpcal_code_zoffs_otp_val_imon  ),
    .otpcal_mult_coeff_otp_val_imon        (otpcal_mult_coeff_otp_val_imon  ),
    .otpcal_scale_offset_sel_imon          (otpcal_scale_offset_sel_imon    ),
    .imon_tempco_a_sign_otp_val            (imon_tempco_a_sign_otp_val      ), 
    .imon_tempco_a_otp_val                 (imon_tempco_a_otp_val           ), 
    .imon_tempco_b_sign_otp_val            (imon_tempco_b_sign_otp_val      ), 
    .imon_tempco_b_otp_val                 (imon_tempco_b_otp_val           ), 
    .vimon_temperature_reference           (vimon_temperature_reference     ), 
		     
    .temp_valid                            (temp_valid                      ),
    .temp_val                              (temp_val                        ),
    .filtered_temp_valid                   (filtered_temp_valid             ),
    .otpcal_cm_gain_s_otp_val_vimon        (otpcal_cm_gain_s_otp_val_vimon  ),
    .otpcal_cm_gain_otp_val_vimon          (otpcal_cm_gain_otp_val_vimon    ),
    .cm_gain_adder_vimon                   (cm_gain_adder_vimon             ),   		     
    .otpcal_gain_otp_val_vmon              (otpcal_gain_otp_val_vmon        ),
    .otpcal_gain_otp_val_imon              (otpcal_gain_otp_val_imon        ),
    .otpcal_offset_otp_val_vmon            (otpcal_offset_otp_val_vmon      ),
    .otpcal_offset_otp_val_imon            (otpcal_offset_otp_val_imon      ),

    .cal_const_updated                     (cal_const_updated               ),
    .supply_is_valid                       (supply_is_valid                 ),
    .supply_latency_bypass                 (supply_latency_bypass           ),
    .supply_latency_cntl_ovrd_en           (supply_latency_cntl_ovrd_en     ),
    .supply_latency_cntl_ovrd              (supply_latency_cntl_ovrd        ),
    .vimon_cal_temp_calcs_ungated          (vimon_cal_temp_calcs_ungated    ),
    .vimon_cal_const_calcs_ungated         (vimon_cal_const_calcs_ungated   ),
    .vimon_cal_scale_ovrd_en               (vimon_cal_scale_ovrd_en         ),
    .cal_scale_ovrd_vmon                   (cal_scale_ovrd_vmon             ),
    .cal_oneby_scale_ovrd_vmon             (cal_oneby_scale_ovrd_vmon       ),
    .cal_scale_ovrd_imon                   (cal_scale_ovrd_imon             ),
    .cal_oneby_scale_ovrd_imon             (cal_oneby_scale_ovrd_imon       ),
    .vmon_tempco_a_otp_val                 (vmon_tempco_a_otp_val           ),
    .vmon_tempco_b_otp_val                 (vmon_tempco_b_otp_val           ),
    .vmon_tempco_a_sign_otp_val            (vmon_tempco_a_sign_otp_val      ),
    .vmon_tempco_b_sign_otp_val            (vmon_tempco_b_sign_otp_val      ),
    .otpcal_mult_coeff_otp_val_vmon        (otpcal_mult_coeff_otp_val_vmon  ),

    .imon_pup_cal_req                      (imon_pup_cal_req                ),
    .dac_msm_imon_pupcal_en                (dac_msm_imon_pupcal_en          ),
    .dhl_run_hlsync                        (dhl_run_hlsync                  ),
		     
    .vp_scaled_datacode_filt_avg8          (vp_scaled_datacode_filt_avg8    ),
    .vp_scaled_datacode_filt_avg4          (vp_scaled_datacode_filt_avg4    ),
    .vp_scaled_datacode_filt_avg2          (vp_scaled_datacode_filt_avg2    ),
    .vp_scaled_datacode_filt_byp           (vp_scaled_datacode_filt_byp     ),
    .cp_vpmon_inpsel_rcal                  (cp_vpmon_inpsel_rcal            ),
    .cp_vpmon_inp_data                     (cp_vpmon_inp_data               ),		     

      // RCAL register controls
    .cp_cal_method                         (cp_cal_method                   ),
    .cp_drv_option                         (cp_drv_option                   ),
    .cp_max_iteration_posbank              (cp_max_iteration_posbank        ),
    .cp_max_iteration_negbank              (cp_max_iteration_negbank        ),
    .cp_imon_rcal_early_terminate          (cp_imon_rcal_early_terminate    ),
    .cp_imon_rcal_early_terminate0         (cp_imon_rcal_early_terminate0   ),
    .cp_imon_rcal_earlyterm_intrcnt_thres  (cp_imon_rcal_earlyterm_intrcnt_thres),		     
    .cp_stl_cnt_adj                        (cp_stl_cnt_adj                  ),			   
    .cp_start_code_posbank                 (cp_start_code_posbank           ),
    .cp_start_code_negbank                 (cp_start_code_negbank           ),
    .cp_otp_code_posbank                   (cp_otp_code_posbank             ),
    .cp_otp_code_negbank                   (cp_otp_code_negbank             ),
    .cp_initial_code_is_otp                (cp_initial_code_is_otp          ),
    .cp_rcal_gain_adj_dc                   (cp_rcal_gain_adj_dc             ),
    .cp_rcal_gain_adj_ac                   (cp_rcal_gain_adj_ac             ),
    .cp_rcal_adj_code                      (cp_rcal_adj_code                ),
    .cp_rcal_ac_period_thres               (cp_rcal_ac_period_thres         ),
    .cp_imon_pupcal_dacmsm_en_ovde_en      (cp_imon_pupcal_dacmsm_en_ovde_en),
    .cp_imon_rcal_pos_itercnt_disable      (cp_imon_rcal_pos_itercnt_disable),
    .cp_imon_rcal_neg_itercnt_disable      (cp_imon_rcal_neg_itercnt_disable),
    .cp_imon_rcal_posbank_en               (cp_imon_rcal_posbank_en         ),
    .cp_imon_rcal_negbank_en               (cp_imon_rcal_negbank_en         ),

    .cp_imon_rcal_add_minusb               (cp_imon_rcal_add_minusb         ),
    .cp_imon_afe_rcal_prog_override        (cp_imon_afe_rcal_prog_override  ),
    .cp_imon_afe_rcal_prog_val             (cp_imon_afe_rcal_prog_val       ),
    .cp_imon_rnn_switch_off_override       (cp_imon_rnn_switch_off_override ),
    .cp_imon_rnn_switch_off_val            (cp_imon_rnn_switch_off_val      ),
    .cp_imon_rnp_switch_off_override       (cp_imon_rnp_switch_off_override ),
    .cp_imon_rnp_switch_off_val            (cp_imon_rnp_switch_off_val      ),
    .cp_max_filtp_delay_cnt                (cp_max_filtp_delay_cnt          ),
    .cp_trim_cnt_thres                     (cp_trim_cnt_thres               ),
    .cp_dly_cnt_thres                      (cp_dly_cnt_thres                ),
    .cp_lpf_fc_sel                         (cp_lpf_fc_sel                   ),
    .cp_lpf_coef_ovrde                     (cp_lpf_coef_ovrde               ),
    .cp_lpf_coef_ovrde_val                 (cp_lpf_coef_ovrde_val           ),
    .cp_fir_6tap_3tapb                     (cp_fir_6tap_3tapb               ),
    .cp_fir_bypass                         (cp_fir_bypass                   ),
    .cp_mvgavg_sample_size                 (cp_mvgavg_sample_size           ),
    .cp_filt_stl_smp                       (cp_filt_stl_smp                 ),
    .cp_no_fc_stl_adj                      (cp_no_fc_stl_adj                ),
    .cp_force_fsm_st                       (cp_force_fsm_st                 ),
    .cp_force_fsm_st_val                   (cp_force_fsm_st_val             ),
    .cp_force_drvfsm_st                    (cp_force_drvfsm_st              ),
    .cp_force_drvfsm_st_val                (cp_force_drvfsm_st_val          ),
    .cp_imon_afecal_drv_ovde_en            (cp_imon_afecal_drv_ovde_en      ),
    .cp_imon_pupcal_ov_en_ovde             (cp_imon_pupcal_ov_en_ovde       ),
    .cp_imon_tbridge_force_pch_hizb_ovde   (cp_imon_tbridge_force_pch_hizb_ovde ),
    .cp_imon_tbridge_force_mch_hizb_ovde   (cp_imon_tbridge_force_mch_hizb_ovde ),
    .cp_imon_tbridge_force_pch_pull_gndp_ovde (cp_imon_tbridge_force_pch_pull_gndp_ovde ),
    .cp_imon_tbridge_force_mch_pull_gndp_ovde (cp_imon_tbridge_force_mch_pull_gndp_ovde ),
    .cp_imon_quantout_p_ovde               (cp_imon_quantout_p_ovde         ),
    .cp_imon_quantout_m_ovde               (cp_imon_quantout_m_ovde         ),      		     
    .cp_force_afe_rcal_clock_on            (cp_force_afe_rcal_clock_on      ),
    .cp_keep_afe_rcal_fsm_on               (cp_keep_afe_rcal_fsm_on         ),
    .cp_rcal_asp_data_sel                  (cp_rcal_asp_data_sel            ),
    .cp_otp_posbank_ovrd                   (cp_otp_posbank_ovrd             ),
    .cp_otp_negbank_ovrd                   (cp_otp_negbank_ovrd             ),
    .cp_clear_cal_code_valid               (cp_clear_cal_code_valid         ),
    .cp_enable_force_filter                (cp_enable_force_filter          ),
    .cp_enable_force_filter_sel            (cp_enable_force_filter_sel      ),
    .cp_vpmon_sample_en                    (cp_vpmon_sample_en              ),
    .cp_vpmon_sample_regval                (cp_vpmon_sample_regval          ),
    .cp_vpmon_sample_interval              (cp_vpmon_sample_interval        ),
		     
    .cp_imon_rcal_mute                     (cp_imon_rcal_mute               ),
    .cp_imon_rcal_pol                      (cp_imon_rcal_pol                ),
    .cp_imon_rcal_code_diff_thres          (cp_imon_rcal_code_diff_thres    ),
    .cp_drv_adj_en                         (cp_drv_adj_en                   ),
    .cp_disable_cm_iso_during_rcal         (cp_disable_cm_iso_during_rcal   ),
    .cp_force_drv_adj                      (cp_force_drv_adj                ),
    .cp_leak_res_constant_dc               (cp_leak_res_constant_dc         ),
    .cp_leak_res_constant_ac               (cp_leak_res_constant_ac         ),		     
    .cp_imon_data_source_sel               (cp_imon_data_source_sel         ),
    .cp_imon_rcal_revert_code              (cp_imon_rcal_revert_code        ),
    .cp_imon_rcal_revertcode_diffmargin    (cp_imon_rcal_revertcode_diffmargin),
    .cp_imon_rcal_roundtozero              (cp_imon_rcal_roundtozero        ),
    .cp_imon_rcal_roundzero_intrcnt_thres  (cp_imon_rcal_roundzero_intrcnt_thres ),
    .cp_imon_rcal_roundtozero_thres        (cp_imon_rcal_roundtozero_thres  ),
		     

    // outputs
    .cic_tv_out_msb_vmon                   (cic_tv_out_msb_vmon             ),
    .cic_tv_out_msb_imon                   (cic_tv_out_msb_imon             ),
    .cic2_out_msb_vmon                     (cic2_out_msb_vmon               ),
    .cic2_out_msb_imon                     (cic2_out_msb_imon               ),
    .dec_out_raw_vmon                      (dec_out_raw_vmon                ), 
    .dec_out_raw_imon                      (dec_out_raw_imon                ),
    .dec_out_data_vmon                     (dec_out_data_vmon               ), // actual final result
    .dec_out_data_imon                     (dec_out_data_imon               ), // actual final result
    .clip_flag_vmon                        (clip_flag_vmon                  ),
    .clip_flag_imon                        (clip_flag_imon                  ), 
    .dec_out_valid_vmon                    (dec_out_valid_vmon              ),
    .dec_out_valid_imon                    (dec_out_valid_imon              ),

    .imon_pupcal_done                      ( imon_pupcal_done                ),
    .imon_rcal_code_diff_above_thres       ( imon_rcal_code_diff_above_thres ),
    .imon_rcal_code_saturation             ( imon_rcal_code_saturation       ),
    .imon_rcal_code_changed_by_lt_2        ( imon_rcal_code_changed_by_lt_2  ),
    .imon_rcal_drv_msm_err                 ( imon_rcal_drv_msm_err           ),

		     
// Outputs from AFE RCAL to analog
    .pdnb_imon_afecal                      (pdnb_imon_afecal                ),		      
    .ds_imon_afe_rinp_trim                 (ds_imon_afe_rinp_trim           ),
    .ds_imon_afe_rinn_trim                 (ds_imon_afe_rinn_trim           ),
    .ds_imon_afe_rinn_switch_off           (ds_imon_afe_rinn_switch_off     ),
    .ds_imon_afe_rinp_switch_off           (ds_imon_afe_rinp_switch_off     ),		     
    .dd_imon_afe_rcal_prog                 (dd_imon_afe_rcal_prog           ),
    .imon_rcal_asp_data                    (imon_rcal_asp_data              ),

// Outputs from AFE RCAL to Driver controls in DAC		     
    .imon_pupcal_ov_en                     (imon_pupcal_ov_en               ),
    .imon_tbridge_force_pch_hizb           (imon_tbridge_force_pch_hizb     ),
    .imon_tbridge_force_mch_hizb           (imon_tbridge_force_mch_hizb     ),
    .imon_tbridge_force_pch_pull_gndp      (imon_tbridge_force_pch_pull_gndp),
    .imon_tbridge_force_mch_pull_gndp      (imon_tbridge_force_mch_pull_gndp),
    .imon_quantout_p                       (imon_quantout_p                 ),
    .imon_quantout_m                       (imon_quantout_m                 ),

    .imon_rcal_resync                      (imon_rcal_resync                ),
    .imon_rcal_cfg_override                (imon_rcal_cfg_override          ),
    .ao_code_posbank                       (ao_code_posbank                 ),
    .ao_code_negbank                       (ao_code_negbank                 ),
    .hist_code_posbank                     (hist_code_posbank               ),
    .hist_code_negbank                     (hist_code_negbank               ),
    .imon_rcal_fsm_state                   (imon_rcal_fsm_state             ),
    .imon_rcal_drv_fsm_state               (imon_rcal_drv_fsm_state         ),
    .ao_temp_val_rcal_saved                (ao_temp_val_rcal_saved          )
   );

endmodule
