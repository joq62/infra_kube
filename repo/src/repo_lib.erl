%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%%
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(repo_lib).
 


%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

-include("include/git.hrl").
-include("infra_kube/repo/src/repo_local.hrl").
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
pull_josca(GitUrl,Destination)->
    os:cmd("git clone "++GitUrl),
    {ok,FileNames}=file:list_dir(?JOSCA_DIR),
    L1=[{FileName,file:consult(filename:join(?JOSCA_DIR,FileName))}||FileName<-FileNames,
								    ".josca"==filename:extension(FileName)],
    L2=[repo_ets:update_josca_info(FileName,JoscaInfo)||{FileName,{ok,JoscaInfo}}<-L1],

    ok.


%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
pull_loadmodules(GitUrl,Destination)->
    os:cmd("git clone "++GitUrl),
    {ok,ServiceDirs}=file:list_dir(Destination),
    R=update_service(ServiceDirs,Destination,[]),
    R.
update_service([],_,Acc)->
    Acc;

update_service([".git"|T],Destination,Acc)->
    update_service(T,Destination,Acc);

update_service([ServiceId|T],Destination,Acc)->
    {ok,FileNames}=file:list_dir(filename:join(Destination,ServiceId)),
    L1=[{FileName,file:read_file(filename:join([Destination,ServiceId,FileName]))}||FileName<-FileNames],
    ModuleList=[{FileName,Binary}||{FileName,{ok,Binary}}<-L1],
    NewAcc=[{repo_ets:update_loadmodule(ServiceId,ModuleList),ServiceId}|Acc],
    update_service(T,Destination,NewAcc).
