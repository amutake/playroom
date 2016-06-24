-module(eunit_test_worker).

-compile(export_all).

-behaviour(gen_server).

-spec start_link() -> {ok, pid()} | {error, term()}.
start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
    {ok, #{}}.

handle_cast(Request, State) ->
    ok = eunit_test_server:cast(Request),
    {noreply, State}.

handle_call(_Request, _From, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% ============================

do_cast(Request) ->
    ok = gen_server:cast(?MODULE, Request),
    ok.
