%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : 
%%% Pool =[{Pid1,Ref1,Module},{Pid2,Ref2,Module}]
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(loader).

-behaviour(gen_server).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
%
-include("infra_kube/loader/src/loader_local.hrl").
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Define
%% --------------------------------------------------------------------
%-define(DEFINE,define).
%% --------------------------------------------------------------------
%% --------------------------------------------------------------------
%% Records
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------


%% External exports -gen_server functions 

-export([restart/0,
	 start_loader/0,
	 test/0
	]).
-export([start/0,stop/0]).

%% gen_server callbacks
-export([init/1, handle_call/3,handle_cast/2, handle_info/2, terminate/2, code_change/3]).

%% ====================================================================
%% External functions
%% ====================================================================
start_loader()->
    R1=application:load(loader),
    R2=application:start(loader),
    io:format("loader start result ~p~n",[{R1,R2}]),
    {R1,R2}.
    
start()-> gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).
stop()-> gen_server:call(?MODULE, {stop},infinity).

%% ====================================================================
%% Server functions
%% ====================================================================

restart()-> 
    gen_server:call(?MODULE, {restart},infinity).

%%----------------------------------------------------------------------
test()-> 
    gen_server:call(?MODULE, {test},infinity).

%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([]) ->
    {ok,InitialInfo}=file:consult("kubelet.config"),
    
    StartResult= case lists:keyfind(node_type,1,InitialInfo) of
		     {node_type,system_node}-> 
			 loader_lib:init_system_node(InitialInfo);
		     {node_type,worker_node}->
			 loader_lib:init_worker_node(InitialInfo)
		 end,
   %  io:format("Start result  ~p~n",[{?MODULE,?LINE, StartResult}]),

    {ip_addr,NodeIp}=lists:keyfind(ip_addr,1,InitialInfo),
    {port,NodePort}=lists:keyfind(port,1,InitialInfo),
    {dns,DnsIp,DnsPort}=lists:keyfind(dns,1,InitialInfo),  
    
    io:format("Started Service  ~p~n",[{?MODULE}]),
    {ok, #state{}}.

%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               |
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------


% --------------------------------------------------------------------
%% Function: stop/0
%% Description:
%% 
%% Returns: non
%% --------------------------------------------------------------------
handle_call({restart},_From, State) ->
    loader_lib:scratch_computer(State#state.keep_dirs),
    loader_lib:load(State#state.git_url,State#state.init_load_apps),
    Reply=loader_lib:start(State#state.init_load_apps),
    {reply, Reply, State};

handle_call({test},_From, State) ->
    Reply=loader_lib:test(),
    {reply, Reply, State};


handle_call({stop}, _From, State) ->
    {stop, normal, shutdown_ok, State};

handle_call(Request, From, State) ->
    Reply = {unmatched_signal,?MODULE,Request,From},
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_cast(Msg, State) ->
    io:format("unmatched match cast ~p~n",[{Msg,?MODULE,time()}]),
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------

handle_info(Info, State) ->
    io:format("unmatched info ~p~n",[{?MODULE,?LINE,Info}]),
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------
%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
