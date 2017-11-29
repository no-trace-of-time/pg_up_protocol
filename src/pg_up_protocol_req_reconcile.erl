%%%-------------------------------------------------------------------
%%% @author jiarj
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 29. 十一月 2017 10:03
%%%-------------------------------------------------------------------
-module(pg_up_protocol_req_reconcile).
-author("jiarj").
-include_lib("eunit/include/eunit.hrl").
-include_lib("mixer/include/mixer.hrl").
-compile({parse_trans, exprecs}).
-behaviour(pg_model).
-behavior(pg_protocol).
-behaviour(pg_up_protocol).

%% callbacks of up protocol
-mixin([{pg_up_protocol, [
  pr_formatter/1
  , in_2_out_map/0
]}]).
%% API
-export([sign_fields/0, options/0, convert_config/0]).
-define(TXN, ?MODULE).


-record(?TXN, {
  version = <<"5.0.0">>
  , encoding = <<"UTF-8">>
%%		, certId => unionpay_config:certId(unionpay_config:short_mer_id(MerId))
  , certId = <<"9">>
  , signature = <<"9">>
  , signMethod = <<"01">>
  , txnType = <<"76">>
  , txnSubType = <<"01">>
  , bizType = <<"000000">>
  , accessType = <<"0">>
  , merId = <<"012345678901234">>
  , settleDate = <<"1212">>
%%, txnTime = list_to_binary(xfutils:now(txn))
  , txnTime = <<"19991212121212">>
  , fileType = <<"00">>
}).
-type ?TXN() :: #?TXN{}.
%%-opaque ?TXN() :: #?TXN{}.
-export_type([?TXN/0]).
-export_records([?TXN]).


sign_fields() ->
  [
    accessType
    , bizType
    , certId
    , encoding
    , fileType
    , merId
    , settleDate
    , signMethod
    , txnSubType
    , txnTime
    , txnType
    , version
  ].

options() ->
  #{
    channel_type => up,
    txn_type=>query,
    direction => req
  }.

convert_config() ->
  [].
%%=============test=================
sign_test() ->
  Qs = [
    {<<"version">>, <<"5.0.0">>}
    , {<<"encoding">>, <<"UTF-8">>}
    , {<<"certId">>, <<"70481187397">>}
    , {<<"signature">>, <<"iBMIAF36Y42ldw+YVPFsg2T23jnrMyvG0Jkdc88d+3KjIs6EumKpQ7tCk4EG+0yfCJ+fptQgBf6xFZw2W4/veboijgIr9t0lFROBm85tr7OwxH7JohBczilE9cNl2B+J7AxE+7jI/LOYL0hsVHextM+IrRpJNirp5fMbiCU6MJ9bJ887vHBbcA/lRh9wdnbLjhPMt+vyjLqrWXxHH/E2+Jat9rkb46A8yU7UmcCk3UY4B6rbbokU7WrcHObw/xs/WDrPHju2z898JHXExlGjmphGbg4zbaVUPZ4O27RMpg6rwmsG1f0h5DrdQOEfsQsoSqm0QG73yJupeLrrp0v0bg==">>}
    , {<<"signMethod">>, <<"01">>}
    , {<<"txnType">>, <<"76">>}
    , {<<"txnSubType">>, <<"01">>}
    , {<<"bizType">>, <<"000000">>}
    , {<<"accessType">>, <<"0">>}
    , {<<"merId">>, <<"898319849000018">>}
    , {<<"settleDate">>, <<"1127">>}
    , {<<"txnTime">>, <<"20171128165458">>}
    , {<<"fileType">>, <<"00">>}
  ],
  P = pg_protocol:out_2_in(?MODULE, Qs),
  Sign_string = pg_up_protocol:sign_string(?MODULE, P),
  Sign_string = <<"accessType=0&bizType=000000&certId=70481187397&encoding=UTF-8&fileType=00&merId=898319849000018&settleDate=1127&signMethod=01&txnSubType=01&txnTime=20171128165458&txnType=76&version=5.0.0">>,
%%  pg_model:get(?MODULE, P, signature) =:=
    pg_up_protocol:sign(?MODULE, P),
  Params = {pg_up_protocol_req_reconcile,<<"5.0.0">>,<<"UTF-8">>,<<"9">>,<<"XSbkIzEF7Ti8h/oLJIPG4z3Ff4b4VLWzoBSSG1F9NMV2zx/lDxZah7cuqB1SHagoREddjFduiHJ+/bui2Xo1iJJ46wLtbsgHtgwtzeXZpc+/1l4BI6LflaLWjDMES+gSGcmMKlT4XZSnd45wHt+eG/fj0ZNUDXBZp+zn2dCyH5IKgUPSbFxQV/hN2fUDn3hm3JgL8gEhn8Z4+OGkhO/gcmMkdcOgZOlMJQPO8w5qs2upy78V0qyTxmgaCSinM4IXJfoJxTZzGYvLcdMaWuhTL1YRoN57KCYmANudG81pSUSQMmwUXrihfK/bfsO5x1e4J9eQUMv8v6NG9WodVzvaOw==">>,<<"01">>,<<"76">>,<<"01">>,<<"000000">>,<<"0">>,<<"898319849000018">>,<<"1127">>,<<"20171129174037">>,<<"00">>},

  pg_up_protocol:in_2_out(?MODULE, Params, post)



.

