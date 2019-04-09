%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%%
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(loader_lib).
 
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("infra_kube/loader/src/loader_local.hrl").
-include("include/git.hrl").
%% --------------------------------------------------------------------
-record(log,
	{
	  service,ip_addr,dns_addr,timestamp,type,severity,msg
	}).
	  
-define(LOG(Type,Severity,MsgStr),
	{
	  service=application:get_application(),
	  ip_addr={application:get_env(ip_addr),application:get_env(port)},
	  dns_addr=application:get_env(dns),
	  timestamp={date(),time()},
	  type=Type,
	  severity=Severity,
	  msg=MsgStr
	}
       ).

%% External exports
-compile(export_all).


%% ====================================================================
%% External functions
%% ====================================================================
%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
init_system_node(InitialInfo)->
    {keep_dirs,KeepDirs}=lists:keyfind(keep_dirs,1,InitialInfo),
    ScratchResult=loader_lib:scratch_computer(KeepDirs),
 %   io:format("~p~n",[{?MODULE,?LINE,ScratchResult}]), 
    timer:sleep(100),

% Clone infra_kube to get system services
    os:cmd("git clone "++?GIT_LM_INFRA_KUBE),
    {init_load_apps,InitLoadApps}=lists:keyfind(init_load_apps,1,InitialInfo),
    
% Create service dirs and copy files 
 %   io:format("make dir = ~p~n",[{?MODULE,?LINE,[file:make_dir(ServiceId)||ServiceId<-InitLoadApps]}]),
    [file:make_dir(ServiceId)||ServiceId<-InitLoadApps],
    copy_files(InitLoadApps),
    
    
    
   % [os:cmd("cp "++filename:join(?INFRA_KUBE_DIR,ServiceId)++"/* "++  ServiceId)||ServiceId<-InitLoadApps],

% Remove the infra_kube files the repo needs to manage them
    os:cmd("rm -r "++?INFRA_KUBE_DIR),
    
%Start services     
    StartResult=[{ServiceId,start_service(ServiceId)}||ServiceId<-InitLoadApps],
  %  io:format("StartResult = ~p~n",[{?MODULE,?LINE,StartResult}]),
    StartResult.

copy_files([])->
    ok;
copy_files([ServiceId|T])->
    {ok,FileNames}=file:list_dir(filename:join(?INFRA_KUBE_DIR,ServiceId)), 
%    io:format("ServiceId,FileNames  = ~p~n",[{?MODULE,?LINE,ServiceId,FileNames}]),
 %   io:format("copy files = ~p~n",[{?MODULE,?LINE,[file:copy(filename:join([?INFRA_KUBE_DIR,ServiceId,FileName]),filename:join(ServiceId,FileName))||FileName<-FileNames]}]),
    [file:copy(filename:join([?INFRA_KUBE_DIR,ServiceId,FileName]),filename:join(ServiceId,FileName))||FileName<-FileNames],
    copy_files(T).
%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
init_worker_node(InitialInfo)->
    {keep_dirs,KeepDirs}=lists:keyfind(keep_dirs,1,InitialInfo),
    ScratchResult=loader_lib:scratch_computer(KeepDirs),
    io:format("~p~n",[{?MODULE,?LINE,ScratchResult}]), 
    init_worker_node(InitialInfo,do_init).
    
init_worker_node(InitialInfo,restart)->
    timer:sleep(?WAIT_FOR_CONTROLLER),
    init_worker_node(InitialInfo);
init_worker_node(_,ok) ->
    ok;
init_worker_node(InitialInfo,_)->

% Clone infra_kube to get system services
    os:cmd("git clone "++?GIT_LM_INFRA_KUBE),
    {init_load_apps,InitLoadApps}=lists:keyfind(init_load_apps,1,InitialInfo),
    
% Create service dirs and copy files 
    [file:make_dir(ServiceId)||ServiceId<-InitLoadApps],
    [os:cmd("cp "++filename:join(?INFRA_KUBE_DIR,ServiceId)++"/* "++  ServiceId)||ServiceId<-InitLoadApps],

% Remove the infra_kube files the repo needs to manage them
    os:cmd("rm -r "++?INFRA_KUBE_DIR),
    
%Start services     
    StartResult=[{ServiceId,start_service(ServiceId)}||ServiceId<-InitLoadApps],
    case [{error,Err}||{error,Err}<-StartResult] of
	[]-> % No errors
	    Acc=ok;
	_->
	    Acc=restart
    end,
    init_worker_node(InitialInfo,Acc).
    

%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
start_service(ServiceId)->
    PathR=code:add_path(ServiceId),
    ok=application:load(list_to_atom(ServiceId)),
    R=application:start(list_to_atom(ServiceId)),
 %   io:format("ServiceId,PathR,R  = ~p~n",[{?MODULE,?LINE,ServiceId,PathR,R}]),
    R.
      
%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
scratch_computer(KeepDirs)->
    {ok,Files}=file:list_dir("."),
    DirsRemove=[Dir||Dir<-Files,
		     filelib:is_dir(Dir),
		     false==lists:member(Dir,KeepDirs)],
    
    %stop  services , ServiceId=DirName
%    [application:stop(list_to_atom(ServiceId))||ServiceId<-DirsRemove],
%    [application:unload(list_to_atom(ServiceId))||ServiceId<-DirsRemove],
 %   [code:del_path(ServiceId)||ServiceId<-DirsRemove],

    RmResult=[{Dir,os:cmd("rm -rf "++Dir)}||Dir<-DirsRemove],
    RmResult.

%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------

unconsult(File,L)->
    {ok,S}=file:open(File,write),
    lists:foreach(fun(X)->
			  io:format(S,"~p.~n",[X]) end,L),
    file:close(S).
			  
