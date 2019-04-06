%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%%
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(if_dns).

% 
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("include/dns.hrl").
-include("include/tcp.hrl").
-include("include/dns_data.hrl").
%% --------------------------------------------------------------------



%% External exports
-compile(export_all).


%% ====================================================================
%% External functions
%% ====================================================================

%% ====================================================================
%% Server functions
%% ====================================================================
%% --------------------------------------------------------------------
%% Function: fun/x
%% Description: fun x skeleton 
%% Returns:ok|error
%% --------------------------------------------------------------------
reg_info()->
    {ok,IpAddr}=application:get_env(ip_addr),
    {ok,Port}=application:get_env(port),
    {ok,ServiceId}=application:get_env(service_id),
    {ServiceId,IpAddr,Port}.
    




%% --------------------------------------------------------------------
%% Function: fun/x
%% Description: fun x skeleton 
%% Returns:ok|error
%% --------------------------------------------------------------------
call(ServiceId,{M,F,A})-> 
    {ok,DnsIp}=application:get_env(dns_ip_addr),
    {ok,DnsPort}=application:get_env(dns_port),
    call(ServiceId,{M,F,A},{DnsIp,DnsPort}).

call(ServiceId,{M,F,A},{DnsIp,DnsPort})->    
 % io:format(" ~p~n",[{?MODULE,?LINE,ServiceId,M,F,A}]),
    call(ServiceId,{M,F,A},{DnsIp,DnsPort},?TIMEOUT_TCPCLIENT);

call(ServiceId ,{M,F,A},TimeOut)->
    {ok,DnsIp}=application:get_env(dns_ip_addr),
    {ok,DnsPort}=application:get_env(dns_port),
    call(ServiceId,{M,F,A},{DnsIp,DnsPort},TimeOut).

call(ServiceId,{M,F,A},{DnsIp,DnsPort},TimeOut)->
    Result=case ServiceId of
	       "dns"->
		   ssl_lib:ssl_call([{DnsIp,DnsPort}],{M,F,A},TimeOut);
	       _->
		   case ssl_lib:ssl_call([{DnsIp,DnsPort}],{dns,get_instances,[ServiceId]}) of
		       {error,Err}->
			   io:format("Error ~p~n",[{?MODULE,?LINE,Err}]),
			   {error,[?MODULE,?LINE,Err]};
		       []->
			   %io:format("Error ~p~n",[{?MODULE,?LINE,'no availible nodes ',ServiceId,Vsn}]),
			   {error,[?MODULE,?LINE,'no availible nodes ',ServiceId]};
		       {badrpc,Err}->
			   io:format("Error ~p~n",[{?MODULE,?LINE,Err}]),
			   {error,[?MODULE,?LINE,Err]};
		       InstancesDnsInfo->
			   Addresses=[{DnsInfo#dns_info.ip_addr,DnsInfo#dns_info.port}||DnsInfo<-InstancesDnsInfo],
			   ssl_lib:ssl_call(Addresses,{M,F,A},TimeOut)
		 
		  end
	   end,
    Result. 

%% --------------------------------------------------------------------
%% Function: fun/x
%% Description: fun x skeleton 
%% Returns:ok|error
%% ------------------------------------------------------------------
cast(ServiceId,{M,F,A})-> 
    {ok,DnsIp}=application:get_env(dns_ip_addr),
    {ok,DnsPort}=application:get_env(dns_port),
    cast(ServiceId ,{M,F,A},{DnsIp,DnsPort}).

cast(ServiceId ,{M,F,A},{DnsIp,DnsPort})->
    Result=case ServiceId of
	"dns"->
		   ssl_lib:ssl_cast([{DnsIp,DnsPort}],{M,F,A});
	       _->
		   case ssl_lib:ssl_call([{DnsIp,DnsPort}],{dns,get_instances,[ServiceId ]}) of
		       {error,Err}->
			   {error,[?MODULE,?LINE,Err]};
		       []->
			   io:format("Error ~p~n",[{?MODULE,?LINE,'no availible nodes ',ServiceId }]),
			   {error,[?MODULE,?LINE,'no availible nodes ',ServiceId]};
		       {badrpc,Err}->
			   io:format("Error ~p~n",[{?MODULE,?LINE,Err}]),
			  {error,[?MODULE,?LINE,Err]};
		       InstancesDnsInfo->
			   Addresses=[{DnsInfo#dns_info.ip_addr,DnsInfo#dns_info.port}||DnsInfo<-InstancesDnsInfo],
			   ssl_lib:ssl_cast(Addresses,{M,F,A})
		   end
	   end,
    Result. 
