-module(care_connect_sup).
-behaviour(supervisor).

-export([start_link/0, init/1]).

start_link() -> supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    Dispatch = cowboy_router:compile([{'_', [
        {"/health", care_connect_http, #{}},
        {"/api/households/:household/checkins", care_connect_http, #{}},
        {"/api/households/:household/checkins/:id/complete", care_connect_http, #{}},
        {"/api/households/:household/updates", care_connect_http, #{}}
    ]}]),
    Port = application:get_env(care_connect, port, 8080),
    {ok, _} = cowboy:start_clear(care_connect_listener, [{port, Port}],
                                 #{env => #{dispatch => Dispatch}}),
    Children = [
        #{id => care_connect_store, start => {care_connect_store, start_link, []},
          restart => permanent, shutdown => 5000, type => worker, modules => [care_connect_store]},
        #{id => care_connect_checkins, start => {care_connect_checkins, start_link, []},
          restart => permanent, shutdown => 5000, type => worker, modules => [care_connect_checkins]}
    ],
    {ok, {{one_for_one, 5, 10}, Children}}.
