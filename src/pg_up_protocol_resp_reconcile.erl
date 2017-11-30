%%%-------------------------------------------------------------------
%%% @author jiarj
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 29. 十一月 2017 15:02
%%%-------------------------------------------------------------------
-module(pg_up_protocol_resp_reconcile).
-author("jiarj").
-include_lib("eunit/include/eunit.hrl").
-include_lib("mixer/include/mixer.hrl").
-compile({parse_trans, exprecs}).
-behaviour(pg_model).
-behavior(pg_protocol).
-behaviour(pg_up_protocol).

%% API
-mixin([{pg_up_protocol, [
  pr_formatter/1
  , in_2_out_map/0
]}]).

-export([sign_fields/0, options/0, convert_config/0]).
-define(TXN, ?MODULE).
-record(?TXN, {
  accessType = <<"0">> :: pg_up_protocol:up_version()
  , bizType = <<"000000">> :: pg_up_protocol:up_bizType()
  , encoding = <<"UTF-8">> :: pg_up_protocol:up_encoding()
  , fileType = <<"00">> :: pg_up_protocol:file_transfer_type()
  , merId = <<"012345678901234">> :: pg_up_protocol:up_merId()
  , settleDate = <<"1127">> :: pg_up_protocol:up_signature()
  , signMethod = <<"01">> :: pg_up_protocol:up_signMethod()
  , txnSubType = <<"01">> :: pg_up_protocol:up_txnSubType()
  , txnTime = <<"19991212121212">> :: pg_up_protocol:up_txnTime()
  , txnType = <<"76">> :: pg_up_protocol:up_txnType()
  , version = <<"5.0.0">> :: pg_up_protocol:up_version()
  , respCode = <<"00">> :: pg_up_protocol:up_respCode()
  , respMsg = <<"交易成功"/utf8>> :: pg_up_protocol:up_respMsg()
  , fileName = <<>>
  , fileContent = <<>>
  , certId = <<"9">> :: pg_up_protocol:up_certId()
  , signature = <<>> :: pg_up_protocol:up_signature()
}).
-type ?TXN() :: #?TXN{}.
%%-opaque ?TXN() :: #?TXN{}.
-export_type([?TXN/0]).
-export_records([?TXN]).


sign_fields() ->
  [].

options() ->
  #{
    channel_type => up,
    txn_type => query,
    direction => resp
  }.

convert_config() ->
  [].