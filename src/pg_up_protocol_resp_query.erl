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
]).

%%-------------------------------------------------------------------
-define(TXN, ?MODULE).

-record(?TXN, {
  version = <<"5.0.0">> :: up_version()
  , encoding = <<"UTF-8">> :: up_encoding()
  , certId = <<"9">> :: up_certId()
  , signature = <<"9">> :: up_signature()
  , signMethod = <<"01">> :: up_signMethod()
  , txnType = <<"00">> :: up_txnType()
  , txnSubType = <<"01">> :: up_txnSubType()
  , channelType
%%  = <<"07">>
  , accessType = <<"0">> :: up_accessType()
  , merId = <<"012345678901234">> :: up_merId()
  , txnTime = <<"19991212121212">> :: up_txnTime()
  , orderId = <<"01234567">> :: up_orderId()
  , reqReserved :: up_reqReserved()
  , reserved :: up_reserved()
  , queryId = <<>> :: up_queryId()
  , traceNo :: up_traceNo()
  , traceTime :: up_traceTime()
  , settleDate = <<>> :: up_settleDate()
%%  , settleCurrencyCode = <<"156">> :: up_settleCurrencyCode()
  , settleCurrencyCode :: up_settleCurrencyCode()
%%  , settleAmt = 0 :: up_settleAmt()
  , settleAmt :: up_settleAmt()
%%  , txnAmt = 0 :: up_txnAmt()
  , txnAmt :: up_txnAmt()
  , origRespCode :: up_respCode()
  , origRespMsg :: up_respMsg()
  , respCode :: up_respCode()
  , respMsg :: up_respMsg
%%  , issuerIdentifyMode = <<"0">> :: up_issuerIndentifyMode()
  , issuerIdentifyMode :: up_issuerIndentifyMode()
%%  , bizType = <<"000201">> :: up_bizType()
  , bizType :: up_bizType()
%%  , currencyCode = <<"156">> :: up_currencyCode()
  , currencyCode :: up_currencyCode()
  , accNo :: up_accNo()
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
    direction => req
  }.
