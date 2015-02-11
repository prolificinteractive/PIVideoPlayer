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

#import "PIVideoView.h"
#import <AVFoundation/AVFoundation.h>

static NSString *const kAVPlayerStatusPropertyName = @"status";
static const NSString *itemStatusContext;

@interface PIVideoView ()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, assign) BOOL playVideoOnFinishedLoading;
@property (nonatomic, assign) BOOL videoLoading;
@property (nonatomic, assign) BOOL videoLoaded;

// Holds the timestamp of the video when the application enters the background. Once it re-enters the foreground, we seek to this timestamp and resume playing the video. This prevents the video from appearing frozen on relaunch or restarting from the beginning.
@property (nonatomic, assign) CMTime pausedTime;

@end

@implementation PIVideoView

#pragma mark - Init / Dealloc

- (instancetype)initWithFileNamed:(NSString *)file type:(NSString *)type
{
    NSString *path = [[NSBundle mainBundle] pathForResource:file ofType:type];
    return [self initWithFilePath:path];
}

- (instancetype)initWithFilePath:(NSString *)filePath
{
    NSURL *fileURL =[NSURL fileURLWithPath:filePath];
    return [self initWithURL:fileURL];
}

- (instancetype)initWithURL:(NSURL *)url
{
    if (self = [super init]){
        self.fileURL = url;
        self.pausedTime = kCMTimeZero;

        // Prevents the video from stopping any background music that the user may be playing.
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient
                                         withOptions:AVAudioSessionCategoryOptionMixWithOthers
                                               error:nil];
    }

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.player.currentItem removeObserver:self forKeyPath:kAVPlayerStatusPropertyName];
}

#pragma mark - Override

// Observes the initial setting of the AVPlayerItem's status property.
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &itemStatusContext && !self.videoLoaded) {
        self.videoLoaded = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self onVideoLoaded];
        });
    }
}

#pragma mark - Public

- (void)loadVideo
{
    if (!self.videoLoaded && !self.videoLoading) {
        [self loadVideoFile];
    }
}

- (void)play
{
    if (!self.fileURL){
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"[%@] attempt to play a video without no fileURL.",
                                               NSStringFromClass([self class])]
                                     userInfo:nil];
    }

    // If the caller has not yet loaded the video, we will load the video first and then start playing the video immediately after. Otherwise, just start playing the video.
    if (!self.videoLoaded && !self.videoLoading) {
        self.playVideoOnFinishedLoading = YES;
        [self loadVideoFile];
    } else if (self.videoLoaded){
        [self beginPlayingLoadedVideoFile];
    }
}

#pragma mark - Private

// If the video is in the middle of playing and the application enters background, when it re-enters the foreground it will have paused the video and won't play. Using this notification, we can follow when the application becomes active and restart the video.
- (void)registerForAVPlayerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillBecomeActive:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];

    // Here, we will pause the video
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
}

- (void)applicationWillBecomeActive:(id)sender
{
    // - seekToTime: will not work here for the short video as it will restart the video from the beginning as that is apparently the nearest keyframe.
    // SEE: http://stackoverflow.com/a/12135579
    [self.player seekToTime:self.pausedTime
            toleranceBefore:kCMTimeZero
             toleranceAfter:kCMTimeZero];
    [self.player play];
}

- (void)applicationWillResignActive:(id)sender
{
    self.pausedTime = self.player.currentTime;
}

- (void)beginPlayingLoadedVideoFile
{
    NSAssert(self.videoLoaded, @"Call to beginPlayingLoadedVideoFile when no video was loaded.");
    [self registerForAVPlayerNotifications];
    [self.player play];

    if ([self.delegate respondsToSelector:@selector(videoViewDidBeginPlayingVideo:)]) {
        [self.delegate videoViewDidBeginPlayingVideo:self];
    }
}

- (void)loadVideoFile
{
    static NSString *const kTracksKey = @"tracks";
    static NSString *const kPlayableKey = @"playable";

    self.videoLoading = YES;

    AVURLAsset *asset = [AVURLAsset assetWithURL:self.fileURL];
    [asset loadValuesAsynchronouslyForKeys:@[kTracksKey, kPlayableKey] completionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *statusError;
            NSError *playableError;

            AVKeyValueStatus status = [asset statusOfValueForKey:kTracksKey error:&statusError];
            BOOL playable = [asset statusOfValueForKey:kPlayableKey error:&playableError];

            if (status == AVKeyValueStatusLoaded && playable) {
                AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
                [item addObserver:self forKeyPath:kAVPlayerStatusPropertyName
                          options:NSKeyValueObservingOptionInitial
                          context:&itemStatusContext];

                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(videoFinishedPlaying:)
                                                             name:AVPlayerItemDidPlayToEndTimeNotification
                                                           object:item];

                self.player = [AVPlayer playerWithPlayerItem:item];

                self.player.rate = 1.f;
                self.player.muted = YES;
                self.player.volume = 0.f;
            } else {
                NSError *error = (statusError ? statusError : playableError);
                if ([self.delegate respondsToSelector:@selector(videoViewDidFailToLoadVideo:error:)]) {
                    [self.delegate videoViewDidFailToLoadVideo:self error:error];
                }
            }
        });
    }];
}

- (void)onVideoLoaded
{
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    playerLayer.frame = self.bounds;

    [self.layer addSublayer:playerLayer];

    if ([self.delegate respondsToSelector:@selector(videoViewDidLoadVideo:)]) {
        [self.delegate videoViewDidLoadVideo:self];
    }

    // If the user called -play before -loadVideo, this BOOL will be YES, and the video should start playing automatically.
    if (self.playVideoOnFinishedLoading) {
        [self beginPlayingLoadedVideoFile];
    }
}

- (void)videoFinishedPlaying:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(videoViewDidFinishPlayingVideo:)]){
        [self.delegate videoViewDidFinishPlayingVideo:self];
    }
}

@end
