%% An Algebraic Theory of Actors and Its Application to a Simple Object-Based Language
%% G.Agha, P.Thati
%% Section 3.4 An Example
%% doi: 10.1007/978-3-540-39993-3_4
-module(fact).
-export([start/1]).

factorial() ->
    receive
        {0, Cust} -> Cust ! 1;
        {Val, Cust} ->
            Cont = spawn(fun() -> factorial_cont(Val, Cust) end),
            self() ! {Val - 1, Cont},
            factorial()
    end.

factorial_cont(Val, Cust) ->
    receive
        Arg -> Cust ! (Val * Arg)
    end.

start(N) ->
    X = spawn(fun() -> factorial() end),
    X ! {N, self()},
    receive
        Result -> io:format("~p~n", [Result])
    after 1000 -> timeout
    end.
