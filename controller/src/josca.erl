%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%%
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(josca).



%% --------------------------------------------------------------------
%% Include files1
%% --------------------------------------------------------------------
-include("interface/if_repo.hrl").
-include("infra_kube/controller/src/controller_local.hrl").
-include("include/git.hrl").
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
%% Function: 
%% Description:
%% Returns: non
%% 
info(FullFileName)->
    {ok,Info}=file:consult(FullFileName),
    {specification,NameStr}=lists:keyfind(specification,1,Info),
    {type,Type}=lists:keyfind(type,1,Info),
    {Type,NameStr,Info}.

files(Info)->
    R= case lists:keyfind(josca_files,1,Info) of
	   false->
	       [];
	   {josca_files,JoscaFiles}->
	       JoscaFiles
       end,
    R.
type(I)->
    R= case  lists:keyfind(type,1,I) of
	   false->
	       [];
	   {type,Type}->
	       Type
       end,
    R.

exported_services(I)->
    R= case  lists:keyfind(exported_services,1,I) of
	   false->
	       [];
	   {services,Service}->
	       Service
       end,
    R.

num_instances(I)->
    {num_instances,R}=lists:keyfind(num_instances,1,I),
    R.
zone(I)->
    R= case  lists:keyfind(zone,1,I) of
	   false->
	       [];
	   {zone,Zone}->
	       Zone
       end,
    R.

needed_capabilities(I)->
    R= case  lists:keyfind(needed_capabilities,1,I) of
	   false->
	       [];
	   {needed_capabilities,Capa}->
	       Capa
       end,
    R.

geo_red(I)->
    R= case  lists:keyfind(geo_red,1,I) of
	   false->
	       [];
	   {geo_red,GeoRed}->
	       GeoRed
       end,
    R.
dependencies(I)->
    R= case  lists:keyfind(dependencies,1,I) of
	   false->
	       [];
	   {dependencies,Dependencies}->
	       Dependencies
       end,
    R.    

%% --------------------------------------------------------------------------


start_order(JoscaFile,State)->
    Result= case kubelet:send("repo",?ReadJoscaInfo(JoscaFile)) of
		[]->
		    NewState=State,
			 %if_dns:cast("applog",{applog,log,
			%			[if_log:init('ERROR',3,["file:consult",FileName,Err])]
			%		       }),
		    io:format(" Error  ~p~n",[{?MODULE,?LINE,time(),eexist,JoscaFile}]),
		    {error,[?MODULE,?LINE,eexist,JoscaFile]};
		{JoscaFile,JoscaInfo}->
		    io:format("repo = JoscaFile,JoscaInfo ~p~n",[{?MODULE,?LINE, JoscaFile,JoscaInfo}]),
		    Acc=case lists:keyfind(type,1,JoscaInfo) of 
			   {type,application}->
			       [];
			   {type,service} ->
			       {application_id,ServiceId}=lists:keyfind(application_id,1,JoscaInfo),
			       [ServiceId]
			end,
						% io:format("~p~n",[{?MODULE,?LINE,Acc}]),
		    {dependencies,JoscaFiles}=lists:keyfind(dependencies,1,JoscaInfo),
		    io:format("~p~n",[{?MODULE,?LINE,JoscaFiles}]),
		    dfs(JoscaFiles,Acc,State);	  
		Err->
		    {error,[?MODULE,?LINE,Err]}
	    end,
    Result.


dfs([],Acc,_)->
    Acc;
dfs([JoscaFile|T],Acc,State)->
   
    case  kubelet:send("repo",?ReadJoscaInfo(JoscaFile)) of
	{error,Err}->
	    JoscaFiles=[],
	    Acc1=Acc,
	    [{error,[?MODULE,?LINE,Err]}|Acc];
	{JoscaFile,JoscaInfo}->
	    case lists:keyfind(type,1,JoscaInfo) of 
		{type,application}->
		    Acc1=Acc;
		{type,service} ->
		     {application_id,ServiceId}=lists:keyfind(application_id,1,JoscaInfo),
		    Acc1=[{ServiceId}|Acc]
	    end,
	    {dependencies,JoscaFiles}=lists:keyfind(dependencies,1,JoscaInfo)
    end,
    Acc2=dfs(JoscaFiles,Acc1,State),
    %io:format("~p~n",[{?MODULE,?LINE,Acc2}]),
    dfs(T,Acc2,State).

%%-----------------------------------------------------------------------------
