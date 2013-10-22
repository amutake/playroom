-module(fizzbuzz).
-export([start/1]).

start(End) ->
    Pid = self(),
    FizzBuzz = spawn(fun() -> fizzbuzz(Pid, End) end),
    Fizz = spawn(fun() -> fizz(3) end),
    Buzz = spawn(fun() -> buzz(5) end),
    FizzBuzz ! {Fizz, Buzz},
    receive
        ok -> ok
    end.

fizzbuzz(Pid, End) ->
    receive
        {Fizz, Buzz, N, _Flag} when N >= End ->
            io:format("~n"),
            exit(Fizz, ok),
            exit(Buzz, ok),
            Pid ! ok;
        {Fizz, Buzz, N, ittenai} ->
            io:format("~p ", [N]),
            Fizz ! {self(), Buzz, N + 1, ittenai},
            fizzbuzz(Pid, End);
        {Fizz, Buzz, N, itta} ->
            io:fwrite(" "),
            Fizz ! {self(), Buzz, N + 1, ittenai},
            fizzbuzz(Pid, End);
        {Fizz, Buzz} ->
            Fizz ! {self(), Buzz, 1, ittenai},
            fizzbuzz(Pid, End)
    end.

fizz(Next) ->
    receive
        {FizzBuzz, Buzz, N, _Flag} when N =:= Next ->
            io:format("Fizz"),
            Buzz ! {FizzBuzz, self(), N, itta},
            fizz(Next + 3);
        {FizzBuzz, Buzz, N, Flag} ->
            Buzz ! {FizzBuzz, self(), N, Flag},
            fizz(Next)
    end.

buzz(Next) ->
    receive
        {FizzBuzz, Fizz, N, _Flag} when N =:= Next ->
            io:format("Buzz"),
            FizzBuzz ! {Fizz, self(), N, itta},
            buzz(Next + 5);
        {FizzBuzz, Fizz, N, Flag} ->
            FizzBuzz ! {Fizz, self(), N, Flag},
            buzz(Next)
    end.
