%%%-------------------------------------------------------------------
%%% @author simonxu
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. Apr 2016 09:48
%%%-------------------------------------------------------------------
-author("simonxu").
-include("./type_binaries.hrl").

-type version() :: byte5().        % NS5
-type encoding() :: byte5().      % UTF-8
-type certId() :: bytes().    % N1..128
-type signature() :: bytes().  % ANS1..1024
-type signMethod() :: byte2().    % N2:01
-type txnType() :: byte2().        % N2
-type txnSubType() :: byte2().    % N2
-type bizType() :: byte6().        % N6
-type channelType() :: byte2().    % N2
-type url() :: bytes().      % ANS1..256
-type accessType() :: byte1().      % N1
-type merId() :: byte15().        % AN15
-type subMerId() :: any().      % AN5..15
-type subMerName() :: any().    % ANS1..40
-type subMerAbbr() :: any().    % ANS1..16
-type orderId() :: byte8_up().      % AN8..32
-type txnTime() :: byte14().      % YYYYMMDDhhmmss
-type accType() :: byte2().        % N2
-type accNo() :: binary().          % AN1..512
-type txnAmt() :: non_neg_integer().
-type currencyCode() :: byte3().    % N3
-type customerInfo() :: any().
-type orderTimeout() :: any().
-type payTimeout() :: any().
-type termId() :: byte8().          % AN8
-type reqReserved() :: bytes().
-type reserved() :: any().
-type riskRateInfo() :: any().
-type encryptCertId() :: binary().
-type frontFailUrl() :: any().
-type instalTransInfo() :: any().
-type defaultPayType() :: byte4().    % N4
-type issInsCode() :: any().        % AN1..20
-type supPayType() :: any().
-type userMac() :: any().
-type customerIp() :: any().
-type cardTransData() :: any().
-type orderDesc() :: any().

-type batchNo() :: byte4().     %% 0001 - 9999
-type totalQty() :: non_neg_integer().
-type totalAmt() :: non_neg_integer().
-type fileContent() :: binary().

%% reply & inform packet
-type respCode() :: byte2().
-type respMsg() :: any().
-type queryId() :: any().
-type settleAmt() :: non_neg_integer().
-type settleCurrencyCode() :: any().
-type settleDate() :: byte4().
-type traceNo() :: any().
-type traceTime() :: any().

%% inform packet
-type exchangeDate() :: any().
-type exchangeRate() :: any().
-type payCardNo() :: any().
-type payCardType() :: binary().
-type payCardIssueName() :: any().
-type bindId() :: any().


-type issuerIndentifyMode() :: byte1().


%% file transfer
-type file_transfer_type() :: byte2().

-type signPubKeyCert() :: binary().

-type mcht_index_key() :: {binary(), binary(), binary()}.

-export_type([
  version/0
  , encoding/0
  , certId/0
  , signature/0
  , signMethod/0
  , txnType/0
  , txnSubType/0
  , bizType/0
  , channelType/0
  , url/0
  , accessType/0
  , merId/0
  , subMerId/0
  , subMerName/0
  , subMerAbbr/0
  , orderId/0
  , txnTime/0
  , accType/0
  , accNo/0
  , txnAmt/0
  , currencyCode/0
  , customerInfo/0
  , orderTimeout/0
  , payTimeout/0
  , termId/0
  , reqReserved/0
  , reserved/0
  , riskRateInfo/0
  , encryptCertId/0
  , frontFailUrl/0
  , instalTransInfo/0
  , defaultPayType/0
  , issInsCode/0
  , supPayType/0
  , userMac/0
  , customerIp/0
  , cardTransData/0
  , orderDesc/0
  , respCode/0
  , respMsg/0
  , queryId/0
  , settleAmt/0
  , settleCurrencyCode/0
  , settleDate/0
  , traceNo/0
  , traceTime/0
  , exchangeDate/0
  , exchangeRate/0
  , payCardNo/0
  , payCardIssueName/0
  , bindId/0
  , file_transfer_type/0
  , batchNo/0
  , totalQty/0
  , totalAmt/0
  , fileContent/0
  , payCardType/0
  , signPubKeyCert/0
  , mcht_index_key/0
]).

-define(UP_VERSION, <<"5.0.0">>).
-define(UP_ENCODING, <<"UTF-8">>).
-define(UP_SIGNMETHOD, <<"01">>).
-define(UP_TXNTYPE_FILE_TRANSFTER, <<"76">>).
-define(UP_TXNSUBTYPE_RECONCILE_FILE_DOWNLOAD, <<"01">>).
-define(UP_BIZTYPE_FILE_TRASNFER, <<"000000">>).
-define(UP_ACCESSTYPE_NORMAL, <<"0">>).
-define(UP_FILETYPE_NORMAL, <<"00">>).

