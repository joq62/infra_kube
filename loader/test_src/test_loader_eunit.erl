%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%%
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(test_loader_eunit).
 
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include_lib("eunit/include/eunit.hrl").

-include("infra_kube/loader/src/loader_local.hrl").

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
    ok=application:load(loader),
    ok=application:start(loader),
    ok.


a_test()->
    Apps=application:loaded_applications(),
    {repo,"repo  ","1.0.0"}=lists:keyfind(repo,1,Apps),
    {dns,"dns  ","1.0.0"}=lists:keyfind(dns,1,Apps),
    {lib,"lib funtions  ","1.0.0"}=lists:keyfind(lib,1,Apps),
    ok.
    


stop_test()->
    ok=application:stop(loader),
    ok=application:unload(loader),
    ok.
