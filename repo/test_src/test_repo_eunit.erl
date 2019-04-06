%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%%
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(test_repo_eunit).
 
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include_lib("eunit/include/eunit.hrl").

-include("infra_kube/repo/src/repo_local.hrl").

-include("include/kubelet_data.hrl").
-include("include/dns_data.hrl").

%% --------------------------------------------------------------------
-define(ADDER_JOSCA,[{"adder.josca",
		      [{specification,adder},
		       {type,service},
		       {description,"Josca file for adder"},
		       {vsn,"1.0.0"},
		       {exported_services,["adder"]},
		       {application_id,"adder"},
		       {num_instances,2},
		       {zone,[]},
		       {geo_red,[]},
		       {needed_capabilities,[]},
		       {dependencies,[]}]}]
	).

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
    os:cmd("rm -r josca"),
    os:cmd("rm -r loadpackage_infra_kube "),
    ok=application:load(repo),
    ok=application:start(repo),
    ok.


init_josca_test()->
    NodeName="repo_test",
    Host=net_adm:localhost(),
    NodeStr=NodeName++"@"++Host,
    Node=list_to_atom(NodeStr),
    [{"adder.josca",
            {"adder.josca",
             [{specification,adder},
              {type,service},
              {description,"Josca file for adder"},
              {vsn,"1.0.0"},
              {exported_services,["adder"]},
              {application_id,"adder"},
              {num_instances,2},
              {zone,[]},
              {geo_red,[]},
              {needed_capabilities,[]},
              {dependencies,[]}]}}]=rpc:call(Node,repo,read_josca_info,["adder.josca"]),
  

    ok.
    
loadmodules_test()->
    NodeName="repo_test",
    Host=net_adm:localhost(),
    NodeStr=NodeName++"@"++Host,
    Node=list_to_atom(NodeStr),
    [{true,"repo"},{true,"dns"},{true,"lib"}]=rpc:call(Node,repo,pull_loadmodules,[]),
    [{"dns",
      [{"dns_lib.beam",_},
       {"dns.app",_},
       {"dns_sup.beam",_},
       {"dns_app.beam",_},
       {"dns.beam",_}]}] =rpc:call(Node,repo,get_loadmodules,["dns"]),

    [{"lib",
      [{"lib_sup.beam",_},
       {"tcp.beam",_},
       {"if_log.beam",_},
       {"dbase_dets.beam",_},
       {"lib.beam",_},
       {"lib.app",_},
       {"repo_cmn.beam",_},
       {"ssl_lib.beam",_},
       {"lib_app.beam",_},
       {"cmn.beam",_},
       {"if_dns.beam",_},
       {"lib_lib.beam",_}]}] =rpc:call(Node,repo,get_loadmodules,["lib"]),
    ok.

stop_test()->
    ok=application:stop(repo),
    ok=application:unload(repo),
    ok.
