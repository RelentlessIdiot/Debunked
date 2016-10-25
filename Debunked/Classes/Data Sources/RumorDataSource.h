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

#import <Foundation/Foundation.h>

#import "AsynchronousDataSource.h"
#import "CachedDataLoader.h"

#import "Rumor.h"
#import "RumorNode.h"


@protocol RumorDelegate<AsynchronousDelegate>

@required

- (void)receiveRumorNodes:(NSArray *)theRumorNodes withResult:(NSInteger)theResult;

@end


@interface RumorDataSource: AsynchronousDataSource {
	NSArray *rumorNodes;
}

@property (nonatomic,retain) NSArray *rumorNodes;

- (id)init;
- (id)initWithRumorNodes:(NSArray *)theRumorNodes NS_DESIGNATED_INITIALIZER;

- (void)loadRumorNodes:(NSArray *)theRumorNodes;
- (NSInteger)requestTop25RumorNodesNotifyDelegate:(NSObject<RumorDelegate> *)theDelegate;
- (NSInteger)requestWhatsNewRumorNodesNotifyDelegate:(NSObject<RumorDelegate> *)theDelegate;
- (NSInteger)requestRandomRumorNotifyDelegate:(NSObject<RumorDelegate> *)theDelegate;
- (NSInteger)requestRumor:(NSString *)url notifyDelegate:(NSObject<RumorDelegate> *)theDelegate;

@end
