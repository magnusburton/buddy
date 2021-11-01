//
//  HealthKitManager.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-03-04.
//

import Foundation
import HealthKit

class HealthKitManager: ObservableObject {
    public let healthStore = HKHealthStore()
    
    private let infoToRead: Set<HKObjectType> = [
        HKCharacteristicType.characteristicType(forIdentifier: .biologicalSex)!,
        HKCharacteristicType.characteristicType(forIdentifier: .dateOfBirth)!,
        HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!,
        
        HKWorkoutType.workoutType(),
        
        HKSampleType.quantityType(forIdentifier: .heartRate)!,
        HKSampleType.quantityType(forIdentifier: .vo2Max)!
    ]
    
    /// Sample types used for background processing
    public let quantityTypes: Set<HKQuantityType> = [
        HKSampleType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
        HKSampleType.quantityType(forIdentifier: .restingHeartRate)!,
        
        HKSampleType.quantityType(forIdentifier: .bodyFatPercentage)!,
        
        HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKSampleType.quantityType(forIdentifier: .stepCount)!,
        HKSampleType.quantityType(forIdentifier: .flightsClimbed)!
    ]
    
    func authorizeHealthKit() async -> Bool {
        // Request read permission for all types
        let samplesToRead = infoToRead.union(quantityTypes)
        
        do {
            try await healthStore.requestAuthorization(toShare: [], read: samplesToRead)
            return true
        } catch let error {
            debugPrint("Error requesting HealthKit authorization: \(error)")
            return false
        }
    }
}

extension HealthKitManager {
    func getHealthData(for identifier: HKQuantityTypeIdentifier, completion: @escaping ([HKQuantitySample]?, Error?) -> Void) {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .day], from: now)
        
        guard let endDate = calendar.date(from: components) else {
            fatalError("*** Unable to create the end date")
        }
        
        guard let startDate = calendar.date(byAdding: .month, value: -2, to: endDate) else {
            fatalError("*** Unable to create the start date")
        }
        
        let datePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        
        guard let quantityType = HKObjectType.quantityType(forIdentifier: identifier) else {
            completion(nil, nil)
            fatalError("*** Unable to create quantity type")
        }
        
        let sortByDate = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        
        // Create the query
        let query = HKSampleQuery(sampleType: quantityType, predicate: datePredicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortByDate]) { query, samples, error in
            
            guard let samples = samples as? [HKQuantitySample], error == nil else {
                completion(nil, error)
                return
            }
            
            completion(samples, nil)
        }
        
        healthStore.execute(query)
    }
    
    func getWorkouts(completion: @escaping ([HKWorkout]?, Error?) -> Void) {
        let compound = NSCompoundPredicate(orPredicateWithSubpredicates:
                                            [HKQuery.predicateForWorkouts(with: .walking),
                                             HKQuery.predicateForWorkouts(with: .running)
                                             /*HKQuery.predicateForWorkouts(with: .hiking)*/])
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate,
                                              ascending: false)
        
        let query = HKSampleQuery(
            sampleType: .workoutType(),
            predicate: compound,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]) { (query, samples, error) in
                DispatchQueue.main.async {
                    guard let samples = samples as? [HKWorkout], error == nil else {
                        completion(nil, error)
                        return
                    }
                    
                    completion(samples, nil)
                }
            }
        
        healthStore.execute(query)
    }
    
    func getWorkout(_ uuid: UUID) async throws -> HKWorkout {
        let predicate = HKQuery.predicateForObject(with: uuid)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: .workoutType(),
                predicate: predicate,
                limit: 1,
                sortDescriptors: nil) { (_, samples, error) in
                    if let error = error {
                        continuation.resume(throwing: error)
                    }
                    
                    guard let samples = samples as? [HKWorkout], let sample = samples.first else {
                        continuation.resume(throwing: HealthKitError.noData)
                        return
                    }
                    
                    continuation.resume(returning: sample)
                }
            
            healthStore.execute(query)
        }
    }
    
    func getWorkoutData(for workout: HKWorkout, identifier: HKQuantityTypeIdentifier) async throws -> [HKQuantitySample] {
        let predicate = HKQuery.predicateForObjects(from: workout)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)
        
        guard let sampleType = HKObjectType.quantityType(forIdentifier: identifier) else {
            throw HealthKitError.unknown
        }
        
        let condensedSampleTypes: [HKQuantityTypeIdentifier] = [.distanceWalkingRunning, .distanceCycling, .basalEnergyBurned, .activeEnergyBurned, .heartRate]
        
        if condensedSampleTypes.contains(identifier) {
            
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sampleType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]) { (_, samples, error) in
                    if let error = error {
                        continuation.resume(throwing: error)
                    }
                    
                    guard let samples = samples as? [HKQuantitySample] else {
                        continuation.resume(throwing: HealthKitError.noData)
                        return
                    }
                    
                    if condensedSampleTypes.contains(identifier) {
                        var singleSamples: [HKQuantitySample] = []
                        
                        for sample in samples {
                            // Check to see if the sample is a series.
                            if sample.count == 1 {
                                // This is a single sample.
                                // Use the sample.
                                singleSamples.append(sample)
                            } else {
                                // This is a series.
                                // Get the detailed items for the series.
//                                async let series = getSampleSeries(for: sample, type: sampleType)
//                                singleSamples.append(contentsOf: await series)
                                
                                let modifiedSample = HKQuantitySample(
                                    type: sampleType,
                                    quantity: sample.quantity,
                                    start: sample.startDate,
                                    end: sample.endDate)
                                singleSamples.append(modifiedSample)
                            }
                        }
                        continuation.resume(returning: singleSamples)
                    } else {
                        continuation.resume(returning: samples)
                    }
                }
            
            healthStore.execute(query)
        }
    }
    
    func getSampleSeries(for quantity: HKQuantitySample, type: HKQuantityType) async -> [HKQuantitySample] {
        let inSeriesSample = HKQuery.predicateForObject(with: quantity.uuid)
        
        return await withCheckedContinuation { continuation in
            var samples: [HKQuantitySample] = []
            
            let query = HKQuantitySeriesSampleQuery(quantityType: type,
                                                    predicate: inSeriesSample)
            { _, quantity, dateInterval, _, done, error in
                if error != nil {
                    continuation.resume(returning: samples)
                    return
                }
                
                if let quantity = quantity, let dateInterval = dateInterval {
                    let sample = HKQuantitySample(type: type, quantity: quantity, start: dateInterval.start, end: dateInterval.end)
                    samples.append(sample)
                }
                
                if done {
                    continuation.resume(returning: samples)
                }
            }
            
            healthStore.execute(query)
        }
    }
    
    @available(*, deprecated, message: "Prefer async alternative instead")
    func getVo2Max(from workout: HKWorkout, completion: @escaping (HKQuantitySample?, Error?) -> Void) {
        Task {
            do {
                let result = try await getVo2Max(from: workout)
                completion(result, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
    
    
    func getVo2Max(from workout: HKWorkout) async throws -> HKQuantitySample {
        let startDate = workout.startDate
        guard let endDate = Calendar.current.date(byAdding: .minute, value: 3, to: workout.endDate) else {
            fatalError("*** Unable to create end date")
        }
        
        let datePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        
        guard let quantityType = HKObjectType.quantityType(forIdentifier: .vo2Max) else {
            fatalError("*** Unable to create quantity type")
        }
        
        // Create the query
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: quantityType, predicate: datePredicate, limit: 1, sortDescriptors: nil) { _, samples, error in
                
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let samples = samples as? [HKQuantitySample], let sample = samples.first else {
                    continuation.resume(throwing: HealthKitError.noData)
                    return
                }
                
                continuation.resume(returning: sample)
            }
            
            healthStore.execute(query)
        }
    }
    
    @available(*, deprecated, message: "Prefer async alternative instead")
    func getCooldownHR(from workout: HKWorkout, completion: @escaping ([HKQuantitySample]?, Error?) -> Void) {
        Task {
            do {
                let result = try await getCooldownHR(from: workout)
                completion(result, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
    
    
    func getCooldownHR(from workout: HKWorkout) async throws -> [HKQuantitySample] {
        let startDate = workout.endDate
        guard let endDate = Calendar.current.date(byAdding: .minute, value: 3, to: startDate) else {
            fatalError("*** Unable to create end date")
        }
        
        let datePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        
        guard let quantityType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            return []
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)
        
        // Create the query
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: quantityType,
                predicate: datePredicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]) { _, samples, error in
                    
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    guard let samples = samples as? [HKQuantitySample] else {
                        continuation.resume(throwing: HealthKitError.noData)
                        return
                    }
                    
                    continuation.resume(returning: samples)
            }
            
            healthStore.execute(query)
        }
    }
}
