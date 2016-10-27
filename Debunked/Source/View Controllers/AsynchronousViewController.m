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

- (UIScrollView *)scrollView
{
    return nil;
}

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
    }
    return self;
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
