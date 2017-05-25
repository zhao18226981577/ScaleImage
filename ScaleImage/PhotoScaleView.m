//
//  PhotoScaleView.m
//  CRM
//
//  Created by 精智 on 17/5/25.
//  Copyright © 2017年 精智. All rights reserved.
//

#import "PhotoScaleView.h"
#import "UIViewAdditions.h"
@interface PhotoScaleView() <UIScrollViewDelegate>
#define PROGRESS_VIEW_WIDTH 60.f
#define BUTTON_SIDE_MARGIN 20.f
#define PREVIEW_ANIMATION_DURATION 0.5f

@property (nonatomic, assign) CGRect        fromRect;
@property (nonatomic, assign) BOOL          isOriginPhotoLoaded;

@property (nonatomic, strong) UIImage       *thumbnail;
@property (nonatomic, strong) UIScrollView  *scrollView;
@property (nonatomic, strong) UIImageView   *imageView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@end

@implementation PhotoScaleView
- (id)initWiththumbnail:(UIImage*)thumbnail fromRect:(CGRect)rect
{
    self = [super initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    if (self)
    {
        self.fromRect = rect;
        self.thumbnail = thumbnail;
        [self initAllViews];
        
        UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeFromSuperviewAnimation)];
        [self addGestureRecognizer:singleTap];
        
        UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scaleImageView:)];
        doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTap];
        // enable double tap
        [singleTap requireGestureRecognizerToFail:doubleTap];
        
        self.isOriginPhotoLoaded = NO;
        [self showImageViewAnimation];
    }
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showImageViewAnimation
{
    self.imageView.frame = self.fromRect;
    if (self.thumbnail)
    {
        self.alpha = 0.f;
        
        // calculate scaled frame
        CGRect finalFrame = [self calculateScaledFinalFrame];
        if (finalFrame.size.height > self.height)
        {
            self.scrollView.contentSize = CGSizeMake(self.width, finalFrame.size.height);
        }
        
        self.imageView.image = self.thumbnail;
        
        // animation frame
        [UIView animateWithDuration:PREVIEW_ANIMATION_DURATION animations:^{
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
            self.imageView.frame = finalFrame;
            self.alpha = 1.f;
        } completion:^(BOOL finished) {
             [_activityIndicator stopAnimating];
        }];

    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeFromSuperviewAnimation
{
    
    // consider scroll offset
    CGRect newFromRect = self.fromRect;
    newFromRect.origin = CGPointMake(self.fromRect.origin.x + self.scrollView.contentOffset.x,
                                     self.fromRect.origin.y + self.scrollView.contentOffset.y);
    [UIView animateWithDuration:PREVIEW_ANIMATION_DURATION animations:^{
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        self.imageView.frame = newFromRect;
        self.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


- (void)initAllViews
{
    self.backgroundColor = [UIColor blackColor];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.delegate = self;
    _scrollView.zoomScale = 1.0;
    _scrollView.minimumZoomScale = 1.0;
    _scrollView.maximumZoomScale = 2.0f;
    _scrollView.backgroundColor = [UIColor clearColor];
    [self addSubview:_scrollView];
    
    _imageView = [[UIImageView alloc] initWithFrame:_scrollView.bounds];
    _imageView.backgroundColor = [UIColor clearColor];
    [_scrollView addSubview:_imageView];
    
    _activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _activityIndicator.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
    [self.scrollView addSubview:_activityIndicator];
    _activityIndicator.hidesWhenStopped = YES;
    
}

- (void)scaleImageView:(UITapGestureRecognizer *)tapGesture
{
    CGPoint tapPoint = [tapGesture locationInView:self.scrollView];
    if (self.scrollView.zoomScale > 1.f)
    {
        [self.scrollView setZoomScale:1.f animated:YES];
    }
    else
    {
        [self zoomScrollView:self.scrollView toPoint:tapPoint withScale:2.f animated:YES];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)calculateScaledFinalFrame
{
    CGSize thumbSize = self.thumbnail.size;
    CGFloat finalHeight = self.width * (thumbSize.height / thumbSize.width);
    CGFloat top = 0.f;
    if (finalHeight < self.height)
    {
        top = (self.height - finalHeight) / 2.f;
    }
    return CGRectMake(0.f, top, self.width, finalHeight);
}


- (void)zoomScrollView:(UIScrollView*)view toPoint:(CGPoint)zoomPoint withScale: (CGFloat)scale animated: (BOOL)animated
{
    //Normalize current content size back to content scale of 1.0f
    CGSize contentSize = CGSizeZero;
    
    contentSize.width = (view.contentSize.width / view.zoomScale);
    contentSize.height = (view.contentSize.height / view.zoomScale);
    
    //translate the zoom point to relative to the content rect
    //jimneylee add compare contentsize with bounds's size
    if (view.contentSize.width < view.bounds.size.width)
    {
        zoomPoint.x = (zoomPoint.x / view.bounds.size.width) * contentSize.width;
    }
    else
    {
        zoomPoint.x = (zoomPoint.x / view.contentSize.width) * contentSize.width;
    }
    if (view.contentSize.height < view.bounds.size.height)
    {
        zoomPoint.y = (zoomPoint.y / view.bounds.size.height) * contentSize.height;
    }
    else
    {
        zoomPoint.y = (zoomPoint.y / view.contentSize.height) * contentSize.height;
    }
    
    //derive the size of the region to zoom to
    CGSize zoomSize = CGSizeZero;
    zoomSize.width = view.bounds.size.width / scale;
    zoomSize.height = view.bounds.size.height / scale;
    
    //offset the zoom rect so the actual zoom point is in the middle of the rectangle
    CGRect zoomRect = CGRectZero;
    zoomRect.origin.x = zoomPoint.x - zoomSize.width / 2.0f;
    zoomRect.origin.y = zoomPoint.y - zoomSize.height / 2.0f;
    zoomRect.size.width = zoomSize.width;
    zoomRect.size.height = zoomSize.height;
    
    //apply the resize
    [view zoomToRect: zoomRect animated: animated];
}

#pragma mark - UIScrolViewDelegate

///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}


-(void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5f : 0.f;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5f : 0.f;
    
    self.imageView.center = CGPointMake(scrollView.contentSize.width * 0.5f + offsetX, scrollView.contentSize.height * 0.5f + offsetY);
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
