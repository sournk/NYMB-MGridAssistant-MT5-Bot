//+------------------------------------------------------------------+
//|                                                   MBookPanel.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#include "Node.mqh"
//+------------------------------------------------------------------+
//|   Text of market book                                            |
//+------------------------------------------------------------------+
class CBookText : public CNode
  {
public:
                     CBookText();
   virtual void Show();
   void SetXDist(long x);
   void SetYDist(long y);
   void SetText(string text);
                    ~CBookText();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CBookText::CBookText(void)
  {
   
  }
  
void CBookText::Show()
{
   ObjectCreate(ChartID(),m_name,OBJ_LABEL,0,0,0);
   ObjectSetInteger(ChartID(),m_name,OBJPROP_XDISTANCE,95);
   ObjectSetInteger(ChartID(),m_name,OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(ChartID(),m_name,OBJPROP_YDISTANCE,0);
   ObjectSetInteger(ChartID(),m_name,OBJPROP_COLOR,clrBlack);
   ObjectSetString(ChartID(),m_name,OBJPROP_TEXT,"MarketBook");
   ObjectSetString(ChartID(),m_name,OBJPROP_FONT,"Microsoft Sans Serif");
}
CBookText::~CBookText(void)
{
   ObjectDelete(ChartID(), m_name);
}

void CBookText::SetText(string text)
{
   ObjectSetString(ChartID(),m_name,OBJPROP_TEXT, text);
}
void CBookText::SetYDist(long y)
{
   ObjectSetInteger(ChartID(),m_name,OBJPROP_YDISTANCE,y);
}
void CBookText::SetXDist(long x)
{
   ObjectSetInteger(ChartID(),m_name,OBJPROP_XDISTANCE, x);
}
//+------------------------------------------------------------------+
