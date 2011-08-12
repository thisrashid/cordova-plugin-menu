//
//  PGTabBar.h
//
//  Based on the previous PhoneGap plugins UIControls.h and NativeControls.h
//
//  phonegap-plugin-menu is available under *either* the terms of the modified BSD license *or* the
//  MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
//
//  Copyright (c) 2011 Michael Brooks, Nitobi Software Inc.
//  Copyright (c) 2011 Shazron Abdullah, Nitobi Software Inc.
//  Copyright (c) 2010 Jesse MacFadyen, Nitobi Software Inc.
//  Copyright (c) 2009 Michael Nachaur, Decaf Ninja Software
//

#import <QuartzCore/QuartzCore.h>
#import <PhoneGap/PhoneGapDelegate.h>
#import "PGTabBar.h"

@implementation PGTabBar

@synthesize tabBar, tabBarItems;
@synthesize lastTabBarPosition;

-(PGPlugin*) initWithWebView:(UIWebView*)theWebView
{
    self = (PGTabBar*)[super initWithWebView:theWebView];
    if (self) 
	{
        self.tabBarItems = [[NSMutableDictionary alloc] initWithCapacity:5];
    }
    return self;
}

- (void) dealloc
{
	self.tabBar = nil;
	self.tabBarItems = nil;
	
    [super dealloc];
}

- (void) removeTabBar:(NSArray*)arguments withDict:(NSDictionary*)options
{
	if (!self.tabBar) {
		return;
	}
	
	[self.webView pg_removeSiblingView:self.tabBar withAnimation:NO];
	[self.webView pg_relayout:NO];
	
	self.tabBar = nil;
    
    PluginResult* pluginResult = [PluginResult resultWithStatus: PGCommandStatus_OK];
    NSString* callbackId = [arguments objectAtIndex:0];
    [self writeJavascript:[pluginResult toSuccessCallbackString:callbackId]];
}


- (void) createTabBar:(NSArray*)arguments withDict:(NSDictionary*)options
{
	if (self.tabBar) {
		return;
	}
	
    self.tabBar = [UITabBar new];
    self.tabBar.delegate = self;
    self.tabBar.multipleTouchEnabled   = NO;
    self.tabBar.autoresizesSubviews    = YES;
    self.tabBar.hidden                 = NO;
    self.tabBar.userInteractionEnabled = YES;
	self.tabBar.opaque = YES;
    [self.tabBar sizeToFit];
	
	self.webView.superview.autoresizesSubviews = YES;
	
	BOOL atBottom = YES;
	
    if (options) {
        atBottom = [[options objectForKey:@"position"] isEqualToString:@"bottom"];
    }
	
	self.lastTabBarPosition = atBottom?PGLayoutPositionBottom:PGLayoutPositionTop;
	[self.webView pg_addSiblingView:self.tabBar withPosition:self.lastTabBarPosition withAnimation:NO];
    
    PluginResult* pluginResult = [PluginResult resultWithStatus: PGCommandStatus_OK];
    NSString* callbackId = [arguments objectAtIndex:0];
    [self writeJavascript:[pluginResult toSuccessCallbackString:callbackId]];
}

/**
 * Show the tab bar after its been created.
 */
- (void) showTabBar:(NSArray*)arguments withDict:(NSDictionary*)options
{
    if (!self.tabBar) {
        [self createTabBar:nil withDict:nil];
	}
    
	if (![self.webView pg_hasSiblingView:self.tabBar]) {
		[self.webView pg_addSiblingView:self.tabBar withPosition:self.lastTabBarPosition withAnimation:NO];
	}
    
    PluginResult* pluginResult = [PluginResult resultWithStatus: PGCommandStatus_OK];
    NSString* callbackId = [arguments objectAtIndex:0];
    [self writeJavascript:[pluginResult toSuccessCallbackString:callbackId]];
}

/**
 * Hide the tab bar
 */
- (void) hideTabBar:(NSArray*)arguments withDict:(NSDictionary*)options
{
    if (!self.tabBar) {
        return;
	}
	
	if ([self.webView pg_hasSiblingView:self.tabBar]) {
		[self.webView pg_removeSiblingView:self.tabBar withAnimation:NO];
		[self.webView pg_relayout:NO];
	}
    
    PluginResult* pluginResult = [PluginResult resultWithStatus: PGCommandStatus_OK];
    NSString* callbackId = [arguments objectAtIndex:0];
    [self writeJavascript:[pluginResult toSuccessCallbackString:callbackId]];
}

/**
 * Create a new tab bar item for use on a previously created tab bar.
 *
 * If the supplied image name is one of the labels listed below, then this method will construct a tab button
 * using the standard system buttons.  Note that if you use one of the system images, that the \c title you supply will be ignored.
 * - <b>Tab Buttons</b>
 *   - tabButton:More
 *   - tabButton:Favorites
 *   - tabButton:Featured
 *   - tabButton:TopRated
 *   - tabButton:Recents
 *   - tabButton:Contacts
 *   - tabButton:History
 *   - tabButton:Bookmarks
 *   - tabButton:Search
 *   - tabButton:Downloads
 *   - tabButton:MostRecent
 *   - tabButton:MostViewed
 * @brief create a tab bar item
 * @param arguments Parameters used to create the tab bar
 *  -# \c name internal name to refer to this tab by
 *  -# \c title title text to show on the tab, or null if no text should be shown
 *  -# \c image image filename or internal identifier to show, or null if now image should be shown
 *  -# \c tag unique number to be used as an internal reference to this button
 * @param options Options for customizing the individual tab item
 *  - \c badge value to display in the optional circular badge on the item; if nil or unspecified, the badge will be hidden
 */
- (void) createTabBarItem:(NSArray*)arguments withDict:(NSDictionary*)options
{
    if (!self.tabBar) {
        [self createTabBar:nil withDict:nil];
	}
    
    NSString* callbackId = [arguments objectAtIndex:0];
    NSString* name       = [arguments objectAtIndex:1];
    NSString* title      = @"";
    NSString* imageName  = @"";
    BOOL enable          = true;
    int tag              = [name intValue];
    
    @try {
        title     = [arguments objectAtIndex:2];
        imageName = [arguments objectAtIndex:3];
        enable    = [[arguments objectAtIndex:4] boolValue];
        tag       = [[arguments objectAtIndex:5] intValue];
    } @catch (NSException *exception) {
        // Move on
    }
    
    UITabBarItem *item = nil;    
    if ([imageName length] > 0) 
	{
        UITabBarSystemItem systemItem = -1;
        if ([imageName isEqualToString:@"tabButton:More"])       systemItem = UITabBarSystemItemMore;
        if ([imageName isEqualToString:@"tabButton:Favorites"])  systemItem = UITabBarSystemItemFavorites;
        if ([imageName isEqualToString:@"tabButton:Featured"])   systemItem = UITabBarSystemItemFeatured;
        if ([imageName isEqualToString:@"tabButton:TopRated"])   systemItem = UITabBarSystemItemTopRated;
        if ([imageName isEqualToString:@"tabButton:Recents"])    systemItem = UITabBarSystemItemRecents;
        if ([imageName isEqualToString:@"tabButton:Contacts"])   systemItem = UITabBarSystemItemContacts;
        if ([imageName isEqualToString:@"tabButton:History"])    systemItem = UITabBarSystemItemHistory;
        if ([imageName isEqualToString:@"tabButton:Bookmarks"])  systemItem = UITabBarSystemItemBookmarks;
        if ([imageName isEqualToString:@"tabButton:Search"])     systemItem = UITabBarSystemItemSearch;
        if ([imageName isEqualToString:@"tabButton:Downloads"])  systemItem = UITabBarSystemItemDownloads;
        if ([imageName isEqualToString:@"tabButton:MostRecent"]) systemItem = UITabBarSystemItemMostRecent;
        if ([imageName isEqualToString:@"tabButton:MostViewed"]) systemItem = UITabBarSystemItemMostViewed;
		
        if (systemItem != -1) {
            item = [[UITabBarItem alloc] initWithTabBarSystemItem:systemItem tag:tag];
		}
    }
    
    if (item == nil) {
        NSLog(@"Creating with custom image and title");
		UIImage* image = [UIImage imageNamed:imageName];
		if (!image) {
			NSString* imagePath = [[PhoneGapDelegate class] pathForResource:imageName];
			image = [UIImage imageWithContentsOfFile:imagePath];
		}
		
        item = [[UITabBarItem alloc] initWithTitle:title image:image tag:tag];
    }
    
    if ([options objectForKey:@"badge"]) {
        item.badgeValue = [options objectForKey:@"badge"];
	}
    
	item.enabled = enable;
	
    BOOL animateItems = YES;
    if ([options objectForKey:@"animate"]) {
        animateItems = [(NSString*)[options objectForKey:@"animate"] boolValue];
	}
	
    NSMutableArray* items = [[self.tabBar items] mutableCopy];
	if (!items) {
		items = [[NSMutableArray alloc] initWithCapacity:1];
	}
	[items addObject:item];
	
    [self.tabBar setItems:items animated:animateItems];
	[items release];
	
	[self.tabBarItems setObject:item forKey:name];
	[item release];
    
    PluginResult* pluginResult = [PluginResult resultWithStatus: PGCommandStatus_OK];
    [self writeJavascript:[pluginResult toSuccessCallbackString:callbackId]];
}


///**
// * Update an existing tab bar item to change its title/badge value.
// */
//- (void) updateTabBarItem:(NSArray*)arguments withDict:(NSDictionary*)options
//{
//    if (!self.tabBar) {
//        [self createTabBar:nil withDict:nil];
//	}
//
//    NSString* callbackId  = [arguments objectAtIndex:0];
//    NSString* name = [arguments objectAtIndex:1];
//    
//    UITabBarItem* item = [self.tabBarItems objectForKey:name];
////    if (item) {
////		item.title = [options objectForKey:@"label"];
////        item.badgeValue = [options objectForKey:@"badge"];
////	}
//    
//    PluginResult* pluginResult = [PluginResult resultWithStatus: PGCommandStatus_OK];
//    [self writeJavascript:[pluginResult toSuccessCallbackString:callbackId]];
//}

/**
 * Update an existing tab bar item's image.
 */
- (void) updateTabBarItemImage:(NSArray*)arguments withDict:(NSDictionary*)options
{
    if (!self.tabBar) {
        [self createTabBar:nil withDict:nil];
	}
    
    NSString* callbackId = [arguments objectAtIndex:0];
    NSString* name       = [arguments objectAtIndex:1];
    NSString* imageName  = [arguments objectAtIndex:2];
    
    UITabBarItem* item = [self.tabBarItems objectForKey:name];
    UIImage* image = [UIImage imageNamed:imageName];
    [item setImage:image];
    
    PluginResult* pluginResult = [PluginResult resultWithStatus: PGCommandStatus_OK];
    [self writeJavascript:[pluginResult toSuccessCallbackString:callbackId]];
}

/**
 * Update an existing tab bar item's title.
 */
- (void) updateTabBarItemTitle:(NSArray*)arguments withDict:(NSDictionary*)options
{
    if (!self.tabBar) {
        [self createTabBar:nil withDict:nil];
	}
    
    NSString* callbackId = [arguments objectAtIndex:0];
    NSString* name       = [arguments objectAtIndex:1];
    NSString* title      = [arguments objectAtIndex:2];
    
    UITabBarItem* item = [self.tabBarItems objectForKey:name];
    [item setTitle: title];
    
    PluginResult* pluginResult = [PluginResult resultWithStatus: PGCommandStatus_OK];
    [self writeJavascript:[pluginResult toSuccessCallbackString:callbackId]];
}

/**
 * Remove an existing tab bar item
 * @param arguments Parameters used to identify the tab bar item to update
 *  -# \c name internal name used to represent this item when it was created
 */
- (void) removeTabBarItem:(NSArray*)arguments withDict:(NSDictionary*)options
{
    if (!self.tabBar) {
        [self createTabBar:nil withDict:nil];
	}
    
    NSString* callbackId  = [arguments objectAtIndex:0];
    NSString* name = [arguments objectAtIndex:1];
    UITabBarItem* item = [self.tabBarItems objectForKey:name];
	
	NSMutableArray* items = [self.tabBar.items mutableCopy];
	NSUInteger index = [items indexOfObject:item];
	if (index != NSNotFound) {
		[items removeObjectAtIndex:index];
		[self.tabBar setItems:items animated:YES];
	}
	
	[items release];
    
    PluginResult* pluginResult = [PluginResult resultWithStatus: PGCommandStatus_OK];
    [self writeJavascript:[pluginResult toSuccessCallbackString:callbackId]];
}

- (void) enableTabBarItem:(NSArray*)arguments withDict:(NSDictionary*)options
{
    NSString* callbackId  = [arguments objectAtIndex:0];
    NSString* name      = [arguments objectAtIndex:1];
    BOOL enable         = [[arguments objectAtIndex:2] boolValue];
	
    UITabBarItem* item = [self.tabBarItems objectForKey:name];
	
	NSUInteger index = [self.tabBar.items indexOfObject:item];
	if (index != NSNotFound) {
		item.enabled = enable;
	}
    
    PluginResult* pluginResult = [PluginResult resultWithStatus: PGCommandStatus_OK];
    [self writeJavascript:[pluginResult toSuccessCallbackString:callbackId]];
}

/**
 * Manually select an individual tab bar item, or nil for deselecting a currently selected tab bar item.
 * @brief manually select a tab bar item
 * @param arguments the name of the tab bar item to select
 * @see createTabBarItem
 * @see showTabBarItems
 */
- (void) selectTabBarItem:(NSArray*)arguments withDict:(NSDictionary*)options
{
    if (!self.tabBar) {
        [self createTabBar:nil withDict:nil];
	}
    
    NSString* callbackId  = [arguments objectAtIndex:0];
    NSString* itemName = [arguments objectAtIndex:1];
    UITabBarItem* item = [self.tabBarItems objectForKey:itemName];
    self.tabBar.selectedItem = item;
    
    PluginResult* pluginResult = [PluginResult resultWithStatus: PGCommandStatus_OK];
    [self writeJavascript:[pluginResult toSuccessCallbackString:callbackId]];
}

- (void)tabBar:(UITabBar*)tabBar didSelectItem:(UITabBarItem *)item
{
    NSString* jsCallBack = [NSString stringWithFormat:@"window.HTMLCommandElement.elements[%d].attribute.action();", item.tag];    
    [super writeJavascript:jsCallBack];
}

@end