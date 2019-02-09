//
//  noteCell.swift
//  Jot.
//
//  Created by Suchit on 15/07/17.
//  Copyright © 2017 Suchit. All rights reserved.
//

import UIKit

class noteCell: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var tagLbl: UILabel!
    
    func configureCell(item: Note){
        
        titleLbl.text = item.titleName
        tagLbl.text = item.tagName
        
    }
    
    
}
