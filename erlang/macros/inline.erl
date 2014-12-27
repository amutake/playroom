-module(inline).
-export([hoge/1]).

-compile({inline, [behv/0]}).

behv() ->
    receive
        {hoge, N} ->
            behv();
        _ ->
            behv()
    end.

hoge(N) ->
    spawn(fun () -> behv() end).
