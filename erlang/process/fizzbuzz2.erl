-module(fizzbuzz2).
-export([start/1]).

%% fizzbuzz : Receiver (Pid -> Int ->
fizzbuzz() ->
    receive
        {Return, 1} ->
            Return ! conv(1); %% (!) : Process (Receiver a) -> a -> ()
        {Return, N} ->
            Cont = spawn(fun() -> fizzbuzz_cont(Return, N) end),
            self() ! {Cont, N - 1},
            fizzbuzz()
    end.

%% fizzbuzz_cont : Pid -> Int -> Receiver String
fizzbuzz_cont(Return, N) ->
    receive
        Acc ->
            Return ! (Acc ++ " " ++ conv(N))
    end.

%% conv : Int -> String
conv(N) when N rem 3 =:= 0, N rem 5 =:= 0 -> "FizzBuzz";
conv(N) when N rem 3 =:= 0 -> "Fizz";
conv(N) when N rem 5 =:= 0 -> "Buzz";
conv(N) -> integer_to_list(N).

start(End) ->
    Self = self(),
    FizzBuzz = spawn(fun() -> fizzbuzz() end),
    FizzBuzz ! {Self, End},
    receive
        Seq -> io:format("~s~n", [Seq])
    after 1000 -> timeout
    end.

%% spawn/1 : (() -> Receiver)
