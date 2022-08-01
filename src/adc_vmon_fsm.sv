module adc_channel_en_fsm_imon #(
  parameter        ZERO_WAIT = 0
  ) (
  input            clk,
  input            rsb,
  input            enable,
  input            ng_pdn_ana,
  input            ng_active,
  input            afe_ready,
  input            adc_ready1,
  input            adc_ready2,

  input            force_ng,
  input            forced_ng,
  input            force_state,
  input      [2:0] forced_state,
  input            force_outputs,
  input            forced_powered_dn,
  input            forced_afe_pdnb1,
  input            forced_afe_pdnb2,
  input            forced_afe_pdnb3,
  input            forced_afe_pdnb4,     
  input            forced_afe_pdnb,
  input            forced_adc_rstb,
  input            forced_adc_pdnb,
  input            forced_powered_up,
  input     [10:0] cp_prog_poweron_pulse_cnt,
  input            cp_pdnb_dly_sel,

  output reg       powered_dn,

  output reg       afe_pdnb1,
  output reg       afe_pdnb2,
  output reg       afe_pdnb3,
  output reg       afe_pdnb4,
  output reg       afe_pdnb,
  output reg       adc_pdnb,
  output reg       adc_rstb,
  output reg       afe_prog_poweron_pulse,

  output reg       powered_up
);




   typedef enum    logic [3:0] 
		   {
		    IDLE            = 4'd0,
		    PUP_PDN1        = 4'd1,
		    PUP_PDN2        = 4'd2,
		    PUP_PDN3        = 4'd3,
		    PUP_PDN4        = 4'd4,
		    PUP_PROG        = 4'd5,
		    PUP_AFE         = 4'd6,
		    PUP_ADC         = 4'd7,
		    RUN_ADC         = 4'd8,		    
		    ADC_ENABLED     = 4'd9
		    } FSM_ST;

   FSM_ST curr_state;
   FSM_ST next_state;


  reg [10:0] cnt_dly; // clk is max 6.144MHz == 166ns per cnt;


  wire      ng_active_int;
  wire      ng_send_fsm_to_idle;

  wire      cnt_en;
  wire      hold_cnt;

  wire      prog_pulse_now;
  
  always_ff @ (posedge clk or negedge rsb) begin
    if (!rsb) begin
      curr_state   <= IDLE;
      powered_dn   <= 1'b1;
      afe_pdnb1 <= 1'b0;
      afe_pdnb2 <= 1'b0;
      afe_pdnb3 <= 1'b0;
      afe_pdnb4 <= 1'b0;       
      afe_pdnb     <= 1'b0;
      cnt_dly      <= 11'd0;
      adc_pdnb     <= 1'b0;
      adc_rstb     <= 1'b0;
      powered_up   <= 1'b0;
      afe_prog_poweron_pulse <= 1'b0;       
    end
    else begin
      if (force_state) begin
        curr_state <= FSM_ST'(forced_state);
      end
      else begin
        curr_state <= next_state;
      end

      if (force_outputs) begin
        cnt_dly      <= 11'd0;
        powered_dn   <= forced_powered_dn;
        afe_pdnb     <= forced_afe_pdnb;
        adc_pdnb     <= forced_adc_pdnb;
        adc_rstb     <= forced_adc_rstb;
        powered_up   <= forced_powered_up;
	afe_pdnb1   <= forced_afe_pdnb1;
	afe_pdnb2   <= forced_afe_pdnb2;
	afe_pdnb3   <= forced_afe_pdnb3;
	afe_pdnb4   <= forced_afe_pdnb4;	 
	 
      end
      else begin
        if (cnt_en)
          if (hold_cnt | (&cnt_dly))
            cnt_dly    <=  cnt_dly;
          else
            cnt_dly    <= (cnt_dly + 11'd1);
        else
          cnt_dly    <= 11'd0;

        powered_dn   <= ( (curr_state == IDLE) );
	afe_pdnb1    <= ( (curr_state == PUP_PDN1) || (curr_state == PUP_PDN2) || (curr_state == PUP_PDN3) || (curr_state == PUP_PDN4) || (curr_state == PUP_PROG) || (curr_state == PUP_AFE) || (curr_state == PUP_ADC) || (curr_state == RUN_ADC) || (curr_state == ADC_ENABLED) );
        afe_pdnb2    <= (                             (curr_state == PUP_PDN2) || (curr_state == PUP_PDN3) || (curr_state == PUP_PDN4) || (curr_state == PUP_PROG) || (curr_state == PUP_AFE) || (curr_state == PUP_ADC) || (curr_state == RUN_ADC) || (curr_state == ADC_ENABLED) );
	afe_pdnb3    <= (                                                         (curr_state == PUP_PDN3) || (curr_state == PUP_PDN4) || (curr_state == PUP_PROG) || (curr_state == PUP_AFE) || (curr_state == PUP_ADC) || (curr_state == RUN_ADC) || (curr_state == ADC_ENABLED) );
	afe_pdnb4    <= (                                                                                     (curr_state == PUP_PDN4) || (curr_state == PUP_PROG) || (curr_state == PUP_AFE) || (curr_state == PUP_ADC) || (curr_state == RUN_ADC) || (curr_state == ADC_ENABLED) );	 
        afe_pdnb     <= (                                                                                                                                             (curr_state == PUP_AFE) || (curr_state == PUP_ADC) || (curr_state == RUN_ADC) || (curr_state == ADC_ENABLED) );
        adc_pdnb     <= (                                                                                                                                                                        (curr_state == PUP_ADC) || (curr_state == RUN_ADC) || (curr_state == ADC_ENABLED) );
        adc_rstb     <= (                                                                                                                                                                                                   (curr_state == RUN_ADC) || (curr_state == ADC_ENABLED) );
        powered_up   <= (                                                                                                                                                                                                                              (curr_state == ADC_ENABLED) );
	afe_prog_poweron_pulse <= (curr_state == PUP_PROG) && (cnt_dly==11'd0);
      end
    end
  end


   
  assign its_been_70us  = (&cnt_dly[8:6]);
  assign its_been_10us  = cp_pdnb_dly_sel ? (cnt_dly[7:0] == 8'hbf) : (&cnt_dly[5:0]);  // select between 10us or 30us
  assign its_been_5us   = (&cnt_dly[4:0]);
  assign its_been_1us   = (&cnt_dly[2:0]);   
  assign its_been_640ns = (&cnt_dly[1:0]);

  assign its_been_prog_dly = (cnt_dly == cp_prog_poweron_pulse_cnt) && (curr_state == PUP_PDN4);
   

  assign prog_pulse_now = (cnt_dly == cp_prog_poweron_pulse_cnt);
 

  assign cnt_en = ( (curr_state == PUP_PDN1       ) && (next_state == PUP_PDN1       ) ||
		    (curr_state == PUP_PDN2       ) && (next_state == PUP_PDN2       ) ||
		    (curr_state == PUP_PDN3       ) && (next_state == PUP_PDN3       ) ||
		    (curr_state == PUP_PDN4       ) && (next_state == PUP_PDN4       ) ||		    
		    (curr_state == PUP_PROG       ) && (next_state == PUP_PROG       ) ||
                    (curr_state == PUP_AFE        ) && (next_state == PUP_AFE        ) ||
                    (curr_state == PUP_ADC        ) && (next_state == PUP_ADC        ) ||		    
                    (curr_state == RUN_ADC        ) && (next_state == RUN_ADC        )    );

  assign hold_cnt =   ( (curr_state == PUP_PDN1       ) && (next_state == PUP_PDN1       ) && its_been_10us) ||
		      ( (curr_state == PUP_PDN2       ) && (next_state == PUP_PDN2       ) && its_been_10us) ||
		      ( (curr_state == PUP_PDN3       ) && (next_state == PUP_PDN3       ) && its_been_10us) ||
		      ( (curr_state == PUP_PDN4       ) && (next_state == PUP_PDN4       ) && its_been_10us) ||		      		      
		      ( (curr_state == PUP_PROG       ) && (next_state == PUP_PROG       ) && its_been_10us) ||
                      ( (curr_state == PUP_AFE        ) && (next_state == PUP_AFE        ) && its_been_10us) ||
                      ( (curr_state == PUP_ADC        ) && (next_state == PUP_ADC        ) && its_been_70us && enable) ||		      
                      ( (curr_state == RUN_ADC        ) && (next_state == RUN_ADC        ) && its_been_640ns)   ;

  assign ng_active_int = force_ng ? forced_ng : ng_active;

  assign ng_send_fsm_to_idle = (ng_active_int & ng_pdn_ana);

  always_comb begin
    next_state = curr_state;
    case(curr_state)
      IDLE    : begin
                  if  ( enable & ~ng_send_fsm_to_idle)
                    next_state = (ZERO_WAIT == 1) ? (ng_active_int ? IDLE : ADC_ENABLED) : 
                                                     PUP_PDN1;
      end
      
      PUP_PDN1 : begin
         if      ((~enable |  ng_send_fsm_to_idle) &              its_been_10us ) // ~10us (powerdown wait)
           next_state = IDLE;
         else if (( enable & ~ng_send_fsm_to_idle) & afe_ready  & its_been_10us ) // ~10us (powerup wait)
           next_state = PUP_PDN2;
      end

      PUP_PDN2 : begin
         if      ((~enable |  ng_send_fsm_to_idle) &              its_been_10us ) // ~10us (powerdown wait)
           next_state = PUP_PDN1;
         else if (( enable & ~ng_send_fsm_to_idle) & afe_ready  & its_been_10us ) // ~10us (powerup wait)
           next_state = PUP_PDN3;
      end

      PUP_PDN3 : begin
         if      ((~enable |  ng_send_fsm_to_idle) &              its_been_10us  )// ~10us (powerdown wait)
           next_state = PUP_PDN2;
         else if (( enable & ~ng_send_fsm_to_idle) & afe_ready  & its_been_10us ) // ~10us (powerup wait)
           next_state = PUP_PDN4;
      end

      PUP_PDN4 : begin
         if      ((~enable |  ng_send_fsm_to_idle) &              its_been_10us  ) // ~10us (powerdown wait)
           next_state = PUP_PDN3;
         else if (( enable & ~ng_send_fsm_to_idle) & afe_ready  & its_been_prog_dly ) // prog delay us (powerup wait)
           next_state = PUP_PROG;
      end
      
      PUP_PROG : begin
         if      ((~enable |  ng_send_fsm_to_idle) &              its_been_10us) // ~10us (powerdown wait)
           next_state = PUP_PDN4;
         else if (( enable & ~ng_send_fsm_to_idle) & afe_ready  & its_been_1us ) // ~1us (powerup wait)
           next_state = PUP_AFE;
      end

      PUP_AFE : begin
         if      ((~enable |  ng_send_fsm_to_idle) &              its_been_10us  )// ~10us (powerdown wait)
           next_state = PUP_PDN4;                                                 // skip PUP_PROG during power down
         else if (( enable & ~ng_send_fsm_to_idle) & adc_ready1 & its_been_10us ) // ~10us (powerup wait)
           next_state = PUP_ADC;
      end

      PUP_ADC : begin
         if      ((~enable |  ng_send_fsm_to_idle) &              its_been_5us  ) // ~5us (powerdown wait)
           next_state = PUP_AFE;
         else if (( enable & ~ng_send_fsm_to_idle) & adc_ready1 & its_been_70us ) // ~70us (powerup wait)
           next_state = RUN_ADC;
      end
      
      RUN_ADC : begin
         if      ((~enable |  ng_send_fsm_to_idle) &              its_been_640ns) // ~640ns (powerdown wait)
           next_state = PUP_ADC;
         else if (( enable & ~ng_active_int      ) & adc_ready2 & its_been_640ns) // ~640ns (powerup wait)
           next_state = ADC_ENABLED;
      end

      ADC_ENABLED : begin
         if (~enable | ng_active_int) begin
            next_state = (ZERO_WAIT == 1) ? IDLE : RUN_ADC;
         end
      end
      default : begin
                  next_state = IDLE;
                end
    endcase
  end



   // DESIGN ASSERTIONS
   //synopsys translate_off

   property check_fsm_goes_to_idle;
      @(posedge clk) disable iff (!rsb)
	$fell(enable) |->  !enable[*60] |-> ##[90:450] curr_state == IDLE;
   endproperty

   ADC_FSM_CHECK_IDLE : assert property(check_fsm_goes_to_idle())
     else $error ("Time %0t, ADC_FSM did not go to idle when disabled", $realtime);
      
      //synopsys translate_on

 
   
endmodule
