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

#import "RumorNodeView.h"


#define PADDING 6

#define IMAGE_WIDTH 72
#define IMAGE_HEIGHT 72

#define VERACITY_IMAGE_WIDTH 16
#define VERACITY_IMAGE_HEIGHT 16

#define LABEL_FONT_SIZE 16
#define LABEL_MIN_FONT_SIZE 10
#define SYNOPSIS_FONT_SIZE 12
#define SYNOPSIS_MIN_FONT_SIZE 10


@implementation RumorNodeView

+ (UIEdgeInsets) padding
{
    return UIEdgeInsetsMake(6.0f, 6.0f, 6.0f, 6.0f);
}

+ (CGSize) imageSize
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat minDimension = MIN(screenSize.width, screenSize.height);
    CGFloat imageDimension = MIN(minDimension / 4.0f, 150.0f);
    return CGSizeMake(imageDimension, imageDimension);
}

+ (NSInteger)preferredHeight
{
    CGSize imageSize = self.imageSize;
    UIEdgeInsets padding = self.padding;
    return padding.top + imageSize.height + padding.bottom;
}

@synthesize rumorNode;
@synthesize nodeImage;
@synthesize selected;

- (void)dealloc
{
    [rumorNode release];
    [nodeImage release];

    [super dealloc];
}

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

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
		self.backgroundColor = [UIColor whiteColor];
		self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
	if (rumorNode == nil) {
		return;
	}
	
	UIColor *labelTextColor = [UIColor blackColor];
	UIFont *labelFont = [UIFont boldSystemFontOfSize: LABEL_FONT_SIZE];
	
	UIColor *synopsisTextColor = [UIColor darkGrayColor];
	UIFont *synopsisFont = [UIFont systemFontOfSize: SYNOPSIS_FONT_SIZE];
	
	if ([self isSelected]) {
		labelTextColor = [UIColor whiteColor];
		synopsisTextColor = [UIColor whiteColor];
	}

    UIEdgeInsets padding = RumorNodeView.padding;
    CGFloat contentHeight = rect.size.height - padding.top - padding.bottom;
    CGRect imageRect = CGRectMake(padding.left, padding.top, contentHeight, contentHeight);

    CGFloat textX = imageRect.origin.x + imageRect.size.width + padding.left;
    CGRect textRect = CGRectMake(
        textX,
        padding.top,
        rect.size.width - textX - padding.right,
        contentHeight);

    NSAttributedString *label = [[[NSAttributedString alloc] initWithString: rumorNode.label
                                                                 attributes: @{NSFontAttributeName: labelFont,
                                                                               NSForegroundColorAttributeName: labelTextColor}] autorelease];

    NSAttributedString *newlineCharacter = [[[NSAttributedString alloc] initWithString: @"\n"
                                                                            attributes: @{NSFontAttributeName: synopsisFont,
                                                                                          NSForegroundColorAttributeName: synopsisTextColor}] autorelease];

    NSString *synopsisString;
    if (rumorNode.synopsis != nil && ![rumorNode.synopsis isEqual:@""]) {
        synopsisString = rumorNode.synopsis;
    } else if (rumorNode.label != nil && ![rumorNode.label isEqual:@""]) {
        synopsisString = rumorNode.label;
    } else {
        synopsisString = [NSString string];
    }

    NSAttributedString *synopsis = [[[NSAttributedString alloc] initWithString: synopsisString
                                                                    attributes: @{NSFontAttributeName: synopsisFont,
                                                                                  NSForegroundColorAttributeName: synopsisTextColor}] autorelease];

    NSMutableAttributedString *text = [[[NSMutableAttributedString alloc] init] autorelease];
    [text appendAttributedString:label];
    [text appendAttributedString:newlineCharacter];
    [text appendAttributedString:synopsis];

    [text drawInRect:textRect];

	if (self.nodeImage != nil) {
        [self.nodeImage drawInRect:imageRect];
	} else if (rumorNode.imageUrl != nil && ![@"" isEqual:rumorNode.imageUrl]) {
		// Draw a placeholder image
        UIImage* placeholderImage = [UIImage imageNamed:@"placeholder.png"];
        CGSize placeholderSize = placeholderImage.size;
        CGRect placeholderRect = CGRectMake(imageRect.origin.x + (imageRect.size.width - placeholderSize.width) / 2.0f,
                                            imageRect.origin.y + (imageRect.size.height - placeholderSize.height) / 2.0f,
                                            placeholderSize.width,
                                            placeholderSize.height);
        [placeholderImage drawInRect:placeholderRect];
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

- (void)renderImage:(UIImage *)image
{
	self.nodeImage = image;
	[self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
}

@end
