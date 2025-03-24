#include "CMGAGrid.mqh"


class CMGAGridList {
protected:
  CArrayObj                GridList;
public:
  void                     CMGAGridList::~CMGAGridList(void);
  
  void                     CMGAGridList::Add(CMGAGrid*& _grid);
  void                     CMGAGridList::Delete(const int _idx);
  int                      CMGAGridList::Total() { return GridList.Total(); };
  void                     CMGAGridList::Clear() { GridList.Clear(); };
  
  CMGAGrid*                operator[](const int _idx);
};

//+------------------------------------------------------------------+
//| Destructor
//+------------------------------------------------------------------+
void CMGAGridList::~CMGAGridList(void){
  this.Clear();
}

//+------------------------------------------------------------------+
//| Add pos to list
//+------------------------------------------------------------------+
void CMGAGridList::Add(CMGAGrid*& _grid) {
  GridList.Add(_grid);
}

//+------------------------------------------------------------------+
//| Delete pos from list
//+------------------------------------------------------------------+
void CMGAGridList::Delete(const int _idx) {
  GridList.Delete(_idx);
}

//+------------------------------------------------------------------+
//| Get by index
//+------------------------------------------------------------------+
CMGAGrid* CMGAGridList::operator[](const int _idx) {
  return GridList.At(_idx);
}