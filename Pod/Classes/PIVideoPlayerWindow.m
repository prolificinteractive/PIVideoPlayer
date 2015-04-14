// Copyright (c) 2015 Prolific Interactive
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "PIVideoPlayerWindow.h"
#import <AVFoundation/AVFoundation.h>

@interface PIVideoPlayerWindow () 

@end

@implementation PIVideoPlayerWindow

#pragma mark - Init/Dealloc

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]){
        self.backgroundColor = [UIColor whiteColor];
        // Quiets a debugger warning during runtime about presenting a window without a root view controller.
        self.rootViewController = [UIViewController new];
    }

    return self;
}

#pragma mark - Public

- (void)playVideoNamed:(NSString *)videoName ofType:(NSString *)type
{
    NSString *fullPath = [[NSBundle mainBundle] pathForResource:videoName ofType:type];
    [self playVideoAtPath:fullPath];
}

- (void)playVideoAtPath:(NSString *)videoPath
{
    NSURL *fileURL = [NSURL fileURLWithPath:videoPath];
    [self playVideoWithURL:fileURL];
}

- (void)playVideoWithURL:(NSURL *)URL
{
    PIVideoView *videoView = [[PIVideoView alloc] initWithURL:URL];
    videoView.delegate = self;
    [self addSubview:videoView];

    [videoView play];
}

#pragma mark - Private

- (void)dismissWindow
{
    // Fade out the video view and alert the delegate for clean-up.
    [UIView animateWithDuration:0.3f
                     animations:^ {
                         self.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         if (self.videoPlayerWindowDelegate) {
                             [self.videoPlayerWindowDelegate videoPlayerWindowDidFinishPlaying:self];
                         }
                     }];
}

#pragma mark - Protocols
#pragma mark <SCVideoViewDelegate>

- (void)videoViewDidFinishPlayingVideo:(PIVideoView *)view
{
    [self dismissWindow];
}

- (void)videoViewDidFailToLoadVideo:(PIVideoView *)view error:(NSError *)error
{
    NSLog(@"Failed to load video due to reason: %@", error.localizedDescription);
    [self dismissWindow];
}

@end
