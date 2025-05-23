//+------------------------------------------------------------------+
//|                                                  MGA-MT5-Bot.mq5 |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+

#property strict
#property script_show_inputs

#property version "2.05"
#property copyright "Denis Kislitsyn"
#property link "https://kislitsyn.me/personal/algo"
#property icon "/Images/favicon_64.ico"
#property description "2.05: [+] DEBUG загрузи позиций из истории построчно"
#property description "      [*] После открытия позиций их параметры больше не загружаются из истории"
#property description "2.04: [+] DEBUG загрузки MainPos из истории на новом шаге сетки с EP, SL, TP"
#property description "2.03: [+] DEBUG при открытии позиций на новом шаге сетки с EP, SL, TP"
#property description "2.02: [+] DEBUG лог поиска позиции в истории"
#property description "2.01: [+] DEBUG лог при SL"

#include "Include\DKStdLib\Logger\CDKLogger.mqh"
#include "Include\DKStdLib\TradingManager\CDKTrade.mqh"
#include "CMGABot.mqh"

CMGABot                         bot;
CDKTrade                        trade;
CDKLogger                       logger;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){  
  CMGABotInputs inputs;
  FillInputs(inputs);
  
  logger.Init(inputs._MS_EGP, inputs._MS_LOG_LL);
  logger.FilterInFromStringWithSep(inputs._MS_LOG_FI, ";");
  logger.FilterOutFromStringWithSep(inputs._MS_LOG_FO, ";");
  
  trade.Init(Symbol(), inputs._MS_MGC, inputs.SET_TRD_SLP, GetPointer(logger));

  bot.CommentEnable                = inputs._MS_COM_EN;
  bot.CommentIntervalSec           = inputs._MS_COM_IS;
  
  bot.Init(Symbol(), Period(), inputs._MS_MGC, trade, inputs._MS_COM_CW, inputs, GetPointer(logger));
  bot.SetFont("Courier New");
  bot.SetHighlightSelection(true);

  if (!bot.Check()) 
    return(INIT_PARAMETERS_INCORRECT);

  if(inputs._MS_TIM_MS >= 1000)
    EventSetTimer(inputs._MS_TIM_MS/1000);
  else
    EventSetMillisecondTimer(inputs._MS_TIM_MS);
  
  return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)  {
  bot.OnDeinit(reason);
  EventKillTimer();
}
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()  {
  bot.OnTick();
}

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()  {
  bot.OnTimer();
}

//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()  {
  bot.OnTrade();
}

//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result) {
  bot.OnTradeTransaction(trans, request, result);
}

double OnTester() {
  return bot.OnTester();
}

void OnChartEvent(const int id,
                  const long& lparam,
                  const double& dparam,
                  const string& sparam) {
  bot.OnChartEvent(id, lparam, dparam, sparam);                                    
}

