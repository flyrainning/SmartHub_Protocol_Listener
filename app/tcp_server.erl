-module(tcp_server).
-author('flyrainning <http://www.fengpiao.net>').
-export([listen/4]).

-define(TCP_OPTIONS, [binary, {packet, 0}, {active, false}, {reuseaddr, true}]).

% Call echo:listen(Port) to start the service.
listen(Script_Server,Script_Port,Script_File,Port) ->
    {ok, LSocket} = gen_tcp:listen(Port, ?TCP_OPTIONS),
    accept(Script_Server,Script_Port,Script_File,LSocket).

% Wait for incoming connections and spawn the echo loop when we get one.
accept(Script_Server,Script_Port,Script_File,LSocket) ->
    {ok, Socket} = gen_tcp:accept(LSocket),
    spawn(fun() -> loop(Socket,{Script_Server,Script_Port,Script_File}) end),
    accept(Script_Server,Script_Port,Script_File,LSocket).

% Echo back whatever data we receive on Socket.
loop(Socket,{Server,SPort,File}) ->
    case gen_tcp:recv(Socket, 0) of
        {ok, Data} ->
%        io:format("recv ~p~n", [Data]),
            %%gen_tcp:send(Socket, Data),
		case check:getdata(Data) of

			{ok,{Protocol,PostData}} ->
%	io:format("getdata ~p~n", [PostData]),		
				{ok,CGIData}=fastcgi:do_request({Server,SPort,File},{Protocol,PostData}),
				CGIDatastr=binary_to_list(CGIData),
		   
		   		ResData=string:substr(CGIDatastr,string:str(CGIDatastr,"\r\n\r\n")+4),
		   		if
					(length(ResData)>1)->
%	io:format("send ~p~n", [ResData]),		
		   				gen_tcp:send(Socket, ResData);
					true ->
						true
				end;
			 _ ->
				true
		end,
		
         
        	loop(Socket,{Server,SPort,File});
          %%  gen_tcp:close(Socket);
        {error, closed} ->
            ok
    end.
    
    


