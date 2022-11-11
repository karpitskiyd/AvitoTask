//
//  AvitoGuysTableViewCell.swift
//  AvitoTask
//
//  Created by Даниил Карпитский on 11/8/22.
//

import UIKit

class AvitoGuysTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var skillsLabel: UILabel!

    var cellModel: Employee?
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func setupCell(model: Employee){
        nameLabel.text = model.name
        phoneNumberLabel.text = model.phoneNumber
        skillsLabel.text = model.skills.joined(separator: "\n")
        
    }

   
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
