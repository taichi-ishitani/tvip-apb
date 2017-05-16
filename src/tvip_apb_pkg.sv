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
`ifndef TVIP_APB_PKG_SV
`define TVIP_APB_PKG_SV

`include  "tvip_apb_macros.svh"
`include  "tvip_apb_if.sv"

package tvip_apb_pkg;
  import  uvm_pkg::*;
  import  tue_pkg::*;
  import  tvip_common_pkg::*;

  `include  "uvm_macros.svh"
  `include  "tue_macros.svh"
  `include  "tvip_common_macros.svh"

  `include  "tvip_apb_types.svh"
  `include  "tvip_apb_configuration.svh"
  `include  "tvip_apb_status.svh"
  `include  "tvip_apb_item.svh"
  `include  "tvip_apb_monitor._base.svh"

  `include  "tvip_apb_master_monitor.svh"
  `include  "tvip_apb_master_sequencer.svh"
  `include  "tvip_apb_master_driver.svh"
  `include  "tvip_apb_master_agent.svh"

  `include  "tvip_apb_master_ral_adapter.svh"
  `include  "tvip_apb_master_ral_predictor.svh"
endpackage
`endif
