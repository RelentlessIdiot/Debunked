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

#import "CategoryDataSource.h"
#import "CachedDataLoader.h"
#import "CategoryConsumer.h"
#import "TopLevelCategoryConsumer.h"
#import "CategoryNodeTableViewCell.h"
#import "RumorNodeTableViewCell.h"


@implementation CategoryDataSource

- (Category *)category
{
    return (Category *)self.item;
}

- (NSInteger)nodeCount
{
    return self.category.nodeCount;
}

- (CategoryNode *)categoryNodeForIndexPath:(NSIndexPath *)theIndexPath
{
    if(self.category.categoryNodes.count > 0) {
        return [self.category.categoryNodes objectAtIndex:theIndexPath.row];
    } else {
        return nil;
    }
}

- (RumorNode *)rumorNodeForIndexPath:(NSIndexPath *)theIndexPath
{
    if(self.category.rumorNodes.count > 0) {
        return [self.category.rumorNodes objectAtIndex:theIndexPath.row];
    } else {
        return nil;
    }
}

- (NSInteger)requestCategory:(NSString *)theUrl notifyDelegate:(NSObject<AsynchronousDelegate> *)theDelegate
{
    return [self request:theUrl consumerClass:CategoryConsumer.class notifyDelegate:theDelegate];
}

- (NSInteger)requestTopLevelCategoryNotifyDelegate:(NSObject<AsynchronousDelegate> *)theDelegate
{
    return [self request:@"http://www.snopes.com/" consumerClass:TopLevelCategoryConsumer.class notifyDelegate:theDelegate];
}

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (self.category.rumorNodes.count > 0) ? RumorNodeView.preferredHeight : CategoryNodeView.preferredHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)theIndexPath
{
    if (self.category.rumorNodes.count > 0) {
        RumorNodeTableViewCell *cell = (RumorNodeTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"RumorNodeTableViewCell"];
        if (cell == nil) {
            cell = [[[RumorNodeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RumorNodeTableViewCell"] autorelease];
        }
        cell.rumorNode = [self rumorNodeForIndexPath:theIndexPath];
        return cell;
    } else {
        CategoryNodeTableViewCell *cell = (CategoryNodeTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"CategoryNodeTableViewCell"];
        if (cell == nil) {
            cell = [[[CategoryNodeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CategoryNodeTableViewCell"] autorelease];
        }
        cell.categoryNode = [self categoryNodeForIndexPath:theIndexPath];
        return cell;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.category.nodeCount;
}

@end
