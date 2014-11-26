#import "CloseAll.h"

static NSString *kCloseAllNotificationName = @"CloseAll.Notification";

%hook DimmingButton

- (id)initWithFrame:(CGRect)frame {
	DimmingButton *dimmingButton = (DimmingButton *) %orig();

	UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:dimmingButton action:@selector(closeAll_longPressRecognized:)];
	[dimmingButton addGestureRecognizer:longPress];
	[longPress release];

	return dimmingButton;
}

%new - (void)closeAll_longPressRecognized:(UILongPressGestureRecognizer *)sender {
	if (sender.state == UIGestureRecognizerStateBegan) {
		CALOG(@"Detected long-press on close button, sending notification to prompt user...");
		[[NSNotificationCenter defaultCenter] postNotificationName:kCloseAllNotificationName object:nil];
	}
}

%end

%hook TabController

// iOS 7
- (id)init {
	TabController *tabController = (TabController *) %orig();
	[[NSNotificationCenter defaultCenter] addObserver:tabController selector:@selector(closeAll_promptCloseAllTabs:) name:kCloseAllNotificationName object:nil];
	return tabController;
}

// iOS 8
- (id)initWithBrowserController:(id)arg1 {
	TabController *tabController = (TabController *) %orig(arg1);
	[[NSNotificationCenter defaultCenter] addObserver:tabController selector:@selector(closeAll_promptCloseAllTabs:) name:kCloseAllNotificationName object:nil];
	return tabController;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kCloseAllNotificationName object:nil];
	%orig();
}

%new - (void)closeAll_promptCloseAllTabs:(NSNotification *)notification {
	CALOG(@"Caught notification to close all tabs, prompting user and slinking away");
	CAAlertView *closeAllAlertView = [[[CAAlertView alloc] initWithTabController:self] autorelease];
	[closeAllAlertView show];
}

%end

@implementation CAAlertView

- (instancetype)initWithTabController:(TabController *)tabController {
	self = [super initWithTitle:@"CloseAll" message:@"Are you sure you'd like to close all open tabs?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];

	if (self) {
		self.safariTabController = tabController;
		CALOG(@"Created new alert view with TabController: %@", self.safariTabController);
	}

	return self;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	CALOG(@"Heard clicked button on %@ at index %i", alertView, (int)buttonIndex);
	if (buttonIndex != [alertView cancelButtonIndex]) {
		if ([self.safariTabController respondsToSelector:@selector(closeAllOpenTabsAnimated:)]) {
			[self.safariTabController closeAllOpenTabsAnimated:YES];
		}

		else {
			[self.safariTabController closeAllOpenTabsAnimated:YES exitTabView:[%c(TiltedTabView) new]];
		}
	}
}

@end
