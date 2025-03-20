//+------------------------------------------------------------------+
//|                                                         Node.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"

#include <Object.mqh>
#include <Arrays\ArrayObj.mqh>
#define NAME_SIZE 8
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CNode : public CObject
  {
private:
   static int m_count;
protected:
   string            m_name;
                     CNode();
   CArrayObj         m_elements;
   virtual void      OnShow();
   virtual void      OnHide();
public:
   virtual void      Show();
   virtual void      Hide();
   virtual void Event(int id,long lparam,double dparam,string sparam){;}
   virtual void Refresh();
                    ~CNode();
  };
static int CNode::m_count = 0;
//+------------------------------------------------------------------+
//|  Generate random uniq name                                       |
//+------------------------------------------------------------------+
CNode::CNode()
  {
   m_count++;
   uchar name[NAME_SIZE];
   for(int i=0; i<NAME_SIZE; i++)
      name[i]=(uchar)(MathRand()%255);
   m_name=CharArrayToString(name);
   m_name = CharArrayToString(name) + "_" + ((string)m_count);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CNode::Show(void)
  {
   OnShow();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CNode::~CNode(void)
  {
   OnHide();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CNode::OnShow(void)
  {
   for(int i=0; i<m_elements.Total(); i++)
     {
      CNode *node=m_elements.At(i);
      node.Show();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CNode::Hide(void)
  {
   OnHide();
   ObjectDelete(ChartID(),m_name);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CNode::OnHide(void)
  {
   for(int i=0; i<m_elements.Total(); i++)
     {
      CNode *node=m_elements.At(i);
      node.Hide();
     }

  }
void CNode::Refresh(void)
{
   for(int i=0; i<m_elements.Total(); i++)
   {
      CNode *node=m_elements.At(i);
      node.Refresh();
   }
}
//+------------------------------------------------------------------+
