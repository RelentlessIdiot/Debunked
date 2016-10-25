//  Created by Matt Gallagher on 12/04/09.
//  Copyright 2009 Matt Gallagher. All rights reserved.
// 
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//
//
//  Modifications Copyright (c) 2009-2016 Robert Ruana <rob@robruana.com>
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

#import "LoadingView.h"
#import <QuartzCore/QuartzCore.h>


//
// CreatePathWithRoundRect
//
// Creates a CGPathRect with a round rect of the given radius.
//
CGPathRef CreatePathWithRoundRect(CGRect rect, CGFloat cornerRadius)
{
	//
	// Create the boundary path
	//
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint(path, NULL,
		rect.origin.x,
		rect.origin.y + rect.size.height - cornerRadius);

	// Top left corner
	CGPathAddArcToPoint(path, NULL,
		rect.origin.x,
		rect.origin.y,
		rect.origin.x + rect.size.width,
		rect.origin.y,
		cornerRadius);

	// Top right corner
	CGPathAddArcToPoint(path, NULL,
		rect.origin.x + rect.size.width,
		rect.origin.y,
		rect.origin.x + rect.size.width,
		rect.origin.y + rect.size.height,
		cornerRadius);

	// Bottom right corner
	CGPathAddArcToPoint(path, NULL,
		rect.origin.x + rect.size.width,
		rect.origin.y + rect.size.height,
		rect.origin.x,
		rect.origin.y + rect.size.height,
		cornerRadius);

	// Bottom left corner
	CGPathAddArcToPoint(path, NULL,
		rect.origin.x,
		rect.origin.y + rect.size.height,
		rect.origin.x,
		rect.origin.y,
		cornerRadius);

	// Close the path at the rounded rect
	CGPathCloseSubpath(path);
	
	return path;
}

@implementation LoadingView

@synthesize hasBorder;

//
// loadingViewInView:
//
// Constructor for this view. Creates and adds a loading view for covering the
// provided aSuperview.
//
// Parameters:
//  aSuperview - the superview that will be covered by the loading view
//
// returns the constructed view, already added as a subview of the aSuperview
//	(and hence retained by the superview)
//
+ (id)loadingViewInView:(UIView *)aSuperview
{
	return [LoadingView loadingViewInView:aSuperview withBorder:YES];
}

 + (id)loadingViewInView:(UIView *)aSuperview withBorder:(BOOL)hasBorder
{
	LoadingView *loadingView = [[[LoadingView alloc] initWithFrame:[aSuperview bounds]] autorelease];
	if (!loadingView) {
		return nil;
	}
	
	loadingView.hasBorder = hasBorder;
	
	[aSuperview setUserInteractionEnabled:NO];
	
	loadingView.opaque = NO;
    loadingView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
	loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[aSuperview addSubview:loadingView];
	[aSuperview bringSubviewToFront:loadingView];

	UILabel *loadingLabelShadow = [[[UILabel alloc] init] autorelease];
	loadingLabelShadow.text = NSLocalizedString(@"Loading...", nil);
	loadingLabelShadow.textColor = [UIColor darkGrayColor];
	loadingLabelShadow.backgroundColor = [UIColor clearColor];
	loadingLabelShadow.textAlignment = NSTextAlignmentCenter;
	loadingLabelShadow.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
    [loadingLabelShadow sizeToFit];

	UILabel *loadingLabelText = [[[UILabel alloc] init] autorelease];
	loadingLabelText.text = NSLocalizedString(@"Loading...", nil);
	loadingLabelText.textColor = [UIColor whiteColor];
	loadingLabelText.backgroundColor = [UIColor clearColor];
	loadingLabelText.textAlignment = NSTextAlignmentCenter;
	loadingLabelText.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
    [loadingLabelText sizeToFit];

	UIActivityIndicatorView *activityIndicatorView =
		[[[UIActivityIndicatorView alloc]
			initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite]
		autorelease];

    CGSize labelSize = [loadingLabelShadow sizeThatFits:aSuperview.bounds.size];
    CGSize activitySize = [activityIndicatorView sizeThatFits:aSuperview.bounds.size];
    CGSize containerSize = CGSizeMake(activitySize.width + 8 + labelSize.width + 1,
                                      MAX(activitySize.height, labelSize.height));
    CGRect containerFrame = CGRectMake((loadingView.bounds.size.width - containerSize.width) / 2.0f,
                                       (loadingView.bounds.size.height - containerSize.height) / 2.0f,
                                       containerSize.width,
                                       containerSize.height);
    UIView *container = [[[UIView alloc] initWithFrame:containerFrame] autorelease];
    container.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin |
                                  UIViewAutoresizingFlexibleRightMargin |
                                  UIViewAutoresizingFlexibleBottomMargin |
                                  UIViewAutoresizingFlexibleLeftMargin);

    [container addSubview:loadingLabelShadow];
    [container addSubview:loadingLabelText];
	[container addSubview:activityIndicatorView];

    [loadingView addSubview:container];

    loadingLabelText.center = CGPointMake(containerSize.width - (labelSize.width / 2.0f) - 1.0f,
                                          (containerSize.height / 2.0f) - 1.0f);
    loadingLabelShadow.center = CGPointMake(containerSize.width - (labelSize.width / 2.0f),
                                            containerSize.height / 2.0f);
    activityIndicatorView.center = CGPointMake(activitySize.width / 2.0f, containerSize.height / 2.0f);

	[activityIndicatorView startAnimating];
	
	// Set up the fade-in animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[[aSuperview layer] addAnimation:animation forKey:@"layerAnimation"];
	
	return loadingView;
}

//
// removeView
//
// Animates the view out from the superview. As the view is removed from the
// superview, it will be released.
//
- (void)removeView
{
	UIView *aSuperview = [self superview];
	[super removeFromSuperview];
	
	[aSuperview setUserInteractionEnabled:YES];

	// Set up the animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	
	[[aSuperview layer] addAnimation:animation forKey:@"layerAnimation"];
}

//
// dealloc
//
// Release instance memory.
//
- (void)dealloc
{
    [super dealloc];
}

@end
