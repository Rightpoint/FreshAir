//
//  UIView+RZFAutoLayout.m
//
//  Created by Nick Donaldson on 10/22/13.

// Copyright 2014 Raizlabs and other contributors
// http://raizlabs.com/
// 
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "UIView+RZFAutoLayout.h"

@implementation UIView (RZFAutoLayout)

# pragma mark - Helpers

- (BOOL)rzf_constraintIsWithSuperview:(NSLayoutConstraint *)constraint
{
    return ((constraint.firstItem == self && constraint.secondItem == self.superview) ||
            (constraint.firstItem == self.superview && constraint.secondItem == self));
}

+ (UIView *)rzf_commonAncestorForViews:(NSArray *)views
{
    NSParameterAssert([views count] > 0);

    if ( [views count] == 1 ) {
        return [views firstObject];
    }

    // First, build a list of view hierarchies, where each element is a list containing the hierarhcy all the way up from each view to the top
    NSMutableArray *viewHierarchies = [[NSMutableArray alloc] initWithCapacity:[views count]];
    for ( UIView *view in views ) {
        NSMutableArray *viewHierarchy = [NSMutableArray array];

        UIView *viewCursor = view;
        while ( viewCursor != nil ) {
            [viewHierarchy addObject:viewCursor];
            viewCursor = [viewCursor superview];
        }

        [viewHierarchies addObject:viewHierarchy];
    }

    // Next, iterate through the view hierarchies. Find the first element that they all have in common. Note that this is n^2, but is quite unlikely this will ever hamper performance because view hierarchies should generally be quite shallow.
    UIView *candidateCommonAncestor = nil;
    NSArray *firstViewHierarchy = [viewHierarchies firstObject];
    NSArray *otherViewHierarchies = [viewHierarchies subarrayWithRange:NSMakeRange(1, [viewHierarchies count] - 1)];

    for ( UIView *view in firstViewHierarchy ) {
        BOOL commonAncestorMatches = YES;

        for ( NSArray *otherViewHierarchy in otherViewHierarchies ) {
            if ( [otherViewHierarchy containsObject:view] == NO ) {
                commonAncestorMatches = NO;
                break;
            }
        }

        if ( commonAncestorMatches ) {
            candidateCommonAncestor = view;
            break;
        }
    }

    return candidateCommonAncestor;
}

# pragma mark - Constraint Accessors

- (NSLayoutConstraint *)rzf_pinnedWidthConstraint
{
    __block NSLayoutConstraint *constraint = nil;
    [self.constraints enumerateObjectsUsingBlock:^(NSLayoutConstraint *c, NSUInteger idx, BOOL *stop) {
        if (c.firstItem == self &&
            c.firstAttribute == NSLayoutAttributeWidth &&
            c.secondAttribute == NSLayoutAttributeNotAnAttribute &&
            c.relation == NSLayoutRelationEqual)
        {
            constraint = c;
            *stop = YES;
        }
    }];
    return constraint;
}

- (NSLayoutConstraint *)rzf_pinnedHeightConstraint
{
    __block NSLayoutConstraint *constraint = nil;
    [self.constraints enumerateObjectsUsingBlock:^(NSLayoutConstraint *c, NSUInteger idx, BOOL *stop) {
        if (c.firstItem == self &&
            c.firstAttribute == NSLayoutAttributeHeight &&
            c.secondAttribute == NSLayoutAttributeNotAnAttribute &&
            c.relation == NSLayoutRelationEqual)
        {
            constraint = c;
            *stop = YES;
        }
    }];
    return constraint;
}

- (NSLayoutConstraint*)rzf_pinnedTopConstraint
{
    if (self.superview == nil) return nil;
    
    __block NSLayoutConstraint *constraint = nil;
    [[[self superview] constraints] enumerateObjectsUsingBlock:^(NSLayoutConstraint *c, NSUInteger idx, BOOL *stop) {
        if ([self rzf_constraintIsWithSuperview:c] &&
            c.firstAttribute == NSLayoutAttributeTop &&
            c.secondAttribute == NSLayoutAttributeTop &&
            c.relation == NSLayoutRelationEqual)
        {
            constraint = c;
            *stop = YES;
        }
    }];
    return constraint;
}

- (NSLayoutConstraint*)rzf_pinnedLeftConstraint
{
    if (self.superview == nil) return nil;
    
    __block NSLayoutConstraint *constraint = nil;
    [[[self superview] constraints] enumerateObjectsUsingBlock:^(NSLayoutConstraint *c, NSUInteger idx, BOOL *stop) {
        if ([self rzf_constraintIsWithSuperview:c] &&
            (c.firstAttribute == NSLayoutAttributeLeft || c.firstAttribute == NSLayoutAttributeLeading) &&
            (c.secondAttribute == NSLayoutAttributeLeft || c.secondAttribute == NSLayoutAttributeLeading) &&
            c.relation == NSLayoutRelationEqual)
        {
            constraint = c;
            *stop = YES;
        }
    }];
    return constraint;
}

- (NSLayoutConstraint*)rzf_pinnedRightConstraint
{
    if (self.superview == nil) return nil;
    
    __block NSLayoutConstraint *constraint = nil;
    [[[self superview] constraints] enumerateObjectsUsingBlock:^(NSLayoutConstraint *c, NSUInteger idx, BOOL *stop) {
        if ([self rzf_constraintIsWithSuperview:c] &&
            (c.firstAttribute == NSLayoutAttributeRight  || c.firstAttribute == NSLayoutAttributeTrailing) &&
            (c.secondAttribute == NSLayoutAttributeRight || c.secondAttribute == NSLayoutAttributeTrailing) &&
            c.relation == NSLayoutRelationEqual)
        {
            constraint = c;
            *stop = YES;
        }
    }];
    return constraint;
}

- (NSLayoutConstraint*)rzf_pinnedBottomConstraint
{
    if (self.superview == nil) return nil;
    
    __block NSLayoutConstraint *constraint = nil;
    [[[self superview] constraints] enumerateObjectsUsingBlock:^(NSLayoutConstraint *c, NSUInteger idx, BOOL *stop) {
        if ([self rzf_constraintIsWithSuperview:c] &&
            c.firstAttribute == NSLayoutAttributeBottom &&
            c.secondAttribute == NSLayoutAttributeBottom &&
            c.relation == NSLayoutRelationEqual)
        {
            constraint = c;
            *stop = YES;
        }
    }];
    return constraint;
}

- (NSLayoutConstraint*)rzf_pinnedCenterXConstraint
{
    if (self.superview == nil) return nil;
    
    __block NSLayoutConstraint *constraint = nil;
    [[[self superview] constraints] enumerateObjectsUsingBlock:^(NSLayoutConstraint *c, NSUInteger idx, BOOL *stop) {
        if ((c.firstItem == self && c.firstAttribute == NSLayoutAttributeCenterX) ||
            (c.secondItem == self && c.secondAttribute == NSLayoutAttributeCenterX))
        {
            constraint = c;
            *stop = YES;
        }
    }];
    return constraint;
}

- (NSLayoutConstraint*)rzf_pinnedCenterYConstraint
{
    if (self.superview == nil) return nil;
    
    __block NSLayoutConstraint *constraint = nil;
    [[[self superview] constraints] enumerateObjectsUsingBlock:^(NSLayoutConstraint *c, NSUInteger idx, BOOL *stop) {
        if ((c.firstItem == self && c.firstAttribute == NSLayoutAttributeCenterY) ||
            (c.secondItem == self && c.secondAttribute == NSLayoutAttributeCenterY))
        {
            constraint = c;
            *stop = YES;
        }
    }];
    return constraint;
}

# pragma mark - Constraint Creation

- (NSLayoutConstraint *)rzf_pinWidthTo:(CGFloat)width
{
    NSLayoutConstraint *w = [NSLayoutConstraint constraintWithItem:self
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:1.0f
                                                          constant:width];
    [self addConstraint:w];

    return w;
}

- (NSLayoutConstraint *)rzf_pinWidthToView:(UIView *)view
{
    return [self rzf_pinWidthToView:view multiplier:1.0f];
}

- (NSLayoutConstraint *)rzf_pinWidthToView:(UIView *)view multiplier:(CGFloat)multiplier
{
    NSLayoutConstraint *w = [NSLayoutConstraint constraintWithItem:self
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:view
                                                         attribute:NSLayoutAttributeWidth
                                                        multiplier:multiplier
                                                          constant:0.0f];
    UIView *commonAncestorView = [[self class] rzf_commonAncestorForViews:@[ self, view ]];
    if ( commonAncestorView == nil ) {
        NSString *exceptionString = [NSString stringWithFormat:@"Can't find a common ancestor for views: %@ and %@", self, view];
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:exceptionString userInfo:nil];
    }

    [commonAncestorView addConstraint:w];

    return w;
}

- (NSLayoutConstraint *)rzf_pinHeightTo:(CGFloat)height
{
    NSLayoutConstraint *h = [NSLayoutConstraint constraintWithItem:self
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:1.0f
                                                          constant:height];
    [self addConstraint:h];

    return h;
}

- (NSLayoutConstraint *)rzf_pinHeightToView:(UIView *)view
{
    return [self rzf_pinHeightToView:view multiplier:1.0f];
}

- (NSLayoutConstraint *)rzf_pinHeightToView:(UIView *)view multiplier:(CGFloat)multiplier
{
    NSLayoutConstraint *h = [NSLayoutConstraint constraintWithItem:self
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:view
                                                         attribute:NSLayoutAttributeHeight
                                                        multiplier:multiplier
                                                          constant:0.0f];
    UIView *commonAncestorView = [[self class] rzf_commonAncestorForViews:@[ self, view ]];
    if ( commonAncestorView == nil ) {
        NSString *exceptionString = [NSString stringWithFormat:@"Can't find a common ancestor for views: %@ and %@", self, view];
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:exceptionString userInfo:nil];
    }


    [commonAncestorView addConstraint:h];

    return h;
}

- (NSArray *)rzf_pinSizeTo:(CGSize)size
{
    NSLayoutConstraint *w = [self rzf_pinWidthTo:size.width];
    NSLayoutConstraint *h = [self rzf_pinHeightTo:size.height];

    return @[w, h];
}

- (NSArray *)rzf_fillContainerHorizontallyWithPadding:(CGFloat)padding
{
    NSAssert(self.superview != nil, @"Must have superview");

    NSLayoutConstraint *l = [NSLayoutConstraint constraintWithItem:self
                                                         attribute:NSLayoutAttributeLeft
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.superview
                                                         attribute:NSLayoutAttributeLeft
                                                        multiplier:1.0f
                                                          constant:padding];
    [self.superview addConstraint:l];

    NSLayoutConstraint *r = [NSLayoutConstraint constraintWithItem:self
                                                         attribute:NSLayoutAttributeRight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.superview
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.0f
                                                          constant:-padding];
    [self.superview addConstraint:r];

    return @[l, r];
}

- (NSArray *)rzf_fillContainerHorizontallyWithMinimumPadding:(CGFloat)padding
{
    NSAssert(self.superview != nil, @"Must have superview");

    NSLayoutConstraint *l = [NSLayoutConstraint constraintWithItem:self
                                                         attribute:NSLayoutAttributeLeft
                                                         relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                            toItem:self.superview
                                                         attribute:NSLayoutAttributeLeft
                                                        multiplier:1.0f
                                                          constant:padding];
    [self.superview addConstraint:l];

    NSLayoutConstraint *r = [NSLayoutConstraint constraintWithItem:self
                                                         attribute:NSLayoutAttributeRight
                                                         relatedBy:NSLayoutRelationLessThanOrEqual
                                                            toItem:self.superview
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.0f
                                                          constant:-padding];
    [self.superview addConstraint:r];

    return @[l, r];
}

- (NSArray *)rzf_fillContainerVerticallyWithPadding:(CGFloat)padding
{
    NSAssert(self.superview != nil, @"Must have superview");

    NSLayoutConstraint *t = [NSLayoutConstraint constraintWithItem:self
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.superview
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0f
                                                          constant:padding];
    [self.superview addConstraint:t];

    NSLayoutConstraint *b = [NSLayoutConstraint constraintWithItem:self
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.superview
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0f
                                                          constant:-padding];
    [self.superview addConstraint:b];

    return @[t, b];
}

- (NSArray *)rzf_fillContainerVerticallyWithMinimumPadding:(CGFloat)padding
{
    NSAssert(self.superview != nil, @"Must have superview");

    NSLayoutConstraint *t = [NSLayoutConstraint constraintWithItem:self
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                            toItem:self.superview
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0f
                                                          constant:padding];
    [self.superview addConstraint:t];

    NSLayoutConstraint *b = [NSLayoutConstraint constraintWithItem:self
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationLessThanOrEqual
                                                            toItem:self.superview
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0f
                                                          constant:-padding];
    [self.superview addConstraint:b];

    return @[t, b];
}

- (NSLayoutConstraint *)rzf_pinTopSpaceToSuperviewWithPadding:(CGFloat)padding
{
    NSAssert(self.superview != nil, @"Must have superview");

    NSLayoutConstraint *c = [NSLayoutConstraint constraintWithItem:self
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.superview
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0f
                                                          constant:padding];
    [self.superview addConstraint:c];

    return c;
}


- (NSLayoutConstraint *)rzf_pinLeftSpaceToSuperviewWithPadding:(CGFloat)padding
{
    NSAssert(self.superview != nil, @"Must have superview");

    NSLayoutConstraint *c = [NSLayoutConstraint constraintWithItem:self
                                                         attribute:NSLayoutAttributeLeft
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.superview
                                                         attribute:NSLayoutAttributeLeft
                                                        multiplier:1.0f
                                                          constant:padding];
    [self.superview addConstraint:c];

    return c;
}

- (NSLayoutConstraint *)rzf_pinBottomSpaceToSuperviewWithPadding:(CGFloat)padding
{
    NSAssert(self.superview != nil, @"Must have superview");

    NSLayoutConstraint *c = [NSLayoutConstraint constraintWithItem:self
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.superview
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0f
                                                          constant:-padding];
    [self.superview addConstraint:c];

    return c;
}

- (NSLayoutConstraint *)rzf_pinRightSpaceToSuperviewWithPadding:(CGFloat)padding
{
    NSAssert(self.superview != nil, @"Must have superview");

    NSLayoutConstraint *c = [NSLayoutConstraint constraintWithItem:self
                                                         attribute:NSLayoutAttributeRight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.superview
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.0f
                                                          constant:-padding];
    [self.superview addConstraint:c];

    return c;
}


- (NSLayoutConstraint *)rzf_centerHorizontallyInContainer
{
    return [self rzf_centerHorizontallyInContainerWithOffset:0];
}

- (NSLayoutConstraint *)rzf_centerHorizontallyInContainerWithOffset:(CGFloat)offset
{
    NSAssert(self.superview != nil, @"Must have superview");
    
    NSLayoutConstraint *c = [NSLayoutConstraint constraintWithItem:self
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.superview
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.0f
                                                          constant:offset];
    [self.superview addConstraint:c];
    
    return c;
}

- (NSLayoutConstraint *)rzf_centerVerticallyInContainer
{
    return [self rzf_centerVerticallyInContainerWithOffset:0];
}

- (NSLayoutConstraint *)rzf_centerVerticallyInContainerWithOffset:(CGFloat)offset
{
    NSAssert(self.superview != nil, @"Must have superview");
    
    NSLayoutConstraint *c = [NSLayoutConstraint constraintWithItem:self
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.superview
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.0f
                                                          constant:offset];
    [self.superview addConstraint:c];

    return c;
}

- (NSArray *)rzf_fillContainerWithInsets:(UIEdgeInsets)insets
{
    NSAssert(self.superview != nil, @"Must have superview");
    
    NSLayoutConstraint *top     = [self rzf_pinTopSpaceToSuperviewWithPadding:insets.top];
    NSLayoutConstraint *left    = [self rzf_pinLeftSpaceToSuperviewWithPadding:insets.left];
    NSLayoutConstraint *bottom  = [self rzf_pinBottomSpaceToSuperviewWithPadding:insets.bottom];
    NSLayoutConstraint *right   = [self rzf_pinRightSpaceToSuperviewWithPadding:insets.right];

    NSArray *constraints = @[top, left, bottom, right];

    return constraints;
}

# pragma mark - Batch Alignment

- (NSArray *)rzf_spaceSubviews:(NSArray *)subviews vertically:(BOOL)vertically minimumItemSpacing:(CGFloat)itemSpacing
{
    return [self rzf_spaceSubviews:subviews vertically:vertically itemSpacing:itemSpacing relation:NSLayoutRelationGreaterThanOrEqual];
}

- (NSArray *)rzf_spaceSubviews:(NSArray *)subviews vertically:(BOOL)vertically itemSpacing:(CGFloat)itemSpacing relation:(NSLayoutRelation)relation
{
    NSAssert(subviews.count > 1, @"Must provide at least two items");
    
    NSMutableArray *constraints = [NSMutableArray array];

    NSLayoutAttribute a1 = vertically ? NSLayoutAttributeTop : NSLayoutAttributeLeft;
    NSLayoutAttribute a2 = vertically ? NSLayoutAttributeBottom : NSLayoutAttributeRight;
    
    [subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop)
    {

        UIView *nextView = (idx == subviews.count - 1) ? nil : subviews[idx + 1];

        if (nextView)
        {
            NSLayoutConstraint *s = [NSLayoutConstraint constraintWithItem:nextView
                                                                 attribute:a1
                                                                 relatedBy:relation
                                                                    toItem:view
                                                                 attribute:a2
                                                                multiplier:1.0f
                                                                  constant:itemSpacing];

            [constraints addObject:s];
        }

    }];
    
    [self addConstraints:constraints];

    return constraints;
}

- (NSArray *)rzf_distributeSubviews:(NSArray *)subviews vertically:(BOOL)vertically
{
    NSAssert(subviews.count > 1, @"Must provide at least two items");
    
    NSMutableArray *constraints = [NSMutableArray array];
    
    NSLayoutAttribute centerAlongAxisAttribute = vertically ? NSLayoutAttributeCenterX : NSLayoutAttributeCenterY;
    NSLayoutAttribute distributeAlongAxisAttribute = vertically ? NSLayoutAttributeCenterY : NSLayoutAttributeCenterX;
    
    // Calculate the incremental offset of each view as proportion of the container's center point: 1/((n + 1) / 2)
    CGFloat distributionMultiplierIncrement = 1.0f / ((subviews.count + 1) / 2.0f);
    
    [subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop)
    {
         // Calculate the actual multiplier for this view index.
         CGFloat distributionMultiplier = distributionMultiplierIncrement * (idx + 1);
         
         // Create a constraint representing distribution along the given axis using this multiplier.
         NSLayoutConstraint *distributeConstraint = [NSLayoutConstraint constraintWithItem:view
                                                                                 attribute:distributeAlongAxisAttribute
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:self
                                                                                 attribute:distributeAlongAxisAttribute
                                                                                multiplier:distributionMultiplier
                                                                                  constant:0.0f];
         
         // Create a constraint to center the view along the other axis.
         NSLayoutConstraint *centerConstraint = [NSLayoutConstraint constraintWithItem:view
                                                                             attribute:centerAlongAxisAttribute
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self
                                                                             attribute:centerAlongAxisAttribute
                                                                            multiplier:1.0f
                                                                              constant:0.0f];
         // Add both constraints for the view.
         [constraints addObject:distributeConstraint];
         [constraints addObject:centerConstraint];
     }];
    
    [self addConstraints:constraints];

    return constraints;
}

- (NSArray *)rzf_alignSubviews:(NSArray *)subviews byAttribute:(NSLayoutAttribute)attribute
{
    NSAssert(subviews.count > 1, @"Must provide at least two items");

    NSMutableArray *constraints = [NSMutableArray array];
    
    [subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop)
    {

        UIView *nextView = (idx == subviews.count - 1) ? nil : subviews[idx + 1];
        if (nextView)
        {
            NSLayoutConstraint *c = [NSLayoutConstraint constraintWithItem:nextView
                                                                 attribute:attribute
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:view
                                                                 attribute:attribute
                                                                multiplier:1.0f
                                                                  constant:0.0f];
            [constraints addObject:c];
        }

    }];
    
    [self addConstraints:constraints];

    return constraints;
}

@end
