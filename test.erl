-module(test).

-compile(export_all).


start() ->
  case "" of
    "" ->
      io:format("OK empty~n");
    "aa" ->
      io:format("NOT OK~n");
    _ ->
      io:format("Nothing match~n")
  end.
