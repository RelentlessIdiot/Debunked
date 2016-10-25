//  Copyright (c) 2009-2016 Robert Ruana <rob@robruana.com>
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
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "Rumor.h"
#import "AsynchronousDataSource.h"
#import "RumorDataSource.h"
#import "LoadingView.h"
#import "WebViewController.h"
#import "CategoryDataSource.h"
#import "RumorDataSource.h"
#import "CategoryTableViewController.h"
#import "WebBrowserViewController.h"
#import "DebunkedAppDelegate.h"


@interface RumorViewController : UIViewController<
									AsynchronousDelegate, 
									UIWebViewDelegate, 
									UIActionSheetDelegate,
									MFMailComposeViewControllerDelegate,
									UIPrintInteractionControllerDelegate>
{

}

@property (nonatomic,retain) Rumor *rumor;
@property (nonatomic,retain) RumorDataSource *dataSource;
@property (nonatomic,assign) LoadingView *loadingView;
@property (nonatomic,retain) UIWebView *webView;
@property (nonatomic,assign) BOOL hasRumor;
@property (nonatomic,assign) BOOL isRendered;
@property (nonatomic,assign) BOOL receivedMemoryWarning;

- (id)init;
- (id)initWithRumor:(Rumor *)theRumor;
- (id)initWithDataSource:(RumorDataSource *)theDataSource;
- (id)initWithDataSource:(RumorDataSource *)theDataSource withRumor:(Rumor *)theRumor;
- (void)updateWebView;
- (void)removeLoadingView;
- (void)segmentAction:(id)sender;
- (void)handleBrowseButton;
- (void)handleShareButton;

@end
