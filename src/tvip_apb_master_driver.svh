//------------------------------------------------------------------------------
//  Copyright 2017 Taichi Ishitani
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//------------------------------------------------------------------------------
`ifndef TVIP_APB_MASTER_DRIVER_SVH
`define TVIP_APB_MASTER_DRIVER_SVH
class tvip_apb_master_driver extends tue_driver #(
  tvip_apb_configuration, tvip_apb_status, tvip_apb_master_item
);
  typedef enum {
    IDLE,
    SETUP,
    ACCESS,
    CONSUME_IPG
  } e_state;

  tvip_apb_vif          vif;
  e_state               state;
  tvip_apb_master_item  item;
  int                   consumed_ipg;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    vif = configuration.vif;
  endfunction

  task run_phase(uvm_phase phase);
    forever @(vif.master_cb or negedge vif.preset_n) begin
      if (!vif.preset_n) begin
        do_reset();
      end
      else begin
        if ((state == ACCESS) && vif.master_cb.pack) begin
          sample_response();
        end

        if (state == CONSUME_IPG) begin
          consume_ipg();
        end

        if ((state == IDLE) && seq_item_port.has_do_available()) begin
          get_next_item();
        end

        case (state)
          SETUP:    do_setup();
          ACCESS:   do_access();
          default:  do_idle();
        endcase
      end
    end
  endtask

  task do_reset();
    if (state inside {SETUP, ACCESS}) begin
      finish_item();
    end
    vif.reset_master();
    item  = null;
    state = IDLE;
  endtask

  task get_next_item();
    seq_item_port.get_next_item(item);
    void'(begin_tr(item));
    consumed_ipg  = 0;
    state         = SETUP;
  endtask

  task do_setup();
    vif.master_cb.psel    <= '1;
    vif.master_cb.paddr   <= item.address;
    vif.master_cb.pwrite  <= item.is_write();
    vif.master_cb.pprot   <= item.get_protection();
    if (item.is_write()) begin
      vif.master_cb.pwdata  <= item.data;
      vif.master_cb.pstrb   <= item.strobe;
    end
    else begin
      vif.master_cb.pwdata  <= '0;
      vif.master_cb.pstrb   <= '0;
    end
    state = ACCESS;
  endtask

  task do_access();
    vif.master_cb.penable <= '1;
  endtask

  task do_idle();
    vif.master_cb.psel    <= '0;
    vif.master_cb.penable <= '0;
    vif.master_cb.paddr   <= '0;
    vif.master_cb.pwrite  <= '0;
    vif.master_cb.pprot   <= '0;
    vif.master_cb.pwdata  <= '0;
    vif.master_cb.pstrb   <= '0;
  endtask

  task sample_response();
    item.slave_error  = vif.master_cb.pslverr;
    if (item.is_read()) begin
      item.data = vif.master_cb.prdata;
    end
    finish_item();
    state = CONSUME_IPG;
  endtask

  task consume_ipg();
    if (consumed_ipg >= item.get_ipg()) begin
      uvm_wait_for_nba_region();
      item  = null;
      state = IDLE;
    end
    else begin
      ++consumed_ipg;
    end
  endtask

  function void finish_item();
    end_tr(item);
    seq_item_port.item_done();
  endfunction

  `tue_component_default_constructor(tvip_apb_master_driver)
  `uvm_component_utils(tvip_apb_master_driver)
endclass
`endif
