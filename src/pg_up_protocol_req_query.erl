%%%-------------------------------------------------------------------
%%% @author simon
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 07. Feb 2017 1:04 PM
%%%-------------------------------------------------------------------
-module(pg_up_protocol_req_query).
-include_lib("eunit/include/eunit.hrl").
-include_lib("mixer/include/mixer.hrl").
-compile({parse_trans, exprecs}).
-author("simon").
-behaviour(pg_model).
-behavior(pg_protocol).
-behaviour(pg_up_protocol).

%% API
%% callbacks of up protocol
-mixin([{pg_up_protocol, [
  pr_formatter/1
  , in_2_out_map/0
]}]).
%% callbacks
-export([
  sign_fields/0
  , options/0
]).


%%-------------------------------------------------------------------
-define(TXN, ?MODULE).

-record(?TXN, {
  version = <<"5.0.0">> :: pg_up_protocol:up_version()
  , encoding = <<"UTF-8">> :: pg_up_protocol:up_encoding()
  , certId = <<"9">> :: pg_up_protocol:up_certId()
  , signature = <<"9">> :: pg_up_protocol:up_signature()
  , signMethod = <<"01">> :: pg_up_protocol:up_signMethod()
  , txnType = <<"00">> :: pg_up_protocol:up_txnType()
  , txnSubType = <<"00">> :: pg_up_protocol:up_txnSubType()
  , bizType = <<"000201">> :: pg_up_protocol:up_bizType()
  , channelType = <<"07">>
  , accessType = <<"0">> :: pg_up_protocol:up_accessType()
  , merId = <<"012345678901234">> :: pg_up_protocol:up_merId()
  , txnTime = <<"19991212121212">> :: pg_up_protocol:up_txnTime()
  , orderId = <<"01234567">> :: pg_up_protocol:up_orderId()
  , queryId = <<>> :: pg_up_protocol:up_queryId()
}).
-type ?TXN() :: #?TXN{}.
%%-opaque ?TXN() :: #?TXN{}.
-export_type([?TXN/0]).
-export_records([?TXN]).

%%-------------------------------------------------------------------
sign_fields() ->
  [
    accessType
    , bizType
    , certId
    , channelType
    , encoding
    , merId
    , orderId
    , queryId
    , signMethod
    , txnSubType
    , txnTime
    , txnType
    , version
  ].

options() ->
  #{
    direction => req
  }.



