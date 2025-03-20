//+------------------------------------------------------------------+
//|                                               CDKArrayString.mqh |
//|                                                  Denis Kislitsyn |
//|                                               http:/kislitsyn.me |
//+------------------------------------------------------------------+

#include <Arrays\ArrayString.mqh>
#include <Generic\HashMap.mqh>

class CDKArrayString : public CArrayString {
public:
  int                     CDKArrayString::SaveToArray(string& _arr[]);
  int                     CDKArrayString::SaveToHashSet(CHashSet<string>& _set);
};

int CDKArrayString::SaveToArray(string& _arr[]){
  int size = Total();
  ArrayResize(_arr, size);
  for(int i=0;i<size;i++)
    _arr[i] = At(i);
    
  return size;
}

int CDKArrayString::SaveToHashSet(CHashSet<string>& _set){
  int size = Total();
  for(int i=0;i<size;i++)
    _set.Add(At(i));
    
  return _set.Count();
}

