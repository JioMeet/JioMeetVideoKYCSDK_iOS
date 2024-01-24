//
//  JoinMeetingScreenViewController.swift
//  JioMeetVideoeKYCSample
//
//  Created by Rohit41.Kumar on 24/01/24.
//

import UIKit
import AVFoundation

class JoinMeetingScreenViewController: UIViewController {

	// MARK: - SubViews
	private var contentStackView = UIStackView()
	private var meetingIdInputView = JoinInputDataView()
	private var meetingPinInputView = JoinInputDataView()
	private var userNameInputView = JoinInputDataView()
	private var joinButton = UIButton()

	// MARK: - UI Properties
	private var contentStackViewCenterYConstraints: NSLayoutConstraint!
	
	// MARK: - Properties
	private var isCameraAllowed = false
	private var isMicAllowed = false
	private var identifier = UUID()
	var hostToken = ""
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.navigationController?.setNavigationBarHidden(true, animated: false)
		configureSubViews()
		arrangeAllSubViews()
		configureSubViewsLayouts()
		
		meetingIdInputView.updateTextFieldText("")
		meetingPinInputView.updateTextFieldText("")
		userNameInputView.updateTextFieldText("")
    }
}


// MARK: - Selector Methods
extension JoinMeetingScreenViewController {
	@objc private func didPressJoinButton(sender: UIButton) {
		view.endEditing(true)
		// Check Mic and Camera Permissions
		getAudioVideoAuthorization {[weak self] (isCameraAllowed, isMicAllowed, isFirstTime) in
			self?.isCameraAllowed = isCameraAllowed
			self?.isMicAllowed = isMicAllowed
			guard isCameraAllowed && isMicAllowed else {
				self?.showMicCameraErrorAlert()
				return
			}
			self?.validateMeetingDetails()
		}
	}
	
	private func validateMeetingDetails() {
		let meetingIDValidateResult = meetingIdInputView.validateData()
		let meetingPinValidateResult = meetingPinInputView.validateData()
		let userNameValidateResult = userNameInputView.validateData()
		
		guard meetingIDValidateResult, meetingPinValidateResult, userNameValidateResult else {
			if meetingIDValidateResult == false {
				meetingIdInputView.showErrorInValidation()
			} else {
				meetingIdInputView.removeError()
			}
			
			if meetingPinValidateResult == false {
				meetingPinInputView.showErrorInValidation()
			} else {
				meetingPinInputView.removeError()
			}
			
			if userNameValidateResult == false {
				userNameInputView.showErrorInValidation()
			} else {
				userNameInputView.removeError()
			}
			// Show Validation
			showError(message: "Please check input data")
			return
		}
		
		meetingIdInputView.removeError()
		meetingPinInputView.removeError()
		userNameInputView.removeError()
		self.joinMeeting()
	}
	
	private func joinMeeting() {
		
		let meetingViewController = MeetingScreenViewController()
		meetingViewController.meetingId = meetingIdInputView.getText()
		meetingViewController.meetingPin = meetingPinInputView.getText()
		meetingViewController.userDisplayName = userNameInputView.getText()
		navigationController?.pushViewController(meetingViewController, animated: true)
	}
}

// MARK: - UI Helper Methods
extension JoinMeetingScreenViewController {
	private func showError(message: String) {
		let errorAlert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
		let okAction = UIAlertAction(title: "Ok", style: .default)
		errorAlert.addAction(okAction)
		present(errorAlert, animated: true)
	}
	
	private func showMicCameraErrorAlert() {
		let errorAlert = UIAlertController(
			title: "Camera Mic Permission Error",
			message: "You have not granted Mic and Camera Permission. Please provide.",
			preferredStyle: .alert
		)
		let cancelAction = UIAlertAction(title: "Cancel", style: .default)
		let settingsAction = UIAlertAction(title: "Open Settings", style: .default) { _ in
			guard let appSettingURL = URL(string: UIApplication.openSettingsURLString) else { return }
			guard UIApplication.shared.canOpenURL(appSettingURL) else { return }
			UIApplication.shared.open(appSettingURL)
		}
		errorAlert.addAction(cancelAction)
		errorAlert.addAction(settingsAction)
		present(errorAlert, animated: true)
	}
	
	private func getAudioVideoAuthorization(completion: @escaping ((_ isCameraAllowed: Bool, _ isMicAllowed: Bool, _ isFirstTime: Bool) -> Void)) {
		getVideoAuthorization(completion: {(isSuccess, isFirstTime) in
			let cameraAccess = isSuccess
			self.getAudioAuthorization(completion: {(isSuccess) in
				let micAccess = isSuccess
				completion(cameraAccess, micAccess, isFirstTime)
			})
		})
	}
	
	private func getVideoAuthorization(completion: @escaping (_ isAuthorized: Bool, _ isFirstTime: Bool) -> Void) {
		AVCaptureDevice.authorizeVideo(completion: {(status) in
			switch status {
			case .justAuthorized:
				completion(true, true)
			case .alreadyAuthorized:
				completion(true, false)
			case .justDenied:
				completion(false, true)
			case .alreadyDenied, .restricted:
				completion(false, false)
			default:
				completion(false, false)
			}
		})
	}
	
	private func getAudioAuthorization(completion: @escaping (_ isAuthorized: Bool) -> Void) {
		AVCaptureDevice.authorizeAudio(completion: {(status) in
			switch status {
			case .justAuthorized, .alreadyAuthorized:
				completion(true)
			default:
				completion(false)
			}
		})
	}
}

// MARK: - Configure SubViews
extension JoinMeetingScreenViewController {
	private func configureSubViews() {
		contentStackView.translatesAutoresizingMaskIntoConstraints = false
		contentStackView.axis = .vertical
		contentStackView.distribution = .fill
		contentStackView.spacing = 20
		contentStackView.alignment = .center
		contentStackView.backgroundColor = .clear
		
		meetingIdInputView.translatesAutoresizingMaskIntoConstraints = false
		meetingIdInputView.backgroundColor = .clear
		meetingIdInputView.setInputData(
			label: "Meeting ID",
			placeHolder: "Enter meeting id",
			keyboardType: .numberPad
		)
		meetingIdInputView.setValidator(validator: "^\\d{10}$")
		meetingIdInputView.updateTextFieldText(meetingIdInputView.getText())
		
		meetingPinInputView.translatesAutoresizingMaskIntoConstraints = false
		meetingPinInputView.backgroundColor = .clear
		meetingPinInputView.setInputData(
			label: "Password",
			placeHolder: "Enter password",
			keyboardType: .namePhonePad
		)
		meetingPinInputView.setValidator(validator: "^\\w{5}$")
		meetingPinInputView.updateTextFieldText(meetingPinInputView.getText())
		
		userNameInputView.translatesAutoresizingMaskIntoConstraints = false
		userNameInputView.backgroundColor = .clear
		userNameInputView.setInputData(
			label: "Name",
			placeHolder: "Enter name",
			keyboardType: .namePhonePad
		)
		userNameInputView.setValidator(validator: "^[a-zA-Z0-9 ]{2,45}")
		userNameInputView.updateTextFieldText(userNameInputView.getText())
		
		joinButton.translatesAutoresizingMaskIntoConstraints = false
		joinButton.backgroundColor = UIColor(hexString: "#2143DB")
		joinButton.setTitle("Join", for: .normal)
		joinButton.setTitleColor(.white, for: .normal)
		joinButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
		joinButton.layer.masksToBounds = true
		joinButton.layer.cornerRadius = 25
		joinButton.addTarget(self, action: #selector(didPressJoinButton(sender:)), for: .touchUpInside)
	}
	
	private func arrangeAllSubViews() {
		view.addSubview(contentStackView)
		
		contentStackView.addArrangedSubview(meetingIdInputView)
		contentStackView.addArrangedSubview(meetingPinInputView)
		contentStackView.addArrangedSubview(userNameInputView)
		contentStackView.addArrangedSubview(joinButton)
	}
	
	private func configureSubViewsLayouts() {
		contentStackViewCenterYConstraints = contentStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100)
		
		NSLayoutConstraint.activate([
			contentStackViewCenterYConstraints,
			contentStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			contentStackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
			
			meetingIdInputView.widthAnchor.constraint(equalTo: contentStackView.widthAnchor, multiplier: 1, constant: -50),
			meetingPinInputView.widthAnchor.constraint(equalTo: contentStackView.widthAnchor, multiplier: 1, constant: -50),
			userNameInputView.widthAnchor.constraint(equalTo: contentStackView.widthAnchor, multiplier: 1, constant: -50),
			
			joinButton.widthAnchor.constraint(equalTo: contentStackView.widthAnchor, multiplier: 1, constant: -50),
			joinButton.heightAnchor.constraint(equalToConstant: 50),
		])
	}
}
