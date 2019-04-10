%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%%
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(monitor_lib).
 
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("infra_kube/monitor/src/monitor_local.hrl").
-include("interface/if_ssl.hrl").
-include("interface/if_controller.hrl").
-include("interface/if_dns.hrl").

-include("include/dns_data.hrl").



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
cmd(ServiceId,{M,F,A},{DnsIp,DnsPort})->
    Reply=case ?SslSend(DnsIp,DnsPort,dns,get_instances,[ServiceId]) of
	      []->
		  {error,[?MODULE,?LINE,eexist,ServiceId]};
	      DnsInfoList->
		  [{IpAddr,Port}|_]=[{DnsInfo#dns_info.ip_addr,DnsInfo#dns_info.port}||DnsInfo<-DnsInfoList],
		  ?SslSend(IpAddr,Port,M,F,A)
	  end,
    Reply.
    
	

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
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
