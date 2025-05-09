//+------------------------------------------------------------------+
//|                                                CDKCommentWnd.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+
#property copyright "Denis Kislitsyn"
#property link      "https://kislitsyn.me"

#include <Controls\Dialog.mqh>
#include "MaximizableAppDialog.mqh"
#include "..\Controls\CDKListView.mqh"

//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
//--- indents and gaps
//#define INDENT_LEFT                         (10)      // indent from left (with allowance for border width)
//#define INDENT_TOP                          (5)      // indent from top (with allowance for border width)
//#define INDENT_RIGHT                        (10)      // indent from right (with allowance for border width)
//#define INDENT_BOTTOM                       (10)      // indent from bottom (with allowance for border width)
//#define CONTROLS_GAP_X                      (2)       // gap by X coordinate
//#define CONTROLS_GAP_Y                      (2)       // gap by Y coordinate
//
//#define LABEL_HEIGHT                        (20)      // size by Y coordinate
//
////--- for buttons
//#define BUTTON_WIDTH                        (170)//(100)     // size by X coordinate
//#define BUTTON_HEIGHT                       (20) //(50)      // size by Y coordinate
//
////--- for the indication area
//#define EDIT_HEIGHT                         (20)//(50)      // size by Y coordinate
//
////--- for group controls
//#define GROUP_WIDTH                         (310)     // size by X coordinate
//#define LIST_HEIGHT                         (179)     // size by Y coordinate
//#define RADIO_HEIGHT                        (56)      // size by Y coordinate
//#define CHECK_HEIGHT                        (93)      // size by Y coordinate


//+------------------------------------------------------------------+
//| Class CDKCommentWnd                                            |
//| Usage: main dialog of the Controls application                   |
//+------------------------------------------------------------------+
class CDKCommentWnd : public MaximizableAppDialog {
public:
                     CDKCommentWnd(void);
                    ~CDKCommentWnd(void);
   //--- create
   virtual bool      Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);
                            
   void              BringToFront();                            
   //--- chart event handler
   virtual bool      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);

   void              OnTick(void);
   
   color             CDKCommentWnd::GetItemColor(CArrayLong& _clr_arr, const int _index);
protected:
  long               Chart;
  int                SubWin; 
  int                ObjectCnt;  
  
  CDKListView        ListView;
  bool               CDKCommentWnd::CreateListView(void);
  
public:
  void               CDKCommentWnd::SetFont(const string _font_name);
  void               CDKCommentWnd::SetHighlightSelection(const bool _highlight_selection_flag);
  bool               CDKCommentWnd::ShowText(string _text, CArrayLong& _clr_arr, CArrayLong& _bgr_clr_arr);
  
  bool               CDKCommentWnd::OnCADragStart(void);
  bool               CDKCommentWnd::OnCADragProcess(void);
  bool               CDKCommentWnd::OnCADragEnd(void);
  
  void               CDKCommentWnd::SelfAdjustment(const bool restore = false);
  
};

//+------------------------------------------------------------------+
//| Event Handling                                                   |
//+------------------------------------------------------------------+
EVENT_MAP_BEGIN(CDKCommentWnd)

//ON_EVENT(ON_CLICK,m_button_cleanup,OnClick_m_button_cleanup)
//ON_EVENT(ON_CLICK,m_button_fibo_base_refresh,OnClick_m_button_fibo_base_refresh)
//ON_EVENT(ON_CLICK,m_button_fibo_base_select_last,OnClick_m_button_fibo_base_select_last)
//ON_EVENT(ON_CLICK,m_button_fibo_base_draw,OnClick_m_button_fibo_base_draw)
//ON_EVENT(ON_CLICK,m_button_fibo_base_remove,OnClick_m_button_fibo_base_remove)
//ON_EVENT(ON_CHANGE,m_combo_box_fibo_base,OnChange_m_combo_box_fibo_base)
//
//ON_EVENT(ON_CLICK,m_button_fibo_set_refresh,OnClick_m_button_fibo_set_refresh)
//ON_EVENT(ON_CLICK,m_button_fibo_set_select_last,OnClick_m_button_fibo_set_select_last)
//ON_EVENT(ON_CLICK,m_button_fibo_set_trade,OnClick_m_button_fibo_set_trade)
//ON_EVENT(ON_CLICK,m_button_fibo_set_remove,OnClick_m_button_fibo_set_remove)
//ON_EVENT(ON_CLICK,m_button_fibo_set_calc_crv,OnClick_m_button_fibo_set_calc_crv)
//ON_EVENT(ON_CHANGE,m_combo_box_fibo_set,OnChange_m_combo_box_fibo_set)
//
//ON_EVENT(ON_CLICK,m_button_delete_bid_stop,OnClick_m_button_delete_bid_stop)

//ON_EVENT(ON_CHANGE,m_radio_group_order_type,OnChange_m_radio_group_order_type)
EVENT_MAP_END(MaximizableAppDialog)

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CDKCommentWnd::CDKCommentWnd(void) {
}
  
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CDKCommentWnd::~CDKCommentWnd(void)  {
  int left = Left();
  string left_name = StringFormat("%s_%s_WND_X1", m_program_name, Symbol());
  GlobalVariableSet(StringFormat("%s_%s_WND_X1", m_program_name, Symbol()), Left());
  GlobalVariableSet(StringFormat("%s_%s_WND_Y1", m_program_name, Symbol()), Top());
  GlobalVariableSet(StringFormat("%s_%s_WND_X2", m_program_name, Symbol()), Left() + Width());
  GlobalVariableSet(StringFormat("%s_%s_WND_Y2", m_program_name, Symbol()), Top() + Height());
}
  
//+------------------------------------------------------------------+
//| Create                                                           |
//+------------------------------------------------------------------+
bool CDKCommentWnd::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2) {
  // Load from glob var wnd pos if Home not pressed
  double x1_f = 0.0;
  double x2_f = 0.0;
  double y1_f = 0.0;
  double y2_f = 0.0;
  if(TerminalInfoInteger(TERMINAL_KEYSTATE_HOME) == 0) {
    GlobalVariableGet(StringFormat("%s_%s_WND_X1", name, Symbol()), x1_f);
    GlobalVariableGet(StringFormat("%s_%s_WND_Y1", name, Symbol()), y1_f);
    GlobalVariableGet(StringFormat("%s_%s_WND_X2", name, Symbol()), x2_f);
    GlobalVariableGet(StringFormat("%s_%s_WND_Y2", name, Symbol()), y2_f);  
  }
  
  if((x1_f == 0.0 || x2_f == 0.0 || y1_f == 0.0 || y2_f == 0.0) ||
     (((x2-x1) > (x2_f-x1_f)) || ((y2-y1) > (y2_f-y1_f)))) {
    x1_f = x1; x2_f = x2;
    y1_f = y1; y2_f = y2;
  }    

  Chart = chart;
  SubWin = subwin;
  ObjectCnt = 0;
    
  if(!MaximizableAppDialog::Create(chart,name,subwin,(int)x1_f,(int)y1_f,(int)x2_f,(int)y2_f))
    return(false);
      
  if(!CreateListView()) 
    return(false);
    

  return(true);
}
  
void CDKCommentWnd::BringToFront() {
  Hide();
  Show();
}


void CDKCommentWnd::SetFont(const string _font_name) {
  ListView.Font(_font_name);
}

void CDKCommentWnd::SetHighlightSelection(const bool _highlight_selection_flag) {
  ListView.HighlightSelection(_highlight_selection_flag);
}

//+------------------------------------------------------------------+
//| Create the "ListView" element                                    |
//+------------------------------------------------------------------+
bool CDKCommentWnd::CreateListView(void)  {
//--- coordinates
  int INDENT_LEFT = 10;//                        (10)      // indent from left (with allowance for border width)
  int INDENT_TOP = 5; //                         (5)      // indent from top (with allowance for border width)
  int INDENT_RIGHT = 10; //                        (10)      // indent from right (with allowance for border width)
  int INDENT_BOTTOM = 10; //                      (10)      // indent from bottom (with allowance for border width)
  int CONTROLS_GAP_X = 2; //                     (2)       // gap by X coordinate
  int CONTROLS_GAP_Y = 2; //                     (2)       // gap by Y coordinate   
   int x1=CONTROLS_GAP_X;
   int y1=CONTROLS_GAP_Y;
   int x2=Width()-INDENT_RIGHT;
   int y2=Height()-CONTROLS_DIALOG_CAPTION_HEIGHT-INDENT_BOTTOM;
//--- create
   if(!ListView.Create(m_chart_id,m_name+"ListView",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!Add(ListView))
      return(false);
//--- succeed

   return(true);
  }  

color CDKCommentWnd::GetItemColor(CArrayLong& _clr_arr, const int _index) {
  if(_index < _clr_arr.Total())
    return (color)_clr_arr.At(_index);
    
  return 0;
}

bool CDKCommentWnd::ShowText(string _text, CArrayLong& _clr_arr, CArrayLong& _bgr_clr_arr) {
  ListView.ItemsClear();
  
  string lines[];
  StringSplit(_text, StringGetCharacter("\n", 0), lines);
  
  for(int i=0;i<ArraySize(lines);i++)    {
    ListView.AddItem(lines[i], 0, GetItemColor(_clr_arr, i), GetItemColor(_bgr_clr_arr, i));   
  }
  
  return true;
}
  
void CDKCommentWnd::OnTick(void){
  int obj_cnt = ObjectsTotal(Chart, SubWin);
  if(obj_cnt == ObjectCnt) return;
  
  ObjectCnt = obj_cnt;
  BringToFront();
}

bool CDKCommentWnd::OnCADragStart(void){
  return true;
}

bool CDKCommentWnd::OnCADragProcess(void){
  return true;
}

bool CDKCommentWnd::OnCADragEnd(void){
  return true;
}

void CDKCommentWnd::SelfAdjustment(const bool restore = false){
  CSize size;
  size.cx = ClientAreaWidth();
  size.cy = ClientAreaHeight();
  //m_main.Size(size);
  //m_main.Pack();

  int INDENT_LEFT = 10;//                        (10)      // indent from left (with allowance for border width)
  int INDENT_TOP = 5; //                         (5)      // indent from top (with allowance for border width)
  int INDENT_RIGHT = 10; //                        (10)      // indent from right (with allowance for border width)
  int INDENT_BOTTOM = 10; //                      (10)      // indent from bottom (with allowance for border width)
  int CONTROLS_GAP_X = 2; //                     (2)       // gap by X coordinate
  int CONTROLS_GAP_Y = 2; //                     (2)       // gap by Y coordinate   
  int x1=CONTROLS_GAP_X;
  int y1=CONTROLS_GAP_Y;
  int x2=Width()-INDENT_RIGHT;
  int y2=Height()-CONTROLS_DIALOG_CAPTION_HEIGHT-INDENT_BOTTOM;
  ListView.Width(x2);
  ListView.Height(y2);
}
