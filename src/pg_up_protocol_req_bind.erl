%%%-------------------------------------------------------------------
%%% @author simon
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 27. 十一月 2017 22:39
%%%-------------------------------------------------------------------
-module(pg_up_protocol_req_bind).
-author("simon").
-include_lib("eunit/include/eunit.hrl").
-include_lib("mixer/include/mixer.hrl").
-compile({parse_trans, expresc}).
-behavior(pg_protocol).
-behavior(pg_up_protocol).

%% API
-mixin([
  {pg_up_protocol, [pr_formatter/1, in_2_out_map/0]}

]).
-export([
  sign_fields/0
  , options/0
  , convert_config/0
]).

%%---------------------------------------------------------------------
-define(P, ?MODULE).

-record(?P, {
  version = <<"5.0.0">> :: pg_up_protocol:version()
  , encoding = <<"UTF-8">> :: pg_up_protocol:encoding()
  , certId = <<>> :: pg_up_protocol:certId()
  , signature = <<"0">> :: pg_up_protocol:signature()
  , signMethod = <<"01">> :: pg_up_protocol:signMethod()
  , txnType = <<"72">> :: pg_up_protocol:txnType()
  , txnSubType = <<"01">> :: pg_up_protocol:txnSubType()
  , bizType = <<"000501">> :: pg_up_protocol:bizType()
  , channelType = <<"07">> :: pg_up_protocol:channelType()
  , frontUrl = <<"0">> :: pg_up_protocol:url()
  , backUrl = <<"0">> :: pg_up_protocol:url()
  , accessType = <<"0">> :: pg_up_protocol:accessType()
  , merId = <<"012345678901234">> :: pg_up_protocol:merId()
  , orderId = <<"0">> :: pg_up_protocol:orderId()
  , txnTime = <<"19991212090909">> :: pg_up_protocol:txnTime()
  , accType = <<"01">> :: pg_up_protocol:accType()
  %% the accNo is encrypted
  , accNo = <<>> :: binary()
  , customerInfo = <<>> :: pg_up_protocol:customerInfo()
  , reqReserved = <<>> :: pg_up_protocol:reqReserved()
  , reserved = <<>> :: pg_up_protocol:reserved()
  , encryptCertId = <<>> :: pg_up_protocol:encryptCertId()
  , termId = <<"01234567">> :: pg_up_protocol:termId()

  , mcht_index_key = <<>> :: pg_up_protocol:mcht_index_key()
  , idType = <<>> :: pg_mcht_protocol:id_type()
  , idNo = <<>> :: pg_mcht_protocol:id_no()
  , idName = <<>> :: pg_mcht_protocol:id_name()
  , mobile = <<>> :: pg_mcht_protocol:mobile()
  , accNoRaw = <<>> :: pg_up_protocol:accNo()

}).

-type ?P() :: #?P{}.
-export_type([?P/0]).
-export_records([?P]).

%%------------------------------------------------------------------
sign_fields() ->
  [
    accNo
    , accType
    , accessType
    , backUrl
    , bizType
    , certId
    , channelType
    , customerInfo
    , encoding
    , encryptCertId
    , merId
    , orderId
    , reqReserved
    , reserved
    , signMethod
    , termId
    , txnSubType
    , txnTime
    , txnType
    , version

  ].

%%------------------------------------------------------------------
options() ->
  #{
    channel_type => up,
    txn_type=>bind,
    direction => req
  }.
%%------------------------------------------------------------------
convert_config() ->
  [
    {default,
      [
        {to,?MODULE},
        {from,
          [

          ]}
      ]
    }

  ].
