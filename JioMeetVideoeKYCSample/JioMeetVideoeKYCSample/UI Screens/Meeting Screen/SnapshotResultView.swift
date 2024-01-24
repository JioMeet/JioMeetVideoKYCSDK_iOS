//
//  SnapshotResultView.swift
//  JioMeetVideoeKYCSample
//
//  Created by Rohit41.Kumar on 24/01/24.
//

import Foundation
import UIKit
import Photos

class SnapshotResultView: UIView {
	private var contentStackView = UIStackView()
	private var resultImageView = UIImageView()
	private var saveToGalleryButton = UIButton()
	private var closeButton = UIButton()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		commonInit()
	}
	
	private func commonInit() {
		backgroundColor = UIColor.black.withAlphaComponent(0.65)
		configureSubViews()
		arrangeAllSubViews()
		configureSubViewsLayouts()
	}
	
	@objc private func didPressCloseButton(sender: UIButton) {
		resultImageView.image = nil
		removeFromSuperview()
	}
	
	@objc private func didPressSaveToGalleryButton(sender: UIButton) {
		if let savedImage = resultImageView.image {
			UIImageWriteToSavedPhotosAlbum(savedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
		}
		resultImageView.image = nil
		removeFromSuperview()
	}
	
	// Called when image save is complete (with error or not)
	@objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
		if let error = error {
			print("ERROR: \(error)")
		}
		else {
			self.showAlert("Image saved", message: "The image is saved into your Photo Library.")
		}
	}
	
	private func showAlert(_ title: String, message: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		findViewController()?.present(alert, animated: true)
	}
}

// MARK: - Data Methods
extension SnapshotResultView {
	func setResultImage(image: UIImage) {
		resultImageView.image = image
		
		let maxHeightForImage = UIScreen.main.bounds.height * 0.65
		let imageViewWidth = (image.size.width * maxHeightForImage) / image.size.height
		
		NSLayoutConstraint.activate([
			resultImageView.widthAnchor.constraint(equalToConstant: imageViewWidth),
			resultImageView.heightAnchor.constraint(equalToConstant: maxHeightForImage)
		])
		self.contentStackView.layoutIfNeeded()
	}
}

// MARK: - Configure SubViews
extension SnapshotResultView {
	private func configureSubViews() {
		contentStackView.translatesAutoresizingMaskIntoConstraints = false
		contentStackView.axis = .vertical
		contentStackView.distribution = .fill
		contentStackView.alignment = .center
		contentStackView.spacing = 20
		contentStackView.backgroundColor = .darkGray
		contentStackView.layer.masksToBounds = true
		contentStackView.layer.cornerRadius = 15
		
		resultImageView.translatesAutoresizingMaskIntoConstraints = false
		resultImageView.contentMode = .scaleAspectFit
		resultImageView.backgroundColor = .clear
		resultImageView.layer.masksToBounds = true
		
		saveToGalleryButton.translatesAutoresizingMaskIntoConstraints = false
		saveToGalleryButton.setTitle("Save to Gallery", for: .normal)
		saveToGalleryButton.setTitleColor(.white, for: .normal)
		saveToGalleryButton.backgroundColor = .systemBlue
		saveToGalleryButton.addTarget(self, action: #selector(didPressSaveToGalleryButton(sender:)), for: .touchUpInside)
		
		closeButton.translatesAutoresizingMaskIntoConstraints = false
		closeButton.setTitle("Close", for: .normal)
		closeButton.setTitleColor(.white, for: .normal)
		closeButton.backgroundColor = .systemBlue
		closeButton.addTarget(self, action: #selector(didPressCloseButton(sender:)), for: .touchUpInside)
	}
	
	private func arrangeAllSubViews() {
		addSubview(contentStackView)
		
		contentStackView.addArrangedSubview(resultImageView)
		contentStackView.addArrangedSubview(saveToGalleryButton)
		contentStackView.addArrangedSubview(closeButton)
		
	}
	
	private func configureSubViewsLayouts() {
		NSLayoutConstraint.activate([
			contentStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
			contentStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
			
			closeButton.widthAnchor.constraint(equalToConstant: 200),
			closeButton.heightAnchor.constraint(equalToConstant: 40),
			
			saveToGalleryButton.widthAnchor.constraint(equalToConstant: 200),
			saveToGalleryButton.heightAnchor.constraint(equalToConstant: 40)
		])
	}
}


extension UIView {
	func findViewController() -> UIViewController? {
		if let nextResponder = next as? UIViewController {
			return nextResponder
		} else if let nextResponder = next as? UIView {
			return nextResponder.findViewController()
		} else {
			return nil
		}
	}
}
