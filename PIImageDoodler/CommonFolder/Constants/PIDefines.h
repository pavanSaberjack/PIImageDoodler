//
//  PIDefines.h
//  PIImageDoodler
//
//  Created by Pavan on 19/05/17.
//  Copyright © 2017 Pavan Itagi. All rights reserved.
//

#ifndef PIDefines_h
#define PIDefines_h

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog(fmt, ##__VA_ARGS__);
#   define ELog(err) {if(err) DLog(@"%@", err)}
#   define DLLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

#define MARK_FUNCTION_ENTERING DLog(@"Entering: %s", __PRETTY_FUNCTION__);
#define MARK_FUNCTION_EXITING DLog(@"Leaving: %s", __PRETTY_FUNCTION__);

#else
#   define DLog(...)
#   define ELog(err)
#endif

// Constants
#define IS_IOS_7 ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0 && [[UIDevice currentDevice].systemVersion floatValue] < 8.0)
#define IS_IOS8_AND_UP ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)
#define IS_IOS9_AND_UP ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0)

#define SCREEN_SIZE [[UIScreen mainScreen] bounds]           // includes the status bar
#define VIEW_FRAME  [[UIScreen mainScreen] applicationFrame] // minus the status bar

#endif /* PIDefines_h */
