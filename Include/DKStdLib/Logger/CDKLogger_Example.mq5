//+------------------------------------------------------------------+
//|                                            CDKLogger_Example.mq5 |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+
#property copyright "Denis Kislitsyn"
#property link      "https://kislitsyn.me"
#property version   "1.00"

#include <DKStdLib\Logger\CDKLogger.mqh>

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart() {
  CDKLogger logger;
  
  // STEP 1. Init Logger with "MyLoggerName" name and INFO level
  logger.Init("MyLoggerName", INFO);
  
  // You can change default logger format "%name%:[%level%] %message%" to your own
  // Use any pattern combination 
  logger.Format = "%YYYY%-%MM%-%DD% %hh%:%mm%-%ss% - %name%:[%level%] %message%"; 
  
  // STEP 2. If you like to filter message only with substrings,
  //         fill the FilterInList 
  // 2.1. Add a substrings to FilterIntList
  logger.FilterInList.Add("Including-Substring-#1");        
  logger.FilterInList.Add("Including-Substring-#2");        
  
  // 2.2. Split string by ";" separator to add all substrings to FilterInList in one line
  logger.FilterInFromStringWithSep("Including-Substring-#3;Including-Substring-#4", ";");  
  
  // STEP 3. If you like to filter OUT message with substings, but leave all others,
  //         fill the FilterOutList 
  // 3.1. Add a substings to FilterOutList
  logger.FilterOutList.Add("Excluding-Substring-#1");        
  logger.FilterOutList.Add("Excluding-Substring-#2");        
  
  // 3.2. Split string by ";" separator to add all substrings to FilterOutList in one line
  logger.FilterOutFromStringWithSep("Excluding-Substring-#3;Excluding-Substring-#4", ";");  // use Filter In put your filter str sep by ; here
  
  // STEP 4. Logging
  logger.Debug("Debug: Including-Substring-#1", false);                  // Debug with no Alert
  logger.Info("Info: Including-Substring-#1", true);                     // Info with Alert dialog
  logger.Warn("Warn: Including-Substring-#1"); 
  logger.Error("Error: Including-Substring-#1: Excluding-Substring-#1"); // Skipped because of FilterOutList
  logger.Critical("Critical: Including-Substring-#1");
  
  logger.Assert(true, 
                "Log msg if true", INFO,   // if ok
                "Log msg if false", ERROR, // if fails
                true);                     // Show Alert as well
  logger.Assert(true, 
                "Same msg for true & false", 
                INFO,   // Log level if ok
                ERROR,  // Log level if fails
                false); // No Alert   
}

logger.Debug(StringFormat("%s/%d: My message: PARAM1=%f",
                          __FUNCTION__, __LINE__,
                          my_param));
                          
if(DEBUG >= logger.Level)                          
  logger.Debug(StringFormat("%s/%d: My message: PARAM1=%f",
                            __FUNCTION__, __LINE__,
                            my_param));                          