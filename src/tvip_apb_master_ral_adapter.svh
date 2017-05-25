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
`ifndef TVIP_APB_MASTER_RAL_ADAPTER_SVH
`define TVIP_APB_MASTER_RAL_ADAPTER_SVH
class tvip_apb_master_ral_adapter extends uvm_reg_adapter;
  function new(string name = "tvip_apb_master_ral_adapter");
    super.new(name);
    supports_byte_enable  = 1;
    provides_responses    = 0;
  endfunction

  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    tvip_apb_master_item  apb_item  = tvip_apb_master_item::type_id::create("apb_item");
    apb_item.address    = rw.addr;
    apb_item.direction  = (rw.kind == UVM_WRITE) ? TVIP_APB_WRITE : TVIP_APB_READ;
    apb_item.protection = tvip_apb_protection'(0);
    if (apb_item.is_write()) begin
      apb_item.data   = rw.data;
      apb_item.strobe = rw.byte_en;
    end
    else begin
      apb_item.data   = '0;
      apb_item.strobe = '0;
    end
    return apb_item;
  endfunction

  virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
    tvip_apb_master_item  apb_item;
    $cast(apb_item, bus_item);
    rw.addr     = apb_item.address;
    rw.kind     = (apb_item.is_write()) ? UVM_WRITE : UVM_READ;
    rw.data     = apb_item.data;
    rw.byte_en  = (apb_item.is_write()) ? apb_item.strobe : '1;
    rw.status   = (apb_item.slave_error) ? UVM_NOT_OK : UVM_IS_OK;
  endfunction

  `uvm_object_utils(tvip_apb_master_ral_adapter)
endclass
`endif
