//
//  ViewController.swift
//  Project22
//
//  Created by Антон Кашников on 07/10/2024.
//

import CoreLocation
import UIKit

final class ViewController: UIViewController {
    // MARK: - IBOutlets
    
    @IBOutlet private var distanceReading: UILabel!
    @IBOutlet private var beaconNameLabel: UILabel!
    @IBOutlet private var circleView: UIView!
    
    // MARK: - Private Properties
    
    private var locationManager: CLLocationManager?
    private var firstDetection = true
    private var currentBeaconUuid: UUID?
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        
        view.backgroundColor = .gray
        circleView.transform = .init(scaleX: 0.001, y: 0.001)
    }
    
    // MARK: - Private Methods
    
    private func startScanning() {
        addBeaconRegion(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5", major: 123, minor: 456, identifier: "MyBeacon1")
        addBeaconRegion(uuidString: "2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6", major: 123, minor: 456, identifier: "MyBeacon2")
        addBeaconRegion(uuidString: "92AB49BE-4127-42F4-B532-90fAF1E26491", major: 123, minor: 456, identifier: "MyBeacon3")
    }
    
    private func addBeaconRegion(uuidString: String, major: CLBeaconMajorValue, minor: CLBeaconMinorValue, identifier: String) {
        let beaconRegion = CLBeaconRegion(
            uuid: .init(uuidString: uuidString)!,
            major: major,
            minor: minor,
            identifier: identifier
        )
        
        locationManager?.startMonitoring(for: beaconRegion)
        locationManager?.startRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
    }
    
    private func update(distance: CLProximity, name: String) {
        UIView.animate(withDuration: 0.8) { [weak self] in
            guard let self else { return }
            self.beaconNameLabel.text = "Beacon name: \(name)"
            
            (self.view.backgroundColor, self.distanceReading.text, self.circleView.transform) = switch distance {
            case .immediate: (.blue, "FAR", .init(scaleX: 1, y: 1))
            case .near: (.orange, "NEAR", .init(scaleX: 0.5, y: 0.5))
            case .far: (.red, "RIGHT HERE", .init(scaleX: 0.25, y: 0.25))
            default: (.gray, "UNKNOWN", .init(scaleX: 0.001, y: 0.001))
            }
        }
    }
    
    private func showFirstDetectionAlert() {
        let alertController = UIAlertController(title: "Beacon detected", message: nil, preferredStyle: .alert)
        alertController.addAction(.init(title: "OK", style: .default))
        present(alertController, animated: true)
        firstDetection = false
    }
}

// MARK: - CLLocationManagerDelegate

extension ViewController: CLLocationManagerDelegate {
    @available(iOS 14.0, *)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        }
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didRange beacons: [CLBeacon],
        satisfying beaconConstraint: CLBeaconIdentityConstraint
    ) {
        if let beacon = beacons.first {
            if currentBeaconUuid == nil { currentBeaconUuid = beaconConstraint.uuid }
            guard currentBeaconUuid == beaconConstraint.uuid else { return }
            
            update(distance: beacon.proximity, name: beaconConstraint.uuid.uuidString)
            showFirstDetectionAlert()
        } else {
            guard currentBeaconUuid == beaconConstraint.uuid else { return }
            currentBeaconUuid = nil
            
            update(distance: .unknown, name: "Unknown")
        }
    }
}
