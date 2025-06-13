//+------------------------------------------------------------------+
//|                                                CDKPriceLevel.mqh |
//|                                                  Denis Kislitsyn |
//|                                               http:/kislitsyn.me |
//|
//| - Define Level by CDKPriceLevel.Start.Init().
//| - Check Level breakout using .FindBreakout() in [Start.Time; Finish.Time]
//| - Check Level hit by ASK/BID
//|
//| Usage:
//| CDKPriceLevel lev;
//| lev.Init(Symbol(), Period(), LEVEL_TYPE_SUPPORT);
//| lev.SetTimeAndValue(dt, price);
//|
//| // Check breakout
//| if (lev.FindBreakout() > 0)
//|   Print(lev.Breakout.GetTime(), " ", lev.Breakout.GetTime());
//|
//| // Check hit
//| if (lev.CheckHit())
//|   Print(lev.Hit.GetTime(), " ", lev.Hit.GetTime());
//+------------------------------------------------------------------+

#include <Object.mqh>
#include "Include\DKStdLib\Common\CDKBarTag.mqh"
#include "Include\DKStdLib\Common\DKDatetime.mqh"
#include "Include\DKStdLib\Common\DKNumPy.mqh"
#include "Include\DKStdLib\TradingManager\CDKSymbolInfo.mqh"
#include "Include\DKStdLib\Drawing\DKChartDraw.mqh"


enum ENUM_HIT_TYPE {
  HIT_TYPE_BREAKOUT = 0,          // Breakout
  HIT_TYPE_BOUNCE = 1             // Bounce
};

enum ENUM_LEVEL_TYPE {
  LEVEL_TYPE_SUPPORT    = 0,    // Support (equal POSITION_TYPE_BUY)
  LEVEL_TYPE_RESISTANCE = 1,    // Resistance (equal POSITION_TYPE_SELL)
};

ENUM_LEVEL_TYPE ReverseLevelType(const ENUM_LEVEL_TYPE _level) {
  if (_level == LEVEL_TYPE_SUPPORT) return LEVEL_TYPE_RESISTANCE;
  return LEVEL_TYPE_SUPPORT;
}

string LevelTypeToString(const ENUM_LEVEL_TYPE _level, const bool _short_format=false) {
  string res = "";
  if (_level == LEVEL_TYPE_SUPPORT) res = "SUPPORT";
  if (_level == LEVEL_TYPE_RESISTANCE) res = "RESISTANCE";
  
  if (_short_format) return StringSubstr(res, 0, 3);
  return res;
}

class CDKPriceLevel : public CObject {
 protected:
  string                Sym;
  CDKSymbolInfo         SymInfo;
  ENUM_TIMEFRAMES       TF;

 public:
  ENUM_LINE_STYLE       LevelLineStyle;          // Level line style
  int                   LevelLineWidth;          // Level line width
  color                 SupColor;                // Support level color
  color                 ResColor;                // Resistance level color
  bool                  DrawStartFinishMarkers;  // Draw start and finish markers
  string                MarkerSymStart;          // Start market sym
  string                MarkerSymFinish;         // Finish market sym
  string                MarketSymFont;           // Marker symbol font
  int                   MarketSymSize;           // Marker symbol size

 public:
  ENUM_LEVEL_TYPE       Type;
  CDKBarTag             Detect;
  CDKBarTag             Start;
  CDKBarTag             Finish;
  CDKBarTag             Breakout;
  CDKBarTag             Hit;
  
  double                TPOPricePerRow;  
  
  string                ChartIDCustom; // Start.Time is used if ="" 

  void                  CDKPriceLevel::Init(const string _sym, const ENUM_TIMEFRAMES _tf, 
                                            const ENUM_LEVEL_TYPE _type, const double _tpo_price_per_row);
  void                  CDKPriceLevel::CDKPriceLevel();

  datetime              CDKPriceLevel::FindBreakout(datetime _start_dt = NULL, datetime _finish_dt = NULL, 
                                                    ENUM_TIMEFRAMES _tf = NULL);                              // Find level breakout by HIGHEST/LOWEST price of TF
  bool                  CDKPriceLevel::CheckHit(const ENUM_HIT_TYPE _hit_type,
                                                const bool _ignore_finish_time = false);                      // Check level hit
  bool                  CDKPriceLevel::CheckHit(const ENUM_HIT_TYPE _hit_type, const double _price, 
                                                const bool _ignore_finish_time = false);                      // Check level hit by _price
  bool                  CDKPriceLevel::CheckHitAsk(const ENUM_HIT_TYPE _hit_type, 
                                                   const bool _ignore_finish_time = false);                   // Check level hit by ASK
  bool                  CDKPriceLevel::CheckHitBid(const ENUM_HIT_TYPE _hit_type, 
                                                   const bool _ignore_finish_time = false);                   // Check level hit by BID

  string                CDKPriceLevel::GetFullChartID(const string _prefix);                                  // Returns full Chart ID (global prefix + id)
  void                  CDKPriceLevel::Draw(const string _prefix, 
                                            const long _chart_id=0, const int _sub_window=0);                 // Draw level
  void                  CDKPriceLevel::RemoveFromChart(const string _prefix, 
                                                       const long _chart_id=0, const int _sub_window=0);      // Removes level from chart
};



//+------------------------------------------------------------------+
//| Init empty level
//| Default Dir is BUY
//+------------------------------------------------------------------+
void CDKPriceLevel::Init(const string _sym, const ENUM_TIMEFRAMES _tf, const ENUM_LEVEL_TYPE _type, const double _tpo_price_per_row) {
  Sym = _sym;
  SymInfo.Name(Sym);
  TF = _tf;

  Type = _type;
  Detect.Init(Sym, TF);
  Start.Init(Sym, TF);
  Finish.Init(Sym, TF);
  Breakout.Init(Sym, TF);
  Hit.Init(Sym, TF);
  
  TPOPricePerRow = _tpo_price_per_row;
  
  ChartIDCustom = "";
}

//+------------------------------------------------------------------+
//| Constructor inits by current Symbol and Period
//+------------------------------------------------------------------+
void CDKPriceLevel::CDKPriceLevel() {
  Init(Symbol(), Period(), LEVEL_TYPE_SUPPORT, 0);

  LevelLineStyle = STYLE_SOLID;
  SupColor = clrCrimson;
  ResColor = clrDodgerBlue;

  DrawStartFinishMarkers = true;
  MarkerSymStart = "u";
  MarkerSymFinish = "t";
  MarketSymFont = "Wingdings 3";//"Arial";
  MarketSymSize = 10;
 
  ChartIDCustom = "";
}

//+------------------------------------------------------------------+
//| Finds breakout of Start.GetValue() level
//| If breakout found Highest/Lowest point saved in
//|
//| Params:
//|   _start_dt: start of interval to find breakout (NULL=Start.Time)
//|   _finish_dt: finish of interval to find breakout (NULL=Start.Time)
//|   _tf: TF to find breakout
//+------------------------------------------------------------------+
datetime CDKPriceLevel::FindBreakout(datetime _start_dt = NULL, datetime _finish_dt = NULL, ENUM_TIMEFRAMES _tf = NULL) {
  if (_tf == NULL) _tf = TF;
  if (_start_dt == NULL) _start_dt = Start.GetTime();
  if (_finish_dt == NULL) _finish_dt = Finish.GetTime();

  int start = 0;
  if (_finish_dt > 0) start = iBarShift(Sym, _tf, _finish_dt);
  if (start < 0) return 0;

  int finish = 0;
  if (_start_dt > 0) finish = iBarShift(Sym, _tf, _start_dt);
  if (finish < 0) return 0;
  if (start > finish) return 0;
  int cnt = finish-start+1;

  double price[];
  int breakout_idx = -1;
  if (Type == LEVEL_TYPE_SUPPORT) {
    if (CopyLow(Sym, _tf, start, cnt, price) <= 0) return 0;
    breakout_idx = ArrayFindFirstConditional(price, 
                                             false, 0.0, COMPARE_TYPE_GE,
                                             true, Start.GetValue(), COMPARE_TYPE_LE,
                                             0, cnt);
  }
  if (Type == LEVEL_TYPE_RESISTANCE) {
    if (CopyHigh(Sym, _tf, start, cnt, price) <= 0) return 0;
    breakout_idx = ArrayFindFirstConditional(price, 
                                             true, Start.GetValue(), COMPARE_TYPE_GE,
                                             false, 0.0, COMPARE_TYPE_LE,
                                             0, cnt);                                              
  }

  if (breakout_idx < 0) return 0;
  
  double breakout_val = price[breakout_idx];
  datetime breakout_dt = iTime(Sym, _tf, ArraySize(price)-breakout_idx+start-1);
  Breakout.Init(Sym, TF, breakout_dt, breakout_val);
  
  return breakout_dt;
}

//+------------------------------------------------------------------+
//| Checks the _price hits Start.Value level
//| Updates Hit if it hits
//+------------------------------------------------------------------+
bool CDKPriceLevel::CheckHit(const ENUM_HIT_TYPE _hit_type, const double _price, const bool _ignore_finish_time = false) {
  if (Start.GetTime() <= 0) return false;
  if (!_ignore_finish_time && Finish.GetTime() != 0 && TimeCurrent() > Finish.GetTime()) return false;

  bool res = false;
  if (Type == LEVEL_TYPE_SUPPORT)    res = (_hit_type == HIT_TYPE_BREAKOUT) ? _price <= Start.GetValue() : _price > Start.GetValue();
  if (Type == LEVEL_TYPE_RESISTANCE) res = (_hit_type == HIT_TYPE_BREAKOUT) ? _price >= Start.GetValue() : _price < Start.GetValue();

  if (res) Hit.Init(Sym, TF, TimeCurrent(), _price);
  return res;
}

//+------------------------------------------------------------------+
//| Checks Ask hits Start.Value level
//| Updates Hit if it hits
//+------------------------------------------------------------------+
bool CDKPriceLevel::CheckHitAsk(const ENUM_HIT_TYPE _hit_type, const bool _ignore_finish_time = false) {
  if (!SymInfo.RefreshRates()) return false;
  double price = SymInfo.Ask();
  if (price <= 0) return false;

  return CheckHit(_hit_type, price);
}

//+------------------------------------------------------------------+
//| Checks Bid hits Start.Value level
//| Updates Hit if it hits
//+------------------------------------------------------------------+
bool CDKPriceLevel::CheckHitBid(const ENUM_HIT_TYPE _hit_type, const bool _ignore_finish_time = false) {
  if (!SymInfo.RefreshRates()) return false;
  double price = SymInfo.Bid();
  if (price <= 0) return false;

  return CheckHit(_hit_type, price, _ignore_finish_time);
}

//+------------------------------------------------------------------+
//| Checks the ASK hits Start.Value for level SUP level and BID for RES
//| Updates Hit if it hits
//+------------------------------------------------------------------+
bool CDKPriceLevel::CheckHit(const ENUM_HIT_TYPE _hit_type, const bool _ignore_finish_time = false) {
  if (!SymInfo.RefreshRates()) return false;
  double price = 0.0;
  
  if (_hit_type == HIT_TYPE_BOUNCE)   price = (Type == LEVEL_TYPE_SUPPORT) ? SymInfo.Ask() : SymInfo.Bid();
  if (_hit_type == HIT_TYPE_BREAKOUT) price = (Type == LEVEL_TYPE_SUPPORT) ? SymInfo.Bid() : SymInfo.Ask();
  
  if (price <= 0.0) return false;

  return CheckHit(_hit_type, price, _ignore_finish_time);
}

//+------------------------------------------------------------------+
//| Returns full ChartID: 'global prefix' + id
//+------------------------------------------------------------------+
string CDKPriceLevel::GetFullChartID(const string _prefix) {
  string id = (ChartIDCustom != "") ? ChartIDCustom : TimeToString(Start.GetTime());
  return StringFormat("%s-%s", _prefix, id);
}

//+------------------------------------------------------------------+
//| // Draw level
//+------------------------------------------------------------------+
void CDKPriceLevel::Draw(const string _prefix, const long _chart_id=0, const int _sub_window=0) {
  string name_line = GetFullChartID(_prefix);
  string name_mark_start = name_line+"-START"; 
  string name_mark_finish = name_line+"-FINISH"; 
  string descr = name_line+"-"+LevelTypeToString(Type ,true);
  color clr = (Type == LEVEL_TYPE_SUPPORT) ? SupColor : ResColor;
  datetime last_chart_dt = iTime(Sym, TF, 0);
  datetime finish_dt = MathMin((Finish.GetTime() != 0) ? Finish.GetTime() : TimeEnd(Start.GetTime(), DATETIME_PART_DAY), last_chart_dt);
  TrendLineCreate(_chart_id,      // chart's ID
                  name_line, // line name
                  descr, // line name
                  _sub_window,    // subwindow index
                  Start.GetTime(),         // first point time
                  Start.GetValue(),        // first point price
                  finish_dt,         // second point time
                  Start.GetValue(),        // second point price
                  clr,      // line color
                  LevelLineStyle, // line style
                  LevelLineWidth,         // line width
                  false,      // in the background
                  false,  // highlight to move
                  false,  // line's continuation to the left
                  Finish.GetTime() == 0, // line's continuation to the right
                  false,     // hidden in the object list
                  0);      // priority for mouse click
                  
 if (DrawStartFinishMarkers) {
   TextCreate(_chart_id,               // ID графика 
              name_mark_start,              // имя объекта 
              _sub_window,             // номер подокна 
              Start.GetTime(),                   // время точки привязки 
              Start.GetValue(),                  // цена точки привязки 
              MarkerSymStart,              // сам текст 
              MarketSymFont,             // шрифт 
              MarketSymSize,             // размер шрифта 
              clr,               // цвет 
              0.0,                // наклон текста 
              ANCHOR_CENTER, // способ привязки 
              false,               // на заднем плане 
              false,          // выделить для перемещений 
              false,              // скрыт в списке объектов 
              0);                // приоритет на нажатие мышью   
  
    if (Finish.GetTime() != 0)            
      TextCreate(_chart_id,               // ID графика 
                 name_mark_finish,              // имя объекта 
                 _sub_window,             // номер подокна 
                 Finish.GetTime(),                   // время точки привязки 
                 Start.GetValue(),                  // цена точки привязки 
                 MarkerSymFinish,              // сам текст 
                 MarketSymFont,             // шрифт 
                 MarketSymSize,             // размер шрифта 
                 clr,               // цвет 
                 0.0,                // наклон текста 
                 ANCHOR_CENTER, // способ привязки 
                 false,               // на заднем плане 
                 false,          // выделить для перемещений 
                 false,              // скрыт в списке объектов  
                 0);                // приоритет на нажатие мышью    
  }
}

//+------------------------------------------------------------------+
//| Removes level from chart
//+------------------------------------------------------------------+
void CDKPriceLevel::RemoveFromChart(const string _prefix, const long _chart_id=0, const int _sub_window=0) {
  ObjectsDeleteAll(_chart_id, GetFullChartID(_prefix), _sub_window);
}