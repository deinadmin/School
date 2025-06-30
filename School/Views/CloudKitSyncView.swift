//
//  CloudKitSyncView.swift
//  School
//
//  Created by Carl on 05.06.25.
//

import SwiftUI
import CloudKit

/// CloudKit sync management interface
/// Debug: Provides comprehensive sync status, manual sync controls, and troubleshooting
struct CloudKitSyncView: View {
    @State private var syncManager = CloudKitSyncManager.shared
    @State private var showingDetailedStatus = false
    @State private var showingTroubleshootingGuide = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Sync Status Overview
            syncStatusSection
            
            // Data Overview
            if syncManager.isCloudKitAvailable {
                dataOverviewSection
            }
            
            // Sync Controls
            syncControlsSection
            
            // Error Display
            if let error = syncManager.currentError {
                errorSection(error: error)
            }
            
            // Additional Information
            additionalInfoSection
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.thinMaterial)
                .shadow(color: Color.black.opacity(0.08), radius: 12, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .onAppear {
            syncManager.checkCloudKitAvailability()
        }
        .sheet(isPresented: $showingDetailedStatus) {
            detailedStatusView
        }
        .sheet(isPresented: $showingTroubleshootingGuide) {
            troubleshootingGuideView
        }
    }
    
    // MARK: - Sync Status Section
    
    private var syncStatusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: syncManager.syncStatus.icon)
                    .foregroundColor(syncManager.syncStatus.color)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("iCloud Synchronisation")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(syncManager.syncStatusDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if syncManager.isSyncing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(0.8)
                }
            }
            
            // Account Status
            HStack {
                Image(systemName: syncManager.isCloudKitAvailable ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(syncManager.isCloudKitAvailable ? .green : .red)
                
                Text(syncManager.accountStatusDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            // Last Sync Date
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.secondary)
                
                Text(syncManager.lastSyncDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
        }
    }
    
    // MARK: - Data Overview Section
    
    private var dataOverviewSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Synchronisierte Daten")
                .font(.subheadline)
                .fontWeight(.medium)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                dataCountCard(icon: "book.fill", title: "Fächer", count: "Alle")
                dataCountCard(icon: "number.circle.fill", title: "Noten", count: "Alle")
                dataCountCard(icon: "tag.fill", title: "Notentypen", count: "Alle")
                dataCountCard(icon: "star.fill", title: "Endnoten", count: "Alle")
            }
        }
    }
    
    private func dataCountCard(icon: String, title: String, count: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.caption)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Text(count)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    // MARK: - Sync Controls Section
    
    private var syncControlsSection: some View {
        VStack(spacing: 12) {
            // Manual Sync Button
            Button(action: {
                syncManager.performManualSync()
            }) {
                HStack {
                    if syncManager.isSyncing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.title3)
                    }
                    
                    Text(syncManager.isSyncing ? "Synchronisierung läuft..." : "Jetzt synchronisieren")
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(syncManager.canPerformManualSync ? Color.blue : Color.gray)
                )
            }
            .disabled(!syncManager.canPerformManualSync)
            
            // Action Buttons Row
            HStack(spacing: 12) {
                Button("Details anzeigen") {
                    showingDetailedStatus = true
                }
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
                
                Button("Problembehandlung") {
                    showingTroubleshootingGuide = true
                }
                .foregroundColor(.orange)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
    
    // MARK: - Error Section
    
    private func errorSection(error: CloudKitSyncError) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                
                Text("Synchronisierungsfehler")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.red)
                
                Spacer()
                
                Button("Fehler löschen") {
                    syncManager.clearError()
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            Text(error.localizedDescription)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("Vorschlag: \(error.suggestedAction)")
                .font(.caption)
                .foregroundColor(.blue)
                .italic()
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.red.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Additional Info Section
    
    private var additionalInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Hinweise")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 4) {
                infoRow(icon: "info.circle", text: "Synchronisation erfolgt automatisch im Hintergrund")
                infoRow(icon: "wifi", text: "Benötigt aktive Internetverbindung")
                infoRow(icon: "icloud", text: "Alle Geräte mit demselben iCloud-Account werden synchronisiert")
            }
        }
    }
    
    private func infoRow(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .font(.caption)
                .frame(width: 16)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
    
    // MARK: - Detailed Status View
    
    private var detailedStatusView: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // Status Cards
                VStack(spacing: 12) {
                    detailCard(
                        title: "CloudKit Status",
                        value: syncManager.syncStatusDescription,
                        icon: syncManager.syncStatus.icon,
                        color: syncManager.syncStatus.color
                    )
                    
                    detailCard(
                        title: "iCloud Account",
                        value: syncManager.accountStatusDescription,
                        icon: syncManager.isCloudKitAvailable ? "checkmark.circle.fill" : "xmark.circle.fill",
                        color: syncManager.isCloudKitAvailable ? .green : .red
                    )
                    
                    detailCard(
                        title: "Letzte Synchronisation",
                        value: syncManager.lastSyncDescription,
                        icon: "clock.arrow.circlepath",
                        color: .blue
                    )
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Sync-Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fertig") {
                        showingDetailedStatus = false
                    }
                }
            }
        }
    }
    
    private func detailCard(title: String, value: String, icon: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Troubleshooting Guide View
    
    private var troubleshootingGuideView: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    troubleshootingSection(
                        title: "iCloud nicht verfügbar",
                        steps: [
                            "Öffnen Sie die Einstellungen-App",
                            "Tippen Sie auf Ihren Namen (Apple ID)",
                            "Wählen Sie 'iCloud'",
                            "Aktivieren Sie iCloud Drive",
                            "Starten Sie die App neu"
                        ]
                    )
                    
                    troubleshootingSection(
                        title: "Synchronisation funktioniert nicht",
                        steps: [
                            "Überprüfen Sie Ihre Internetverbindung",
                            "Tippen Sie auf 'Jetzt synchronisieren'",
                            "Warten Sie einige Minuten",
                            "Starten Sie die App neu",
                            "Prüfen Sie Ihren iCloud-Speicher"
                        ]
                    )
                    
                    troubleshootingSection(
                        title: "Speicher voll",
                        steps: [
                            "Öffnen Sie die Einstellungen-App",
                            "Tippen Sie auf Ihren Namen",
                            "Wählen Sie 'iCloud' → 'Speicher verwalten'",
                            "Löschen Sie nicht benötigte Daten",
                            "Oder erweitern Sie Ihren iCloud-Speicher"
                        ]
                    )
                }
                .padding()
            }
            .navigationTitle("Problembehandlung")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fertig") {
                        showingTroubleshootingGuide = false
                    }
                }
            }
        }
    }
    
    private func troubleshootingSection(title: String, steps: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(index + 1).")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                            .frame(width: 20, alignment: .leading)
                        
                        Text(step)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
} 