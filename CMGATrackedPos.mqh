#include <Arrays\ArrayObj.mqh>

#include "Include\DKStdLib\TradingManager\CDKPositionInfo.mqh"

class CMGATrackedPos : public CObject {
protected:
  CDKLogger*                Logger;
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
                                            Logger(NULL),
                                            
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
                                            
  void                                                                  
                            CMGATrackedPos::SetLogger(CDKLogger* _logger) { Logger = _logger; }                
  void                      CMGATrackedPos::Init(ulong _id,
                                                 string _sym, 
                                                 ENUM_POSITION_TYPE _dir,
                                                 datetime _time_in,
                                                 ulong _deal_in,
                                                 ulong _deal_out,
                                                 double _vol,
                                                 double _sum,
                                                 double _price_in,
                                                 double _sl_in,
                                                 double _tp_in,
                                                 double _profit);
                                            
  bool                      CMGATrackedPos::LoadFromHistoryPos(const ulong _position_id);
  bool                      CMGATrackedPos::Refresh();
  
  bool                      CMGATrackedPos::IsActive();
  double                    CMGATrackedPos::GetProfit();
  
  string                    CMGATrackedPos::ToString();
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
    
    LSF_DEBUG(StringFormat("i=%d; pos_id=%I64u: deal_id=%I64u; deal_entry=%s; sym=%s",
                           i, _position_id, 
                           deal_id, EnumToString(deal_entry), Sym));
  
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
      
      LSF_DEBUG(StringFormat("i=%d; pos_id=%I64u: DealInID=%I64u; Type=%s; TimeIn=%s; vol_in=%0.10g; price_in=%0.10g; SumIn=%0.10g; VolumeIn=%0.10g; SLIn=%0.10g; TPIn=%0.10g",
                             i, _position_id, 
                             DealInID, EnumToString(Type), TimeToString(TimeIn, TIME_DATE | TIME_MINUTES | TIME_SECONDS),
                             vol_in, price_in, SumIn, VolumeIn,
                             SLIn, TPIn
                             ));      
    }
    
    if(deal_entry == DEAL_ENTRY_OUT) {
      if(DealOutID <= 0) DealOutID = deal_id;
      ProfitOut += HistoryDealGetDouble(deal_id, DEAL_PROFIT);

      if(SLIn <= 0.0) SLIn = HistoryDealGetDouble(deal_id, DEAL_SL);
      if(TPIn <= 0.0) TPIn = HistoryDealGetDouble(deal_id, DEAL_TP);
      
      LSF_DEBUG(StringFormat("i=%d; pos_id=%I64u: DealOutID=%I64u; ProfitOut=%0.10g; SLIn=%0.10g; TPIn=%0.10g",
                             i, _position_id, 
                             DealOutID, ProfitOut, SLIn, TPIn
                             ));      
      
    }
  }
  PriceInAvg = (VolumeIn > 0.0) ? SumIn / VolumeIn : 0.0;
  LSF_DEBUG(StringFormat("PriceInAvg=%0.10g; SumIn=%0.10g; VolumeIn=%0.10g",
                         PriceInAvg, SumIn, VolumeIn));

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
    if(CompareDouble(ProfitOut, 0.0)) 
      Refresh();
    return ProfitOut;
  }
  
  return pos.Profit();
}

string CMGATrackedPos::ToString() {
  return StringFormat("TPOS=%I64u; SYM=%s; DEAL_IN=%I64u; DEAL_OUT=%I64u; VOL=%0.2f; SUM=%0.2f; PRICE_AVG=%0.10g; SL=%0.10g; TP=%0.10g; PROFIT_OUT=%0.2f",
                      PositionID, Sym, DealInID, DealOutID, VolumeIn, SumIn, PriceInAvg, SLIn, TPIn, ProfitOut);
}

void CMGATrackedPos::Init(ulong _id,
                          string _sym, 
                          ENUM_POSITION_TYPE _dir,
                          datetime _time_in,
                          ulong _deal_in,
                          ulong _deal_out,
                          double _vol,
                          double _sum,
                          double _price_in,
                          double _sl_in,
                          double _tp_in,
                          double _profit) {
  PositionID = _id;
  Sym = _sym;
  Type = _dir;
  TimeIn = _time_in;
  DealInID = _deal_in;
  DealOutID = _deal_out;
  VolumeIn = _vol;
  SumIn = _sum;
  PriceInAvg = _price_in;
  SLIn = _sl_in;
  TPIn = _tp_in;
  ProfitOut = _profit;
}