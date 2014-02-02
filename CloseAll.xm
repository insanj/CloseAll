#include <substrate.h>

@interface NSDistributedNotificationCenter : NSNotificationCenter
@end

@interface DimmingButton : UIButton
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

@interface TabController : NSObject
- (void)closeAllOpenTabsAnimated:(_Bool)arg1;
@end

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