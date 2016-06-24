-module(ltest_tests).

-compile(export_all).

-include_lib("eunit/include/eunit.erl").

add_test() ->
    2 = ltest:add(1, 1),
    0 = ltest:add(1, -1),
    ?assert(true),
    ?assertEqual(3, ltest:add(1, 2)),
    ok.
