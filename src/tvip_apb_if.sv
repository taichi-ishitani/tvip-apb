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
`ifndef TVIP_APB_IF_SV
`define TVIP_APB_IF_SV

`include  "tvip_apb_macros.svh"

interface tvip_apb_if (
  input logic pclk,
  input logic preset_n
);
  localparam  int AW  = `TVIP_APB_MAX_ADDRESS_WIDTH;
  localparam  int DW  = `TVIP_APB_MAX_DATA_WIDTH;

  logic             psel;
  logic             penable;
  logic [AW-1:0]    paddr;
  logic [2:0]       pprot;
  logic             pwrite;
  logic [DW-1:0]    pwdata;
  logic [DW/8-1:0]  pstrb;
  logic             pready;
  logic [DW-1:0]    prdata;
  logic             pslverr;
  logic             pack;

  assign  pack  = (psel && penable && pready) ? 1 : 0;

  clocking master_cb @(posedge pclk);
    output  psel;
    output  penable;
    output  paddr;
    output  pprot;
    output  pwrite;
    output  pwdata;
    output  pstrb;
    input   pready;
    input   prdata;
    input   pslverr;
    input   pack;
  endclocking

  clocking slave_cb @(posedge pclk);
    input   psel;
    input   penable;
    input   paddr;
    input   pprot;
    input   pwrite;
    input   pwdata;
    input   pstrb;
    output  pready;
    output  prdata;
    output  pslverr;
    input   pack;
  endclocking

  clocking monitor_cb @(posedge pclk);
    input psel;
    input penable;
    input paddr;
    input pprot;
    input pwrite;
    input pwdata;
    input pstrb;
    input pready;
    input prdata;
    input pslverr;
    input pack;
  endclocking

  function automatic void reset_master();
    psel    = '0;
    penable = '0;
    paddr   = '0;
    pprot   = '0;
    pwrite  = '0;
    pwdata  = '0;
    pstrb   = '0;
  endfunction
endinterface

`endif
