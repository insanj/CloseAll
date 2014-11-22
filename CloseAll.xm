#import "CloseAll.h"

static NSString *kCloseAllNotificationName = @"CloseAll.Notification";
static CAAlertView *closeAllAlertView;

%hook DimmingButton

- (id)initWithFrame:(CGRect)frame{
	DimmingButton *button = (DimmingButton *) %orig();

	UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:button action:@selector(closeAll_longPressRecognized:)];
	[button addGestureRecognizer:longPress];
	[longPress release];

	return button;
}

%new - (void)closeAll_longPressRecognized:(UILongPressGestureRecognizer *)sender {
	if (sender.state == UIGestureRecognizerStateBegan) {
		CALOG(@"Detected long-press on close button, sending notification to close all tabs...");
		[[NSDistributedNotificationCenter defaultCenter] postNotificationName:kCloseAllNotificationName object:nil];
	}
}

%end

%hook TiltedTabView

- (BOOL)_gestureRecognizer:(UIPanGestureRecognizer *)arg1 shouldInteractWithItem:(id)arg2 {
	CGFloat xOffset = [arg1 locationInView:arg1.view].x;
	NSMutableArray *targets = MSHookIvar<NSMutableArray *>(arg1, "_targets");
	NSString *actionString = NSStringFromSelector(MSHookIvar<SEL>(targets[0], "_action"));

	if ([actionString isEqualToString:@"_tabCloseRecognized:"] && xOffset < arg1.view.frame.size.width / 4.0 && xOffset > arg1.view.frame.size.width / 8.0) {
		CALOG(@"Detected right gesture on tab view, sending notification to close all tabs...");
		[[NSDistributedNotificationCenter defaultCenter] postNotificationName:kCloseAllNotificationName object:nil];
	}

	return %orig();
}

%end

%hook TabController

- (id)init {
	TabController *controller = (TabController *) %orig();
	[[NSDistributedNotificationCenter defaultCenter] addObserver:controller selector:@selector(closeAll_promptCloseAllTabs) name:kCloseAllNotificationName object:nil];
	return controller;
}

%new -(void)closeAll_promptCloseAllTabs {
	CALOG(@"Caught notification to close all tabs, prompting user and slinking away");

	if (closeAllAlertView.visible) {
		[closeAllAlertView dismissWithClickedButtonIndex:closeAllAlertView.cancelButtonIndex animated:NO];
	}

	else if (!closeAllAlertView.safariTabController) {
		closeAllAlertView.safariTabController = self;
		[closeAllAlertView show];
	}

	else {
		closeAllAlertView = [[CAAlertView alloc] initWithTabController:self];
		[closeAllAlertView show];
	}
}

- (void)dealloc {
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self name:kCloseAllNotificationName object:nil];
	%orig();
}

%end

@implementation CAAlertView

- (instancetype)initWithTabController:(TabController *)tabController {
	self = [super initWithTitle:@"CloseAll" message:@"Are you sure you'd like to close all open tabs?" delegate:nil cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];

	if (self) {
		self.safariTabController = tabController;
	}

	return self;
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
	if (buttonIndex != [self cancelButtonIndex]) {
		[self.safariTabController closeAllOpenTabsAnimated:YES];
	}

	[super dismissWithClickedButtonIndex:buttonIndex animated:animated];
}

@end
