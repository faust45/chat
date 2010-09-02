-module(chat).

-export([start/0]).
-compile(export_all).


start() ->
  {ok, ListenSocket} = gen_tcp:listen(5000, [list, {packet, http}, {active, false}, {reuseaddr, true}]),
  par_conn(ListenSocket).


par_conn(ListenSocket) ->
    io:format("Wait for client...~n"), 
    {ok, Socket} = gen_tcp:accept(ListenSocket),
    inet:setopts(Socket, [list, {packet, http}, {active, true}]),
    io:format("par_conn accept client~n"), 

    spawn(fun() -> par_conn(ListenSocket) end),
    loop(Socket).



loop(Socket) -> 
  io:format("start chanel ~n"), 
  receive
    {http, Socket, {http_request, Method, Path, Version}} ->
      io:format("http Server method= ~p path: ~p~n",[Method, Path]),
      headers(Socket, {request, Method, Path, Version}, []);
    {tcp_closed, Socket} ->
      io:format("Server socket closed~n");
    Any ->
      io:format("Any ~p~n",[Any]),
      loop(Socket)
  end.

 
headers(Socket, Request, Headers) ->
  receive
    {http, Socket, {http_header, _, Name, _, Value}} ->
      io:format("http Headers = ~p | ~p~n",[Name, Value]),
      headers(Socket, Request, [{Name, Value} | Headers]);
    {http, Socket, http_eoh} ->
      proc(Socket, Request, Headers)
  end.
  

proc(Socket, Request, Headers) ->
  {request, Method, Path, Version} = Request,
  {abs_path, APath} = Path,
  Tokens = string:tokens(APath, "/"),
  File = first(Tokens),

  io:format("http APath = ~p ~n",[APath]),
  io:format("http Tokens = ~p ~n",[File]),
  case File of
    "stream" ->
      io:format("http stream is come ~n"),
      ok = gen_tcp:send(Socket, "Hi man, its cool stuff..."),
      loop(Socket);
    "" -> 
      send_file(Socket, 'chat.html'),
      gen_tcp:close(Socket);
    _ ->
      send_file(Socket, File),
      gen_tcp:close(Socket)
  end.



send_file(Socket, Path) ->
  {ok, DATA} = file:read_file(Path),
  io:format("~p~n", [DATA]),
  ok = gen_tcp:send(Socket, DATA).

first([El | T]) ->
  El;

first([]) ->
  "".


