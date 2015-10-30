//
//  PIViewController.m
//  PIVideoPlayer
//
//  Created by Christopher Jones on 02/04/2015.
//  Copyright (c) 2014 Christopher Jones. All rights reserved.
//

#import "PIViewController.h"
#import <PIVideoPlayer/PIVideoView.h>
#import <PIVideoPlayer/PIVideoPlayerWindow.h>

@interface PIViewController () <PIVideoViewDelegate>

@property (nonatomic, assign) BOOL isVideoView;

@property (nonatomic, strong) PIVideoView *videoView;
@property (nonatomic, strong) PIVideoPlayerWindow *videoWindow;

@end

@implementation PIViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Change this boolean value to see an example of either a PIVideoView or a PIVideoPlayerWindow on fullscreen mode
    self.isVideoView = NO;
    if (self.isVideoView) {
        [self createVideoView];
    } else {
        [self createVideoWindow];
    }
}

// Example videoUrl: Replace this URL by a custom one (this link could be not valid)
- (NSURL *)videoUrl
{
    return [NSURL URLWithString:@"https://12-lvl3-gcs-pdl.vimeocdn.com/vimeo-prod-skyfire-std-us/01/3729/5/143647165/432270169.mp4?expires=1446238357&token=0a6522895c686cce9fe46"];
}

- (void)createVideoWindow
{
    // Example PIVideoPlayerWindow
    self.videoWindow = [[PIVideoPlayerWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.videoWindow.windowLevel = UIWindowLevelAlert;
    self.videoWindow.backgroundColor = [UIColor blackColor];
    [self.videoWindow makeKeyAndVisible];
    [self.videoWindow playVideoWithURL:[self videoUrl]];
    
    [self addFullScreenConstraintsWithItem:self.videoWindow.videoView toItem:self.videoWindow];
}

- (void)createVideoView
{
    // Example PIVideoView
    self.videoView = [[PIVideoView alloc] initWithURL:[self videoUrl]];
    self.videoView.translatesAutoresizingMaskIntoConstraints = NO;
    self.videoView.delegate = self;
    self.videoView.backgroundColor = [UIColor blackColor];
    self.videoView.shouldLoopVideo = YES;
    [self.videoView play];
    [self.view addSubview:self.videoView];
    
    [self addFullScreenConstraintsWithItem:self.videoView toItem:self.view];
}

// Add full screen constraint
- (void)addFullScreenConstraintsWithItem:(UIView *)item toItem:(UIView *)to
{
    // Add constraints Top - Leading - Width - Height
    [to addConstraint:[NSLayoutConstraint constraintWithItem:item
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:to
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1
                                                           constant:0]];
    [to addConstraint:[NSLayoutConstraint constraintWithItem:item
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:to
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1
                                                           constant:0]];
    [to addConstraint:[NSLayoutConstraint constraintWithItem:item
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:to
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1
                                                           constant:0]];
    [to addConstraint:[NSLayoutConstraint constraintWithItem:item
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:to
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:1
                                                           constant:0]];
}

// Transition
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator

{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self.view needsUpdateConstraints];
}

#pragma mark - PIVideoView Delegate Methods

- (void)videoViewDidLoadVideo:(PIVideoView *)view
{
    // YAY
}

- (void)videoViewDidFailToLoadVideo:(PIVideoView *)view
                              error:(NSError *)error
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Could not load video" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)videoViewDidBeginPlayingVideo:(PIVideoView *)view
{
    // YAY 2
}

- (void)videoViewDidFinishPlayingVideo:(PIVideoView *)view
{
    if (!self.videoView.shouldLoopVideo) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"End" message:@"Video ended" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - PIVideoPlayerWindow Delegate Methods


- (void)videoPlayerWindowDidFinishPlaying:(PIVideoPlayerWindow *)window
{
    // YAY 3
}

@end
