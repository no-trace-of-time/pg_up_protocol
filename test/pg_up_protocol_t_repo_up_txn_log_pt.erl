%%%-------------------------------------------------------------------
%%% @author simon
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. Jan 2017 1:43 PM
%%%-------------------------------------------------------------------
-module(pg_up_protocol_t_repo_up_txn_log_pt).
-compile({parse_trans, exprecs}).
-behavior(pg_repo).
-author("simon").

%%-define(BH, behaviour_repo).
%% API
%% callbacks
-export([
  table_config/0
]).

-compile(export_all).
%%-------------------------------------------------------------
-define(TBL, up_txn_log).


-type txn_type() :: pay |refund|gws_up_query.
-type status() :: success |waiting |fail.
-type txn_amt() :: non_neg_integer().

-export_type([txn_type/0, status/0, txn_amt/0]).

-record(?TBL, {
  mcht_index_key
  %% mcht req related

  % 考虑支付/退货两种交易的支持,先考虑支付
  , txn_type :: txn_type()

  , up_merId
  , up_txnTime
  , up_orderId
  , up_txnAmt :: txn_amt()
  , up_reqReserved
  , up_orderDesc
  , up_issInsCode
  , up_index_key


%% unionpay resp related

  , up_queryId
  , up_respCode
  , up_respMsg
  , up_settleAmt
  , up_settleDate :: binary()
  , up_traceNo
  , up_traceTime

  , up_query_index_key
  %% mcht resp related
  , txn_status
  , up_accNo
  , up_consumerInfo

  , up_idType
  , up_idNo
  , up_idName
  , up_mobile

  , up_batchNo
  , up_totalQty
  , up_fileContent
}).

-type ?TBL() :: #?TBL{}.
-export_type([?TBL/0]).

-export_records([?TBL]).
%%-------------------------------------------------------------
%% call backs
table_config() ->
  #{
    table_indexes => [up_index_key, up_settleDate]
    , data_init => []
    , pk_is_sequence => false
    , pk_key_name => mcht_index_key
    , pk_type => tuple

    , unique_index_name => up_index_key
    , query_option =>
  #{
    up_txnAmt => integer_equal
  }

  }.
