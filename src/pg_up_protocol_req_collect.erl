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
  %% the accNo is encrypted
  , accNo = <<>> :: binary()
  , txnAmt = 0 :: pg_up_protocol:txnAmt()
  , currencyCode = <<"156">> :: pg_up_protocol:currencyCode()
  , customerInfo = <<>> :: pg_up_protocol:customerInfo()
  , reqReserved = <<>> :: pg_up_protocol:reqReserved()
  , reserved = <<>> :: pg_up_protocol:reserved()
  , mcht_index_key = <<>> :: pg_up_protocol:mcht_index_key()
  , idType = <<>> :: pg_mcht_protocol:id_type()
  , idNo = <<>> :: pg_mcht_protocol:id_no()
  , idName = <<>> :: pg_mcht_protocol:id_name()
  , mobile = <<>> :: pg_mcht_protocol:mobile()
  , accNoRaw = <<>> :: pg_up_protocol:accNo()
  , encryptCertId = <<>> :: pg_up_protocol:encryptCertId()
  , termId = <<"01234567">> :: pg_up_protocol:termId()
}).

-type ?P() :: #?P{}.
-export_type([?P/0]).
-export_records([?P]).

%%---------------------------------------------------------------------------------
sign_fields() ->
  [
    accNo
    , accType
    , accessType
    , backUrl
    , bizType
    , certId
    , channelType
    , currencyCode
    , customerInfo
    , encoding
    , encryptCertId
    , merId
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
    channel_type => up,
    txn_type=>collect,
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
        {to, pg_up_protocol_req_collect},
        {from,
          [
            {pg_mcht_protocol, pg_mcht_protocol_req_collect,
              [
                {accNo, {fun bank_card_no/1, [bank_card_no]}}
%%                , {accNo, bank_card_no}
                , {customerInfo, {fun customer_info/4, [id_type, id_no, id_name, mobile]}}
                , {merId, {fun mer_id/1, [mcht_id]}}
                , {certId, {fun cert_id/1, [mcht_id]}}
                , {txnAmt, txn_amt}
%%                , {reqReserved, order_desc}
                , {channelType, {fun channel_type/1, [mcht_id]}}
                , {idType, id_type}
                , {idNo, id_no}
                , {idName, id_name}
                , {mobile, mobile}
                , {accNoRaw, bank_card_no}

                , {backUrl, {fun get_up_back_url/0, []}}
                , {txnTime, {fun now_txn/0, []}}
                , {orderId, {fun xfutils:get_new_order_id/0, []}}
                , {encryptCertId, {fun get_up_encrypt_cert_id/0, []}}
                , {termId, {fun get_term_id/1, [mcht_id]}}
                , {version, {fun get_version/0, []}}
                , {mcht_index_key, mcht_index_key}

              ]
            }
          ]
        }
      ]
    },
    {save_req,
      [
%%        {to, {fun repo_up_module/0, []}},
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

repo_up_module() ->
  pg_up_protocol:repo_module(up_txn_log).

-define(APP, pg_up_protocol).
customer_info_raw(IdType, IdNo, IdName, Mobile)
  when is_binary(IdType), is_binary(IdNo), is_binary(IdName), is_binary(Mobile) ->
  PhoneInfo = <<"phoneNo=", Mobile/binary>>,
  lager:debug("Sends Info phone info = ~p", [PhoneInfo]),
%%  ?debugFmt("PhoneInfo=[~ts]", [PhoneInfo]),
  EncryptedInfo = encrypt_sens_info(PhoneInfo),
  Return = <<
    "{"
    , "certifId=", IdNo/binary, "&"
    , "certifTp=", IdType/binary, "&"
    , "customerNm=", IdName/binary, "&"
    , "encryptedInfo=", EncryptedInfo/binary
    , "}"
  >>,
  lager:debug("customer info raw  = ~ts", [Return]),
  Return.
customer_info(IdType, IdNo, IdName, Mobile)
  when is_binary(IdType), is_binary(IdNo), is_binary(IdName), is_binary(Mobile) ->
  Info = customer_info_raw(IdType, IdNo, IdName, Mobile),
%%  ?debugFmt("customer_info_raw= ~ts", [Info]),
  base64:encode(Info).

customer_info_test_1() ->
  Exp = <<"{certifId=341126197709218366&certfTp=01&customerNm=全渠道&encryptedInfo="/utf8>>,
  Info = customer_info_raw(<<"01">>, <<"341126197709218366">>, <<"全渠道"/utf8>>, <<"13552535506">>),
%%  ?assertEqual(<<>>, Info),

  InfoEncoded = customer_info(<<"01">>, <<"341126197709218366">>, <<"全渠道"/utf8>>, <<"13552535506">>),
%%  ?assertEqual(<<"e2NlcnRpZklkPTM0MTEyNjE5NzcwOTIxODM2NiZjZXJ0ZlRwPTAxJmN1c3RvbWVyTm095YWo5rig6YGTJnBob25lTm89MTM1NTI1MzU1MDZ9">>,
%%    InfoEncoded),
  ok.

up_mer_id(MchtId) ->
  MRepoMchants = pg_up_protocol:repo_module(mchants),
%%  {ok, MRepoMchants} = application:get_env(?APP, mchants_repo_name),
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


encrypt_sens_info(Raw) when is_binary(Raw) ->
  %% use mer public key to enc BankCardNo, then base64:encode
  PublicKey = up_config:get_config(sens_public_key),
  EncBin = public_key:encrypt_public(Raw, PublicKey),
  base64:encode(EncBin).

bank_card_no(BankCardNo) when is_binary(BankCardNo) ->
  encrypt_sens_info(BankCardNo).

%% every time , encrypt_public/2 result is not same
bank_card_no_test_1() ->
  ExpPK = {'RSAPublicKey', 25075441131720567085866729902218159377747062423371383524107374761812717563770268109948997780288273071334258860858052915905355276343651307038086547922894132189380520541045599388877318252919095727764841077854895985104729100540638767684783361856348670561720370893509135410850018931054760898624291436503576684397021129014869781575449697643844434389225954363141170194360004654461363558157997231378724765755264305476379664451164352960066619439868314736961337393825214127794543032860376797376971393045209385195525356416942360758376969793124724100310897024728103993596295956646042637599700366931961110130318723862096932387779,
    65537},
  ?assertEqual(ExpPK, public_key(<<"1">>)),
  ?assertEqual(<<>>, bank_card_no(<<"9555500216246958">>)),
  ok.

now_txn() ->
  datetime_x_fin:now(txn).

get_up_back_url() ->
  up_config:get_config(pg_collect_back_url).

get_up_encrypt_cert_id() ->
  up_config:get_config(encrypt_cert_id).


get_version() ->
  case up_config:get_config(sign_version) of
    '5.0.0' ->
      <<"5.0.0">>;
    '5.1.0' ->
      <<"5.1.0">>
  end.

get_term_id(MchtId) ->
  MRepoMcht = pg_up_protocol:repo_module(mchants),
  pg_repo:fetch_by(MRepoMcht, MchtId, up_term_no).
