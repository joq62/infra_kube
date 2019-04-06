%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%%
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(repo_ets).



%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("infra_kube/repo/src/repo_local.hrl").


%% --------------------------------------------------------------------
%% External exports
-compile(export_all).
%% ====================================================================
%% External functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------


init_repo_table()->
    Reply=case ets:info(?REPO_TABLE) of
	      undefined->
		  ets:new(?REPO_TABLE,[set,named_table,public]);
	      _->
		  ets:delete(?REPO_TABLE),
		  ets:new(?REPO_TABLE,[set,named_table,public])
	  end, 
    Reply.
     
%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------

update_josca_info(FileNameUpdate,JoscaInfoUpdate)->
    L=ets:match(?REPO_TABLE,'$1'),    
    L1=[{FileName,JoscaInfo}||[{FileName,JoscaInfo}]<-L,
			      FileNameUpdate==FileName],
    R=case L1 of
	  []->
	      ets:insert(?REPO_TABLE,{FileNameUpdate,JoscaInfoUpdate});
	  [Remove] ->
	      ets:delete_object(?REPO_TABLE,Remove),
	      ets:insert(?REPO_TABLE,{FileNameUpdate,JoscaInfoUpdate})
      end,
    R.

delete_josca_info(FileName,JoscaInfo)->
    ets:delete_object(?REPO_TABLE,{FileName,JoscaInfo}).

read_josca_info(FileName)->
    ets:lookup(?REPO_TABLE,FileName).

update_loadmodule(ServiceIdUpdate,ModuleListUpdate)->
    L=ets:match(?REPO_TABLE,'$1'),    
    L1=[{ServiceId,ModuleList}||[{ServiceId,ModuleList}]<-L,
			      ServiceIdUpdate==ServiceId],
    R=case L1 of
	  []->
	      ets:insert(?REPO_TABLE,{ServiceIdUpdate,ModuleListUpdate});
	  [Remove] ->
	      ets:delete_object(?REPO_TABLE,Remove),
	      ets:insert(?REPO_TABLE,{ServiceIdUpdate,ModuleListUpdate})
      end,
    R.


delete_loadmodule(ServiceId,ModuleList)->
    ets:delete_object(?REPO_TABLE,{ServiceId,ModuleList}).

get_loadmodules(ServiceId)->
    ets:lookup(?REPO_TABLE,ServiceId).
