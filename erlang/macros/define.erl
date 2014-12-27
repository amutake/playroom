-module(define).
-export([hoge/1]).

-define(BEHV,
        receive
            {hoge, N} ->
                ?BEHV;
            _ ->
                ?BEHV
        end).

hoge(N) ->
    spawn(fun () ->
                  ?BEHV
                      end).
