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

#import <UIKit/UIKit.h>

@class PIVideoView;

@protocol PIVideoViewDelegate <NSObject>

@optional

/**
 *  Notifies the receiver that an instance of the video view has loaded the video and is ready to begin playing.
 *
 *  @param view
 *      The current instance of PIVideoView
 */
- (void)videoViewDidLoadVideo:(PIVideoView *)view;

/**
 *  Notifies the receiver that an instance of the video view has failed to load the video.
 *
 *  @param view
 *      The current instance of PIVideoView
 *
 *  @param error
 *      Error message signaling the reason why the video failed to load.
 */
- (void)videoViewDidFailToLoadVideo:(PIVideoView *)view
                              error:(NSError *)error;

/**
 *  Notifies the receiver that an instance of the video view has begun playing its video.
 *
 *  @param view
 *      The current instance of PIVideoView
 */
- (void)videoViewDidBeginPlayingVideo:(PIVideoView *)view;

/**
 *  Notifies the receiver that an instance of the video view has finished playing its video.
 *
 *  @param view
 *      The current instance of PIVideoView
 */
- (void)videoViewDidFinishPlayingVideo:(PIVideoView *)view;

@end


/**
 *  A view for playing videos. Does not provide any chrome or controls for playing the video file.
 */
@interface PIVideoView : UIView

/**
 *  The URL of the video file to be played. This must be set before calling `-loadVideo` or `-play`
 */
@property (nonatomic, strong) NSURL *fileURL;

/**
 *	If it's on, it'll loop the video continously and videoViewDidFinishPlayingVideo delegate method won't be called.
 */
@property (nonatomic, assign) BOOL shouldLoopVideo;

/**
 *  The video view delegate.
 */
@property (nonatomic, weak) id<PIVideoViewDelegate> delegate;

/**
 *  Initializes a new video view instance using the video at the specified URL.
 *
 *  @param url
 *      The URL of the video to play.
 *
 *  @return
 *      A new instance of SCVideoView;
 */
- (instancetype)initWithURL:(NSURL *)url;

/**
 *  Initializes a new video view instance using the specified video file name and type. Note that the file name and type will be searched for in the main NSBundle.
 *
 *  @param file
 *      The name of the file to play.
 *
 *  @param type
 *      The file type
 *
 *  @return
 *      A new instance of SCVideoView;
 */
- (instancetype)initWithFileNamed:(NSString *)file
                             type:(NSString *)type;

/**
 *  Initializes a new video view instance using the video at the specified path.
 *
 *  @param filePath
 *      The filePath to the video.
 *
 *  @return
 *      A new instance of SCVideoView;
 */
- (instancetype)initWithFilePath:(NSString *)filePath;

/**
 *  Prepares the video to be played, if needed.
 */
- (void)loadVideo;

/**
 *  Begins playing the video. If the video has not yet been loaded, the video will be loaded first.
 */
- (void)play;

@end
