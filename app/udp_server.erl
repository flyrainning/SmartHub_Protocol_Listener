-module(udp_server).
-author('flyrainning <http://www.fengpiao.net>').
-export([listen/4]).

-define(UDP_OPTIONS, [binary, {active, false}]).

% Call echo:listen(Port) to start the service.
listen(Script_Server,Script_Port,Script_File,Port) ->
    {ok, USocket} = gen_udp:open(Port, ?UDP_OPTIONS),
    accept(Script_Server,Script_Port,Script_File,USocket).

% Wait for incoming connections and spawn the echo loop when we get one.
accept(Script_Server,Script_Port,Script_File,Socket) ->
    case gen_udp:recv(Socket, 0) of
    	{ok, {Address, Port, Packet}} ->
%%io:format("rec: ~p~n", [Packet]),
    		spawn(fun() -> cgi_call(Socket,{Script_Server,Script_Port,Script_File}, {Address, Port, Packet}) end);
    	
    	%%{error, Reason} ->
    	%%	finderr
    	_ ->
        	true
    end,
    
    accept(Script_Server,Script_Port,Script_File,Socket).



cgi_call(Socket,{Server,SPort,File},{Address, Port, Data}) ->
% io:format("recv ~p~n", [Data]),
	case check:getdata(Data) of
		{ok,{Protocol,PostData}} ->
%	io:format("okdata ~p~n", [PostData]),
			{ok,CGIData}=fastcgi:do_request({Server,SPort,File},{Protocol,PostData}),
			CGIDatastr=binary_to_list(CGIData),
        %% io:format("CGIDatastr ~p~n", [CGIDatastr]),  
           		ResData=string:substr(CGIDatastr,string:str(CGIDatastr,"\r\n\r\n")+4),
        %%io:format("ResData ~p~n", [ResData]),  
           		if
				(length(ResData)>1)->
%	io:format("sendback ~p~n", [ResData]),
           				gen_udp:send(Socket, Address, Port, ResData);
				true ->
					true
			end;
		 _ ->
			true
	end.
    
