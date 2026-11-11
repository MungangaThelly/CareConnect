-module(care_connect_store).
-behaviour(gen_server).

-export([start_link/0, add_checkin/2, list_checkins/1, complete_checkin/2,
         due_checkins/1, add_update/2, list_updates/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-define(TAB, care_connect_data).

start_link() -> gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).
add_checkin(Household, Checkin) -> gen_server:call(?MODULE, {add_checkin, Household, Checkin}).
list_checkins(Household) -> gen_server:call(?MODULE, {list_checkins, Household}).
complete_checkin(Household, Id) -> gen_server:call(?MODULE, {complete_checkin, Household, Id}).
due_checkins(Now) -> gen_server:call(?MODULE, {due_checkins, Now}).
add_update(Household, Update) -> gen_server:call(?MODULE, {add_update, Household, Update}).
list_updates(Household) -> gen_server:call(?MODULE, {list_updates, Household}).

init([]) -> ets:new(?TAB, [named_table, set, protected]), {ok, #{}}.
handle_call({add_checkin, Household, Checkin}, _From, State) ->
    ets:insert(?TAB, {{checkin, Household, maps:get(id, Checkin)}, Checkin}), {reply, {ok, Checkin}, State};
handle_call({list_checkins, Household}, _From, State) ->
    Items = [V || {{checkin, H, _}, V} <- ets:tab2list(?TAB), H =:= Household],
    {reply, {ok, Items}, State};
handle_call({complete_checkin, Household, Id}, _From, State) ->
    Key = {checkin, Household, Id},
    Reply = case ets:lookup(?TAB, Key) of
        [{Key, Item}] -> Updated = Item#{status => completed, completed_at => erlang:system_time(second)},
                         ets:insert(?TAB, {Key, Updated}), {ok, Updated};
        [] -> {error, not_found}
    end,
    {reply, Reply, State};
handle_call({due_checkins, Now}, _From, State) ->
    Due = [I || {{checkin, _, _}, I} <- ets:tab2list(?TAB), maps:get(status, I) =:= pending,
        maps:get(due_at, I) + maps:get(grace_seconds, I) =< Now],
    {reply, {ok, Due}, State};
handle_call({add_update, Household, Update}, _From, State) ->
    ets:insert(?TAB, {{update, Household, maps:get(id, Update)}, Update}), {reply, {ok, Update}, State};
handle_call({list_updates, Household}, _From, State) ->
    Items = [V || {{update, H, _}, V} <- ets:tab2list(?TAB), H =:= Household],
    {reply, {ok, Items}, State};
handle_call(_Request, _From, State) -> {reply, {error, bad_request}, State}.
handle_cast(_Request, State) -> {noreply, State}.
handle_info(_Info, State) -> {noreply, State}.
terminate(_Reason, _State) -> ok.
code_change(_OldVersion, State, _Extra) -> {ok, State}.
