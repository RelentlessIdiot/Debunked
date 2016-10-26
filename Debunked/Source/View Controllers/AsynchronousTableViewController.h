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
#import "AsynchronousDataSource.h"
#import "LoadingView.h"


@interface AsynchronousTableViewController: UIViewController<UITableViewDelegate, AsynchronousDelegate>
{
    NSInteger lastRequestId;
    BOOL needsLoadingView;
}

@property (nonatomic,retain) AsynchronousDataSource *dataSource;
@property (nonatomic,assign) LoadingView *loadingView;
@property (nonatomic,retain) UITableView *tableView;
@property (nonatomic,retain) NSString *url;

- (id)initWithUrl:(NSString *)theUrl;
- (void)receive:(id)theItem;
- (void)reloadDataSource;
- (void)scrollToTop;

@end
