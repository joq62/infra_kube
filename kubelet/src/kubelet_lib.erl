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
-include("interface/if_repo.hrl").

-include("infra_kube/kubelet/src/kubelet_local.hrl").

-include("include/trace_debug.hrl").
-include("include/kubelet_data.hrl").
-include("include/dns_data.hrl").
-include("include/repository_data.hrl").

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
%dns_register(DnsInfo, DnsList) ->
 %   TimeStamp=erlang:now(),
  %  NewDnsInfo=DnsInfo#dns_info{time_stamp=TimeStamp},
  %  #dns_info{time_stamp=_,ip_addr=IpAddr,port=Port,service_id=ServiceId}=DnsInfo,
    
  %  X1=[X||X<-DnsList,false==({IpAddr,Port,ServiceId}==
%				  {X#dns_info.ip_addr,X#dns_info.port,X#dns_info.service_id})],
 %   NewDnsList=[NewDnsInfo|X1],
 %   NewDnsList.

%de_dns_register(DnsInfo,DnsList)->
 %   #dns_info{time_stamp=_,ip_addr=IpAddr,port=Port,service_id=ServiceId}=DnsInfo,
 %   NewDnsList=[X||X<-DnsList,false==({IpAddr,Port,ServiceId}==
%				  {X#dns_info.ip_addr,X#dns_info.port,X#dns_info.service_id})],
 %   NewDnsList.

%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
load_start_service(ServiceId)->
    Result=case file:make_dir(ServiceId) of
	       {error,Err}->
		   {error,[?MODULE,?LINE,ServiceId,Err]};
	       ok->
		   case kubelet:send("repo",?GetLoadmodules(ServiceId)) of
		       {ServiceId,ModuleList}->
			   WriteFileResult=[{FileName,file:write_file(filename:join(ServiceId,FileName),Binary)}||{FileName,Binary}<-ModuleList],
			   case write_result(WriteFileResult,ok) of
			       {error,Err} ->
				   {error,[?MODULE,?LINE,ServiceId,Err,WriteFileResult]};
			       ok-> % Modules loaded - just start the service
				   Application=list_to_atom(ServiceId),
				   PathR=code:add_path(ServiceId),
				   R=application:start(Application),   
				   code:add_path(ServiceId),
				   application:start(Application),
				   ok
			   end;
		       Err ->
			   {error,[?MODULE,?LINE,ServiceId,Err]}
		   end
	   end,
    Result.    

write_result([],ok)->
    ok;
write_result([],{error,Err}) ->
    {error,Err};
write_result([{_,R}|T],_) ->
    write_result(T,R).

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
stop_unload_service(ServiceId)->
    Application=list_to_atom(ServiceId),
    R1=application:stop(Application),
    R2=application:unload(Application),    
    os:cmd("rm -rf "++ServiceId),
    io:format("~p~n",[{?MODULE,?LINE,ServiceId}]),
    code:del_path(ServiceId),
    {R1,R2}.
    

%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
%zone()->
 %   {ok,I}=file:consult("kubelet.config"),
  %  R=case lists:keyfind(zone,1,I) of
%	  {zone,Z}->
%	      Z;
%	  false ->
%	      []
%     end,
%    R.

%capabilities()->
%    {ok,I}=file:consult("kubelet.config"),
%    R=case lists:keyfind(capabilities,1,I) of
%	  {capabilities,C}->
%	      C;
%	  false ->
%	      []
 %     end,
 %   R.


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
