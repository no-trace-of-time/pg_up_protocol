%%%-------------------------------------------------------------------
%%% @author simon
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. 十月 2017 14:02
%%%-------------------------------------------------------------------
-module(pg_up_protocol_info_collect).
-include_lib("eunit/include/eunit.hrl").
-include_lib("mixer/include/mixer.hrl").
-compile({parse_trans, exprecs}).
%%-compile({parse_trans, ct_expand}).
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

%% API
%% callbacks of pg_up_protocol
-export([
  sign_fields/0
  , options/0
%%  , to_list/1
]).
%% callbacks of pg_protocol
-export([
  convert_config/0
]).


-compile(export_all).
%%-------------------------------------------------------------------------
-define(P, ?MODULE).

-record(?P, {
  version = <<"5.0.0">> :: pg_up_protocol:version()
  , encoding = <<"UTF-8">> :: pg_up_protocol:encoding()
  , signature = <<"0">> :: pg_up_protocol:signature()
  , signMethod = <<"01">> :: pg_up_protocol:signMethod()
  , txnType = <<"11">> :: pg_up_protocol:txnType()
  , txnSubType = <<"02">> :: pg_up_protocol:txnSubType()
  , bizType = <<"000501">> :: pg_up_protocol:bizType()
  , accessType = <<"0">> :: pg_up_protocol:accessType()
  , merId = <<"012345678901234">> :: pg_up_protocol:merId()
  , orderId = <<"0">> :: pg_up_protocol:orderId()
  , txnTime = <<"19991212090909">> :: pg_up_protocol:txnTime()
  %% the accNo is encrypted
  , accNo = <<>> :: pg_up_protocol:accNo()
  , txnAmt = 0 :: pg_up_protocol:txnAmt()
  , currencyCode = <<"156">> :: pg_up_protocol:currencyCode()
  , reqReserved = <<>> :: pg_up_protocol:reqReserved()
  , reserved = <<>> :: pg_up_protocol:reserved()
  , queryId = <<>> :: pg_up_protocol:queryId()
  , respCode = <<>> :: pg_up_protocol:respCode()
  , respMsg = <<>> :: pg_up_protocol:respMsg()
  , settleAmt = 0 :: pg_up_protocol:settleAmt()
  , settleCurrencyCode = <<>> :: pg_up_protocol:settleCurrencyCode()
  , settleDate = <<>> :: pg_up_protocol:settleDate()
  , traceNo = <<>> :: pg_up_protocol:traceNo()
  , traceTime = <<>> :: pg_up_protocol:traceTime()
  , exchangeDate = <<>> :: pg_up_protocol:exchangeDate()
  , exchangeRate = <<>> :: pg_up_protocol:exchangeRate()
  , payCardType = <<>> :: pg_up_protocol:payCardType()
  , signPubKeyCert = <<>> :: pg_up_protocol:signPubKeyCert()
}).

-type ?P() :: #?P{}.
-export_type([?P/0]).
-export_records([?P]).

%%---------------------------------------------------------------------------------
sign_fields() ->
  [
    accNo
    , accessType
    , bizType
    , currencyCode
    , encoding
    , exchangeDate
    , exchangeRate
    , merId
    , orderId
    , payCardType
    , queryId
    , reqReserved
    , reserved
    , respCode
    , respMsg
    , settleAmt
    , settleCurrencyCode
    , settleDate
    , signMethod
    , signPubKeyCert
    , traceNo
    , traceTime
    , txnAmt
    , txnSubType
    , txnTime
    , txnType
    , version
  ].

options() ->
  #{
    direction => resp
  }.


convert_config() ->
  [
    {default,
      %% get value list to further update up_txn_log
      [
        {to, proplists},
        {from,
          [
            {?MODULE,
              [
                {up_index_key, pg_up_protocol, up_index_key},
                {up_respCode, respCode},
                {up_respMsg, respMsg},
                {txn_status, {fun xfutils:up_resp_code_2_txn_status/1, [respCode]}},
                {up_settleDate, settleDate},
                {up_queryId, queryId},
                {up_traceNo, traceNo},
                {up_traceTime, traceTime}
              ]
            }


          ]
        }
      ]
    },
    %% mcht_req_collect -> up_req_collect
    {save_resp,
      [
        {to, {fun pg_up_protocol:repo_up_module/0, []}},
        {from,
          [
            {?MODULE,
              [
                {up_index_key, pg_up_protocol, up_index_key}
                , {up_respCode, respCode}
                , {up_respMsg, respMsg}

              ]
            }
          ]
        }
      ]
    }
  ].


-define(APP, pg_up_protocol).
