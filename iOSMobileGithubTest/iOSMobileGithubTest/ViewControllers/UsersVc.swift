//
//  UsersVc.swift
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

class UsersVc: UIViewController,UITableViewDelegate, UITableViewDataSource,userCellDelegate {

    let imgView = UIImageView(frame: CGRect(x: 8, y: 6, width: 33, height: 33))
    let titleLabel = UILabel(frame:CGRect(x:45, y:12, width:180, height:21))
    
    @IBOutlet var table: UITableView!
    @IBOutlet var nextBtn: UIButton!
    
    var reachability: Reachability!
    fileprivate var offlineToast: UIView!
    var isToastShowing: Bool {
        get {
            return !((self.offlineToast?.isHidden) ?? true)
        }
    }
    
    var usersFromDataBase:Results<User>? = nil
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.table.separatorColor = UIColor.white
        self.setupCustomNavigationBar()
        self.checkConnections()
        self.checkNextButtonEnable()
        self.loadUsersFromGitHub()
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
    
    func setupCustomNavigationBar()
    {
        let imgBackground = UIImage(named:"background")
        self.navigationController?.navigationBar.setBackgroundImage(imgBackground?.resizableImage(withCapInsets: UIEdgeInsetsMake(0, 0, 0, 0), resizingMode: .stretch), for: .default)
        let imgIcon = UIImage(named:"githubLogo")
        self.imgView.contentMode = .scaleAspectFit
        self.imgView.image = imgIcon
        self.titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        self.titleLabel.textColor = UIColor.white
        self.titleLabel.text = "iOSMobileGithubTest"
        self.navigationController?.navigationBar.addSubview(imgView)
        self.navigationController?.navigationBar.addSubview(titleLabel)
    }
    
    func showNavBarItems()
    {
        self.imgView.isHidden = false
        self.titleLabel.isHidden = false
    }
    
    func hideNavBarItems()
    {
        self.imgView.isHidden = true
        self.titleLabel.isHidden = true
    }
    
    func redirectLogToDocuments() -> String {
        
        let allPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = allPaths.first!
        let pathForLog: String = documentsDirectory + "/logs.txt"
        
        return pathForLog
    }
    
    func checkConnections()
    {
        do {
            reachability = Reachability()
            offlineToast = try self.view.toastViewForMessage(NSLocalizedString("NO_CONNECTION", comment: "You have no connection"), title: "", image: UIImage(named: "quoteSlapperHandIcon"), style: ToastStyle())
        } catch {
            debugPrint("Unable to create Reachability")
        }
        
        guard let _ = reachability, let _ = offlineToast else {
            return
        }
        
        reachability.whenReachable = { [weak self] reachability in
            DispatchQueue.main.async {
                self?.offlineToast.isHidden = true
            }
        }
        
        reachability.whenUnreachable = { [weak self] reachability in
            DispatchQueue.main.async {
                self?.showConnectiontoast()
                self?.offlineToast.isHidden = false
            }
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    func showConnectiontoast(){
        self.view.showToast(self.offlineToast, duration: TimeInterval.infinity, position: .center) { _ in
            self.showConnectiontoast()
        }
    }
    
    func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
    
    func checkNextButtonEnable()
    {
        if (StorageHelper.getNext_url_pagination() == "" || StorageHelper.getNext_url_pagination() == nil)
        {
            self.nextBtn.isEnabled = false
            self.nextBtn.setTitleColor(UIColor.init(hex:0x526975 ), for: .normal)
        }
        else
        {
            self.nextBtn.isEnabled = true
            self.nextBtn.setTitleColor(UIColor.white, for: .normal)
        }
    }
    
    // MARK: - Requests
    
    func loadUsersFromGitHub()
    {
        self.view.makeToastActivity(.center)
        _ = NetworkManager.manager.startRequest(GitHubAPI.getAllUsers, success:
            {
                responseRequest,responseData in
                debugPrint("getAllUsers StatusCode:\(String(describing: responseRequest?.statusCode))")
                let json = try! JSON(data: responseData! as! Data)
//                debugPrint("getAllUsers response:\(json)")
                if responseRequest?.statusCode == 200
                {
                    DataBaseHelper.clearDatabase()
                    self.usersFromDataBase = nil
                    if json.arrayValue.count == 0
                    {
                        self.view.makeToast(NSLocalizedString("MESSAGE_SEARCH_NOT_FOUND", comment: "not found message"))
                    }
                    else
                    {
                        for userJson in json.arrayValue
                        {
                            let user = User.fromJson(userJson)
                            DataBaseHelper.createOrUpdateUser(user)
                        }
                        self.usersFromDataBase = DataBaseHelper.getUsers()
                        self.table.reloadData()
                    }
                    let headers = responseRequest?.allHeaderFields as? [String:String]
//                    debugPrint("headers:\(String(describing: headers))")
                    if let link = headers!["Link"]
                    {
                        debugPrint("Link Pagination Users:\(link)")
                        let links = link.components(separatedBy: ",")
                        var dictionary: [String: String] = [:]
                        links.forEach({
                            let components = $0.components(separatedBy: "; ")
                            let cleanPath = components[0].trimmingCharacters(in: CharacterSet(charactersIn: "<>"))
                            dictionary[components[1]] = cleanPath
                        })
                        if let nextPagePath = dictionary["rel=\"next\""] {
                            debugPrint("nextPagePath: \(nextPagePath)")
                            StorageHelper.setNext_url_pagination(nextPagePath)
                        }
                        
                        if let prevPagePath = dictionary["rel=\"prev\""] {
                            debugPrint("prevPagePath: \(prevPagePath)")
                            StorageHelper.setPrev_url_pagination(prevPagePath)
                        }
                        self.checkNextButtonEnable()
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
    
    // MARK: - IBActions
    
    @IBAction func nextAction()
    {
        let since = self.getQueryStringParameter(url: StorageHelper.getNext_url_pagination()!, param: "since")
        self.view.makeToastActivity(.center)
        _ = NetworkManager.manager.startRequest(GitHubAPI.getUsersNextPagination(since: since!), success:
            {
                responseRequest,responseData in
                debugPrint("getUsersNextPagination StatusCode:\(String(describing: responseRequest?.statusCode))")
                let json = try! JSON(data: responseData! as! Data)
                //                debugPrint("getUsersNextPagination response:\(json)")
                if responseRequest?.statusCode == 200
                {
                    DataBaseHelper.clearDatabase()
                    self.usersFromDataBase = nil
                    if json.arrayValue.count == 0
                    {
                        self.view.makeToast(NSLocalizedString("MESSAGE_SEARCH_NOT_FOUND", comment: "not found message"))
                    }
                    else
                    {
                        for userJson in json.arrayValue
                        {
                            let user = User.fromJson(userJson)
                            DataBaseHelper.createOrUpdateUser(user)
                        }
                        self.usersFromDataBase = DataBaseHelper.getUsers()
                        self.table.reloadData()
                    }
                    let headers = responseRequest?.allHeaderFields as? [String:String]
                    //                    debugPrint("headers:\(String(describing: headers))")
                    if let link = headers!["Link"]
                    {
                        debugPrint("Link Pagination Users:\(link)")
                        let links = link.components(separatedBy: ",")
                        var dictionary: [String: String] = [:]
                        links.forEach({
                            let components = $0.components(separatedBy: "; ")
                            let cleanPath = components[0].trimmingCharacters(in: CharacterSet(charactersIn: "<>"))
                            dictionary[components[1]] = cleanPath
                        })
                        if let nextPagePath = dictionary["rel=\"next\""] {
                            debugPrint("nextPagePath: \(nextPagePath)")
                            StorageHelper.setNext_url_pagination(nextPagePath)
                        }
                        
                        if let prevPagePath = dictionary["rel=\"prev\""] {
                            debugPrint("prevPagePath: \(prevPagePath)")
                            StorageHelper.setPrev_url_pagination(prevPagePath)
                        }
                        self.checkNextButtonEnable()
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
    
    @IBAction func firstAction()
    {
       self.loadUsersFromGitHub()
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
            height = 110
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
                if let users = self.usersFromDataBase
                {
                    rows = users.count
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
            label.text = NSLocalizedString("SECTION_TITLE", comment: "Section Title")
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = self.table.dequeueReusableCell(withIdentifier: "userCell") as! userCell
        if tableView == self.table
        {
            
            switch indexPath.section
            {
                case 0:
                let user = self.usersFromDataBase![indexPath.row]
                cell.cellDelegate = self
                cell.userId = user.id
                cell.userImgAvatar.load(url: Foundation.URL(string: user.avatar_url)!)
                cell.userNameLbl.text = user.login
                cell.linkProfile.setAttributedTitle(NSAttributedString(string: user.html_url, attributes: cell.attributesForProfile), for: .normal)
                cell.linkRepositories.setAttributedTitle(NSAttributedString(string: NSLocalizedString("REPO", comment: "repo"), attributes: cell.attributesForRepo), for: .normal)
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
    
    // MARK: - UserCellDelegate
    func didPressProfile(_ userId: Int)
    {
        if let user = DataBaseHelper.getUserById(user_id: userId)
        {
            if let url = URL(string: user.html_url) {
                UIApplication.shared.open(url, options: [:])
            }
        }
    }
    
    func didPressRepositories(_ userId: Int)
    {
        if let user = DataBaseHelper.getUserById(user_id: userId)
        {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "RepositoriesVc") as! RepositoriesVc
            vc.userId = user.id
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension UIColor {
    convenience init(hex: Int) {
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        self.init(red: components.R, green: components.G, blue: components.B, alpha: 1)
    }
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
                else
                {
                    DispatchQueue.main.async {
                        self?.image = UIImage(named: "githubLogo")
                    }
                }
            }
        }
    }
}
