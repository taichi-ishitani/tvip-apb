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
`ifndef TVIP_APB_ITEM_SVH
`define TVIP_APB_ITEM_SVH
class tvip_apb_item extends tvip_common_item #(
  tvip_apb_configuration, tvip_apb_status
);
  rand  tvip_apb_address            address;
  rand  tvip_apb_direction          direction;
  rand  tvip_apb_data               data;
  rand  tvip_apb_strobe             strobe;
  rand  tvip_apb_privileged_access  privileged_access;
  rand  tvip_apb_secure_access      secure_access;
  rand  tvip_apb_access_type        access_type;  
  rand  bit                         slave_error;

  function bit is_read();
    return (direction == TVIP_APB_READ) ? 1 : 0;
  endfunction

  function bit is_write();
    return (direction == TVIP_APB_WRITE) ? 1 : 0;
  endfunction

  function bit [2:0] get_protection();
    bit [2:0] protection;
    protection[0] = privileged_access;
    protection[1] = secure_access;
    protection[2] = access_type;
    return protection;
  endfunction

  function void set_protection(bit [2:0] protection);
    privileged_access = tvip_apb_privileged_access'(protection[0]);
    secure_access     = tvip_apb_secure_access'(protection[1]);
    access_type       = tvip_apb_access_type'(protection[0]);
  endfunction

  `tue_object_default_constructor(tvip_apb_item)
  `uvm_object_utils_begin(tvip_apb_item)
    `uvm_field_int(address, UVM_DEFAULT | UVM_HEX)
    `uvm_field_enum(tvip_apb_direction, direction, UVM_DEFAULT)
    `uvm_field_int(data  , UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(strobe, UVM_DEFAULT | UVM_BIN)
    `uvm_field_enum(tvip_apb_privileged_access, privileged_access, UVM_DEFAULT)
    `uvm_field_enum(tvip_apb_secure_access    , secure_access    , UVM_DEFAULT)
    `uvm_field_enum(tvip_apb_access_type      , access_type      , UVM_DEFAULT)
    `uvm_field_int(slave_error, UVM_DEFAULT | UVM_BIN)
  `uvm_object_utils_end
endclass

class tvip_apb_master_item extends tvip_apb_item;
  function new(string name = "tvip_apb_master_item");
    super.new(name);
    slave_error.rand_mode(0);
  endfunction

  constraint c_valid_address {
    if ((configuration != null) && (configuration.address_width < `TVIP_APB_MAX_ADDRESS_WIDTH)) {
      (address >> configuration.address_width) == '0;
    }
  }

  constraint c_valid_data {
    if (direction == TVIP_APB_WRITE) {
      if ((configuration != null) && (configuration.data_width < `TVIP_APB_MAX_DATA_WIDTH)) {
        (data >> configuration.data_width) == '0;
      }
    }
  }

  constraint c_default_data {
    if (direction == TVIP_APB_READ) {
      soft data == '0;
    }
  }

  constraint c_valid_strobe {
    if (direction == TVIP_APB_WRITE) {
      if ((configuration != null) && (configuration.data_width < `TVIP_APB_MAX_DATA_WIDTH)) {
        (strobe >> (configuration.data_width / 8)) == '0;
      }
    }
  }

  constraint c_default_strobe {
    if (direction == TVIP_APB_READ) {
      soft strobe == '0;
    }
  }

  `uvm_object_utils(tvip_apb_master_item)
endclass

class tvip_apb_slave_item extends tvip_apb_item;
  function new(string name = "tvip_apb_slave_item");
    super.new(name);
    direction.rand_mode(0);
    address.rand_mode(0);
    strobe.rand_mode(0);
    privileged_access.rand_mode(0);
    secure_access.rand_mode(0);
    access_type.rand_mode(0);
  endfunction

  constraint c_valid_data {
    if (direction == TVIP_APB_READ) {
      if ((configuration != null) && (configuration.data_width < `TVIP_APB_MAX_DATA_WIDTH)) {
        (data >> configuration.data_width) == '0;
      }
    }
  }

  function void pre_randomize();
    if (direction == TVIP_APB_WRITE) begin
      data.rand_mode(0);
    end
  endfunction

  `uvm_object_utils(tvip_apb_slave_item)
endclass
`endif
