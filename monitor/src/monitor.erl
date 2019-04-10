%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : 
%%% Pool =[{Pid1,Ref1,Module},{Pid2,Ref2,Module}]
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(monitor).

-behaviour(gen_server).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("interface/if_ssl.hrl").
-include("interface/if_controller.hrl").
-include("interface/if_dns.hrl").

-include("infra_kube/monitor/src/monitor_local.hrl").

%-include("include/trace_debug.hrl").
%-include("include/tcp.hrl").
%-include("certificate/cert.hrl").



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

-export([
	 print/1,
	 cmd/4
	]).
-export([start_monitor/0,stop_monitor/0]).

-export([start/0,stop/0]).

%% gen_server callbacks
-export([init/1, handle_call/3,handle_cast/2, handle_info/2, terminate/2, code_change/3]).

%% ====================================================================
%% External functions
%% ====================================================================

start()-> gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).
stop()-> gen_server:call(?MODULE, {stop},infinity).


start_monitor()->
    R1=application:load(?MODULE),
    R2=application:start(?MODULE),
    {R1,R2}.

stop_monitor()->
    R1=application:stop(?MODULE),
    R2=application:unload(?MODULE),
    {R1,R2}.



%% ====================================================================
%% Server functions
%% ====================================================================


cmd(ServiceId,M,F,A)->
    gen_server:call(?MODULE, {cmd,ServiceId,M,F,A},infinity).
    
%%-----------------------------------------------------------------------

print(Msg)->
    gen_server:cast(?MODULE, {print,Msg}).

%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([]) ->
    
    % config data 
    {ok,InitialInfo}=file:consult("monitor.config"),
 %   {monitor_port,MonitorPort}=lists:keyfind(monitor_port,1,InitialInfo),  
    {dns,DnsIp,DnsPort}=lists:keyfind(dns,1,InitialInfo),  
    {cert,CertFile}=lists:keyfind(cert,1,InitialInfo),
    {key,KeyFile}=lists:keyfind(key,1,InitialInfo),
   
    ok=ssl:start(),
   % {ok, LSock} = ssl:listen(MonitorPort, [binary,{packet,4},
%				    {certfile,CertFile}, {keyfile,KeyFile}, 
%				      {reuseaddr, true}, {active, true}]),
    
  

    io:format("Started Service  ~p~n",[{?MODULE}]),
    {ok, #state{dns_addr={DnsIp,DnsPort}}}.

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
handle_call({cmd,ServiceId,M,F,A},_From, State) ->
    {DnsIp,DnsPort}=State#state.dns_addr,
    Reply = rpc:call(node(),monitor_lib,cmd,[ServiceId,{M,F,A},{DnsIp,DnsPort}],1000*10),
    {reply, Reply, State};

% --------------------------------------------------------------------
%% Function: stop/0
%% Description:
%% 
%% Returns: non
%% --------------------------------------------------------------------
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
handle_cast({print,Msg}, State) ->
     io:format(">> ~p~n",[Msg]),
    {noreply, State};


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
handle_info({ssl_closed,{sslsocket,{gen_tcp,_Port,tls_connection,undefined},_Pid}}, State)->
   % io:format("Port, Pid  ~p~n",[{?MODULE,?LINE,Port, Pid}]),
    {noreply, State};

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

