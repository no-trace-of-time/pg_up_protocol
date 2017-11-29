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
  accessType = <<"0">>
  , bizType = <<"000000">>
  , encoding = <<"UTF-8">>
  , fileType = <<"00">>
  , merId = <<"012345678901234">>
  , settleDate = <<"1127">>
  , signMethod = <<"01">>
  , txnSubType = <<"01">>
  , txnTime = <<"19991212121212">>
  , txnType = <<"76">>
  , version = <<"5.0.0">>
  , respCode = <<"00">>
  , respMsg = <<"交易成功"/utf8>>
  , fileName = <<>>
  , fileContent = <<>>
  , signature = <<>>
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