//
//  ProfileViewController.swift
//  SwiftyCompanion
//
//  Created by Muamba-nzambi, Moses on 2019/12/20.
//  Copyright © 2019 MuaMoses. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Locksmith

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var backgroundViewImage: UIImageView!
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var login: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var wallet: UILabel!
    @IBOutlet weak var correctionPoints: UILabel!
    @IBOutlet weak var grade: UILabel!
    @IBOutlet weak var availability: UILabel!
    @IBOutlet weak var level: UILabel!
    @IBOutlet weak var levelProgressBar: UIProgressView!
    
    @IBOutlet weak var skillsTable: UITableView!
    @IBOutlet weak var projectsTable: UITableView!
    
    var json: JSON!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        avatar.layer.borderWidth = 2
        avatar.layer.masksToBounds = true
        avatar.layer.borderColor = UIColor.white.cgColor
        avatar.layer.cornerRadius = avatar.frame.width / 2
        
        levelProgressBar.transform = levelProgressBar.transform.scaledBy(x: 1, y: 3)
        levelProgressBar.layer.cornerRadius = levelProgressBar.frame.height / 2
        levelProgressBar.clipsToBounds = true
        levelProgressBar.layer.sublayers![1].cornerRadius = levelProgressBar.frame.height / 2
        levelProgressBar.subviews[1].clipsToBounds = true
        
        skillsTable.layer.cornerRadius = 5
        projectsTable.layer.cornerRadius = 5
                
        setProfile()
        setPhoto()
        
    }
    
    func setProfile() {
        
        if let name = json["displayname"].string {
            self.name.text = name
        }
        if let login = json["login"].string {
            self.login.text = "(\(login))"
        }
        if let email = json["email"].string {
            self.email.text = email
        }
        if let wallet = json["wallet"].int {
            self.wallet.text = "Wallet: \(wallet)"
        }
        if let correctionPoints = json["correction_point"].int {
            self.correctionPoints.text = "Corrections: \(correctionPoints)"
        }
        if let grade = json["cursus_users"][1]["grade"].string {
            self.grade.text = "Grade: \(grade)"
        }
        
        if let availability = json["location"].string {
            self.availability.text = "Available\n\(availability)"
        } else {
            self.availability.text = "Unavailable\n-"
        }
        
        if let level = json["cursus_users"][0]["level"].float {
            let progress = modf(level).1
            levelProgressBar.progress = progress
            self.level.text = "Level: \(Int(level)) - \(Int(progress * 100))%"
        }
    }
    
    func setPhoto() {
        guard let urlString = json["image_url"].string else { return }
        guard let url = URL(string: urlString) else { return }
        
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    self.avatar.image = UIImage(data: data)
                }
            }
        }
        
    }
    
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch tableView {
        case skillsTable:
            return json["cursus_users"][1]["skills"].count
        case projectsTable:
            print("Projects: \(json["projects_users"])")
            return json["projects_users"].count
        default:
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == skillsTable, let cell = tableView.dequeueReusableCell(withIdentifier: "skillsCell", for: indexPath) as? SkillsTableViewCell {
            
            let skillName = json["cursus_users"][0]["skills"][indexPath.row]["name"].string
            let skillLevel = json["cursus_users"][0]["skills"][indexPath.row]["level"].float
            
            if skillName != nil && skillLevel != nil {
                cell.skillLabel.text = skillName! + " - level: " + String(skillLevel!)
            }
            
            return cell
        } else if tableView == projectsTable, let cell = tableView.dequeueReusableCell(withIdentifier: "projectsCell", for: indexPath) as? ProjectsTableViewCell {
            
            let name = json["projects_users"][indexPath.row]["project"]["slug"].string
            let mark = json["projects_users"][indexPath.row]["final_mark"].float
            let validated = json["projects_users"][indexPath.row]["validated?"].bool
            
            switch validated {
            case true:
                cell.statusImage.image = #imageLiteral(resourceName: "success")
            case false:
                cell.statusImage.image = #imageLiteral(resourceName: "fail")
            default:
                cell.statusImage.image = #imageLiteral(resourceName: "in_progress")
            }
            
            if name != nil && mark != nil {
                cell.projectLabel.text = name! + " - " + String(mark!).capitalized + "%"
            } else if name != nil {
                cell.projectLabel.text = name! + " - in progress"
            }
            
            return cell
        }
        return UITableViewCell()
    }
    
}
