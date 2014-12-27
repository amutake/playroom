-module(mutual).
-export([odd/1, even/1, odd_fact/1]).

'odd'(0) -> false;
'odd'(N) -> even(N - 1).

even(0) -> true;
even(N) -> odd(N - 1).

odd_fact(M) ->
    %% self recursion
    %% Fact = fun(N) -> case N of
    %%     0 -> 1;
    %%     _ -> N * Fact(N)
    %%     end
    %% end,
    FactFix = fun(F, N) -> case N of
        0 -> 1;
        _ -> N * F(N - 1)
        end
    end,
    %% mutual recursion
    OddFix = fun(F, N) -> case N of
        0 -> false;
        _ -> F(N - 1)
      end
    end,
    EvenFix = fun(F, N) -> case N of
        0 -> true;
        _ -> F(N - 1)
      end
    end,
    Fact = fun(N) -> FactFix(FactFix, N) end,
    Odd = fun(N) -> OddFix(EvenFix, N) end,
    %% Even = fun(N) -> EvenFix(OddFix, N) end,
    Odd(Fact(M)).
