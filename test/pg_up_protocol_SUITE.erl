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
-define(M_R, pg_up_protocol_t_up_txn_log_pt).

-compile(export_all).

setup() ->
  lager:start(),


  application:start(up_config),
  pg_test_utils:setup(mnesia),

%%  pg_repo:drop(?M_R),
%%  pg_repo:init(?M_R),

  ok.

my_test_() ->
  {
    setup
    , fun setup/0
    ,
    {
      inorder,
      [
        fun verify_test_1/0
%%        , fun sign_test_1/0
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

pk() ->
  {<<"898319849000018">>, <<"20170206160227">>, <<"20170206160227544228896">>}.

protocol() ->
  pg_protocol:out_2_in(?M_P, qs()).


verify_test_1() ->
  ?assertEqual(ok, pg_up_protocol:verify(?M_P, protocol())),
  ok.


