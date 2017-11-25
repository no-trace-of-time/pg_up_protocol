%%%-------------------------------------------------------------------
%%% @author simon
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. 十月 2017 14:02
%%%-------------------------------------------------------------------
-module(pg_up_protocol_req_batch_collect).
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
  , certId = <<>> :: pg_up_protocol:certId()
  , signature = <<"0">> :: pg_up_protocol:signature()
  , signMethod = <<"01">> :: pg_up_protocol:signMethod()
  , txnType = <<"21">> :: pg_up_protocol:txnType()
  , txnSubType = <<"02">> :: pg_up_protocol:txnSubType()
  , bizType = <<"000501">> :: pg_up_protocol:bizType()
  , channelType = <<"07">> :: pg_up_protocol:channelType()
  , backUrl = <<"0">> :: pg_up_protocol:url()
  , accessType = <<"0">> :: pg_up_protocol:accessType()
  , merId = <<"012345678901234">> :: pg_up_protocol:merId()
%%  , orderId = <<"0">> :: pg_up_protocol:orderId()
  , batchNo = <<"0">> :: pg_up_protocol:batchNo()
  , txnTime = <<"19991212090909">> :: pg_up_protocol:txnTime()
%%  , accType = <<"01">> :: pg_up_protocol:accType()
  , totalQty = 0 :: pg_up_protocol:totalQty()
  , totalAmt = 0 :: pg_up_protocol:totalAmt()
  , fileContent = <<"0">> :: pg_up_protocol:fileContent()
  , reqReserved = <<>> :: pg_up_protocol:reqReserved()
  , reserved = <<>> :: pg_up_protocol:reserved()
  , mcht_index_key
}).

-type ?P() :: #?P{}.
-export_type([?P/0]).
-export_records([?P]).

%%---------------------------------------------------------------------------------
sign_fields() ->
  [
%%    accNo
%%    accType
    accessType
    , backUrl
    , batchNo
    , bizType
    , certId
    , channelType
%%    , currencyCode
%%    , customerInfo
    , encoding
    , fileContent
%%    , encryptCertId
    , merId
%%    , orderId
    , reqReserved
    , reserved
    , signMethod
    , totalAmt
    , totalQty
%%    , txnAmt
    , txnSubType
    , txnTime
    , txnType
    , version

  ].

options() ->
  #{
    channel_type => up,
    txn_type=>batch_collect,
    direction => req
  }.


%%to_list(Protocol) when is_tuple(Protocol) ->
%%  VL = [
%%    {txn_type, collect}
%%    , {txn_status, waiting}
%%    , {up_index_key, pg_up_protocol:get(?MODULE, Protocol, up_index_key)}
%%  ] ++ pg_model:to(?MODULE, Protocol, proplists),
%%  VL.


convert_config() ->
  [
    %% mcht_req_collect -> up_req_collect
    {default,
      [
        {to, pg_up_protocol_req_batch_collect},
        {from,
          [
            {pg_mcht_protocol, pg_mcht_protocol_req_batch_collect,
              [
                {mcht_index_key, mcht_index_key}
                , {merId, {fun mer_id/1, [mcht_id]}}
                , {certId, {fun cert_id/1, [mcht_id]}}
                , {totalAmt, txn_amt}
                , {totalQty, txn_count}
                , {fileContent, {fun file_content/1, [file_content]}}
                , {batchNo, {fun batch_no/1, [batch_no]}}
%%                , {reqReserved, order_desc}
                , {channelType, {fun channel_type/1, [mcht_id]}}

                , {backUrl, {fun get_up_back_url/0, []}}
                , {txnTime, {fun now_txn/0, []}}
                , {version, {fun get_version/0, []}}
%%                , {orderId, {fun xfutils:get_new_order_id/0, []}}

              ]
            }
          ]
        }
      ]
    },
    {save_req,
      [
        {to, {fun repo_up_module/0, []}},
        {from,
          [
            {?MODULE,
              [
                {txn_type, {static, collect}}
                , {txn_status, {static, waiting}}
                , {mcht_index_key, pg_model, mcht_index_key}
                , {up_merId, merId}
                , {up_txnTime, txnTime}
                , {up_orderId, {fun xfutils:get_new_order_id/0, []}}
                , {up_txnAmt, txnAmt}
                , {up_reqReserved, reqReserved}
%%                , {up_orderDesc, orderDesc}
                , {up_index_key, pg_up_protocol, up_index_key}

                , {up_batchNo, batchNo}
                , {up_totalAmt, totalAmt}
                , {up_totalQty, totalQty}
                , {up_fileContent, fileContent}

              ]
            }
          ]
        }
      ]
    }
  ].

repo_up_module() ->
  pg_up_protocol:repo_module(up_txn_log).

-define(APP, pg_up_protocol).

up_mer_id(MchtId) ->
  {ok, MRepoMchants} = application:get_env(?APP, mchants_repo_name),
  [PaymentMethod] = pg_repo:fetch_by(MRepoMchants, MchtId, payment_method),
  MerId = up_config:get_mer_id(PaymentMethod),
  MerId.

mer_id(MchtId) ->
  MerIdAtom = up_mer_id(MchtId),
  ?debugFmt("MerId = ~p", [MerIdAtom]),
  MerIdBin = atom_to_binary(MerIdAtom, utf8),
  MerIdBin.

mer_id_test_1() ->
  ?assertEqual(<<"898319849000017">>, mer_id(1)),
  ok.

cert_id(MchtId) ->
  MerId = up_mer_id(MchtId),
  CertId = up_config:get_mer_prop(MerId, certId),
  ?debugFmt("CertId = ~p~n", [CertId]),
  CertId.

cert_id_test_1() ->
  ?assertEqual(<<"68759663125">>, cert_id(1)),
  ok.

channel_type(MchtId) ->
  MerId = up_mer_id(MchtId),
  up_config:get_mer_prop(MerId, channelType).

public_key(MchtId) ->
  MerId = mer_id(MchtId),
  PublicKey = up_config:get_mer_prop(MerId, publicKey),
  PublicKey.


now_txn() ->
  datetime_x_fin:now(txn).

get_up_back_url() ->
  up_config:get_config(pg_batch_collect_back_url).


get_version() ->
  case up_config:get_config(sign_version) of
    '5.0.0' ->
      <<"5.0.0">>;
    '5.1.0' ->
      <<"5.1.0">>
  end.

batch_no(BatchNo) when is_integer(BatchNo) ->
  list_to_binary(io_lib:format("~4..0B", [BatchNo])).

file_content(FileContent) when is_binary(FileContent) ->
  FileContent.
%%  base64:encode(xfutils:deflate(FileContent)).