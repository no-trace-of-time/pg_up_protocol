%%%-------------------------------------------------------------------
%%% @author simon
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. Dec 2016 8:17 PM
%%%-------------------------------------------------------------------
-module(pg_up_protocol_t_repo_mchants_pt).
-compile({parse_trans, exprecs}).
-behavior(pg_repo).
-author("simon").

%% API
%% callbacks
-export([
  table_config/0
]).

-compile(export_all).
%%-------------------------------------------------------------
-define(TBL, mchants).

-record(?TBL, {
  id = 0
  , mcht_full_name = <<"">>
  , mcht_short_name = <<"">>
  , status = normal
  , payment_method = [gw_netbank]
  , sign_method = rsa_hex
  , up_mcht_id = <<"">>
  , quota = [{txn, -1}, {daily, -1}, {monthly, -1}]
  , up_term_no = <<"12345678">>
  , update_ts = erlang:timestamp()
}).
-type ?TBL() :: #?TBL{}.
-export_type([?TBL/0]).

-export_records([?TBL]).
%%-------------------------------------------------------------
%% call backs
table_config() ->
  #{
    table_indexes => [mcht_full_name]
    , data_init => []
    , pk_is_sequence => true
    , pk_key_name => id
    , pk_type => integer

    , unique_index_name => mcht_full_name
    , query_option =>
  #{
    mcht_full_name => within
    , mcht_short_name => within
    , payment_method => member
  }

  }.

