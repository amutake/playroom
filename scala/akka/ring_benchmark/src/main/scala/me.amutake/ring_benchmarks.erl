-module(ring_benchmarks).
-export([start/2]).

start(N, T) ->
    Self = self(),
    RootId = spawn(fun() -> ring_root(Self, T) end),
    NodeIds = replicate_process(N, fun ring_node/0),
    RootId ! lists:append(NodeIds, [RootId]),
    RootId ! ok,
    receive
        ok -> io:write(ok)
    end.

replicate_process(0, _) -> [];
replicate_process(N, Fun) ->
    [spawn(fun() -> Fun() end)|replicate_process(N - 1, Fun)].

ring_root(Mid, Times) ->
    receive
        [Pid|Pids] ->
            Pid ! Pids,
            receive
                [] -> root_loop(Mid, Pid, Times)
            end
    end.

root_loop(Mid, _, 0) -> Mid ! ok;
root_loop(Mid, Pid, Times) ->
    receive
        ok ->
            Pid ! ok,
            root_loop(Mid, Pid, Times - 1)
    end.

ring_node() ->
    receive
        [Pid|Pids] ->
            Pid ! Pids,
            node_loop(Pid)
    end.

node_loop(Pid) ->
    receive
        ok ->
            Pid ! ok,
            node_loop(Pid)
    end.
