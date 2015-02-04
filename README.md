# PIVideoPlayer

## Description

This project aims to create a simple wrapper around `AVFoundation` in order to play videos in a `UIView`. As of now, this repo
only supports silent, single-loop videos. The idea was to create a library that was simpler than the default video player 
(there is no chrome, not tracking, etc.).

## Usage

There are two ways to play video included in this project.

The first way is to use `PIVideoPlayerView` which is a subclass of `UIView` that plays video. You are responsible for setting the frame
size, loading the video, and starting it.

The second way is to use `PIVideoPlayerWindow` which presents a simple way to play a full-screen video above all other views. 
As with normal ARC rules, be sure to retain a reference to the `UIWindow`` in some capacity or else it will be consumed by ARC.

## Requirements

This project utilizes ARC and is compatible with iOS version 7.0 and above.

## Installation

PIVideoPlayer is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "PIVideoPlayer"

## Author

Christopher Jones, c.jones@prolificinteractive.com

## License

PIVideoPlayer is available under the MIT license. See the LICENSE file for more info.

