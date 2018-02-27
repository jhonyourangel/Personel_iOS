//
//  ProjectsVC.swift
//  Personel
//
//  Created by Ion Utale on 11/02/2018.
//  Copyright © 2018 Ion Utale. All rights reserved.
//

import UIKit
import TransitionButton

protocol ProjectsDelegate {
    func projectName(name: String)
}

class ProjectsVC: ViewController {
    @IBOutlet weak var tableView: UITableView!
    var projects: [Project]! = []
    var delegate: ProjectsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.getProjects()
        self.navigationController?.isNavigationBarHidden = (delegate != nil)
    }
    
    func getProjects() {
        self.startLoader()
        Network.getProjects() { (proj, sc, error) in
            self.stopLoader()

            if error != nil {
                self.presentBanner(title: "Error", message: "unable to get projects.\(error?.localizedDescription ?? "")")
                return
            }
            self.projects = proj
            UserManager.projects = proj
            self.tableView.reloadData()
        }
    }
    
    @IBAction func createProject() {
        let project = Project()
        project.income = 0
        project.name = ""
        self.performSegue(withIdentifier: "addProject", sender: project)
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addProject" {
            let destination = segue.destination as! AddProjectVC
            destination.project = sender as! Project
        }
    }
}

extension ProjectsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            let proj = projects[indexPath.row]
            self.startLoader()
            Network.deleteProject(id: proj._id!, completion: { (genericResposne, statusCode, error) in
                self.stopLoader()
                
//                print(genericResposne?.msg, genericResposne?.project?._id, genericResposne?.project?.name)
                
                if error != nil {
                    self.presentBanner(title: "Error", message: "The projet could not be deleted", backgroundColor: .white)
                } else {
                    self.getProjects()
                }
            })
        }
    }
}

extension ProjectsVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = projects[indexPath.row].name
        cell?.detailTextLabel?.text = "\(projects[indexPath.row].income!)"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if delegate == nil {
            self.performSegue(withIdentifier: "addProject", sender: projects[indexPath.row])
        } else {
            delegate?.projectName(name: projects[indexPath.row].name!)
            self.navigationController?.popViewController(animated: true)
        }
    }
}
