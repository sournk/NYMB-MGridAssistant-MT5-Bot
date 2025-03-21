//+------------------------------------------------------------------+
//|                                                   CMGAInputs.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+

// Field naming convention:
//  1. With the prefix '__' the field will not be declared for user input
//  2. With the prefix '_' the field will be declared as 'sinput'
//  3. otherwise it will be declared as 'input'

//#include <Indicators\Oscilators.mqh>
//#include <Indicators\Trend.mqh>

#include "Include\DKStdLib\Common\DKStdLib.mqh"



// PARSING AREA OF INPUT STRUCTURE == START == DO NOT REMOVE THIS COMMENT
struct CMGABotInputs {
  // input  group                    "1. ONLINE ANALYSIS (A)"
  
  // input  group                    "2. MISC (MS)"
  ulong                       _MS_MGC;                  // Expert Adviser ID - Magic // 20250309
  string                      _MS_EGP;                  // Expert Adviser Global Prefix // "MGA"
  LogLevel                    _MS_LOG_LL;               // Log Level // DEBUG
  string                      _MS_LOG_FI;               // Log Filter IN String (use `;` as sep) // ""
  string                      _MS_LOG_FO;               // Log Filter OUT String (use `;` as sep) // ""
  bool                        _MS_COM_EN;               // Comment Enable (turn off for fast testing) // true
  uint                        _MS_COM_IS;               // Comment Interval, Sec // 30
  bool                        _MS_COM_CW;               // Comment Custom Window // true
  uint                        _MS_TIM_MS;               // Timer Interval, ms // 60000
  uint                        __MS_LIC_DUR_SEC;         // License Duration, Sec // 0*24*60*60
  
  
// PARSING AREA OF INPUT STRUCTURE == END == DO NOT REMOVE THIS COMMENT

  string LastErrorMessage;
  bool CMGABotInputs::InitAndCheck();
  bool CMGABotInputs::Init();
  bool CMGABotInputs::CheckBeforeInit();
  bool CMGABotInputs::CheckAfterInit();
  void CMGABotInputs::CMGABotInputs();
  
  // IND HNDLs
  // vvvvvvvvv
};

//+------------------------------------------------------------------+
//| Init struc and Check values
//+------------------------------------------------------------------+
bool CMGABotInputs::InitAndCheck(){
  LastErrorMessage = "";

  if (!CheckBeforeInit())
    return false;

  if (!Init()) {
    LastErrorMessage = "Input.Init() failed";
    return false;
  }

  return CheckAfterInit();
}

//+------------------------------------------------------------------+
//| Init struc
//+------------------------------------------------------------------+
bool CMGABotInputs::Init(){
  return true;
}

//+------------------------------------------------------------------+
//| Check struc after Init
//+------------------------------------------------------------------+
bool CMGABotInputs::CheckAfterInit(){
  LastErrorMessage = "";
  return LastErrorMessage == "";
}

// GENERATED CODE == START == DO NOT REMOVE THIS COMMENT

input  group                    "1. ONLINE ANALYSIS (A)"
  
                   // input  group                    "2. MISC (MS)"
sinput ulong                     Inp__MS_MGC                        = 20250309; // MS_MGC: Expert Adviser ID - Magic
sinput string                    Inp__MS_EGP                        = "MGA";    // MS_EGP: Expert Adviser Global Prefix
sinput LogLevel                  Inp__MS_LOG_LL                     = DEBUG;    // MS_LOG_LL: Log Level
sinput string                    Inp__MS_LOG_FI                     = "";       // MS_LOG_FI: Log Filter IN String (use `;` as sep)
sinput string                    Inp__MS_LOG_FO                     = "";       // MS_LOG_FO: Log Filter OUT String (use `;` as sep)
sinput bool                      Inp__MS_COM_EN                     = true;     // MS_COM_EN: Comment Enable (turn off for fast testing)
sinput uint                      Inp__MS_COM_IS                     = 30;       // MS_COM_IS: Comment Interval, Sec
sinput bool                      Inp__MS_COM_CW                     = true;     // MS_COM_CW: Comment Custom Window
sinput uint                      Inp__MS_TIM_MS                     = 60000;    // MS_TIM_MS: Timer Interval, ms

// INPUTS FOR USER MANUAL:

// ##### 1. ONLINE ANALYSIS (A)"
  
                                           // input  group                    "2. MISC (MS)
// - [x] `MS_MGC`: Expert Adviser ID - Magic
// - [x] `MS_EGP`: Expert Adviser Global Prefix
// - [x] `MS_LOG_LL`: Log Level
// - [x] `MS_LOG_FI`: Log Filter IN String (use `;` as sep)
// - [x] `MS_LOG_FO`: Log Filter OUT String (use `;` as sep)
// - [x] `MS_COM_EN`: Comment Enable (turn off for fast testing)
// - [x] `MS_COM_IS`: Comment Interval, Sec
// - [x] `MS_COM_CW`: Comment Custom Window
// - [x] `MS_TIM_MS`: Timer Interval, ms


//+------------------------------------------------------------------+
//| Fill Input struc with user inputs vars
//+------------------------------------------------------------------+    
void FillInputs(CMGABotInputs& _inputs) {
  _inputs._MS_MGC                   = Inp__MS_MGC;                              // MS_MGC: Expert Adviser ID - Magic
  _inputs._MS_EGP                   = Inp__MS_EGP;                              // MS_EGP: Expert Adviser Global Prefix
  _inputs._MS_LOG_LL                = Inp__MS_LOG_LL;                           // MS_LOG_LL: Log Level
  _inputs._MS_LOG_FI                = Inp__MS_LOG_FI;                           // MS_LOG_FI: Log Filter IN String (use `;` as sep)
  _inputs._MS_LOG_FO                = Inp__MS_LOG_FO;                           // MS_LOG_FO: Log Filter OUT String (use `;` as sep)
  _inputs._MS_COM_EN                = Inp__MS_COM_EN;                           // MS_COM_EN: Comment Enable (turn off for fast testing)
  _inputs._MS_COM_IS                = Inp__MS_COM_IS;                           // MS_COM_IS: Comment Interval, Sec
  _inputs._MS_COM_CW                = Inp__MS_COM_CW;                           // MS_COM_CW: Comment Custom Window
  _inputs._MS_TIM_MS                = Inp__MS_TIM_MS;                           // MS_TIM_MS: Timer Interval, ms
}


//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
void CMGABotInputs::CMGABotInputs():
       _MS_MGC(20250309),
       _MS_EGP("MGA"),
       _MS_LOG_LL(DEBUG),
       _MS_LOG_FI(""),
       _MS_LOG_FO(""),
       _MS_COM_EN(true),
       _MS_COM_IS(30),
       _MS_COM_CW(true),
       _MS_TIM_MS(60000),
       __MS_LIC_DUR_SEC(0*24*60*60){

};


//+------------------------------------------------------------------+
//| Check struc before Init
//+------------------------------------------------------------------+
bool CMGABotInputs::CheckBeforeInit() {
  LastErrorMessage = "";


  return LastErrorMessage == "";
}
// GENERATED CODE == END == DO NOT REMOVE THIS COMMENT



