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
#import "AsynchronousDataSource.h"
#import "Rumor.h"
#import "RumorNode.h"


@protocol RumorDelegate<AsynchronousDelegate>

@required

- (void)receiveRumorNodes:(NSArray *)theRumorNodes withResult:(NSInteger)theResult;

@end


@protocol RumorDataSource <AsynchronousDataSource>

@required

@property (nonatomic,retain) NSMutableArray *rumorNodes;

- (id)init;
- (id)initWithRumorNodes:(NSMutableArray *)theRumorNodes;

- (void)loadRumorNodes:(NSMutableArray *)theRumorNodes;

- (NSInteger)requestTop25RumorNodesNotifyDelegate:(NSObject<RumorDelegate> *)theDelegate;
- (NSInteger)requestWhatsNewRumorNodesNotifyDelegate:(NSObject<RumorDelegate> *)theDelegate;
- (NSInteger)requestRandomRumorNotifyDelegate:(NSObject<RumorDelegate> *)theDelegate;
- (NSInteger)requestRumor:(NSString *)url notifyDelegate:(NSObject<RumorDelegate> *)theDelegate;

@end
