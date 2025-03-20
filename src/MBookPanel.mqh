//+------------------------------------------------------------------+
//|                                                   MBookPanel.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#include "MarketBook.mqh"
#include "Node.mqh"
#include "MBookText.mqh"
#include "MBookFon.mqh"
//+------------------------------------------------------------------+
//| CBookPanel class                                                 |
//+------------------------------------------------------------------+
class CBookPanel : public CNode
  {
private:
   CMarketBook       m_book;
   bool              m_showed;
   CBookText         m_text;
public:
   CBookPanel();
   ~CBookPanel();
   virtual void Refresh();
   virtual void Event(int id, long lparam, double dparam, string sparam);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CBookPanel::CBookPanel()
{
   m_book.Refresh();
   m_text.Show();
   m_elements.Add(new CBookFon(GetPointer(m_book)));
   ObjectCreate(ChartID(), m_name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(ChartID(), m_name, OBJPROP_XDISTANCE, 80);
   ObjectSetInteger(ChartID(), m_name, OBJPROP_YDISTANCE, -3);
   ObjectSetInteger(ChartID(), m_name, OBJPROP_COLOR, clrBlack);
   ObjectSetString(ChartID(), m_name, OBJPROP_FONT, "Webdings");
   ObjectSetString(ChartID(), m_name, OBJPROP_TEXT, CharToString(0x36));
}
CBookPanel::~CBookPanel(void)
{
   OnHide();
   m_text.Hide();
   ObjectDelete(ChartID(), m_name);
}

void CBookPanel::Event(int id, long lparam, double dparam, string sparam)
{
   switch(id)
   {
      case CHARTEVENT_OBJECT_CLICK:
      {
         if(sparam != m_name)return;
         m_book.Refresh();
         if(!m_showed)OnShow();        
         else OnHide();
         m_showed = !m_showed;
      }
   }
}

void CBookPanel::Refresh()
{
   m_book.Refresh();
   CNode::Refresh();
}
//+------------------------------------------------------------------+
