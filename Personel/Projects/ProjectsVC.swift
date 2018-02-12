//
//  ProjectsVC.swift
//  Personel
//
//  Created by Ion Utale on 11/02/2018.
//  Copyright © 2018 Ion Utale. All rights reserved.
//

import UIKit
import TransitionButton

class ProjectsVC: ViewController {
    @IBOutlet weak var tableView: UITableView!
    var projects: [Project]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.startLoader()
        Network.getProjects() { (proj, sc, error) in
            if error != nil {
                self.presentBanner(title: "Error", message: "unable to get projects.\(error?.localizedDescription ?? "")")
                return
            }
            self.projects = proj
            UserManager.projects = proj
            self.tableView.reloadData()
            self.stopLoader()
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
        self.performSegue(withIdentifier: "addProject", sender: projects[indexPath.row])
    }
}
