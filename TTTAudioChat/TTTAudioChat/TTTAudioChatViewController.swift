//
//  TTTAudioChatViewController.swift
//  TTTAudioChat
//
//  Created by yanzhen on 2018/8/13.
//  Copyright © 2018年 yanzhen. All rights reserved.
//

import UIKit
import TTTRtcEngineVoiceKit

class TTTAudioChatViewController: UIViewController {

    private var routing = TTTRtcAudioOutputRouting.audioOutput_Speaker
    private var avRegions = [TTTAVRegion]()
    private var users = [TTTUser]()
    @IBOutlet private weak var roomIDLabel: UILabel!
    @IBOutlet private weak var idLabel: UILabel!
    @IBOutlet private weak var audioStatsLabel: UILabel!
    @IBOutlet private weak var voiceBtn: UIButton!
    @IBOutlet private weak var speakerBtn: UIButton!
    @IBOutlet private weak var avRegionsView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        roomIDLabel.text = "房号: \(TTManager.roomID)"
        idLabel.text = "ID: \(TTManager.me.uid)"
        avRegions += avRegionsView.subviews.filter { $0 is TTTAVRegion } as! [TTTAVRegion]
        TTManager.rtcEngine.delegate = self
        //加入房间会回调音频路由，默认是扬声器，这里不可能是听筒
        if !TTManager.rtcEngine.isSpeakerphoneEnabled() {
            routing = .audioOutput_Headset
            speakerBtn.isEnabled = false
        }
    }

    @IBAction private func muteVocieAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        TTManager.me.mutedSelf = sender.isSelected
        TTManager.rtcEngine.muteLocalAudioStream(sender.isSelected)
    }
    
    @IBAction private func speakerAction(_ sender: UIButton) {
        TTManager.rtcEngine.setEnableSpeakerphone(sender.isSelected)
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction private func exitChannel(_ sender: UIButton) {
        let alert = UIAlertController(title: "提示", message: "你确定要退出房间吗？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        let sureAction = UIAlertAction(title: "确定", style: .default) { (action) in
            TTManager.rtcEngine.leaveChannel(nil)
        }
        alert.addAction(sureAction)
        present(alert, animated: true, completion: nil)
    }
}

extension TTTAudioChatViewController: TTTRtcEngineDelegate {
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, didJoinedOfUid uid: Int64, clientRole: TTTRtcClientRole, isVideoEnabled: Bool, elapsed: Int) {
        let user = TTTUser(uid)
        users.append(user)
        getAvaiableAVRegion()?.configureRegion(user)
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, didOfflineOfUid uid: Int64, reason: TTTRtcUserOfflineReason) {
        guard let userInfo = getUser(uid) else { return }
        getAVRegion(uid)?.closeRegion()
        users.remove(at: userInfo.1)
        
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, reportAudioLevel userID: Int64, audioLevel: UInt, audioLevelFullRange: UInt) {
        if userID == TTManager.me.uid {
            voiceBtn.setImage(getVoiceImage(audioLevel), for: .normal)
        } else {
            getAVRegion(userID)?.reportAudioLevel(audioLevel)
        }
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, didAudioMuted muted: Bool, byUid uid: Int64) {
        guard let user = getUser(uid)?.0 else { return }
        user.mutedSelf = muted
        getAVRegion(uid)?.mutedSelf(muted)
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, localAudioStats stats: TTTRtcLocalAudioStats!) {
        audioStatsLabel.text = "A-↑\(stats.sentBitrate)kbps"
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, remoteAudioStats stats: TTTRtcRemoteAudioStats!) {
        getAVRegion(stats.uid)?.setRemoterAudioStats(stats.receivedBitrate)
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, didLeaveChannelWith stats: TTTRtcStats!) {
        dismiss(animated: true, completion: nil)
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, didAudioRouteChanged routing: TTTRtcAudioOutputRouting) {
        self.routing = routing
        if routing == .audioOutput_Headset {
            //耳机时不能做扬声器，听筒切换，拔下耳机还是扬声器播放
            speakerBtn.isEnabled = false
            speakerBtn.isSelected = false
        } else {
            speakerBtn.isEnabled = true
        }
    }
    
    func rtcEngineConnectionDidLost(_ engine: TTTRtcEngineKit!) {
        view.window?.showToast("ConnectionDidLost")
        engine.leaveChannel(nil)
        dismiss(animated: true, completion: nil)
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, didKickedOutOfUid uid: Int64, reason: TTTRtcKickedOutReason) {
        var errorInfo = ""
        switch reason {
        case .kickedOut_KickedByHost:
            errorInfo = "被主播踢出"
        case .kickedOut_PushRtmpFailed:
            errorInfo = "rtmp推流失败"
        case .kickedOut_MasterExit:
            errorInfo = "主播已退出"
        case .kickedOut_ReLogin:
            errorInfo = "重复登录"
        case .kickedOut_NoAudioData:
            errorInfo = "长时间没有上行音频数据"
        case .kickedOut_NoVideoData:
            errorInfo = "长时间没有上行视频数据"
        case .kickedOut_NewChairEnter:
            errorInfo = "其他人以主播身份进入"
        case .kickedOut_ChannelKeyExpired:
            errorInfo = "Channel Key失效"
        default:
            errorInfo = "未知错误"
        }
        view.window?.showToast(errorInfo)
    }
}

private extension TTTAudioChatViewController {
    func getAvaiableAVRegion() -> TTTAVRegion? {
        return avRegions.first { $0.user == nil }
    }
    
    func getAVRegion(_ uid: Int64) -> TTTAVRegion? {
        return avRegions.first { $0.user?.uid == uid }
    }
    
    func getUser(_ uid: Int64) -> (TTTUser, Int)? {
        if let index = users.index(where: { $0.uid == uid } ) {
            return (users[index], index)
        }
        return nil
    }
    
    func getVoiceImage(_ audioLevel: UInt) -> UIImage {
        let speakerphone = routing != .audioOutput_Headset
        if TTManager.me.mutedSelf {
            return speakerphone ? #imageLiteral(resourceName: "voice_close") : #imageLiteral(resourceName: "tingtong_close")
        }
        var image: UIImage = #imageLiteral(resourceName: "voice_small")
        if audioLevel < 4 {
            image = speakerphone ? #imageLiteral(resourceName: "voice_small") : #imageLiteral(resourceName: "tingtong_small")
        } else if audioLevel < 7 {
            image = speakerphone ? #imageLiteral(resourceName: "voice_middle") : #imageLiteral(resourceName: "tingtong_middle")
        } else {
            image = speakerphone ? #imageLiteral(resourceName: "voice_big") : #imageLiteral(resourceName: "tingtong_big")
        }
        return image
    }
}
