//
//  KeyboardViewController.swift
//  Custom keyboard extension for sharing memes
//

import UIKit

class KeyboardViewController: UIInputViewController {

    private var keyboardView: MemeKeyboardView!
    private var memes: [Meme] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Load cached memes from App Group
        loadMemes()

        // Create and configure keyboard view
        keyboardView = MemeKeyboardView(frame: .zero, memes: memes)
        keyboardView.translatesAutoresizingMaskIntoConstraints = false
        keyboardView.delegate = self

        view.addSubview(keyboardView)

        NSLayoutConstraint.activate([
            keyboardView.topAnchor.constraint(equalTo: view.topAnchor),
            keyboardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            keyboardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            keyboardView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            keyboardView.heightAnchor.constraint(equalToConstant: 280)
        ])
    }

    private func loadMemes() {
        memes = FirebaseService.loadCachedMemes()
        print("Loaded \(memes.count) cached memes in keyboard")
    }

    override func textWillChange(_ textInput: UITextInput?) {
        // Called when text is about to change
    }

    override func textDidChange(_ textInput: UITextInput?) {
        // Called when text changes
    }
}

// MARK: - MemeKeyboardViewDelegate

extension KeyboardViewController: MemeKeyboardViewDelegate {
    func didSelectMeme(_ meme: Meme) {
        // Load image from cache
        guard let image = ImageCache.shared.loadImage(forKey: meme.id) ??
                          ImageCache.shared.imageFromDataURL(meme.imageUrl) else {
            print("Failed to load image for meme: \(meme.id)")
            return
        }

        // Insert image into text
        insertImage(image)
    }

    func didRequestKeyboardSwitch() {
        // Switch to next keyboard
        advanceToNextInputMode()
    }

    private func insertImage(_ image: UIImage) {
        // Save to pasteboard so user can paste it
        UIPasteboard.general.image = image

        // Try to insert image directly if supported
        if let textDocumentProxy = self.textDocumentProxy as? UITextDocumentProxy {
            // Some apps support pasting images directly
            // For others, user will need to manually paste

            // Show feedback that image was copied
            AudioServicesPlaySystemSound(1519) // Peek haptic feedback
        }
    }
}

// MARK: - Import for haptic feedback

import AudioToolbox
