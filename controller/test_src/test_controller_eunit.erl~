%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%%
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(test_dns_eunit).
 
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include_lib("eunit/include/eunit.hrl").

%-include("infra_kube/lib/src/dns_local.hrl").

-include("include/kubelet_data.hrl").
-include("include/dns_data.hrl").

%% --------------------------------------------------------------------

%% External exports

-export([]).


%% ====================================================================
%% External functions
%% ====================================================================
%% --------------------------------------------------------------------
%% Function:init 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
init_test()->
    {ok,L}=file:consult("kubelet.config"),
    {ip_addr,NodeIp}=lists:keyfind(ip_addr,1,L),
    {port,NodePort}=lists:keyfind(port,1,L),
    {dns,DnsIp,DnsPort}=lists:keyfind(dns,1,L),
    Application=dns,
    ok=application:set_env(Application,ip_addr,NodeIp),
    ok=application:set_env(Application,port,NodePort),
    ok=application:set_env(Application,application_id,"dns"),
    ok=application:set_env(Application,dns_ip_addr,DnsIp),
    ok=application:set_env(Application,dns_port,DnsPort),
    ok=application:set_env(Application,exported_services,["dns"]),

    ok=application:load(dns),
    ok=application:start(dns),
    ok.





stop_test()->
    ok=application:stop(dns),
    ok=application:unload(dns),
    ok.
