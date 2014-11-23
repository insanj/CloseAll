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
		CALOG(@"Detected long-press on close button, sending notification to close all tabs...");
		[[NSNotificationCenter defaultCenter] postNotificationName:kCloseAllNotificationName object:nil];
	}
}

%end

%hook TabController

- (void)tiltedTabViewDidPresent:(id)arg1 {
	%orig(arg1);
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeAll_promptCloseAllTabs:) name:kCloseAllNotificationName object:nil];
}

-(void)tiltedTabViewDidDismiss:(id)arg1 {
	%orig(arg1);
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kCloseAllNotificationName object:nil];
}

%new - (void)closeAll_promptCloseAllTabs:(NSNotification *)notification {
	CALOG(@"Caught notification to close all tabs, prompting user and slinking away");
	CAAlertView *closeAllAlertView = [[[CAAlertView alloc] initWithTabController:self] autorelease];
	[closeAllAlertView show];
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
		if ([self.safariTabController respondsToSelector:@selector(closeAllOpenTabsAnimated:)]) {
			[self.safariTabController closeAllOpenTabsAnimated:YES];
		}

		else {
			[self.safariTabController closeAllOpenTabsAnimated:YES exitTabView:[%c(TiltedTabView) new]];
		}
	}

	[super dismissWithClickedButtonIndex:buttonIndex animated:animated];
}

@end
