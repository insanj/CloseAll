#import <UIKit/UIKit.h>
#import <Foundation/NSDistributedNotificationCenter.h>
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

@interface TiltedTabView : UIView <UIScrollViewDelegate>

- (BOOL)_gestureRecognizer:(UIPanGestureRecognizer *)arg1 shouldInteractWithItem:(id)arg2;

@end

@interface TabController : NSObject

- (void)closeAllOpenTabsAnimated:(BOOL)arg1;

@end

@interface TabController (CloseAll)

- (void)closeAll_promptCloseAllTabs;

@end

@interface CAAlertView : UIAlertView

@property (strong, nonatomic) TabController *safariTabController;

- (instancetype)initWithTabController:(TabController *)tabController;

@end
