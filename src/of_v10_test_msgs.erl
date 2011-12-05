%% @author Bruno Rijsman <brunorijsman@hotmail.com>
%% @copyright 2011 Bruno Rijsman
%%

-module(of_v10_test_msgs).

-export([header_bin/0,
         header_rec/0,
         header_bad_version_bin/0,
         header_bad_message_type_bin/0,
         hello_bin/0,
         hello_rec/0,
         hello_with_extension_bin/0,
         hello_with_extension_rec/0,
         error_bin/0,
         error_rec/0,
         error_with_data_bin/0,
         error_with_data_rec/0,
         echo_request_bin/0,
         echo_request_rec/0,
         echo_request_with_data_bin/0,
         echo_request_with_data_rec/0,
         echo_reply_bin/0,
         echo_reply_rec/0,
         echo_reply_with_data_bin/0,
         echo_reply_with_data_rec/0,
         vendor_bin/0,
         vendor_rec/0,
         vendor_with_data_bin/0,
         vendor_with_data_rec/0,
         features_request_bin/0,
         features_request_rec/0,
         features_reply_bin/0,
         features_reply_rec/0]).
         %% get_config_request_bin/0,
         %% get_config_request_rec/0]).

-include_lib("../include/of_v10.hrl").

%%
%% Exported functions.
%%

header_bin() ->
    << ?OF_V10_VERSION            : 8,      % Version
       ?OF_V10_MESSAGE_TYPE_HELLO : 8,      % Type
       0                          : 16,     % Length
       0                          : 32 >>.  % Xid

header_rec() ->
    #of_v10_header{version = ?OF_V10_VERSION,
                   type    = ?OF_V10_MESSAGE_TYPE_HELLO,
                   length  = 0,
                   xid     = 0}.

header_bad_version_bin() ->
    << 99                         : 8,      % Version
       ?OF_V10_MESSAGE_TYPE_HELLO : 8,      % Type
       0                          : 16,     % Length
       0                          : 32 >>.  % Xid

header_bad_message_type_bin() ->
    << ?OF_V10_VERSION   : 8,      % Version
       99                : 8,      % Type
       0                 : 16,     % Length
       0                 : 32 >>.  % Xid

hello_bin() ->
    << >>.

hello_rec() ->
    #of_v10_hello{}.

hello_with_extension_bin() ->
    << 1, 2, 3, 4, 5 >>.

hello_with_extension_rec() ->
    #of_v10_hello{}.

error_bin() ->
    <<?OF_V10_ERROR_TYPE_BAD_REQUEST         : 16,
      ?OF_V10_ERROR_CODE_BAD_REQUEST_BAD_LEN : 16 >>.

error_rec() ->
    #of_v10_error{type = ?OF_V10_ERROR_TYPE_BAD_REQUEST,
                  code = ?OF_V10_ERROR_CODE_BAD_REQUEST_BAD_LEN,
                  data = << >>}.

error_with_data_bin() ->
    <<?OF_V10_ERROR_TYPE_BAD_ACTION              : 16,
      ?OF_V10_ERROR_CODE_BAD_ACTION_BAD_OUT_PORT : 16,
      5, 4, 3, 2, 1 >>.

error_with_data_rec() ->
    #of_v10_error{type = ?OF_V10_ERROR_TYPE_BAD_ACTION,
                  code = ?OF_V10_ERROR_CODE_BAD_ACTION_BAD_OUT_PORT,
                  data = <<5, 4, 3, 2, 1>>}.

echo_request_bin() ->
    << >>.

echo_request_rec() ->
    #of_v10_echo_request{data = << >>}.

echo_request_with_data_bin() ->
    << 3, 3, 3, 4, 4, 4 >>.

echo_request_with_data_rec() ->
    #of_v10_echo_request{data = << 3, 3, 3, 4, 4, 4 >>}.

echo_reply_bin() ->
    << >>.

echo_reply_rec() ->
    #of_v10_echo_reply{data = << >>}.

echo_reply_with_data_bin() ->
    << 3, 3, 3, 4, 4, 4 >>.

echo_reply_with_data_rec() ->
    #of_v10_echo_reply{data = << 3, 3, 3, 4, 4, 4 >>}.

vendor_bin() ->
    << 1 : 32 >>.   % Vendor ID

vendor_rec() ->
    #of_v10_vendor{vendor_id = 1,
                   data      = << >>}.

vendor_with_data_bin() ->
    << 1234 : 32,            % Vendor ID
       99, 99, 88, 88 >>.    % Data

vendor_with_data_rec() ->
    #of_v10_vendor{vendor_id = 1234,
                   data      = << 99, 99, 88, 88 >>}.

features_request_bin() ->
    << >>.

features_request_rec() ->
    #of_v10_features_request{}.

features_reply_bin() ->
    CapabilitiesBin = capabilities_bin(),
    ActionsBin = actions_bin(),
    Port1Bin = port_bin(),
    Port2Bin = port_bin(),
    << 123456789 : 64,             %% Data path ID
       5000      : 32,             %% Number of buffers
       50        : 8,              %% Number of tables
       0         : 24,             %% Padding
       CapabilitiesBin/binary,     %% Capabilities
       ActionsBin/binary,          %% Actions
       Port1Bin/binary,            %% Port 1 configuration
       Port2Bin/binary >>.         %% Port 2 configuration

features_reply_rec() ->
    #of_v10_features_reply{data_path_id = 123456789,
                           n_buffers    = 5000,
                           n_tables     = 50,
                           capabilities = capabilities_rec(),
                           actions      = actions_rec(),
                           ports        = [port_rec(), port_rec()]}.

%% get_config_request_bin() ->
%%     << >>.

%% get_config_request_rec() ->
%%     #of_v10_get_config_request{}.

%%
%% Internal functions.
%%

capabilities_bin() ->
    << 0 : 24,                     %% Reserved
       1 : 1,                      %% ARP match IP
       0 : 1,                      %% Queue stats
       0 : 1,                      %% IP reassembly
       0 : 1,                      %% Reserved
       1 : 1,                      %% STP
       0 : 1,                      %% Port stats
       0 : 1,                      %% Table stats
       0 : 1 >>.                   %% Flow stats

capabilities_rec() ->
    #of_v10_capabilities{flow_stats   = false,
                         table_stats  = false,
                         port_stats   = false,
                         stp          = true,
                         ip_reasm     = false,
                         queue_stats  = false,
                         arp_match_ip = true}.

actions_bin() ->
    << 0 : 20,                     %% Reserved
       1 : 1,                      %% Enqueue
       1 : 1,                      %% Set transport destination
       1 : 1,                      %% Set transport source
       1 : 1,                      %% Set network TOS
       1 : 1,                      %% Set network destination
       1 : 1,                      %% Set network source
       1 : 1,                      %% Set datalink destination
       1 : 1,                      %% Set datalink source
       0 : 1,                      %% Strip VLAN
       1 : 1,                      %% Set VLAN PCP
       1 : 1,                      %% Set VLAN ID
       1 : 1 >>.                   %% Output

actions_rec() ->
    #of_v10_actions{output       = true,
                    set_vlan_id  = true,
                    set_vlan_pcp = true,
                    strip_vlan   = false,
                    set_dl_src   = true,
                    set_dl_dst   = true,
                    set_nw_src   = true,
                    set_nw_dst   = true,
                    set_nw_tos   = true,
                    set_tp_src   = true,
                    set_tp_dst   = true,
                    enqueue      = true}.

hw_addr_bin() ->
    << 1, 2, 3, 4, 5, 6 >>.

port_name_bin() ->
    << "port1", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 >>.

port_config_bin() ->
    << 0 : 25,                     %% Reserved
       1 : 1,                      %% No packet in
       1 : 1,                      %% No forward
       0 : 1,                      %% No flood
       0 : 1,                      %% No receive STP
       0 : 1,                      %% No receive
       0 : 1,                      %% No STP
       1 : 1 >>.                   %% Port down

port_config_rec() ->
    #of_v10_port_config{port_down    = true,
                        no_stp       = false,
                        no_recv      = false,
                        no_recv_stp  = false,
                        no_flood     = false,
                        no_fwd       = true,
                        no_packet_in = true}.

port_state_bin() ->
    StpPortState = ?OF_V10_STP_PORT_STATE_LEARN,
    << 0            : 22,          %% Reserved,
       StpPortState : 2,           %% STP port state
       0            : 7,           %% Reserved
       0            : 1 >>.        %% Link down

port_state_rec() ->
    #of_v10_port_state{link_down      = false,
                       stp_port_state = ?OF_V10_STP_PORT_STATE_LEARN}.

port_features_bin() ->
    << 0 : 20,                     %% Reserved
       0 : 1,                      %% Pause asymetric
       0 : 1,                      %% Pause
       1 : 1,                      %% Auto negotiation
       0 : 1,                      %% Fiber medium
       1 : 1,                      %% Copper medium
       0 : 1,                      %% Full duplex 10 Gbps
       0 : 1,                      %% Full duplex 1 Gbps
       0 : 1,                      %% Half duplex 1 Gbps
       1 : 1,                      %% Full duplex 100 Mbps
       1 : 1,                      %% Half duplex 100 Mbps
       1 : 1,                      %% Full duplex 10 Mbps
       1 : 1 >>.                   %% Half duplex 10 Mbps

port_features_rec() ->
    #of_v10_port_features{half_duplex_10_mbps  = true,
                          full_duplex_10_mbps  = true,
                          half_duplex_100_mbps = true,
                          full_duplex_100_mbps = true,
                          half_duplex_1_gbps   = false,
                          full_duplex_1_gbps   = false,
                          full_duplex_10_gbps  = false,
                          copper_medium        = true,
                          fiber_medium         = false,
                          auto_negotiation     = true,
                          pause                = false,
                          pause_asymetric      = false}.

port_bin() ->
    HwAddrBin = hw_addr_bin(),
    PortNameBin = port_name_bin(),
    PortConfigBin = port_config_bin(),
    PortStateBin = port_state_bin(),
    PortFeaturesBin = port_features_bin(),
    << 1 : 16,                     %% Port no
       HwAddrBin/binary,           %% Hardware address
       PortNameBin/binary,         %% Name
       PortConfigBin/binary,       %% Config
       PortStateBin/binary,        %% State
       PortFeaturesBin/binary,     %% Current features
       PortFeaturesBin/binary,     %% Advertised features
       PortFeaturesBin/binary,     %% Supported features
       PortFeaturesBin/binary >>.  %% Peer features

port_rec() ->
    #of_v10_port{port_no             = 1,
                 hw_addr             = hw_addr_bin(),
                 name                = "port1",
                 config              = port_config_rec(),
                 state               = port_state_rec(),
                 current_features    = port_features_rec(),
                 advertised_features = port_features_rec(),
                 supported_features  = port_features_rec(),
                 peer_features       = port_features_rec()}.
