-module(eunit_test_tests).

-include_lib("eunit/include/eunit.hrl").

hoge_test_() ->
    [{"hoge",
      fun() ->
              ok = meck:new(eunit_test_server, [no_link, passthrough]),
              ok = meck:new(eunit_test_worker, [no_link, passthrough]),
              {ok, _ServerPid} = eunit_test_server:start_link(),
              {ok, _WorkerPid} = eunit_test_worker:start_link(),

              eunit_test_worker:do_cast(hoge),
              ?assertEqual(ok, meck:wait(eunit_test_server, handle_cast, 2, 3000)),
              ?debugVal(meck:history(eunit_test_server)),
              ?debugVal(meck:history(eunit_test_worker)),

              _ = meck:unload(),
              ok
      end}].
