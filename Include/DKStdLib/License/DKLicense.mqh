//+------------------------------------------------------------------+
//|                                                    DKLicense.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+

// 2025-01-24: [*] TimeLocal instead TimeCurrent in license check

#property copyright "Denis Kislitsyn"
#property link      "https://kislitsyn.me"

#include "..\Common\DKDatetime.mqh"
#include "..\Common\md5hash.mqh"

string LicenseToString(const long aAccount, const datetime aDate, const string aSalt) {
  string query = StringFormat("%I64u:%s", aAccount, TimeToString(aDate, TIME_DATE));
  string quetySalted = query + aSalt;
  
  CMD5Hash md5;
  return query + ":" + md5.Hash(query);
}

bool IsLicenseValid(string aLicenseKeyToCheck, const long aAccount, const string aSalt) {
  string arr[];
  if (StringSplit(aLicenseKeyToCheck, StringGetCharacter(":", 0), arr) != 3) return false;
  
  datetime licenseKeyDT = StringToTime(arr[1]);
  if (TimeCurrent()> licenseKeyDT) return false;
  
  return LicenseToString(aAccount, licenseKeyDT, aSalt) == aLicenseKeyToCheck;
}

bool IsExpired(const long _allowed_period_sec) {
  if (_allowed_period_sec <= 0) return false;
  datetime dt_loc = TimeLocal();
  datetime dt_file = __DATETIME__;
  return (dt_loc > dt_file+_allowed_period_sec);
}

bool CheckExpiredAndShowMessage(const long _allowed_period_sec, string _formated_message = "") {
  bool res = IsExpired(_allowed_period_sec);
  datetime due_dt = (datetime)(__DATETIME__ + _allowed_period_sec);
  if (res) {
    if (_formated_message == "") _formated_message = "Allowed usage period has expired on %s";
    Alert(StringFormat(_formated_message, TimeToString(due_dt)));
  }
  return res;
}
