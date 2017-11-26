%%%-------------------------------------------------------------------
%%% @author simon
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 07. Feb 2017 1:04 PM
%%%-------------------------------------------------------------------
-module(pg_up_protocol_resp_query).
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
  , convert_config/0
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
  , txnSubType = <<"01">> :: pg_up_protocol:up_txnSubType()
  , channelType
%%  = <<"07">>
  , accessType = <<"0">> :: pg_up_protocol:up_accessType()
  , merId = <<"012345678901234">> :: pg_up_protocol:up_merId()
  , txnTime = <<"19991212121212">> :: pg_up_protocol:up_txnTime()
  , orderId = <<"01234567">> :: pg_up_protocol:up_orderId()
  , reqReserved :: pg_up_protocol:up_reqReserved()
  , reserved :: pg_up_protocol:up_reserved()
  , queryId = <<>> :: pg_up_protocol:up_queryId()
  , traceNo :: pg_up_protocol:up_traceNo()
  , traceTime :: pg_up_protocol:up_traceTime()
  , settleDate = <<>> :: pg_up_protocol:up_settleDate()
%%  , settleCurrencyCode = <<"156">> :: pg_up_protocol:up_settleCurrencyCode()
  , settleCurrencyCode :: pg_up_protocol:up_settleCurrencyCode()
%%  , settleAmt = 0 :: pg_up_protocol:up_settleAmt()
  , settleAmt :: pg_up_protocol:up_settleAmt()
%%  , txnAmt = 0 :: pg_up_protocol:up_txnAmt()
  , txnAmt :: pg_up_protocol:up_txnAmt()
  , origRespCode :: pg_up_protocol:up_respCode()
  , origRespMsg :: pg_up_protocol:up_respMsg()
  , respCode :: pg_up_protocol:up_respCode()
  , respMsg :: pg_up_protocol:up_respMsg()
%%  , issuerIdentifyMode = <<"0">> :: pg_up_protocol:up_issuerIndentifyMode()
  , issuerIdentifyMode :: pg_up_protocol:up_issuerIndentifyMode()
%%  , bizType = <<"000201">> :: pg_up_protocol:up_bizType()
  , bizType :: pg_up_protocol:up_bizType()
%%  , currencyCode = <<"156">> :: pg_up_protocol:up_currencyCode()
  , currencyCode :: pg_up_protocol:up_currencyCode()
  , accNo :: pg_up_protocol:up_accNo()
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
    , channelType
    , currencyCode
    , encoding
    , issuerIdentifyMode
    , merId
    , orderId
    , origRespCode
    , origRespMsg
    , queryId
    , reqReserved
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


options() ->
  #{
    channel_type => up,
    txn_type => query,
    direction => req
  }.
convert_config() ->
  [
    %% up_req_resp -> up_txn_log
    {default,
      [
        {to, proplists},
        {from,
          [
            {?MODULE,
              [
                {up_index_key, pg_up_protocol, up_index_key}
                , {up_respCode, {fun resp_info/2, [respCode, origRespCode]}}
                , {up_respMsg, {fun resp_info/2, [respMsg, origRespMsg]}}
                , {txn_status, {fun txn_status/2, [respCode, origRespCode]}}

              ]
            }
          ]
        }
      ]
    }
  ].

resp_info(RespInfo, undefined) ->
  RespInfo;
resp_info(_RespInfo, OrigRespInfo) ->
  OrigRespInfo.


txn_status(RespCode, undefined) ->
  xfutils:up_resp_code_2_txn_status(RespCode);
txn_status(_RespCode, OrigRespCode) ->
  xfutils:up_resp_code_2_txn_status(OrigRespCode).

