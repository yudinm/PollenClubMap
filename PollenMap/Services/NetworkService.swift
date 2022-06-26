//
//  NetworkService.swift
//  PollenMap
//
//  Created by Mikhail Yudin on 19.05.2022.
//


/// https://api.pollen.club/ajax/get_forecasts

/// https://api.pollen.club/static/forecasts/
/// %D0%91%D0%B5%D1%80%D0%B5%D0%B7%D0%B0
/// /2022/5/23/0.json?_=1652938902010


import Foundation

protocol Service { }

protocol NetworkServiceProtocol {
    static var apiURL: String { get }
        
    func fetchForecasts(with completion: @escaping(Forecasts)->(Void))
    func fetchAreaData(for forecasts: Forecasts,
                       and allergen: String,
                       with interval: Int,
                       and completion: @escaping([ForecastArea])->(Void))
}

enum PollenEndpoints {
    case availableForecasts
    
    func path() -> String {
        switch self {
        case .availableForecasts:
            return "ajax/get_forecasts"
        }
    }
}

open class NetworkService: NSObject, NetworkServiceProtocol {
    static internal var apiURL = "https://api.pollen.club"
    private let networkingQueue = OperationQueue()
    private var tasks: [URL: LoadingJSONOperation] = [:]
    
    public override init() {
        networkingQueue.maxConcurrentOperationCount = 1
        networkingQueue.qualityOfService = .utility
        super.init()
    }
}

extension NetworkService {
    func fetchForecasts(with completion: @escaping (Forecasts) -> (Void)) {
        guard let url = URL(string: NetworkService.apiURL)?.appendingPathComponent(PollenEndpoints.availableForecasts.path()) else { return }
        tasks[url] = LoadingJSONOperation(url: url)
        guard let task = tasks[url] else { return }
        task.completionBlock = {
            do {
                guard let data = task.data else { return }
                let forecasts = try JSONDecoder()
                    .decode(Forecasts.self, from: data)
                completion(forecasts)
            } catch {
                fatalError("Parsing json error: \(error)")
            }
        }
        networkingQueue.addOperation(task)
    }
}

extension NetworkService {
    func fetchAreaData(for forecasts: Forecasts,
                       and allergen: String,
                       with interval: Int,
                       and completion: @escaping ([ForecastArea]) -> (Void))
    {
        guard let path = forecasts.intervalPath[interval] else { return }
        if (!forecasts.allergens.contains(allergen)) { return }
        let url = URL(string: NetworkService.apiURL)!
            .appendingPathComponent(forecasts.root)
            .appendingPathComponent(allergen)
            .appendingPathComponent(path)
        tasks[url] = LoadingJSONOperation(url: url)
        guard let task = tasks[url] else { return }
        task.completionBlock = {
            do {
                guard let data = task.data else { return }
                let forecastAreaList = try JSONDecoder()
                    .decode([ForecastArea].self, from: data)
                completion(forecastAreaList)
            } catch {
                fatalError("Parsing json error: \(error)")
            }
        }
        networkingQueue.addOperation(task)
    }
}

open class LoadingJSONOperation: Operation {
//    typealias DataHandler = (Data) -> (Void)
    private let url: URL
//    private let handler: DataHandler
    private var dataTask: URLSessionDataTask?
    private let taskDispatchGroup = DispatchGroup()
    var data: Data?

    init(url: URL) {
        self.url = url
        super.init()
    }
    
    open override func main() {
        if isCancelled { return }
        taskDispatchGroup.enter()
        dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                self.handleClientError(error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                self.handleServerError(response)
                return
            }
            if let mimeType = httpResponse.mimeType,
                mimeType == "application/json",
                let data = data
            {
                if self.isCancelled { return }
                self.data = data
                self.taskDispatchGroup.leave()
            }
        }
        guard let dataTask = dataTask else { return }
        dataTask.resume()
        taskDispatchGroup.wait()
    }
    
    open override func cancel() {
        super.cancel()
        dataTask?.cancel()
    }

    func handleClientError(_ error: Error) {
        print("Client error: ")
        fatalError(error.localizedDescription)
    }
    
    func handleServerError(_ response: URLResponse?) {
        print("Server error: ")
        print(response?.debugDescription ?? "")
    }

}
