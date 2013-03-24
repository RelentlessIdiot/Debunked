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
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "Rumor.h"
#import "AsynchronousDataSource.h"
#import "RumorDataSource.h"
#import "LoadingView.h"
#import "WebViewController.h"
#import "DataSourceFactory.h"
#import "RumorDataSource.h"
#import "WebBrowserViewController.h"
#import "DebunkedAppDelegate.h"


@interface RumorViewController : UIViewController<
									AsynchronousDelegate, 
									UIWebViewDelegate, 
									UIActionSheetDelegate,
									MFMailComposeViewControllerDelegate,
									UIPrintInteractionControllerDelegate> {
	Rumor *rumor;
	UIWebView *webView;
	LoadingView *loadingView;
	NSObject<RumorDataSource> *dataSource;
	BOOL hasRumor;
	BOOL isRendered;
	BOOL receivedMemoryWarning;
	UIView *toolbar;
}

@property (nonatomic,retain) Rumor *rumor;
@property (nonatomic,retain) NSObject<RumorDataSource> *dataSource;
@property (nonatomic,assign) LoadingView *loadingView;
@property (nonatomic,retain) UIWebView *webView;
@property (nonatomic,assign) BOOL hasRumor;
@property (nonatomic,assign) BOOL isRendered;
@property (nonatomic,assign) BOOL receivedMemoryWarning;
@property (nonatomic, retain) UIView *toolbar;

- (id)init;
- (id)initWithRumor:(Rumor *)theRumor;
- (id)initWithDataSource:(NSObject<RumorDataSource> *)theDataSource;
- (id)initWithDataSource:(NSObject<RumorDataSource> *)theDataSource withRumor:(Rumor *)theRumor;
- (void)updateWebView;
- (void)removeLoadingView;
- (void)segmentAction:(id)sender;
- (void)handleBrowseButton;
- (void)handleShareButton;

@end
