//
//  IMAVideoData.swift
//  OVPSample_tvOS
//
//  Created by Nilit Danan on 12/20/20.
//

import PlayKit
import PlayKit_IMA

extension VideoData {
    
    static func getIMAVideos() -> [VideoData] {
        var videos: [VideoData] = []
        
        let imaPrerollConfig = IMAConfig()
        imaPrerollConfig.adTagUrl = IMAPrerollTag
        videos.append(VideoData(title: "1_xay0wjby, autoPlay, preload - IMAPrerollTag",
                                player: PlayerData(autoPlay: true,
                                                   preload: true,
                                                   pluginConfig: PluginConfig(config: [IMAPlugin.pluginName : imaPrerollConfig])),
                                media: OVPMedia(entryId: "1_xay0wjby")))
        
        let imaSkippableConfig = IMAConfig()
        imaSkippableConfig.alwaysStartWithPreroll = true
        imaSkippableConfig.adTagUrl = IMASkippableTag
        videos.append(VideoData(title: "1_ytsd86sc, autoPlay, preload, startTime-20 - IMASkippableTag",
                                player: PlayerData(pluginConfig: PluginConfig(config: [IMAPlugin.pluginName : imaSkippableConfig])),
                                media: OVPMedia(entryId: "1_ytsd86sc", startTime: 20)))
        
        let imaPostrollConfig = IMAConfig()
        imaPostrollConfig.adTagUrl = IMAPostrollTag
        videos.append(VideoData(title: "1_3wzacuha, autoPlay-false, preload - IMAPostrollTag",
                                player: PlayerData(autoPlay: false,
                                                   pluginConfig: PluginConfig(config: [IMAPlugin.pluginName : imaPostrollConfig])),
                                media: OVPMedia(entryId: "1_3wzacuha")))
        
        let imaAdRulesConfig = IMAConfig()
        imaAdRulesConfig.adTagUrl = IMAAdRulesTag
        videos.append(VideoData(title: "1_25q88snr, autoPlay, preload-false - IMAAdRulesTag",
                                player: PlayerData(preload: false,
                                                   pluginConfig: PluginConfig(config: [IMAPlugin.pluginName : imaAdRulesConfig])),
                                media: OVPMedia(entryId: "1_25q88snr")))

        let imaPrerollAdsResponseConfig = IMAConfig()
        imaPrerollAdsResponseConfig.adsResponse = IMAPrerollAdsResponse
        videos.append(VideoData(title: "1_kvv3j1zk, autoPlay-false, preload-false - IMAPrerollAdsResponse",
                                player: PlayerData(autoPlay: false,
                                                   preload: false,
                                                   pluginConfig: PluginConfig(config: [IMAPlugin.pluginName : imaPrerollAdsResponseConfig])),
                                media: OVPMedia(entryId: "1_kvv3j1zk")))
        
        return videos
    }
    
}
