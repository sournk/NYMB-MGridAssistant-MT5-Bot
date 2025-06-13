//+------------------------------------------------------------------+
//|                                                   CDKBaseBot.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//| ver. 2025-03-11
//|   [+] OnBar(CArrayInt& _tf_list)
//| ver. 2025-02-28
//|   [+] SBotRetCode
//| ver. 2025-01-24
//|   [+] Lincese check from Inputs.__MS_LIC_DUR_SEC
//| ver. 2024-12-06
//|   [*] OnBar executed when ANY TF bar appears
//| ver. 2024-11-11
//|   [+] OnStopLoss, OnTakeProfit,
//| ver. 2024-11-03
//|   [+] Bot can show comment in the window above the chart
//+------------------------------------------------------------------+

#define IS_TRANSACTION_ORDER_PLACED            (trans.type == TRADE_TRANSACTION_REQUEST && request.action == TRADE_ACTION_PENDING && OrderSelect(result.order) && (ENUM_ORDER_STATE)OrderGetInteger(ORDER_STATE) == ORDER_STATE_PLACED)
//#define IS_TRANSACTION_ORDER_MODIFIED          (trans.type == TRADE_TRANSACTION_REQUEST && request.action == TRADE_ACTION_MODIFY && OrderSelect(result.order) && (ENUM_ORDER_STATE)OrderGetInteger(ORDER_STATE) == ORDER_STATE_PLACED)
#define IS_TRANSACTION_ORDER_MODIFIED          (trans.type == TRADE_TRANSACTION_REQUEST && request.action == TRADE_ACTION_MODIFY && OrderSelect(request.order) && (ENUM_ORDER_STATE)OrderGetInteger(ORDER_STATE) == ORDER_STATE_PLACED)
#define IS_TRANSACTION_ORDER_DELETED           (trans.type == TRADE_TRANSACTION_HISTORY_ADD && (trans.order_type >= 2 && trans.order_type < 6) && trans.order_state == ORDER_STATE_CANCELED)
#define IS_TRANSACTION_ORDER_EXPIRED           (trans.type == TRADE_TRANSACTION_HISTORY_ADD && (trans.order_type >= 2 && trans.order_type < 6) && trans.order_state == ORDER_STATE_EXPIRED)
#define IS_TRANSACTION_ORDER_TRIGGERED         (trans.type == TRADE_TRANSACTION_HISTORY_ADD && (trans.order_type >= 2 && trans.order_type < 6) && trans.order_state == ORDER_STATE_FILLED)

#define IS_TRANSACTION_POSITION_OPENED         (trans.type == TRADE_TRANSACTION_DEAL_ADD && HistoryDealSelect(trans.deal) && (ENUM_DEAL_ENTRY)HistoryDealGetInteger(trans.deal, DEAL_ENTRY) == DEAL_ENTRY_IN)
#define IS_TRANSACTION_POSITION_STOP_TAKE      (trans.type == TRADE_TRANSACTION_DEAL_ADD && HistoryDealSelect(trans.deal) && (ENUM_DEAL_ENTRY)HistoryDealGetInteger(trans.deal, DEAL_ENTRY) == DEAL_ENTRY_OUT && (ENUM_DEAL_REASON)HistoryDealGetInteger(trans.deal, DEAL_REASON) == DEAL_REASON_SL)
#define IS_TRANSACTION_POSITION_TAKE_TAKE      (trans.type == TRADE_TRANSACTION_DEAL_ADD && HistoryDealSelect(trans.deal) && (ENUM_DEAL_ENTRY)HistoryDealGetInteger(trans.deal, DEAL_ENTRY) == DEAL_ENTRY_OUT && (ENUM_DEAL_REASON)HistoryDealGetInteger(trans.deal, DEAL_REASON) == DEAL_REASON_TP)
#define IS_TRANSACTION_POSITION_CLOSED         (trans.type == TRADE_TRANSACTION_DEAL_ADD && HistoryDealSelect(trans.deal) && (ENUM_DEAL_ENTRY)HistoryDealGetInteger(trans.deal, DEAL_ENTRY) == DEAL_ENTRY_OUT && ((ENUM_DEAL_REASON)HistoryDealGetInteger(trans.deal, DEAL_REASON) != DEAL_REASON_SL && (ENUM_DEAL_REASON)HistoryDealGetInteger(trans.deal, DEAL_REASON) != DEAL_REASON_TP))
#define IS_TRANSACTION_POSITION_CLOSEBY        (trans.type == TRADE_TRANSACTION_DEAL_ADD && HistoryDealSelect(trans.deal) && (ENUM_DEAL_ENTRY)HistoryDealGetInteger(trans.deal, DEAL_ENTRY) == DEAL_ENTRY_OUT_BY)
#define IS_TRANSACTION_POSITION_MODIFIED       (trans.type == TRADE_TRANSACTION_REQUEST && request.action == TRADE_ACTION_SLTP)


#include <Object.mqh>
#include <Arrays\ArrayLong.mqh>

#include "..\License\DKLicense.mqh"
#include "..\Logger\CDKLogger.mqh"
#include "..\TradingManager\CDKTrade.mqh"
#include "..\TradingManager\CDKPositionInfo.mqh"
#include "..\NewBarDetector\DKNewBarDetector.mqh"
#include "..\Filter\CDKAllowedTime.mqh"
#include "CDKCommentWnd.mqh"

#define FLP __FUNCTION__ + "/" + (string)__LINE__
#define SBOTRETCODE_IAL(_ret_code, _code, _msg, _logger) _ret_code.InitAndLog(_code, \
                                                         (SBotRetCode<ENUM_RETCODE>::LogLevelByBotRetCode(_code) >= _logger.Level) ? _msg : "", \
                                                         FLP, _logger)
#define SBOTRETCODE_RETURN_IAL(_code, _msg, _logger) {SBotRetCode<ENUM_RETCODE> ret_code; \
                                                      return ret_code.InitAndLog(_code, \
                                                                                (SBotRetCode<ENUM_RETCODE>::LogLevelByBotRetCode(_code) >= _logger.Level) ? _msg : "", \
                                                                                FLP, _logger);}

template<typename T_ENUM>
struct SBotRetCode {
  T_ENUM                     Code;
  string                     Msg;

  static string EnumBotRetCodeToString(T_ENUM _ret_code) {
    string str = EnumToString(_ret_code);
    StringReplace(str, "BRC_", "");
   
    return str;
  }  
  
  static LogLevel LogLevelByBotRetCode(T_ENUM _code) {
    int log_level_code = MathAbs(_code % 10);
    if(log_level_code == 1) return DEBUG;
    if(log_level_code == 2) return INFO;
    if(log_level_code == 3) return WARN;
    if(log_level_code == 4) return ERROR;
    if(log_level_code == 5) return CRITICAL;  
    
    return NO;
  }
  
  SBotRetCode Log(CDKLogger& _logger, string _prefix) {
    LogLevel level = LogLevelByBotRetCode(Code);
    
    if(level >= _logger.Level) {
      string msg = StringFormat("%sRES=%s%s", 
                               _prefix != "" ? _prefix + ": " : "",
                               EnumBotRetCodeToString(Code),
                               (Msg != "") ? "; " + Msg : "");
      _logger.Log(msg, level);          
    }
    return this;
  }  
  
  SBotRetCode InitAndLog(T_ENUM _code, string _msg, string _prefix, CDKLogger& _logger) {
    Code = _code;
    Msg = _msg;
    Log(_logger, _prefix);
    return this;
  }  
};

template<typename T>
class CDKBaseBot : public CObject {
 private:
  string                   CommentText;
  string                   CommentFont;
  CArrayLong               Color;
  CArrayLong               BgrColor; 
  
 protected:
  CDKSymbolInfo            Sym;
  ENUM_TIMEFRAMES          TF;
  ulong                    Magic;
  CDKLogger                Logger;
  CDKTrade                 Trade;
  
  T                        Inputs;
  
  CDKAllowedTime           TimeAllowed;

  CDKNewBarDetector        NewBarDetector;
  CArrayInt                NewBarList;

  CArrayLong               Poses;
  CArrayLong               Orders;
  
  bool                     UseCustomComment;
  CDKCommentWnd*           CommentWnd;

 public:
  bool                     TrackPosByMagic;
  bool                     TrackOrdByMagic;
  bool                     TrackPosBySymbol;
  bool                     TrackOrdBySymbol; 
    
  bool                     CommentEnable;
  uint                     CommentIntervalSec;
  datetime                 CommentLastUpdate;
  
  void                     CDKBaseBot::SetFont(const string _font_name);
  void                     CDKBaseBot::SetHighlightSelection(const bool _highlight_selection_flag);

  void                     CDKBaseBot::Init(const string _sym,
                                            const ENUM_TIMEFRAMES _tf,
                                            const ulong _magic,
                                            CDKTrade& _trade,
                                            const bool _use_custom_comment_window,
                                            const T& _inputs,
                                            CDKLogger* _logger = NULL);
  virtual void             CDKBaseBot::InitChild()=NULL;
                                        
  bool                     CDKBaseBot::Check(void);



  // Get all market poses and orders
  void                     CDKBaseBot::LoadMarketPos();
  void                     CDKBaseBot::LoadMarketOrd();
  void                     CDKBaseBot::LoadMarket();
  
  // Pos and orders operation
  bool                     CDKBaseBot::DeleteAllPoses();
  bool                     CDKBaseBot::DeleteAllOrders();
  
  // Comment
  void                     CDKBaseBot::SetComment(const string _comment);
  void                     CDKBaseBot::ClearComment();
  void                     CDKBaseBot::AddCommentLine(const string _str, const color _clr = 0, const color _bgr_clr = 0);
  void                     CDKBaseBot::ShowComment(const bool _ignore_interval = false);

  // Event Handlers
  void                     CDKBaseBot::OnTick(void);
  void                     CDKBaseBot::OnTrade(void);
  void                     CDKBaseBot::OnTimer(void);
  void                     CDKBaseBot::OnChartEvent(const int id,
                                                    const long& lparam,
                                                    const double& dparam,
                                                    const string& sparam);
  void                     CDKBaseBot::OnTradeTransaction(const MqlTradeTransaction &trans, 
                                                          const MqlTradeRequest &request, 
                                                          const MqlTradeResult &result);

  virtual void             CDKBaseBot::OnBar(CArrayInt& _tf_list)=NULL;                                                          
  virtual void             CDKBaseBot::OnOrderPlaced(ulong _order) {}
  virtual void             CDKBaseBot::OnOrderModified(ulong _order) {}
  virtual void             CDKBaseBot::OnOrderDeleted(ulong _order) {}
  virtual void             CDKBaseBot::OnOrderExpired(ulong _order) {}
  virtual void             CDKBaseBot::OnOrderTriggered(ulong _order) {}

  virtual void             CDKBaseBot::OnPositionOpened(ulong _position, ulong _deal) {}
  virtual void             CDKBaseBot::OnPositionStopLoss(ulong _position, ulong _deal) {}
  virtual void             CDKBaseBot::OnPositionTakeProfit(ulong _position, ulong _deal) {}
  virtual void             CDKBaseBot::OnPositionClosed(ulong _position, ulong _deal) {}
  virtual void             CDKBaseBot::OnPositionCloseBy(ulong _position, ulong _deal){}
  virtual void             CDKBaseBot::OnPositionModified(ulong _position) {}

  void                     CDKBaseBot::CDKBaseBot(void);
  void                     CDKBaseBot::~CDKBaseBot(void);
};


//+------------------------------------------------------------------+
//| Set comment text
//| To show comment is using ShowComment func
//+------------------------------------------------------------------+
template<typename T>
void CDKBaseBot::SetComment(const string _comment){
  ClearComment();
  CommentText = _comment;
} 

//+------------------------------------------------------------------+
//| Clear comment text
//+------------------------------------------------------------------+
template<typename T>
void CDKBaseBot::ClearComment() {
  CommentText = "";
  Color.Clear();
  BgrColor.Clear();
}

//+------------------------------------------------------------------+
//| Clear comment text
//+------------------------------------------------------------------+
template<typename T>
void CDKBaseBot::AddCommentLine(const string _str, const color _clr = 0, const color _bgr_clr = 0) {
  string sep = (CommentText != "") ? "\n" : "";
  CommentText += sep +_str;
  
  if(UseCustomComment) {
    Color.Add(_clr);
    BgrColor.Add(_bgr_clr);
  }
}

//+------------------------------------------------------------------+
//| Update current grid status
//+------------------------------------------------------------------+
template<typename T>
void CDKBaseBot::ShowComment(const bool _ignore_interval = false) {
  if (!CommentEnable) return;
  if (CommentText == "") return;
  if (!_ignore_interval && TimeCurrent() < CommentLastUpdate+CommentIntervalSec) return; // Wait comment update interval

  if (UseCustomComment)
    CommentWnd.ShowText(CommentText, Color, BgrColor);
  else  
    Comment(CommentText);
    
  CommentLastUpdate = TimeCurrent();
}

//+------------------------------------------------------------------+
//| Constructor   
//+------------------------------------------------------------------+
template<typename T>
void CDKBaseBot::CDKBaseBot(void) {
  Logger.Init("CDKBaseBot", NO);
  UseCustomComment = false;
}

//+------------------------------------------------------------------+
//| Destructor    
//+------------------------------------------------------------------+
template<typename T>
void CDKBaseBot::~CDKBaseBot(void) {
  if(CommentWnd != NULL) {
    CommentWnd.Destroy(0);
    delete CommentWnd;
  }
}

//+------------------------------------------------------------------+
//| Set Comment Font Name
//+------------------------------------------------------------------+
template<typename T>
void CDKBaseBot::SetFont(const string _font_name) {
  if(UseCustomComment)
    CommentWnd.SetFont(_font_name);
}

//+------------------------------------------------------------------+
//| Set Comment HighlightSelection
//+------------------------------------------------------------------+
template<typename T>
void CDKBaseBot::SetHighlightSelection(const bool _highlight_selection_flag) {
  if(UseCustomComment)
    CommentWnd.SetHighlightSelection(_highlight_selection_flag);  
}

//+------------------------------------------------------------------+
//| Init Bot
//+------------------------------------------------------------------+
template<typename T>
void CDKBaseBot::Init(const string _sym,
                      const ENUM_TIMEFRAMES _tf,
                      const ulong _magic,
                      CDKTrade& _trade,
                      const bool _use_custom_comment_window,
                      const T& _inputs,
                      CDKLogger* _logger = NULL) {
  MathSrand(GetTickCount());

  if (_logger != NULL) Logger = _logger; // Set custom logger

  Sym.Name(_sym);
  TF = _tf;
  Magic = _magic;
  
  TrackPosByMagic = true;
  TrackOrdByMagic = true;
  
  TrackPosBySymbol = true;
  TrackOrdBySymbol = true;
  
  Trade = _trade;
  Trade.SetExpertMagicNumber(Magic);
  
  Inputs = _inputs;
  
  TimeAllowed.ClearIntervalsAll();
  
  CommentText = "";
  CommentIntervalSec = 1*60; // 1 min
  CommentLastUpdate = 0;
  CommentEnable = true;
  if ((MQLInfoInteger(MQL_TESTER) && !MQLInfoInteger(MQL_VISUAL_MODE)) || MQLInfoInteger(MQL_OPTIMIZATION)) CommentEnable = false;
  
  // Create custom comment dialog
  UseCustomComment = (CommentEnable) ? _use_custom_comment_window : false;
  if(UseCustomComment && CommentWnd == NULL) {
    CommentWnd = new CDKCommentWnd();
    if(!CommentWnd.Create(0, 
                          StringFormat("%s %I64u", Logger.Name, Inputs._MS_MGC),
                          0, 80, 80, 600, 530))
      return;
    CommentWnd.Run();   
  }
  
  // Bar detector init
  NewBarDetector.AddTimeFrame(TF);
  NewBarDetector.ResetAllLastBarTime();
  
  LoadMarket();
  
  InitChild();
}

//+------------------------------------------------------------------+
//| Check bot's params
//+------------------------------------------------------------------+
template<typename T>
bool CDKBaseBot::Check(void) {
  bool res = true;
  //// Проверим режим счета. Нужeн ОБЯЗАТЕЛЬНО ХЕДЖИНГОВЫЙ счет
  //CAccountInfo acc;
  //if(acc.MarginMode() != ACCOUNT_MARGIN_MODE_RETAIL_HEDGING) {
  //  Logger.Error("Only hedging mode allowed", true);
  //  res = false;
  //}

  if(CheckExpiredAndShowMessage(Inputs.__MS_LIC_DUR_SEC)) 
    res = false;

  if(!Sym.Name(Symbol())) {
    Logger.Error(StringFormat("Symbol %s is not available", Symbol()), true);
    res = false;
  }
  
  return res;
}

//+------------------------------------------------------------------+
//| Loads pos from market
//+------------------------------------------------------------------+
template<typename T>
void CDKBaseBot::LoadMarketPos() {
  Poses.Clear();

  CDKPositionInfo pos;
  for (int i=0; i<PositionsTotal(); i++) {
    if (!pos.SelectByIndex(i)) continue;
    if (TrackPosByMagic && pos.Magic() != Magic) continue;
    if (TrackPosBySymbol && pos.Symbol() != Sym.Name()) continue;

    Poses.Add(pos.Ticket());
  }
}

//+------------------------------------------------------------------+
//| Loads orders from market
//+------------------------------------------------------------------+
template<typename T>
void CDKBaseBot::LoadMarketOrd() {
  Orders.Clear();

  COrderInfo order;
  for (int i=0; i<OrdersTotal(); i++) {
    if (!order.SelectByIndex(i)) continue;
    if (TrackOrdByMagic && order.Magic() != Magic) continue;
    if (TrackOrdBySymbol && order.Symbol() != Sym.Name()) continue;

    Orders.Add(order.Ticket());
  }
}

//+------------------------------------------------------------------+
//| Loads market poses and orders
//+------------------------------------------------------------------+
template<typename T>
void CDKBaseBot::LoadMarket() {
  LoadMarketPos();
  LoadMarketOrd();
}

//+------------------------------------------------------------------+
//| Delete all poses
//+------------------------------------------------------------------+
template<typename T>
bool CDKBaseBot::DeleteAllPoses() {
  int del_cnt = 0;
  for(int i=0;i<Poses.Total();i++) {
    bool del_res = Trade.PositionClose(Poses.At(i));
    LSF_ASSERT(del_res, 
               StringFormat("POS=%d/%d; TICKET=%I64u; RET_CODE=%d; RET_MSG='%s'",
                            i+1, Poses.Total(), Poses.At(i), 
                            Trade.ResultRetcode(), Trade.ResultRetcodeDescription()),
               WARN,
               ERROR);
    if(del_res) del_cnt++;
  }
  
  return del_cnt == Poses.Total();
}

//+------------------------------------------------------------------+
//| Delete all orders
//+------------------------------------------------------------------+
template<typename T>
bool CDKBaseBot::DeleteAllOrders() {
  int del_cnt = 0;
  for(int i=0;i<Orders.Total();i++) {
    bool del_res = Trade.OrderDelete(Orders.At(i));
    LSF_ASSERT(del_res, 
               StringFormat("ORDER=%d/%d; TICKET=%I64u; RET_CODE=%d; RET_MSG='%s'",
                            i+1, Orders.Total(), Orders.At(i), 
                            Trade.ResultRetcode(), Trade.ResultRetcodeDescription()),
               WARN,
               ERROR);
    if(del_res) del_cnt++;
  }
  
  return del_cnt == Orders.Total();
}

//+------------------------------------------------------------------+
//| OnTick Handler
//+------------------------------------------------------------------+
template<typename T>
void CDKBaseBot::OnTick(void) {
  CArrayInt BarList;
  if(NewBarDetector.CheckNewBarAvaliable(BarList)) {
    NewBarList = BarList;
    if(DEBUG >= Logger.Level) 
      for(int i=0;i<NewBarList.Total();i++) 
        Logger.Debug(StringFormat("%s/%d: New bar detected: TF=%s",
                                  __FUNCTION__, __LINE__,
                                  TimeframeToString((ENUM_TIMEFRAMES)NewBarList.At(i))));
    OnBar(BarList);
  }

  if(UseCustomComment)
    CommentWnd.OnTick(); 

  ShowComment();
}


//+------------------------------------------------------------------+
//| OnTrade Handler
//+------------------------------------------------------------------+
template<typename T>
void CDKBaseBot::OnTrade(void) {
  LoadMarket();
  ShowComment();
}

//+------------------------------------------------------------------+
//| OnTimer Handler
//+------------------------------------------------------------------+
template<typename T>
void CDKBaseBot::OnTimer(void) {
  ShowComment();
}

//+------------------------------------------------------------------+
//| OnChartEvent Handler
//+------------------------------------------------------------------+
template<typename T>
void CDKBaseBot::OnChartEvent(const int id,         // event ID  
                              const long& lparam,   // event parameter of the long type
                              const double& dparam, // event parameter of the double type
                              const string& sparam) { // event parameter of the string type
  if(!UseCustomComment) return;
  
  CommentWnd.ChartEvent(id,lparam,dparam,sparam);
}

//+------------------------------------------------------------------+
//| OnTradeTransaction Handler
//+------------------------------------------------------------------+
template<typename T>
void CDKBaseBot::OnTradeTransaction(const MqlTradeTransaction &trans, 
                                    const MqlTradeRequest &request,
                                    const MqlTradeResult &result) {
  if(IS_TRANSACTION_ORDER_PLACED)
    OnOrderPlaced(result.order);
  
  else if(IS_TRANSACTION_ORDER_MODIFIED) {
    OnOrderModified(request.order);
  }
  
  else if(IS_TRANSACTION_ORDER_DELETED) {
    OnOrderDeleted(trans.order);
  }
  
  else if(IS_TRANSACTION_ORDER_EXPIRED) {
    OnOrderExpired(trans.order);
  }
  
  else if(IS_TRANSACTION_ORDER_TRIGGERED) {
    OnOrderTriggered(trans.order);
  }
  
  else if(IS_TRANSACTION_POSITION_OPENED) {
    OnPositionOpened(trans.position,trans.deal);
  }
  
  else if(IS_TRANSACTION_POSITION_STOP_TAKE) {
    OnPositionStopLoss(trans.position,trans.deal);
  }
    
  else if(IS_TRANSACTION_POSITION_TAKE_TAKE) {
    OnPositionTakeProfit(trans.position,trans.deal);
  }    
  
  else if(IS_TRANSACTION_POSITION_CLOSED) {
    OnPositionClosed(trans.position,trans.deal);
  }
  
  else if(IS_TRANSACTION_POSITION_CLOSEBY) {
    OnPositionCloseBy(trans.position,trans.deal);
  }    
  
  else if(IS_TRANSACTION_POSITION_MODIFIED) {
    OnPositionModified(request.position);    
  }                                
}


  // https://www.mql5.com/en/forum/73900/page2
  //if (HistoryDealSelect(trans.deal)) {
  //   ENUM_DEAL_ENTRY deal_entry = (ENUM_DEAL_ENTRY) HistoryDealGetInteger(trans.deal, DEAL_ENTRY);
  //   ENUM_DEAL_REASON deal_reason = (ENUM_DEAL_REASON) HistoryDealGetInteger(trans.deal, DEAL_REASON);
  //   if(EnumToString(deal_entry) == "DEAL_ENTRY_IN")
  //      {
  //         if(EnumToString(deal_reason) == "DEAL_REASON_EXPERT" && EnumToString(trans.deal_type) == "DEAL_TYPE_BUY")
  //            {
  //               Alert("Buy");
  //            }
  //         else if(EnumToString(deal_reason) == "DEAL_REASON_EXPERT" && EnumToString(trans.deal_type) == "DEAL_TYPE_SELL")
  //            {
  //               Alert("Sell");
  //            }
  //      }
  //   else if(EnumToString(deal_entry) == "DEAL_ENTRY_OUT")
  //      {
  //         if(EnumToString(deal_reason) == "DEAL_REASON_SL" && EnumToString(trans.deal_type) == "DEAL_TYPE_BUY")
  //            {
  //               Alert("Sell SL");
  //            }
  //         else if(EnumToString(deal_reason) == "DEAL_REASON_SL" && EnumToString(trans.deal_type) == "DEAL_TYPE_SELL")
  //            {
  //               Alert("Buy SL");
  //            }
  //         else if(EnumToString(deal_reason) == "DEAL_REASON_TP" && EnumToString(trans.deal_type) == "DEAL_TYPE_BUY")
  //            {
  //               Alert("Sell TP");
  //            }
  //         else if(EnumToString(deal_reason) == "DEAL_REASON_TP" && EnumToString(trans.deal_type) == "DEAL_TYPE_SELL")
  //            {
  //               Alert("Buy TP");
  //            }               
  //    } 
  //}  
