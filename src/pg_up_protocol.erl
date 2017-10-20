-module(pg_up_protocol).
-include_lib("eunit/include/eunit.hrl").
%%-behavior(pg_model).
%%-behavior(pg_protocol).

%% callbacks
-callback sign_fields() -> [atom()].
-callback options() -> map().
-callback validate() -> boolean().
-callback save(M :: atom(), Protocol :: pg_model:pg_model()) -> ok|fail.

%% API exports
%% callbacks of pg_protocol
-export([
  in_2_out_map/0
]).

%% callbacks of pg_model
-export([
  pr_formatter/1
]).


%% own api
-export([
  get/3
  , verify/2
  , sign_string/2
  , sign/2
  , validate_format/1
]).
%%====================================================================
%% API functions
%%====================================================================
pr_formatter(Field)
  when (Field =:= resp_msg)
  or (Field =:= reserved)
  or (Field =:= reqReserved)
  ->
  string;
pr_formatter(_) ->
  default.


%%------------------------------------------------------
in_2_out_map() ->
  #{
    version => <<"version">>
    , encoding=> <<"encoding">>
    , certId=> <<"certId">>
    , signature=> <<"signature">>
    , signMethod=> <<"signMethod">>
    , txnType=> <<"txnType">>
    , txnSubType=> <<"txnSubType">>
    , bizType=> <<"bizType">>
    , channelType=> <<"channelType">>
    , accessType=> <<"accessType">>
    , merId=> <<"merId">>
    , txnTime=> <<"txnTime">>
    , orderId=> <<"orderId">>
    , queryId=> <<"queryId">>

    , txnAmt => {<<"txnAmt">>, integer}
    , currencyCode =><<"currencyCode">>
    , reqReserved =><<"reqReserved">>
    , respCode =><<"respCode">>
    , respMsg =><<"respMsg">>
    , settleAmt =>{<<"settleAmt">>, integer}
    , settleCurrencyCode =><<"settleCurrencyCode">>
    , settleDate =><<"settleDate">>
    , traceNo =><<"traceNo">>
    , traceTime =><<"traceTime">>
    , txnSubType =><<"txnSubType">>
    , txnTime =><<"txnTime">>
    , reserved =><<"reserved">>
    , accNo =><<"accNo">>

    , origRespCode => <<"origRespCode">>
    , origRespMsg => <<"origRespMsg">>
    , issuerIdentifyMode => <<"issuerIdentifyMode">>

    , exchangeRate => <<"exchangeRate">>
  }.

%%------------------------------------------------------
-spec get(M :: atom(), Model :: pg_model:pg_model(), Field :: atom())
      -> Value :: any().

get(M, Model, up_index_key) when is_atom(M), is_tuple(Model) ->
  {
    pg_model:get(M, Model, merId)
    , pg_model:get(M, Model, txnTime)
    , pg_model:get(M, Model, orderId)
  };
get(M, Model, Field) when is_atom(Field) ->
  pg_model:get(M, Model, Field);
get(M, Model, Fields) when is_list(Fields) ->
  [?MODULE:get(M, Model, Field) || Field <- Fields].

%%------------------------------------------------------
-spec verify(M, Protocol) -> PassOrNot when
  M :: atom(),
  Protocol :: pg_model:pg_model(),
  PassOrNot :: ok | fail.

verify(M, P) when is_atom(M), is_tuple(P) ->
  SignString = sign_string(M, P),
  Digest = digest_string(SignString),

  Sig = pg_model:get(M, P, signature),
  SigDecoded = signature_decode(Sig),

  PK = up_config:get_config(public_key),

  case public_key:verify(Digest, sha, SigDecoded, PK) of
    true -> ok;
    false ->
      UpIndexKey = get(M, P, up_index_key),
      lager:error("Up Txn ~p sig verify failed.SignString = ~ts,Sig = ~ts",
        [UpIndexKey, SignString, Sig]),
      fail
  end.

%%------------------------------------------------
-spec sign(M, P) -> Sig when
  M :: atom(),
  P :: pg_model:pg_model(),
  Sig :: binary() | iolist().

sign(M, P) when is_atom(M), is_tuple(P) ->
  SignString = sign_string(M, P),
  MerId = pg_model:get(M, P, merId),
  lager:debug("SignString = ~ts", [SignString]),
  Digest = digest_string(SignString),
  Key = up_config:get_mer_prop(MerId, privateKey),
  SignBin = do_sign(Digest, Key),
  SignBin.

%%------------------------------------------------
validate_format(P) ->
  ok.

%%====================================================================
%% Internal functions
%%====================================================================
-spec sign_string(M, Model) -> Sig when
  M :: atom(),
  Model :: pg_model:pg_model(),
  Sig :: binary().
sign_string(M, Model) when is_atom(M), is_tuple(Model) ->
  SignFields = M:sign_fields(),
  L = [
    one_sign_field(X, pg_model:get(M, Model, X))
    || X <- SignFields
  ],
  list_to_binary(L).

one_sign_field(version = X, Value) ->
  %% last field
  [atom_to_list(X), <<"=">>, Value];
one_sign_field(settleDate, <<"0000">>) ->
  [];
one_sign_field(_X, EmptyValue)
  when (EmptyValue =:= <<>>)
  or (EmptyValue =:= undefined)
  ->
  [];
one_sign_field(X, Value) when is_integer(Value) ->
  [atom_to_list(X), <<"=">>, integer_to_binary(Value), <<"&">>];
one_sign_field(X, Value) when is_binary(Value);is_list(Value) ->
  [atom_to_list(X), <<"=">>, Value, <<"&">>].

%%---------------------------------------------------
-spec digest_string_upper(binary()) -> binary().
digest_string_upper(Bin) ->
  DigestBin = crypto:hash(sha, Bin),
  DigestHex = xfutils:bin_to_hex(DigestBin),
  % convert to lowercase
  DigestHex.
%%---------------------------------------------------
-spec digest_string(binary()) -> binary().
digest_string(Bin) ->
  U = digest_string_upper(Bin),
  list_to_binary(string:to_lower(binary_to_list(U))).

digest_string_test() ->
  A = <<"accNo=6225682141000002950&accessType=0&backUrl=https://101.231.204.80:5000/gateway/api/backTransReq.do&bizType=000201&certId=124876885185794726986301355951670452718&channelType=07&currencyCode=156&encoding=UTF-8&merId=898340183980105&orderId=2014110600007615&signMethod=01&txnAmt=000000010000&txnSubType=01&txnTime=20150109135921&txnType=01&version=5.0.0">>,

  ?assertEqual(<<"c527432e8f632d555c651eaf8e5e0b027405fa46">>, digest_string(A)).


%%---------------------------------------------------
-spec signature_decode(binary()) -> binary().
signature_decode(Signature) ->
  base64:decode(Signature).
%%---------------------------------------------------
do_sign(DigestBin, PK) when is_binary(DigestBin) ->
  base64:encode(public_key:sign(DigestBin, 'sha', PK)).
