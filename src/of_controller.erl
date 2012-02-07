%% @Author Bruno Rijsman <brunorijsman@hotmail.com>
%% @copyright 2012 Bruno Rijsman

%% TODO: Add support for IPv6
%% TODO: Add support for SSL

-module(of_controller).

-behavior(gen_server).

-export([start_link/1,
         stop/1,
         subscribe/2,
         unsubscribe/2]).

-export([init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3]).

-include_lib("eunit/include/eunit.hrl").
-include_lib("include/of_log.hrl").

-record(of_controller_state, {
          listen_port,
          listen_socket,
          acceptor_pid,
          handle_connection,    %% TODO: Do this with parse transform stubbing instead
          switches
         }).

-define(DEFAULT_LISTEN_PORT, 6636).
-define(TEST_LISTEN_PORT, 7000).

%%
%% Exported functions.
%%

start_link(Args) ->
    try
        State = initial_state(Args),
        gen_server:start_link(?MODULE, State, [])
    catch
        error:Reason ->
            {error, Reason}
    end.

stop(ControllerPid) ->
    gen_server:call(ControllerPid, stop).

subscribe(ControllerPid, Event) ->
    gen_server:call(ControllerPid, {subscribe, Event}).

unsubscribe(ControllerPid, Event) ->
    gen_server:call(ControllerPid, {unsubscribe, Event}).

%%                 
%% gen_server callbacks.
%%

init(State) ->
    process_flag(trap_exit, true),
    #of_controller_state{listen_socket = ListenSocket} = State,
    ServerPid = self(),
    AcceptorPid = spawn_link(fun() -> accept_loop(ServerPid, ListenSocket) end),
    State1 = State#of_controller_state{acceptor_pid = AcceptorPid},
    ok = of_group:create(of_switch),
    {ok, State1}.

handle_call(stop, _From, State) ->
    ?DEBUG("stop"),
    of_group:delete(of_switch),
    #of_controller_state{listen_socket = ListenSocket, switches = Switches} = State,
    case ListenSocket of
        undefined -> 
            nop;
        Socket ->
            gen_tcp:close(Socket)
    end,
    lists:foreach(fun(Pid) -> of_switch:stop(Pid) end, Switches),
    {stop, normal, stopped, State};

handle_call({subscribe, Event = switch}, From, State) ->
    {SubscriberPid, _} = From,
    ?DEBUG("subscribe Event=~w Subscriber=~w", [Event, SubscriberPid]),
    of_group:join(of_switch, SubscriberPid),
    #of_controller_state{switches = Switches} = State,
    lists:foreach(fun(Pid) -> SubscriberPid ! {of_event, switch, add, Pid} end, Switches),
    {reply, ok, State};

handle_call({subscribe, Event}, From, State) ->
    ?DEBUG("subscribe unknown Event=~w Subscriber=~w", [Event, From]),
    {reply, {error, unknown_event}, State};

handle_call({unsubscribe, Event = switch}, From, State) ->
    {SubscriberPid, _} = From,
    ?DEBUG("unsubscribe Event=~w Subscriber=~w", [Event, SubscriberPid]),
    of_group:leave(of_switch, SubscriberPid),
    {reply, ok, State};

handle_call({unsubscribe, Event}, From, State) ->
    ?DEBUG("unsubscribe unknown Event=~w Subscriber=~w", [Event, From]),
    {reply, {error, unknown_event}, State}.

%% @@ TODO: Also handle removing switches and reporting a corresponding event
%% @@ TODO: Also do some of this processing for outgoing connections
handle_cast({accepted, Socket}, State) ->
    #of_controller_state{handle_connection = HandleConnection, switches = Switches} = State,
    {ok, SwitchPid} = HandleConnection(Socket),
    %% TODO: Handle this differently and get rid of the undefined case
    State1 = case SwitchPid of
                 undefined ->
                     State;
                 _ ->
                     of_group:send(of_switch, {of_event, switch, add, SwitchPid}),
                     Switches1 = [SwitchPid | Switches],
                     State#of_controller_state{switches = Switches1}
                 end,
    {noreply, State1};

handle_cast({'EXIT', From, Reason}, State) ->
    ?DEBUG("received EXIT from ~w for reason ~w", [From, Reason]),
    {noreply, State};

handle_cast(Cast, State) ->
    ?DEBUG("received cast ~w", [Cast]),
    {noreply, State}.

handle_info(Info, State) ->
    ?DEBUG("received info ~w", [Info]),
    {noreply, State}.

terminate(Reason, _State) ->
    ?DEBUG("terminate Reason=~w", [Reason]),
    ok.

code_change(_OldVersion, State, _Extra) ->
    {ok, State}.

%%
%% Internal functions.
%%

initial_state(Args) ->
    State1 = #of_controller_state{listen_port       = ?DEFAULT_LISTEN_PORT,
                              listen_socket     = undefined,
                              acceptor_pid      = undefined,
                              handle_connection = fun handle_connection/1,
                              switches          = []},
    State2 = parse_args(Args, State1),
    TcpOptions = [binary, 
                  {packet, raw}, 
                  {active, false}, 
                  {reuseaddr, true},
                  {keepalive, true},
                  {backlog, 30}],
    ListenPort = State2#of_controller_state.listen_port,
    case gen_tcp:listen(ListenPort, TcpOptions) of
        {ok, ListenSocket} ->
            ?DEBUG("listening on port ~w", [ListenPort]),
            State2#of_controller_state{listen_socket = ListenSocket};
        {error, Reason} ->
            erlang:error(Reason)
    end.

parse_args(Args, State) ->
    lists:foldl(fun parse_arg/2, State, Args).

parse_arg({handle_connection, HandleConnection}, State) ->
    State#of_controller_state{handle_connection = HandleConnection};

parse_arg({listen_port, ListenPort}, State) ->
    State#of_controller_state{listen_port = ListenPort};

parse_arg(Arg, _State) ->
    erlang:error({unrecognized_attribute, Arg}).

handle_connection(Socket) ->
    %% Don't crash if switch doesn't start -- log something instead
    {ok, SwitchPid} = of_switch:start_link(),
    ok = of_switch:accept(SwitchPid, Socket),
    {ok, SwitchPid}.
    
accept_loop(ServerPid, ListenSocket) ->
    case gen_tcp:accept(ListenSocket) of
        {ok, Socket} ->
            ok = gen_tcp:controlling_process(Socket, ServerPid),
            gen_server:cast(ServerPid, {accepted, Socket}),
            accept_loop(ServerPid, ListenSocket);
        {error, Reason} ->
            exit({accept_error, Reason})
    end.


%%
%% Unit tests.
%%

test_handle_connection(Socket, TestPid) ->
    TestPid ! {connection, Socket},
    {ok, undefined}.

start_link_and_stop_test() ->
    StartLinkResult = start_link([]),
    ?assertMatch({ok, _}, StartLinkResult),
    {ok, Pid} = StartLinkResult,
    ?assertEqual(stopped, stop(Pid)).

start_link_arg_handle_connection_test() ->
    TestPid = self(),
    HandleConnection = fun(Socket) -> test_handle_connection(Socket, TestPid) end,
    StartLinkResult = start_link([{handle_connection, HandleConnection}]),
    ?assertMatch({ok, _}, StartLinkResult),
    {ok, Pid} = StartLinkResult,
    ?assertMatch(stopped, stop(Pid)).

start_link_arg_listen_port_test() ->
    StartLinkResult = start_link([{listen_port, ?TEST_LISTEN_PORT}]),
    ?assertMatch({ok, _}, StartLinkResult),
    {ok, Pid} = StartLinkResult,
    ?assertMatch(stopped, stop(Pid)).

start_link_arg_all_test() ->
    TestPid = self(),
    HandleConnection = fun(Socket) -> test_handle_connection(Socket, TestPid) end,
    StartLinkResult = start_link([{handle_connection, HandleConnection}, {listen_port, ?TEST_LISTEN_PORT}]),
    ?assertMatch({ok, _}, StartLinkResult),
    {ok, Pid} = StartLinkResult,
    ?assertMatch(stopped, stop(Pid)).

start_link_arg_bad_test() ->
    ?assertEqual({error,{unrecognized_attribute,bad}}, start_link([bad])).

connect_default_port_test() ->
    TestPid = self(),
    HandleConnection = fun(Socket) -> test_handle_connection(Socket, TestPid) end,
    StartLinkResult = start_link([{handle_connection, HandleConnection}]),
    ?assertMatch({ok, _}, StartLinkResult),
    {ok, Pid} = StartLinkResult,
    LocalHost = {127, 0, 0, 1},
    ConnectResult = gen_tcp:connect(LocalHost, ?DEFAULT_LISTEN_PORT, []),
    ?assertMatch({ok, _}, ConnectResult),
    {ok, ClientSocket} = ConnectResult,
    receive
        {connection, _ServerSocket} -> ok
    end,
    ?assertMatch(ok, gen_tcp:close(ClientSocket)),
    ?assertMatch(stopped, stop(Pid)).

connect_other_port_test() ->
    TestPid = self(),
    HandleConnection = fun(Socket) -> test_handle_connection(Socket, TestPid) end,
    StartLinkResult = start_link([{handle_connection, HandleConnection}, {listen_port, ?TEST_LISTEN_PORT}]),
    ?assertMatch({ok, _}, StartLinkResult),
    {ok, Pid} = StartLinkResult,
    LocalHost = {127, 0, 0, 1},
    ConnectResult = gen_tcp:connect(LocalHost, ?TEST_LISTEN_PORT, []),
    ?assertMatch({ok, _}, ConnectResult),
    {ok, ClientSocket} = ConnectResult,
    receive
        {connection, _ServerSocket} -> ok
    end,
    ?assertMatch(ok, gen_tcp:close(ClientSocket)),
    ?assertMatch(stopped, stop(Pid)).
