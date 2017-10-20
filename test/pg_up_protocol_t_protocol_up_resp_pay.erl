%%%-------------------------------------------------------------------
%%% @author simon
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. Jan 2017 9:30 PM
%%%-------------------------------------------------------------------
-module(pg_up_protocol_t_protocol_up_resp_pay).
-compile({parse_trans, exprecs}).
-include_lib("eunit/include/eunit.hrl").
-include_lib("mixer/include/mixer.hrl").
-author("simon").
-behaviour(pg_model).
-behaviour(pg_protocol).
-behaviour(pg_up_protocol).

-compile(export_all).
-mixin([
  {pg_up_protocol, [pr_formatter/1, in_2_out_map/0]}
]).
%% API
%% callbacks
-export([
  sign_fields/0
  , options/0
  , save/2
]).


%%-------------------------------------------------------------------
-define(TXN, ?MODULE).

-record(?TXN, {
  version = <<"5.0.0">>
  , encoding = <<"UTF-8">>
  , certId = <<"9">>
  , signature = <<"sig">>
  , signMethod = <<"01">>
  , txnType = <<"01">>
  , txnSubType = <<"01">>
  , bizType = <<"000201">>
  , accessType = <<"0">>
  , merId = <<"012345678901234">>
  , orderId = <<"01234567">>
  , txnTime = <<"19991212121212">>
  , txnAmt = <<"0">>
  , currencyCode = <<"156">>
  , reqReserved = <<"reqReserved">>
  , reserved = <<>>
  , accNo = <<>>
  , queryId = <<>>
  , respCode = <<>>
  , respMsg = <<>>
  , settleAmt = <<>>
  , settleCurrencyCode = <<>>
  , settleDate = <<>>
  , traceNo = <<>>
  , traceTime = <<>>
  , exchangeRate = <<>>
}).
-type ?TXN() :: #?TXN{}.
%%-opaque ?TXN() :: #?TXN{}.
-export_type([?TXN/0]).
-export_records([?TXN]).

%%-------------------------------------------------------------------
sign_fields() ->
  [
    accNo
    , accessType
    , bizType
    , certId
    , currencyCode
    , encoding
    , exchangeRate
    , merId
    , orderId
    , queryId
    , reqReserved
    , reserved
    , respCode
    , respMsg
    , settleAmt
    , settleCurrencyCode
    , settleDate
    , signMethod
    , traceNo
    , traceTime
    , txnAmt
    , txnSubType
    , txnTime
    , txnType
    , version
  ].

convert_config() ->
  [

  ].

options() ->
  #{
    direction => resp
  }.

save(M, P) ->
  ok.

