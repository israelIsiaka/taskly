//
//  ErrorHandler.swift
//  taskly
//
//  Centralized error handling utilities
//

import Foundation

/// App-specific error types
enum AppError: LocalizedError {
    case networkError(String)
    case cloudKitError(String)
    case dataError(String)
    case validationError(String)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network Error: \(message)"
        case .cloudKitError(let message):
            return "CloudKit Error: \(message)"
        case .dataError(let message):
            return "Data Error: \(message)"
        case .validationError(let message):
            return "Validation Error: \(message)"
        case .unknown(let error):
            return "Unknown Error: \(error.localizedDescription)"
        }
    }
}

/// Error handler utility
struct ErrorHandler {
    /// Convert any error to a user-friendly message
    static func userFriendlyMessage(from error: Error) -> String {
        if let appError = error as? AppError {
            return appError.errorDescription ?? "An error occurred"
        }
        
        // Handle common system errors
        let nsError = error as NSError
        switch nsError.domain {
        case NSCocoaErrorDomain:
            return "Data operation failed. Please try again."
        case NSURLErrorDomain:
            return "Network connection failed. Please check your internet connection."
        default:
            return error.localizedDescription.isEmpty ? "An unexpected error occurred" : error.localizedDescription
        }
    }
    
    /// Log error for debugging
    static func log(_ error: Error, context: String = "") {
        let message = userFriendlyMessage(from: error)
        print("❌ Error\(context.isEmpty ? "" : " in \(context)"): \(message)")
        #if DEBUG
        print("   Full error: \(error)")
        #endif
    }
}
