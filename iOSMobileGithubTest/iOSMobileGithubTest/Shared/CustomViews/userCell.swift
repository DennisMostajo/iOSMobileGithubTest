//
//  userCell.swift
//  iOSMobileGithubTest
//
//  Created by Dennis Mostajo on 7/9/18.
//  Copyright © 2018 Dennis Mostajo. All rights reserved.
//

import UIKit

protocol userCellDelegate : class {
    func didPressProfile(_ userId: Int)
    func didPressRepositories(_ userId: Int)
}

class userCell: UITableViewCell {
    
    @IBOutlet var userImgAvatar: UIImageView!
    @IBOutlet var userNameLbl: UILabel!
    @IBOutlet var linkProfile: UIButton!
    @IBOutlet var linkRepositories: UIButton!
    
    var cellDelegate:userCellDelegate?
    var userId = 0
    
    let attributesForProfile : [NSAttributedStringKey : Any] = [
        NSAttributedStringKey.font : UIFont.systemFont(ofSize: 12.0),
        NSAttributedStringKey.foregroundColor : UIColor.white,
        NSAttributedStringKey.underlineStyle : NSUnderlineStyle.styleSingle.rawValue
    ]
    
    let attributesForRepo : [NSAttributedStringKey : Any] = [
        NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15.0),
        NSAttributedStringKey.foregroundColor : UIColor.white,
        NSAttributedStringKey.underlineStyle : NSUnderlineStyle.styleSingle.rawValue
    ]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func buttonPressedProfile() {
        cellDelegate?.didPressProfile(userId)
    }
    @IBAction func buttonPressedRepositories() {
        cellDelegate?.didPressRepositories(userId)
    }
}
