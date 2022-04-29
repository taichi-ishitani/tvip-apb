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
`ifndef TVIP_APB_MONITOR_BASE_SVH
`define TVIP_APB_MONITOR_BASE_SVH
class tvip_apb_monitor_base #(
  type  ITEM  = tvip_apb_master_item
) extends tue_param_monitor #(
  tvip_apb_configuration, tvip_apb_status, ITEM
);
  protected tvip_apb_vif  vif;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    vif = configuration.vif;
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      do_reset();
      fork
        monitor_thread();
        @(negedge vif.preset_n);
      join_any
      disable fork;
    end
  endtask

  virtual protected task do_reset();
    wait (vif.preset_n === 1);
  endtask

  virtual protected task monitor_thread();
    ITEM  item;

    forever begin
      wait_for_psel();
      item  = create_item("item");

      wait_for_penable();
      sample_request(item);

      wait_for_pready();
      sample_response(item);
      write_item(item);
    end
  endtask

  virtual protected task wait_for_psel();
    do begin
      @(vif.monitor_cb);
    end while (!vif.monitor_cb.psel);
  endtask

  virtual protected task wait_for_penable();
    @(posedge vif.monitor_cb.penable);
  endtask

  virtual protected function void sample_request(ITEM item);
    item.address            = vif.monitor_cb.paddr;
    item.direction          = tvip_apb_direction'(vif.monitor_cb.pwrite);
    item.privileged_access  = vif.monitor_cb.pprot[0];
    item.secure_access      = vif.monitor_cb.pprot[1];
    item.access_type        = vif.monitor_cb.pprot[2];
    if (item.is_write()) begin
      item.data   = vif.monitor_cb.pwdata;
      item.strobe = vif.monitor_cb.pstrb;
    end
  endfunction

  virtual protected task wait_for_pready();
    wait (vif.master_cb.pready);
  endtask

  virtual protected function void sample_response(ITEM item);
    item.slave_error  = vif.monitor_cb.pslverr;
    if (item.is_read()) begin
      item.data = vif.monitor_cb.prdata;
    end
  endfunction

  `tue_component_default_constructor(tvip_apb_monitor_base)
endclass
`endif
