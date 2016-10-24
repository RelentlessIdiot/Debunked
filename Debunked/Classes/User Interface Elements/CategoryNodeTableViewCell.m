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

#import "CategoryNode.h"
#import "CategoryNodeTableViewCell.h"


@implementation CategoryNodeTableViewCell

@synthesize categoryNode;
@synthesize categoryNodeView;

- (void)setCategoryNode:(CategoryNode *)theCategoryNode
{
	if (theCategoryNode != categoryNode) {
		[categoryNode release];
		[theCategoryNode retain];
		categoryNode = theCategoryNode;
	}
	categoryNodeView.categoryNode = categoryNode;
	[categoryNodeView performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
}

- (void)setHighlighted:(BOOL)highlighted
{
	[super setHighlighted:highlighted];
	[categoryNodeView setSelected:highlighted];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
	[super setHighlighted:highlighted animated:NO];
	[categoryNodeView setSelected:highlighted];
}

- (void)setSelected:(BOOL)selected
{
	[super setSelected:selected];
	[categoryNodeView setSelected:selected];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	[super setSelected:selected animated:NO];
	[categoryNodeView setSelected:selected];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        categoryNode = nil;
		self.selectionStyle = UITableViewCellSelectionStyleBlue;
		self.accessoryType = UITableViewCellAccessoryNone;
		
		CGRect frame = CGRectMake(0.0, 0.0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
		categoryNodeView = [[CategoryNodeView alloc] initWithFrame:frame];
		[self.contentView addSubview:categoryNodeView];
	}
    return self;
}

- (void)redisplay
{
	[categoryNodeView performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
}


- (void)dealloc {
	[categoryNode release];
	[categoryNodeView release];
    [super dealloc];
}


@end
