//
//  BasicVideoData.swift
//  OVPSample
//
//  Created by Nilit Danan on 8/5/20.
//  Copyright © 2020 Kaltura Inc. All rights reserved.
//

extension VideoData {

    static func getBasicVideos() -> [VideoData] {
        var videos: [VideoData] = []

        let ks = "djJ8NjI2NXwcfkLK3kyb0bjrs4yrGnOo42HUL3v5C1dAFBe9gieJk4eM_h07xbqfZ1Etl6R95talqRHsOJxx1CK0G39p1hdxOjRPLqIz0DCAIGP6jec6SlQYDRtLCl6Pt2J0YTCbW7t5NDMzYJcI3VzC0OSlqyDYM6npWZZrXBpZf2dsJ1nde20oxz7tT_8C835fPO2_o9Zb4VC84OaTCokTtqxyXI5haxEics4wFrHlCC3DTJ6CPZbClOs2U4amPpSf1yo7xeOyZLPFKyV-KXwm5-y7GlUjw4Fu8Q-cyUc6gWfYqthHKQNn0KW4i3QEVLv1Qa1Kvf4H9HdZQg7qkyfkHqY4YQ6TjXNtJpCE-unziHkWILQ3oAOyJLsoLzMZIKCztDg72sLWxgyChc4eajB2SV768ZPXaRsyE6rx9KsqNMWaexeXxQ=="
        
        videos.append(VideoData(title: "FEC-10638 0_fdb6sbgm + KS, autoPlay, preload",
                                player: PlayerData(autoPlay: true, preload: true),//, ks: ks), //GET
                                media: OVPMedia(entryId: "0_fdb6sbgm")))
        
        videos.append(VideoData(title: "FEC-10638, Inter 0_p8eqn0h8, autoPlay, preload",
                                player: PlayerData(autoPlay: true, preload: true), //GET
                                media: OVPMedia(ks: ks, entryId: "0_p8eqn0h8")))
        
        videos.append(VideoData(title: "FEC-10638 1_cqzapbhz + KS + captions, autoPlay, preload",
                                player: PlayerData(autoPlay: true, preload: true),
                                media: OVPMedia(entryId: "1_cqzapbhz")))
        
//        videos.append(VideoData(title: "External subs 0_lv1nbgm7 + KS + captions, autoPlay, preload",
//                                player: PlayerData(autoPlay: true, preload: true, ks: ks),
//                                media: OVPMedia(entryId: "0_lv1nbgm7")))
        
        videos.append(VideoData(title: "1_xay0wjby, autoPlay, preload",
                                player: PlayerData(autoPlay: true, preload: true),
                                media: OVPMedia(entryId: "1_xay0wjby")))
        
        videos.append(VideoData(title: "1_ytsd86sc, autoPlay, preload, startTime-20",
                                player: PlayerData(),
                                media: OVPMedia(entryId: "1_ytsd86sc", startTime: 20)))
        
        videos.append(VideoData(title: "1_3wzacuha, autoPlay-false, preload",
                                player: PlayerData(autoPlay: false),
                                media: OVPMedia(entryId: "1_3wzacuha")))
        
        videos.append(VideoData(title: "1_25q88snr, autoPlay, preload-false",
                                player: PlayerData(preload: false),
                                media: OVPMedia(entryId: "1_25q88snr")))

        videos.append(VideoData(title: "1_kvv3j1zk, autoPlay-false, preload-false",
                                player: PlayerData(autoPlay: false, preload: false),
                                media: OVPMedia(entryId: "1_kvv3j1zk")))
        
        return videos
    }
}
