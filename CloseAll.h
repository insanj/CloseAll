#import <UIKit/UIKit.h>
#import "substrate.h"

#ifdef DEBUG
    #define CALOG(fmt, ...) NSLog((@"[CloseAll] %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
    #define CALOG(fmt, ...) 
#endif

@interface DimmingButton : UIButton

@end

@interface DimmingButton (CloseAll)

- (void)closeAll_longPressRecognized:(UILongPressGestureRecognizer *)sender;

@end

@interface TabController : NSObject

- (void)tiltedTabViewDidPresent:(id)arg1; // TiltedTabView
- (void)tiltedTabViewDidDismiss:(id)arg1;

// - (id)init
// - (id)initWithBrowserController

// ios 7
- (void)closeAllOpenTabsAnimated:(BOOL)arg1;

// ios 8
- (void)closeAllOpenTabsAnimated:(BOOL)arg1 exitTabView:(id)arg2;

@end

@interface TabController (CloseAll)

- (void)closeAll_promptCloseAllTabs:(NSNotification *)notification;

@end

@interface CAAlertView : UIAlertView

@property (strong, nonatomic) TabController *safariTabController;

- (instancetype)initWithTabController:(TabController *)tabController;

@end
