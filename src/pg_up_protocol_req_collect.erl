%%%-------------------------------------------------------------------
%%% @author simon
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. 十月 2017 14:02
%%%-------------------------------------------------------------------
-module(pg_up_protocol_req_collect).
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
  , to_list/1
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
  , certId = <<"9">> :: pg_up_protocol:certId()
  , signature = <<"0">> :: pg_up_protocol:signature()
  , signMethod = <<"01">> :: pg_up_protocol:signMethod()
  , txnType = <<"11">> :: pg_up_protocol:txnType()
  , txnSubType = <<"00">> :: pg_up_protocol:txnSubType()
  , bizType = <<"000501">> :: pg_up_protocol:bizType()
  , channelType = <<"07">> :: pg_up_protocol:channelType()
  , backUrl = <<"0">> :: pg_up_protocol:url()
  , accessType = <<"0">> :: pg_up_protocol:accessType()
  , merId = <<"012345678901234">> :: pg_up_protocol:merId()
  , orderId = <<"0">> :: pg_up_protocol:orderId()
  , txnTime = <<"19991212090909">> :: pg_up_protocol:txnTime()
  , accType = <<"01">> :: pg_up_protocol:accType()
  , accNo = <<>> :: pg_up_protocol:accNo()
  , txnAmt = 0 :: pg_up_protocol:txnAmt()
  , currencyCode = <<"156">> :: pg_up_protocol:currencyCode()
  , customerInfo = <<>> :: pg_up_protocol:customerInfo()
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
    accNo
    , accessType
    , backUrl
    , bizType
    , certId
    , channelType
    , currencyCode
    , customerInfo
    , encoding
    , merId
    , orderId
    , reqReserved
    , reserved
    , signMethod
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


to_list(Protocol) when is_tuple(Protocol) ->
  VL = [
    {txn_type, collect}
    , {txn_status, waiting}
    , {up_index_key, pg_up_protocol:get(?MODULE, Protocol, up_index_key)}
  ] ++ pg_model:to(?MODULE, Protocol, proplists),
  VL.


convert_config() ->
  [
    %% mcht_req_collect -> up_req_collect
    {default,
      [
%%        {pg_mcht_protocol_req_collect,
        {pg_mcht_protocol, pg_mcht_protocol_req_collect,
          [
            {mcht_index_key, mcht_index_key}
            , {accNo, {fun bank_card_no/2, [mcht_id, bank_card_no]}}
            , {customerInfo, {fun customer_info/4, [id_type, id_no, id_name, mobile]}}
            , {merId, {fun mer_id/1, [mcht_id]}}
            , {certId, {fun cert_id/1, [mcht_id]}}
            , {txnAmt, txn_amt}
            , {reqReserved, order_desc}
            , {channelType, {fun channel_type/1, [mcht_id]}}

          ]
        }
      ]
    }
  ].


-define(APP, pg_up_protocol).
customer_info_raw(IdType, IdNo, IdName, Mobile)
  when is_binary(IdType), is_binary(IdNo), is_binary(IdName), is_binary(Mobile) ->
  <<
    "{"
    , "certfTp=", IdType/binary, "&"
    , "certifId=", IdNo/binary, "&"
    , "customerNm=", IdName/binary, "&"
    , "phoneNo=", Mobile/binary
    , "}"
  >>.
customer_info(IdType, IdNo, IdName, Mobile)
  when is_binary(IdType), is_binary(IdNo), is_binary(IdName), is_binary(Mobile) ->
  Info = customer_info_raw(IdType, IdNo, IdName, Mobile),
  base64:encode(Info).

customer_info_test() ->
  Exp = <<"{certfTp=01&certifId=320404197200000000&customerNm=徐峰&phoneNo=13900000000}"/utf8>>,
  Info = customer_info_raw(<<"01">>, <<"320404197200000000">>, <<"徐峰"/utf8>>, <<"13900000000">>),
  ?assertEqual(Exp, Info),
  ok.

up_mer_id(MchtId) ->
  {ok, MRepoMchants} = application:get_env(?APP, mchants_repo_name),
  [PaymentMethod] = pg_repo:fetch_by(MRepoMchants, MchtId, payment_method),
  MerId = up_config:get_mer_id(PaymentMethod),
  MerId.

mer_id(MchtId) ->
  MerIdAtom = up_mer_id(MchtId),
  MerIdBin = atom_to_binary(MerIdAtom, utf8),
  MerIdBin.

mer_id_test_1() ->
  ?assertEqual(<<"898319849000017">>, mer_id(1)),
  ok.

cert_id(MchtId) ->
  MerId = up_mer_id(MchtId),
  up_config:get_mer_prop(MerId, certId).

channel_type(MchtId) ->
  MerId = up_mer_id(MchtId),
  up_config:get_mer_prop(MerId, channelType).

bank_card_no(MchtId, BankCardNo) when is_binary(MchtId), is_binary(BankCardNo) ->
  %% use mer public key to enc BankCardNo, then base64:encode
  MerId = mer_id(MchtId),
  PublicKey = up_config:get_mer_prop(MerId, publicKey),
  EncBin = public_key:encrypt_public(BankCardNo, PublicKey),
  base64:encode(EncBin).
