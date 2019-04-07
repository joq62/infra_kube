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
init_worker_node(InitialInfo)->
   init_system_node(InitialInfo).

%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
init_system_node(InitialInfo)->
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
    StartResult.

%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
start_service(ServiceId)->
    PathR=code:add_path(ServiceId),
    R=application:start(list_to_atom(ServiceId)),
    {R,PathR}.
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
			  
