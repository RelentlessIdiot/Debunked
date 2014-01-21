//  Copyright (c) 2009-2014 Robert Ruana <rob@relentlessidiot.com>
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

#import "RumorNodeView.h"


#define TOP_ROW_Y 6

#define VERACITY_IMAGE_X 6
#define VERACITY_IMAGE_WIDTH 16
#define VERACITY_IMAGE_HEIGHT 16

#define LABEL_X 28 // 6 + 16 + 6 // VERACITY_IMAGE_X + VERACITY_IMAGE_WIDTH + 6

#define BOTTOM_ROW_Y 23 // 6 + 16 + 1 // TOP_ROW_Y + VERACITY_IMAGE_HEIGHT + 1

#define IMAGE_X 6
#define IMAGE_Y 29
#define IMAGE_WIDTH 32
#define IMAGE_HEIGHT 32

#define SYNOPSIS_X 47 // 6 + 32 + 9 // IMAGE_X + IMAGE_WIDTH + 9

#define LABEL_FONT_SIZE 14
#define LABEL_MIN_FONT_SIZE 14
#define SYNOPSIS_FONT_SIZE 12
#define SYNOPSIS_MIN_FONT_SIZE 10

#define PREFERRED_HEIGHT 82

#define ACCESSORY_WIDTH 14


@implementation RumorNodeView

@synthesize nodeImage;
@synthesize selected;

- (RumorNode *)rumorNode
{
	return rumorNode;
}

- (void)setRumorNode:(RumorNode *)theRumorNode
{
	if (rumorNode != theRumorNode) {
		[rumorNode release];
		rumorNode = [theRumorNode retain];
		
		self.nodeImage = nil;
		
		if (rumorNode != nil && rumorNode.imageUrl != nil) {
			CachedImageLoader *imageLoader = [CachedImageLoader sharedImageLoader];
			[imageLoader addClientToDownloadQueue:self];
		}
	}
}

+ (NSInteger)preferredHeight
{
	return PREFERRED_HEIGHT;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithRumorNode:nil withFrame:frame];
}


- (id)initWithRumorNode:(RumorNode *)theRumorNode withFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.rumorNode = theRumorNode;
		self.backgroundColor = [UIColor whiteColor];
		self.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
	if (rumorNode == nil) {
		return;
	}
	
	UIColor *labelTextColor = [UIColor blackColor];
	UIFont *labelFont = [UIFont boldSystemFontOfSize:LABEL_FONT_SIZE];
	
	UIColor *synopsisTextColor = [UIColor darkGrayColor];
	UIFont *synopsisFont = [UIFont systemFontOfSize:SYNOPSIS_FONT_SIZE];
	
	if ([self isSelected]) {
		labelTextColor = [UIColor whiteColor];
		synopsisTextColor = [UIColor whiteColor];
	}
	
	CGRect contentRect = rect;
	contentRect.size.width -= ACCESSORY_WIDTH;
	CGRect synopsisRect = contentRect;
	CGPoint point;
	
	if (rumorNode.veracityImage != nil) {
		point = CGPointMake(VERACITY_IMAGE_X, TOP_ROW_Y);
		[rumorNode.veracityImage drawAtPoint:point];
	}
	
	NSInteger leftMargin = SYNOPSIS_X;
	if (rumorNode.imageUrl == nil || [rumorNode.imageUrl isEqual:@""]) {
		leftMargin = LABEL_X;
	}
	synopsisRect.size.width = synopsisRect.size.width - leftMargin;
	
	NSString *title = [NSString string];
	if (rumorNode.label != nil && ![rumorNode.label isEqual:@""]) {
		title = rumorNode.label;
	} else if (rumorNode.synopsis != nil && ![rumorNode.synopsis isEqual:@""]) {
		title = [rumorNode.synopsis capitalizedString];
	}
	[labelTextColor set];
	point = CGPointMake(leftMargin, TOP_ROW_Y - 2);
	[title drawAtPoint:point forWidth:synopsisRect.size.width withFont:labelFont minFontSize:LABEL_MIN_FONT_SIZE actualFontSize:NULL lineBreakMode:NSLineBreakByTruncatingTail baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
	
	
	NSString *synopsis = [NSString string];
	if (rumorNode.synopsis != nil && ![rumorNode.synopsis isEqual:@""]) {
		synopsis = rumorNode.synopsis;
	} else if (rumorNode.label != nil && ![rumorNode.label isEqual:@""]) {
		synopsis = rumorNode.label;
	}
	synopsisRect.origin.x = leftMargin;
	synopsisRect.origin.y = BOTTOM_ROW_Y - 2;
	synopsisRect.size.width = synopsisRect.size.width;
	synopsisRect.size.height = synopsisRect.size.height - BOTTOM_ROW_Y;
	
	[synopsisTextColor set];
	[synopsis drawInRect:synopsisRect withFont:synopsisFont];
	
	
	if (rumorNode.veracityImage != nil) {
		point = CGPointMake(IMAGE_X, IMAGE_Y);
	} else {
		point = CGPointMake(VERACITY_IMAGE_X, TOP_ROW_Y);
	}
	if (self.nodeImage != nil) {
		[self.nodeImage drawAtPoint:point];
	} else {
		// Draw a placeholder image
		if (rumorNode.imageUrl != nil && ![@"" isEqual:rumorNode.imageUrl]) {
			UIImage* placeholderImage = [UIImage imageNamed:@"placeholder.png"];
			[placeholderImage drawAtPoint:point];
		}
	}
}

- (NSWebViewURLRequest *)request
{
	if (rumorNode != nil && rumorNode.imageUrl != nil) {
		NSString *urlString = rumorNode.imageUrl;
		NSURL *url = [NSURL URLWithString:urlString];
		NSWebViewURLRequest *urlRequest = [NSWebViewURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
		return urlRequest;
	} else {
		return nil;
	}
	
}

- (void)renderImage:(UIImage *)image;
{
	self.nodeImage = image;
	[self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
}

- (void)dealloc
{
	[rumorNode release];
	[nodeImage release];
	
    [super dealloc];
}


@end
