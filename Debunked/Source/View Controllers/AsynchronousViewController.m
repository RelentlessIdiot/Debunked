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

#import "AsynchronousViewController.h"


@implementation AsynchronousViewController

@synthesize dataSource;
@synthesize loadingView;
@synthesize url;
- (UIScrollView *)scrollView { return nil; }
- (BOOL)canEmail { return NO; }
- (BOOL)canPrint { return NO; }

- (void)dealloc
{
    [dataSource release];
    [url release];

    [super dealloc];
}

- (id)init
{
    return [self initWithUrl:nil];
}

- (id)initWithUrl:(NSString *)theUrl
{
    if (self = [super init]) {
        lastRequestId = 0;
        self.url = theUrl;

        UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share.png"]
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(handleShareButton)];
        self.navigationItem.rightBarButtonItem = shareButton;
        [shareButton release];
    }
    return self;
}

- (void)handleShareButton
{
    UIActionSheet *actionSheet;

    if (self.canEmail) {
        if (self.canPrint) {
            actionSheet = [[UIActionSheet alloc] initWithTitle: nil
                                                      delegate: self
                                             cancelButtonTitle: @"Cancel"
                                        destructiveButtonTitle: nil
                                             otherButtonTitles: @"Open in Safari", @"Email Article", @"Print Article", nil];
        } else {
            actionSheet = [[UIActionSheet alloc] initWithTitle: nil
                                                      delegate: self
                                             cancelButtonTitle: @"Cancel"
                                        destructiveButtonTitle: nil
                                             otherButtonTitles: @"Open in Safari", @"Email Article", nil];
        }
    } else if (self.canPrint) {
        actionSheet = [[UIActionSheet alloc] initWithTitle: nil
                                                  delegate: self
                                         cancelButtonTitle: @"Cancel"
                                    destructiveButtonTitle: nil
                                         otherButtonTitles: @"Open in Safari", @"Print Article", nil];
    } else {
        actionSheet = [[UIActionSheet alloc] initWithTitle: nil
                                                  delegate: self
                                         cancelButtonTitle: @"Cancel"
                                    destructiveButtonTitle: nil
                                         otherButtonTitles: @"Open in Safari", nil];
    }

    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actionSheet showInView:self.parentViewController.tabBarController.view];
    [actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSInteger safariIndex = 0;
    NSInteger emailIndex = 1;
    NSInteger printIndex = 2;

    if (self.canEmail) {
        emailIndex = 1;
        if (self.canPrint) {
            printIndex = 2;
        } else {
            printIndex = -1;
        }
    } else {
        emailIndex = -1;
        if (self.canPrint) {
            printIndex = 1;
        } else {
            printIndex = -1;
        }
    }
    if (buttonIndex == safariIndex) {
        [self openInSafari];
    } else if (buttonIndex == emailIndex) {
        [self email];
    } else if (buttonIndex == printIndex) {
        [self print];
    }
}

- (void)email
{

}

- (void)print
{

}

- (void)openInSafari
{
    if (self.url == nil) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.snopes.com/"]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.url]];
    }
}

- (void)addLoadingView
{
    if (self.scrollView.dragging || self.scrollView.decelerating) {
        needsLoadingView = YES;
    } else if (self.loadingView == nil) {
        needsLoadingView = NO;
        self.loadingView = [LoadingView loadingViewInView:self.view withBorder:NO];
    }
}

- (void)removeLoadingView
{
    needsLoadingView = NO;
    [loadingView removeView];
    loadingView = nil;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (needsLoadingView == YES) {
        needsLoadingView = NO;
        if (self.loadingView == nil) {
            self.loadingView = [LoadingView loadingViewInView:self.view withBorder:NO];
        }
    }
}

- (void)reloadDataSource
{
    @synchronized(self) {
        [self.dataSource cancelRequest:lastRequestId];
        [self addLoadingView];
    }
}

- (void)receive:(id)theItem
{
    @synchronized(self) {
        [self removeLoadingView];
    }
}

- (void)scrollToTop
{
    [self.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}

@end
