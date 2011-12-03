%% -*- mode: erlang -*-
%% -*- erlang-indent-level: 4;indent-tabs-mode: nil -*-
%% ex: ts=4 sw=4 et
%% Copyright 2011 Benjamin Nortier
%%
%%   Licensed under the Apache License, Version 2.0 (the "License");
%%   you may not use this file except in compliance with the License.
%%   You may obtain a copy of the License at
%%
%%       http://www.apache.org/licenses/LICENSE-2.0
%%
%%   Unless required by applicable law or agreed to in writing, software
%%   distributed under the License is distributed on an "AS IS" BASIS,
%%   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%%   See the License for the specific language governing permissions and
%%   limitations under the License.

-module(node_geom_post_resource).
-author('Benjamin Nortier <bjnortier@gmail.com>').
-export([
         init/1, 
         allowed_methods/2,
         content_types_accepted/2,
         accept_content/2,
	 post_is_create/2,
	 allow_missing_post/2,
	 create_path/2,
	 resource_exists/2,
         malformed_request/2
        ]).


-include_lib("webmachine/include/webmachine.hrl").

-record(context, {adapter}).

init([{adapter_mod, Adapter}]) -> {ok, #context{adapter = Adapter}}.

allowed_methods(ReqData, Context) -> 
    {['POST'], ReqData, Context}.

resource_exists(ReqData, Context) ->
    {false, ReqData, Context}.

content_types_accepted(ReqData, Context) ->
    {[{"application/json", accept_content}], ReqData, Context}.

post_is_create(ReqData, Context) ->
    {true, ReqData, Context}. 

allow_missing_post(ReqData, Context) ->
    {true, ReqData, Context}.

create_path(ReqData, Context) ->
    {"not used", ReqData, Context}. 

accept_content(ReqData, Context) ->
    {true, wrq:set_resp_header("Content-type", "application/json", ReqData), Context}.

malformed_request(ReqData, Context) ->
    Body = wrq:req_body(ReqData),
    try 
	RequestJSON = jiffy:decode(Body),
	User = wrq:path_info(user, ReqData),
	Design = wrq:path_info(design, ReqData),
	Adapter = Context#context.adapter,
	case Adapter:create(User, Design, RequestJSON) of
	    {ok, ResponseJSON} ->
		{false, wrq:set_resp_body(ResponseJSON, ReqData), Context};
	    {error, ResponseJSON} ->
		{true, wrq:set_resp_body(ResponseJSON, ReqData), Context};
	    {error, Code, ResponseJSON} ->
		{{halt, Code}, wrq:set_resp_body(ResponseJSON, ReqData), Context}
	end

    catch
	_:_ ->
            lager:warning("invalid JSON: ~p", [Body]),
	    {true, wrq:set_resp_body(<<"\"invalid JSON\"">>, ReqData), Context}
    end.





