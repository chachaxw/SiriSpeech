//
//  ViewController.swift
//  SiriSpeech
//
//  Created by Wei Zhou on 12/12/2016.
//  Copyright © 2016 Wei Zhou. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController, SFSpeechRecognizerDelegate {

    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var microphoneButton: UIButton!

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest? // 用于处理语音识别请求，为语音识别提供音频输入
    private var recognitionTask: SFSpeechRecognitionTask? // 返回识别请求的结果
    private let audioEngine = AVAudioEngine() // 音频引擎
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        microphoneButton.isEnabled = false
        speechRecognizer.delegate = self
        
        SFSpeechRecognizer.requestAuthorization {(authStatus) in
            var isButtonEnabled = false
            
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation {
                self.microphoneButton.isEnabled = isButtonEnabled
            }
        }
        
        
    }
    
    
    @IBAction func microphoneTapped(_ sender: AnyObject) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            textView.text = "You can tap button for saying something"
            microphoneButton.isEnabled = false
            microphoneButton.layer.removeAllAnimations()
            microphoneButton.layer.borderWidth = CGFloat(0)
            microphoneButton.setImage(#imageLiteral(resourceName: "AudioIcon"), for: .normal)
            microphoneButton.layer.backgroundColor = UIColor.init(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.00).cgColor
        } else {
            startRecording()
            animateButton()
            microphoneButton.setImage(#imageLiteral(resourceName: "Loading"), for: .normal)
            microphoneButton.layer.backgroundColor = UIColor.init(red: 1.00, green: 1.00, blue: 1.00, alpha: 0.00).cgColor
            microphoneButton.layer.borderColor = UIColor.init(red: 0.94, green: 0.35, blue: 0.93, alpha: 1.00).cgColor
        }
    }

    func startRecording() {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            var isFinal = false
            
            if result != nil {
                print("录音结果 \(result)")
                self.textView.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.microphoneButton.isEnabled = true
            }
        })
            
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
            
        audioEngine.prepare()
            
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
            
        self.textView.text = "Say something, I'm listening!"
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            microphoneButton.isEnabled = true
        } else {
            microphoneButton.isEnabled = false
        }
    }
    
    func animateButton() {
        let rotate = CABasicAnimation(keyPath: "transform.rotation")
        rotate.toValue = 2 * M_PI
        rotate.repeatCount = MAXFLOAT
        rotate.duration = 1
        rotate.isRemovedOnCompletion = false
        microphoneButton.layer.add(rotate, forKey: nil)
    }
    
    func showLoveAnimation() {
        
    }

}

