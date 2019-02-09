//
//  CalculatorVC.swift
//  Jot.
//
//  Created by Suchit on 05/07/17.
//  Copyright © 2017 Suchit. All rights reserved.
//

import UIKit

class CalculatorVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var operationLbl: UILabel!
    
    @IBOutlet weak var resultLbl: UILabel!
    
    
    enum Operation: String
    {
        case Divide = "/"
        case Multiply = "*"
        case Subtract = "-"
        case Add = "+"
        case Reminder = "%"
        case Power = "^"
        case Empty = "Empty"
    }
    
    var currentOperation = Operation.Empty
    var runningNumber = ""
    var leftHand = ""
    var rightHand = ""
    var result = ""
    var operationLblHolder = ""
    
    
    @IBAction func numberPressed(sender: UIButton)
    {
        runningNumber += "\(sender.tag)"
        operationLblHolder += "\(sender.tag)"
        operationLbl.text = ""
        operationLbl.text = operationLblHolder
    }
    
    
    @IBAction func dotPressed(sender: UIButton)
    {
        runningNumber += "."
        operationLblHolder += "."
        operationLbl.text = ""
        operationLbl.text = operationLblHolder
    }
    
   
    
    @IBAction func clearPressed(sender: UIButton)
    {
        currentOperation = Operation.Empty
        runningNumber = ""
        leftHand = ""
        rightHand = ""
        result = ""
        operationLblHolder = ""
        operationLbl.text = "0"
        resultLbl.text = "0"
    }
    
    @IBAction func onDividePressed(sender: UIButton)
    {
        operationLblHolder += "/"
        operationLbl.text = operationLblHolder
        
        processOperation(operation: .Divide)
    }
    
    @IBAction func onMultiplyPressed(sender: UIButton)
    {
        operationLblHolder += "x"
        operationLbl.text = operationLblHolder
        
        processOperation(operation: .Multiply)
    }
    
    @IBAction func onAddPressed(sender: UIButton)
    {
        operationLblHolder += "+"
        operationLbl.text = operationLblHolder
        
        processOperation(operation: .Add)
    }
    
    
    @IBAction func onSubtractPressed(sender: UIButton)
    {
        operationLblHolder += "-"
        operationLbl.text = operationLblHolder
        
        processOperation(operation: .Subtract)
    }
    
    
    @IBAction func onReminderPressed(sender: UIButton)
    {
        operationLblHolder += "%"
        operationLbl.text = operationLblHolder
        
        processOperation(operation: .Reminder)
    }
    
    @IBAction func onPowerPressed(sender: UIButton)
    {
        operationLblHolder += "^"
        operationLbl.text = operationLblHolder
        
        processOperation(operation: .Power)
    }
    
    @IBAction func equalsPressed(sender: UIButton)
    {
        processOperation(operation: currentOperation)
    }
    
    func processOperation(operation: Operation)
    {
        if currentOperation != Operation.Empty
        {
            if runningNumber != ""
            {
                rightHand = runningNumber
                runningNumber = ""
                
                if currentOperation == Operation.Divide
                {
                    result = "\((Double)(leftHand)! / (Double)(rightHand)!)"
                }
                else if currentOperation == Operation.Multiply
                {
                    result = "\((Double)(leftHand)! * (Double)(rightHand)!)"
                }
                else if currentOperation == Operation.Subtract
                {
                    result = "\((Double)(leftHand)! - (Double)(rightHand)!)"
                }
                else if currentOperation == Operation.Add
                {
                    result = "\((Double)(leftHand)! + (Double)(rightHand)!)"
                }
                else if currentOperation == Operation.Reminder
                {
                    result = "\((Double)(leftHand)!.truncatingRemainder(dividingBy: (Double)(rightHand)!))"
                }
                else if currentOperation == Operation.Power
                {
                    result = "\(pow((Double)(leftHand)! , (Double)(rightHand)!))"
                }
                leftHand = result
                resultLbl.text = result
                
            }
            currentOperation = operation
            
        }
        else
        {
            leftHand = runningNumber
            runningNumber = ""
            currentOperation = operation
        }
    }

    
    @IBAction func BackBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
