%%%-------------------------------------------------------------------
%%% @author simon
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. 十月 2017 13:23
%%%-------------------------------------------------------------------
-module(pg_up_protocol_SUITE).
-author("simon").
-include_lib("eunit/include/eunit.hrl").

%% API
-export([]).

-define(M_P, pg_up_protocol_t_protocol_up_resp_pay).
-define(M_R, pg_up_protocol_t_repo_up_txn_log_pt).
-define(M_P_REQ, pg_up_protocol_t_protocol_up_req_pay).
-define(M_R_MCHANTS, pg_up_protocol_t_repo_mchants_pt).
-define(M_P_MCHT_REQ, pg_mcht_protocol_req_collect).
-define(APP, pg_up_protocol).

-compile(export_all).



setup() ->
  lager:start(),

  application:start(inets),

  env_init(),

  application:start(up_config),
  application:start(pg_up_protocol),
  pg_test_utils:setup(mnesia),

  env_init(),

  table_init(),
  table_data_init(),


  ok.

env_init() ->
  Cfgs = [
    {pg_up_protocol,
      [
        {mchants_repo_name, pg_up_protocol_t_repo_mchants_pt}
        , {up_repo_name, pg_up_protocol_t_repo_up_txn_log_pt}
        , {debug, true}

      ]
    }
    , {pg_protocol,
      [
        {debug_convert_config, true}
      ]
    }
    , {pg_convert,
      [
        {debug, false}
        , {field_existance_validate, true}

      ]
    }
    , {up_config,
      [
        {up_mer_list,
          [
            {gw_collect, {wap, ['777290058110097']}}
          ]
        }
      ]
    }
  ],


  pg_test_utils:env_init(Cfgs),
  ok.

do_table_init(Table) when is_atom(Table) ->
  pg_repo:drop(Table),
  pg_repo:init(Table),
  ok.

table_init() ->
  [do_table_init(Table) || Table <- [?M_R, ?M_R_MCHANTS]].

do_table_data_init(Table, VL) ->
  R = pg_model:new(Table, VL),
  pg_repo:save(R).

table_data_init() ->
  VLs =
    [
      [
        {id, 1}
        , {mcht_full_name, <<"test1">>}
        , {payment_method, [gw_collect1]}
        , {up_term_no, <<"12345678">>}
      ],
      [
        {id, 2}
        , {mcht_full_name, <<"test2">>}
        , {payment_method, [gw_collect]}
        , {up_term_no, <<"12345670">>}
      ]
    ],

  [do_table_data_init(?M_R_MCHANTS, VL) || VL <- VLs].


%%-------------------------------------------------------------

my_test_() ->
  {
    setup
    , fun setup/0
    ,
    {
      inorder,
      [
        fun repo_data_test_1/0
        , fun pg_up_protocol:sign_aaa_test_1/0
        , fun sign_test_1/0
        , fun get_test_1/0
        , fun save_test_1/0
%%      ,  fun verify_test_1/0
        , fun public_key_test_1/0
        , fun pg_up_protocol_req_collect:mer_id_test_1/0
        , fun pg_up_protocol_req_collect:cert_id_test_1/0
        , fun pg_up_protocol_req_collect:customer_info_test_1/0
%%        , fun mcht_req_test_1/0
        , fun save_req_convert_test_1/0

        , fun send_up_collect_test_1/0
        , fun send_up_collect_256_test_1/0

        , fun send_up_batch_collect_test_1/0

        , fun info_collect_test_1/0

      ]
    }
  }.

%%---------------------------------------------------
repo_data_test_1() ->
  [R] = pg_repo:read(?M_R_MCHANTS, 1),
  ?assertEqual([gw_collect1], pg_model:get(?M_R_MCHANTS, R, payment_method)),
  ok.
%%---------------------------------------------------
qs() ->
  [
    {<<"accessType">>, <<"0">>}
    , {<<"bizType">>, <<"000201">>}
    , {<<"certId">>, <<"69597475696">>}
    , {<<"currencyCode">>, <<"156">>}
    , {<<"encoding">>, <<"UTF-8">>}
    , {<<"merId">>, <<"898319849000018">>}
    , {<<"orderId">>, <<"20170206160227544228896">>}
    , {<<"queryId">>, <<"201702061602278126268">>}
    , {<<"reqReserved">>, <<123, 112, 73, 61, 116, 101, 115, 116, 44, 97, 73, 61, 48, 51, 52, 50, 57, 53, 48, 48, 48, 52, 48, 48, 48, 54, 50, 49, 50, 44, 97, 78, 61, 228, 184, 138, 230, 181, 183, 232, 129, 154, 229, 173, 154, 233, 135, 145, 232, 158, 141, 228, 191, 161, 230, 129, 175, 230, 156, 141, 229, 138, 161, 230, 156, 137, 233, 153, 144, 229, 133, 172, 229, 143, 184, 44, 97, 66, 61, 229, 134, 156, 228, 184, 154, 233, 147, 182, 232, 161, 140, 228, 184, 138, 230, 181, 183, 229, 188, 160, 230, 177, 159, 233, 155, 134, 231, 148, 181, 230, 184, 175, 230, 148, 175, 232, 161, 140, 125>>}
    , {<<"respCode">>, <<"00">>}
    , {<<"respMsg">>, <<"success">>}
    , {<<"settleAmt">>, <<"100">>}
    , {<<"settleCurrencyCode">>, <<"156">>}
    , {<<"settleDate">>, <<"0206">>}
    , {<<"signMethod">>, <<"01">>}
    , {<<"signature">>, <<"TzaoXeacnq+qQrdSQkAGF//n/AWyKbovFtFuMRwxZr+8MeEhC6Jrq9DDhIfuS3Be5NAP679ChfB09CswpH5WQyXmcghOuwWyRS8ihMQ0oT4SEOe3fYf7xTv/TE8O1pGRrHTisiiupEfG+hTfjMnlwBeqzLhyzoOoPWWOteSFTzQEO/DbfMTfZkCRJ6DzGo9JweHAHAak1rrLhIcrNQwoV6WFEoHmMb6rX8VkbOVOY+cYit7/Ats8ojMHUvKpG/bGY/9UFUN028D3y2YlXNp+VsJacEfftE0V5a5pek3U/5zOH7nLvSiiWsqmwbC/rYMv9Yz0Dpmu377TKxoFr63cAQ==">>}
    , {<<"traceNo">>, <<"812626">>}
    , {<<"traceTime">>, <<"0206160227">>}
    , {<<"txnAmt">>, <<"100">>}
    , {<<"txnSubType">>, <<"01">>}
    , {<<"txnTime">>, <<"20170206160227">>}
    , {<<"txnType">>, <<"01">>}
    , {<<"version">>, <<"5.0.0">>}
  ].

qs(req) ->
  [

    {<<"accessType">>, <<"0">>}
    , {<<"backUrl">>, <<"http://tpay.trust-one.com/pg/pay_succ_info">>}
    , {<<"bizType">>, <<"000201">>}
    , {<<"certId">>, <<"69567322249">>}
    , {<<"channelType">>, <<"07">>}
    , {<<"currencyCode">>, <<"156">>}
    , {<<"encoding">>, <<"UTF-8">>}
    , {<<"frontUrl">>, <<"http://tpay.trust-one.com/pg/pay_succ">>}
    , {<<"merId">>, <<"898350249000240">>}
    , {<<"orderId">>, <<"20171020143600141965510">>}
    , {<<"reqReserved">>, <<123, 112, 73, 61, 116, 101, 115, 116, 44, 97, 73, 61, 48, 51, 52, 50, 57, 53, 48, 48, 48, 52, 48, 48, 48, 54, 50, 49, 50, 44, 97, 78, 61, 228, 184, 138, 230, 181, 183, 232, 129, 154, 229, 173, 154, 233, 135, 145, 232, 158, 141, 228, 191, 161, 230, 129, 175, 230, 156, 141, 229, 138, 161, 230, 156, 137, 233, 153, 144, 229, 133, 172, 229, 143, 184, 44, 97, 66, 61, 229, 134, 156, 228, 184, 154, 233, 147, 182, 232, 161, 140, 228, 184, 138, 230, 181, 183, 229, 188, 160, 230, 177, 159, 233, 155, 134, 231, 148, 181, 230, 184, 175, 230, 148, 175, 232, 161, 140, 125>>}
    , {<<"reserved">>, <<"{cardNumberLock=1}">>}
    , {<<"signMethod">>, <<"01">>}
    , {<<"signature">>, <<"f2XYauTilrKRy3FaRlox8jtp3Hig8YmcuDQv9A3JhgW/FyXB/5bcVEOjr81ErACeF76K171UHAHRZLn3PnPBJqrBySsMBy6O2VzUyiARV+IYkCMpNAOmLdTYSYZ4lvU3tZZyNF5Svue3MaAiJEmLxYGV+QtARK6RMnOBlgC2pPs=">>}
    , {<<"termId">>, <<"12345678">>}
    , {<<"txnAmt">>, <<"100">>}
    , {<<"txnSubType">>, <<"01">>}
    , {<<"txnTime">>, <<"20171020143600">>}
    , {<<"txnType">>, <<"01">>}
    , {<<"version">>, <<"5.0.0">>}
  ];

qs(mcht_req) ->
  [
    {<<"tranAmt">>, <<"50">>}
    , {<<"orderDesc">>, <<"测试交易"/utf8>>}
    , {<<"merchId">>, <<"00001">>}
    , {<<"tranId">>, <<"20171021095817473460847">>}
    , {<<"bankCardNo">>, <<"6216261000000000018">>}
    , {<<"tranDate">>, <<"20171021">>}
    , {<<"tranTime">>, <<"095817">>}
    , {<<"signature">>, <<"16808B681094E884DC4EDF3882D59AFA4063D1D58867EAC6E52852F1018E2363A93F5790E2E737411716270A9A04B394294A1F91599C9603DA0EC96EE82B796CF483C94BC4D88C85EB7CE3B0EC9C142D7F512C95B428AF16F870C7458A07A270EE7773BAA44414462D7FAEBC430E59FCAB1AEAC587520D15933EDEC262741A9FE8D7F12DFEB8C87F568F3B9E074103E7731D8713275BA004B18C33F54C4ABB9815B63AF3A2585B4268354E52B19D094D33653771D77949E873A683AD9E9282EC75E8D1DF22F845FCCD9B50F2971072A82026A0D270E78B63C55ED065DE025F472E04B9F24D8F31AE0BE9133E42F029CF18C7128F13770B3F7BEC9DCBC329527B">>}
    , {<<"certifType">>, <<"01">>}
    , {<<"certifId">>, <<"341126197709218366">>}
    , {<<"certifName">>, <<"全渠道"/utf8>>}
%%    , {<<"certifName">>, <<"aaa"/utf8>>}
    , {<<"phoneNo">>, <<"13552535506">>}
    , {<<"trustBackUrl">>, <<"http://localhost:8888/pg/simu_mcht_back_succ_info">>}
  ];
qs(batch_collect) ->
  [
    {<<"tranAmt">>, <<"130000">>}
    , {<<"orderDesc">>, <<"测试交易"/utf8>>}
    , {<<"merchId">>, <<"00001">>}
    , {<<"tranId">>, <<"20171021095817473460847">>}
    , {<<"tranDate">>, <<"20171021">>}
    , {<<"tranTime">>, <<"095817">>}
    , {<<"signature">>, <<"7D2B74AF2BCC3B1C4C1B6FF2328E3C27881FB0497FB0413D4E53801047E1F83CD19CE97B4D9A0C4C7D9BD17B3D9AF4F652536EAA6076E1A1B5D1E7C53A6E3CF1572C8647407BFEF7CD5BBE8ECF210EA495A4335E43A012E4CAF17B6E9FD7813D2E6D44D52B84D823FF8EBD156E10B446E673994DFA1060F1C1D5371DB618439E2FD666BC1E99A49BCC1642A44592292A8942373967E48A51D27C2C5DD8276F679CD30025C3E8ED9F22B004494DFBA2DB0EEA311A5596B6D4B4067CD534A5CFCF61CE1086C6871CE33AF8525E1F2A7B0F8FF33A7D6CF431FB0A309A6441DBF414C7A4F7DF3D1FC2734C40913D566D900B32DA85D01D0583FF0AA69EC326C2E01A">>}
    , {<<"trustBackUrl">>, <<"http://localhost:8888/pg/simu_mcht_back_succ_info">>}
    , {<<"tranCount">>, <<"3">>}
    , {<<"fileContent">>, file_content()}
    , {<<"batchNo">>, <<"0009">>}
    , {<<"reqReserved">>, <<"qqq">>}
  ].

pk() ->
  {<<"898319849000018">>, <<"20170206160227">>, <<"20170206160227544228896">>}.

pk(mcht_req) ->
  {<<"00001">>, <<"20171021">>, <<"20171021095817473460847">>};
pk(batch_collect) ->
  {<<"00001">>, <<"20171111">>, <<"20171021095817473460847">>}.

protocol() ->
  pg_protocol:out_2_in(?M_P, qs()).

protocol(req) ->
  pg_protocol:out_2_in(?M_P_REQ, qs(req));
protocol(mcht_req) ->
  pg_protocol:out_2_in(?M_P_MCHT_REQ, qs(mcht_req));
protocol(mcht_req_batch_collect) ->
  pg_protocol:out_2_in(pg_mcht_protocol_req_batch_collect, qs(batch_collect)).

%%--------------------------------------------------------------------
file_content() ->
  FileName = "DK00000000700000000000001201509110003I.txt",
  FilePathName = code:lib_dir(?APP) ++ "/test/" ++ FileName,
  ?debugFmt("FilePathName = ~p", [FilePathName]),
  {ok, FileContentBin} = file:read_file(FilePathName),
  ?debugFmt("FileContent in ~p = ~p", [FilePathName, FileContentBin]),
  base64:encode(xfutils:deflate(FileContentBin)).


%%---------------------------------------------------
verify_test_1() ->
  ?assertEqual(ok, pg_up_protocol:verify(?M_P, protocol())),
  ok.


get_test_1() ->
  P = protocol(),
  ?assertEqual(pk(), pg_up_protocol:get(?M_P, P, up_index_key)),
  ?assertEqual([<<"812626">>], pg_up_protocol:get(?M_P, P, [traceNo])),
  ?assertEqual([pk(), <<"812626">>], pg_up_protocol:get(?M_P, P, [up_index_key, traceNo])),
  ok.

save_test_1() ->
  ok.

sign_test_1() ->
  P = protocol(),
  ?assertEqual(<<"accessType=0&bizType=000201&certId=69597475696&currencyCode=156&"
  "encoding=UTF-8&merId=898319849000018&orderId=20170206160227544228896"
  "&queryId=201702061602278126268&reqReserved={pI=test,aI=03429500040006212,aN=上海聚孚金融信息服务有限公司,aB=农业银行上海张江集电港支行}"
  "&respCode=00&respMsg=success&settleAmt=100&settleCurrencyCode=156"
  "&settleDate=0206&signMethod=01&traceNo=812626&traceTime=0206160227"
  "&txnAmt=100&txnSubType=01&txnTime=20170206160227&txnType=01&version=5.0.0"/utf8>>,
    pg_up_protocol:sign_string(?M_P, P)),
%%  ?assertEqual(<<"F2LWyMt+dEwX4a4S2FsMv2Xs3Ry7uDlanIRn56GH0YqP8P+Kzz3CQu+JLBCRDM2LqTSH5VgJDWK0LLyxrctR9hyXJqxEVeiGHoOQNj9uvXRrP7QSq219Q64D1CKJfcCmzIinlCx1nUColH7+OLK1r9VuH6s/9BEx4B5NHtH8hag=">>,
%%    pg_model:get(?M_P, P, signature)),

  P_REQ = protocol(req),
  ?assertEqual(<<"accessType=0&backUrl=http://tpay.trust-one.com/pg/pay_succ_info"
  "&bizType=000201&certId=69567322249&channelType=07&currencyCode=156&defaultPayType=0001"
  "&encoding=UTF-8&frontUrl=http://tpay.trust-one.com/pg/pay_succ&merId=898350249000240"
  "&orderId=20171020143600141965510&reqReserved={pI=test,aI=03429500040006212,aN=上海聚孚金融信息服务有限公司,aB=农业银行上海张江集电港支行}"
  "&reserved={cardNumberLock=1}&signMethod=01&termId=12345678&txnAmt=100&txnSubType=01"
  "&txnTime=20171020143600&txnType=01&version=5.0.0"/utf8>>,
    pg_up_protocol:sign_string(?M_P_REQ, P_REQ)),
  ?assertEqual(pg_model:get(?M_P_REQ, P_REQ, signature), pg_up_protocol:sign(?M_P_REQ, P_REQ)),


  ok.


%%---------------------------------------------------
public_key_test_1() ->
  Mer = '898319849000017',
  Exp = {'RSAPublicKey',
    27458097339787492174296826163544949818677781540074993874397459235197367059712882266695236016118958171713550095848280053955490059881751464276841257182491862597598099171365297101417111587696114402806744161243363735267289681167544410706736329605989523324384573658954813224000947195763541373190301782660711382464183525786252700843191085722972372856902043836810872992934524389482477215524672438111072694003952227234062577937094056650876571959033280122979504280902703052628866598163772514185148482193191003949335589824361712747261882707541024948015496439483821044120446095872755086843088053006332772223145255595389325396963,
    65537},
  ?assertEqual(Exp, up_config:get_mer_prop(Mer, publicKey)),

  PrivK = up_config:get_mer_prop(Mer, privateKey),
  Msg = <<"aaa">>,
  Sig = public_key:sign(Msg, 'sha', PrivK),
  ?assertEqual(true, public_key:verify(Msg, 'sha', Sig, Exp)),

  ok.
%%---------------------------------------------------
mcht_req_test_1() ->
  %% mcht_req, without sign
  PMchtReq = protocol(mcht_req),

  %% convert to up
  PUpReq = pg_convert:convert(pg_up_protocol_req_collect, PMchtReq),
  Exp = {pg_up_protocol_req_collect, <<"5.0.0">>, <<"UTF-8">>,
    <<"70481187397">>, <<"0">>, <<"01">>, <<"11">>, <<"00">>,
    <<"000501">>, <<"07">>, <<"0">>, <<"0">>,
    <<"898319849000017">>, <<"0">>, <<"19991212090909">>,
    <<"01">>,
    <<"">>,
    50, <<"156">>,
    <<"e2NlcnRmVHA9MDEmY2VydGlmSWQ9MzQxMTI2MTk3NzA5MjE4MzY2JmN1c3RvbWVyTm095YWo5rig6YGTJnBob25lTm89MTM1NTI1MzU1MDZ9">>,
    <<230, 181, 139, 232, 175, 149, 228, 186, 164, 230, 152, 147>>,
    <<>>,
    {<<"00001">>, <<"20171021">>,
      <<"20171021095817473460847">>},
    <<"01">>, <<"341126197709218366">>,
    <<229, 133, 168, 230, 184, 160, 233, 129, 147>>,
    <<"13552535506">>, <<"6216261000000000018">>
  },
  ?assertEqual(Exp, pg_model:set(pg_up_protocol_req_collect, PUpReq, accNo, <<"">>)),

  %% save up_req_collect
  MRepo = pg_up_protocol:repo_module(up_txn_log),

  ?assertEqual(
    {up_txn_log, {<<"00001">>, <<"20171021">>,
      <<"20171021095817473460847">>},
      collect, <<"898319849000017">>,
      <<"19991212090909">>, <<"0">>, 50,
      <<230, 181, 139, 232, 175, 149, 228, 186, 164, 230, 152, 147>>,
      undefined, undefined,
      {<<"898319849000017">>, <<"19991212090909">>,
        <<"0">>},
      undefined, undefined, undefined, undefined,
      undefined, undefined, undefined, undefined,
      waiting, <<"6216261000000000018">>, undefined,
      <<"01">>, undefined,
      <<229, 133, 168, 230, 184, 160, 233, 129, 147>>,
      <<"13552535506">>}
    , pg_convert:convert(pg_up_protocol_req_collect, PUpReq, save_req)),

  ok = pg_up_protocol:save(pg_up_protocol_req_collect, PUpReq),

  lager:error("Key = ~p", [mnesia:dirty_first(up_txn_log)]),
  io:format("Key = ~p", [mnesia:dirty_first(up_txn_log)]),

  ?assertEqual({<<"00001">>, <<"20171021">>, <<"20171021095817473460847">>}, pk(mcht_req)),
  [Repo] = pg_repo:read(MRepo, pk(mcht_req)),

  ?assertEqual([pk(mcht_req), collect, waiting, <<"898319849000017">>],
    pg_model:get(MRepo, Repo, [mcht_index_key, txn_type, txn_status, up_merId])),


%%    timer:sleep(1000),
  ok.

%%---------------------------------------------------
save_req_convert_test_1() ->
  M = pg_up_protocol_req_collect,
  PUpReq = {M, <<"5.0.0">>, <<"UTF-8">>,
    <<"68759663125">>, <<"0">>, <<"01">>,
    <<"11">>, <<"02">>, <<"000501">>, <<"07">>,
    <<"http://localhost:8888/pg/pay_succ_info">>,
    <<"0">>, <<"777290058110097">>,
    <<"20171103211953426061082">>,
    <<"20171103211953">>, <<"01">>,
    <<"EZS3Ue7Cl9p7+HERXvq8IS7qwX6M2OpIydKdvMJMKM8nXrT1Qqd5TBa8XosCReayPZpkor6s6erQfiy80J3Hp8T3qKEvv49FePxwEJSs08pHHVCBCBBGuTDLE0YLNvr7JRqbWdem3JctcgslBuuzi67K1k4NqM7OzcZZJ0lNf/+20DXcNTt8YjYLrXgehltZev2DyU7rLNup+9dfu9NR4J93qPVmKTJ2XSnTBzfRv0SDW2TqcCD0ttUKv/xChVPm6W05E1Jj/xxj8gSA2q19D9HDCLWWk6nCRnogkC6QkeV1jmTHMH1PgQFeiGtByj6OWMofGTMl6NzITTc6sOS0Fg==">>,
    50, <<"156">>,
    <<"e2NlcnRpZklkPTM0MTEyNjE5NzcwOTIxODM2NiZjZXJ0aWZUcD0wMSZjdXN0b21lck5tPeWFqOa4oOmBkyZlbmNyeXB0ZWRJbmZvPUR4My96Q3BMeStYY3RwK3RzZThqT3pFYlh1NTlISGVXU2NmODBQUDdZU3M0eGJQWDBTNUtUUHl0dVlHOGVjQi8xdzZhQ0I0eXRhekwzcWZQM1FBakl5RVN2L0Zsb0FVZU9SMjRYT3Y1ZUM4VG8xZnc2TlZiWmswUTRzeG1oVFNLeEpSYlNTdHExTStIb2lBUHFyblFndEc5U1dzRms5NEI0STBmRWFsUk5MaGxoZ1ZyMUJIaCtqbmE1WXRQSFE0RXZ2c1h2WUsvVVU2cUxycy8xU1FGekRaUWx3WllZNTY3ekVUbVdpQ0ttci85OUV4T1NiV0xwVW5qMFVlVDZZaERKRXpVaWc4aDhkQlRmNWdqeGVTK2tpTzg4OXdzSWRlR1hNNy9jMktPRUtTMzE0RHZRK3VkWm42Ky84ZE9kVXpVNHVxVHBURXBzQnM0NGlpZXk3U2d5dz09fQ==">>,
    <<230, 181, 139, 232, 175, 149, 228, 186, 164, 230,
      152, 147>>,
    <<>>,
    {<<"00001">>, <<"20171021">>, <<"20171021095817473460847">>},
    <<"01">>, <<"341126197709218366">>,
    <<229, 133, 168, 230, 184, 160, 233, 129, 147>>,
    <<"13552535506">>,
    <<"6216261000000000018">>,
    <<"68759622183">>,
    <<"12345678">>},
  ?debugFmt("PUpReq = ~ts", [pg_model:pr(M, PUpReq)]),
  ?assertEqual({<<"00001">>, <<"20171021">>, <<"20171021095817473460847">>},
    pg_model:get(M, PUpReq, mcht_index_key)),
  RepoUp = pg_convert:convert(M, PUpReq, save_req),
  ?assertEqual([{<<"777290058110097">>, <<"20171103211953">>, <<"20171103211953426061082">>},
    <<"6216261000000000018">>, <<"341126197709218366">>, <<"全渠道"/utf8>>, <<"13552535506">>],
    pg_model:get(pg_up_protocol:repo_module(up_txn_log), RepoUp,
      [up_index_key, up_accNo, up_idNo, up_idName, up_mobile])),

  %% convert to query
  PUpQuery = pg_convert:convert(pg_up_protocol_req_query, RepoUp),
  ?debugFmt("PUpQuery = ~ts", [pg_model:pr(pg_up_protocol_req_query, PUpQuery)]),
  ?assertEqual([<<"777290058110097">>, <<"20171103211953426061082">>],
    pg_model:get(pg_up_protocol_req_query, PUpQuery, [merId, orderId])),
  ok.

%%---------------------------------------------------
send_up_collect_test_1() ->
  PMchtReq = protocol(mcht_req),
  PUpReq = pg_convert:convert(pg_up_protocol_req_collect, PMchtReq),
  Sig = pg_up_protocol:sign(pg_up_protocol_req_collect, PUpReq),
  PUpReqWithSig = pg_model:set(pg_up_protocol_req_collect, PUpReq, signature, Sig),
  ?debugFmt("PUpReqWithSig = ~p", [PUpReqWithSig]),

%%  PostBody = pg_up_protocol:post_string(pg_up_protocol_req_collect, PUpReqWithSig),
  PostBody = pg_up_protocol:in_2_out(pg_up_protocol_req_collect, PUpReqWithSig, post),
  Url = up_config:get_config(up_back_url),

  ?debugFmt("PostString = ~ts,Url = ~p", [PostBody, Url]),

  {ok, {Status, Headers, Body}} = httpc:request(post,
    {binary_to_list(Url), [], "application/x-www-form-urlencoded", iolist_to_binary(PostBody)},
    [], [{body_format, binary}]),
  ?debugFmt("http Statue = ~p~nHeaders  = ~p~nBody=~ts~n", [Status, Headers, Body]),

  %% parse resp
  MResp = pg_up_protocol_resp_collect,
  RespPV = xfutils:parse_post_body(Body),
  ProtocolUpResp = pg_protocol:out_2_in(MResp, RespPV),
  ?debugFmt("ProtocolUpResp = ~ts", [pg_model:pr(MResp, ProtocolUpResp)]),
  ?assertEqual(<<"UTF-8">>, pg_model:get(MResp, ProtocolUpResp, encoding)),
  ?assertNotEqual(nomatch, binary:match(Body, <<"respCode=00">>)),

  timer:sleep(1000),

  ok.


%%---------------------------------------------------------------------------------------
send_up_collect_256_test_1() ->
  PMchtReq = protocol(mcht_req),
  ?debugFmt("PMchtReq = ~p", [PMchtReq]),
  PUpReq = pg_model:set(pg_up_protocol_req_collect,
    pg_convert:convert(pg_up_protocol_req_collect, PMchtReq), version, <<"5.1.0">>),
  Sig = pg_up_protocol:sign(pg_up_protocol_req_collect, PUpReq),
  PUpReqWithSig = pg_model:set(pg_up_protocol_req_collect, PUpReq, signature, Sig),
  ?debugFmt("PUpReqWithSig = ~p", [PUpReqWithSig]),

%%  PostBody = pg_up_protocol:post_string(pg_up_protocol_req_collect, PUpReqWithSig),
  PostBody = pg_up_protocol:in_2_out(pg_up_protocol_req_collect, PUpReqWithSig, post),
  Url = up_config:get_config(up_back_url),

  ?debugFmt("PostString = ~ts,Url = ~p", [PostBody, Url]),

  {ok, {Status, Headers, Body}} = httpc:request(post,
    {binary_to_list(Url), [], "application/x-www-form-urlencoded", iolist_to_binary(PostBody)},
    [], [{body_format, binary}]),
  ?debugFmt("http Statue = ~p~nHeaders  = ~p~nBody=~ts~n", [Status, Headers, Body]),
  ?assertNotEqual(nomatch, binary:match(Body, <<"respCode=00">>)),

  timer:sleep(1000),

  ok.
%%---------------------------------------------------
send_up_batch_collect_test_1() ->
  PMchtReq = protocol(mcht_req_batch_collect),
  PUpReq = pg_convert:convert(pg_up_protocol_req_batch_collect, PMchtReq),
  Sig = pg_up_protocol:sign(pg_up_protocol_req_batch_collect, PUpReq),
  PUpReqWithSig = pg_model:set(pg_up_protocol_req_batch_collect, PUpReq, signature, Sig),
  ?debugFmt("PUpReqWithSig = ~p", [PUpReqWithSig]),

%%  PostBody = pg_up_protocol:post_string(pg_up_protocol_req_collect, PUpReqWithSig),
  PostBody = pg_up_protocol:in_2_out(pg_up_protocol_req_batch_collect, PUpReqWithSig, post),
  Url = up_config:get_config(up_batch_url),

  ?debugFmt("PostString = ~ts,Url = ~p", [PostBody, Url]),

  {ok, {Status, Headers, Body}} = httpc:request(post,
    {binary_to_list(Url), [], "application/x-www-form-urlencoded", iolist_to_binary(PostBody)},
    [], [{body_format, binary}]),
  ?debugFmt("http Statue = ~p~nHeaders  = ~p~nBody=~ts~n", [Status, Headers, Body]),

  %% parse resp
%%  MResp = pg_up_protocol_resp_collect,
%%  RespPV = xfutils:parse_post_body(Body),
%%  ProtocolUpResp = pg_protocol:out_2_in(MResp, RespPV),
%%  ?debugFmt("ProtocolUpResp = ~ts", [pg_model:pr(MResp, ProtocolUpResp)]),
%%  ?assertEqual(<<"UTF-8">>, pg_model:get(MResp, ProtocolUpResp, encoding)),
%%  ?assertNotEqual(nomatch, binary:match(Body, <<"respCode=00">>)),

  timer:sleep(1000),

  ok.
%%---------------------------------------------------
info_collect_test_1() ->
  M = pg_up_protocol_info_collect,
  P = pg_model:new(M, [
    {merId, <<"111">>}
    , {txnTime, <<"20171115104441">>}
    , {orderId, <<"9999">>}
    , {respCode, <<"00">>}
    , {respMsg, <<"succ">>}
    , {settleDate, <<"1115">>}
    , {queryId, <<"qqq">>}
    , {traceNo, <<"traceNo">>}
    , {traceTime, <<"201701011010">>}
  ]),
  VL = pg_convert:convert(M, P),
  ?assertEqual(
    [
      {<<"111">>, <<"20171115104441">>, <<"9999">>}
      , <<"00">>
      , <<"succ">>
      , success
      , <<"20171115">>
      , <<"qqq">>
      , <<"traceNo">>
      , <<"201701011010">>

    ], [proplists:get_value(Key, VL)
      || Key <-
        [up_index_key, up_respCode, up_respMsg, txn_status,
          up_settleDate, up_queryId, up_traceNo, up_traceTime]]
  ),

  ok.

