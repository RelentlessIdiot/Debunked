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

#import "RumorNode.h"
#import "RumorNodeTableViewCell.h"


@implementation RumorNodeTableViewCell

@synthesize rumorNode;
@synthesize rumorNodeView;

- (void)setRumorNode:(RumorNode *)theRumorNode
{
	if (theRumorNode != rumorNode) {
		[rumorNode release];
		[theRumorNode retain];
		rumorNode = theRumorNode;
	}
	rumorNodeView.rumorNode = rumorNode;
	[rumorNodeView performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
}

- (void)setSelected:(BOOL)selected
{
	[super setSelected:selected];
	[rumorNodeView setSelected:selected];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	[super setSelected:selected animated:NO];
	[rumorNodeView setSelected:selected];
}

- (void)setHighlighted:(BOOL)highlighted
{
	[super setHighlighted:highlighted];
	[rumorNodeView setSelected:highlighted];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
	[super setHighlighted:highlighted animated:NO];
	[rumorNodeView setSelected:highlighted];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        rumorNode = nil;
		self.selectionStyle = UITableViewCellSelectionStyleBlue;
		self.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
		
		CGRect frame = CGRectMake(0.0, 0.0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
		rumorNodeView = [[RumorNodeView alloc] initWithFrame:frame];
		[self.contentView addSubview:rumorNodeView];
	}
    return self;
}


- (void)redisplay
{
	[rumorNodeView performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
}


- (void)dealloc {
	[rumorNode release];
	[rumorNodeView release];
    [super dealloc];
}


@end
