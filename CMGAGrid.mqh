#include <ChartObjects\ChartObjectsShapes.mqh>
#include <ChartObjects\ChartObjectsLines.mqh>
#include "Include\DKStdLib\TradingManager\CDKTrade.mqh"
#include "Include\DKStdLib\TradingManager\CDKSymbolInfo.mqh"
#include "CMGATrackedPos.mqh"

class CMGAGrid : public CObject {
protected:
  CDKLogger*                  Logger;
  CMGABotInputs               Inputs;
  CDKTrade                    Trade;
  CDKSymbolInfo               Sym;
  
  string                      ID;
  ENUM_POSITION_TYPE          Dir;
  CMGATrackedPos*             OriginalPos;   
  CMGATrackedPos              GridMainPos;
  CMGATrackedPos              GridHedgePos;  
  int                         GridStep;
  double                      GridProfit;
public:
  void                        CMGAGrid::~CMGAGrid() { delete OriginalPos; };
  
 
  void                        CMGAGrid::Init(CMGABotInputs& _inputs, CDKTrade& _trade, CDKLogger* _logger) { Inputs = _inputs; Trade = _trade; Logger = _logger; GridStep = 0; GridProfit = 0.0; };
  
  SBotRetCode<ENUM_RETCODE>   CMGAGrid::Start(CMGATrackedPos*& _init_pos);
  SBotRetCode<ENUM_RETCODE>   CMGAGrid::NextStep();
  SBotRetCode<ENUM_RETCODE>   CMGAGrid::ClosePos(CMGATrackedPos*& _pos);
  
  bool                        CMGAGrid::OpenMainPos(CMGATrackedPos*& _from_pos, const double _lot);
  bool                        CMGAGrid::OpenHedgePos(CMGATrackedPos*& _from_pos, const double _lot);
  
  string                      CMGAGrid::GetID() { return ID; };
  int                         CMGAGrid::GetGridStep() { return GridStep; };
  CMGATrackedPos*             CMGAGrid::GetOriginalPos() { return OriginalPos; };
  CMGATrackedPos*             CMGAGrid::GetMainPos() { return GetPointer(GridMainPos); };
  CMGATrackedPos*             CMGAGrid::GetHedgePos() { return GetPointer(GridHedgePos); };
  
  void                        CMGAGrid::Draw();
};

//+------------------------------------------------------------------+
//| Start Grid
//+------------------------------------------------------------------+
SBotRetCode<ENUM_RETCODE> CMGAGrid::Start(CMGATrackedPos*& _init_pos) {
  OriginalPos = _init_pos;
  Dir = OriginalPos.Type;
  Sym.Name(OriginalPos.Sym);
  ID = StringFormat("%s_%s%I64u", Sym.Name(), PositionTypeToString(Dir, true), OriginalPos.PositionID);
  GridStep = 1;
  GridProfit = _init_pos.ProfitOut;
  
  bool main_open_res = OpenMainPos(OriginalPos, OriginalPos.VolumeIn*Inputs.SET_LOT_RAT);
  if(!main_open_res)
    SBOTRETCODE_RETURN_IAL(BRC_GRIDSTEP_MAIN_OPEN_ERROR, 
                           StringFormat("GID=%s; STEP=%d; RET_CODE=%d; RES_MSG='%s'", 
                                        ID, GridStep, 
                                        Trade.ResultRetcode(),
                                        Trade.ResultRetcodeDescription()), 
                           Logger);      
  
  bool hedge_open_res = OpenHedgePos(OriginalPos, OriginalPos.VolumeIn*Inputs.SET_LOT_RAT);
  if(!hedge_open_res)  
    SBOTRETCODE_RETURN_IAL(BRC_GRIDSTEP_HEDGE_OPEN_ERROR, 
                           StringFormat("GID=%s; STEP=%d; RET_CODE=%d; RES_MSG='%s'", 
                                        ID, GridStep, 
                                        Trade.ResultRetcode(),
                                        Trade.ResultRetcodeDescription()), 
                           Logger);      
                           
  SBOTRETCODE_RETURN_IAL(BRC_GRIDSTEP_OK, 
                         StringFormat("GID=%s; STEP=%d; MAIN_TICKET=%I64u; HEDGE_TICKET=%I64u", 
                                      ID, GridStep, GridMainPos.PositionID, GridHedgePos.PositionID), 
                         Logger);      
}

//+------------------------------------------------------------------+
//| Next Grid Step
//+------------------------------------------------------------------+
SBotRetCode<ENUM_RETCODE> CMGAGrid::NextStep() {
  if(GridMainPos.IsActive())
    SBOTRETCODE_RETURN_IAL(BRC_GRIDSTEP_SKIP_POS_IS_ACTIVE, 
                           StringFormat("GID=%s; STEP=%d; MAIN_TICKET=%I64u; HEDGE_TICKET=%I64u", 
                                        ID, GridStep, GridMainPos.PositionID, GridHedgePos.PositionID), 
                           Logger);      
  
  if(!GridMainPos.Refresh())
    SBOTRETCODE_RETURN_IAL(BRC_GRIDSTEP_REFRESH_MAIN_ERROR, 
                           StringFormat("GID=%s; STEP=%d; MAIN_TICKET=%I64u; HEDGE_TICKET=%I64u", 
                                        ID, GridStep, GridMainPos.PositionID, GridHedgePos.PositionID), 
                           Logger);      

  if(GridMainPos.ProfitOut > 0.0)
    SBOTRETCODE_RETURN_IAL(BRC_GRIDSTEP_STOP_MAIN_GOT_PROFIT, 
                           StringFormat("GID=%s; STEP=%d; MAIN_TICKET=%I64u; HEDGE_TICKET=%I64u; MAIN_PROFIT=%0.2f", 
                                        ID, GridStep, GridMainPos.PositionID, GridHedgePos.PositionID, GridMainPos.ProfitOut), 
                           Logger);          
  
  GridStep++;
  
  double new_lot_rat = (GridHedgePos.GetProfit() <= 0.0) ? Inputs.SET_LOT_RAT : 1.0;
  double new_lot = new_lot_rat;
  LSF_DEBUG(StringFormat("GID=%s; STEP=%d; LOT_RAT=%.10g; LOT=%s", 
                         ID, GridStep, new_lot_rat, Sym.LotFormat(new_lot)));
  
  CMGATrackedPos* pos = GetPointer(GridMainPos);
  bool main_open_res = OpenMainPos(pos, new_lot);
  if(!main_open_res)
    SBOTRETCODE_RETURN_IAL(BRC_GRIDSTEP_MAIN_OPEN_ERROR, 
                           StringFormat("GID=%s; STEP=%d; RET_CODE=%d; RES_MSG='%s'", 
                                        ID, GridStep, 
                                        Trade.ResultRetcode(),
                                        Trade.ResultRetcodeDescription()), 
                           Logger);      
                           
  pos = GetPointer(GridHedgePos);
  bool hedge_open_res = OpenHedgePos(pos, new_lot);
  if(!hedge_open_res)  
    SBOTRETCODE_RETURN_IAL(BRC_GRIDSTEP_HEDGE_OPEN_ERROR, 
                           StringFormat("GID=%s; STEP=%d; RET_CODE=%d; RES_MSG='%s'", 
                                        ID, GridStep, 
                                        Trade.ResultRetcode(),
                                        Trade.ResultRetcodeDescription()), 
                           Logger);      
                           
  SBOTRETCODE_RETURN_IAL(BRC_GRIDSTEP_OK, 
                         StringFormat("GID=%s; STEP=%d; MAIN_TICKET=%I64u; HEDGE_TICKET=%I64u", 
                                      ID, GridStep, GridMainPos.PositionID, GridHedgePos.PositionID), 
                         Logger); 
}

//+------------------------------------------------------------------+
//| Close pos
//+------------------------------------------------------------------+
SBotRetCode<ENUM_RETCODE> CMGAGrid::ClosePos(CMGATrackedPos*& _pos) {
  CDKPositionInfo pos;
  if(!pos.SelectByTicket(_pos.PositionID))
    SBOTRETCODE_RETURN_IAL(BRC_GRIDPOSCLOSE_SKIP_NO_POS_IN_MARKET, 
                           StringFormat("GID=%s; STEP=%d; TICKET=%I64u", 
                                        ID, GridStep, _pos.PositionID), 
                           Logger);                              
  
  if(!Trade.PositionClose(_pos.PositionID))
    SBOTRETCODE_RETURN_IAL(BRC_GRIDPOSCLOSE_TRADE_ERROR, 
                           StringFormat("GID=%s; STEP=%d; TICKET=%I64u; RET_CODE=%d; RET_MSG='%s'", 
                                        ID, GridStep, _pos.PositionID,
                                        Trade.ResultRetcode(),
                                        Trade.ResultRetcodeDescription()
                                        ), 
                           Logger);     
                           
  SBOTRETCODE_RETURN_IAL(BRC_GRIDPOSCLOSE_OK, 
                         StringFormat("GID=%s; STEP=%d; TICKET=%I64u", 
                                      ID, GridStep, _pos.PositionID), 
                         Logger);                            
}

//+------------------------------------------------------------------+
//| Open Main pos
//+------------------------------------------------------------------+
bool CMGAGrid::OpenMainPos(CMGATrackedPos*& _from_pos, const double _lot) {
  double lot     = Sym.NormalizeLot(_lot);
  double ep      = Sym.GetPriceToOpen(Dir);
  double sl_dist = MathAbs(_from_pos.PriceInAvg - _from_pos.SLIn);
  double sl      = Sym.AddToPrice(Dir, ep, -1*sl_dist);
  double tp      = Sym.AddToPrice(Dir, ep, +1*sl_dist*Inputs.SET_MTP_RRD);
  string comment = StringFormat("%s:M_%s:1", Inputs._MS_EGP, ID);
  
  // Main pos
  
  GridMainPos.PositionID = Trade.PositionOpenMarket(Dir, lot, Sym.Name(), 0.0, sl, tp, comment);
  if(GridMainPos.PositionID > 0) {
    GridMainPos.LoadFromHistoryPos(GridMainPos.PositionID);  
    return true;
  }
  
  return false;
}

//+------------------------------------------------------------------+
//| Open hedge pos
//+------------------------------------------------------------------+
bool CMGAGrid::OpenHedgePos(CMGATrackedPos*& _from_pos, const double _lot) {
  ENUM_POSITION_TYPE dir_hedge = (Dir == POSITION_TYPE_BUY) ? POSITION_TYPE_SELL : POSITION_TYPE_BUY;
  double lot     = Sym.NormalizeLot(_lot);
  double ep      = GridMainPos.PriceInAvg;
  double tp      = GridMainPos.SLIn;
  double sl_dist = MathAbs(GridMainPos.PriceInAvg-GridMainPos.SLIn);
  double sl      = Sym.AddToPrice(dir_hedge, ep, -1*sl_dist*Inputs.SET_HSL_RAT);
  string comment = StringFormat("%s:H_%s:1", Inputs._MS_EGP, ID);
  
  // Hedge pos
  GridHedgePos.PositionID = Trade.PositionOpenMarket(dir_hedge, lot, Sym.Name(), 0.0, sl, tp, comment);
  
  if(GridHedgePos.PositionID > 0) {
    GridHedgePos.LoadFromHistoryPos(GridHedgePos.PositionID);
    return true;
  }
  
  return false;
}

//+------------------------------------------------------------------+
//| Draw current grid state
//+------------------------------------------------------------------+
void CMGAGrid::Draw() {
  if(!Inputs._GRH_POS_ENB) return;
  if(Symbol() != Sym.Name()) return;

  datetime dt_fr = GridMainPos.TimeIn;
  datetime dt_to = TimeCurrent();
  dt_to = (dt_fr == dt_to) ? dt_fr+PeriodSeconds(Period()) : dt_to;
  
  // 01. MAIN POS SL
  CChartObjectRectangle rec_sl;
  string rec_sl_name = StringFormat("%s_M_SL_%s_%d", Inputs._MS_EGP, ID, GridStep);
  rec_sl.Create(0, rec_sl_name, 0,
                dt_fr, GridMainPos.PriceInAvg,
                dt_to, GridMainPos.SLIn);
  rec_sl.Description(rec_sl_name);
  rec_sl.Background(true);
  rec_sl.Fill(Inputs._GRH_POS_FIL);
  rec_sl.Color(Inputs._GRH_POS_SLC);
  rec_sl.Detach();
  
  // 02. MAIN POS TP
  CChartObjectRectangle rec_tp;
  string rec_tp_name = StringFormat("%s_M_TP_%s_%d", Inputs._MS_EGP, ID, GridStep);
  rec_tp.Create(0, rec_tp_name, 0,
                dt_fr, GridMainPos.PriceInAvg,
                dt_to, GridMainPos.TPIn);
  rec_tp.Description(rec_tp_name);
  rec_tp.Background(true);
  rec_tp.Fill(Inputs._GRH_POS_FIL);
  rec_tp.Color(Inputs._GRH_POS_TPC);
  rec_tp.Detach();
  
  // 03. HEDGE POS SL
  CChartObjectTrend line_sl;
  string line_sl_name = StringFormat("%s_H_SL_%s_%d", Inputs._MS_EGP, ID, GridStep);
  line_sl.Create(0, line_sl_name, 0,
                dt_fr, GridHedgePos.SLIn,
                dt_to, GridHedgePos.SLIn);
  line_sl.Description(line_sl_name);
  line_sl.Background(false);
  line_sl.Color(Inputs._GRH_HED_SLC);
  line_sl.Width(Inputs._GRH_HED_WTH);
  line_sl.Detach();  
  
  // 03. HEDGE POS TP
  CChartObjectTrend line_tp;
  string line_tp_name = StringFormat("%s_H_TP_%s_%d", Inputs._MS_EGP, ID, GridStep);
  line_tp.Create(0, line_tp_name, 0,
                dt_fr, GridHedgePos.TPIn,
                dt_to, GridHedgePos.TPIn);
  line_tp.Description(line_tp_name);
  line_tp.Background(false);
  line_tp.Color(Inputs._GRH_HED_TPC);
  line_tp.Width(Inputs._GRH_HED_WTH);
  line_tp.Detach();      
}