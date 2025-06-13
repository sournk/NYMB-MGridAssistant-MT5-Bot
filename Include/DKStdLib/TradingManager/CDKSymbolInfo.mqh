//+------------------------------------------------------------------+
//|                                                CDKSymbolInfo.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//| 2025-03-22:
//|   [+] LotFormat
//| 2025-03-08:
//|   [+] CopyRatesAsSeries, GetRatesAsSeries, CopyAndGetRatesAsSeries
//| 2025-02-24:
//|   [+] GetTickSizeDigits()
//| 2024-06-26:
//|   [+] AddPrice() funcs
//|
//| 2024-11-08:
//|   [+] double Spread()
//|   [+] GetSpreadAt() func
//| 2024-11-29:
//|   [*] double Spread() renamed to SpreadDouble
//+------------------------------------------------------------------+
#property copyright "Denis Kislitsyn"
#property link      "https://kislitsyn.me"

#include <Trade\SymbolInfo.mqh>
#include "..\Common\DKStdLib.mqh"

class CDKSymbolInfo : public CSymbolInfo {
private:
  MqlRates            Rates[];
  double              GetMockValue(const string _name);
public:
  void                CDKSymbolInfo();
  void                ~CDKSymbolInfo();

  int                 PriceToPoints(const double aPrice);                              // Convert aPrice to price value for current Symbol
  double              PointsToPrice(const int aPoint);                                 // Convert aPoint to points for current Symbol
  
  string              PriceFormat(const double _price);                                // Format price with sym digits "%0.[Digits]f"
  string              LotFormat(const double _lot);                                    // Format Lot with sym digits "%0.[LotStep]f"
  
  double              GetPriceToOpen(const ENUM_POSITION_TYPE aPositionDirection);     // Returns market price Ask or Bid to OPEN new pos with aPositionDirection dir
  double              GetPriceToClose(const ENUM_POSITION_TYPE aPositionDirection);    // Returns market price Ask or Bid to CLOSE new pos with aPositionDirection dir
  
  double              AddToPrice(const ENUM_POSITION_TYPE _dir, double _price_base, const double _price_addition);
  double              AddToPrice(const ENUM_POSITION_TYPE _dir, const double _price_base, const int _distance_addition);
  
  double              NormalizeLot(double lot, const bool _floor = true);              // Returns normalized lots size for symbol
  
  double              Ask();
  void                AskMockSet(const double _value);
  void                AskMockRemove();
  
  double              Bid();
  void                BidMockSet(const double _value);
  void                BidMockRemove();
  
  void                MockTimeSet(const datetime _dt, const ENUM_SERIESMODE _series_mode);
  void                MockTimeRemove();
  
  void                MockRemoveAll();
  
  double              SpreadDouble();
  double              GetSpreadAt(const ulong _ms);
  
  int                 TickSizeDigits();
  
  int                 CopyRatesAsSeries(ENUM_TIMEFRAMES  timeframe,
                                        int              start_pos,
                                        int              count);
  MqlRates            GetRateCache(const int _idx);
  int                 GetRatesArray(MqlRates& _rates[]);
  MqlRates            GetRate(ENUM_TIMEFRAMES  timeframe,
                              const int        _idx);
};

void CDKSymbolInfo::CDKSymbolInfo() {
  ArraySetAsSeries(Rates, true);
  MockRemoveAll();
}

void CDKSymbolInfo::~CDKSymbolInfo() {
  MockRemoveAll();
}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Price Operations
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Convert aPrice to price value for current Symbol                 |
//+------------------------------------------------------------------+
int CDKSymbolInfo::PriceToPoints(const double aPrice) {
  CSymbolInfo::RefreshRates();
  
  return((int)(aPrice * MathPow(10, Digits())));
}

//+------------------------------------------------------------------+
//| Convert aPoint to points for current Symbol                      |
//+------------------------------------------------------------------+
double CDKSymbolInfo::PointsToPrice(const int aPoint) {
  CSymbolInfo::RefreshRates();
  
  return(NormalizeDouble(aPoint * this.Point(), this.Digits()));
}


//+------------------------------------------------------------------+
//| Make price format with Sym digits
//+------------------------------------------------------------------+
string CDKSymbolInfo::PriceFormat(const double _price) {
  string fmt = "%0." + IntegerToString(this.Digits()) + "f";
  return StringFormat(fmt, _price);
}

//+------------------------------------------------------------------+
//| Make Lot format with Sym.LotStep
//+------------------------------------------------------------------+
string CDKSymbolInfo::LotFormat(const double _lot) {
   double lot_step = LotsStep();
   
   // Определяем количество знаков после запятой в LotStep
   int decimal_places = 0;
   while (lot_step < 1.0) {
      lot_step *= 10;
      decimal_places++;
   }
   
   // Форматируем строку в зависимости от количества знаков
   string format_string = "";
   if (decimal_places > 0)
      format_string = StringFormat("%%.%df", decimal_places);
   else
      format_string = "%.0f";
   
   return StringFormat(format_string, _lot);
}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Market Price Operations
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

double CDKSymbolInfo::GetPriceToOpen(const ENUM_POSITION_TYPE aPositionDirection) {
  CSymbolInfo::RefreshRates();
  
  if (aPositionDirection == POSITION_TYPE_BUY)  return Ask();
  if (aPositionDirection == POSITION_TYPE_SELL) return Bid();
  return 0;   
}

double CDKSymbolInfo::GetPriceToClose(const ENUM_POSITION_TYPE aPositionDirection) {
  CSymbolInfo::RefreshRates();
  
  if (aPositionDirection == POSITION_TYPE_BUY)  return Bid();
  if (aPositionDirection == POSITION_TYPE_SELL) return Ask();
  return 0;   
}

double CDKSymbolInfo::AddToPrice(const ENUM_POSITION_TYPE _dir, double _price_base, const double _price_addition) {
  return _price_base + GetPosDirSign(_dir)*_price_addition;
}

double CDKSymbolInfo::AddToPrice(const ENUM_POSITION_TYPE _dir, const double _price_base, const int _distance_addition) {
  return AddToPrice(_dir, _price_base, PointsToPrice(_distance_addition));
}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Lots Size Operations
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

double CDKSymbolInfo::NormalizeLot(double lot, const bool _floor = true) {
  CSymbolInfo::RefreshRates();
  
  lot =  NormalizeDouble(lot, Digits());
  double lotStep = LotsStep();
  if (_floor) return floor(lot / lotStep) * lotStep;
  return round(lot / lotStep) * lotStep;
}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Market data can be mocked by global variable for testing
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

double CDKSymbolInfo::GetMockValue(const string _name) {
  if (GlobalVariableCheck(_name)) {
    double global_value = GlobalVariableGet(_name);
    if (global_value > 0) return global_value;
  }
  
  if (GlobalVariableCheck("CDKSymbolInfo::MockTime_dt")) {
    datetime dt = (datetime)GlobalVariableGet("CDKSymbolInfo::MockTime_dt");
    int mode = (ENUM_SERIESMODE)GlobalVariableGet("CDKSymbolInfo::MockTime_series_mode");
    
    int bar_shift = iBarShift(Name(), PERIOD_M1, dt);
    if (mode == MODE_OPEN)  return iOpen(Name(),  PERIOD_M1, bar_shift);
    if (mode == MODE_CLOSE) return iClose(Name(), PERIOD_M1, bar_shift);
    if (mode == MODE_HIGH)  return iHigh(Name(),  PERIOD_M1, bar_shift);
    if (mode == MODE_LOW)   return iLow(Name(),   PERIOD_M1, bar_shift);
  }
  
  return 0;
}

double CDKSymbolInfo::Ask() {
  double global_value = GetMockValue("CDKSymbolInfo::Ask");
  if (global_value > 0) return global_value;
  
  return CSymbolInfo::Ask();      
}

void CDKSymbolInfo::AskMockSet(const double _value) {
  GlobalVariableSet("CDKSymbolInfo::Ask", _value);  
}

void CDKSymbolInfo::AskMockRemove() {
  GlobalVariableDel("CDKSymbolInfo::Ask");
}

double CDKSymbolInfo::Bid() {
  double global_value = GetMockValue("CDKSymbolInfo::Bid");
  if (global_value > 0) return global_value;
  
  return CSymbolInfo::Bid();      
}

void CDKSymbolInfo::BidMockSet(const double _value) {
  GlobalVariableSet("CDKSymbolInfo::Bid", _value);  
}

void CDKSymbolInfo::BidMockRemove() {
  GlobalVariableDel("CDKSymbolInfo::Bid");
}

void CDKSymbolInfo::MockRemoveAll() {
  AskMockRemove();
  BidMockRemove();
  
  MockTimeRemove();
}

void CDKSymbolInfo::MockTimeSet(const datetime _dt, const ENUM_SERIESMODE _series_mode) {
  GlobalVariableSet("CDKSymbolInfo::MockTime_dt", _dt); 
  GlobalVariableSet("CDKSymbolInfo::MockTime_series_mode", _series_mode);
}

void CDKSymbolInfo::MockTimeRemove() {
  GlobalVariableDel("CDKSymbolInfo::MockTime_dt");
  GlobalVariableDel("CDKSymbolInfo::MockTime_series_mode");
}

double CDKSymbolInfo::SpreadDouble(){
  CSymbolInfo::RefreshRates();
  return Ask()-Bid();
}

double CDKSymbolInfo::GetSpreadAt(const ulong _ms) {
  MqlTick ticks[];
  if(CopyTicks(Symbol(), ticks, COPY_TICKS_BID && COPY_TICKS_ASK, _ms, 1) < 1)
    return DBL_MAX;
  
  return ticks[0].ask - ticks[0].bid;
}

int CDKSymbolInfo::TickSizeDigits() {
  double tick_size = TickSize();
  int digits = 0;
  while (tick_size < 1.0 && digits < 10) { // Ограничиваем до 100 знаков на всякий случай
    tick_size *= 10;
    digits++;
  }
  return digits;
}

int CDKSymbolInfo::CopyRatesAsSeries(ENUM_TIMEFRAMES  timeframe,
                                     int              start_pos,
                                     int              count) {
  return CopyRates(Name(), timeframe, start_pos, count, Rates);
}

MqlRates CDKSymbolInfo::GetRateCache(const int _idx) {
  if(_idx <= (ArraySize(Rates)-1))
    return Rates[_idx];
    
  MqlRates rate;
  rate.time = 0;
  return rate;
}

int CDKSymbolInfo::GetRatesArray(MqlRates& _rates[]) {
  ArrayCopy(_rates, Rates);
  return ArraySize(_rates);
}

MqlRates CDKSymbolInfo::GetRate(ENUM_TIMEFRAMES  timeframe,
                                const int        _idx) {
  MqlRates mql_rates[];
  if(CopyRates(Name(), timeframe, _idx, 1, mql_rates)>=1)
    return mql_rates[0];
    
  MqlRates mql_rate;
  mql_rate.time = 0;
  return mql_rate;    
}

