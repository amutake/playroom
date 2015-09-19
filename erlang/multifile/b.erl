-module(b).
-export([main/0]).

main() ->
    io:format("~w~n", [a:add(1,2)]).
