//
//  repositoryCell.swift
//  iOSMobileGithubTest
//
//  Created by Dennis Mostajo on 7/9/18.
//  Copyright © 2018 Dennis Mostajo. All rights reserved.
//

import UIKit

class repositoryCell: UITableViewCell {

    @IBOutlet var repoNameLbl: UILabel!
    @IBOutlet var repoDescriptionLbl: UILabel!
    @IBOutlet var cantRepoIssuesLbl: UILabel!
    @IBOutlet var cantRepoIssuesOpenLbl: UILabel!
    @IBOutlet var cantRepoForksLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
