
   
-module(fastcgi).
-compile(export_all).


do_request({Server,Port,File},{Protocol,PostData}) -> 

   

     Env = [
  %%   {"SERVER_SOFTWARE","test web server"},
  %%    {"SERVER_NAME","localhost"},
  %%    {"HTTP_HOST","localhost"},
  %%    {"GATEWAY_INTERFACE","CGI/1.1"},
  %%    {"SERVER_PROTOCOL","HTTP/1.1"},
 %%     {"SERVER_PORT","8080"},
      {"REQUEST_METHOD","GET"},
      
  %%   {"DOCUMENT_ROOT","/fpapi/erlang/phototype/"},
      {"SCRIPT_FILENAME",File},
   %%    {"SCRIPT_NAME","/test.php"},

     %% {"QUERY_STRING",[]},
      {"protocol",Protocol},
      {"data",PostData}
      ],%%构造http访问相关配置
      
  %%  io:format("Argv msg: ~ts~n", [Argv]),
    {ok, Socket}=gen_tcp:connect(Server,Port,[binary, {packet, 0}, {active,true}],30000),
    fcgi_send_record(Socket,1,1,<<1:16,0:8,0:40>>),
    fcgi_send_record(Socket, 4,1, Env),   
    fcgi_send_record(Socket, 4,1, []), 
    Bin = phpRespone(Socket,[]),
    gen_tcp:close(Socket),
    %%原报文<<Version:8, Type:8, RequestId:16, ContentLength:16,PaddingLength:8, Reserved:8,Str/binary >> = Bin,   
    <<_:32,ContentLength:16,_:16,Str/binary >> = Bin,   
    %%计算输出内容长度   
    Dlen=ContentLength-52,   
    %%获取内容   
    << _H:52/binary,Data:Dlen/binary,_Other/binary >> = Str,   
  %%  io:fwrite("rs:~p~n",[Data]),
    {ok,Data}.


recv_msg(Sock) ->
    receive   
        {tcp, Sock, Bin} ->
   %%         io:format("Bin msg: ~p~n", [Bin]),
            %%原报文<<Version:8, Type:8, RequestId:16, ContentLength:16,PaddingLength:8, Reserved:8,Str/binary >> = Bin,   
            <<_:32,ContentLength:16,_:16,Str/binary >> = Bin,   
            %%计算输出内容长度   
            Dlen=ContentLength-52,   
            %%获取内容   
            << _H:52/binary,Data:Dlen/binary,_Other/binary >> = Str,   
   %%         io:fwrite("rs:~p~n",[Data]),
            {ok,Data};
        {tcp_closed,Sock} ->
   %%         io:format("socket close: ~p~n", [Sock]);
   		1;
        _Other ->    
   %%         io:format("Other msg: ~p~n", [_Other]),   
            recv_msg(Sock) 
  after 3000 ->io:format("Time out.~n")   
  end.   

phpRespone(Sock,SoFar) ->
    receive   
        {tcp, Sock, Bin} ->
            phpRespone(Sock,[Bin|SoFar]);
        {tcp_closed,Sock} ->
            list_to_binary(lists:reverse(SoFar));
        _Other ->    
    %%        io:format("Other msg: ~p~n", [_Other]),   
            phpRespone(Sock,SoFar) 
  after 3000 ->io:format("Time out.~n")   
  end.   


%%发送选项   
fcgi_send_record(Socket, Type, RequestId, NameValueList) ->   
    EncodedRecord = fcgi_encode_record(Type, RequestId,NameValueList),   
    gen_tcp:send(Socket, EncodedRecord).   
  
  
  
%%组包   
fcgi_encode_record(Type, RequestId, NameValueList) when is_list(NameValueList) ->   
    fcgi_encode_record(Type, RequestId,fcgi_encode_name_value_list(NameValueList));
    
%%判断ContentData是否满8字节,否则填充   
fcgi_encode_record(Type, RequestId, ContentData)   when is_binary(ContentData) ->   
    ContentLength = size(ContentData),   
    PaddingLength = if  
                        ContentLength rem 8 == 0 ->   
                            0;   
                        true ->   8
- (ContentLength rem 8)   
                    end,   
    %%填充数据,每8字节组包   不足用0填充     
    PaddingData = <<0:(PaddingLength*8)>>,   
    Version = 1,   
    Reserved = 0,   
    <<Version:8,   
      Type:8,   
      RequestId:16,   
      ContentLength:16,   
      PaddingLength:8,   
      Reserved:8,   
      ContentData/binary,   
      PaddingData/binary >>.   
 
 
 
%%将环境变量组成binary   
fcgi_encode_name_value_list(_NameValueList = []) ->   
    << >>;
    
fcgi_encode_name_value_list(_NameValueList = [{Name, Value} | Tail]) ->   
    <<(fcgi_encode_name_value(Name,Value))/binary,(fcgi_encode_name_value_list(Tail))/binary >>.
    
fcgi_encode_name_value(Name, _Value = undefined) ->   
    fcgi_encode_name_value(Name, "");
    
fcgi_encode_name_value(Name, Value) when is_list(Name) and is_list(Value) ->   
    NameSize = length(Name),   
    NameSizeData = << NameSize:8>>,   
    ValueSize = length(Value),
    
    if ValueSize < 128 ->
            ValueSizeData = <<ValueSize:8>>;
        ValueSize > 127 ->
            ValueSizeData = <<(ValueSize bor 16#80000000):32>>
    end,
    
    << NameSizeData/binary,ValueSizeData/binary,(list_to_binary(Name))/binary,(list_to_binary(Value))/binary >>.
