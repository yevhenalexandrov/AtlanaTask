//
//  UserViewerRepoViewCell.swift
//  AtlanaTask
//
//  Created by Yevhen Alexandrov on 27.02.2021.
//

import UIKit


class UserViewerRepoViewCell: UITableViewCell, Reusable, Configurable, NibLoadableView {
 
    @IBOutlet weak var repoNameLabel: UILabel!
    @IBOutlet weak var forksCountLabel: UILabel!
    @IBOutlet weak var starsCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    private func setupViews() {
        repoNameLabel.text = ""
        forksCountLabel.text = ""
        starsCountLabel.text = ""
    }
    
    func configure(with viewModel: GithubRepo) {
        repoNameLabel.text = viewModel.repositoryName
        forksCountLabel.text = "\(viewModel.forksCount) Forks"
        starsCountLabel.text = "\(viewModel.starsCount) Stars"
    }
}
