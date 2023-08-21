//
//  SearchViewController.swift
//  Soshiki
//
//  Created by Jim Phieffer on 1/29/23.
//

import UIKit

class SearchViewController_Old: UICollectionViewController {
    var observers: [NSObjectProtocol] = []

    let refreshControl = UIRefreshControl()

    var dataSource: UICollectionViewDiffableDataSource<Int, Entry_Old>!

    var entries: [Entry_Old] = []
    var offset = 0
    var loadTask: Task<Void, Never>?
    var hasMore = true

    var currentSearch: String = ""

    let searchController = UISearchController(searchResultsController: nil)

    let mediaTypeButton = UIButton()
    let mediaTypeLabel = UILabel()

    init() {
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { _, environment in
            let itemsPerRow = UserDefaults.standard.object(forKey: "app.settings.itemsPerRow") as? Int ?? 3
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(environment.container.contentSize.width / CGFloat(itemsPerRow) * 1.5 + 40)
                ),
                subitem: NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(CGFloat(1) / CGFloat(itemsPerRow)),
                        heightDimension: .estimated(environment.container.contentSize.width / CGFloat(itemsPerRow) * 1.5 + 40)
                    )
                ),
                count: itemsPerRow
            )
            group.interItemSpacing = .fixed(16)
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 16
            section.contentInsets = NSDirectionalEdgeInsets(all: 8)
            return section
        })
        let config = UICollectionViewCompositionalLayoutConfiguration()
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(25)
            ),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        config.boundarySupplementaryItems = [ header ]
        layout.configuration = config
        super.init(collectionViewLayout: layout)

        self.title = "Search"

        let cellRegistration: UICollectionView.CellRegistration<EntryCollectionViewCell, Entry_Old> = .init(handler: { _, _, _ in
            // cell.setEntry(to: entry.toSourceEntry())
        })
        self.dataSource = UICollectionViewDiffableDataSource(
            collectionView: self.collectionView,
            cellProvider: { collectionView, indexPath, itemIdentifier in
                collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
            }
        )

        let registration = UICollectionView.SupplementaryRegistration<UICollectionReusableView>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { [weak self] headerView, _, _ in
            guard let self else { return }
            let titleLabel = UILabel()
            titleLabel.text = "Media Type"
            titleLabel.textColor = .secondaryLabel
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            headerView.addSubview(titleLabel)
            headerView.addSubview(self.mediaTypeLabel)
            headerView.addSubview(self.mediaTypeButton)
            titleLabel.leadingAnchor.constraint(equalTo: headerView.layoutMarginsGuide.leadingAnchor, constant: 8).isActive = true
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
            self.mediaTypeLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 5).isActive = true
            self.mediaTypeLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
            self.mediaTypeButton.leadingAnchor.constraint(equalTo: self.mediaTypeLabel.trailingAnchor, constant: 5).isActive = true
            self.mediaTypeButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        }
        self.dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            if kind == UICollectionView.elementKindSectionHeader {
                return collectionView.dequeueConfiguredReusableSupplementary(using: registration, for: indexPath)
            } else {
                return nil
            }
        }

        self.collectionView.dataSource = self.dataSource

        self.refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        self.collectionView.refreshControl = self.refreshControl

        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.searchController.searchResultsUpdater = self
        self.navigationItem.searchController = searchController

        mediaTypeButton.translatesAutoresizingMaskIntoConstraints = false
        mediaTypeButton.showsMenuAsPrimaryAction = true
        mediaTypeButton.setImage(UIImage(systemName: "chevron.up.chevron.down"), for: .normal)

        mediaTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        // mediaTypeLabel.text = LibraryManager.shared.mediaType.rawValue.capitalized
        mediaTypeLabel.font = .systemFont(ofSize: 17, weight: .semibold)

        reloadMediaTypeMenu()

        refresh()

        observers.append(
            NotificationCenter.default.addObserver(forName: .init("app.settings.itemsPerRow"), object: nil, queue: nil) { [weak self] _ in
                Task { @MainActor in
                    self?.collectionViewLayout.invalidateLayout()
                }
            }
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        for observer in observers {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    func reloadCollectionViewData() {
        var snapshot = NSDiffableDataSourceSectionSnapshot<Entry_Old>()
        snapshot.append(entries)
        dataSource.apply(snapshot, to: 0, animatingDifferences: false)
    }

    func reloadMediaTypeMenu() {
        // mediaTypeLabel.text = LibraryManager.shared.mediaType.rawValue.capitalized
//        self.mediaTypeButton.menu = UIMenu(children: MediaType.allCases.map({ mediaType in
//            UIAction(
//                title: mediaType.rawValue.capitalized,
//                image: mediaType == LibraryManager.shared.mediaType ? UIImage(systemName: "checkmark") : nil
//            ) { [weak self] _ in
//                LibraryManager.shared.mediaType = mediaType
//                self?.refresh()
//                self?.reloadMediaTypeMenu()
//            }
//        }))
    }

    @objc func refresh(_ refreshControl: UIRefreshControl? = nil) {
        offset = 0
        hasMore = true
        loadTask?.cancel()
        loadTask = Task {
//            if let results = try? await SoshikiAPI.shared.getEntries(
//                mediaType: LibraryManager.shared.mediaType,
//                query: [
//                    .title(currentSearch),
//                    .limit(100),
//                    .offset(offset)
//                ]).get() {
//                entries = results
//                hasMore = !results.isEmpty
//                reloadCollectionViewData()
//            }
            refreshControl?.endRefreshing()
            self.loadTask = nil
        }
    }
}

extension SearchViewController_Old {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        self.navigationController?.pushViewController(
//            EntryViewController(entry: entries[indexPath.item]),
//            animated: true
//        )
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

extension SearchViewController_Old {
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if hasMore, loadTask == nil, scrollView.contentSize.height - view.bounds.height - scrollView.contentOffset.y < 500 {
            loadTask = Task {
//                if let results = try? await SoshikiAPI.shared.getEntries(
//                    mediaType: LibraryManager.shared.mediaType,
//                    query: [
//                        .title(currentSearch),
//                        .limit(100),
//                        .offset(offset)
//                    ]).get() {
//                    self.entries.append(contentsOf: results)
//                    self.entries = self.entries.removingDuplicates()
//                    self.hasMore = !results.isEmpty
//                    self.reloadCollectionViewData()
//                }
                self.loadTask = nil
            }
        }
    }
}

extension SearchViewController_Old: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.currentSearch = searchController.searchBar.text ?? ""
        self.refresh()
    }
}
