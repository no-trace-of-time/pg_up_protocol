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

-compile(export_all).

setup() ->
  lager:start(),


  application:start(up_config),
  pg_test_utils:setup(mnesia),

  pg_repo:drop(?M_R),
  pg_repo:init(?M_R),

  ok.

my_test_() ->
  {
    setup
    , fun setup/0
    ,
    {
      inorder,
      [
        fun sign_test_1/0
        , fun get_test_1/0
        , fun save_test_1/0
%%      ,  fun verify_test_1/0
      ]
    }
  }.

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
  ].

pk() ->
  {<<"898319849000018">>, <<"20170206160227">>, <<"20170206160227544228896">>}.

protocol() ->
  pg_protocol:out_2_in(?M_P, qs()).

protocol(req) ->
  pg_protocol:out_2_in(?M_P_REQ, qs(req)).


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


