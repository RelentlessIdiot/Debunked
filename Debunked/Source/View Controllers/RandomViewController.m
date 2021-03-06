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

#import "RandomViewController.h"
#import "DebunkedAppDelegate.h"


@implementation RandomViewController

- (NSString *)url
{
    return self.rumorDataSource.rumor.url;
}

- (id)initWithUrl:(NSString *)theUrl
{
    if (self = [super initWithUrl:nil]) {
		UIBarButtonItem *nextButton = [[[UIBarButtonItem alloc] init] autorelease];
		nextButton.style = UIBarButtonItemStylePlain;
		nextButton.title = @"Random";
		nextButton.target = self;
		nextButton.action = @selector(onNextButtonClick);

        NSMutableArray* buttons = [NSMutableArray arrayWithArray:self.navigationItem.rightBarButtonItems];
        [buttons insertObject: nextButton atIndex:0];
        [self.navigationItem setRightBarButtonItems:buttons];
	}
	return self;
}

- (void)onNextButtonClick
{
    RandomViewController *randomViewController = [[[RandomViewController alloc] init] autorelease];
    [self performSelectorOnMainThread:@selector(pushViewControllerAnimated:) withObject:randomViewController waitUntilDone:NO];
}

- (void)reloadDataSource
{
    @synchronized(self) {
        [self.dataSource cancelRequest:lastRequestId];
        [self addLoadingView];
        lastRequestId = [self.rumorDataSource requestRandomRumorNotifyDelegate:self];
    }
}

@end
