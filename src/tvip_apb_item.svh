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
class tvip_apb_item extends tue_sequence_item #(
  .CONFIGURATION  (tvip_apb_configuration ),
  .STATUS         (tvip_apb_status        )
);
  rand  tvip_apb_address            address;
  rand  tvip_apb_direction          direction;
  rand  tvip_apb_data               data;
  rand  tvip_apb_strobe             strobe;
  rand  tvip_apb_privileged_access  privileged_access;
  rand  tvip_apb_secure_access      secure_access;
  rand  tvip_apb_access_type        access_type;
  rand  bit                         slave_error;
  rand  int                         ipg;

  constraint c_valid_ipg {
    ipg >= -1;
  }

  constraint c_default_ipg {
    soft ipg == -1;
  }

  constraint c_valid_address {
    (address >> this.configuration.address_width) == '0;
  }

  constraint c_valid_write_data {
    if (direction == TVIP_APB_WRITE) {
      (data >> this.configuration.data_width) == '0;
    }
    else {
      data == 0;
    }
  }

  constraint c_valid_strobe {
    if (direction == TVIP_APB_WRITE) {
      (strobe >> (this.configuration.data_width / 8)) == 0;
    }
    else {
      strobe == 0;
    }
  }

  constraint c_valid_read_data {
    if (direction == TVIP_APB_READ) {
      (data >> this.configuration.data_width) == 0;
    }
  }

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

  function int get_ipg();
    return (ipg >= 0) ? ipg : 0;
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
    `uvm_field_int(ipg, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
  `uvm_object_utils_end
endclass

class tvip_apb_master_item extends tvip_apb_item;
  function void pre_randomize();
    slave_error.rand_mode(0);
    c_valid_read_data.constraint_mode(0);
  endfunction

  `tue_object_default_constructor(tvip_apb_master_item)
  `uvm_object_utils(tvip_apb_master_item)
endclass

class tvip_apb_slave_item extends tvip_apb_item;
  function void pre_randomize();
    direction.rand_mode(0);
    address.rand_mode(0);
    c_valid_address.constraint_mode(0);
    data.rand_mode(is_read());
    c_valid_write_data.constraint_mode(0);
    c_valid_read_data.constraint_mode(is_read());
    strobe.rand_mode(0);
    c_valid_strobe.constraint_mode(0);
    privileged_access.rand_mode(0);
    secure_access.rand_mode(0);
    access_type.rand_mode(0);
  endfunction

  `tue_object_default_constructor(tvip_apb_slave_item)
  `uvm_object_utils(tvip_apb_slave_item)
endclass
`endif
