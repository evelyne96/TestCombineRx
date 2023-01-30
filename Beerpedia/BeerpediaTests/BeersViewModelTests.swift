//
//  BeerpediaTests.swift
//  BeerpediaTests
//
//  Created by Evelyne Suto on 16.01.2023.
//

import XCTest
import Combine

final class BeersViewModelTests: XCTestCase {
    private var sut: BeersViewModel!
    private var mockAPI: MockBeerAPIClient!
    private var mockCoordinator: MockBeerCoordinator!
    private var loadingStates = [Bool]()
    private var subscriptions = Set<AnyCancellable>()
    
    override func setUp() {
        super.setUp()
        mockAPI = MockBeerAPIClient()
        mockCoordinator = MockBeerCoordinator()
        sut = BeersViewModel(apiClient: mockAPI, coordinator: mockCoordinator)
    }
    
    override func tearDown() {
        subscriptions.removeAll()
        mockAPI = nil
        mockCoordinator = nil
        sut = nil
        super.tearDown()
    }
    
    private func setResults(beersResult: Result<[Beer], APIError>? = nil,
                            imageResult: Result<Data, APIError>? = nil) {
        mockAPI.beersResult = beersResult
        mockAPI.imageResult = imageResult
    }

    private func collectLoadStates(count: Int, expectation: XCTestExpectation) {
        sut.isLoading
            .collect(count)
            .sink { [weak self, weak expectation] in
                expectation?.fulfill()
                self?.loadingStates = $0
            }.store(in: &subscriptions)
    }
    
    func test_onLoadedEvent_whenAPISucceeds_shouldLoadSuccessUIState() throws {
        let expectedLoadingStates = [false, true, false]
        let expectedBeers = [Beer.testBeer]
        setResults(beersResult: .success(expectedBeers))

        let loadExpectation = XCTestExpectation(description: #function)
        collectLoadStates(count: 3, expectation: loadExpectation)
        
        // trigger event & wait for expectation
        sut.viewEvent.send(.onLoaded)
        wait(for: [loadExpectation], timeout: 0.1)

        // check UI state
        XCTAssertEqual(loadingStates, expectedLoadingStates)
        XCTAssertEqual(mockAPI.calls, [.getBeers])
        XCTAssertEqual(sut.beers.value, expectedBeers.mapToBeerViewModel())
        XCTAssertEqual(sut.error.value, nil)
    }

    func test_onLoadedEvent_whenAPIFails_shouldLoadErrorUIState() throws {
        let expectedLoadingStates = [false, true, false]
        let expectedError = APIError.invalidData
        setResults(beersResult: .failure(expectedError))

        let loadExpectation = XCTestExpectation(description: #function)
        collectLoadStates(count: 3, expectation: loadExpectation)
        
        // trigger event & wait for expectation
        sut.viewEvent.send(.onLoaded)
        wait(for: [loadExpectation], timeout: 0.1)

        // check UI state
        XCTAssertEqual(loadingStates, expectedLoadingStates)
        XCTAssertEqual(mockAPI.calls, [.getBeers])
        XCTAssertEqual(sut.beers.value, [])
        XCTAssertEqual(sut.error.value, expectedError.description)
    }
    
    func test_onLoadedEvent_whenEventTriggersMultipleTimes_shouldCallAPIOnlyOnce() throws {
        let expectedError: APIError = .invalidData
        
        setResults(beersResult: .failure(expectedError))
        
        let loadExpectation = XCTestExpectation(description: #function)
        loadExpectation.isInverted = true
        collectLoadStates(count: 4, expectation: loadExpectation)

        // trigger event & wait for expectation
        sut.viewEvent.send(.onLoaded)
        sut.viewEvent.send(.onLoaded)
        wait(for: [loadExpectation], timeout: 0.1)

        XCTAssertEqual(mockAPI.calls, [.getBeers])
        XCTAssertEqual(sut.beers.value, [])
    }
    
    func test_didSelectEvent_shouldCoordinateToDetailsScreen() throws {
        let viewModels = [Beer.testBeer, Beer.testBeer].mapToBeerViewModel()
        sut.beers.send(viewModels)
        
        sut.viewEvent.send(.didSelect(IndexPath(row: 0, section: 0)))
        
        XCTAssertEqual(mockCoordinator.navigationPaths, [.showBeerDetails(viewModels.first!)])
    }
}
