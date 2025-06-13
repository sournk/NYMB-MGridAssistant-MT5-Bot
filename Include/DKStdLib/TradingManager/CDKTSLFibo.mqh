//+------------------------------------------------------------------+
//|                                                   CDKTSLFibo.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+
#property copyright "Denis Kislitsyn"
#property link      "https://kislitsyn.me"

#include "CDKTrade.mqh"
#include "CDKTSLBase.mqh"

class CDKTSLFibo : public CDKTSLBase {
private:
  double                    SL;
  double                    TP;
  double                    Fibo[];
  
public:
  void                      CDKTSLFibo::CDKTSLBase();
  void                      CDKTSLFibo::Init(double _sl, double _tp, double& _fibo_arr[]);
  bool                      CDKTSLFibo::Update(CDKTrade& _trade, const bool _update_tp);
};

void CDKTSLFibo::CDKTSLBase() {
  CDKTSLBase::Init(500, 0);
}

void CDKTSLFibo::Init(double _sl, double _tp, double& _fibo_arr[]) {
  SL = _sl; TP = _tp;
  ArrayCopy(Fibo, _fibo_arr);
  
  double fibo_dist = MathAbs(TP-SL) * Fibo[0];
  double fibo_price = AddToPrice(SL, fibo_dist);
  int fibo_price_dist = PriceToPoints(MathAbs(PriceOpen()-fibo_price));
  CDKTSLBase::Init(fibo_price_dist, 0);
}

bool CDKTSLFibo::Update(CDKTrade& _trade, const bool _update_tp) {
  double sl_old = StopLoss();
  double price_activation = (IsPriceGEOpen(sl_old)) ? sl_old : PriceOpen();
  double price_to_close = PriceToClose();
  
  double fibo_price = 0.0;
  int fibo_idx = -1;
  for(int i=0;i<ArraySize(Fibo);i++){
    double fibo_dist = MathAbs(TP-SL) * Fibo[i];
    double price_to_check = AddToPrice(SL, fibo_dist);
    if(IsPriceGE(price_to_close, price_to_check)) {
      fibo_idx = i;
      fibo_price = price_to_check;
    }
    else
      break;
  }
  if(fibo_idx < 0) return false; 
  
  fibo_price = PriceOpen();
  if(fibo_idx > 0) 
    fibo_price = AddToPrice(SL, MathAbs(TP-SL) * Fibo[fibo_idx-1]);    
  
  return CDKTSLBase::UpdateSL(_trade, fibo_price, _update_tp);
}