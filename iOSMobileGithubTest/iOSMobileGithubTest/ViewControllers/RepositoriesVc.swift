//
//  RepositoriesVc.swift
//  iOSMobileGithubTest
//
//  Created by Dennis Mostajo on 7/9/18.
//  Copyright © 2018 Dennis Mostajo. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON
import DateToolsSwift
import JWTDecode
import Toast_Swift

class RepositoriesVc: UIViewController,UITableViewDelegate, UITableViewDataSource, repositoryCellDelegate
{
    let backButton = UIButton(type:.custom)
    let imgView = UIImageView(frame: CGRect(x: 35, y: 6, width: 33, height: 33))
    let titleLabel = UILabel(frame:CGRect(x:70, y:12, width:180, height:21))
    var userId = 0
    @IBOutlet var userImgAvatar: UIImageView!
    @IBOutlet var userNameLbl: UILabel!
    @IBOutlet var table: UITableView!
    
    var repositoriesFromDataBase:Results<Repository>? = nil
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.table.separatorColor = UIColor.white
        self.setupChildCustomNavigationBar()
        self.loadRepositoriesUserFromGitHub()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.showNavBarItems()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideNavBarItems()
    }

    // MARK: - Methods
    
    func setupChildCustomNavigationBar()
    {
        self.navigationItem.setHidesBackButton(true, animated:true)
        let imgBackground = UIImage(named:"background")
        self.navigationController?.navigationBar.setBackgroundImage(imgBackground?.resizableImage(withCapInsets: UIEdgeInsetsMake(0, 0, 0, 0), resizingMode: .stretch), for: .default)
        self.backButton.frame = CGRect(x: 0, y: 5, width: 35, height: 35)
        self.backButton.setImage(UIImage(named: "backNavBtn"), for: .normal)
        self.backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        let imgIcon = UIImage(named:"githubLogo")
        self.imgView.contentMode = .scaleAspectFit
        self.imgView.image = imgIcon
        self.titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        self.titleLabel.textColor = UIColor.white
        self.titleLabel.text = "iOSMobileGithubTest"
        self.navigationController?.navigationBar.addSubview(imgView)
        self.navigationController?.navigationBar.addSubview(titleLabel)
        self.navigationController?.navigationBar.addSubview(backButton)
    }
    
    @objc func backAction()
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    func showNavBarItems()
    {
        self.backButton.isHidden = false
        self.imgView.isHidden = false
        self.titleLabel.isHidden = false
    }
    
    func hideNavBarItems()
    {
        self.backButton.isHidden = true
        self.imgView.isHidden = true
        self.titleLabel.isHidden = true
    }
    
    // MARK: - Requests
    
    func loadRepositoriesUserFromGitHub()
    {
        if !(self.userId == 0)
        {
            if let user = DataBaseHelper.getUserById(user_id: self.userId)
            {
                self.userImgAvatar.load(url: Foundation.URL(string: user.avatar_url)!)
                self.userNameLbl.text = user.login
                self.view.makeToastActivity(.center)
                _ = NetworkManager.manager.startRequest(GitHubAPI.getRepositoriesFromUser(userName: user.login), success:
                    {
                        responseRequest,responseData in
                        debugPrint("getRepositoriesFromUser StatusCode:\(String(describing: responseRequest?.statusCode))")
                        let json = try! JSON(data: responseData! as! Data)
//                        debugPrint("getRepositoriesFromUser response:\(json)")
                        if responseRequest?.statusCode == 200
                        {
                            if json.arrayValue.count == 0
                            {
                                self.view.makeToast(NSLocalizedString("MESSAGE_SEARCH_NOT_FOUND", comment: "not found message"))
                            }
                            else
                            {
                                for repositoryJson in json.arrayValue
                                {
                                    let repository = Repository.fromJson(repositoryJson)
                                    DataBaseHelper.createOrUpdateRepository(repository)
                                }
                                self.repositoriesFromDataBase = DataBaseHelper.getRepositoriesByUserId(user_id: user.id)
                                self.table.reloadData()
                            }
                            let headers = responseRequest?.allHeaderFields as? [String:String]
//                            debugPrint("headers:\(String(describing: headers))")
                            if let link = headers!["Link"]
                            {
                                debugPrint("Link Pagination Repos:\(link)")
                            }
                        }
                        self.view.hideToastActivity()
                },
                                                        failure:
                    {
                        _, _, error in
                        debugPrint("error:\(error)")
                        self.view.hideToastActivity()
                })
            }
        }
    }
    
    // MARK: - UITableView
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        var height:CGFloat = 0
        if tableView == self.table
        {
            height = 25
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        var height:CGFloat = 0
        if tableView == self.table
        {
            height = 200
        }
        return height
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var sections:Int = 0
        if tableView == self.table
        {
            sections = 1
        }
        return sections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        var rows:Int = 0
        if tableView == self.table
        {
            switch section
            {
            case 0:
                if let repositories = self.repositoriesFromDataBase
                {
                    rows = repositories.count
                }
                break
            default:
                break
            }
        }
        return rows
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 25))
        headerView.backgroundColor = UIColor.white
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: view.frame.size.width, height: 25))
        label.textColor = UIColor.init(hex: 0x37464C)
        label.font = UIFont.boldSystemFont(ofSize: 17)
        headerView.addSubview(label)
        if (section == 0) {
            label.text = NSLocalizedString("REPOSITORIES_TITLE", comment: "repos Title")
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = self.table.dequeueReusableCell(withIdentifier: "repositoryCell") as! repositoryCell
        if tableView == self.table
        {
            
            switch indexPath.section
            {
            case 0:
                let repository = self.repositoriesFromDataBase![indexPath.row]
                cell.cellDelegate = self
                cell.repositoryId = repository.id
                cell.repoNameLbl.text = "Repo:  \(repository.name)"
                cell.repoDescriptionLbl.text = "Description: \(repository.description_repo)"
                cell.repoLinkBtn.setAttributedTitle(NSAttributedString(string: repository.repo_html_url, attributes: cell.attributesForRepoLink), for: .normal)
                cell.cantRepoIssuesOpenLbl.text = "\(repository.open_issues_count)"
                cell.cantRepoForksLbl.text = "\(repository.forks_count)"
                break
            default:
                break
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if tableView == self.table
        {
            
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - RepositoryCellDelegate
    func didPressRepositoryLink(_ repositoryId: Int)
    {
        if let repository = DataBaseHelper.getRepositoryById(repository_id: repositoryId)
        {
            if let url = URL(string: repository.repo_html_url) {
                UIApplication.shared.open(url, options: [:])
            }
        }
    }
}
