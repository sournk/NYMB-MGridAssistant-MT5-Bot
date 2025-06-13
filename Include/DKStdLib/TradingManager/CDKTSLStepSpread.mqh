//+------------------------------------------------------------------+
//|                                             CDKTSLStepSpread.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+
#property copyright "Denis Kislitsyn"
#property link      "https://kislitsyn.me"

#include "CDKTrade.mqh"
#include "CDKTSLBase.mqh"

class CDKTSLStepSpread : public CDKTSLBase {
  int                       ActivationStep;
public:
  void                      CDKTSLStepSpread::CDKTSLBase();
  void                      CDKTSLStepSpread::Init(const int _activation_step_point, const int _sl_distance);
  bool                      CDKTSLStepSpread::Update(CDKTrade& _trade, const bool _update_tp);
  
  bool                      CDKTSLStepSpread::UpdateSL(CDKTrade& _trade, const double _new_sl, const bool _update_tp);
};

void CDKTSLStepSpread::CDKTSLBase() {
  Init(500, 0);
}

void CDKTSLStepSpread::Init(const int _activation_step_point, const int _sl_distance) {
  ActivationStep = _activation_step_point;
  CDKTSLBase::Init(0, _sl_distance);
}

//+------------------------------------------------------------------+
//| Update public methods
//+------------------------------------------------------------------+
bool CDKTSLStepSpread::UpdateSL(CDKTrade& _trade, const double _new_sl, const bool _update_tp) {
  ResRetcode = 0;
  ResRetcodeDescription = "";
  // Activation price is disabled (=0) or AskBid is better
  if (!(PriceActivation <= 0 || IsPriceGT(PriceToClose(), PriceActivation))) {
    ResRetcode = TSL_CUSTOM_RET_CODE_PRICE_ACTIVATION_NOT_REACHED;
    ResRetcodeDescription = "activation price has not reached yet";    
    return false;
  }
  
  double curr_sl = StopLoss();
  SLNew = NormalizeDouble(_new_sl, m_symbol.Digits());
  
  double currTP = TakeProfit();
  TPNew = AddToPrice(PriceToClose(), Distance);
  TPNew = NormalizeDouble(TPNew, m_symbol.Digits());
  
  if (!_update_tp) TPNew = currTP;
  
  if (CompareDouble(SLNew, curr_sl) && CompareDouble(TPNew, currTP)) {
    ResRetcode = TSL_CUSTOM_RET_CODE_PRICE_NOT_BETTER;
    ResRetcodeDescription = "New SL&TP are not changed";        
    return false;
  }
  
  bool res = false;
  // Current price is better than newTP or current price is worst new_sl ->
  // -> close pos immediatly, because it's impossible to set TP or SL
  if ((_update_tp && IsPriceGE(PriceToClose(), TPNew)) || IsPriceLE(PriceToClose(), SLNew))
    res = _trade.PositionClose(Ticket());
  else
    res = _trade.PositionModify(Ticket(), SLNew, TPNew);
    
  ResRetcode = _trade.ResultRetcode();
  ResRetcodeDescription = _trade.ResultRetcodeDescription();

  return res;
}

//+------------------------------------------------------------------+
//| Update
//+------------------------------------------------------------------+
bool CDKTSLStepSpread::Update(CDKTrade& _trade, const bool _update_tp) {
  double sl_old = StopLoss();
  double price_activation = (IsPriceGEOpen(sl_old)) ? sl_old : PriceOpen();
  price_activation = AddToPrice(price_activation, ActivationStep);
  CDKTSLBase::SetActivation(price_activation);
  
  double price_to_close = PriceToClose();
  double sl_new = AddToPrice(price_to_close, -1*GetDistance());
  
  double spread_curr = Spread();
  double spread_open = GetSpreadAtOpenning();
  sl_new = AddToPrice(sl_new, -1*MathMax(spread_curr-spread_open, 0));
    
  return UpdateSL(_trade, sl_new, _update_tp);
}