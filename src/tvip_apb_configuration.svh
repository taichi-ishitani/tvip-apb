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
`ifndef TVIP_APB_CONFIGURATION_SVH
`define TVIP_APB_CONFIGURATION_SVH
class tvip_apb_configuration extends tue_configuration;
        tvip_apb_vif  vif;
  rand  int           address_width;
  rand  int           data_width;

  constraint c_valid_address_width {
    address_width inside {[1:32]};
    address_width <= `TVIP_APB_MAX_ADDRESS_WIDTH;
  }

  constraint c_valid_data_width {
    data_width inside {8, 16, 32};
    data_width <= `TVIP_APB_MAX_DATA_WIDTH;
  }

  virtual function bit apply_config_db(
    uvm_component context_component, string instance_name
  );
    if (!uvm_config_db #(tvip_apb_vif)::get(
      context_component, instance_name, "vif", vif)
    ) begin
      return 0;
    end
    return 1;
  endfunction

  `tue_object_default_constructor(tvip_apb_configuration)
  `uvm_object_utils(tvip_apb_configuration)
endclass
`endif
