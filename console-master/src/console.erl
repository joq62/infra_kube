%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : 
%%% Pool =[{Pid1,Ref1,Module},{Pid2,Ref2,Module}]
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(console).

-behaviour(gen_server).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("interface/if_controller.hrl").
-include("interface/if_dns.hrl").

-include("console/src/console_local.hrl").

-include("include/trace_debug.hrl").
-include("include/tcp.hrl").
-include("certificate/cert.hrl").
-include("include/dns.hrl").
-include("include/dns_data.hrl").
-include("include/kubelet_data.hrl").
-include("include/loader.hrl").

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

-export([start_service/2,
	 stop_service/2,
	 loaded_services/0,
	 my_ip/0,
	 start_kubelet/0,
	 heart_beat/0,
	 register/1,de_register/1,
	 send/2,send/3
	]).
-export([start/0,stop/0]).

%% gen_server callbacks
-export([init/1, handle_call/3,handle_cast/2, handle_info/2, terminate/2, code_change/3]).

%% ====================================================================
%% External functions
%% ====================================================================
start_kubelet()->
    R1=application:load(kubelet),
    R2=application:start(kubelet),
    io:format("kubelet start result ~p~n",[{R1,R2}]),
    {R1,R2}.

send(ServiceId,{M,F,A}) ->
    Reply= case ServiceId of
	       "kubelet"->
		   rpc:call(node(),M,F,A);
	       ServiceId->
		   case console_dns:dns(ServiceId) of
		       []->
			   {error,[?MODULE,?LINE,no_services_available,ServiceId]};
		       [{IpAddr,Port}|_]->
			   ssl_lib:ssl_call([{IpAddr,Port}],{M,F,A})
		   end
	   end,
    Reply.

send(Zone,ServiceId,{M,F,A}) ->
    Reply= case ServiceId of
	       "kubelet"->
		   rpc:call(node(),M,F,A);
	       ServiceId->
		   case console_dns:dns(Zone,ServiceId) of
		       []->
			   {error,[?MODULE,?LINE,no_services_available,Zone,ServiceId]};
		       
		       [{IpAddr,Port}|_]->
			   ssl_lib:ssl_call([{IpAddr,Port}],{M,F,A})
		   end
	   end,
    Reply.
      
start()-> gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).
stop()-> gen_server:call(?MODULE, {stop},infinity).

%% ====================================================================
%% Server functions
%% ====================================================================

start_service(ServiceId,Vsn)-> 
    gen_server:call(?MODULE, {start_service,ServiceId,Vsn},infinity).
stop_service(ServiceId,Vsn)-> 
    gen_server:call(?MODULE, {stop_service,ServiceId,Vsn},infinity).

my_ip()-> 
    gen_server:call(?MODULE, {my_ip},infinity).
loaded_services()-> 
    gen_server:call(?MODULE, {loaded_services},infinity).

%%-----------------------------------------------------------------------

register(ServiceId)->
    gen_server:cast(?MODULE, {register,ServiceId}).
de_register(ServiceId)->
    gen_server:cast(?MODULE, {de_register,ServiceId}).

heart_beat()->
    gen_server:cast(?MODULE, {heart_beat}).

%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([]) ->
    
    % Init the local dns table - implemented with ets
    console_dns:init_dns_table(),

    % config data 
    {ok,InitialInfo}=file:consult("kubelet.config"),
    {ip_addr,NodeIp}=lists:keyfind(ip_addr,1,InitialInfo),
    {port,NodePort}=lists:keyfind(port,1,InitialInfo),
    {max_workers,MaxWorkers}=lists:keyfind(max_workers,1,InitialInfo),
    {zone,Zone}=lists:keyfind(zone,1,InitialInfo),
    {capabilities,Capabilities}=lists:keyfind(capabilities,1,InitialInfo),
    {dns,DnsIp,DnsPort}=lists:keyfind(dns,1,InitialInfo),  
    {node_type,NodeType}=lists:keyfind(node_type,1,InitialInfo),  
    {git_url,GitUrl}=lists:keyfind(git_url,1,InitialInfo),
    {cert,CertFile}=lists:keyfind(cert,1,InitialInfo),
    {key,KeyFile}=lists:keyfind(key,1,InitialInfo),

    KubeletInfo=#kubelet_info{time_stamp="not_initiaded_time_stamp",
			      service_id = glurk,
			      vsn = glurk,
			      ip_addr=NodeIp,
			      port=NodePort,
			      max_workers=MaxWorkers,
			      zone=Zone,
			      capabilities=Capabilities,
			      node_type=NodeType
			     },    
    ok=ssl:start(),
    {ok, LSock} = ssl:listen(NodePort, [binary,{packet,4},
				    {certfile,CertFile}, {keyfile,KeyFile}, 
				      {reuseaddr, true}, {active, true}]),
    Workers=init_workers(LSock,MaxWorkers,[]), % Glurk remove?
    spawn(fun()-> local_heart_beat(?HEARTBEAT_INTERVAL) end), 
    %console specific 
  

    io:format("Started Service  ~p~n",[{?MODULE}]),
    {ok, #state{ service_list=[],
		 git_url=GitUrl,
		 kubelet_info=KubeletInfo,
		 lSock=LSock,max_workers=MaxWorkers,
		 active_workers=0,workers=Workers,dns_list=[],dns_addr={dns,DnsIp,DnsPort}}}.

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

handle_call({start_service,AppId,Vsn}, From, State) ->
    Reply=console:send("controller",?Add(AppId,Vsn)),
    {reply, Reply, State};

handle_call({stop_service,AppId,Vsn}, From, State) ->
    Reply=console:send("controller",?Remove(AppId,Vsn)),
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
handle_cast({register,ServiceId}, State) ->
    KubeletInfo=State#state.kubelet_info,
    IpAddr= KubeletInfo#kubelet_info.ip_addr,
    Port=KubeletInfo#kubelet_info.port,
    [Zone]=KubeletInfo#kubelet_info.zone,
    DnsInfo=#dns_info{time_stamp=na,zone=Zone,  service_id=ServiceId,ip_addr=IpAddr,port=Port},
    {dns,DnsIp,DnsPort}=State#state.dns_addr,
    console:send("dns",?DnsRegister(DnsInfo)),

%    io:format("register,DnsInfo ~p~n",[{?MODULE,?LINE,DnsInfo}]),
    {noreply, State};

handle_cast({de_register,ServiceId}, State) ->
    KubeletInfo=State#state.kubelet_info,
    IpAddr= KubeletInfo#kubelet_info.ip_addr,
    Port=KubeletInfo#kubelet_info.port,
    [Zone]=KubeletInfo#kubelet_info.zone,
    DnsInfo=#dns_info{time_stamp=na,zone=Zone,  service_id=ServiceId,ip_addr=IpAddr,port=Port},
    {dns,DnsIp,DnsPort}=State#state.dns_addr,
    
    %DnsInfo=?DNS_INFO(Zone,ServiceId,IpAddr,Port,time_stamp,schedule),
    console:send("dns",?DeDnsRegister(DnsInfo)),
 %   if_dns:cast("dns",{dns,de_dns_register,[DnsInfo]},{DnsIp,DnsPort}),
%    io:format("de_register,DnsInfo ~p~n",[{?MODULE,?LINE,DnsInfo}]),
    {noreply, State};

handle_cast({heart_beat},State) ->
    {dns,DnsIp,DnsPort}=State#state.dns_addr,
    AvailableServices=if_dns:call("dns",{dns,get_all_instances,[]},{DnsIp,DnsPort}), 
   
     % Convert DnsInfo -> ServiceInfo
    FilteredServices=[{DnsInfo#dns_info.zone,DnsInfo#dns_info.service_id,DnsInfo#dns_info.ip_addr,DnsInfo#dns_info.port}||DnsInfo<-AvailableServices],
    LocalServiceList=ets:tab2list(?DNS_TABLE),
    
    {Added,Removed}=console_dns:diff_dns(LocalServiceList,FilteredServices),
    case Added of
	[]->
	    ok;
	Added->
	    [console_dns:update_dns_table(ServiceInfo)||ServiceInfo<-Added]
    end,
    case Removed of
	[]->
	    ok;
	Removed->
	    [console_dns:delete(ServiceInfo)||ServiceInfo<-Removed]
    end,
 %   io:format("Added  ~p~n",[{?MODULE,?LINE,Added}]),
  %  io:format("Removed  ~p~n",[{?MODULE,?LINE,Removed}]),
    
    NewState=State#state{service_list=FilteredServices},
 %   io:format("AvailableServices  ~p~n",[{?MODULE,?LINE,FilteredServices}]),
    %console specific 
   spawn(console,register,["console"]),
   {noreply,NewState};


handle_cast({log,Msg}, State) ->
    {dns,DnsIp,DnsPort}=State#state.dns_addr,
    if_dns:cast("applog",{applog,log,[Msg]},{DnsIp,DnsPort}),
    {noreply, State};


handle_cast({upgrade,_ServiceId,_Vsn}, State) ->
	    % get tar file from SW repositroy
	    % create service_info record
	    % create temp dir 
	    % untar files 
	    % read app file -get all modules
            % de_register the service and remove it from service list
	    % copy modules and app file to service_ebin dir
	    % start the service
	    % remove temp dir
	    % add service to service_list
	    % service shall push info to dns and kubectroller     % 
  
    
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
handle_info({_Pid,active}, State) ->
    ActiveWorkers=State#state.active_workers+1,
    NewState = State#state{active_workers=ActiveWorkers},
%   io:format("active  ~p~n",[{?MODULE,?LINE,NewState}]), 
   {noreply, NewState};

handle_info({'DOWN',Ref,process,Pid,normal},  #state{lSock = LSock,active_workers=ActiveWorkers,
						     max_workers=Max,workers=Workers} = State) ->
    %  io:format("DOWN Pid,Ref an workers  ~p~n",[{?MODULE,?LINE,Pid,Ref,Workers}]), 
    W1=lists:delete({Pid,Ref},Workers),
    NewActiveWorkers=ActiveWorkers-1,
    if
	ActiveWorkers<Max-> %Accept new 
	    ParentPid=self(),
	    {NewPid,NewRef}=spawn_monitor(fun()->start_worker(ParentPid,LSock) end),
	    NewWorkerList=[{NewPid,NewRef}|W1];
	ActiveWorkers==Max->
	    NewWorkerList=W1
    end,

    NewState=State#state{active_workers=NewActiveWorkers,workers=NewWorkerList},
   % io:format("DOWN  ~p~n",[{?MODULE,?LINE,NewState}]),
    {noreply, NewState};

handle_info({ssl_closed,{sslsocket,{gen_tcp,Port,tls_connection,undefined},Pid}}, State)->
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
local_heart_beat(Interval)->
  %  io:format(" ~p~n",[{?MODULE,?LINE}]),
    timer:sleep(1000),
    ?MODULE:heart_beat(),
    timer:sleep(Interval),
    spawn(fun()-> local_heart_beat(Interval) end).

%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------

init_workers(_,0,Workers)->
    Workers;
init_workers(LSock,N,Workers)->
    ParentPid=self(),
    {Pid,Ref}=spawn_monitor(fun()->start_worker(ParentPid,LSock) end),
    NewWorkers=[{Pid,Ref}|Workers],
    init_workers(LSock,N-1,NewWorkers).
    



%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
start_worker(ParentPid,LSock)->
    {ok, Socket} = ssl:transport_accept(LSock),
    ok= ssl:ssl_accept(Socket),
    ParentPid!{self(),active},
    receive
	{ssl,{sslsocket,_Z1,_Z2},IoList}->
	    case binary_to_term(iolist_to_binary(IoList)) of
		[{M,F,A},?KEY_MSG]->
		    Reply=rpc:call(node(),erlang,apply,[M,F,A]),
		 %   Reply=rpc:call(node(),M,F,A),
		    ssl:send(Socket,[term_to_binary(Reply)]);
		%% To be deleted
		[call,{M,F,A},?KEY_MSG]->
						%	    io:format(" ~p~n",[{?MODULE,?LINE,{call,{M,F,A}}}]),
		    Reply=rpc:call(node(),M,F,A),
		    ssl:send(Socket,[term_to_binary(Reply)]);
		[cast,{M,F,A},?KEY_MSG]->
			%    io:format(" ~p~n",[{?MODULE,?LINE,{cast,{M,F,A}}}]),
		    _CastReply=rpc:cast(node(),M,F,A);
		%  End to be deleted io:format("~p~n",[{?MODULE,?LINE,CastReply}]);
		Err->
		    io:format("Error ~p~n",[{?MODULE,?LINE,Err}])
	    end;
	{tcp_closed,Socket} ->
	    exit
    end.

