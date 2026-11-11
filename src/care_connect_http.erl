-module(care_connect_http).
-behaviour(cowboy_handler).

-export([init/2]).

init(Req0, State) ->
    Method = cowboy_req:method(Req0),
    Path = cowboy_req:path(Req0),
    {Status, Body} = route(Method, Path, Req0),
    Req = cowboy_req:reply(Status, #{<<"content-type">> => <<"application/json">>},
                           jsx:encode(Body), Req0),
    {ok, Req, State}.

route(<<"GET">>, <<"/health">>, _Req) -> {200, #{status => ok}};
route(<<"GET">>, Path, _Req) ->
    case path_parts(Path) of
        [<<"api">>, <<"households">>, H, <<"checkins">>] -> result(care_connect_store:list_checkins(H));
        [<<"api">>, <<"households">>, H, <<"updates">>] -> result(care_connect_store:list_updates(H));
        _ -> {404, #{error => not_found}}
    end;
route(<<"POST">>, Path, Req0) ->
    {ok, Data, Req} = cowboy_req:read_body(Req0),
    case {path_parts(Path), jsx:decode(Data, [return_maps])} of
        {[<<"api">>, <<"households">>, H, <<"checkins">>], M} ->
            case {maps:find(<<"person">>, M), maps:find(<<"due_at">>, M), maps:find(<<"grace_seconds">>, M)} of
                {{ok, Person}, {ok, Due}, {ok, Grace}} when is_binary(Person), is_integer(Due), is_integer(Grace), Grace >= 0 ->
                    {201, value(care_connect_checkins:create(H, Person, Due, Grace))};
                _ -> {400, #{error => invalid_checkin}}
            end;
        {[<<"api">>, <<"households">>, H, <<"checkins">>, Id, <<"complete">>], _} ->
            result(care_connect_checkins:complete(H, Id));
        {[<<"api">>, <<"households">>, H, <<"updates">>], M} ->
            case {maps:find(<<"author">>, M), maps:find(<<"message">>, M)} of
                {{ok, Author}, {ok, Message}} when is_binary(Author), is_binary(Message), byte_size(Message) =< 2000 ->
                    Id = integer_to_binary(erlang:unique_integer([positive, monotonic])),
                    Item = #{id => Id, author => Author, message => Message,
                             created_at => erlang:system_time(second)},
                    {201, value(care_connect_store:add_update(H, Item))};
                _ -> {400, #{error => invalid_update}}
            end;
        _ -> {404, #{error => not_found}}
    end;
route(_, _, _Req) -> {405, #{error => method_not_allowed}}.

path_parts(Path) -> [P || P <- binary:split(Path, <<"/">>, [global]), P =/= <<>>].
result({ok, Items}) -> {200, #{items => Items}};
result({error, not_found}) -> {404, #{error => not_found}};
result({error, _}) -> {400, #{error => invalid_request}}.
value({ok, Item}) -> Item;
value({error, _}) -> #{error => invalid_request}.
