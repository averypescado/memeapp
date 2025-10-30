//
//  MemeKeyboardView.swift
//  UI for the keyboard extension
//

import UIKit

protocol MemeKeyboardViewDelegate: AnyObject {
    func didSelectMeme(_ meme: Meme)
    func didRequestKeyboardSwitch()
}

class MemeKeyboardView: UIView {

    weak var delegate: MemeKeyboardViewDelegate?

    private let memes: [Meme]
    private var collectionView: UICollectionView!
    private let searchBar = UISearchBar()
    private var filteredMemes: [Meme]

    init(frame: CGRect, memes: [Meme]) {
        self.memes = memes
        self.filteredMemes = memes
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .systemBackground

        // Header with search and keyboard switch button
        let headerStack = UIStackView()
        headerStack.axis = .horizontal
        headerStack.spacing = 8
        headerStack.translatesAutoresizingMaskIntoConstraints = false

        // Keyboard switch button
        let switchButton = UIButton(type: .system)
        switchButton.setImage(UIImage(systemName: "globe"), for: .normal)
        switchButton.addTarget(self, action: #selector(switchKeyboard), for: .touchUpInside)
        switchButton.translatesAutoresizingMaskIntoConstraints = false

        // Search bar
        searchBar.placeholder = "Search memes..."
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false

        headerStack.addArrangedSubview(switchButton)
        headerStack.addArrangedSubview(searchBar)

        addSubview(headerStack)

        // Collection view layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

        let itemWidth = (UIScreen.main.bounds.width - 32) / 3
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MemeCell.self, forCellWithReuseIdentifier: "MemeCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(collectionView)

        // Constraints
        NSLayoutConstraint.activate([
            switchButton.widthAnchor.constraint(equalToConstant: 44),

            headerStack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            headerStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            headerStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),

            collectionView.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    @objc private func switchKeyboard() {
        delegate?.didRequestKeyboardSwitch()
    }

    private func filterMemes(with searchText: String) {
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
}

// MARK: - UISearchBarDelegate

extension MemeKeyboardView: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterMemes(with: searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - UICollectionViewDataSource

extension MemeKeyboardView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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

extension MemeKeyboardView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let meme = filteredMemes[indexPath.item]
        delegate?.didSelectMeme(meme)
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
