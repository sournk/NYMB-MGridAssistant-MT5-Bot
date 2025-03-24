#include <Arrays\ArrayObj.mqh>

#include "Include\DKStdLib\TradingManager\CDKPositionInfo.mqh"

class CMGATrackedPos : public CObject {
public:
  string                    Sym;
  ulong                     PositionID;
  ENUM_POSITION_TYPE        Type;
  
  datetime                  TimeIn;
  
  ulong                     DealInID;
  ulong                     DealOutID;
  
  double                    VolumeIn;
  double                    SumIn;
  double                    PriceInAvg;
  
  double                    SLIn;
  double                    TPIn;
  
  double                    ProfitOut;
  
  void                      CMGATrackedPos::CMGATrackedPos():
                                            Sym(""),
                                            PositionID(0),
                                            TimeIn(0),
                                            
                                            DealInID(0),
                                            DealOutID(0),
                                            
                                            VolumeIn(0.0),
                                            SumIn(0.0),
                                            PriceInAvg(0.0),
                                            
                                            SLIn(0.0),
                                            TPIn(0.0),
                                            
                                            ProfitOut(0.0)
                                            {};
                                            
  bool                      CMGATrackedPos::LoadFromHistoryPos(const ulong _position_id);
  bool                      CMGATrackedPos::Refresh();
  
  bool                      CMGATrackedPos::IsActive();
  double                    CMGATrackedPos::GetProfit();
};

bool CMGATrackedPos::LoadFromHistoryPos(const ulong _position_id) {
  if(!HistorySelectByPosition(_position_id))
    return false;
  
  Sym = "";
  PositionID = _position_id;
  Type = POSITION_TYPE_BUY;
  DealInID = 0;
  DealOutID = 0;
  VolumeIn = 0.0;
  SumIn = 0.0;
  SLIn = 0.0;
  TPIn = 0.0;
  ProfitOut = 0.0;
  for (int i=HistoryDealsTotal()-1;i>=0;i--) {
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
    }
  }
  PriceInAvg = (VolumeIn > 0.0) ? SumIn / VolumeIn : 0.0;

  return true;
}

bool CMGATrackedPos::Refresh() {
  if(PositionID == 0) return false;
  return LoadFromHistoryPos(PositionID);
}

bool CMGATrackedPos::IsActive(){
  CDKPositionInfo pos;
  return pos.SelectByTicket(PositionID);
}

double CMGATrackedPos::GetProfit() {
  CDKPositionInfo pos;
  if(!pos.SelectByTicket(PositionID))  {
    if(ProfitOut <= 0.0) 
      Refresh();
    return ProfitOut;
  }
  
  return pos.Profit();
}