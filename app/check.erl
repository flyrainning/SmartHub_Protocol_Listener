-module(check).
-author('flyrainning <http://www.fengpiao.net>').
-export([getdata/1]).

       	
getdata(Data) -> 
	if
		(size(Data)>5)->

		
           		<<CRC:32/integer,Len:8/integer,ResDataWithProtocols/binary>> =Data,
           		<<ResDataWithProtocol:Len/binary-unit:8, _/binary>> = ResDataWithProtocols,

           		CRC2=erlang:crc32(ResDataWithProtocol),
           	
         	
         	%% io:format("CRC ~p~n", [CRC]),
         	
         	%% io:format("CRC2 ~p~n", [CRC2]),
			if
		 	 	CRC == CRC2 ->
		 	 		<<Protocol:8/bitstring,ResData/binary>> =ResDataWithProtocol,
		%%  io:format("p ~p~n", [Protocol]),
		%%  io:format("Res ~p~n", [ResData]),	
		 	 		{ok,{binary_to_list(Protocol),binary_to_list(ResData)}};
		 	 		%%{ok,{Protocol,binary_to_list(ResData)}};
		 	 	true ->
		 	 		{error, "CRC"}
			end;
         	 
		true ->
			{error, "SIZE"}
	end.
    

