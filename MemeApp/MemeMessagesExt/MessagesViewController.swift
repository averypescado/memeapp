//
//  MessagesViewController.swift
//  iMessage Extension for sharing memes
//

import UIKit
import Messages

class MessagesViewController: MSMessagesAppViewController {

    private var memes: [Meme] = []
    private var collectionView: UICollectionView!
    private var searchBar: UISearchBar!
    private var filteredMemes: [Meme] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        loadMemes()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        // Search bar
        searchBar = UISearchBar()
        searchBar.placeholder = "Search memes..."
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)

        // Collection view layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

        // Calculate item size based on screen width (3 columns)
        let screenWidth = UIScreen.main.bounds.width
        let itemWidth = (screenWidth - 32) / 3  // 32 = padding (8*4)
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MemeCell.self, forCellWithReuseIdentifier: "MemeCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        // Constraints
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func loadMemes() {
        // Load cached memes from App Group
        if let data = AppGroup.shared.data(forKey: AppGroup.Keys.cachedMemes),
           let cachedMemes = try? JSONDecoder().decode([Meme].self, from: data) {
            memes = cachedMemes
            filteredMemes = cachedMemes
            collectionView.reloadData()
        }
    }

    private func insertMeme(_ meme: Meme) {
        guard let conversation = activeConversation else { return }

        // Load image from cache or data URL
        guard let image = ImageCache.shared.loadImage(forKey: meme.id) ??
                          ImageCache.shared.imageFromDataURL(meme.imageUrl) else {
            print("Failed to load image for meme: \(meme.id)")
            return
        }

        // Convert to PNG data
        guard let imageData = image.pngData() else { return }

        // Create a temporary file URL
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("png")

        do {
            // Write image to temp file
            try imageData.write(to: tempURL)

            // Insert as file attachment (sends as regular image)
            conversation.insertAttachment(tempURL, withAlternateFilename: "meme.png") { error in
                if let error = error {
                    print("Error inserting attachment: \(error)")
                }
                // Clean up temp file
                try? FileManager.default.removeItem(at: tempURL)
            }

            // Dismiss the extension
            requestPresentationStyle(.compact)
        } catch {
            print("Error writing image: \(error)")
        }
    }
}

// MARK: - UISearchBarDelegate

extension MessagesViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredMemes = memes
        } else {
            filteredMemes = memes.filter { meme in
                meme.tags.contains { $0.lowercased().contains(searchText.lowercased()) } ||
                meme.sourceUrl.lowercased().contains(searchText.lowercased())
            }
        }
        collectionView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - UICollectionViewDataSource

extension MessagesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if filteredMemes.isEmpty {
            // Show empty state
            let label = UILabel()
            label.text = "No memes yet!\nSave memes from Chrome to see them here."
            label.textAlignment = .center
            label.textColor = .gray
            label.numberOfLines = 0
            label.font = .systemFont(ofSize: 16)
            collectionView.backgroundView = label
        } else {
            collectionView.backgroundView = nil
        }

        return filteredMemes.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemeCell", for: indexPath) as! MemeCell
        let meme = filteredMemes[indexPath.item]
        cell.configure(with: meme)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension MessagesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let meme = filteredMemes[indexPath.item]
        insertMeme(meme)
    }
}

// MARK: - MemeCell

class MemeCell: UICollectionViewCell {
    private let imageView = UIImageView()
    private let favoriteIcon = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false

        favoriteIcon.image = UIImage(systemName: "star.fill")
        favoriteIcon.tintColor = .systemYellow
        favoriteIcon.translatesAutoresizingMaskIntoConstraints = false
        favoriteIcon.isHidden = true

        contentView.addSubview(imageView)
        contentView.addSubview(favoriteIcon)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            favoriteIcon.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            favoriteIcon.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            favoriteIcon.widthAnchor.constraint(equalToConstant: 20),
            favoriteIcon.heightAnchor.constraint(equalToConstant: 20)
        ])
    }

    func configure(with meme: Meme) {
        // Try loading from cache
        if let cachedImage = ImageCache.shared.loadImage(forKey: meme.id) {
            imageView.image = cachedImage
        } else if let image = ImageCache.shared.imageFromDataURL(meme.thumbnailUrl) {
            imageView.image = image
            ImageCache.shared.saveImage(image, forKey: meme.id)
        } else {
            imageView.image = nil
        }

        favoriteIcon.isHidden = !meme.favorite
    }
}
