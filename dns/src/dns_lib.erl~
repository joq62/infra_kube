%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%%
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(dns_lib).
 


%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("include/dns.hrl").
-include("include/dns_data.hrl").
-include("include/data.hrl").
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
local_log_call(DnsInfo,Type,Info,_DnsList)->
    ServiceId=DnsInfo#dns_info.service_id,
    IpAddr=DnsInfo#dns_info.ip_addr,
    Port=DnsInfo#dns_info.port,	
    Event=[{ip_addr,IpAddr},
	   {port,Port},
	   {service_id,ServiceId},
	   {event_type,Type},
	   {event_info,Info}
	  ],
    Event.



get_instances(WantedServiceStr,DnsList)->
    Reply=[DnsInfo||DnsInfo<-DnsList, WantedServiceStr=:=DnsInfo#dns_info.service_id], 
    Reply.
