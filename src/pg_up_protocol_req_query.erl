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
    channel_type => up,
    txn_type=>query,
    direction => req
  }.

convert_config() ->
  [
    %% up_txn_log -> up_req_query
    {default,
      [
        {to, ?MODULE},
        {from,
          [
            {{pg_up_protocol, repo_module, [up_txn_log]},
              [
                {version, {fun get_version/0, []}}
                , {merId, up_merId}
                , {certId, {fun cert_id/1, [up_merId]}}
                , {txnTime, up_txnTime}
                , {orderId, up_orderId}

              ]
            }
          ]
        }
      ]
    },
    {save_req,
      [
%%        {to, {fun repo_up_module/0, []}},
        {to, {pg_up_protocol, repo_module, [up_txn_log]}},
        {from,
          [
            {?MODULE,
              [
                {txn_type, {static, collect}}
                , {txn_status, {static, waiting}}
                , {mcht_index_key, pg_model, mcht_index_key}
                , {up_merId, merId}
                , {up_txnTime, txnTime}
                , {up_orderId, orderId}
                , {up_txnAmt, txnAmt}
                , {up_reqReserved, reqReserved}
%%                , {up_orderDesc, orderDesc}
                , {up_index_key, pg_up_protocol, up_index_key}

                , {up_accNo, accNoRaw}
                , {up_idType, idType}
                , {up_idNo, idNo}
                , {up_idName, idName}
                , {up_mobile, mobile}
              ]
            }
          ]
        }
      ]
    }
  ].


get_version() ->
  case up_config:get_config(sign_version) of
    '5.0.0' ->
      <<"5.0.0">>;
    '5.1.0' ->
      <<"5.1.0">>
  end.

cert_id(MerId) when is_binary(MerId) ->
  CertId = up_config:get_mer_prop(MerId, certId),
  ?debugFmt("CertId = ~p~n", [CertId]),
  CertId.

now_txn() ->
  datetime_x_fin:now(txn).
