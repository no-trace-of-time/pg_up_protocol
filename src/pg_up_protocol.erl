-module(pg_up_protocol).
-include_lib("eunit/include/eunit.hrl").
-include("include/type_up_protocol.hrl").
-compile({parse_trans, ct_expand}).
%%-behavior(pg_model).
%%-behavior(pg_protocol).

%% callbacks
-callback sign_fields() -> [atom()].
-callback options() -> map().
%%-callback validate() -> boolean().
%%-callback to_list(Protocol :: pg_model:pg_model()) -> proplists:proplist().

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
%%  , sign/4
  , validate_format/1
  , save/2
  , repo_module/1
  , out_2_in/2
  , in_2_out/3
]).


-export([
  sign_aaa_test_1/0
]).
-define(APP, pg_up_protocol).
%%====================================================================
%% API functions
%%====================================================================
pr_formatter(Field)
  when (Field =:= respMsg)
  or (Field =:= reserved)
  or (Field =:= reqReserved)
  or (Field =:= origRespMsg)
  ->
  string;
pr_formatter(_) ->
  default.


%%------------------------------------------------------
build_in_2_out_map() ->
  Fields = [
    version
    , encoding
    , certId
    , signature
    , signMethod
    , txnType
    , txnSubType
    , bizType
    , channelType
    , accessType
    , merId
    , txnTime
    , orderId
    , queryId

    , {txnAmt, integer}
    , currencyCode
    , reqReserved
    , respCode
    , respMsg
    , {settleAmt, integer}
    , settleCurrencyCode
    , settleDate
    , traceNo
    , traceTime
    , txnSubType
    , txnTime
    , reserved
    , accNo

    , origRespCode
    , origRespMsg
    , issuerIdentifyMode

    , exchangeRate
    , frontUrl
    , backUrl
    , customerInfo
    , termId
    , defaultPayType

    , accType

  ],

  F = fun
        ({Key, Type}) ->
          {Key, {atom_to_binary(Key, utf8), Type}};
        (Key) ->
          {Key, atom_to_binary(Key, utf8)}
      end,
  VL = [F(Field) || Field <- Fields],
  maps:from_list(VL).


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
    , frontUrl => <<"frontUrl">>
    , backUrl => <<"backUrl">>
    , customerInfo => <<"customerInfo">>
    , termId => <<"termId">>
    , defaultPayType => <<"defaultPayType">>

    , accType => <<"accType">>
    , encryptCertId => <<"encryptCertId">>

    , batchNo => <<"batchNo">>
    , totalQty => {<<"totalQty">>, integer}
    , totalAmt => {<<"totalAmt">>, integer}
    , fileContent => <<"fileContent">>
    , fileType => <<"fileType">>
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
-spec sign(M, P) -> {SignString, Sig} when
  M :: atom(),
  P :: pg_model:pg_model(),
  SignString :: binary(),
  Sig :: binary() | iolist().

sign(M, P) when is_atom(M), is_tuple(P) ->
  SignString = sign_string(M, P),
  [Version, MerId] = pg_model:get(M, P, [version, merId]),
  Sig = sign(M, SignString, Version, MerId),
  {SignString, Sig}.
%%------------------------------------------------
-spec sign(M, SignString, Version, MerId) -> Sig when
  M :: atom(),
  SignString :: binary(),
  Version :: pg_up_protocol:version(),
  MerId :: pg_up_protocol:merId(),
  Sig :: binary() | iolist().

sign(M, SignString, Version, MerId)
  when is_atom(M), is_binary(SignString), is_binary(Version), is_binary(MerId) ->
  %% sign string directly

%%  MerId = pg_model:get(M, P, merId),
  Key = up_config:get_mer_prop(MerId, privateKey),

%%  SignBin = case pg_model:get(M, P, version) of
  SignBin = case Version of
              <<"5.0.0">> ->
                Digest = digest_string(SignString),
                ?debugFmt("Digest128 = ~p", [Digest]),
                do_sign(Digest, Key);
              <<"5.1.0">> ->
                Digest = digest256_string(SignString),
                ?debugFmt("Digest256 = ~p", [Digest]),
                do_sign256(Digest, Key)
            end,
  lager:debug("SignString = ~ts,Sig=~ts", [SignString, SignBin]),
  ?debugFmt("SignString = ~ts,Sig=~ts", [SignString, SignBin]),
  SignBin.

sign256(M, P) when is_atom(M), is_tuple(P) ->
  SignString = sign_string(M, P),
  MerId = pg_model:get(M, P, merId),
  Digest = digest256_string(SignString),
  Key = up_config:get_mer_prop(MerId, privateKey),
  SignBin = do_sign256(Digest, Key),
  lager:debug("SignString = ~ts,Sig=~ts", [SignString, SignBin]),
  ?debugFmt("SignString = ~ts,Sig=~ts", [SignString, SignBin]),
  SignBin.
%%------------------------------------------------
validate_format(P) ->
  ok.

%%------------------------------------------------
-spec save(M, P) -> Result when
  M :: atom(),
  P :: pg_model:pg_model(),
  Result :: ok|fail.

save(M, P) when is_atom(M), is_tuple(P) ->
%%  VL = M:to_list(P),
%%  MRepo = repo_up_module(),
%%  Repo = pg_model:new(MRepo, VL),
  Repo = pg_convert:convert(M, [P], save_req),
  xfutils:cond_lager(?MODULE, debug, error, "Repo to be saved = ~p", [Repo]),
  lager:error("Repo to be saveddd = ~p", [Repo]),
  pg_repo:save(Repo).


%%------------------------------------------------
repo_module(up_txn_log) ->
  {ok, Module} = application:get_env(?APP, up_repo_name),
  Module;
repo_module(mchants) ->
  {ok, Module} = application:get_env(?APP, mchants_repo_name),
  Module.
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

-spec digest256_string_upper(binary()) -> binary().
digest256_string_upper(Bin) ->
  DigestBin = crypto:hash(sha256, Bin),
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


digest256_string(Bin) ->
  U = digest256_string_upper(Bin),
  list_to_binary(string:to_lower(binary_to_list(U))).
%%---------------------------------------------------
-spec signature_decode(binary()) -> binary().
signature_decode(Signature) ->
  base64:decode(Signature).
%%---------------------------------------------------
do_sign(DigestBin, PK) when is_binary(DigestBin) ->
  base64:encode(public_key:sign(DigestBin, 'sha', PK)).
%%  base64:encode(public_key:sign(DigestBin, 'sha256', PK)).
do_sign256(DigestBin, PK) when is_binary(DigestBin) ->
  base64:encode(public_key:sign(DigestBin, 'sha256', PK)).
%%---------------------------------------------------
out_2_in(M, PV) when is_atom(M), is_list(PV) ->
  pg_protocol:out_2_in(M, PV).
%%---------------------------------------------------
out_fields(M) when is_atom(M) ->
  [signature | M:sign_fields()].
%%---------------------------------------------------
in_2_out(M, Protocol, proplists) when is_atom(M), is_tuple(Protocol) ->
  pg_model:to(M, Protocol, {proplists, out_fields(M), in_2_out_map()});
in_2_out(M, Protocol, post) when is_atom(M), is_tuple(Protocol) ->
  pg_model:to(M, Protocol, {poststring, out_fields(M), in_2_out_map()}).

%%-----------------------------------------------------
sign_aaa_test_1() ->
  SignString = <<"aaa">>,
  Digest = digest_string(SignString),
  Key = up_config:get_mer_prop('777290058110097', privateKey),
  SignBin = do_sign(Digest, Key),
  ?assertEqual(<<"xdzlekQXkOvFHxw+O5av+M5ldunyEEswIj/LHztkqaTbCDk+4b7nzSRSYRxfpOXv+boye9F7mqUXEDQarEct0TeauUxPtBkQidnZCbh0nZRvkT4B/OrX8iWpINEabGkh200nd16oere7Zw/u0AvMvroOcagGFkHzzD8NPvAk0gPhNNhTqD9sh6VRkWgjxcoQdpJsqgP9H8GG4TJHHkQ9Yf8coPdyZEbRHfBhbstyWxZ1D/9hPNtoER09AVikzqj/zF6AKGFbaPPBfLD0ym/ZVwyum1cIJ87aHtWsz1F8NkKOvBkc0IZCZ+cbpwlkNOBJxtA46IYZHitern54ehVCWw==">>
    , SignBin),

  ?assertEqual(<<"FwMQZpbIMqrGkmB3HjNLir4FcKSBExAKaHVQJi4dd/TzAFicCQGLFcPcKJSX0uIp5KHSpuN2B5JjTvTdtstj7cVgAlHyWZkYhOg0tsK3QG706FwcpcwW9HCyy0UH9TxaBZ8+Iip81Ntt3eK8DJZPaTI04dBlXOz3xkrhUZWm8MgIABlAxNkRD+xBQTEfDqyXbXKjjUHVRoeB2r3DDhYVnUAQoXf7DHzBmz70q3Q3eMD0cXhuwrsIQVXMFb90qQgMiAzB8fvjMuGFy0EXhNUc8edVes3oNa5fkHoPxMfyLjNMao7isWx7wGq8rWwwTXI9Fv0KrEdosAgIW9+0lNZAog==">>
    , sign(pg_up_protocol_req_collect, <<"abc">>, <<"5.1.0">>, <<"898319849000017">>)),
  ok.
