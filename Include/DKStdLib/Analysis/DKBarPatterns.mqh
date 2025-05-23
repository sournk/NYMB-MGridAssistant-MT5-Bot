//+------------------------------------------------------------------+
//|                                                DKBarPatterns.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+
#property copyright "Denis Kislitsyn"
#property link      "https://kislitsyn.me"


struct SDKMqlRates : MqlRates {
  SDKMqlRates Init(MqlRates& _base) {
    this = _base;
    return this;
  }
  
  double Size() {
    return this.high - this.low;
  }
  
  double Body() {
    return MathAbs(this.open - this.close);
  }
  
  double WickTop() {
    return this.high - MathMax(this.close, this.open);
  }  
  
  double WickBottom() {
    return MathMin(this.close, this.open) - this.low;
  }
  
  double MidPoint() {
    return (this.high - this.low) / 2;
  }  
  
  double BodyMidPoint() {
    return MathAbs(this.open - this.close) / 2;
  }  
  
  int Dir() {
    if(this.close > this.open) return +1;
    if(this.close < this.open) return -1;
    return 0;
  }
};

//+------------------------------------------------------------------+
//| Base class for bar pattern
//+------------------------------------------------------------------+
class CDKBarPatternBase {
protected:
  MqlRates                   Rates[];
public:
  void                       CDKBarPatternBase::CDKBarPatternBase() {
    ArrayResize(Rates, 0);
    ArraySetAsSeries(Rates, true);
  }
  
  void                       CDKBarPatternBase::Init(MqlRates& _rates_as_series[]) {
    ArrayCopy(Rates, _rates_as_series);
  }
  
  MqlRates                   CDKBarPatternBase::Rate(const int _idx) {
    return Rates[_idx];
  }
  
  virtual bool               CDKBarPatternBase::IsPattern(const uint _idx = 0);
};

//+------------------------------------------------------------------+
//| Class for 'Three Black Crows' pattern
//+------------------------------------------------------------------+
class CDKBarPatternThreeBlackCrows : public CDKBarPatternBase {
private:
  int                        BarCnt;
public:
  bool                       WickSizeFilterEnable;
  double                     WickSizeMinRatio;
  
  void                       CDKBarPatternThreeBlackCrows::CDKBarPatternThreeBlackCrows():
                               BarCnt(3),
                               WickSizeFilterEnable(false),
                               WickSizeMinRatio(0.1) {};
  bool                       CDKBarPatternThreeBlackCrows::IsPattern(const uint _idx = 0){
    MqlRates pat_rates[]; ArraySetAsSeries(pat_rates, true);
    ArrayCopy(pat_rates, Rates, 0, _idx, 3);
    
    // 01. PATTERN BAR COUNT
    if(ArraySize(pat_rates) < BarCnt) 
      return false;
    
    for(int i=0;i<BarCnt;i++) {
      SDKMqlRates rate;
      rate.Init(pat_rates[i]);
      
      // 02. CHECK DIR -1
      if(rate.Dir() != -1) 
        return false;
      
      // 03. CHECK WICK
      if(WickSizeFilterEnable && rate.Body() > 0.0) {
        double wt = rate.WickTop();
        double wb = rate.WickBottom();
        double bd = rate.Body();
        if((rate.WickTop() / rate.Body() >= WickSizeMinRatio) ||
           (rate.WickBottom() / rate.Body() >= WickSizeMinRatio))
          return false;
      }
          
      // 04. CHECK CLOSE AND OPEN ARRANGED      
      if(i>0){
        MqlRates bar_curr = pat_rates[i-1];
        MqlRates bar_prev = pat_rates[i];
        if(bar_prev.close < bar_curr.close)
          return false;
          
        if(bar_prev.open < bar_curr.open)
          return false;        
      }
    }
    
    return true;
  }
};

//+------------------------------------------------------------------+
//| Class for 'Three Black Crows' pattern
//+------------------------------------------------------------------+
class CDKBarPatternThreeWhiteSoldiers : public CDKBarPatternBase {
private:
  int                        BarCnt;
public:
  bool                       WickSizeFilterEnable;
  double                     WickSizeMinRatio;
  
  void                       CDKBarPatternThreeWhiteSoldiers::CDKBarPatternThreeWhiteSoldiers():
                               BarCnt(3),
                               WickSizeFilterEnable(false),
                               WickSizeMinRatio(0.1) {};
  bool                       CDKBarPatternThreeWhiteSoldiers::IsPattern(const uint _idx = 0){
    MqlRates pat_rates[]; ArraySetAsSeries(pat_rates, true);
    ArrayCopy(pat_rates, Rates, 0, _idx, 3);
    
    // 01. PATTERN BAR COUNT
    if(ArraySize(pat_rates) < BarCnt) 
      return false;
    
    for(int i=0;i<BarCnt;i++) {
      SDKMqlRates rate;
      rate.Init(pat_rates[i]);
      
      // 02. CHECK DIR +1
      if(rate.Dir() != +1) 
        return false;
      
      // 03. CHECK WICK
      if(WickSizeFilterEnable && rate.Body() > 0.0) {
        double wt = rate.WickTop();
        double wb = rate.WickBottom();
        double bd = rate.Body();
        if((rate.WickTop() / rate.Body() >= WickSizeMinRatio) ||
           (rate.WickBottom() / rate.Body() >= WickSizeMinRatio))
          return false;
      }
          
      // 04. CHECK CLOSE AND OPEN ARRANGED      
      if(i>0){
        MqlRates bar_curr = pat_rates[i-1];
        MqlRates bar_prev = pat_rates[i];
        if(bar_prev.close > bar_curr.close)
          return false;
          
        if(bar_prev.open > bar_curr.open)
          return false;        
      }
    }
    
    return true;
  }
};