//
//  TTTRtcManager.swift
//  TTTAduioChat
//
//  Created by yanzhen on 2018/8/13.
//  Copyright © 2018年 yanzhen. All rights reserved.
//

import UIKit
import TTTRtcEngineVoiceKit

let TTManager = TTTRtcManager.manager

class TTTRtcManager: NSObject {

    public static let manager = TTTRtcManager()
    public var rtcEngine: TTTRtcEngineKit!
    public var roomID: Int64 = 0
    public var isHighQualityAudio = false
    public var me = TTTUser(0)
    private override init() {
        super.init()
        rtcEngine = TTTRtcEngineKit.sharedEngine(withAppId: <#name#>, delegate: nil)
    }
}

