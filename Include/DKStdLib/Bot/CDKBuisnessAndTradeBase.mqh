//+------------------------------------------------------------------+
//|                                                   CDKBaseBot.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//|
//| 2024-10-24:
//|   [+] CDKBuisnessAndTradeBase inits Trader and Logger for all child classes
//+------------------------------------------------------------------+

#include <Object.mqh>

#include "..\Logger\CDKLogger.mqh"
#include "..\TradingManager\CDKTrade.mqh"

template<typename T>
class CDKBuisnessAndTradeBase : public CObject {
protected:
  CDKTrade                 Trade;
  CDKLogger                Logger;
  T                        Inputs;
public:
  void                     CDKBuisnessAndTradeBase::CDKBuisnessAndTradeBase(void) { Logger.Level = NO; };
  void                     CDKBuisnessAndTradeBase::Init(CDKTrade& _trade, CDKLogger&  _logger, const T& _inputs) { 
    Trade = _trade; Logger = _logger; Inputs = _inputs; 
  };
};