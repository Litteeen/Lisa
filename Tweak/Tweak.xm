#import "Lisa.h"

BOOL enabled;
BOOL enableCustomizationSection;

// test notifications
static BBServer* bbServer = nil;

static dispatch_queue_t getBBServerQueue() {

    static dispatch_queue_t queue;
    static dispatch_once_t predicate;

    dispatch_once(&predicate, ^{
    void* handle = dlopen(NULL, RTLD_GLOBAL);
        if (handle) {
            dispatch_queue_t __weak *pointer = (__weak dispatch_queue_t *) dlsym(handle, "__BBServerQueue");
            if (pointer) queue = *pointer;
            dlclose(handle);
        }
    });

    return queue;

}

static void fakeNotification(NSString *sectionID, NSDate *date, NSString *message, bool banner) {
    
	BBBulletin* bulletin = [[%c(BBBulletin) alloc] init];

	bulletin.title = @"Lisa";
    bulletin.message = message;
    bulletin.sectionID = sectionID;
    bulletin.bulletinID = [[NSProcessInfo processInfo] globallyUniqueString];
    bulletin.recordID = [[NSProcessInfo processInfo] globallyUniqueString];
    bulletin.publisherBulletinID = [[NSProcessInfo processInfo] globallyUniqueString];
    bulletin.date = date;
    bulletin.defaultAction = [%c(BBAction) actionWithLaunchBundleID:sectionID callblock:nil];
    bulletin.clearable = YES;
    bulletin.showsMessagePreview = YES;
    bulletin.publicationDate = date;
    bulletin.lastInterruptDate = date;

    if (banner) {
        if ([bbServer respondsToSelector:@selector(publishBulletin:destinations:)]) {
            dispatch_sync(getBBServerQueue(), ^{
                [bbServer publishBulletin:bulletin destinations:15];
            });
        }
    } else {
        if ([bbServer respondsToSelector:@selector(publishBulletin:destinations:alwaysToLockScreen:)]) {
            dispatch_sync(getBBServerQueue(), ^{
                [bbServer publishBulletin:bulletin destinations:4 alwaysToLockScreen:YES];
            });
        } else if ([bbServer respondsToSelector:@selector(publishBulletin:destinations:)]) {
            dispatch_sync(getBBServerQueue(), ^{
                [bbServer publishBulletin:bulletin destinations:4];
            });
        }
    }

}

void LSATestNotifications() {

    SpringBoard* springboard = (SpringBoard *)[objc_getClass("SpringBoard") sharedApplication];
	[springboard _simulateLockButtonPress];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        fakeNotification(@"com.apple.mobilephone", [NSDate date], @"Missed Call", false);
        fakeNotification(@"com.apple.Music", [NSDate date], @"ODESZA - For Us (feat. Briana Marela)", false);
        fakeNotification(@"com.apple.MobileSMS", [NSDate date], @"Hello, I'm Lisa", false);
        fakeNotification(@"com.apple.MobileSMS", [NSDate date], @"Hello, I'm Lisa", false);
        fakeNotification(@"com.apple.MobileSMS", [NSDate date], @"Hello, I'm Lisa", false);
        fakeNotification(@"com.apple.MobileSMS", [NSDate date], @"Hello, I'm Lisa", false);
    });

}

%group Lisa

%hook CSCoverSheetViewController

- (void)viewDidLoad { // add lisa

	%orig;

	if (!lisaView) {
		lisaView = [[UIView alloc] initWithFrame:[[self view] bounds]];
		[lisaView setBackgroundColor:[UIColor blackColor]];
		[lisaView setHidden:YES];
		if (![lisaView isDescendantOfView:[self view]]) [[self view] insertSubview:lisaView atIndex:0];
	}

}

- (void)viewDidDisappear:(BOOL)animated { // hide lisa when unlocked

    %orig;

    [lisaView setHidden:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"lisaUnhideElements" object:nil];

}

%end

%hook SBMainDisplayPolicyAggregator

- (BOOL)_allowsCapabilityLockScreenTodayViewWithExplanation:(id *)arg1 { // disable today swipe

    if (disableTodaySwipeSwitch)
		return NO;
	else
		return %orig;

}

- (BOOL)_allowsCapabilityTodayViewWithExplanation:(id *)arg1 { // disable today swipe

    if (disableTodaySwipeSwitch)
		return NO;
	else
		return %orig;

}

- (BOOL)_allowsCapabilityLockScreenCameraSupportedWithExplanation:(id *)arg1 { // disable camera swipe

    if (disableCameraSwipeSwitch)
		return NO;
	else
		return %orig;

}

- (BOOL)_allowsCapabilityLockScreenCameraWithExplanation:(id *)arg1 { // disable camera swipe

    if (disableCameraSwipeSwitch)
		return NO;
	else
		return %orig;

}

%end

%hook SBBacklightController

- (void)turnOnScreenFullyWithBacklightSource:(long long)arg1 { // show lisa based on user settings

	%orig;

    if (onlyWhenDNDIsActiveSwitch && isDNDActive) {
        if (whenNotificationArrivesSwitch && arg1 == 12) {
            [lisaView setHidden:NO];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"lisaHideElements" object:nil];
            return;
        } else if (whenPlayingMusicSwitch && ([[%c(SBMediaController) sharedInstance] isPlaying] || [[%c(SBMediaController) sharedInstance] isPaused])) {
            [lisaView setHidden:NO];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"lisaHideElements" object:nil];
            return;
        } else if (alwaysWhenNotificationsArePresentedSwitch && notificationCount > 0) {
            [lisaView setHidden:NO];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"lisaHideElements" object:nil];
            return;
        } else {
            [lisaView setHidden:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"lisaUnhideElements" object:nil];
            return;
        }
    } else if (!onlyWhenDNDIsActiveSwitch) {
        if (whenNotificationArrivesSwitch && arg1 == 12) {
            [lisaView setHidden:NO];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"lisaHideElements" object:nil];
            return;
        } else if (whenPlayingMusicSwitch && ([[%c(SBMediaController) sharedInstance] isPlaying] || [[%c(SBMediaController) sharedInstance] isPaused])) {
            [lisaView setHidden:NO];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"lisaHideElements" object:nil];
            return;
        } else if (alwaysWhenNotificationsArePresentedSwitch && notificationCount > 0) {
            [lisaView setHidden:NO];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"lisaHideElements" object:nil];
            return;
        } else {
            [lisaView setHidden:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"lisaUnhideElements" object:nil];
            return;
        }
    }

}

%end

%end

%group LisaVisibility

%hook UIStatusBar_Modern

- (void)setFrame:(CGRect)arg1 { // add notification observer

    if (hideStatusBarSwitch) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveHideNotification:) name:@"lisaHideElements" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveHideNotification:) name:@"lisaUnhideElements" object:nil];
    }

	return %orig;

}

%new
- (void)receiveHideNotification:(NSNotification *)notification { // receive notification and hide or unhide status bar

	if ([notification.name isEqual:@"lisaHideElements"])
        [[self statusBar] setHidden:YES];
	else if ([notification.name isEqual:@"lisaUnhideElements"])
        [[self statusBar] setHidden:NO];

}

- (void)dealloc { // remove observer
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
	%orig;

}

%end

%hook SBUIProudLockIconView

- (id)initWithFrame:(CGRect)frame { // add notification observer

    if (hideFaceIDLockSwitch) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveHideNotification:) name:@"lisaHideElements" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveHideNotification:) name:@"lisaUnhideElements" object:nil];
    }

	return %orig;

}

%new
- (void)receiveHideNotification:(NSNotification *)notification { // receive notification and hide or unhide faceid lock

	if ([notification.name isEqual:@"lisaHideElements"])
        [self setHidden:YES];
	else if ([notification.name isEqual:@"lisaUnhideElements"])
        [self setHidden:NO];

}

- (void)dealloc { // remove observer
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
	%orig;

}

%end

%hook SBFLockScreenDateView

- (id)initWithFrame:(CGRect)frame { // add notification observer

    if (hideTimeAndDateSwitch) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveHideNotification:) name:@"lisaHideElements" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveHideNotification:) name:@"lisaUnhideElements" object:nil];
    }

	return %orig;

}

%new
- (void)receiveHideNotification:(NSNotification *)notification { // receive notification and hide or unhide time and date

	if ([notification.name isEqual:@"lisaHideElements"])
        [self setHidden:YES];
	else if ([notification.name isEqual:@"lisaUnhideElements"])
        [self setHidden:NO];

}

- (void)dealloc { // remove observer
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
	%orig;

}

%end

%hook CSQuickActionsButton

- (id)initWithFrame:(CGRect)frame { // add notification observer

    if (hideQuickActionsSwitch) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveHideNotification:) name:@"lisaHideElements" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveHideNotification:) name:@"lisaUnhideElements" object:nil];
    }

	return %orig;

}

%new
- (void)receiveHideNotification:(NSNotification *)notification { // receive notification and hide or unhide quick actions

	if ([notification.name isEqual:@"lisaHideElements"])
        [self setHidden:YES];
	else if ([notification.name isEqual:@"lisaUnhideElements"])
        [self setHidden:NO];

}

- (void)dealloc { // remove observer
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
	%orig;

}

%end

%hook CSTeachableMomentsContainerView

- (id)initWithFrame:(CGRect)frame { // add notification observer

    if (hideControlCenterIndicatorSwitch || hideUnlockTextSwitch) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveHideNotification:) name:@"lisaHideElements" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveHideNotification:) name:@"lisaUnhideElements" object:nil];
    }

	return %orig;

}

%new
- (void)receiveHideNotification:(NSNotification *)notification { // receive notification and hide or unhide control center indicator and or unlock text

	if ([notification.name isEqual:@"lisaHideElements"]) {
        if (hideUnlockTextSwitch) {
            SBUILegibilityLabel* label = MSHookIvar<SBUILegibilityLabel *>(self, "_callToActionLabel");
            [label setHidden:YES];
        }
        if (hideControlCenterIndicatorSwitch) [[self controlCenterGrabberContainerView] setHidden:YES];
    } else if ([notification.name isEqual:@"lisaUnhideElements"]) {
        if (hideUnlockTextSwitch) {
            SBUILegibilityLabel* label = MSHookIvar<SBUILegibilityLabel *>(self, "_callToActionLabel");
            [label setHidden:NO];
        }
        if (hideControlCenterIndicatorSwitch) [[self controlCenterGrabberContainerView] setHidden:NO];
    }

}

- (void)dealloc { // remove observer
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
	%orig;

}

%end

%hook SBUICallToActionLabel

- (id)initWithFrame:(CGRect)frame { // add notification observer

    if (hideUnlockTextSwitch) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveHideNotification:) name:@"lisaHideElements" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveHideNotification:) name:@"lisaUnhideElements" object:nil];
    }

	return %orig;

}

%new
- (void)receiveHideNotification:(NSNotification *)notification { // receive notification and hide or unhide unlock text

	if ([notification.name isEqual:@"lisaHideElements"])
        [self setHidden:YES];
	else if ([notification.name isEqual:@"lisaUnhideElements"])
        [self setHidden:NO];

}

- (void)dealloc { // remove observer
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
	%orig;

}

%end

%hook CSHomeAffordanceView

- (id)initWithFrame:(CGRect)frame { // add notification observer

    if (hideHomebarSwitch) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveHideNotification:) name:@"lisaHideElements" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveHideNotification:) name:@"lisaUnhideElements" object:nil];
    }

	return %orig;

}

%new
- (void)receiveHideNotification:(NSNotification *)notification { // receive notification and hide or unhide homebar

	if ([notification.name isEqual:@"lisaHideElements"])
        [self setHidden:YES];
	else if ([notification.name isEqual:@"lisaUnhideElements"])
        [self setHidden:NO];

}

- (void)dealloc { // remove observer
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
	%orig;

}

%end

%hook CSPageControl

- (id)initWithFrame:(CGRect)frame { // add notification observer

    if (hidePageDotsSwitch) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveHideNotification:) name:@"lisaHideElements" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveHideNotification:) name:@"lisaUnhideElements" object:nil];
    }

	return %orig;

}

%new
- (void)receiveHideNotification:(NSNotification *)notification { // receive notification and hide or unhide homebar

	if ([notification.name isEqual:@"lisaHideElements"])
        [self setHidden:YES];
	else if ([notification.name isEqual:@"lisaUnhideElements"])
        [self setHidden:NO];

}

- (void)dealloc { // remove observer
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
	%orig;

}

%end

%end

%group LisaData

%hook NCNotificationMasterList

- (unsigned long long)notificationCount { // get notifications count

    notificationCount = %orig;

    return %orig;

}

%end

%hook DNDState

- (BOOL)isActive { // get dnd state

    isDNDActive = %orig;

    return %orig;

}

%end

%end

%group TestNotifications

%hook BBServer

- (id)initWithQueue:(id)arg1 {

    bbServer = %orig;
    
    return bbServer;

}

- (id)initWithQueue:(id)arg1 dataProviderManager:(id)arg2 syncService:(id)arg3 dismissalSyncCache:(id)arg4 observerListener:(id)arg5 utilitiesListener:(id)arg6 conduitListener:(id)arg7 systemStateListener:(id)arg8 settingsListener:(id)arg9 {
    
    bbServer = %orig;

    return bbServer;

}

- (void)dealloc {

    if (bbServer == self) bbServer = nil;

    %orig;

}

%end

%end

%ctor {

    preferences = [[HBPreferences alloc] initWithIdentifier:@"love.litten.lisapreferences"];

    [preferences registerBool:&enabled default:nil forKey:@"Enabled"];
    [preferences registerBool:&enableCustomizationSection default:nil forKey:@"EnableCustomizationSection"];

    // Customization
    [preferences registerBool:&onlyWhenDNDIsActiveSwitch default:NO forKey:@"onlyWhenDNDIsActive"];
    [preferences registerBool:&whenNotificationArrivesSwitch default:YES forKey:@"whenNotificationArrives"];
    [preferences registerBool:&alwaysWhenNotificationsArePresentedSwitch default:YES forKey:@"alwaysWhenNotificationsArePresented"];
    [preferences registerBool:&whenPlayingMusicSwitch default:YES forKey:@"whenPlayingMusic"];
    [preferences registerBool:&hideStatusBarSwitch default:YES forKey:@"hideStatusBar"];
    [preferences registerBool:&hideControlCenterIndicatorSwitch default:YES forKey:@"hideControlCenterIndicator"];
    [preferences registerBool:&hideFaceIDLockSwitch default:YES forKey:@"hideFaceIDLock"];
    [preferences registerBool:&hideTimeAndDateSwitch default:YES forKey:@"hideTimeAndDate"];
    [preferences registerBool:&hideQuickActionsSwitch default:YES forKey:@"hideQuickActions"];
    [preferences registerBool:&hideUnlockTextSwitch default:YES forKey:@"hideUnlockText"];
    [preferences registerBool:&hideHomebarSwitch default:YES forKey:@"hideHomebar"];
    [preferences registerBool:&hidePageDotsSwitch default:YES forKey:@"hidePageDots"];
    [preferences registerBool:&disableTodaySwipeSwitch default:NO forKey:@"disableTodaySwipe"];
    [preferences registerBool:&disableCameraSwipeSwitch default:NO forKey:@"disableCameraSwipe"];

    if (enabled) {
        %init(Lisa);
        if (enableCustomizationSection) %init(LisaVisibility);
        if (onlyWhenDNDIsActiveSwitch || alwaysWhenNotificationsArePresentedSwitch) %init(LisaData);
        %init(TestNotifications);
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)LSATestNotifications, (CFStringRef)@"love.litten.lisa/TestNotifications", NULL, (CFNotificationSuspensionBehavior)kNilOptions);
        return;
    }

}