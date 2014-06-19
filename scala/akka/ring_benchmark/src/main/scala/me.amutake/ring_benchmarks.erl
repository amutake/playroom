-module(ring_benchmarks).
-export([start/2]).

start(N, T) ->
    Self = self(),
    RootId = spawn(fun() -> ring_root(Self, T) end),
    NodeIds = create_nodes(N - 1),
    lists:map(fun({Id1, Id2}) -> Id1 ! {next, Id2} end, lists:zip([RootId|NodeIds], lists:append(NodeIds, [RootId]))),
    RootId ! ok,
    receive
        ok -> io:write(ok)
    end.

create_nodes(0) -> [];
create_nodes(N) ->
    [spawn(fun() -> ring_node() end)|create_nodes(N - 1)].

ring_root(Master, Times) ->
    receive
        {next, Next} ->
            root_loop(Master, Next, Times)
    end.

root_loop(Master, _, 0) -> Master ! ok;
root_loop(Master, Next, Times) ->
    receive
        ok ->
            Next ! ok,
            root_loop(Master, Next, Times - 1)
    end.

ring_node() ->
    receive
        {next, Next} ->
            node_loop(Next)
    end.

node_loop(Next) ->
    receive
        ok ->
            Next ! ok,
            node_loop(Next)
    end.
