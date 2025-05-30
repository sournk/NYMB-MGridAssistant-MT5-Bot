//+------------------------------------------------------------------+
//|                                                   MarketBook.mq5 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots 1
#include "MarketBook.mqh"
#include "MBookPanel.mqh"

CBookPanel Panel;
double fake_buffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,fake_buffer,INDICATOR_CALCULATIONS);
   MarketBookAdd(Symbol());
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| MarketBook change event                                          |
//+------------------------------------------------------------------+
void OnBookEvent(const string &symbol)
  {
   Panel.Refresh();
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//| Chart events                                                     |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // идентификатор события  
                  const long& lparam,   // параметр события типа long
                  const double& dparam, // параметр события типа double
                  const string& sparam  // параметр события типа string
                  )
  {
   Panel.Event(id,lparam,dparam,sparam);
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
//---

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
