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
  version = <<"5.0.0">> :: pg_up_protocol:up_version()
  , encoding = <<"UTF-8">> :: pg_up_protocol:up_encoding()
%%		, certId => unionpay_config:certId(unionpay_config:short_mer_id(MerId))
  , certId = <<"9">> :: pg_up_protocol:up_certId()
  , signature = <<"9">> :: pg_up_protocol:up_signature()
  , signMethod = <<"01">> :: pg_up_protocol:up_signMethod()
  , txnType = <<"76">> :: pg_up_protocol:up_txnType()
  , txnSubType = <<"01">> :: pg_up_protocol:up_txnSubType()
  , bizType = <<"000000">> :: pg_up_protocol:up_bizType()
  , accessType = <<"0">> :: pg_up_protocol:up_accessType()
  , merId = <<"012345678901234">> :: pg_up_protocol:up_merId()
  , settleDate = <<"1212">>
  , txnTime = <<"19991212121212">> :: pg_up_protocol:up_txnTime()
  , fileType = <<"00">> :: pg_up_protocol:file_transfer_type()
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

