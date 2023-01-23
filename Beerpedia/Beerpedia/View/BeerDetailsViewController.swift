//
//  BeerDetailsViewController.swift
//  Beerpedia
//
//  Created by Evelyne Suto on 17.01.2023.
//

import Combine
import Foundation
import UIKit

final class BeerDetailsViewController: UIViewController {
    private enum UIConstants {
        static var nib: String = "BeerDetails"
        static var spacing: CGFloat = 16
    }
    
    private let viewModel: BeerViewModel
    private var cancellables = Set<AnyCancellable>()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var firstBrewed: UILabel!
    @IBOutlet weak var contributed: UILabel!
    
    init(viewModel: BeerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: UIConstants.nib,
                   bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        bindViews()
        viewModel.viewEvent.send(.onLoaded)
    }
    
    private func bindViews() {
        name.text = viewModel.name
        firstBrewed.text = viewModel.firstBrewed
        contributed.text = viewModel.contributedBy
        
        viewModel.image
            .receive(on: DispatchQueue.main)
            .assign(to: \.image, on: imageView)
            .store(in: &cancellables)
    }
}
