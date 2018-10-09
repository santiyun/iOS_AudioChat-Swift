//
//  TTTSettingViewController.swift
//  TTTAudioChat
//
//  Created by yanzhen on 2018/9/11.
//  Copyright © 2018年 yanzhen. All rights reserved.
//

import UIKit

class TTTSettingViewController: UIViewController {

    @IBOutlet private weak var audioSwitch: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        audioSwitch.isOn = TTManager.isHighQualityAudio
    }
    
    @IBAction private func saveSettingsAction(_ sender: Any) {
        TTManager.isHighQualityAudio = audioSwitch.isOn
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func back(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}
