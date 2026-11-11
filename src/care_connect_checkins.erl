-module(care_connect_checkins).
-behaviour(gen_server).

-export([start_link/0, create/4, complete/2]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

start_link() -> gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).
create(Household, Person, DueAt, Grace) ->
    gen_server:call(?MODULE, {create, Household, Person, DueAt, Grace}).
complete(Household, Id) ->
    gen_server:call(?MODULE, {complete, Household, Id}).

init([]) -> erlang:send_after(15000, self(), scan_due), {ok, #{}}.
handle_call({create, Household, Person, DueAt, Grace}, _From, State) ->
    Id = integer_to_binary(erlang:unique_integer([positive, monotonic])),
    Item = #{id => Id, person => Person, due_at => DueAt, grace_seconds => Grace,
             status => pending, created_at => erlang:system_time(second)},
    {ok, Saved} = care_connect_store:add_checkin(Household, Item),
    {reply, {ok, Saved}, State};
handle_call({complete, Household, Id}, _From, State) ->
    {reply, care_connect_store:complete_checkin(Household, Id), State};
handle_call(_Request, _From, State) -> {reply, {error, bad_request}, State}.
handle_cast(_Request, State) -> {noreply, State}.
handle_info(scan_due, State) ->
    Now = erlang:system_time(second),
    {ok, Due} = care_connect_store:due_checkins(Now),
    [logger:notice("Check-in missed; human follow-up may be needed: ~p", [maps:get(id, I)]) || I <- Due],
    erlang:send_after(15000, self(), scan_due),
    {noreply, State};
handle_info(_Info, State) -> {noreply, State}.
terminate(_Reason, _State) -> ok.
code_change(_OldVersion, State, _Extra) -> {ok, State}.
