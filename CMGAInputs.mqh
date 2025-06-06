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
  // input  group                    "1. СЕТАП (SET)"
  string                      SET_SYM_LST;              // Список отслеживаемых символов через ';' (''-все) // ""
  double                      SET_LOT_RAT;              // Мультпликатор лота по умолчанию // 2.0(x>0.0)
  uint                        SET_LOT_NXS;              // Номер шага для следующего мультипликатора лота // 7(x>0)
  double                      SET_LOT_NXR;              // Следующий мультпликатор лота // 1.5(x>0.0)  
  double                      SET_MTP_RRD;              // TP RR Основной позиции по умолчанию // 2.0(x>0.0)
  double                      SET_HSL_RAT;              // Коэф. SL для Хедж позиции от дистанции TP // 0.333(x>0.0)
  uint                        SET_TRD_SLP;              // Допустимое проскальзывание торговых операций, пункт // 0
  uint                        SET_TRD_REP;              // Количество повторов после ошибки (0-откл) // 5
  uint                        SET_TRD_RET;              // Задержка перед повтором после ошибки, мс // 2000
  
  // input  group                    "2. УВЕДОМЛЕНИЯ (NTF)"
  bool                        _NTF_ALM_ENB;             // Включить стандарные уведомления // true
  bool                        _NTF_EML_ENB;             // Включить email-уведомления через MetaTrader 5 // false
  bool                        _NTF_PUS_ENB;             // Включить push-уведомления в MetaTrader 5 Mobile // false
  
  
  // input  group                    "3. ГРАФИКА (GRH)"
  bool                        _GRH_POS_ENB;             // Рисовать позиции сеток // true
  bool                        _GRH_POS_FIL;             // Заливать фон основной позиции // true
  color                       _GRH_POS_SLC;             // Цвет основной позиции SL // clrLightPink
  color                       _GRH_POS_TPC;             // Цвет основной позиции TP // clrLightGreen  
  uint                        _GRH_HED_WTH;             // Толщина линий хеджей // 2(x>0)
  color                       _GRH_HED_SLC;             // Цвет хедж позиции SL // clrRed
  color                       _GRH_HED_TPC;             // Цвет хедж позиции TP // clrGreen
  
  // input  group                    "4. ЭМУЛЯЦИЯ В ТЕСТЕРЕ (TST)"
  datetime                    _TST_1ST_DT;              // Время открытия Первой позиции // D'2025-01-21 12:05:05'
  ENUM_POSITION_TYPE          _TST_1ST_DIR;             // Направление Первой позиции // POSITION_TYPE_BUY
  double                      _TST_1ST_LOT;             // Лот Первой позиции // 1.0(x>0.0)
  uint                        _TST_1ST_SLD;             // SL Первой позиции, пункт // 200(x>0)
  double                      _TST_1ST_RR;              // RR для TP Первой позиции, пункт // 2.5(x>0.0)
  uint                        _TST_NXT_DEL;             // Задержка перед следующей позицией, сек // 5*60*60(x>0)

  // input  group                    "5. MISC (MS)"
  ulong                       _MS_MGC;                  // Expert Adviser ID - Magic // 20250321
  string                      _MS_EGP;                  // Expert Adviser Global Prefix // "MGA"
  LogLevel                    _MS_LOG_LL;               // Log Level // INFO
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

input  group                    "1. СЕТАП (SET)"
input  string                    Inp_SET_SYM_LST                    = "";                     // SET_SYM_LST: Список отслеживаемых символов через ';' (''-все)
input  double                    Inp_SET_LOT_RAT                    = 2.0;                    // SET_LOT_RAT: Мультпликатор лота по умолчанию
input  uint                      Inp_SET_LOT_NXS                    = 7;                      // SET_LOT_NXS: Номер шага для следующего мультипликатора лота
input  double                    Inp_SET_LOT_NXR                    = 1.5;                    // SET_LOT_NXR: Следующий мультпликатор лота
input  double                    Inp_SET_MTP_RRD                    = 2.0;                    // SET_MTP_RRD: TP RR Основной позиции по умолчанию
input  double                    Inp_SET_HSL_RAT                    = 0.333;                  // SET_HSL_RAT: Коэф. SL для Хедж позиции от дистанции TP
input  uint                      Inp_SET_TRD_SLP                    = 0;                      // SET_TRD_SLP: Допустимое проскальзывание торговых операций, пункт
input  uint                      Inp_SET_TRD_REP                    = 5;                      // SET_TRD_REP: Количество повторов после ошибки (0-откл)
input  uint                      Inp_SET_TRD_RET                    = 2000;                   // SET_TRD_RET: Задержка перед повтором после ошибки, мс

input  group                    "2. УВЕДОМЛЕНИЯ (NTF)"
sinput bool                      Inp__NTF_ALM_ENB                   = true;                   // NTF_ALM_ENB: Включить стандарные уведомления
sinput bool                      Inp__NTF_EML_ENB                   = false;                  // NTF_EML_ENB: Включить email-уведомления через MetaTrader 5
sinput bool                      Inp__NTF_PUS_ENB                   = false;                  // NTF_PUS_ENB: Включить push-уведомления в MetaTrader 5 Mobile

input  group                    "3. ГРАФИКА (GRH)"
sinput bool                      Inp__GRH_POS_ENB                   = true;                   // GRH_POS_ENB: Рисовать позиции сеток
sinput bool                      Inp__GRH_POS_FIL                   = true;                   // GRH_POS_FIL: Заливать фон основной позиции
sinput color                     Inp__GRH_POS_SLC                   = clrLightPink;           // GRH_POS_SLC: Цвет основной позиции SL
sinput color                     Inp__GRH_POS_TPC                   = clrLightGreen;          // GRH_POS_TPC: Цвет основной позиции TP
sinput uint                      Inp__GRH_HED_WTH                   = 2;                      // GRH_HED_WTH: Толщина линий хеджей
sinput color                     Inp__GRH_HED_SLC                   = clrRed;                 // GRH_HED_SLC: Цвет хедж позиции SL
sinput color                     Inp__GRH_HED_TPC                   = clrGreen;               // GRH_HED_TPC: Цвет хедж позиции TP

input  group                    "4. ЭМУЛЯЦИЯ В ТЕСТЕРЕ (TST)"
sinput datetime                  Inp__TST_1ST_DT                    = D'2025-01-21 12:05:05'; // TST_1ST_DT: Время открытия Первой позиции
sinput ENUM_POSITION_TYPE        Inp__TST_1ST_DIR                   = POSITION_TYPE_BUY;      // TST_1ST_DIR: Направление Первой позиции
sinput double                    Inp__TST_1ST_LOT                   = 1.0;                    // TST_1ST_LOT: Лот Первой позиции
sinput uint                      Inp__TST_1ST_SLD                   = 200;                    // TST_1ST_SLD: SL Первой позиции, пункт
sinput double                    Inp__TST_1ST_RR                    = 2.5;                    // TST_1ST_RR: RR для TP Первой позиции, пункт
sinput uint                      Inp__TST_NXT_DEL                   = 5*60*60;                // TST_NXT_DEL: Задержка перед следующей позицией, сек

input  group                    "5. MISC (MS)"
sinput ulong                     Inp__MS_MGC                        = 20250321;               // MS_MGC: Expert Adviser ID - Magic
sinput string                    Inp__MS_EGP                        = "MGA";                  // MS_EGP: Expert Adviser Global Prefix
sinput LogLevel                  Inp__MS_LOG_LL                     = INFO;                   // MS_LOG_LL: Log Level
sinput string                    Inp__MS_LOG_FI                     = "";                     // MS_LOG_FI: Log Filter IN String (use `;` as sep)
sinput string                    Inp__MS_LOG_FO                     = "";                     // MS_LOG_FO: Log Filter OUT String (use `;` as sep)
sinput bool                      Inp__MS_COM_EN                     = true;                   // MS_COM_EN: Comment Enable (turn off for fast testing)
sinput uint                      Inp__MS_COM_IS                     = 30;                     // MS_COM_IS: Comment Interval, Sec
sinput bool                      Inp__MS_COM_CW                     = true;                   // MS_COM_CW: Comment Custom Window
sinput uint                      Inp__MS_TIM_MS                     = 60000;                  // MS_TIM_MS: Timer Interval, ms

// INPUTS FOR USER MANUAL:

// ##### 1. СЕТАП (SET)
// - [x] `SET_SYM_LST`: Список отслеживаемых символов через ';' (''-все)
// - [x] `SET_LOT_RAT`: Мультпликатор лота по умолчанию
// - [x] `SET_LOT_NXS`: Номер шага для следующего мультипликатора лота
// - [x] `SET_LOT_NXR`: Следующий мультпликатор лота
// - [x] `SET_MTP_RRD`: TP RR Основной позиции по умолчанию
// - [x] `SET_HSL_RAT`: Коэф. SL для Хедж позиции от дистанции TP
// - [x] `SET_TRD_SLP`: Допустимое проскальзывание торговых операций, пункт
// - [x] `SET_TRD_REP`: Количество повторов после ошибки (0-откл)
// - [x] `SET_TRD_RET`: Задержка перед повтором после ошибки, мс

// ##### 2. УВЕДОМЛЕНИЯ (NTF)
// - [x] `NTF_ALM_ENB`: Включить стандарные уведомления
// - [x] `NTF_EML_ENB`: Включить email-уведомления через MetaTrader 5
// - [x] `NTF_PUS_ENB`: Включить push-уведомления в MetaTrader 5 Mobile

// ##### 3. ГРАФИКА (GRH)
// - [x] `GRH_POS_ENB`: Рисовать позиции сеток
// - [x] `GRH_POS_FIL`: Заливать фон основной позиции
// - [x] `GRH_POS_SLC`: Цвет основной позиции SL
// - [x] `GRH_POS_TPC`: Цвет основной позиции TP
// - [x] `GRH_HED_WTH`: Толщина линий хеджей
// - [x] `GRH_HED_SLC`: Цвет хедж позиции SL
// - [x] `GRH_HED_TPC`: Цвет хедж позиции TP

// ##### 4. ЭМУЛЯЦИЯ В ТЕСТЕРЕ (TST)
// - [x] `TST_1ST_DT`: Время открытия Первой позиции
// - [x] `TST_1ST_DIR`: Направление Первой позиции
// - [x] `TST_1ST_LOT`: Лот Первой позиции
// - [x] `TST_1ST_SLD`: SL Первой позиции, пункт
// - [x] `TST_1ST_RR`: RR для TP Первой позиции, пункт
// - [x] `TST_NXT_DEL`: Задержка перед следующей позицией, сек

// ##### 5. MISC (MS)
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
  _inputs.SET_SYM_LST               = Inp_SET_SYM_LST;                                        // SET_SYM_LST: Список отслеживаемых символов через ';' (''-все)
  _inputs.SET_LOT_RAT               = Inp_SET_LOT_RAT;                                        // SET_LOT_RAT: Мультпликатор лота по умолчанию
  _inputs.SET_LOT_NXS               = Inp_SET_LOT_NXS;                                        // SET_LOT_NXS: Номер шага для следующего мультипликатора лота
  _inputs.SET_LOT_NXR               = Inp_SET_LOT_NXR;                                        // SET_LOT_NXR: Следующий мультпликатор лота
  _inputs.SET_MTP_RRD               = Inp_SET_MTP_RRD;                                        // SET_MTP_RRD: TP RR Основной позиции по умолчанию
  _inputs.SET_HSL_RAT               = Inp_SET_HSL_RAT;                                        // SET_HSL_RAT: Коэф. SL для Хедж позиции от дистанции TP
  _inputs.SET_TRD_SLP               = Inp_SET_TRD_SLP;                                        // SET_TRD_SLP: Допустимое проскальзывание торговых операций, пункт
  _inputs.SET_TRD_REP               = Inp_SET_TRD_REP;                                        // SET_TRD_REP: Количество повторов после ошибки (0-откл)
  _inputs.SET_TRD_RET               = Inp_SET_TRD_RET;                                        // SET_TRD_RET: Задержка перед повтором после ошибки, мс
  _inputs._NTF_ALM_ENB              = Inp__NTF_ALM_ENB;                                       // NTF_ALM_ENB: Включить стандарные уведомления
  _inputs._NTF_EML_ENB              = Inp__NTF_EML_ENB;                                       // NTF_EML_ENB: Включить email-уведомления через MetaTrader 5
  _inputs._NTF_PUS_ENB              = Inp__NTF_PUS_ENB;                                       // NTF_PUS_ENB: Включить push-уведомления в MetaTrader 5 Mobile
  _inputs._GRH_POS_ENB              = Inp__GRH_POS_ENB;                                       // GRH_POS_ENB: Рисовать позиции сеток
  _inputs._GRH_POS_FIL              = Inp__GRH_POS_FIL;                                       // GRH_POS_FIL: Заливать фон основной позиции
  _inputs._GRH_POS_SLC              = Inp__GRH_POS_SLC;                                       // GRH_POS_SLC: Цвет основной позиции SL
  _inputs._GRH_POS_TPC              = Inp__GRH_POS_TPC;                                       // GRH_POS_TPC: Цвет основной позиции TP
  _inputs._GRH_HED_WTH              = Inp__GRH_HED_WTH;                                       // GRH_HED_WTH: Толщина линий хеджей
  _inputs._GRH_HED_SLC              = Inp__GRH_HED_SLC;                                       // GRH_HED_SLC: Цвет хедж позиции SL
  _inputs._GRH_HED_TPC              = Inp__GRH_HED_TPC;                                       // GRH_HED_TPC: Цвет хедж позиции TP
  _inputs._TST_1ST_DT               = Inp__TST_1ST_DT;                                        // TST_1ST_DT: Время открытия Первой позиции
  _inputs._TST_1ST_DIR              = Inp__TST_1ST_DIR;                                       // TST_1ST_DIR: Направление Первой позиции
  _inputs._TST_1ST_LOT              = Inp__TST_1ST_LOT;                                       // TST_1ST_LOT: Лот Первой позиции
  _inputs._TST_1ST_SLD              = Inp__TST_1ST_SLD;                                       // TST_1ST_SLD: SL Первой позиции, пункт
  _inputs._TST_1ST_RR               = Inp__TST_1ST_RR;                                        // TST_1ST_RR: RR для TP Первой позиции, пункт
  _inputs._TST_NXT_DEL              = Inp__TST_NXT_DEL;                                       // TST_NXT_DEL: Задержка перед следующей позицией, сек
  _inputs._MS_MGC                   = Inp__MS_MGC;                                            // MS_MGC: Expert Adviser ID - Magic
  _inputs._MS_EGP                   = Inp__MS_EGP;                                            // MS_EGP: Expert Adviser Global Prefix
  _inputs._MS_LOG_LL                = Inp__MS_LOG_LL;                                         // MS_LOG_LL: Log Level
  _inputs._MS_LOG_FI                = Inp__MS_LOG_FI;                                         // MS_LOG_FI: Log Filter IN String (use `;` as sep)
  _inputs._MS_LOG_FO                = Inp__MS_LOG_FO;                                         // MS_LOG_FO: Log Filter OUT String (use `;` as sep)
  _inputs._MS_COM_EN                = Inp__MS_COM_EN;                                         // MS_COM_EN: Comment Enable (turn off for fast testing)
  _inputs._MS_COM_IS                = Inp__MS_COM_IS;                                         // MS_COM_IS: Comment Interval, Sec
  _inputs._MS_COM_CW                = Inp__MS_COM_CW;                                         // MS_COM_CW: Comment Custom Window
  _inputs._MS_TIM_MS                = Inp__MS_TIM_MS;                                         // MS_TIM_MS: Timer Interval, ms
}


//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
void CMGABotInputs::CMGABotInputs():
       SET_SYM_LST(""),
       SET_LOT_RAT(2.0),
       SET_LOT_NXS(7),
       SET_LOT_NXR(1.5),
       SET_MTP_RRD(2.0),
       SET_HSL_RAT(0.333),
       SET_TRD_REP(5),
       SET_TRD_RET(2000),
       _NTF_ALM_ENB(true),
       _NTF_EML_ENB(false),
       _NTF_PUS_ENB(false),
       _GRH_POS_ENB(true),
       _GRH_POS_FIL(true),
       _GRH_POS_SLC(clrLightPink),
       _GRH_POS_TPC(clrLightGreen),
       _GRH_HED_WTH(2),
       _GRH_HED_SLC(clrRed),
       _GRH_HED_TPC(clrGreen),
       _TST_1ST_DT(D'2025-01-21 12:05:05'),
       _TST_1ST_DIR(POSITION_TYPE_BUY),
       _TST_1ST_LOT(1.0),
       _TST_1ST_SLD(200),
       _TST_1ST_RR(2.5),
       _TST_NXT_DEL(5*60*60),
       _MS_MGC(20250321),
       _MS_EGP("MGA"),
       _MS_LOG_LL(INFO),
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
  if(!(SET_LOT_RAT>0.0)) LastErrorMessage = "'SET_LOT_RAT' must satisfy condition: SET_LOT_RAT>0.0";
  if(!(SET_LOT_NXS>0)) LastErrorMessage = "'SET_LOT_NXS' must satisfy condition: SET_LOT_NXS>0";
  if(!(SET_LOT_NXR>0.0)) LastErrorMessage = "'SET_LOT_NXR' must satisfy condition: SET_LOT_NXR>0.0";
  if(!(SET_MTP_RRD>0.0)) LastErrorMessage = "'SET_MTP_RRD' must satisfy condition: SET_MTP_RRD>0.0";
  if(!(SET_HSL_RAT>0.0)) LastErrorMessage = "'SET_HSL_RAT' must satisfy condition: SET_HSL_RAT>0.0";
  if(!(_GRH_HED_WTH>0)) LastErrorMessage = "'_GRH_HED_WTH' must satisfy condition: _GRH_HED_WTH>0";
  if(!(_TST_1ST_LOT>0.0)) LastErrorMessage = "'_TST_1ST_LOT' must satisfy condition: _TST_1ST_LOT>0.0";
  if(!(_TST_1ST_SLD>0)) LastErrorMessage = "'_TST_1ST_SLD' must satisfy condition: _TST_1ST_SLD>0";
  if(!(_TST_1ST_RR>0.0)) LastErrorMessage = "'_TST_1ST_RR' must satisfy condition: _TST_1ST_RR>0.0";
  if(!(_TST_NXT_DEL>0)) LastErrorMessage = "'_TST_NXT_DEL' must satisfy condition: _TST_NXT_DEL>0";

  return LastErrorMessage == "";
}
// GENERATED CODE == END == DO NOT REMOVE THIS COMMENT



