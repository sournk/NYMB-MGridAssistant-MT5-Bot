//+------------------------------------------------------------------+
//|                                             CDKBOSPriceLevel.mqh |
//|                                                  Denis Kislitsyn |
//|                                               http:/kislitsyn.me |
//+------------------------------------------------------------------+

#include <Object.mqh>
#include <Generic\HashMap.mqh>
#include <Arrays\ArrayLong.mqh>
#include <Arrays\ArrayDouble.mqh>
#include "Include\DKStdLib\Common\CDKBarTag.mqh"
#include "Include\DKStdLib\Common\DKDatetime.mqh"
#include "Include\DKStdLib\Common\DKNumPy.mqh"
#include "Include\DKStdLib\TradingManager\CDKSymbolInfo.mqh"
#include "Include\DKStdLib\Drawing\DKChartDraw.mqh"

#include "CDKPriceLevel.mqh"

enum ENUM_FRACTAL_TYPE {
  FRACTAL_TYPE_UP   = 0, // Верх
  FRACTAL_TYPE_DOWN = 1, // Низ
};

enum ENUM_TPO_BOS_MODE {
  TPO_BOS_MODE_ZIGZAG  = 0, // ZigZag
  TPO_BOS_MODE_FRACTAL = 1  // Fractal
};

class CDKBOSPriceLevel : public CDKPriceLevel {
 protected:
   int                  IndZZHandle;
   int                  IndFractalUpHandle;
   int                  IndFractalDownHandle;

 public: //Settings
  int                   ZZBOSDetectionDepth;
  ENUM_TPO_BOS_MODE     BOSMode;
  
 public:
  CDKBarTag             Right;
  CDKBarTag             Left;
  

  void                  CDKBOSPriceLevel::CDKBOSPriceLevel();
  bool                  CDKBOSPriceLevel::Init(const string _sym, const ENUM_TIMEFRAMES _tf, const ENUM_LEVEL_TYPE _type,
                                               const datetime _dt, const double _price, const double _tpo_price_per_row,
                                               const int _zz_handle,
                                               const int _fractal_up_handle,
                                               const int _fractal_down_handle,
                                               const ENUM_TPO_BOS_MODE _bos_mode);
                                               

  bool                  CDKBOSPriceLevel::GetBOSExtremes(const int _start_idx, const int _cnt, double& _buf[]);
  double                CDKBOSPriceLevel::GetRightZZ(const int _start_idx);
                                               
  bool                  CDKBOSPriceLevel::UpdateBOS(const string _chart_prefix, const long _chart_id=0, const int _sub_window=0);
  
  void                  CDKBOSPriceLevel::Draw(const string _prefix, const bool _draw_link,
                                               const long _chart_id=0, const int _sub_window=0);                 // Draw level
};

//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
void CDKBOSPriceLevel::CDKBOSPriceLevel() {
  ZZBOSDetectionDepth = 24*60;
  BOSMode = TPO_BOS_MODE_FRACTAL;
}

//+------------------------------------------------------------------+
//| Fill _idx_arr and _val_arr with indexies and values of BOS extremes
//| using ZZ or Fractal indicator
//+------------------------------------------------------------------+
//bool CDKBOSPriceLevel::GetBOSExtremes(const int _start_idx, const int _cnt, double& _buf[]) {
//  if (BOSMode == TPO_BOS_MODE_ZIGZAG) {
//    ArraySetAsSeries(_buf, true);
//    if (CopyBuffer(IndZZHandle, 0, _start_idx, _cnt, _buf) <= 0) return false; 
//  }
//  
//  if (BOSMode == TPO_BOS_MODE_FRACTAL) {
//    CHashMap<int, double> hash;
//    double buf_up[]; ArraySetAsSeries(buf_up, true);
//    double buf_down[]; ArraySetAsSeries(buf_down, true);
//    if (CopyBuffer(IndFractalUpHandle, 0, _start_idx, _cnt, buf_up) <= 0) return false; 
//    if (CopyBuffer(IndFractalDownHandle, 0, _start_idx, _cnt, buf_down) <= 0) return false; 
//    if (ArraySize(buf_up) != ArraySize(buf_down)) return false;
//    
//    if (Type == LEVEL_TYPE_RESISTANCE) buf_down[0] = iClose(Sym, TF, 0);
//    if (Type == LEVEL_TYPE_SUPPORT) buf_up[0] = iClose(Sym, TF, 0);
//    
//    ArraySetAsSeries(_buf, true);
//    ArrayResize(_buf, ArraySize(buf_up));
//    ArrayFill(_buf, 0, ArraySize(_buf), 0.0);
//    
//    int prev_dir = 0; int dir = 0;
//    int prev_idx_up = -1; double prev_val_up = 0.0;
//    int prev_idx_down = -1; double prev_val_down = DBL_MAX;
//    
//    for(int i=0;i<ArraySize(buf_up);i++) {
//      if (buf_up[i] > 0) {
//        if (buf_up[i]>prev_val_up) {
//          prev_idx_up = i;
//          prev_val_up = buf_up[i];
//        }
//      
//        dir = +1;
//        if (prev_dir == 0) prev_dir = dir;
//      }
//      if (buf_down[i] > 0) {
//        if (buf_down[i]<prev_val_down) {
//          prev_idx_down = i;
//          prev_val_down = buf_down[i];
//        }      
//        dir = -1;
//        if (prev_dir == 0) prev_dir = dir;
//      }      
//      
//      if (dir != prev_dir || i >= (ArraySize(buf_up)-1)) {
//        if(prev_dir > 0 && prev_idx_up >= 0) {
//          _buf[prev_idx_up] = prev_val_up;
//          prev_idx_up = -1;
//          prev_val_up = 0;
//        }
//        if(prev_dir < 0) {
//          _buf[prev_idx_down] = prev_val_down;
//          prev_idx_down = -1;
//          prev_val_down = DBL_MAX;
//        }
//        prev_dir = dir;
//      }
//    }
//  }
//  
//  return true;
//}
bool CDKBOSPriceLevel::GetBOSExtremes(const int _start_idx, const int _cnt, double& _buf[]) {
  ArraySetAsSeries(_buf, true);
  if (BOSMode == TPO_BOS_MODE_ZIGZAG) {
    double zz[];
    if (CopyBuffer(IndZZHandle, 0, _start_idx, _cnt, zz) <= 0) return false; 

    CArrayInt zz_idx;
    for(int i=0;i<ArraySize(zz);i++)
      if (zz[i] > 0) zz_idx.Add(i);      
    
    if (zz_idx.Total() < 2) return false;
    
    CArrayInt zz_res_idx;
    zz_res_idx.Add(zz_idx.At(0));
    for(int i=1;i<zz_idx.Total();i++) {
      if(i<(zz_idx.Total()-1)) {
        if (Type == LEVEL_TYPE_RESISTANCE && zz[zz_idx.At(i+1)]>=zz[zz_idx.At(i)]) continue;
        if (Type == LEVEL_TYPE_SUPPORT    && zz[zz_idx.At(i+1)]<=zz[zz_idx.At(i)]) continue;
      }
       
      if (Type == LEVEL_TYPE_RESISTANCE && zz[zz_idx.At(i)]>=zz[zz_idx.At(i-1)]) zz_res_idx.Add(zz_idx.At(i));
      if (Type == LEVEL_TYPE_SUPPORT    && zz[zz_idx.At(i)]<=zz[zz_idx.At(i-1)]) zz_res_idx.Add(zz_idx.At(i));
    } 
    
    ArrayFill(_buf, 0, ArraySize(_buf), 0.0);
    for(int i=0;i<zz_res_idx.Total();i++) 
      _buf[zz_res_idx.At(i)] = zz[zz_res_idx.At(i)];
      
  }
  
  if (BOSMode == TPO_BOS_MODE_FRACTAL) {
    if(Type == LEVEL_TYPE_RESISTANCE)     
      if (CopyBuffer(IndFractalUpHandle, 0, _start_idx, _cnt, _buf) <= 0) return false;
      
    if(Type == LEVEL_TYPE_SUPPORT)     
      if (CopyBuffer(IndFractalDownHandle, 0, _start_idx, _cnt, _buf) <= 0) return false; 
  }
  
  return true;
}

//+------------------------------------------------------------------+
//| Return right ZZ value from _start_idx
//+------------------------------------------------------------------+
double CDKBOSPriceLevel::GetRightZZ(const int _start_idx) {
  double buf[];
  //if (CopyBuffer(IndZZHandle, 0, 0, _start_idx+1, buf) < 0) return 0.0;
  if (GetBOSExtremes(0, _start_idx+1, buf) <= 0) return 0.0;
  
  for(int i=0;i<ArraySize(buf);i++) 
    if(buf[i] > 0) return buf[i];
  
  return 0.0;
}

//+------------------------------------------------------------------+
//| Init BOS to start hit detection
//+------------------------------------------------------------------+
bool CDKBOSPriceLevel::Init(const string _sym, const ENUM_TIMEFRAMES _tf, const ENUM_LEVEL_TYPE _type,
                            const datetime _dt, const double _price, const double _tpo_price_per_row,
                            const int _zz_handle,
                            const int _fractal_up_handle,
                            const int _fractal_down_handle,
                            const ENUM_TPO_BOS_MODE _bos_mode) {
  CDKPriceLevel::Init(_sym, _tf, _type, _tpo_price_per_row);

  IndZZHandle = _zz_handle;
  IndFractalUpHandle = _fractal_up_handle;
  IndFractalDownHandle = _fractal_down_handle;
  BOSMode = _bos_mode;
  
  Detect.SetTimeAndValue(_dt, _price);
  
  double zz[]; ArraySetAsSeries(zz, true);
  if (GetBOSExtremes(0, Detect.GetIndex()+ZZBOSDetectionDepth, zz) <= 0) return false; 
  
  //Put all not null zz idx to arr
  CArrayInt zz_idx;
  for(int i=0;i<ArraySize(zz);i++)
    if (zz[i] > 0) zz_idx.Add(i);  
  if (zz_idx.Total() < 1) return false; 

  Right.Init(Sym, TF, 0, iClose(Sym, TF, 0));
  Left.Init(Sym, TF, zz_idx.At(0), zz[zz_idx.At(0)]); 
  Start.SetIndexAndValue(Left.GetIndex(), Left.GetValue());
  
  return true;  
}

//+------------------------------------------------------------------+
//| Update BOS level
//|
//| Returns: 
//|   true if BOS level has updated
//+------------------------------------------------------------------+
bool CDKBOSPriceLevel::UpdateBOS(const string _chart_prefix, const long _chart_id=0, const int _sub_window=0) {
  int right_idx = Right.GetIndex(true);
  if(right_idx <= 0) return false; // No new bar born

  // Looking for NEW Right extreme
  int extreme_idx = -1;
  double extreme_val = 0.0;
  if(Type == LEVEL_TYPE_RESISTANCE) {
    extreme_idx = iLowest(Sym, TF, MODE_LOW, right_idx+1, 0);
    extreme_val = iLow(Sym, TF, extreme_idx);
    if(extreme_val > Right.GetValue()) return false; // No new extreme was found
  }
  if(Type == LEVEL_TYPE_SUPPORT) {
    extreme_idx = iHighest(Sym, TF, MODE_HIGH, right_idx+1, 0);
    extreme_val = iHigh(Sym, TF, extreme_idx);  
    if(extreme_val < Right.GetValue()) return false; // No new extreme was found
  }
  
  double zz[]; ArraySetAsSeries(zz, true);
  if (GetBOSExtremes(0, ZZBOSDetectionDepth, zz) <= 0) return false;
  
  CArrayInt zz_idx;
  for(int i=0;i<ArraySize(zz);i++)
    if (zz[i] > 0 && i >= extreme_idx) zz_idx.Add(i);  
  if(zz_idx.Total() < 1) return false;  
  
  Right.SetIndexAndValue(extreme_idx, extreme_val);
  Left.SetIndexAndValue(zz_idx.At(0), zz[zz_idx.At(0)]);
  if(Start.GetIndex(true) != zz_idx.At(0)) Start.SetIndexAndValue(Left.GetIndex(), Left.GetValue());

  // Delete chart object before set Start
  if (_chart_prefix != "")
    RemoveFromChart(_chart_prefix, _chart_id, _sub_window);
    
  return true;  
}

//+------------------------------------------------------------------+
//| // Draw level and interconnection with Detect point
//+------------------------------------------------------------------+
void CDKBOSPriceLevel::Draw(const string _prefix, const bool _draw_link, const long _chart_id=0, const int _sub_window=0) {
  CDKPriceLevel::Draw(_prefix, _chart_id, _sub_window);
  if (!_draw_link) return;
  
  string name_line = GetFullChartID(_prefix)+"-LINK";
  color clr = (Type == LEVEL_TYPE_SUPPORT) ? SupColor : ResColor;
  TrendLineCreate(_chart_id,      // chart's ID
                  name_line, // line name
                  name_line, // line name
                  _sub_window,    // subwindow index
                  Detect.GetTime(),         // second point time
                  Detect.GetValue(),        // second point price
                  Start.GetTime(),         // first point time
                  Start.GetValue(),        // first point price
                  clr,      // line color
                  LevelLineStyle, // line style
                  LevelLineWidth,         // line width
                  false,      // in the background
                  false,  // highlight to move
                  false,  // line's continuation to the left
                  false, // line's continuation to the right
                  false,     // hidden in the object list
                  0);      // priority for mouse click
}