//+------------------------------------------------------------------+
//|                                                      CMGABot.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+

// #todo 1. Clean imports
// #todo 1. Delete unused Includes

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
  BRC_DB_CREATE_TABLE_EXISTS             = +1001,
  BRC_DB_CREATE_TABLE_ERROR              = +1014,  
  BRC_DB_CREATE_TABLE_OK                 = -1003,

  BRC_DB_SAVE_ERROR_NOT_AVALIABLE        = +2004,
  BRC_DB_SAVE_ERROR_EMPTY_MARKETBOOK     = +2013,
  BRC_DB_SAVE_ERROR_BOOKINFO             = +2024,
  BRC_DB_SAVE_OK                         = -2002,
};


class CMGABot : public CDKBaseBot<CMGABotInputs> {
public: // SETTINGS
  
protected:
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
  
  // Bot's logic
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

}

//+------------------------------------------------------------------+
//| OnTrade Handler
//+------------------------------------------------------------------+
void CMGABot::OnPositionOpened(ulong _position, ulong _deal) {
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
  
  //AddCommentLine(StringFormat("WORST LOT/SLIPPAGE since %s:", TimeToString(StartDT)), 0, clrLightPink);
  
  ShowComment(_ignore_interval);     
}

////+------------------------------------------------------------------+
////| Save MarketBook to DB
////+------------------------------------------------------------------+
//SBotRetCode<ENUM_RETCODE> CMGABot::SaveMarketBookToDB() {
//  // 01. CHECK DB
//  if(!DB.IsAvaliable()) 
//    SBOTRETCODE_RETURN_IAL(BRC_DB_SAVE_ERROR_NOT_AVALIABLE, 
//                           StringFormat("FILE=%s", DBFilename),
//                           Logger);   
//                 
//  SBOTRETCODE_RETURN_IAL(BRC_DB_SAVE_OK, StringFormat("DT=%s; MB_DEPTH=%d", SQLiteTimeStr(dt_curr), total), Logger);   
//}
//
