//
//  ViewController.swift
//  Jot.
//
//  Created by Suchit on 30/06/17.
//  Copyright © 2017 Suchit. All rights reserved.
//

import UIKit
import Speech

class MainVC: UIViewController {


    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var mic: UIButton!
    
    @IBAction func crossPressed(_ sender: Any) {
        self.viewTop.constant = 18
        self.textViewTop.constant = 25
        pdfBtn.isHidden = true
        penBtn.isHidden = true
        settingBtn.isHidden = true
        pdfLbl.isHidden = true
        notesLbl.isHidden = true
        settingsLbl.isHidden = true
        dotBtn.isHidden = false
        crossBtn.isHidden = true
    }
    
    @IBOutlet weak var crossBtn: UIButton!
    @IBOutlet weak var textViewTop: NSLayoutConstraint!
    @IBOutlet weak var viewTop: NSLayoutConstraint!
    @IBOutlet weak var pdfBtn: UIButton!
    @IBOutlet weak var penBtn: UIButton!
    @IBOutlet weak var pdfLbl: UILabel!
    @IBOutlet weak var notesLbl: UILabel!
    @IBOutlet weak var settingsLbl: UILabel!
    @IBOutlet weak var settingBtn: UIButton!
    @IBOutlet weak var dotBtn: UIButton!
    
    @IBAction func navPressed(_ sender: Any) {
        self.viewTop.constant = 88
        self.textViewTop.constant = 95
        pdfBtn.isHidden = false
        penBtn.isHidden = false
        settingBtn.isHidden = false
        pdfLbl.isHidden = false
        notesLbl.isHidden = false
        settingsLbl.isHidden = false
        dotBtn.isHidden = true
        crossBtn.isHidden = false
        
        
    }

    
    @IBOutlet weak var noticeLbl: UILabel!
    @IBOutlet weak var micGr: UIButton!
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    

    @IBAction func micPressed(_ sender: Any) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            micGr.isHidden = true
            mic.isHidden = false
            if textView.text == "..."
            {
                textView.text = "write here.."
            }
            noticeLbl.text = "TAP MIC TO USE VOICE"
        } else {
            micGr.isHidden = false
            mic.isHidden = true
            noticeLbl.text = "TAP MIC TO STOP VOICE RECOGNITION"
            startRecording()
        }
    }
    
    func startRecording()
    {
        
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
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                
                self.textView.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.mic.isEnabled = true
            }
        }
        )
        
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
        
        textView.text = "..."
        
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            mic.isEnabled = true
        } else {
            mic.isEnabled = false
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.createToolbar(textField: self.textView)
        speechRecognizer?.delegate = self as? SFSpeechRecognizerDelegate
        SFSpeechRecognizer.requestAuthorization{ (authStatus) in
            var isButtonEnabled = false
            
            switch authStatus{
            case .authorized:
                isButtonEnabled = true
            case .denied:
                isButtonEnabled = false
                print("User Denied Access To Speech Recognition")
            case .restricted:
                isButtonEnabled = false
                print("Speech Recognition Restricted On This Device")
            case .notDetermined:
                isButtonEnabled = false
                print("Speech Recognition Not Yet Authorized")
            }
            
            let notificationCenter = NotificationCenter.default
            notificationCenter.addObserver(self, selector: #selector(self.adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
            notificationCenter.addObserver(self, selector: #selector(self.adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        }

        
    }
    @IBAction func savePressed(_ sender: Any) {
        if (textView.text != "" && textView.text != "write here.." && textView.text != nil)
        {
        var item: Note!
        
        item = Note(context: context)
       
        item.titleName = textView.text.uppercased()
        item.tagName = ""
        item.field = textView.text
      
        ad.saveContext()
        }
        view.endEditing(true)
        
    }
    

    
    func createToolbar(textField : UITextView) {
        let toolbar = UIToolbar()
        toolbar.barStyle = UIBarStyle.default
        toolbar.sizeToFit()
        let save = UIBarButtonItem(title: "Save Note", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.savePressed(_:)))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        doneBtn.tintColor = UIColor.darkGray
        save.tintColor = UIColor.darkGray
        toolbar.items = [save,flexSpace,doneBtn]
        textField.inputAccessoryView = toolbar
    }
    
    func doneButtonAction() {
        self.view.endEditing(true)
    }
    
    func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide {
            textView.contentInset = UIEdgeInsets.zero
        } else {
            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        textView.scrollIndicatorInsets = textView.contentInset
        
        let selectedRange = textView.selectedRange
        textView.scrollRangeToVisible(selectedRange)
    }
}






