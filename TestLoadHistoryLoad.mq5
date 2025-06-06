//+------------------------------------------------------------------+
//|                                          TestLoadHistoryLoad.mq5 |
//|                                                  Denis Kislitsyn |
//|                               https://kislitsyn.me/personal/algo |
//+------------------------------------------------------------------+
#property copyright "Denis Kislitsyn"
#property link      "https://kislitsyn.me/personal/algo"
#property version   "1.00"

#include "Include\DKStdLib\TradingManager\CDKTrade.mqh"
#include "Include\DKStdLib\TradingManager\CDKSymbolInfo.mqh"

bool LoadFromHistoryPos(const ulong _position_id) {
  if(!HistorySelectByPosition(_position_id))
    return false;
  
  string Sym = "";
  ulong PositionID = _position_id;
  ENUM_POSITION_TYPE Type = POSITION_TYPE_BUY;
  ulong DealInID = 0;
  ulong DealOutID = 0;
  double VolumeIn = 0.0;
  double SumIn = 0.0;
  double SLIn = 0.0;
  double TPIn = 0.0;
  double ProfitOut = 0.0;
  datetime TimeIn = 0;
  
  for(int i=HistoryDealsTotal()-1;i>=0;i--) {
    ulong deal_id = HistoryDealGetTicket(i);
    ENUM_DEAL_ENTRY deal_entry = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(deal_id, DEAL_ENTRY);
    
    if(Sym == "") Sym =  HistoryDealGetString(deal_id, DEAL_SYMBOL);
  
    if(deal_entry == DEAL_ENTRY_IN) {
      if(DealInID <= 0) { 
        DealInID = deal_id;
        Type = ((ENUM_DEAL_TYPE)HistoryDealGetInteger(deal_id, DEAL_TYPE) == DEAL_TYPE_BUY) ? POSITION_TYPE_BUY : POSITION_TYPE_SELL;
        TimeIn = (datetime)HistoryDealGetInteger(deal_id, DEAL_TIME);
      }
      double vol_in = HistoryDealGetDouble(deal_id, DEAL_VOLUME);
      double price_in = HistoryDealGetDouble(deal_id, DEAL_PRICE);
      SumIn += vol_in*price_in;
      VolumeIn += vol_in;

      if(SLIn <= 0.0) SLIn = HistoryDealGetDouble(deal_id, DEAL_SL);
      if(TPIn <= 0.0) TPIn = HistoryDealGetDouble(deal_id, DEAL_TP);
    }
    
    if(deal_entry == DEAL_ENTRY_OUT) {
      if(DealOutID <= 0) DealOutID = deal_id;
      ProfitOut += HistoryDealGetDouble(deal_id, DEAL_PROFIT);

      if(SLIn <= 0.0) SLIn = HistoryDealGetDouble(deal_id, DEAL_SL);
      if(TPIn <= 0.0) TPIn = HistoryDealGetDouble(deal_id, DEAL_TP);
    }
  }
  double PriceInAvg = (VolumeIn > 0.0) ? SumIn / VolumeIn : 0.0;

  Print(PositionID);
  Print(VolumeIn);
  Print(SLIn);  
  Print(TPIn); 
  Print(PriceInAvg); 

  return true;
}

void OpenPos() {
  CDKTrade Trade;
  
  CDKSymbolInfo Sym;
  Sym.Name(Symbol());
  Sym.RefreshRates();
  
  double lot     = Sym.NormalizeLot(5);
  string comment = "";
  
  ENUM_POSITION_TYPE Dir = POSITION_TYPE_BUY;
  
  // Main pos
  int attempt_cnt = 1;
  do {
    double ep      = Sym.GetPriceToOpen(Dir);
    double sl_dist = 0.5;
    double sl      = Sym.AddToPrice(Dir, ep, -1*sl_dist);
    double tp      = Sym.AddToPrice(Dir, ep, +1*sl_dist*2);  
  
    ulong PositionID = Trade.PositionOpenMarket(Dir, lot, Sym.Name(), 0.0, sl, tp, comment);
    
    if(PositionID > 0) {
      LoadFromHistoryPos(PositionID);  
      return;
    }
    else
      Sleep(1000);
      
    attempt_cnt++;
  }
  while(attempt_cnt <= 5);
}

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart() {
  OpenPos();
}
