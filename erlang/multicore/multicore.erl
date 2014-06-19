-module(multicore).
-export([start/0]).

start() ->
    A = spawn(fun() -> loop() end),
    B = spawn(fun() -> loop() end),
    C = spawn(fun() -> loop() end),
    % D = spawn(fun() -> loop() end),
    A ! go,
    B ! go,
    C ! go,
    % D ! go,
    receive
        ok -> ok
    end.

loop() ->
    receive
        go -> inf_loop(0, up)
    end.

inf_loop(0, down) -> inf_loop(0, up);
inf_loop(100000000000000, up) -> inf_loop(100000000000000, down);
inf_loop(N, down) -> inf_loop(N - 1, down);
inf_loop(N, up) -> inf_loop(N + 1, up).
