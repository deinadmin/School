//
//  CloudKitSyncStatusView.swift
//  School
//
//  Created by Carl on 05.06.25.
//

import SwiftUI

/// Compact CloudKit sync status indicator for main view
/// Debug: Shows minimal sync status information without taking much space
struct CloudKitSyncStatusView: View {
    @State private var syncManager = CloudKitSyncManager.shared
    @State private var showingFullSync = false
    
    /// Whether the sync status should be shown
    /// Debug: Only show when relevant (syncing, error, or recently synced)
    private var shouldShowStatus: Bool {
        switch syncManager.syncStatus {
        case .unknown, .synced:
            // Only show synced status if recently synced or if there was recent activity
            return syncManager.isSyncing || (syncManager.lastSyncDate != nil && 
                   Date().timeIntervalSince(syncManager.lastSyncDate!) < 300) // 5 minutes
        case .notAvailable, .error:
            return true // Always show problems
        case .syncing:
            return true // Always show active sync
        }
    }
    
    var body: some View {
        Group {
            if shouldShowStatus {
                Button(action: {
                    showingFullSync = true
                }) {
            HStack(spacing: 8) {
                // Status icon with animation
                Image(systemName: syncManager.syncStatus.icon)
                    .foregroundColor(syncManager.syncStatus.color)
                    .font(.caption)
                    .rotationEffect(.degrees(syncManager.isSyncing ? 360 : 0))
                    .animation(
                        syncManager.isSyncing ? 
                        Animation.linear(duration: 1.0).repeatForever(autoreverses: false) : 
                        .default,
                        value: syncManager.isSyncing
                    )
                
                // Status text
                Text(syncStatusText)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(.thinMaterial)
                    .overlay(
                        Capsule()
                            .stroke(syncManager.syncStatus.color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingFullSync) {
            NavigationView {
                CloudKitSyncView()
                    .navigationTitle("iCloud Sync")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Fertig") {
                                showingFullSync = false
                            }
                        }
                    }
            }
        }
        .onAppear {
            // Debug: Check sync status when view appears
            syncManager.checkCloudKitAvailability()
        }
            }
        }
    }
    
    /// Compact status text for the indicator
    /// Debug: Provides brief status description suitable for small space
    private var syncStatusText: String {
        if syncManager.isSyncing {
            return "Synchronisiert..."
        }
        
        switch syncManager.syncStatus {
        case .unknown:
            return "iCloud Status wird geprüft"
        case .notAvailable:
            return "iCloud nicht verfügbar"
        case .syncing:
            return "Synchronisiert..."
        case .synced:
            if let lastSync = syncManager.lastSyncDate {
                let interval = Date().timeIntervalSince(lastSync)
                if interval < 60 {
                    return "Gerade synchronisiert"
                } else if interval < 3600 {
                    return "Vor \(Int(interval/60)) Min synchronisiert"
                } else {
                    return "Zuletzt heute synchronisiert"
                }
            } else {
                return "iCloud aktiv"
            }
        case .error:
            return "Sync-Fehler"
        }
    }
}

/// Even more compact CloudKit sync status for toolbar
/// Debug: Minimal space sync indicator for toolbars
struct CompactCloudKitSyncIndicator: View {
    @State private var syncManager = CloudKitSyncManager.shared
    
    var body: some View {
        Image(systemName: syncManager.syncStatus.icon)
            .foregroundColor(syncManager.syncStatus.color)
            .font(.caption)
            .rotationEffect(.degrees(syncManager.isSyncing ? 360 : 0))
            .animation(
                syncManager.isSyncing ? 
                Animation.linear(duration: 1.0).repeatForever(autoreverses: false) : 
                .default,
                value: syncManager.isSyncing
            )
            .onAppear {
                syncManager.checkCloudKitAvailability()
            }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        CloudKitSyncStatusView()
        CompactCloudKitSyncIndicator()
    }
    .padding()
} 