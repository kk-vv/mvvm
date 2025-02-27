//
//  ViewModel.swift
//  MVVMWithCombine
//
//  Created by Felix Hu on 2025/2/27.
//

import Foundation
import Combine

typealias ActivityState = Result<Bool, Error>

protocol ViewModelInputs {
  func onSearch(by name: String?)
  func toggleMark(by trackId: Int)
}

protocol ViewModelOutputs {
  var viewState: AnyPublisher<ViewState, Never> { get }
  var activityState: AnyPublisher<ActivityState, Never> { get }
}

protocol ViewModelType {
  var inputs: ViewModelInputs { get }
  var outputs: ViewModelOutputs { get }
}

class ViewModel {
  
  private let searchInput: PassthroughSubject<String?, Never> = .init()
  private let toggleMarkInput: PassthroughSubject<Int, Never> = .init()
  private let service: AppStoreService
  
  private let backingViewState: CurrentValueSubject<ViewState, Never>
  private let backingActivityState: CurrentValueSubject<ActivityState, Never> = .init(.success(false))
  private var cancellables: Set<AnyCancellable> = []
  
  init(service: AppStoreService = .init()) {
    self.service = service
    backingViewState = .init(.init())
    
    bindInputs()
  }
  
  private func bindInputs() {
    searchInput.compactMap { $0 }
      .filter { !$0.isEmpty }
      .throttle(for: .milliseconds(200), scheduler: DispatchQueue.main, latest: true)
      .sink { [weak self] term in
        self?.handleSearchAction(term: term)
      }
      .store(in: &cancellables)
    
    toggleMarkInput
      .sink { [weak self] trackId in
        self?.setViewState {
          $0.toggleMarked(by: trackId)
        }
      }
      .store(in: &cancellables)    
  }
  
  private func handleSearchAction(term: String) {
    self.backingActivityState.send(.success(true))
    service.searchApp(term: term)
      .sink { [weak self] event in
        self?.backingActivityState.send(.success(false))
        switch event {
        case .finished: ()
        case .failure(let error):
          self?.backingActivityState.send(.failure(error))
        }
      } receiveValue: { [weak self] apps in
        self?.setViewState {
          $0.reloadApps(apps)
        }
      }
      .store(in: &cancellables)
  }
  
  private func setViewState(_ setter: (inout ViewState) -> Void) {
    var viewState = backingViewState.value
    setter(&viewState)
    backingViewState.send(viewState)
  }
  
}

extension ViewModel: ViewModelInputs {
  
  func onSearch(by name: String?) {
    searchInput.send(name)
  }
  
  func toggleMark(by trackId: Int) {
    toggleMarkInput.send(trackId)
  }
  
}

extension ViewModel: ViewModelOutputs {
  
  var viewState: AnyPublisher<ViewState, Never> {
    backingViewState.eraseToAnyPublisher()
  }
  
  var activityState: AnyPublisher<Result<Bool, any Error>, Never> {
    backingActivityState.eraseToAnyPublisher()
  }
  
}

extension ViewModel: ViewModelType {
  var inputs: ViewModelInputs { self }
  var outputs: ViewModelOutputs { self }
}
