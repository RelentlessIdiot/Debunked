//  Copyright (c) 2009-2013 Robert Ruana <rob@relentlessidiot.com>
//
//  This file is part of Debunked.
//
//  Debunked is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Debunked is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Debunked.  If not, see <http://www.gnu.org/licenses/>.

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface DebunkedAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *mainWindow;
    UITabBarController *tabBarController;
	UIImageView *splashView;
}

@property (nonatomic, retain) UITabBarController *tabBarController;
@property (nonatomic, retain) UIWindow *mainWindow;

- (void)setupPortraitUserInterface;
- (void)startupAnimationDone:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

@end
