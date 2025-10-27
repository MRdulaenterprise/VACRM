//
//  VAGovCacheService.swift
//  Veterans
//
//  Created by Dagger4 on 10/24/25.
//

import Foundation

/// VA.GOV API caching service with hybrid caching strategy
/// Caches reference data (disabilities, service branches, states) for extended periods
/// Always fetches live data for forms and facilities
class VAGovCacheService {
    
    // MARK: - Properties
    
    private let userDefaults = UserDefaults.standard
    private let cachePrefix = "vaGovCache_"
    private let timestampSuffix = "_timestamp"
    
    // Cache durations (in seconds)
    private let referenceDataCacheDuration: TimeInterval = 7 * 24 * 60 * 60 // 7 days
    private let facilitiesCacheDuration: TimeInterval = 24 * 60 * 60 // 24 hours
    private let formsCacheDuration: TimeInterval = 60 * 60 // 1 hour (forms change frequently)
    
    // MARK: - Cache Keys
    
    enum CacheKey: String, CaseIterable {
        case disabilities = "disabilities"
        case serviceBranches = "serviceBranches"
        case treatmentCenters = "treatmentCenters"
        case states = "states"
        case countries = "countries"
        case contentionTypes = "contentionTypes"
        case militaryPayTypes = "militaryPayTypes"
        case specialCircumstances = "specialCircumstances"
        case intakeSites = "intakeSites"
        case facilities = "facilities"
        case forms = "forms"
        
        var cacheDuration: TimeInterval {
            switch self {
            case .disabilities, .serviceBranches, .treatmentCenters, .states, .countries,
                 .contentionTypes, .militaryPayTypes, .specialCircumstances, .intakeSites:
                return 7 * 24 * 60 * 60 // 7 days
            case .facilities:
                return 24 * 60 * 60 // 24 hours
            case .forms:
                return 60 * 60 // 1 hour
            }
        }
    }
    
    // MARK: - Public Methods
    
    /// Check if cached data exists and is not expired
    func isCacheValid(for key: CacheKey) -> Bool {
        let timestampKey = cachePrefix + key.rawValue + timestampSuffix
        guard let timestamp = userDefaults.object(forKey: timestampKey) as? Date else {
            return false
        }
        
        let cacheAge = Date().timeIntervalSince(timestamp)
        return cacheAge < key.cacheDuration
    }
    
    /// Get cached data if valid
    func getCachedData<T: Codable>(for key: CacheKey, type: T.Type) -> T? {
        guard isCacheValid(for: key) else {
            return nil
        }
        
        let dataKey = cachePrefix + key.rawValue
        guard let data = userDefaults.data(forKey: dataKey) else {
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(type, from: data)
        } catch {
            print("Failed to decode cached data for \(key.rawValue): \(error)")
            return nil
        }
    }
    
    /// Cache data with timestamp
    func cacheData<T: Codable>(_ data: T, for key: CacheKey) {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(data)
            
            let dataKey = cachePrefix + key.rawValue
            let timestampKey = cachePrefix + key.rawValue + timestampSuffix
            
            userDefaults.set(encodedData, forKey: dataKey)
            userDefaults.set(Date(), forKey: timestampKey)
            
            print("Cached data for \(key.rawValue)")
        } catch {
            print("Failed to cache data for \(key.rawValue): \(error)")
        }
    }
    
    /// Clear cache for specific key
    func clearCache(for key: CacheKey) {
        let dataKey = cachePrefix + key.rawValue
        let timestampKey = cachePrefix + key.rawValue + timestampSuffix
        
        userDefaults.removeObject(forKey: dataKey)
        userDefaults.removeObject(forKey: timestampKey)
        
        print("Cleared cache for \(key.rawValue)")
    }
    
    /// Clear all VA.GOV caches
    func clearAllCaches() {
        for key in CacheKey.allCases {
            clearCache(for: key)
        }
        print("Cleared all VA.GOV caches")
    }
    
    /// Get cache statistics
    func getCacheStatistics() -> CacheStatistics {
        var validCaches = 0
        var expiredCaches = 0
        var totalCacheSize = 0
        
        for key in CacheKey.allCases {
            let dataKey = cachePrefix + key.rawValue
            if let data = userDefaults.data(forKey: dataKey) {
                totalCacheSize += data.count
                if isCacheValid(for: key) {
                    validCaches += 1
                } else {
                    expiredCaches += 1
                }
            }
        }
        
        return CacheStatistics(
            validCaches: validCaches,
            expiredCaches: expiredCaches,
            totalCacheSize: totalCacheSize,
            lastUpdated: getLastCacheUpdate()
        )
    }
    
    // MARK: - Private Methods
    
    private func getLastCacheUpdate() -> Date? {
        var latestDate: Date?
        
        for key in CacheKey.allCases {
            let timestampKey = cachePrefix + key.rawValue + timestampSuffix
            if let timestamp = userDefaults.object(forKey: timestampKey) as? Date {
                if latestDate == nil || timestamp > latestDate! {
                    latestDate = timestamp
                }
            }
        }
        
        return latestDate
    }
}

// MARK: - Cache Statistics

struct CacheStatistics {
    let validCaches: Int
    let expiredCaches: Int
    let totalCacheSize: Int
    let lastUpdated: Date?
    
    var formattedCacheSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(totalCacheSize))
    }
    
    var formattedLastUpdated: String {
        guard let lastUpdated = lastUpdated else {
            return "Never"
        }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: lastUpdated, relativeTo: Date())
    }
}

// MARK: - Cache Key Extensions

extension VAGovCacheService.CacheKey {
    /// Get cache age in human-readable format
    func getCacheAge() -> String? {
        let timestampKey = "vaGovCache_" + rawValue + "_timestamp"
        guard let timestamp = UserDefaults.standard.object(forKey: timestampKey) as? Date else {
            return nil
        }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
    
    /// Get cache size in bytes
    func getCacheSize() -> Int {
        let dataKey = "vaGovCache_" + rawValue
        return UserDefaults.standard.data(forKey: dataKey)?.count ?? 0
    }
}
