%% @author Bruno Rijsman <brunorijsman@hotmail.com>
%% @copyright 2012 Bruno Rijsman

-module(of_switch).

-behavior(gen_server).

-export([start_link/0,
         stop/1,
         connect/3,
         accept/2]).

-export([init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3]).

-include_lib("eunit/include/eunit.hrl").

-include_lib("../include/of.hrl").
-include_lib("../include/of_v10.hrl").

-record(of_switch_state, {
          connection_pid,
          version,
          next_local_xid,
          receive_hello_timer,
          send_echo_request_timer,
          pending_requests
         }).

-record(pending_request, {
          xid,
          timer,
          process_reply_fun
         }).

-define(MAX_UINT32, 4294967295).

%% TODO: Make all of these configurable. 
-define(SEND_ECHO_REQUEST_INTERVAL_MSECS, 30000).
-define(RECEIVE_HELLO_TIMEOUT_MSECS, 1000).
-define(RECEIVE_REPLY_TIMEOUT_MSECS, 1000).

%%
%% Exported functions.
%%

start_link() ->
    gen_server:start_link(?MODULE, [], []).

stop(Pid) ->
    gen_server:call(Pid, stop).

connect(Pid, IpAddress, TcpPort) ->
    gen_server:call(Pid, {connect, IpAddress, TcpPort}).

accept(Pid, Socket) ->
    ok = gen_tcp:controlling_process(Socket, Pid),
    gen_server:call(Pid, {accept, Socket}).

%%                 
%% gen_server callbacks.
%%

init([]) ->
    State = #of_switch_state{connection_pid           = undefined, 
                             version                  = undefined,
                             next_local_xid           = 1,
                             receive_hello_timer      = undefined,
                             send_echo_request_timer  = undefined,
                             pending_requests         = dict:new()},
    {ok, State}.

handle_call({connect, IpAddress, TcpPort}, _From, State) ->
    io:format("of_switch: connect IpAddress=~w TcpPort=~w~n", [IpAddress, TcpPort]),
    State1 = initiate_connection(IpAddress, TcpPort, State),
    {reply, ok, State1};

handle_call({accept, Socket}, _From, State) ->
    io:format("of_switch: accept Socket=~w~n", [Socket]),
    State1 = accept_connection(Socket, State),
    {reply, ok, State1};

handle_call(stop, _From, State) ->
    io:format("of_switch: stop~n"),
    {stop, normal, stopped, State}.

handle_cast(Cast, State) ->
    io:format("of_switch: cast Cast=~w~n", [Cast]),
    {noreply, State}.

handle_info({of_receive_message, Xid, Message}, State) ->
    process_received_message(Xid, Message, State);

handle_info(timer_expired_receive_hello, State) ->
    process_timer_expired_receive_hello(State);

handle_info(timer_expired_send_echo_request, State) ->
    process_timer_expired_send_echo_request(State);

handle_info({timer_expired_receive_reply, Xid}, State) ->
    process_timer_expired_receive_reply(Xid, State);

handle_info(Info, State) ->
    io:format("of_switch: info Info=~w~n", [Info]),
    {noreply, State}.

terminate(Reason, _State) ->
    io:format("of_switch: terminate Reason=~w~n", [Reason]),
    ok.

code_change(OldVersion, State, _Extra) ->
    io:format("of_switch: code_change OldVersion=~w~n", [OldVersion]),
    {ok, State}.

%%                 
%% Internal functions.
%%

initiate_connection(IpAddress, TcpPort, State) ->
    ?assert(State#of_switch_state.connection_pid == undefined),
    {ok, ConnectionPid} = of_connection:start_link(),
    ok = of_connection:connect(ConnectionPid, IpAddress, TcpPort),
    State1 = State#of_switch_state{connection_pid = ConnectionPid},
    process_connection_up(State1).

accept_connection(Socket, State) -> 
    {ok, ConnectionPid} = of_connection:start_link(),
    ok = of_connection:accept(ConnectionPid, Socket),
    State1 = State#of_switch_state{connection_pid = ConnectionPid},
    process_connection_up(State1).

close_connection(State) ->
    ConnectionPid = State#of_switch_state.connection_pid,
    ?assert(is_pid(ConnectionPid)),
    ok = of_connection:close(ConnectionPid),
    of_connection:stop(ConnectionPid),
    State#of_switch_state{connection_pid = undefined, version = undefined}.

start_timer(Timer, Time, Message) ->
    case Timer of
        undefined -> nop;
        _         -> {ok, cancel} = timer:cancel(Timer)
    end,
    {ok, NewTimer} = timer:send_after(Time, Message),
    NewTimer.

stop_timer(Timer) ->
    case Timer of
        undefined -> nop;
        _         -> {ok, cancel} = timer:cancel(Timer)
    end,
    ok.
    
start_receive_hello_timer(State) ->
    Timer = start_timer(State#of_switch_state.receive_hello_timer,
                        ?RECEIVE_HELLO_TIMEOUT_MSECS, 
                        timer_expired_receive_hello),
    State#of_switch_state{receive_hello_timer = Timer}.
    
stop_receive_hello_timer(State) ->
    stop_timer(State#of_switch_state.receive_hello_timer),
    State#of_switch_state{receive_hello_timer = undefined}.

start_send_echo_request_timer(State) ->
    Timer = start_timer(State#of_switch_state.send_echo_request_timer,
                        ?SEND_ECHO_REQUEST_INTERVAL_MSECS, 
                        timer_expired_send_echo_request),
    State#of_switch_state{send_echo_request_timer = Timer}.

%% TODO: need this?    
%% stop_send_echo_request_timer(State) ->
%%     stop_timer(State#of_switch_state.send_echo_request_timer),
%%     State#of_switch_state{send_echo_request_timer = undefined}.


send_message(Xid, Message, State) ->
    io:format("of_switch: send message Xid=~w Message=~w~n", [Xid, Message]),
    ConnectionPid = State#of_switch_state.connection_pid,
    ok = of_connection:send(ConnectionPid, Xid, Message),
    State.

allocate_xid(State) ->
    Xid = State#of_switch_state.next_local_xid,
    NextXid = case Xid of
                  ?MAX_UINT32 -> 1;
                  _           -> Xid + 1
              end,
    State1 = State#of_switch_state{next_local_xid = NextXid},
    {Xid, State1}.

add_pending_request(Xid, State, ProcessReplyFun) ->
    Message = {timer_expired_receive_reply, Xid},
    {ok, Timer} = timer:send_after(?RECEIVE_REPLY_TIMEOUT_MSECS, Message),
    PendingRequest = #pending_request{xid               = Xid, 
                                      timer             = Timer, 
                                      process_reply_fun = ProcessReplyFun},
    PendingRequests = State#of_switch_state.pending_requests,
    PendingRequests1 = dict:store(Xid, PendingRequest, PendingRequests),
    State#of_switch_state{pending_requests = PendingRequests1}.

extract_pending_request(Xid, State) ->
    PendingRequests = State#of_switch_state.pending_requests,
    case dict:is_key(Xid, PendingRequests) of
        true ->
            PendingRequest = dict:fetch(Xid, PendingRequests),
            PendingRequests1 = dict:erase(Xid, PendingRequests),
            State1 = State#of_switch_state{pending_requests = PendingRequests1},
            {PendingRequest, State1};
        false ->
            {undefined, State}
    end.

send_request(Message, ProcessReplyFun, State) ->
    {Xid, State1} = allocate_xid(State),
    State2 = add_pending_request(Xid, State1, ProcessReplyFun),
    send_message(Xid, Message, State2).

send_hello(State) ->
    Hello = #of_vxx_hello{version = ?OF_VERSION_MAX},
    send_message(_Xid = 0, Hello, State).

send_v10_echo_request(State) ->
    EchoRequest = #of_v10_echo_request{data = << >>},
    send_request(EchoRequest, fun process_received_v10_echo_reply/3, State).

send_error_incompatible(State) ->
    Error = #of_vxx_error{version = ?OF_VERSION_MIN,
                          type    = ?OF_VXX_ERROR_TYPE_HELLO_FAILED,
                          code    = ?OF_VXX_ERROR_CODE_HELLO_FAILED_INCOMPATIBLE,
                          data    = << ?OF_IMPLEMENTATION_NAME >>},
    send_message(_Xid = 0, Error, State).

process_connection_up(State) ->
    State1 = send_hello(State),
    State2 = start_receive_hello_timer(State1),
    start_send_echo_request_timer(State2).     %% TODO This depends on version negotiation

%% process_connection_down(State) ->
%%     %% TODO
%%     State.

process_timer_expired_receive_hello(State) ->
    State1 = State#of_switch_state{receive_hello_timer = undefined},
    io:format("of_switch: no hello received from peer, closing connection~n"),
    State2 = close_connection(State1),
    {stop, no_hello_received, State2}.

process_timer_expired_send_echo_request(State) ->
    State1 = State#of_switch_state{send_echo_request_timer = undefined},
    State2 = send_v10_echo_request(State1),    %% TODO: This depends on negotiated verion
    {noreply, State2}.

process_timer_expired_receive_reply(Xid, State) ->
    %% TODO: look up the Xid and determine what to do
    io:format("of_switch: no reply received from peer for Xid=~w, closing connection~n", [Xid]),
    State1 = close_connection(State),
    {stop, no_reply_received, State1}.

process_received_message(Xid, Message, State) ->
    io:format("of_switch: receive message Xid=~w Message=~w~n", [Xid, Message]),
    case State#of_switch_state.version of
        undefined -> process_received_initial_message(Xid, Message, State);
        _         -> process_received_subsequent_message(Xid, Message, State)
    end.

process_received_initial_message(Xid, Message, State) ->
    if
        is_record(Message, of_vxx_hello)        -> process_received_initial_hello(Xid, Message, State);
        true                                    -> process_received_initial_unexpected_message(Xid, Message, State)
    end.

process_received_initial_hello(_Xid, Hello, State) ->
    State1 = stop_receive_hello_timer(State),
    Version = Hello#of_vxx_hello.version,
    if
        (Version >= ?OF_VERSION_MIN) andalso (Version =< ?OF_VERSION_MAX) ->
            io:format("of_switch: version negotiation succeeded Version=~w~n", [Version]),
            State2 = State#of_switch_state{version = Version},
            {noreply, State2};
        true ->
            io:format("of_switch: version negotiation failed Version=~w~n", [Version]),
            State2 = send_error_incompatible(State1),
            State3 = close_connection(State2),
            %% TODO: This causes a "=ERROR REPORT===="; can that be avoided?
            {stop, version_negotiation_failed, State3}
    end.

process_received_initial_unexpected_message(_Xid, _Message, State) ->
    %% TODO
    {noreply, State}.

process_received_subsequent_message(Xid, Message, State) ->
    %% TODO: make sure version is negotiated version; pass Version along with Xid after all.
    if
        is_record(Message, of_vxx_hello)        -> process_received_hello(Xid, Message, State);
        is_record(Message, of_v10_echo_request) -> process_received_v10_echo_request(Xid, Message, State);
        is_record(Message, of_v10_echo_reply)   -> process_received_reply(Xid, Message, State);
        true                                    -> process_received_unknown_message(Xid, Message, State)
    end.

process_received_hello(_Xid, Hello, State) ->
    %% Be tolerant: allow peer to send hello message as non-initial message (ignore it)
    io:format("of_switch: peer unexpectedly sent non-initial hello message Hello=~w~n", [Hello]),
    {noreply, State}.

process_received_v10_echo_request(Xid, EchoRequest, State) ->
    Data = EchoRequest#of_v10_echo_request.data,
    EchoReply = #of_v10_echo_reply{data = Data},
    State1 = send_message(Xid, EchoReply, State),
    {noreply, State1}.

process_received_reply(Xid, Reply, State) ->
    {PendingRequest, State1} = extract_pending_request(Xid, State),
    case PendingRequest of
        undefined ->
            io:format("of_switch: received unsolicited or late reply Xid=~w Reply=~w~n", [Xid, Reply]),
            {noreply, State1};
        _ ->
            #pending_request{timer = Timer, process_reply_fun = ProcessReplyFun} = PendingRequest,
            timer:cancel(Timer),
            ProcessReplyFun(Xid, Reply, State1)
    end.

process_received_v10_echo_reply(_Xid, EchoReply, State) ->
    %% Be tolerant; accept echo reply with data which does not match echo request
    case EchoReply#of_v10_echo_reply.data of
        << >> -> nop;
        Data  -> io:format("of_switch: echo reply contains unexpected data ~w~n", [Data])
    end,
    State1 = start_send_echo_request_timer(State),
    {noreply, State1}.

process_received_unknown_message(_Xid, Message, State) ->
    %% TODO: add missing messages
    io:format("of_switch: process_received_unknown_message Message=~w~n", [Message]),
    {noreply, State}.
