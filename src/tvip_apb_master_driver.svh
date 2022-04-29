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
  protected tvip_apb_vif          vif;
  protected tvip_apb_master_item  current_item;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    vif = configuration.vif;
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      do_reset();
      fork
        driver_thread();
        @(negedge vif.preset_n);
      join_any
    end
  endtask

  protected virtual task do_reset();
    if (current_item != null) begin
      finish_item();
    end

    vif.reset_master();
    wait (vif.preset_n);
  endtask

  protected virtual task driver_thread();
    int ipg;

    forever begin
      wait_for_next_item();
      drive_request();
      wait_for_done();
      sample_response();
      drive_idle();

      ipg = current_item.get_ipg();
      finish_item();

      repeat (ipg + 1) begin
        @(vif.master_cb);
      end
    end
  endtask

  protected virtual task wait_for_next_item();
    seq_item_port.get_next_item(current_item);
    void'(begin_tr(current_item));
    if (!vif.master_cb_edge.triggered) begin
      @(vif.master_cb_edge);
    end
  endtask

  protected virtual task drive_request();
    vif.master_cb.psel    <= '1;
    vif.master_cb.paddr   <= current_item.address;
    vif.master_cb.pwrite  <= current_item.is_write();
    vif.master_cb.pprot   <= current_item.get_protection();
    if (current_item.is_write()) begin
      vif.master_cb.pwdata  <= current_item.data;
      vif.master_cb.pstrb   <= current_item.strobe;
    end

    @(vif.master_cb);
    vif.master_cb.penable <= '1;
  endtask

  protected virtual task wait_for_done();
    wait (vif.master_cb.pready);
  endtask

  protected virtual task sample_response();
    current_item.slave_error  = vif.master_cb.pslverr;
    if (current_item.is_read()) begin
      current_item.data = vif.master_cb.prdata;
    end
  endtask

  protected virtual task drive_idle();
    vif.master_cb.psel    <= '0;
    vif.master_cb.penable <= '0;
  endtask

  protected virtual function void finish_item();
    end_tr(current_item);
    seq_item_port.item_done();
    current_item  = null;
  endfunction

  `tue_component_default_constructor(tvip_apb_master_driver)
  `uvm_component_utils(tvip_apb_master_driver)
endclass
`endif
