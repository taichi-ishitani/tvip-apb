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
  tvip_apb_vif  vif;

  ITEM  item;
  bit   in_progress;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    vif = configuration.vif;
  endfunction

  task run_phase(uvm_phase phase);
    forever @(vif.monitor_cb) begin
      if (!vif.preset_n) begin
        do_reset();
      end
      else if ((!in_progress) && vif.monitor_cb.psel) begin
        sample_request();
      end
      else if (in_progress && vif.monitor_cb.pack) begin
        sample_response();
      end
    end
  endtask

  virtual function void do_reset();
    in_progress = 0;
    item        = null;
  endfunction

  virtual function void sample_request();
    in_progress     = 1;
    item            = create_item("master_item");
    item.address    = vif.monitor_cb.paddr;
    item.direction  = tvip_apb_direction'(vif.monitor_cb.pwrite);
    if (item.is_write()) begin
      item.data   = vif.monitor_cb.pwdata;
      item.strobe = vif.monitor_cb.pstrb;
    end
  endfunction

  virtual function void sample_response();
    item.slave_error  = vif.monitor_cb.pslverr;
    if (item.is_read()) begin
      item.data = vif.monitor_cb.prdata;
    end

    write_item(item);
    item        = null;
    in_progress = 0;
  endfunction

  `tue_component_default_constructor(tvip_apb_monitor_base)
endclass
`endif
