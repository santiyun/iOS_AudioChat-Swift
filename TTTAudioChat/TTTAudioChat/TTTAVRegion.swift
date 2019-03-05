//
//  TTTAVRegion.swift
//  TTTAduioChat
//
//  Created by yanzhen on 2018/8/13.
//  Copyright © 2018年 yanzhen. All rights reserved.
//

import UIKit

class TTTAVRegion: UIView {
    
    public var user: TTTUser?
    @IBOutlet private var backgroundView: UIView!
    @IBOutlet private weak var idLabel: UILabel!
    @IBOutlet private weak var audioStatsLabel: UILabel!
    @IBOutlet private weak var voiceBtn: UIButton!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibView()
    }
    
    private func loadNibView() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "TTTAVRegion", bundle: bundle)
        backgroundView = nib.instantiate(withOwner: self, options: nil)[0] as? UIView
        backgroundView.frame = bounds
        backgroundView.backgroundColor = UIColor.clear
        addSubview(backgroundView)
    }
    
    private func getVoiceImage(_ audioLevel: UInt) -> UIImage {
        var image: UIImage = #imageLiteral(resourceName: "voice_small")
        if audioLevel < 4 {
            image = #imageLiteral(resourceName: "voice_small")
        } else if audioLevel < 7 {
            image = #imageLiteral(resourceName: "voice_middle")
        } else {
            image = #imageLiteral(resourceName: "voice_big")
        }
        return image
    }
}

extension TTTAVRegion {
    public func configureRegion(_ user: TTTUser) {
        self.user = user
        voiceBtn.setImage(#imageLiteral(resourceName: "voice_small"), for: .normal)
        idLabel.isHidden = false
        audioStatsLabel.isHidden = false
        voiceBtn.isHidden = false
        idLabel.text = user.uid.description
        if user.mutedSelf {
            mutedSelf(true)
        }
    }
    
    public func closeRegion() {
        idLabel.isHidden = true
        audioStatsLabel.isHidden = true
        voiceBtn.isHidden = true
        user = nil
    }
    
    public func reportAudioLevel(_ audioLevel: UInt) {
        if user!.mutedSelf { return }
        voiceBtn.setImage(getVoiceImage(audioLevel), for: .normal)
    }
    
    public func setRemoterAudioStats(_ stats: UInt) {
        audioStatsLabel.text = "A-↓\(stats)kbps"
    }
    
    public func mutedSelf(_ mute: Bool) {
        voiceBtn.setImage(mute ? #imageLiteral(resourceName: "speaking_closed") : #imageLiteral(resourceName: "voice_small"), for: .normal)
    }
}
