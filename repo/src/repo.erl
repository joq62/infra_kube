%%% -------------------------------------------------------------------
%%% Author  : Joq Erlang
%%% Description : test application calc
%%%  
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(repo).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("interface/if_kubelet.hrl").
%-include("interface/if_monitor.hrl").

-include("infra_kube/repo/src/repo_local.hrl").

-include("include/git.hrl").
-include("include/tcp.hrl").
-include("include/data.hrl").
-include("include/dns_data.hrl").
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Key Data structures
%% 
%% --------------------------------------------------------------------


%% --------------------------------------------------------------------




-export([pull_josca/0,
	 read_josca_info/1,
	 update_josca_info/2,
	 delete_josca_info/2,
	 pull_loadmodules/0,
	 get_loadmodules/1
	]).

-export([start/0,
	 stop/0,
	 heart_beat/0
	]).

%% gen_server callbacks
-export([init/1, handle_call/3,handle_cast/2, handle_info/2, terminate/2, code_change/3]).


%% ====================================================================
%% External functions
%% ====================================================================

%% Asynchrounus Signals



%% Gen server functions

start()-> gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).
stop()-> gen_server:call(?MODULE, {stop},infinity).



%%------------------- gen_server:call -----------------------------------
read_josca_info(FileName)->
    gen_server:call(?MODULE,{read_josca_info,FileName},infinity).

update_josca_info(FileName,JoscaInfo)->
    gen_server:call(?MODULE,{update_josca_info,FileName,JoscaInfo},infinity).

delete_josca_info(FileName,JoscaInfo)->
    gen_server:call(?MODULE,{delete_josca_info,FileName,JoscaInfo},infinity).

pull_josca()->
    gen_server:call(?MODULE, {pull_josca},infinity).

pull_loadmodules()->
    gen_server:call(?MODULE, {pull_loadmodules},infinity).

get_loadmodules(ServiceId)->
    gen_server:call(?MODULE,{get_loadmodules,ServiceId},infinity).


heart_beat()->
    gen_server:call(?MODULE, {heart_beat},5000).


%%--------------------gen_server:cast ----------------------------------



%% ====================================================================
%% Server functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%
%% --------------------------------------------------------------------
init([]) ->
    repo_ets:init_repo_table(),
 
    repo_lib:pull_josca(?GIT_JOSCA,?JOSCA_DIR),
    repo_lib:pull_loadmodules(?GIT_LM_INFRA_KUBE,?INFRA_KUBE_DIR),
    repo_lib:pull_loadmodules(?GIT_LM_APPS_KUBE,?APPS_KUBE_DIR),

    spawn(fun()-> local_heart_beat(?HEARTBEAT_INTERVAL) end), 
    io:format("Service ~p~n",[{?MODULE, 'started '}]),
  %  kubelet:send("kubelet",?Register(atom_to_list(?MODULE))),
    {ok, #state{}}.   
    
%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               |
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (aterminate/2 is called)
%% --------------------------------------------------------------------

handle_call({read_josca_info,FileName}, _From, State) ->
    Reply=repo_ets:read_josca_info(FileName),
    {reply, Reply, State};

handle_call({update_josca_info,FileName,JoscaInfo}, _From, State) ->
    Reply=repo_ets:update_josca_info(FileName,JoscaInfo),
    {reply, Reply, State};

handle_call({delete_josca_info,FileName,JoscaInfo}, _From, State) ->
    Reply=repo_ets:delete_josca_info(FileName,JoscaInfo),
    {reply, Reply, State};


handle_call({pull_josca}, _From, State) ->
    GitUrl=?GIT_JOSCA,
    Destination=?JOSCA_DIR,
    Reply=repo_lib:pull_josca(GitUrl,Destination),
    {reply, Reply, State};

handle_call({pull_loadmodules}, _From, State) ->
    GitUrl=?GIT_LM_INFRA_KUBE,
    Destination=?INFRA_KUBE_DIR,
    Reply=repo_lib:pull_loadmodules(GitUrl,Destination),
    {reply, Reply, State};

handle_call({get_loadmodules,ServiceId}, _From, State) ->
    Reply=repo_ets:get_loadmodules(ServiceId),
    {reply, Reply, State};

handle_call({heart_beat},_, State) ->
    kubelet:send("kubelet",?Register(atom_to_list(?MODULE))),   
    {reply,ok, State};

handle_call({stop}, _From, State) ->
    kubelet:send("kubelet",?DeRegister(atom_to_list(?MODULE))),  
    io:format("stop ~p~n",[{?MODULE,?LINE}]),
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
    io:format("unmatched match cast ~p~n",[{?MODULE,?LINE,Msg}]),
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------

handle_info({tcp_closed,_Port}, State) ->
  %  io:format("unmatched signal ~p~n",[{?MODULE,?LINE,tcp,Port,binary_to_term(Bin)}]),
    {noreply, State};

handle_info({tcp,_Port,_Bin}, State) ->
  %  io:format("unmatched signal ~p~n",[{?MODULE,?LINE,tcp,Port,binary_to_term(Bin)}]),
    {noreply, State};


handle_info(Info, State) ->
    io:format("unmatched match info ~p~n",[{?MODULE,?LINE,Info}]),
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
%% Internal functions
%% --------------------------------------------------------------------
    

%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
local_heart_beat(Interval)->
%    io:format(" ~p~n",[{?MODULE,?LINE}]),
    timer:sleep(100),
    ?MODULE:heart_beat(),
    timer:sleep(Interval),
    spawn(fun()-> local_heart_beat(Interval) end).
%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------

