-module(prj5_sol).
-include_lib("eunit/include/eunit.hrl").
-compile([nowarn_export_all, export_all]).

%---------------------------- Test Control ------------------------------
%% Enabled Tests
%%   comment out -define to deactivate test.
%%   alternatively, enclose deactivated tests within
%%   -if(false). and -endif. lines
%% enable all tests before submission.
%% the skeleton file is distributed with all tests are deactivated



-define(test_category_items1, enabled).
-define(test_category_items2, enabled).
-define(test_category_items3, enabled).
-define(test_delete_item, enabled).
-define(test_upsert_item, enabled).
-define(test_find_items, enabled).
-define(test_items_req, enabled).
-define(test_items_req_with_sort, enabled).
-define(test_items_client_no_sort, enabled).
-define(test_items_client_with_sort_dosort, enabled).
-define(test_items_client_with_sort, enabled).
-define(test_items_client_no_sort_mutate, enabled).
-define(test_items_client_with_sort_mutate, enabled).
-define(test_items_client_hot_reload, enabled).



%% Tracing Tests: set trace_level as desired.
% trace_level == 0:  no tracing
% trace_level == 1:  function + test-name 
% trace_level == 2:  function + test-name + args + result
-define(trace_level, 0).
-if(?trace_level == 2).
  -define(test_trace(Test, F, Args, Result),
	  io:format(standard_error, "~p:~p: ~p =~n~p~n",
		    [ element(2, erlang:fun_info(F, name)), Test,
		      Args, Result])).
-elif(?trace_level == 1).
  -define(test_trace(Test, F, _Args, _Result),
	  io:format(standard_error, "~p:~p~n",
		    [ element(2, erlang:fun_info(F, name)), Test])).
-else.
  -define(test_trace(_Test, _F, _Args, _Result), true).
-endif.

%% A TestSpec is either a triple of the form { Test, Args, Result }
%% where Test is an atom describing the test, Args gives the list of
%% arguments to the function under test and Result is the expected
%% result, or a quadruple of the form { Test, Args, Result, Fn },
%% where Fn is applied to the actual Result before being compared with
%% the expected result Result.

make_tests(F, TestSpecs) ->   
    MapFn = fun (Spec) ->
		    case Spec of
			{ _Test, Args, Result } ->
			   fun () ->  
				   FResult = apply(F, Args),
				   ?test_trace(_Test, F, Args, FResult),
				   ?assertEqual(Result, FResult) 
			   end;
			{ _Test, Args, Result, Fn } ->
			    fun () ->  
				    FResult = apply(F, Args),
				    ?test_trace(_Test, F, Args, FResult),
				    ?assertEqual(Result, Fn(FResult)) 
			    end;
			_ -> 
			    Msg = io_lib:format("unknown spec ~p", [Spec]),
			    error(lists:flatten(Msg))
		    end				
	    end,
    lists:map(MapFn, TestSpecs).


%---------------------- Order-Item Type and Data ------------------------

% we use sku as a primary key for an order-item.
% code can assume that any collection of order-items will have most one
% having a specific sku.
-record(order_item, {sku, category, nUnits, price}).

% given a variable Item which is an order_ite,, use Item#order_item.sku to
% access the order-item sku field.

% item predicates
item_has_sku(Sku) -> fun (E) -> E#order_item.sku == Sku end.
item_has_category(Category) -> fun (E) -> E#order_item.category == Category end.
item_has_nunits(NUnits) -> fun (E) -> E#order_item.nUnits == NUnits end. 
item_has_price(Price) -> fun (E) -> E#order_item.price == Price end.
     
% test data

-define(CW123, #order_item{sku=cw123, category=cookware, nUnits=3,
                           price=12.50}).
-define(CW126, #order_item{sku=cw126, category=cookware, nUnits=2, 
                           price=11.50}).
-define(AP723, #order_item{sku=ap723, category=apparel, nUnits=2, price=10.50}).
-define(CW127, #order_item{sku=cw127, category=cookware, nUnits=1, price=9.99}).
-define(AP273, #order_item{sku=ap273, category=apparel, nUnits=3, price=21.50}).
-define(FD825, #order_item{sku=fd825, category=food, nUnits=2, price=2.48}).
-define(AP932, #order_item{sku=ap932, category=apparel, nUnits=2, price=12.50}).
-define(FD285, #order_item{sku=fd285, category=food, nUnits=2, price=2.48}).

% data used for upserts
-define(CW123_1, 
        #order_item{sku=cw123, category=cookware, nUnits=3, price=22.50}).
-define(FD285_1, #order_item{sku=fd285, category=food, nUnits=3, price=1.48}).
-define(AP923_1, #order_item{sku=ap923, category=apparel, nUnits=2, price=0.99}).

-define(Items, 
        [ ?CW123, ?CW126, ?AP723, ?CW127, ?AP273, ?FD825, ?AP932, ?FD285 ]).
-define(SortedItems, 
       [  ?AP273,  ?AP723,  ?AP932, ?CW123, ?CW126, ?CW127, ?FD285, ?FD825 ]).

items() -> ?Items.
upsert_items() -> [ ?CW123_1, ?FD285_1, ?AP923_1 ].
    


%-------------------------- category_items1/2 ---------------------------

% #1: "10-points"
% category_items1(Category, Items): return sub-list of Items
% having category = Category.
% Restriction: must be implemented using recursion without using any library 
% functions.
category_items1(_Category, []) -> [];
category_items1(Category, [Item | Rest]) ->
    if Item#order_item.category == Category ->
        [Item | category_items1(Category, Rest)];
    true ->
        category_items1(Category, Rest)
    end.

category_items_test_specs() -> 
    Items = ?Items,
    [ { cookware_empty, [cookware, []], [] },
      { cookware_items, [cookware, Items], [ ?CW123, ?CW126, ?CW127 ] },
      { apparel_items, [apparel, Items], [ ?AP723,  ?AP273,  ?AP932 ] },
      { food_items, [food, Items], [  ?FD825, ?FD285 ] },
      { tool_items, [tool, Items], [] }				
    ].


category_items1_test_() ->
    make_tests(fun category_items1/2, category_items_test_specs()).
 %test_category_items1    


%-------------------------- category_items2/2 ---------------------------

% #2: "5-points"
% category_items2(Category, Items): return sub-list of Items
% having category = Category.
% Restriction: must be implemented using a single call to lists:filter().
category_items2(Category, Items) ->
    [Item || Item <- Items, Item#order_item.category == Category].


category_items2_test_() ->
    make_tests(fun category_items2/2, category_items_test_specs()).
 %test_category_items2

%-------------------------- category_items3/2 ---------------------------

% #3: "5-points"
% category_items3(Category, Items): return sub-list of Items
% having category = Category.
% Restriction: must be implemented using a list comprehension.
category_items3(Category, Items) ->
    [Item || Item <- Items, Item#order_item.category == Category].


category_items3_test_() ->
    make_tests(fun category_items3/2, category_items_test_specs()).
 %test_category_items3

%------------------------- delete_item/2 ----------------------------

% #4: "10-points"
% Given a list Items of items, return sublist of Items
% with item with sku=Sku removed.  It is ok if Sku does not exist.
% Hint: use a list comprehension 
delete_item(_Sku, []) -> [];
delete_item(Sku, [Item | Rest]) when Item#order_item.sku == Sku -> Rest;
delete_item(Sku, [Item | Rest]) -> [Item | delete_item(Sku, Rest)].


%% returns list of pairs: { Args, Result }, where Args is list of
%% arguments to function and Result should be the value returned
%% by the function.
delete_item_test_specs() -> 
    Items = ?Items,
    [
     { delete_last, 
       [ fd285, Items ], 
       [ ?CW123, ?CW126, ?AP723, ?CW127, ?AP273, ?FD825, ?AP932 ]
     },
     { delete_intermediate,
       [ ap723, Items ], 
       [ ?CW123, ?CW126, ?CW127, ?AP273, ?FD825, ?AP932, ?FD285 ]
     },
     { delete_nonexisting, [ ap111, Items ], Items }
    ].


delete_item_test_() ->
    make_tests(fun delete_item/2, delete_item_test_specs()).
 %test_delete_item

%--------------------------- upsert_item/2 --------------------------

% #5: "10-points"
% Given a list Items of items, if Items contains 
% an item E1 with E1.sku == E.sku, then return Items
% with E1 replaced by E, otherwise return Items with
% [E] appended.
upsert_item(Item, Items) ->
    case lists:keyfind(Item#order_item.sku, #order_item.sku, Items) of
        false -> Items ++ [Item];
        ExistingItem -> lists:keyreplace(Item#order_item.sku, #order_item.sku, Items, Item)
    end.


%% returns list of pairs: { Args, Result }, where Args is list of
%% arguments to function and Result should be the value returned
%% by the function.
upsert_item_test_specs() -> 
    Items = ?Items,
    [ { upsert_existing_first, [?CW123_1, Items], 
	[ ?CW123_1, ?CW126, ?AP723, ?CW127, ?AP273, ?FD825, ?AP932, ?FD285 ]
      },
      { upsert_existing_last, [?FD285_1, Items], 
	[ ?CW123, ?CW126, ?AP723, ?CW127, ?AP273, ?FD825, ?AP932, ?FD285_1 ]
      },
      { upsert_new, [?AP923_1, Items], 
        [ ?CW123, ?CW126, ?AP723, ?CW127, ?AP273, ?FD825, ?AP932, ?FD285, 
          ?AP923_1 ]
      }
    ].


upsert_item_test_() ->
    make_tests(fun upsert_item/2, upsert_item_test_specs()).
 %test_upsert_item

%--------------------------- find_items/2 ---------------------------

% #6: "15-points"
% find_items(Preds, Items):
% Given a list Items of items and a list of predicates Preds
% where each predicate P in Preds has type Item -> bool,
% return a sub-list of Items containing those Item in Items
% for which all P in Preds return true.
% Restriction: may not use recursion.
% Hint: consider using a list comprehension with lists:all/2.
find_items(Preds, Items) ->
    lists:filter(
        fun(Item) -> lists:all(fun(Pred) -> Pred(Item) end, Preds) end,
        Items
    ).
			   

find_items_test_specs() -> 
  Items = ?Items,
  [ { category_cookware, [ [item_has_category(cookware)], Items ], 
      category_items3(cookware, Items) 
    },
    { apparel_2, [ [item_has_category(apparel), item_has_nunits(2)], Items ],
      [ ?AP723, ?AP932 ]
    },
    { food_nunits_price, 
      [ [ item_has_category(food), 
	  item_has_nunits(2), 
	  item_has_price(2.48)
	], Items ],
      [ ?FD825, ?FD285 ]
    },
    { sku, [ [item_has_sku(cw126)], Items ], [ ?CW126 ] },
    { sku_nunits_none, 
      [ [item_has_category(cw126), item_has_nunits(3)], Items ], 
      [] 
    },
    { price, [ [item_has_price(2.48)], Items ], [?FD825, ?FD285] },
    { price_none, [ [item_has_price(2.50)], Items ], [] },
    { nunits, [ [item_has_nunits(2)], Items ], 
      [?CW126, ?AP723, ?FD825, ?AP932, ?FD285] 
    },
    { nunits_none, [ [item_has_nunits(5)], Items ], [] }
  ].

find_items_test_() ->
    make_tests(fun find_items/2, find_items_test_specs()).
 %test_find_items

%--------------------------- items_req/2 ----------------------------

% #7: "15-points"
% items_req(Req, Items):
% Return an ok-result of the form {ok, Result, ItemsZ} or 
% an error-result of the form {err, ErrString, Items}.
% Specifically, when Req matches:
%   { delete, Sku }:      ok-result with Result = void and ItemsZ =
%                         delete_item(Item, Items).
%   { dump }:             ok-result with Result = Items and 
%                         ItemsZ = Items.
%   { find, Preds }:      ok-result with Result = 
%                         find_items(Preds, Items)
%                         and ItemsZ = Items.
%   { read, Sku }:        If Preds = [item_has_sku(Sku)] and
%                         [Result] = find_items(Preds, Items), return
%                         an ok-result with ItemsZ = Items; otherwise
%                         return an error-result with a suitable ErrString.
%   { upsert, Item }:     ok-result with Result = void and 
%			  ItemsZ = upsert_item(Item, Items).
%   _:                    return an error-result with a suitable ErrString.
% Hint: use io_lib:format(Format, Args) to build suitable error strings,
% for example: lists:flatten(io_lib:format("bad Req ~p", [Req]))
items_req({delete, Sku}, Items) ->
    {ok, void, delete_item(Sku, Items)};
items_req({dump}, Items) ->
    {ok, Items, Items};
items_req({find, Preds}, Items) ->
    Result = find_items(Preds, Items),
    {ok, Result, Items};
items_req({read, Sku}, Items) ->
    case find_items([item_has_sku(Sku)], Items) of
        [Result] -> {ok, Result, Items};
        _ -> {err, lists:flatten(io_lib:format("read failed for Sku: ~p", [Sku])), Items}
    end;
items_req({upsert, Item}, Items) ->
    ItemsZ = upsert_item(Item, Items),
    {ok, void, ItemsZ};
items_req(_, Items) ->
    {err, "invalid request", Items}.

%% map upsert_item_test_specs into args-result pairs suitable
%% for items_req({upsert, _}, ...).
items_req_upsert_test_specs() ->
  [ { Test, [ {upsert, Item}, Items ], { ok, void, Result } } ||
    { Test, [Item, Items], Result } <- upsert_item_test_specs() ].


%% map delete_item_test_specs into args-result pairs suitable
%% for items_req({delete, _}, ...).
items_req_delete_test_specs() ->
  [ { Test, [ {delete, Name}, Items ], { ok, void, Result } } ||
    { Test, [Name, Items], Result } <- delete_item_test_specs() ].

%% map find_items_test_specs into args-result pairs suitable
%% for items_req({find, _}, ...).
items_req_find_test_specs() ->
  [ { Test, [ {find, Preds}, Items ], { ok, Result, Items } } ||
    { Test, [Preds, Items], Result } <- find_items_test_specs() ].

ignore_err_message(Result) ->
    case Result of
      { Status, _Msg } -> { Status };
      { Status, _Msg, Rest } -> { Status, Rest }
    end.

items_req_test_specs() ->
    % since these specs are used also by server, keep mutable tests last
    Items = ?Items,
    [ { read_intermediate, [{ read, ap723 }, Items ], { ok, ?AP723, Items } },
      { read_last, [ { read, fd285 }, Items ], { ok, ?FD285, Items } },
      { dump, [ {dump}, Items ], { ok, Items, Items } },
      { read_nonexisting, [ { read, fd999 }, Items ], {err, Items}, 
	fun ignore_err_message/1 },
      { bad_req, [ { read1, cw123 }, Items ], {err, Items}, 
        fun ignore_err_message/1 
      }
    ] ++
    items_req_find_test_specs() ++
    items_req_upsert_test_specs() ++
    items_req_delete_test_specs().

items_req_test_() ->
    make_tests(fun items_req/2, items_req_test_specs()).
 %test_items_req

%---------------------- items_req_with_sort/2 -----------------------

% #8: "10-points"
% items_req_with_sort(Req, Items):
% Exactly like items_req/2 except that it handles an additional Req:
% { sort } which should return { ok, void, SortedItems }
% where SortedItems is Items sorted in ascending order by sku.
% Hint: use lists:sort/2 to sort, delegate all non-sort Fns to items_req/2.
items_req_with_sort({sort}, Items) ->
    SortedItems =
        case {sort} of
            {sort} ->
                lists:sort(fun(A, B) ->
                    A#order_item.sku < B#order_item.sku
                end, Items);
            _ ->
                Items
        end,
    {ok, void, SortedItems};
items_req_with_sort(Req, Items) ->
    items_req(Req, Items).


items_req_with_sort_test_specs() ->
    [ { sort, [{sort}, ?Items], { ok, void, ?SortedItems } } ] ++
    items_req_test_specs().

% the additional specs here are not suitable for use by the server
items_req_with_sort_extra_test_specs() ->
    [ { sort_single, [{sort}, [?CW123]], { ok, void, [?CW123]} },
      { sort_empty, [{sort}, [] ], { ok, void, [] } }
    ] ++ items_req_with_sort_test_specs().
    
-ifdef(test_items_req_with_sort).
items_req_with_sort_test_() ->
    Fn = fun items_req_with_sort/2,
    make_tests(Fn, items_req_with_sort_extra_test_specs()).
-endif. %test_items_req_with_sort

%-------------------- Hot Reload Server and Client ----------------------

% #9: "20-points"

% start_items_server(Items, Fn):
% start a server process with items list Items and processing
% function Fn (usually either items_req/2 or
% items_req_with_sort/2).  Register server process under ID items
% and return PID of started process.
% 
% The server should accept messages of the form { Pid, Req } where Pid
% is the client's PID.  The action taken by the server depends on Req:
% { stop }:            Terminate the server after sending a { ok, stopped}
%		       response to the client.   
% { new_fn, Fn1 }:     Continue server with processing function
%                      Fn replaced by Fn1 after sending a {ok, void} 
%                      response to the client. 
%  All other requests: Req should be forwarded to Fn as Fn(Req, Items),
%                      where Fn is the current processing function 
%                      and Items are the current items in the 
%                      server state.  Assuming the result of the forwarded
%                      call is { Status, Result, Items1 }, then the server
%                      should continue with (possibly) new Items1 and
%                      current processing function Fn after sending a
%                      { Status, Result } response to the client.
% The actual messages returned to the client should always include the
% server's PID, so they look like { self(), Response } where Response is
% the response described above.

start_items_server(Items, Fn) ->
  Param =[Items, Fn],
  ServerID = spawn(prj5_sol, items_server, Param),
  register(items, ServerID).
    

% stop previously started server with registered ID items.
% should return {ok, stopped}.

stop_items_server() ->
  items ! {self(),{stop}},
  receive
    {
      _Status, _Result} ->
        {ok, stopped}
    end.

items_server(Items, Fn) ->
  receive
    {
      ClientPid, Req} ->
        case Req of 
          {stop} ->
            ClientPid ! {ok, stopped};
          {new_fn, Fn1} ->
            ClientPid ! {self(), {ok, void}},
            items_server(Items, Fn1);
          _ ->
              {Status, Result, Items1} = Fn(Req, Items),
              ClientPid ! {self(), {Status, Result}},
              items_server(Items1,Fn)
         end
      end.

% send request Req to server registered under ID items and return 
% Result from server.
items_client(Req) ->
  items ! {self(), Req},
  receive
    {_, {Status,Result}} ->
      {Status, Result}
  end.


%% map items_req test to a items_client test
make_items_client_test_specs(Specs) ->
    DropLast = fun (Tuple) -> 
		       if tuple_size(Tuple) =:= 2 ->
			  { element(1, Tuple) };
			  true -> { element(1, Tuple), element(2, Tuple) }
		       end
	       end,
    MapFn = fun (Spec) ->
		case Spec of
		    { Test, [Arg0|_], Result } -> 
			{ Test, [Arg0], DropLast(Result) };
		    { Test, [Arg0|_], Result, Fn } ->
			{ Test, [Arg0], DropLast(Result), Fn }
		end
	    end,
    [ MapFn(Spec) || Spec <- Specs ].

items_client_no_sort_test_specs() ->
    make_items_client_test_specs(items_req_test_specs()).
    
items_client_with_sort_test_specs() ->
    make_items_client_test_specs(items_req_with_sort_test_specs()).
    
-ifdef(test_items_client_no_sort).
items_client_no_sort_test_() ->
    Items = ?Items,
    { setup,
      fun () -> start_items_server(Items, fun items_req/2) end,
      fun (_) ->  stop_items_server() end,
      make_tests(fun items_client/1, items_client_no_sort_test_specs())
    }.
-endif.

-ifdef(test_items_client_with_sort).
% test non-sort functionality
items_client_with_sort_test_() ->
    Items = ?Items,
    { setup,
      fun () -> start_items_server(Items, fun items_req_with_sort/2) end,
      fun (_) ->  stop_items_server() end,
      make_tests(fun items_client/1, items_client_no_sort_test_specs())
    }.
-endif.

-ifdef(test_items_client_with_sort_dosort).
items_client_with_sort_dosort_test_() ->
    Items = ?Items,
    { setup,
      fun () -> start_items_server(Items, fun items_req_with_sort/2) end,
      fun (_) ->  stop_items_server() end,
      make_tests(fun items_client/1, 
	[
	 { sort, [{sort}], {ok, void} },
	 { sorted_dump, [{dump}], { ok, ?SortedItems } }
	])
    }.
-endif.

items_client_mutate_test_specs() ->
    Items = ?Items,
    [ { dump0, [{dump}], {ok, Items} },
      { delete_last, [{delete, fd285}], {ok, void } },
      { dump1, [{dump}],
        {ok, [ ?CW123, ?CW126, ?AP723, ?CW127, ?AP273, ?FD825, ?AP932 ] }
      },
      { delete_intermediate, [{delete, ap723}], { ok, void } },
      { dump2, [{dump}],
       {ok, [ ?CW123, ?CW126, ?CW127, ?AP273, ?FD825, ?AP932 ] }
      },
      { read_intermediate, [{read, cw127}], { ok, ?CW127 } },
      { read_first, [{read, cw123}], { ok, ?CW123 } },
      { upsert_first, [{upsert, ?CW123_1}], { ok, void } },
      { dump3, [{dump}],
       {ok, [ ?CW123_1, ?CW126, ?CW127, ?AP273, ?FD825, ?AP932 ] }
      },
      { upsert_end1, [{upsert, ?AP923_1}], { ok, void } },
      { upsert_end2, [{upsert, ?FD285_1}], { ok, void } },
      { dump4, [{dump}],
       {ok, [ ?CW123_1, ?CW126, ?CW127, ?AP273, ?FD825, ?AP932, 
              ?AP923_1, ?FD285_1 ] 
       }
      },
      { find_price, [ {find, [item_has_price(11.5)]} ], { ok, [?CW126] } }
    ].
    
-ifdef(test_items_client_no_sort_mutate).
items_client_no_sort_mutate_test_() ->
    Items = ?Items,
    { setup,
      fun () -> start_items_server(Items, fun items_req/2) end,
      fun (_) ->  stop_items_server() end,
      make_tests(fun items_client/1, items_client_mutate_test_specs())
    }.
-endif.

-ifdef(test_items_client_with_sort_mutate).
items_client_with_sort_mutate_test_() ->
    Items = ?Items,
    { setup,
      fun () -> start_items_server(Items, fun items_req_with_sort/2) end,
      fun (_) ->  stop_items_server() end,
      make_tests(fun items_client/1, 
		 items_client_mutate_test_specs()
		 ++ [ { sort, [{sort}], {ok, void} },
		      { dump5, [{dump}], 
			{ok, [ ?AP273, ?AP923_1, ?AP932, 
			       ?CW123_1, ?CW126, ?CW127, ?FD285_1,  ?FD825]
			}
		      }
		    ])
    }.
-endif.

-ifdef(test_items_client_hot_reload).
items_client_hot_reload_test_() ->
    Items = ?Items,
    Ignore = fun ignore_err_message/1,
    { setup,
      fun () -> start_items_server(Items, fun items_req_with_sort/2) end,
      fun (_) ->  stop_items_server() end,
      make_tests(fun items_client/1, 
		 [ { first_sort, [{sort}], {ok, void} },
		   { dump1, [{dump}], {ok, ?SortedItems} },
		   { new_fn1, [{new_fn, fun items_req/2}], {ok, void} },
		   { sort_err, [{sort}], {err}, Ignore },
		   { dump2, [{dump}], {ok, ?SortedItems} },
		   { new_fn1, [{new_fn, fun items_req_with_sort/2}], 
		     {ok, void} 
		   }
		 ])
    }.
-endif.

