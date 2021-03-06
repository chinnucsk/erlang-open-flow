%%%=====================================================================================================================
%%% Copyright (c) 2012-2013, Bruno Rijsman
%%% All rights reserved.
%%%
%%% Redistribution and use in source and binary forms, with or without modification, are permitted provided that the 
%%% following conditions are met:
%%%
%%% * Redistributions of source code must retain the above copyright notice, this list of conditions and the following 
%%%   disclaimer.
%%%
%%% * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the 
%%%   following disclaimer in the documentation and/or other materials provided with the distribution.
%%%
%%% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, 
%%% INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
%%% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
%%% SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
%%% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
%%% WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
%%% USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%%%=====================================================================================================================

-ifndef(OF_V11_HRL).
-define(OF_V11_HRL, true).

%% TODO: Fix the include paths
-include_lib("../include/of_types.hrl").

%% Protocol version
-define(OF_V11_VERSION, 2).

%% Message type
-define(OF_V11_MESSAGE_TYPE_MIN,                      0).
-define(OF_V11_MESSAGE_TYPE_MAX,                      23).
-define(OF_V11_MESSAGE_TYPE_HELLO,                    0).
-define(OF_V11_MESSAGE_TYPE_ERROR,                    1).
-define(OF_V11_MESSAGE_TYPE_ECHO_REQUEST,             2).
-define(OF_V11_MESSAGE_TYPE_ECHO_REPLY,               3).
-define(OF_V11_MESSAGE_TYPE_EXPERIMENTER,             4).
-define(OF_V11_MESSAGE_TYPE_FEATURES_REQUEST,         5).
-define(OF_V11_MESSAGE_TYPE_FEATURES_REPLY,           6).
-define(OF_V11_MESSAGE_TYPE_GET_CONFIG_REQUEST,       7).
-define(OF_V11_MESSAGE_TYPE_GET_CONFIG_REPLY,         8).
-define(OF_V11_MESSAGE_TYPE_SET_CONFIG,               9).
-define(OF_V11_MESSAGE_TYPE_PACKET_IN,                10).
-define(OF_V11_MESSAGE_TYPE_FLOW_REMOVED,             11).
-define(OF_V11_MESSAGE_TYPE_PORT_STATUS,              12).
-define(OF_V11_MESSAGE_TYPE_PACKET_OUT,               13).
-define(OF_V11_MESSAGE_TYPE_FLOW_MOD,                 14).
-define(OF_V11_MESSAGE_TYPE_GROUP_MOD,                15).
-define(OF_V11_MESSAGE_TYPE_PORT_MOD,                 16).
-define(OF_V11_MESSAGE_TYPE_TABLE_MOD,                17).
-define(OF_V11_MESSAGE_TYPE_STATS_REQUEST,            18).
-define(OF_V11_MESSAGE_TYPE_STATS_REPLY,              19).
-define(OF_V11_MESSAGE_TYPE_BARRIER_REQUEST,          20).
-define(OF_V11_MESSAGE_TYPE_BARRIER_REPLY,            21).
-define(OF_V11_MESSAGE_TYPE_QUEUE_GET_CONFIG_REQUEST, 22).
-define(OF_V11_MESSAGE_TYPE_QUEUE_GET_CONFIG_REPLY,   23).

%% Error types
-define(OF_V11_ERROR_TYPE_MIN,                  0).
-define(OF_V11_ERROR_TYPE_MAX,                  10).
-define(OF_V11_ERROR_TYPE_HELLO_FAILED,         0).
-define(OF_V11_ERROR_TYPE_BAD_REQUEST,          1).
-define(OF_V11_ERROR_TYPE_BAD_ACTION,           2).
-define(OF_V11_ERROR_TYPE_BAD_INSTRUCTION,      3).
-define(OF_V11_ERROR_TYPE_BAD_MATCH,            4).
-define(OF_V11_ERROR_TYPE_FLOW_MOD_FAILED,      5).
-define(OF_V11_ERROR_TYPE_GROUP_MOD_FAILED,     6).
-define(OF_V11_ERROR_TYPE_PORT_MOD_FAILED,      7).
-define(OF_V11_ERROR_TYPE_TABLE_MOD_FAILED,     8).
-define(OF_V11_ERROR_TYPE_QUEUE_OP_FAILED,      9).
-define(OF_V11_ERROR_TYPE_SWITCH_CONFIG_FAILED, 10).

%% Error codes
-define(OF_V11_ERROR_CODE_MIN, 0).
-define(OF_V11_ERROR_CODE_MAX, 12).

-define(OF_V11_ERROR_CODE_HELLO_FAILED_INCOMPATIBLE, 0).
-define(OF_V11_ERROR_CODE_HELLO_FAILED_EPERM,        1).

-define(OF_V11_ERROR_CODE_BAD_REQUEST_BAD_VERSION,      0).
-define(OF_V11_ERROR_CODE_BAD_REQUEST_BAD_TYPE,         1).
-define(OF_V11_ERROR_CODE_BAD_REQUEST_BAD_STAT,         2).
-define(OF_V11_ERROR_CODE_BAD_REQUEST_BAD_EXPERIMENTER, 3).
-define(OF_V11_ERROR_CODE_BAD_REQUEST_BAD_SUBTYPE,      4).
-define(OF_V11_ERROR_CODE_BAD_REQUEST_EPERM,            5).
-define(OF_V11_ERROR_CODE_BAD_REQUEST_BAD_LEN,          6).
-define(OF_V11_ERROR_CODE_BAD_REQUEST_BUFFER_EMPTY,     7).
-define(OF_V11_ERROR_CODE_BAD_REQUEST_BUFFER_UNKNOWN,   8).
-define(OF_V11_ERROR_CODE_BAD_REQUEST_BAD_TABLE_ID,     9).

-define(OF_V11_ERROR_CODE_BAD_ACTION_BAD_TYPE,              0).
-define(OF_V11_ERROR_CODE_BAD_ACTION_BAD_LEN,               1).
-define(OF_V11_ERROR_CODE_BAD_ACTION_BAD_EXPERIMENTER,      2).
-define(OF_V11_ERROR_CODE_BAD_ACTION_BAD_EXPERIMENTER_TYPE, 3).
-define(OF_V11_ERROR_CODE_BAD_ACTION_BAD_OUT_PORT,          4).
-define(OF_V11_ERROR_CODE_BAD_ACTION_BAD_ARGUMENT,          5).
-define(OF_V11_ERROR_CODE_BAD_ACTION_EPERM,                 6).
-define(OF_V11_ERROR_CODE_BAD_ACTION_TOO_MANY,              7).
-define(OF_V11_ERROR_CODE_BAD_ACTION_BAD_QUEUE,             8).
-define(OF_V11_ERROR_CODE_BAD_ACTION_BAD_OUT_GROUP,         9).
-define(OF_V11_ERROR_CODE_BAD_ACTION_MATCH_INCONSISTENT,    10).
-define(OF_V11_ERROR_CODE_BAD_ACTION_UNSUPPORTED_ORDER,     11).
-define(OF_V11_ERROR_CODE_BAD_ACTION_BAD_TAG,               12).

-define(OF_V11_ERROR_CODE_BAD_INSTRUCTION_UNKNOWN_INST,        0).
-define(OF_V11_ERROR_CODE_BAD_INSTRUCTION_UNSUP_INST,          1).
-define(OF_V11_ERROR_CODE_BAD_INSTRUCTION_BAD_TABLE_ID,        2).
-define(OF_V11_ERROR_CODE_BAD_INSTRUCTION_UNSUP_METADATA,      3).
-define(OF_V11_ERROR_CODE_BAD_INSTRUCTION_UNSUP_METADATA_MASK, 4).
-define(OF_V11_ERROR_CODE_BAD_INSTRUCTION_UNSUP_EXP_INST,      5).

-define(OF_V11_ERROR_CODE_BAD_MATCH_BAD_TYPE,         0).
-define(OF_V11_ERROR_CODE_BAD_MATCH_BAD_LEN,          1).
-define(OF_V11_ERROR_CODE_BAD_MATCH_BAD_TAG,          2).
-define(OF_V11_ERROR_CODE_BAD_MATCH_BAD_DL_ADDR_MASK, 3).
-define(OF_V11_ERROR_CODE_BAD_MATCH_BAD_NW_ADDR_MASK, 4).
-define(OF_V11_ERROR_CODE_BAD_MATCH_BAD_WILDCARDS,    5).
-define(OF_V11_ERROR_CODE_BAD_MATCH_BAD_FIELD,        6).
-define(OF_V11_ERROR_CODE_BAD_MATCH_BAD_VALUE,        7).

-define(OF_V11_ERROR_CODE_FLOW_MOD_FAILED_UNKNOWN,      0).
-define(OF_V11_ERROR_CODE_FLOW_MOD_FAILED_TABLE_FULL,   1).
-define(OF_V11_ERROR_CODE_FLOW_MOD_FAILED_BAD_TABLE_ID, 2).
-define(OF_V11_ERROR_CODE_FLOW_MOD_FAILED_OVERLAP,      3).
-define(OF_V11_ERROR_CODE_FLOW_MOD_FAILED_EPERM,        4).
-define(OF_V11_ERROR_CODE_FLOW_MOD_FAILED_BAD_TIMEOUT,  5).
-define(OF_V11_ERROR_CODE_FLOW_MOD_FAILED_BAD_COMMAND,  6).

-define(OF_V11_ERROR_CODE_GROUP_MOD_FAILED_GROUP_EXISTS,         0).
-define(OF_V11_ERROR_CODE_GROUP_MOD_FAILED_INVALID_GROUP,        1).
-define(OF_V11_ERROR_CODE_GROUP_MOD_FAILED_WEIGHT_UNSUPPORTED,   2).
-define(OF_V11_ERROR_CODE_GROUP_MOD_FAILED_OUT_OF_V11_GROUPS,    3).
-define(OF_V11_ERROR_CODE_GROUP_MOD_FAILED_OUT_OF_V11_BUCKETS,   4).
-define(OF_V11_ERROR_CODE_GROUP_MOD_FAILED_CHAINING_UNSUPPORTED, 5).
-define(OF_V11_ERROR_CODE_GROUP_MOD_FAILED_WATCH_UNSUPPORTED,    6).
-define(OF_V11_ERROR_CODE_GROUP_MOD_FAILED_LOOP,                 7).
-define(OF_V11_ERROR_CODE_GROUP_MOD_FAILED_UNKNOWN_GROUP,        8).

-define(OF_V11_ERROR_CODE_PORT_MOD_FAILED_BAD_PORT,      0).
-define(OF_V11_ERROR_CODE_PORT_MOD_FAILED_BAD_HW_ADDR,   1).
-define(OF_V11_ERROR_CODE_PORT_MOD_FAILED_BAD_CONFIG,    2).
-define(OF_V11_ERROR_CODE_PORT_MOD_FAILED_BAD_ADVERTISE, 3).

-define(OF_V11_ERROR_CODE_TABLE_MOD_FAILED_BAD_TABLE,  0).
-define(OF_V11_ERROR_CODE_TABLE_MOD_FAILED_BAD_CONFIG, 1).

-define(OF_V11_ERROR_CODE_QUEUE_OP_FAILED_BAD_PORT,  0).
-define(OF_V11_ERROR_CODE_QUEUE_OP_FAILED_BAD_QUEUE, 1).
-define(OF_V11_ERROR_CODE_QUEUE_OP_FAILED_EPERM,     2).

-define(OF_V11_ERROR_CODE_SWITCH_CONFIG_FAILED_BAD_FLAGS, 0).
-define(OF_V11_ERROR_CODE_SWITCH_CONFIG_FAILED_BAD_LEN,   1).

%% Port numbers
-define(OF_V11_PORT_NO_MAX,        0xffffff00).
-define(OF_V11_PORT_NO_IN,         0xfffffff8).
-define(OF_V11_PORT_NO_TABLE,      0xfffffff9).
-define(OF_V11_PORT_NO_NORMAL,     0xfffffffa).
-define(OF_V11_PORT_NO_FLOOD,      0xfffffffb).
-define(OF_V11_PORT_NO_ALL,        0xfffffffc).
-define(OF_V11_PORT_NO_CONTROLLER, 0xfffffffd).
-define(OF_V11_PORT_NO_LOCAL,      0xfffffffe).
-define(OF_V11_PORT_NO_ANY,        0xffffffff).

%% Queue property types
-define(OF_V11_QUEUE_PROPERTY_TYPE_NONE,     0).
-define(OF_V11_QUEUE_PROPERTY_TYPE_MIN_RATE, 1).

%% Match types
-define(OF_V11_MATCH_TYPE_STANDARD, 0).

%% Maximum length of hardware address
-define(OF_V11_ETH_ALEN, 6).

%% Maximum length of a port name (inluding terminating null character)
-define(OF_V11_MAX_PORT_NAME_LEN, 16).

-define(OF_V11_HEADER_LEN, 8).

-define(OF_V11_HEADER_PATTERN,
        << Version : 8,
           Type    : 8,
           Length  : 16,
           Xid     : 32 >>).

-define(OF_V11_PORTS_PATTERN,
        << PortNo             : 32,
           _Pad1              : 32,
           HwAddr             : ?OF_V11_ETH_ALEN/binary-unit:8,
           _Pad2              : 16,
           Name               : ?OF_V11_MAX_PORT_NAME_LEN/binary-unit:8,
           Config             : 4/binary,
           State              : 4/binary,
           CurrentFeatures    : 4/binary,
           AdvertisedFeatures : 4/binary,
           SupportedFeatures  : 4/binary,
           CurrentSpeedKbps   : 32,
           MaxSpeedKbps       : 32,
           MorePorts/binary >>).

-define(OF_V11_PORT_CONFIG_PATTERN,
        << _Reserved1 : 25,
           NoPacketIn : 1,
           NoFwd      : 1,
           _Reserved2 : 2,
           NoRecv     : 1,
           _Reserved3 : 1,
           PortDown   : 1 >>).

-define(OF_V11_PORT_STATE_PATTERN,
        << _Reserved : 29,
           Live      : 1,
           Blocked   : 1,
           LinkDown  : 1 >>).

-define(OF_V11_PORT_FEATURES_PATTERN,
        << _Reserved         : 16,
           PauseAsymetric    : 1,
           Pause             : 1,
           AutoNegotiation   : 1,
           FiberMedium       : 1,
           CopperMedium      : 1,
           OtherRate         : 1,
           FullDuplex1Tbps   : 1,
           FullDuplex100Gbps : 1,
           FullDuplex40Gbps  : 1,
           FullDuplex10Gbps  : 1,
           FullDuplex1Gbps   : 1,
           HalfDuplex1Gbps   : 1,
           FullDuplex100Mbps : 1,
           HalfDuplex100Mbps : 1,
           FullDuplex10Mbps  : 1,
           HalfDuplex10Mbps  : 1 >>).

-define(OF_V11_QUEUE_PATTERN,
        << QueueId : 32,
           Length  : 16,
           _       : 16,
           QueueProperties/binary >>).

-define(OF_V11_QUEUE_PROPERTY_HEADER_PATTERN,
        << Type   : 16,
           Length : 16,
           _      : 32 >>).

-define(OF_V11_QUEUE_PROPERTY_MIN_RATE_PATTERN,
        << RateInTenthPercent : 16,
           _                  : 48 >>).

-define(OF_V11_MATCH_PATTERN,
        << Type         : 16,
           Length       : 16,
           InPort       : 32,
           Wildcards    : 32,
           DlSource     : ?OF_V11_ETH_ALEN/binary-unit:8,
           DlSourceMask : ?OF_V11_ETH_ALEN/binary-unit:8,
           DlDst        : ?OF_V11_ETH_ALEN/binary-unit:8,
           DlDstMask    : ?OF_V11_ETH_ALEN/binary-unit:8,
           DlVlan       : 16,
           DlVlanPcp    : 8,
           _Pad1        : 8,
           DlType       : 16,
           NwTos        : 8,
           NwProto      : 8,
           NwSrc        : 32,
           NwSrcMask    : 32,
           NwDst        : 32,
           NwDstMask    : 32,
           TpSrc        : 16,
           TpDst        : 16,
           MplsLabel    : 32,
           MplsTc       : 8,
           _Pad2        : 24,
           MetaData     : 64,
           MetaDataMask : 64 >>).

-define(OF_V11_CAPABILITIES_PATTERN, 
        << _Reserved1 : 24,
           ArpMatchIp : 1,
           QueueStats : 1,
           IpReasm    : 1,
           _Reserved2 : 1,
           GroupStats : 1,
           PortStats  : 1,
           TableStats : 1,
           FlowStats  : 1 >>).   

-define(OF_V11_SWITCH_CONFIG_PATTERN, 
        << _Reserved              : 13,
           InvalidTtlToController : 1,
           FragReasm              : 1,
           FragDrop               : 1,
           MissSendLen            : 16 >>).   

-define(OF_V11_HELLO_PATTERN,
        << _FutureExtension/binary >>).

-define(OF_V11_ERROR_PATTERN,
        << Type : 16,
           Code : 16,
           Data/binary >>).

-define(OF_V11_ECHO_REQUEST_PATTERN,
        << Data/binary >>).

-define(OF_V11_ECHO_REPLY_PATTERN,
        << Data/binary >>).

-define(OF_V11_EXPERIMENTER_PATTERN,
        << ExperimenterId : 32,
           _Pad           : 32,
           Data/binary >>).

-define(OF_V11_FEATURES_REQUEST_PATTERN, << >>).

-define(OF_V11_FEATURES_REPLY_PATTERN,
        << DataPathId   : 64,
           NBuffers     : 32,
           NTables      : 8,
           _Pad         : 24,
           Capabilities : 4/binary,
           _Reserved    : 32,
           Ports/binary >>).

-define(OF_V11_GET_CONFIG_REQUEST_PATTERN, << >>).

-define(OF_V11_GET_CONFIG_REPLY_PATTERN,
        << SwitchConfig/binary >>).

-type of_v11_version() :: ?OF_V11_VERSION.

-type of_v11_message_type() :: ?OF_V11_MESSAGE_TYPE_MIN..?OF_V11_MESSAGE_TYPE_MAX.

-type of_v11_error_type() :: ?OF_V11_ERROR_TYPE_MIN..?OF_V11_ERROR_TYPE_MAX.

-type of_v11_error_code() :: ?OF_V11_ERROR_CODE_MIN..?OF_V11_ERROR_CODE_MAX.

-type of_v11_error_data() :: binary().

-record(of_v11_header, {
          version :: of_v11_version(),
          type    :: of_v11_message_type(),
          length  :: uint16(),
          xid     :: of_xid() }). 

-record(of_v11_hello, {}).

-record(of_v11_error, {
          type :: uint16(),   %% Accept unrecognized types
          code :: uint16(),   %% Accept unrecognized codes
          data :: binary() }).

-record(of_v11_echo_request, {
          data :: binary() }).

-record(of_v11_echo_reply, {
          data :: binary() }).

-record(of_v11_experimenter, {
          experimenter_id :: uint32(),
          data            :: binary() }).

-record(of_v11_features_request, {}).

-record(of_v11_port_config, {
          port_down    :: boolean(),
          no_recv      :: boolean(),
          no_fwd       :: boolean(),
          no_packet_in :: boolean() }).

-record(of_v11_port_state, {
          link_down :: boolean(),
          blocked   :: boolean(),
          live      :: boolean() }).

-record(of_v11_port_features, {
          half_duplex_10_mbps  :: boolean(),
          full_duplex_10_mbps  :: boolean(),
          half_duplex_100_mbps :: boolean(),
          full_duplex_100_mbps :: boolean(),
          half_duplex_1_gbps   :: boolean(),
          full_duplex_1_gbps   :: boolean(),
          full_duplex_10_gbps  :: boolean(),
          full_duplex_40_gbps  :: boolean(),
          full_duplex_100_gbps :: boolean(),
          full_duplex_1_tbps   :: boolean(),
          other_rate           :: boolean(),
          copper_medium        :: boolean(),
          fiber_medium         :: boolean(),
          auto_negotiation     :: boolean(),
          pause                :: boolean(),
          pause_asymetric      :: boolean() }).

-record(of_v11_port, {
          port_no             :: uint32(),
          hw_addr             :: of_hw_addr(),
          name                :: string(),
          config              :: #of_v11_port_config{},
          state               :: #of_v11_port_state{},
          current_features    :: #of_v11_port_features{},
          advertised_features :: #of_v11_port_features{},
          supported_features  :: #of_v11_port_features{},
          current_speed_kbps  :: uint32(),
          max_speed_kbps      :: uint32()}).

-record(of_v11_capabilities, {
          flow_stats   :: boolean(),
          table_stats  :: boolean(),
          port_stats   :: boolean(),
          group_stats  :: boolean(),
          ip_reasm     :: boolean(),
          queue_stats  :: boolean(),
          arp_match_ip :: boolean() }).

-record(of_v11_features_reply, {
          data_path_id :: uint64(),
          n_buffers    :: uint32(),
          n_tables     :: uint8(),
          capabilities :: #of_v11_capabilities{},
          ports        :: [#of_v11_port{}] }).

-record(of_v11_get_config_request, {}).

-record(of_v11_switch_config, {
          frag_drop                 :: boolean(),
          frag_reasm                :: boolean(),
          invalid_ttl_to_controller :: boolean(),
          miss_send_len             :: uint16() }).

-record(of_v11_get_config_reply, {
          switch_config :: #of_v11_switch_config{} }).

%% TODO: Add missing messages
-type of_v11_message() :: #of_v11_hello{} |
                          #of_v11_error{} |
                          #of_v11_echo_request{} |
                          #of_v11_echo_reply{}.

-endif.
