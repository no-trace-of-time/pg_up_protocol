%%%-------------------------------------------------------------------
%%% @author simon
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. Jan 2017 9:29 PM
%%%-------------------------------------------------------------------
-module(pg_up_protocol_t_protocol_up_req_pay).
-compile({parse_trans, exprecs}).
-include_lib("mixer/include/mixer.hrl").
-author("simon").
-behaviour(pg_model).
-behavior(pg_protocol).
-behavior(pg_up_protocol).

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
  , signature = <<"0">>
  , signMethod = <<"01">>
  , txnType = <<"01">>
  , txnSubType = <<"01">>
  , bizType = <<"000201">>
  , channelType = <<"07">>
  , frontUrl = <<"0">>
  , backUrl = <<"0">>
  , accessType = <<"0">>
  , merId = <<"012345678901234">>
  , subMerId = <<>>
  , subMerName = <<>>
  , subMerAbbr = <<>>
  , orderId = <<"0">>
  , txnTime = <<"19991212090909">>
  , accType = <<"00">>
  , accNo = <<>>
  , txnAmt = <<"0">>
  , currencyCode = <<"156">>
  , customerInfo = <<>>
  , orderTimeOut = <<>>
  , payTimeout = <<>>
  , termId = <<"01234567">>
  , reqReserved = <<"reqReserved">>
  , reserved = <<"{cardNumberLock=1}">>
  , riskRateInfo = <<>>
  , encryptCertId = <<>>
  , frontFailUrl = <<>>
  , instalTransInfo = <<>>
  , defaultPayType = <<"0001">>
  , issInsCode = <<>>
  , supPayType = <<>>
  , userMac = <<>>
  , customerIp = <<>>
  , cardTransData = <<>>
  , orderDesc = <<>>

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
    , backUrl
    , bizType
    , certId
    , channelType
    , currencyCode
    , defaultPayType
    , encoding
    , frontUrl
%%    , issInsCode
    , merId
%%    , orderDesc
    , orderId
    , reqReserved
    , reserved
    , signMethod
    , termId
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

save(M,P) ->

  ok.
