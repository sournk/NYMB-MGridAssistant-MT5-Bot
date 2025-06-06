//+------------------------------------------------------------------+
//|                                                      CMGABot.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+

// #todo 1. Clean imports
// #todo 2. Delete unused Includes

//#include <Generic\HashMap.mqh>
//#include <Arrays\ArrayString.mqh>
//#include <Arrays\ArrayObj.mqh>
//#include <Arrays\ArrayDouble.mqh>
//#include <Arrays\ArrayLong.mqh>
//#include <Trade\TerminalInfo.mqh>
//#include <Trade\DealInfo.mqh>
//#include <Trade\OrderInfo.mqh>
//#include <Charts\Chart.mqh>
//#include <Math\Stat\Math.mqh>


//#include <ChartObjects\ChartObjectsShapes.mqh>
//#include <ChartObjects\ChartObjectsLines.mqh>
//#include <ChartObjects\ChartObjectsArrows.mqh> 

//#include "Include\MarketBook\MarketBook.mqh"
//#include "Include\DBWrapper\Database.mqh"

//#include "Include\DKStdLib\Analysis\DKChartAnalysis.mqh"
//#include "Include\DKStdLib\Analysis\DKBarPatterns.mqh"
// #include "Include\DKStdLib\Common\DKNumPy.mqh"
//#include "Include\DKStdLib\Common\CDKBarTag.mqh"

//#include "Include\DKStdLib\Common\CDKString.mqh"
//#include "Include\DKStdLib\Logger\CDKLogger.mqh"
//#include "Include\DKStdLib\TradingManager\CDKPositionInfo.mqh"
//#include "Include\DKStdLib\TradingManager\CDKTrade.mqh"
//#include "Include\DKStdLib\TradingManager\CDKTSLStep.mqh"
//#include "Include\DKStdLib\TradingManager\CDKTSLStepSpread.mqh"
//#include "Include\DKStdLib\TradingManager\CDKTSLFibo.mqh"
//#include "Include\DKStdLib\TradingManager\CDKTSLPriceChannel.mqh"
//#include "Include\DKStdLib\TradingManager\CDKTSLBE.mqh"
//#include "Include\DKStdLib\Drawing\DKChartDraw.mqh"
//#include "Include\DKStdLib\History\DKHistory.mqh"

//#include "Include\DKStdLib\Common\CDKString.mqh"
//#include "Include\DKStdLib\Common\DKDatetime.mqh"
//#include "Include\DKStdLib\Arrays\CDKArrayString.mqh"
#include "Include\DKStdLib\Bot\CDKBaseBot.mqh"

#include "CMGAInputs.mqh"



enum ENUM_RETCODE {
  BRC_MOCK_NO_TRADE_ERROR                = +1004,
  BRC_MOCK_OK                            = -1003,
  
  BRC_GRIDSTEP_SKIP_POS_IS_ACTIVE        = +2001,
  BRC_GRIDSTEP_REFRESH_MAIN_ERROR        = +2014,
  BRC_GRIDSTEP_MAIN_OPEN_ERROR           = +2024,
  BRC_GRIDSTEP_HEDGE_OPEN_ERROR          = +2034,
  BRC_GRIDSTEP_OK                        = -2003,
  BRC_GRIDSTEP_STOP_MAIN_GOT_PROFIT      = -2013,
  
  BRC_GRIDPOSCLOSE_SKIP_NO_POS_IN_MARKET = +3001,
  BRC_GRIDPOSCLOSE_TRADE_ERROR           = +3014,
  BRC_GRIDPOSCLOSE_OK                    = -3003,
};

#include "CMGAGridList.mqh"


class CMGABot : public CDKBaseBot<CMGABotInputs> {
public: // SETTINGS
  
protected:
  datetime                   MockNextDT;
  CMGAGridList               GridList;
  CArrayString               SymList;
public:
  // Constructor & init
  //void                       CMGABot::CMGABot(void);
  void                       CMGABot::~CMGABot(void);
  void                       CMGABot::InitChild();
  bool                       CMGABot::Check(void);

  // Event Handlers
  void                       CMGABot::OnDeinit(const int reason);
  void                       CMGABot::OnTick(void);
  void                       CMGABot::OnTrade(void);
  void                       CMGABot::OnTimer(void);
  double                     CMGABot::OnTester(void);
  void                       CMGABot::OnBar(CArrayInt& _tf_list);
  void                       CMGABot::OnPositionOpened(ulong _position, ulong _deal);
  void                       CMGABot::OnPositionStopLoss(ulong _position, ulong _deal);
  
  // Bot's logic
  SBotRetCode<ENUM_RETCODE>  CMGABot::MockEnterPos();
  
  void                       CMGABot::SendNotification(const string _msg);
  
  void                       CMGABot::UpdateComment(const bool _ignore_interval = false);
};

//+------------------------------------------------------------------+
//| Destructor
//+------------------------------------------------------------------+
void CMGABot::~CMGABot(void){
}


//+------------------------------------------------------------------+
//| Inits bot
//+------------------------------------------------------------------+
void CMGABot::InitChild() {
  // Put code here
  // vvvvvvvvvvvvv
 
  SymList.Clear();
  CDKString str;
  str.Assign(Inputs.SET_SYM_LST);
  str.Split(";", SymList);
 
  MockNextDT = UpdateDateInMqlDateTime(Inputs._TST_1ST_DT, TimeCurrent(), true);
  
  GridList.Clear();
 
  UpdateComment(true);
}

//+------------------------------------------------------------------+
//| Check bot's params
//+------------------------------------------------------------------+
bool CMGABot::Check(void) {
  if(!CDKBaseBot<CMGABotInputs>::Check())
    return false;
    
  if(!Inputs.InitAndCheck()) {
    Logger.Critical(Inputs.LastErrorMessage, true);
    return false;
  }
  
  // Put your additional checks here
  // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
  
  if(Period() != PERIOD_M1) {
    Logger.Critical("Бот должен быть запущен только на M1", true);
    return false;
  }
  
  if(Inputs._NTF_EML_ENB && TerminalInfoInteger(TERMINAL_EMAIL_ENABLED)) {
    Logger.Critical("Настройте почту 'Tools->Options->Email', чтобы использовать email нотификации");
    return false;
  }
  
  if(Inputs._NTF_PUS_ENB && TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED)) {
    Logger.Critical("Настройте push нотификации 'Tools->Options->Notifications', чтобы их использовать");
    return false;
  }
  
  return true;
}

//+------------------------------------------------------------------+
//| OnDeinit Handler
//+------------------------------------------------------------------+
void CMGABot::OnDeinit(const int reason) {
}

//+------------------------------------------------------------------+
//| OnTick Handler
//+------------------------------------------------------------------+
void CMGABot::OnTick(void) {
  CDKBaseBot<CMGABotInputs>::OnTick(); // Check new bar and show comment
  
  // 01. Channels update
  bool need_update = false;
    
  // 04. Update comment
  if(need_update)
    UpdateComment(true);
}

//+------------------------------------------------------------------+
//| OnBar Handler
//+------------------------------------------------------------------+
void CMGABot::OnBar(CArrayInt& _tf_list) {
  // 01. MOCK ENTER
  if(MQLInfoInteger(MQL_TESTER) && TimeCurrent() >= MockNextDT) {
    MockEnterPos();
    MockNextDT += Inputs._TST_NXT_DEL;    
  }
  
  // 02. PROCCESS GRIDS
  int i = 0;
  while(i<GridList.Total()) {
    CMGAGrid* grid = GridList[i];
    
    SBotRetCode<ENUM_RETCODE> res = grid.NextStep();
    if(res.Code == BRC_GRIDSTEP_STOP_MAIN_GOT_PROFIT) {
      this.SendNotification(StringFormat("TP cетки %s/%d с кодом %s: %s", 
                                         grid.GetID(), grid.GetGridStep(), res.EnumBotRetCodeToString(res.Code), res.Msg));      
      
      // Try to close Hedge pos if it is still in market
      CMGATrackedPos* hedge_pos = grid.GetHedgePos();
      grid.ClosePos(hedge_pos);
      GridList.Delete(i);      
      continue;
    }

    if(res.Code == BRC_GRIDSTEP_OK) 
      this.SendNotification(StringFormat("Новый шаг cетки %s/%d с кодом %s: %s", 
                                         grid.GetID(), grid.GetGridStep(), res.EnumBotRetCodeToString(res.Code), res.Msg));
    if(res.Code > 0 && (res.Code % 10) > 1) 
      this.SendNotification(StringFormat("Ошибка нового шага cетки %s/%d с кодом %s: %s", 
                                         grid.GetID(), grid.GetGridStep(), res.EnumBotRetCodeToString(res.Code), res.Msg));
                                         
    // Main pos had not opened ==> Grid is failed ==> Delete it from list
    if(res.Code == BRC_GRIDSTEP_MAIN_OPEN_ERROR) {
      GridList.Delete(i);      
      continue;
    }
      
    grid.Draw();
    i++;       
  } 
  
  UpdateComment(true);
}

//+------------------------------------------------------------------+
//| OnTrade Handler
//+------------------------------------------------------------------+
void CMGABot::OnPositionOpened(ulong _position, ulong _deal) {
}

//+------------------------------------------------------------------+
//| OnPositionStopLoss Handler
//+------------------------------------------------------------------+
void CMGABot::OnPositionStopLoss(ulong _position, ulong _deal) {
  string closed_deal_sym = HistoryDealGetString(_deal, DEAL_SYMBOL);
  ulong closed_deal_magic = HistoryDealGetInteger(_deal, DEAL_MAGIC);
  
  LSF_DEBUG(StringFormat("POS=%I64u; DEAL=%I64u; DEAL_SYM=%s; SYM_LIST='%s'; DEAL_MAGIC=%I64u; MS_MGC=%I64u",
                         _position, _deal, closed_deal_sym, Inputs.SET_SYM_LST, 
                         closed_deal_magic, Inputs._MS_MGC));
  
  if(SymList.Total() > 0) 
    if(SymList.SearchLinear(closed_deal_sym) < 0)
      return;

  if(closed_deal_magic != Inputs._MS_MGC) {
    // User's pos has closed
    CMGATrackedPos* pos = new CMGATrackedPos();
    pos.SetLogger(GetPointer(Logger));
    if(pos.LoadFromHistoryPos(_position)) {
      LSF_DEBUG(StringFormat("Loaded pos from history: %s", pos.ToString()));
      CMGAGrid* grid = new CMGAGrid();
      grid.Init(Inputs, Trade, GetPointer(Logger));
      grid.Start(pos);
      grid.Draw();
      GridList.Add(grid);
      
      string msg = StringFormat("Старт сетки по SL позиции %s #%I64u %s #%0.2f",
                                pos.Sym, pos.PositionID, PositionTypeToString(pos.Type), pos.VolumeIn);
      this.SendNotification(msg);
    }
  } 
  
  UpdateComment(true);
}

//+------------------------------------------------------------------+
//| OnTrade Handler
//+------------------------------------------------------------------+
void CMGABot::OnTrade(void) {
  CDKBaseBot<CMGABotInputs>::OnTrade();
}

//+------------------------------------------------------------------+
//| OnTimer Handler
//+------------------------------------------------------------------+
void CMGABot::OnTimer(void) {
  CDKBaseBot<CMGABotInputs>::OnTimer();

  UpdateComment(true);  
}

//+------------------------------------------------------------------+
//| OnTester Handler
//+------------------------------------------------------------------+
double CMGABot::OnTester(void) {
  return 0;
}



//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Bot's logic
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Updates comment
//+------------------------------------------------------------------+
void CMGABot::UpdateComment(const bool _ignore_interval = false) {
  ClearComment();
  
  int total = GridList.Total();
  int total_len = StringLen(IntegerToString(total));
  string pos_fmt = "%0" + (string)total_len + "d. %s STEP=%d: #%s @%s SL=%s; TP=%s; 💰=%s";
  if(total > 0)
    AddCommentLine(StringFormat("СТАТУС: СЕТКИ В РАБОТЕ (%d):", total), 0, clrLightGreen);
  else
    AddCommentLine(StringFormat("СТАТУС: ОЖИДАНИЕ SL%s",
                                (Inputs.SET_SYM_LST != "") ? " " + Inputs.SET_SYM_LST : ""), 
                   0, clrLightYellow);
  AddCommentLine(" ");
      
  for(int i=0;i<total;i++) {
    CMGAGrid* grid = GridList[i];
    CMGATrackedPos* original_pos = grid.GetOriginalPos();
    CMGATrackedPos* main_pos = grid.GetMainPos();
    CMGATrackedPos* hedge_pos = grid.GetHedgePos();
    AddCommentLine(StringFormat(pos_fmt,
                                i+1,
                                grid.GetID(),
                                grid.GetGridStep(),
                                (original_pos != NULL) ? Sym.LotFormat(original_pos.VolumeIn) : "N/A",
                                (original_pos != NULL) ? Sym.PriceFormat(original_pos.PriceInAvg) : "N/A", 
                                (original_pos != NULL) ? Sym.PriceFormat(original_pos.SLIn) : "N/A", 
                                (original_pos != NULL) ? Sym.PriceFormat(original_pos.TPIn) : "N/A",
                                (original_pos != NULL) ? DoubleToString(original_pos.ProfitOut, 2) : "N/A"
                                ),
                   0, clrLightBlue);   
    AddCommentLine(StringFormat("%*sM: #%I64u %s @%s SL=%s; TP=%s; 💰=%s", 
                                total_len+2, "",
                                (main_pos != NULL) ? main_pos.PositionID : 0,
                                (main_pos != NULL) ? Sym.LotFormat(main_pos.VolumeIn) : "N/A",
                                (main_pos != NULL) ? Sym.PriceFormat(main_pos.PriceInAvg) : "N/A", 
                                (main_pos != NULL) ? Sym.PriceFormat(main_pos.SLIn) : "N/A", 
                                (main_pos != NULL) ? Sym.PriceFormat(main_pos.TPIn) : "N/A",
                                (main_pos != NULL) ? DoubleToString(main_pos.GetProfit(), 2) : "N/A"
                                ),
                   0, (main_pos.GetProfit() > 0) ? clrLightGreen : clrLightPink);
    AddCommentLine(StringFormat("%*sH: #%I64u %s @%s SL=%s; TP=%s; 💰=%s", 
                                total_len+2, "",
                                (hedge_pos != NULL) ? hedge_pos.PositionID : 0,
                                (hedge_pos != NULL) ? Sym.LotFormat(hedge_pos.VolumeIn) : "N/A",
                                (hedge_pos != NULL) ? Sym.PriceFormat(hedge_pos.PriceInAvg) : "N/A", 
                                (hedge_pos != NULL) ? Sym.PriceFormat(hedge_pos.SLIn) : "N/A", 
                                (hedge_pos != NULL) ? Sym.PriceFormat(hedge_pos.TPIn) : "N/A",
                                (hedge_pos != NULL) ? DoubleToString(hedge_pos.GetProfit(), 2) : "N/A"
                                ),
                   0, (hedge_pos.GetProfit() > 0) ? clrLightGreen : clrLightPink);
  }
  
  ShowComment(_ignore_interval);     
}

//+------------------------------------------------------------------+
//| Mock Enter Pos
//+------------------------------------------------------------------+
SBotRetCode<ENUM_RETCODE> CMGABot::MockEnterPos() {
  double ep = Sym.GetPriceToOpen(Inputs._TST_1ST_DIR);
  double sl = Sym.AddToPrice(Inputs._TST_1ST_DIR, ep, -1*Inputs._TST_1ST_SLD);
  double sl_dist = MathAbs(ep-sl);
  double tp = Sym.AddToPrice(Inputs._TST_1ST_DIR, ep, sl_dist*Inputs._TST_1ST_RR);
  string comment = "MOCK";
  
  Trade.SetExpertMagicNumber(0);
  ulong ticket = Trade.PositionOpenMarket(Inputs._TST_1ST_DIR, Inputs._TST_1ST_LOT, Sym.Name(), 0.0, sl, tp, comment);
  Trade.SetExpertMagicNumber(Inputs._MS_MGC);
  if(ticket <= 0)
    SBOTRETCODE_RETURN_IAL(BRC_MOCK_NO_TRADE_ERROR, 
                           StringFormat("RET_CODE=%d; RET_MSG='%s'", 
                                        Trade.ResultRetcode(),
                                        Trade.ResultRetcodeDescription()),
                           Logger);   

  SBOTRETCODE_RETURN_IAL(BRC_MOCK_OK, 
                         StringFormat("TICKET=%I64u; DIR=%s", ticket, PositionTypeToString(Inputs._TST_1ST_DIR)), 
                         Logger);   
}

//+------------------------------------------------------------------+
//| Send Notification
//+------------------------------------------------------------------+
void CMGABot::SendNotification(const string _msg) {
  if(Inputs._NTF_ALM_ENB) Alert(_msg);
  if(Inputs._NTF_EML_ENB && TerminalInfoInteger(TERMINAL_EMAIL_ENABLED)) 
    SendMail(StringFormat("[%s] MT5 bot alert", Logger.Name), _msg);
  if(Inputs._NTF_PUS_ENB && TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED))
    SendNotification(_msg);
}