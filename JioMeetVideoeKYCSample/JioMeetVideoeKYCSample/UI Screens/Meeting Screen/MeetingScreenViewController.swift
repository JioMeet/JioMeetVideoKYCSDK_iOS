//
//  MeetingScreenViewController.swift
//  JioMeetVideoeKYCSample
//
//  Created by Rohit41.Kumar on 24/01/24.
//

import UIKit
import JioMeetCoreSDK
import JioMeetVideoKYCSDK

class MeetingScreenViewController: UIViewController {
	
	private var contentStackView = UIStackView()
	private var meetingView = JMMeetingView()
	
	private var actionButtonsStackView = UIStackView()
	private var demoActionsButton = UIButton()
	private var capturePhotoButton = UIButton()
	private var captureDocumentButton = UIButton()
	private var cancelActionButton = UIButton()
	
	private var isPhotoCaptureRequested = false
	private var isDocumentCaptureRequested = false
	
	private let identifier = UUID()
	
	internal var meetingId = ""
	internal var meetingPin = ""
	internal var userDisplayName = ""
	
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationController?.setNavigationBarHidden(true, animated: false)
		view.backgroundColor = .systemBackground
		
		configureSubViews()
		arrangeAllSubViews()
		configureSubViewsLayouts()
		setActionButtonsVisibility()
		
		let meetingData = JMJoinMeetingData(
			meetingId: self.meetingId,
			meetingPin: self.meetingPin,
			displayName: self.userDisplayName
		)
		let meetingConfig = JMJoinMeetingConfig(
			userRole: .speaker,
			isInitialAudioOn: true,
			isInitialVideoOn: true
		)
		meetingView.addMeetingEventsDelegate(delegate: self, identifier: identifier)
		meetingView.joinMeeting(data: meetingData, config: meetingConfig)
	}
	
	private func setActionButtonsVisibility() {
		if self.isPhotoCaptureRequested {
			self.demoActionsButton.isHidden = true
			self.capturePhotoButton.isHidden = false
			self.captureDocumentButton.isHidden = true
			self.cancelActionButton.isHidden = false
		} else if self.isDocumentCaptureRequested {
			self.demoActionsButton.isHidden = true
			self.capturePhotoButton.isHidden = true
			self.captureDocumentButton.isHidden = false
			self.cancelActionButton.isHidden = false
		} else {
			self.demoActionsButton.isHidden = false
			self.capturePhotoButton.isHidden = true
			self.captureDocumentButton.isHidden = true
			self.cancelActionButton.isHidden = true
		}
	}
	
	private func getDemoActionButtonMenu() -> UIMenu {
		let allActions: [UIAction] = [
			UIAction(title: "Leave Meeting", image: UIImage(systemName: "phone.down.fill"), attributes: .destructive) { _ in
				self.isPhotoCaptureRequested = false
				self.isDocumentCaptureRequested = false
				self.setActionButtonsVisibility()
				self.meetingView.leaveMeeting()
			},
			UIAction(title: "Flip Camera", image: UIImage(systemName: "camera.fill")) { _ in
				self.meetingView.switchCamera()
			},
			UIAction(title: "Request Document Capture", image: UIImage(systemName: "doc.circle.fill")) { _ in
				self.isPhotoCaptureRequested = false
				self.isDocumentCaptureRequested = true
				self.setActionButtonsVisibility()
				self.meetingView.showDocumentCaptureOverlay()
			},
			UIAction(title: "Request Photo Capture", image: UIImage(systemName: "person.crop.circle.fill")) { _ in
				self.isDocumentCaptureRequested = false
				self.isPhotoCaptureRequested = true
				self.setActionButtonsVisibility()
				self.meetingView.showFaceCaptureOverlay()
			},
		]
		return UIMenu(title: "Select Action", image: nil, identifier: nil, options: [], children: allActions)
	}
	
	private func showMeetingJoinError(message: String) {
		let errorAlert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
		let okAction = UIAlertAction(title: "Ok", style: .default) {[weak self] _ in
			self?.navigationController?.popViewController(animated: true)
		}
		errorAlert.addAction(okAction)
		present(errorAlert, animated: true)
	}
}

// MARK: - Buttons Actions
extension MeetingScreenViewController {
	@objc private func didPressCancelButton(sender: UIButton) {
		self.isPhotoCaptureRequested = false
		self.isDocumentCaptureRequested = false
		self.setActionButtonsVisibility()
		self.meetingView.removeCurrentOverlay()
	}
	
	@objc private func didPressCapturePhotoButton(sender: UIButton) {
		self.isPhotoCaptureRequested = false
		self.isDocumentCaptureRequested = false
		self.setActionButtonsVisibility()
		self.meetingView.takePhotoSnapshot {[weak self] (image) in
			guard let strongSelf = self else { return }
			strongSelf.view.viewWithTag(7500)?.removeFromSuperview()
			guard let strongImage = image else { return }
			let resultView = SnapshotResultView()
			resultView.tag = 7500
			resultView.translatesAutoresizingMaskIntoConstraints = false
			strongSelf.view.addSubview(resultView)
			NSLayoutConstraint.activate([
				resultView.leadingAnchor.constraint(equalTo: strongSelf.view.leadingAnchor),
				resultView.trailingAnchor.constraint(equalTo: strongSelf.view.trailingAnchor),
				resultView.topAnchor.constraint(equalTo: strongSelf.view.topAnchor),
				resultView.bottomAnchor.constraint(equalTo: strongSelf.view.bottomAnchor),
			])
			resultView.setResultImage(image: strongImage)
		}
	}
	
	@objc private func didPressCaptureDocumentButton(sender: UIButton) {
		self.isPhotoCaptureRequested = false
		self.isDocumentCaptureRequested = false
		self.setActionButtonsVisibility()
		self.meetingView.takeDocumentSnapshot {[weak self] (image) in
			guard let strongSelf = self else { return }
			strongSelf.view.viewWithTag(7500)?.removeFromSuperview()
			guard let strongImage = image else { return }
			let resultView = SnapshotResultView()
			resultView.tag = 7500
			resultView.translatesAutoresizingMaskIntoConstraints = false
			strongSelf.view.addSubview(resultView)
			NSLayoutConstraint.activate([
				resultView.leadingAnchor.constraint(equalTo: strongSelf.view.leadingAnchor),
				resultView.trailingAnchor.constraint(equalTo: strongSelf.view.trailingAnchor),
				resultView.topAnchor.constraint(equalTo: strongSelf.view.topAnchor),
				resultView.bottomAnchor.constraint(equalTo: strongSelf.view.bottomAnchor),
			])
			resultView.setResultImage(image: strongImage)
		}
	}
}

// MARK: - JMClient Delegate Methods
extension MeetingScreenViewController: JMClientDelegate {
	func jmClient(_ meeting: JMMeeting, didLocalUserJoinedMeeting user: JMMeetingUser) {
		actionButtonsStackView.isHidden = false
	}
	
	func jmClient(_ meeting: JMMeeting, didLocalUserLeftMeeting reason: JMUserLeftReason) {
		self.navigationController?.popViewController(animated: true)
	}
	
	func jmClient(didLocalUserFailedToJoinMeeting error: JMMeetingJoinError) {
		var errorMessageString = "Unknown Error Occurred"
		
		switch error {
		case .invalidConfiguration:
			errorMessageString = "Failed to Get Configurations"
		case .invalidMeetingDetails:
			errorMessageString = "Invalid Meeting ID or PIN, Please check again."
		case .meetingExpired:
			errorMessageString = "This meeting has been expired."
		case .meetingLocked:
			errorMessageString = "Sorry, you cannot join this meeting because room is locked."
		case .failedToRegisterUser:
			errorMessageString = "Failed to Register User for Meeting."
		case .maxParticipantsLimit:
			errorMessageString = "Maximum Participant Limit has been reached for this meeting."
		case .failedToJoinCall(let errorMessage):
			errorMessageString = errorMessage
		case .other(let errorMessage):
			errorMessageString = errorMessage
		default: break
		}
		showMeetingJoinError(message: errorMessageString)
	}
}

// MARK: - Configure SubViews
extension MeetingScreenViewController {
	private func configureSubViews() {
		contentStackView.translatesAutoresizingMaskIntoConstraints = false
		contentStackView.axis = .vertical
		contentStackView.distribution = .fill
		contentStackView.alignment = .fill
		contentStackView.spacing = 0
		contentStackView.backgroundColor = .clear
		
		meetingView.translatesAutoresizingMaskIntoConstraints = false
		
		actionButtonsStackView.translatesAutoresizingMaskIntoConstraints = false
		actionButtonsStackView.axis = .horizontal
		actionButtonsStackView.distribution = .fillEqually
		actionButtonsStackView.alignment = .fill
		actionButtonsStackView.spacing = 5
		actionButtonsStackView.backgroundColor = .clear
		actionButtonsStackView.isHidden = true
		
		demoActionsButton.translatesAutoresizingMaskIntoConstraints = false
		demoActionsButton.backgroundColor = .systemBlue
		demoActionsButton.setTitleColor(.white, for: .normal)
		demoActionsButton.setTitle("Select Capture Action", for: .normal)
		demoActionsButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
		if #available(iOS 14.0, *) {
			demoActionsButton.menu = getDemoActionButtonMenu()
			demoActionsButton.showsMenuAsPrimaryAction = true
		} else {
			// Fallback on earlier versions
		}
		
		
		capturePhotoButton.translatesAutoresizingMaskIntoConstraints = false
		capturePhotoButton.backgroundColor = .systemGreen
		capturePhotoButton.setTitleColor(.white, for: .normal)
		capturePhotoButton.setTitle("Capture Photo", for: .normal)
		capturePhotoButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
		capturePhotoButton.addTarget(self, action: #selector(didPressCapturePhotoButton(sender:)), for: .touchUpInside)
		
		captureDocumentButton.translatesAutoresizingMaskIntoConstraints = false
		captureDocumentButton.backgroundColor = .systemGreen
		captureDocumentButton.setTitleColor(.white, for: .normal)
		captureDocumentButton.setTitle("Capture Document", for: .normal)
		captureDocumentButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
		captureDocumentButton.addTarget(self, action: #selector(didPressCaptureDocumentButton(sender:)), for: .touchUpInside)
		
		cancelActionButton.translatesAutoresizingMaskIntoConstraints = false
		cancelActionButton.backgroundColor = .systemRed
		cancelActionButton.setTitleColor(.white, for: .normal)
		cancelActionButton.setTitle("Cancel", for: .normal)
		cancelActionButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
		cancelActionButton.addTarget(self, action: #selector(didPressCancelButton(sender:)), for: .touchUpInside)
	}
	
	private func arrangeAllSubViews() {
		view.addSubview(contentStackView)
		
		contentStackView.addArrangedSubview(meetingView)
		contentStackView.addArrangedSubview(actionButtonsStackView)
		
		actionButtonsStackView.addArrangedSubview(demoActionsButton)
		actionButtonsStackView.addArrangedSubview(capturePhotoButton)
		actionButtonsStackView.addArrangedSubview(captureDocumentButton)
		actionButtonsStackView.addArrangedSubview(cancelActionButton)
	}
	
	private func configureSubViewsLayouts() {
		NSLayoutConstraint.activate([
			contentStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			contentStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			contentStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			contentStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
			
			actionButtonsStackView.heightAnchor.constraint(equalToConstant: 30)
		])
	}
}
