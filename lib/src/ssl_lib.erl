%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Created : 7 March 2015
%%% Revsion : 2015-06-19: 1.0.0 :  Created
%%% Description :
%%% Generic tcp server interface to internet and "middle man". Concept 
%%% described in Joe Armstrong book
%%% -------------------------------------------------------------------
-module(ssl_lib).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Definitions
%% --------------------------------------------------------------------
-include("include/trace_debug.hrl").
-include("include/tcp.hrl").
-include("certificate/cert.hrl").

%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports
%% --------------------------------------------------------------------
-export([ssl_call/2,ssl_call/3,ssl_cast/2,
	 server_seq/3,server_parallel/3,par_connect/1]).

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
ssl_call(Addresses,{os,cmd,A})->
    ssl_send_call(Addresses,[call,{?KEY_M_OS_CMD,?KEY_F_OS_CMD,A},?KEY_MSG],?TIMEOUT_TCPCLIENT,noresult);
ssl_call(Addresses,{M,F,A})->
    ssl_send_call(Addresses,[call,{M,F,A},?KEY_MSG],?TIMEOUT_TCPCLIENT,noresult).

ssl_call(Addresses,{os,cmd,A},TimeOut)->
    ssl_send_call(Addresses,[call,{?KEY_M_OS_CMD,?KEY_F_OS_CMD,A},?KEY_MSG],TimeOut,noresult);
ssl_call(Addresses,{M,F,A},TimeOut)->
    ssl_send_call(Addresses,[call,{M,F,A},?KEY_MSG],TimeOut,noresult).

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
ssl_send_call([],_,_,Reply)->
     Reply;
ssl_send_call([{IpAddr,Port}|T],Msg,TimeOut,_Result)->
    case ssl:connect(IpAddr,Port,?CLIENT_SETUP) of
	{ok,Socket}->
	    case ssl:send(Socket,[term_to_binary(Msg)]) of
		ok->
		    receive
			{ssl,{sslsocket,_Z1,_Z2},IoList}->
			    Bin=iolist_to_binary(IoList),
			    NewResult=binary_to_term(Bin),
			    Retry=false;
			{error,Err} ->
			    io:format("send error ~p~n",[{?MODULE,?LINE,Err,IpAddr,Port,Msg}]),
			    NewResult={error,[?MODULE,?LINE,Err]},
			    ssl:close(Socket),
			    Retry=true
		    after TimeOut ->
			    io:format("send error ~p~n",[{?MODULE,?LINE,time_out,IpAddr,Port,Msg}]),
			    NewResult={error,[?MODULE,?LINE,tcp_timeout,IpAddr,Port,Msg]},
			    ssl:close(Socket),
			    Retry=true
		    end;
		{error,Err}->
		    Retry=true,
		    NewResult={error,[?MODULE,?LINE,Err,IpAddr,Port,Msg]}
	    end;
	{error,Err}->
	    Retry=true,
	    NewResult={error,[?MODULE,?LINE,Err,IpAddr,Port,Msg]}
    end,
    case Retry of
	true->
	    Reply=ssl_send_call(T,Msg,TimeOut,NewResult);
	false ->
	    Reply=NewResult
    end,
    Reply.
    
%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------

   
ssl_cast(Addresses,{os,cmd,A})->
    ssl_send_cast(Addresses,[cast,{?KEY_M_OS_CMD,?KEY_F_OS_CMD,A},?KEY_MSG],noresult);
ssl_cast(Addresses,{M,F,A})->
    ssl_send_cast(Addresses,[cast,{M,F,A},?KEY_MSG],noresult).

ssl_send_cast([],_,Reply)->
    Reply;
ssl_send_cast([{IpAddr,Port}|T],Msg,_Result)->
    case ssl:connect(IpAddr,Port,?CLIENT_SETUP) of
	{ok,Socket}->
	    case ssl:send(Socket,[term_to_binary(Msg)]) of
		ok->
		    NewResult=ok,
		    Retry=false,
		    ssl:close(Socket);
		{error,Err}->
		    Retry=true,
		    NewResult={error,[?MODULE,?LINE,Err,IpAddr,Port,Msg]}
	    end;
	{error,Err}->
	    
	    Retry=true,
	    NewResult={error,[?MODULE,?LINE,Err,IpAddr,Port,Msg]}
    end,
    case Retry of
	true->
	    Reply=ssl_send_cast(T,Msg,NewResult);
	false ->
	    Reply=NewResult
    end,
    Reply.

%% --------------------------------------------------------------------
%% Function: fun/x
%% Description: fun x skeleton 
%% Returns:ok|error
%% --------------------------------------------------------------------

% Receive part
%% --------------------------------------------------------------------
%% Function: fun/x
%% Description: fun x skeleton 
%% Returns:ok|error
%% ------------------------------------------------------------------
server_seq(Port,CertFile,KeyFile)->
    ssl:start(),
    {ok, LSock} = ssl:listen(Port, [binary,{packet,4},{certfile,CertFile}, {keyfile,KeyFile}, 
				      {reuseaddr, true}, {active, true}]),
    seq_loop(LSock).

seq_loop(LSock)->
    {ok, Socket} = ssl:transport_accept(LSock),
    ok= ssl:ssl_accept(Socket),
    single(Socket),
    seq_loop(LSock).

%% --------------------------------------------------------------------
%% Function: fun/x
%% Description: fun x skeleton 
%% Returns:ok|error
%% ------------------------------------------------------------------
server_parallel(Port,CertFile,KeyFile)->
    ssl:start(),
    {ok, LSock} = ssl:listen(Port, [binary,{packet,4},{certfile,CertFile}, {keyfile,KeyFile}, 
				      {reuseaddr, true}, {active, true}]),
    spawn(fun()-> par_connect(LSock) end),
    receive
	wait_for_ever->
	    ok
    end.

par_connect(LSock)->
    {ok, Socket} = ssl:transport_accept(LSock),
    ok= ssl:ssl_accept(Socket),
    spawn(fun()-> par_connect(LSock) end),
    single(Socket).
%% --------------------------------------------------------------------
%% Function: fun/x
%% Description: fun x skeleton 
%% Returns:ok|error
%% ------------------------------------------------------------------
single(Socket)->
    receive
	{tcp, Socket, RawData}->
	    case binary_to_term(RawData) of
		[{call,{M,F,A}},?KEY_MSG]->
		    R=rpc:call(node(),M,F,A),
		    io:format("~p~n",[{?MODULE,?LINE,R}]),
		    Reply=case R of
			      {badrpc,Err}->
				  {error,[?MODULE,?LINE,Err]};
			      R->
				  R
			  end,
		    ssl:send(Socket,[term_to_binary(Reply)]),
		    single(Socket);
		[{cast,{M,F,A}},?KEY_MSG]->
		    _A=rpc:cast(node(),M,F,A),
		    ssl:close(Socket);
		Err->
		    io:format("Error ~p~n",[{?MODULE,?LINE,Err}])
	    end;
	{tcp_closed,Socket} ->
	    exit
    end.
