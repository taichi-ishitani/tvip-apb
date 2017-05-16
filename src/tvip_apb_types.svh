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
`ifndef TVIP_APB_TYPES_SVH
`define TVIP_APB_TYPES_SVH

typedef bit [`TVIP_APB_MAX_ADDRESS_WIDTH-1:0] tvip_apb_address;
typedef bit [`TVIP_APB_MAX_DATA_WIDTH-1:0]    tvip_apb_data;
typedef bit [`TVIP_APB_MAX_DATA_WIDTH/8-1:0]  tvip_apb_strobe;

typedef enum bit {
  TVIP_APB_READ   = 0,
  TVIP_APB_WRITE  = 1
} tvip_apb_direction;

typedef enum bit {
  TVIP_APB_NORMAL_ACCESS      = 0,
  TVIP_APB_PRIVILEGED_ACCESS  = 1
} tvip_apb_privileged_access;

typedef enum bit {
  TVIP_APB_SECURE_ACCESS      = 0,
  TVIP_APB_NON_SECURE_ACCESS  = 1
} tvip_apb_secure_access;

typedef enum bit {
  TVIP_APB_DATA_ACCESS        = 0,
  TVIP_APB_INSTRACTION_ACCESS = 1
} tvip_apb_transaction_type;

typedef struct packed {
  tvip_apb_transaction_type   transaction_type;
  tvip_apb_secure_access      secure_access;
  tvip_apb_privileged_access  privileged_access;
} tvip_apb_protection;

typedef virtual tvip_apb_if tvip_apb_vif;

`endif
