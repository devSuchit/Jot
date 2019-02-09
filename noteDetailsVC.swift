//
//  noteDetailsVC.swift
//  Jot.
//
//  Created by Suchit on 15/07/17.
//  Copyright © 2017 Suchit. All rights reserved.
//

import UIKit

class noteDetailsVC: UIViewController {
    
    @IBOutlet weak var titleEdit: UITextField!
    @IBOutlet weak var tagEdit: UITextField!
    @IBOutlet weak var noteEdit: UITextView!
    
    
    
    var itemToEdit: Note?
    var temp = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createToolbar(textField: self.noteEdit)
        if itemToEdit != nil{
            loadItemData()
        }
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)

        // Do any additional setup after loading the view.
    }
    
    @IBAction func savePressed(_ sender: Any) {
        view.endEditing(true)
        if itemToEdit == nil && (titleEdit.text != "") && (noteEdit.text != "write here.." || noteEdit.text != ""){
            
            itemToEdit = Note(context: context)
            if var title = titleEdit.text{
                title = title.uppercased()
                itemToEdit?.titleName = title
            }
            
            if var tag = tagEdit.text{
                tag = tag.lowercased()
                itemToEdit?.tagName = tag
            }
            
            if let field = noteEdit.text{
                itemToEdit?.field = field
            }
            ad.saveContext()
            
            dismiss(animated: true)
        }
        else if itemToEdit == nil && (titleEdit.text == "") && (noteEdit.text != "write here.." && noteEdit.text != ""){
            
            itemToEdit = Note(context: context)
            if let title = titleEdit.text{
                if title == "" && itemToEdit?.field != ""
                {
                    itemToEdit?.titleName = noteEdit.text.uppercased()
                }
                else if title == "" && itemToEdit?.field == ""
                {
                    temp = 0
                }
                else
                {
                    itemToEdit?.titleName = title.uppercased()
                }
            }
            
            
            if let tag = tagEdit.text{
                itemToEdit?.tagName = tag.lowercased()
            }
            
            if let field = noteEdit.text{
                itemToEdit?.field = field
            }
            
            
            if temp != 0
            {
                ad.saveContext()
            }
            dismiss(animated: true)
        }
        else if itemToEdit != nil &&  (titleEdit.text == "") && (noteEdit.text == "write here.." || noteEdit.text == ""){
            itemToEdit = nil
            dismiss(animated: true)
        }
        else if itemToEdit != nil && (titleEdit.text != "") && (noteEdit.text != "write here.." || noteEdit.text != ""){
            if var title = titleEdit.text{
                title = title.uppercased()
                itemToEdit?.titleName = title
            }
            
            
            if var tag = tagEdit.text{
                tag = tag.lowercased()
                itemToEdit?.tagName = tag
            }
            
            if let field = noteEdit.text{
                itemToEdit?.field = field
            }
            
            ad.saveContext()
            dismiss(animated: true)
        }
        else
        {
          dismiss(animated: true)
        }
        
        
    }
    
    func loadItemData(){
        
        if let item = itemToEdit {
            titleEdit.text = item.titleName
            tagEdit.text = item.tagName
            noteEdit.text = item.field
        }
    }
    
    func createToolbar(textField : UITextView) {
        let toolbar = UIToolbar()
        toolbar.barStyle = UIBarStyle.default
        toolbar.sizeToFit()
        let save = UIBarButtonItem(title: "Save Note", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.savePressed(_:)))
        
        save.tintColor = UIColor.darkGray
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        doneBtn.tintColor = UIColor.darkGray
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
            noteEdit.contentInset = UIEdgeInsets.zero
        } else {
            noteEdit.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        noteEdit.scrollIndicatorInsets = noteEdit.contentInset
        
        let selectedRange = noteEdit.selectedRange
        noteEdit.scrollRangeToVisible(selectedRange)
    }

}
