//
//  ViewController.swift
//  MVVMWithCombine
//
//  Created by Felix Hu on 2025/2/27.
//

import UIKit
import Combine

class ViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var searchButton: UIButton!
  
  private let viewModel: ViewModelType
  private var cancellables: Set<AnyCancellable> = .init()
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    self.viewModel = ViewModel()
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  required init?(coder: NSCoder) {
    self.viewModel = ViewModel()
    super.init(coder: coder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.register(.init(nibName: "CellView" , bundle: nil), forCellReuseIdentifier: "ItemCell")
    tableView.rowHeight = CellView.staticHeight
    searchBar.searchTextField.delegate = self
    searchButton.addTarget(self , action: #selector(onSearchAction), for: .touchUpInside)
    
    bindOutputs()
  }
  
  private func bindOutputs() {
    viewModel.outputs.activityState
      .receive(on: DispatchQueue.main)
      .sink { [weak self] event in
        switch event {
        case .success(let isLoading):
          self?.searchButton.isHidden = isLoading
          if isLoading {
            self?.activityIndicator.startAnimating()
          } else {
            self?.activityIndicator.stopAnimating()
          }
        case .failure(let error):
          self?.searchButton.isHidden = false
          print("Error:", error.localizedDescription)
        }
      }
      .store(in: &cancellables)
    
    viewModel.outputs.viewState
      .receive(on: DispatchQueue.main)
      .removeDuplicates()
      .sink { [weak self] viewState in
        self?.updateData(viewState)
      }
      .store(in: &cancellables)
  }
  
  @objc
  private func onSearchAction() {
    view.endEditing(true)
    viewModel.inputs.onSearch(by: searchBar.text)
  }
  
  enum Section {
    case list
  }
  
  struct Item: Hashable {
    let app: AppStoreApp
    let isMarked: Bool
  }
  
  private var dataSource: UITableViewDiffableDataSource<Section, Item>?
  
  private func getDataSource(_ viewState: ViewState) -> UITableViewDiffableDataSource<Section, Item> {
    return .init(tableView: tableView) { tableView, indexPath, item in
      let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell")! as! CellView
      cell.reload(item.app, isMarked: item.isMarked)
      cell.onToggleMark = { [weak self] in
        self?.viewModel.inputs.toggleMark(by: item.app.trackId)
      }
      return cell
    }
  }
  
  private func updateData(_ viewState: ViewState) {
    var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
    snapshot.appendSections([.list])
    snapshot.appendItems(viewState.apps.map {
      .init(app: $0, isMarked: viewState.isMarked(with: $0.trackId))
    })
    if self.dataSource == nil {
      self.dataSource = getDataSource(viewState)
    }
    self.dataSource?.apply(snapshot, animatingDifferences: false, completion: nil)
  }
  
}

extension ViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    onSearchAction()
    return true
  }
}

