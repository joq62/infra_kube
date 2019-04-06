%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%%
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(if_log).

% 
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

-include("include/tcp.hrl").
-include("include/dns_data.hrl").
%% --------------------------------------------------------------------
-record(log,
	{
	  service,ip_addr,dns_addr,timestamp,type,severity,msg
	}).


%% External exports
-compile(export_all).


%% ====================================================================
%% External functions
%% ====================================================================

%% ====================================================================
%% Server functions
%% ====================================================================
%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
log(Type,Severity,MsgStr)->
    Msg=rpc:call(node(),if_log,init_log,[Type,Severity,MsgStr]),
    if_dns:cast("applog",{applog,log,[Msg]}).


init(Type,Severity,MsgStr)->
    rpc:call(node(),if_log,init_log,[Type,Severity,MsgStr]).

init_log(Type,Severity,MsgStr)->
    {ok,Service}=application:get_application(),
    {ok,DnsIp}=application:get_env(dns_ip_addr),
    {ok,DnsPort}=application:get_env(dns_port),
    {ok,IpAddr}=application:get_env(ip_addr),
    {ok,Port}=application:get_env(port),
    Log=#log{service=Service,ip_addr={IpAddr,Port},dns_addr={DnsIp,DnsPort},
	      timestamp={date(),time()},type=Type,
	      severity=1,
	      msg=MsgStr},
    Log.
