#include <substrate.h>

@interface NSDistributedNotificationCenter : NSNotificationCenter
@end

@interface DimmingButton : UIButton
@end

@interface TiltedTabView : UIView <UIScrollViewDelegate>
-(BOOL)_gestureRecognizer:(UIPanGestureRecognizer *)arg1 shouldInteractWithItem:(id)arg2;
@end

@interface TabController : NSObject
-(void)closeAllOpenTabsAnimated:(_Bool)arg1;
@end

%hook DimmingButton

-(id)initWithFrame:(CGRect)frame{
	DimmingButton *button = (DimmingButton *) %orig();
	UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:button action:@selector(ca_longPress:)];
	[button addGestureRecognizer:longPress];
	[longPress release];
	return button;
}

%new -(void)ca_longPress:(UILongPressGestureRecognizer *)sender{
	NSLog(@"[CloseAll] Detected long-press on close button, sending notification to close all tabs...");
	if(sender.state == UIGestureRecognizerStateEnded)
		[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"CLCloseAllTabs" object:nil];
}

%end

%hook TiltedTabView

-(BOOL)_gestureRecognizer:(UIPanGestureRecognizer *)arg1 shouldInteractWithItem:(id)arg2{
	
	CGFloat xOffset = [arg1 locationInView:arg1.view].x;
	NSMutableArray *targets = MSHookIvar<NSMutableArray *>(arg1, "_targets");
	NSString *actionString = NSStringFromSelector(MSHookIvar<SEL>(targets[0], "_action"));

	NSLog(@"-=-=-=-=-=-=-=- xOfffff: %f, width : %f, action : %@", xOffset, arg1.view.frame.size.width, actionString);

	if([actionString isEqualToString:@"_tabCloseRecognized:"] && xOffset < arg1.view.frame.size.width / 4.0 && xOffset > arg1.view.frame.size.width / 8.0){
		NSLog(@"[CloseAll] Detected right gesture on tab view, sending notification to close all tabs...");
		[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"CLCloseAllTabs" object:nil];
	}

	return %orig();
}

%end


%hook TabController

-(id)init{
	TabController *controller = (TabController *)%orig();
	[[NSDistributedNotificationCenter defaultCenter] addObserver:controller selector:@selector(cl_closeAllTabs) name:@"CLCloseAllTabs" object:nil];
	return controller;
}

%new -(void)cl_closeAllTabs{
	NSLog(@"[CloseAll] Caught notification to close all tabs, doing so now!");
	[self closeAllOpenTabsAnimated:YES];
}

-(void)dealloc{
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self name:@"CLCloseAllTabs" object:nil];
	%orig();
}

%end