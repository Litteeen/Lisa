#import <UIKit/UIKit.h>
#import <Cephei/HBPreferences.h>
#import <AudioToolbox/AudioServices.h>
#import <dlfcn.h>

HBPreferences* preferences;
UIView* lisaView;
UIVisualEffectView* blurView;
UIBlurEffect* blur;

int notificationCount = 0;
BOOL isDNDActive = NO;

extern BOOL enabled;
extern BOOL enableCustomizationSection;
extern BOOL enableAnimationsSection;
extern BOOL enableHapticFeedbackSection;

// Customization
BOOL onlyWhenDNDIsActiveSwitch = NO;
BOOL whenNotificationArrivesSwitch = YES;
BOOL alwaysWhenNotificationsArePresentedSwitch = YES;
BOOL whenPlayingMusicSwitch = YES;
BOOL onlyWhileChargingSwitch = NO;
BOOL hideStatusBarSwitch = YES;
BOOL hideControlCenterIndicatorSwitch = YES;
BOOL hideFaceIDLockSwitch = YES;
BOOL hideTimeAndDateSwitch = YES;
BOOL hideQuickActionsSwitch = YES;
BOOL hideUnlockTextSwitch = YES;
BOOL hideHomebarSwitch = YES;
BOOL hidePageDotsSwitch = YES;

BOOL hideComplicationsSwitch = YES;
BOOL hideKaiSwitch = YES;
BOOL hideAperioSwitch = YES;
BOOL hideLibellumSwitch = YES;

BOOL disableTodaySwipeSwitch = NO;
BOOL disableCameraSwipeSwitch = NO;
BOOL blurredBackgroundSwitch = NO;
BOOL tapToDismissLisaSwitch = YES;
NSString* backgroundAlphaValue = @"1.0";

// Animations
BOOL lisaFadeOutAnimationSwitch = YES;
NSString* lisaFadeOutAnimationValue = @"0.5";

// Haptic Feedback
BOOL hapticFeedbackSwitch = NO;
NSString* hapticFeedbackStrengthValue = @"0";

@interface CSCoverSheetViewController : UIViewController
@end

// time and date
@interface SBFLockScreenDateView : UIView
- (void)receiveHideNotification:(NSNotification *)notification;
@end

// faceid lock
@interface SBUIProudLockIconView : UIView
- (void)receiveHideNotification:(NSNotification *)notification;
@end

// status bar
@interface _UIStatusBar : UIView
@end

@interface UIStatusBar_Modern : UIView
- (_UIStatusBar *)statusBar;
- (void)receiveHideNotification:(NSNotification *)notification;
@end

// quick actions
@interface CSQuickActionsButton : UIView
- (void)receiveHideNotification:(NSNotification *)notification;
@end

// control center indicator and unlock text for homebar devices
@interface CSTeachableMomentsContainerView : UIView
@property(nonatomic, strong, readwrite)UIView* controlCenterGrabberContainerView;
@property(nonatomic, retain)UIView* callToActionLabelContainerView;
- (void)receiveHideNotification:(NSNotification *)notification;
@end

// unlock text for home button devices
@interface SBUICallToActionLabel : UILabel
- (void)receiveHideNotification:(NSNotification *)notification;
@end

// homebar
@interface CSHomeAffordanceView : UIView
- (void)receiveHideNotification:(NSNotification *)notification;
@end

// page dots
@interface CSPageControl : UIPageControl
- (void)receiveHideNotification:(NSNotification *)notification;
@end

// complications
@interface ComplicationsView : UIView
- (void)receiveHideNotification:(NSNotification *)notification;
@end

// kai
@interface KAIBatteryPlatter : UIView
- (void)receiveHideNotification:(NSNotification *)notification;
@end

// aperio
@interface APEPlatter : UIView
- (void)receiveHideNotification:(NSNotification *)notification;
@end

// libellum
@interface LibellumView : UIView
- (void)receiveHideNotification:(NSNotification *)notification;
@end

@interface SBUILegibilityLabel : UIView
@end

@interface SBMediaController : NSObject
+ (id)sharedInstance;
- (BOOL)isPlaying;
@end

@interface SBUIController : NSObject
+ (id)sharedInstance;
- (BOOL)isOnAC;
@end

// test notifications
@interface BBAction : NSObject
+ (id)actionWithLaunchBundleID:(id)arg1 callblock:(id)arg2;
@end

@interface BBBulletin : NSObject
@property(nonatomic, copy)NSString* sectionID;
@property(nonatomic, copy)NSString* recordID;
@property(nonatomic, copy)NSString* publisherBulletinID;
@property(nonatomic, copy)NSString* title;
@property(nonatomic, copy)NSString* message;
@property(nonatomic, retain)NSDate* date;
@property(assign, nonatomic)BOOL clearable;
@property(nonatomic)BOOL showsMessagePreview;
@property(nonatomic, copy)BBAction* defaultAction;
@property(nonatomic, copy)NSString* bulletinID;
@property(nonatomic, retain)NSDate* lastInterruptDate;
@property(nonatomic, retain)NSDate* publicationDate;
@end

@interface BBServer : NSObject
- (void)publishBulletin:(BBBulletin *)arg1 destinations:(NSUInteger)arg2 alwaysToLockScreen:(BOOL)arg3;
- (void)publishBulletin:(id)arg1 destinations:(unsigned long long)arg2;
@end

@interface BBObserver : NSObject
@end

@interface NCBulletinNotificationSource : NSObject
- (BBObserver *)observer;
@end

@interface SBNCNotificationDispatcher : NSObject
- (NCBulletinNotificationSource *)notificationSource;
@end

@interface SpringBoard : UIApplication
- (void)_simulateLockButtonPress;
- (void)_simulateHomeButtonPress;
@end