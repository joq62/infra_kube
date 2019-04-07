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
    L1=[{{FileName,josca_info},JoscaInfo}||[{FileName,JoscaInfo}]<-L,
			      FileNameUpdate==FileName],
    R=case L1 of
	  []->
	      ets:insert(?REPO_TABLE,{{FileNameUpdate,josca_info},JoscaInfoUpdate});
	  [Remove] ->
	      ets:delete_object(?REPO_TABLE,Remove),
	      ets:insert(?REPO_TABLE,{{FileNameUpdate,josca_info},JoscaInfoUpdate})
      end,
    R.

delete_josca_info(FileName,JoscaInfo)->
    ets:delete_object(?REPO_TABLE,{{FileName,josca_info},JoscaInfo}).

read_josca_info(FileName)->
    R=case ets:lookup(?REPO_TABLE,{FileName,josca_info}) of
	  [{{FileName,josca_info},JoscaInfo}]->
	      {FileName,JoscaInfo};
	  [] ->
	      []
      end,
    R.
update_loadmodule(ServiceIdUpdate,ModuleListUpdate)->
    L=ets:match(?REPO_TABLE,'$1'),    
    L1=[{{ServiceId,loadmodules},ModuleList}||[{ServiceId,ModuleList}]<-L,
			      ServiceIdUpdate==ServiceId],
    R=case L1 of
	  []->
	      ets:insert(?REPO_TABLE,{{ServiceIdUpdate,loadmodules},ModuleListUpdate});
	  [Remove] ->
	      ets:delete_object(?REPO_TABLE,Remove),
	      ets:insert(?REPO_TABLE,{{ServiceIdUpdate,loadmodules},ModuleListUpdate})
      end,
    R.


delete_loadmodule(ServiceId,ModuleList)->
    ets:delete_object(?REPO_TABLE,{{ServiceId,loadmodules},ModuleList}).

get_loadmodules(ServiceId)->
    R = case ets:lookup(?REPO_TABLE,{ServiceId,loadmodules}) of
	   [{{ServiceId,loadmodules},ModuleList}]->
		{ServiceId,ModuleList};
	    [] ->
		[]
	end,
    R.
