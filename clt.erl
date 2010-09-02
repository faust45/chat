-module(clt).

-compile(export_all).

start() -> 
  {ok, Socket} = 
  gen_tcp:connect("localhost", 5000, [binary, {packet, 4}]), 
  ok = gen_tcp:send(Socket, term_to_binary("coool")), 

  receive 
    {tcp,Socket,Bin} -> 
      io:format("Client received binary = ~p~n",[Bin]), 
      Val = binary_to_term(Bin), 
      io:format("Client result = ~p~n",[Val]), 
      gen_tcp:close(Socket) 
  end.
