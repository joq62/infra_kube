%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%%
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(kubelet_lib).
 
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("kubelet/src/kubelet_local.hrl").

-include("include/trace_debug.hrl").
-include("include/kubelet_data.hrl").
-include("include/dns_data.hrl").
-include("include/repository_data.hrl").
-include("include/loader.hrl").
%% --------------------------------------------------------------------

%% External exports
-compile(export_all).

%-export([load_start_node/3,stop_unload_node/3
%	]).


%% ====================================================================
%% External functions
%% ====================================================================
%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
dns_register(DnsInfo, DnsList) ->
    TimeStamp=erlang:now(),
    NewDnsInfo=DnsInfo#dns_info{time_stamp=TimeStamp},
    #dns_info{time_stamp=_,ip_addr=IpAddr,port=Port,service_id=ServiceId}=DnsInfo,
    
    X1=[X||X<-DnsList,false==({IpAddr,Port,ServiceId}==
				  {X#dns_info.ip_addr,X#dns_info.port,X#dns_info.service_id})],
    NewDnsList=[NewDnsInfo|X1],
    NewDnsList.

de_dns_register(DnsInfo,DnsList)->
    #dns_info{time_stamp=_,ip_addr=IpAddr,port=Port,service_id=ServiceId}=DnsInfo,
    NewDnsList=[X||X<-DnsList,false==({IpAddr,Port,ServiceId}==
				  {X#dns_info.ip_addr,X#dns_info.port,X#dns_info.service_id})],
    NewDnsList.

%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
load_start_service(ApplicationId,GitUrl,{NodeIp,NodePort},{DnsIp,DnsPort})->
    io:format(" ~p~n",[{?MODULE, ?LINE,ApplicationId }]),
    os:cmd("rm -r "++?LOADPACKAGE++ApplicationId),
    GitService=GitUrl++?LOADPACKAGE++ApplicationId++".git",
    os:cmd("git clone "++GitService),

    GitJosca=GitUrl++?JOSCA++".git",
    os:cmd("git clone "++GitJosca),
    FileName=filename:join([?JOSCA,ApplicationId++".josca"]),
    Result=case file:consult(FileName) of
	       {error,Err}->
		   {error,[?MODULE,?LINE,Err,FileName]},
		   io:format("~p~n",[{error,[?MODULE,?LINE,Err,FileName]}]),
		   [{error,[?MODULE,?LINE,Err,FileName]}];
	       {ok,JoscaInfo}->
		   Application=list_to_atom(ApplicationId),
		   ok=application:set_env(Application,ip_addr,NodeIp),
		   ok=application:set_env(Application,port,NodePort),
		   ok=application:set_env(Application,application_id,ApplicationId),
		   ok=application:set_env(Application,dns_ip_addr,DnsIp),
		   ok=application:set_env(Application,dns_port,DnsPort),
		   io:format(" ~p~n",[{?MODULE, ?LINE,ApplicationId }]),
		   {exported_services,ExportedServices}=lists:keyfind(exported_services,1,JoscaInfo),
		   io:format(" ~p~n",[{?MODULE, ?LINE,exported_services,ExportedServices }]),
		   ok=application:set_env(Application,exported_services,ExportedServices),
		   ok=application:set_env(Application,git_url,GitUrl),

		   PathR=code:add_path(?LOADPACKAGE++ApplicationId),
		   R=application:start(Application),   
		   code:add_path(?LOADPACKAGE++ApplicationId),
		   application:start(Application)
	   end,	    
    Result.    

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
stop_unload_service(ApplicationId)->
    Application=list_to_atom(ApplicationId),
    R1=application:stop(Application),
    R2=application:unload(Application),    
    os:cmd("rm -rf "++?LOADPACKAGE++ApplicationId),
    code:del_path(?LOADPACKAGE++ApplicationId),
    {R1,R2}.
    

%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
zone()->
    {ok,I}=file:consult("kubelet.config"),
    R=case lists:keyfind(zone,1,I) of
	  {zone,Z}->
	      Z;
	  false ->
	      []
      end,
    R.

capabilities()->
    {ok,I}=file:consult("kubelet.config"),
    R=case lists:keyfind(capabilities,1,I) of
	  {capabilities,C}->
	      C;
	  false ->
	      []
      end,
    R.


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
