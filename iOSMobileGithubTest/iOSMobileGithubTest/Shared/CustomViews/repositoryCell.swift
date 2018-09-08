//
//  repositoryCell.swift
//  iOSMobileGithubTest
//
//  Created by Dennis Mostajo on 7/9/18.
//  Copyright © 2018 Dennis Mostajo. All rights reserved.
//

import UIKit

protocol repositoryCellDelegate : class {
    func didPressRepositoryLink(_ repositoryId: Int)
}

class repositoryCell: UITableViewCell {

    @IBOutlet var repoNameLbl: UILabel!
    @IBOutlet var repoDescriptionLbl: UILabel!
    @IBOutlet var repoLinkBtn: UIButton!
    @IBOutlet var cantRepoIssuesOpenLbl: UILabel!
    @IBOutlet var cantRepoForksLbl: UILabel!
    
    var cellDelegate:repositoryCellDelegate?
    var repositoryId = 0
    
    let attributesForRepoLink : [NSAttributedStringKey : Any] = [
        NSAttributedStringKey.font : UIFont.systemFont(ofSize: 12.0),
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

    @IBAction func buttonPressedRepo() {
        cellDelegate?.didPressRepositoryLink(repositoryId)
    }
}
