//
//  SearchView.swift
//  SwiftyCompanion
//
//  Created by Muamba-nzambi, Moses on 2019/12/18.
//  Copyright © 2019 MuaMoses. All rights reserved.
//

import UIKit

class SkillsTableViewCell: UITableViewCell {

    @IBOutlet weak var skillLabel: UILabel!

}

class ProjectsTableViewCell: UITableViewCell {
    @IBOutlet weak var projectLabel: UILabel!
    @IBOutlet weak var statusImage: UIImageView!
    
}

class SearchUIButton: UIButton {

    override open var isEnabled: Bool {
        didSet {
            backgroundColor = isEnabled ? #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1) : #colorLiteral(red: 0.8038417697, green: 0.8039775491, blue: 0.8038237691, alpha: 1)
        }
    }

}
