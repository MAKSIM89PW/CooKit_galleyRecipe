//
//  Presenter.swift
//  galleyRecipe
//
//  Created by Камиль Хакимов on 03.02.2023.
//

import UIKit
import RealmSwift
import Kingfisher

final class SearchViewController: GradientViewController {
    enum Localization {
        static let textLabelStub: String = "Try changing some\nsearch parameters"
        static let textLabelChar: String = "🤷️"
        static let headerLabelOnEmptyScreen: String = "No recipes found"
        static let placeholder: String = "UIKit Soup"
    }

    var presenter: SearchViewPresenterProtocol
    private var topConstraint: NSLayoutConstraint!

    // MARK: - UI Components
    let categoryCollectionView = ChipsCollectionView()
    let countryCollectionView = ChipsCollectionView()

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.sizeToFit()
        searchBar.placeholder = Localization.placeholder
        searchBar.searchBarStyle = .minimal
        searchBar.searchTextField.font = UIFont(name: "Poppins-Regular", size: 16)
        searchBar.setImage(UIImage(named: "Union"), for: UISearchBar.Icon.search, state: .normal)
        searchBar.searchTextField.borderStyle = .none
        searchBar.searchTextPositionAdjustment.horizontal = 10
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.backgroundColor = .clear
        searchBar.layer.cornerRadius = 16
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = UIColor.customBorderColor.cgColor
        return searchBar
    }()

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CustomTableViewCell.identifier)
        tableView.separatorStyle = .none
        if #available(iOS 15.0, *) { tableView.sectionHeaderTopPadding = 0.0 }
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.text = Localization.headerLabelOnEmptyScreen
        label.font = UIFont(name: "Poppins-Bold", size: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var characterLabel: UILabel = {
        let characterLabel = UILabel()
        characterLabel.text = Localization.textLabelChar
        characterLabel.font = UIFont(name: "Poppins-Bold", size: 100)
        characterLabel.textAlignment = .center
        characterLabel.translatesAutoresizingMaskIntoConstraints = false
        return characterLabel
    }()

    private lazy var textLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.textColor = .textColor
        textLabel.font = UIFont(name: "Poppins-Regular", size: 16)
        textLabel.text = Localization.textLabelStub
        textLabel.adjustsFontSizeToFitWidth = true
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 0
        textLabel.lineBreakMode = .byWordWrapping
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        return textLabel
    }()

    private lazy var sortButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: ImageConstant.sortButton)
        button.setImage(image, for: .normal)
        button.backgroundColor = .clear
        button.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(tapToSortButton),
                         for: .touchUpInside)
        return button
    }()

    init(presenter: SearchViewPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        countryCollectionView.delegate = self
        countryCollectionView.dataSource = self
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self

        setLayout()
        presenter.setDeafaultChips()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    @objc
    func tapToSortButton() {
        UIView.animate(withDuration: 0.1,
                       animations: {
            self.sortButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        },
                       completion: { _ in
            UIView.animate(withDuration: 0.3) {
                self.sortButton.transform = CGAffineTransform.identity
            }
        })
    }
}
// MARK: - TableViewDelegate & TableViewDataSource
extension SearchViewController: UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return presenter.recipes?.count ?? 0 }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CustomTableViewCell.identifier,
                                                       for: indexPath) as?
                CustomTableViewCell else { return UITableViewCell() }
        cell.selectionStyle = .none

        guard let model = presenter.recipes?[indexPath.row] else { return UITableViewCell() }

        let favoriteButton = { [weak self] in
            guard let self = self else { return }
            self.presenter.saveOrDeleteFavoriteRecipe(id: model.id)
            cell.changeFavoriteButtonIcon(isFavorite: self.presenter.checkRecipeInRealm(id: model.id))
        }

        let timerButotn = {
        }

        cell.configure(recipeDescription: model.title,
                       imageUrlString: model.image,
                       favoriteButton: favoriteButton,
                       timerButotn: timerButotn,
                       isFavorite: presenter.checkRecipeInRealm(id: model.id))

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.tapOnTheRecipe()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return .recipeTableViewCellHeigh }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let totalResults = presenter.totalResults ?? 0
        var text = "No recipes found"

        if totalResults == 1 {
            text = "Found \(totalResults) recipe"
        } else if totalResults > 1 {
            text = "Found \(totalResults) recipes"
        }

        let headerView = setTableViewHeader(width: tableView.frame.width,
                                            height: .tableViewHeader,
                                            text: text)
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return .tableViewHeader }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0

        UIView.animate(
            withDuration: 0.1,
            delay: 0.0001 * Double(indexPath.row),
            animations: {
                cell.alpha = 1
        })
    }
    // MARK: - scrollView Methods
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) { searchBar.resignFirstResponder() }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.alpha = 0
        sortButton.alpha = 0
        categoryCollectionView.alpha = 0
        countryCollectionView.alpha = 0

        if scrollView.contentOffset.y < 100 {
            searchBar.alpha = 1 - (scrollView.contentOffset.y * 0.01)
            sortButton.alpha = 1 - (scrollView.contentOffset.y * 0.01)
            categoryCollectionView.alpha = 1 - (scrollView.contentOffset.y * 0.02)
            countryCollectionView.alpha = 1 - (scrollView.contentOffset.y * 0.05)
        }
    }
}
// MARK: - ChipsCollectionViewDelegate&DataSource
extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.countryCollectionView {
            return presenter.getCuisineObjs().count
        } else {
            return presenter.getMealObjs().count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.countryCollectionView {
            guard let countryCell = countryCollectionView.dequeueReusableCell(withReuseIdentifier: ChipsCollectionViewCell.identifier,
                                                                              for: indexPath) as? ChipsCollectionViewCell else { return UICollectionViewCell() }
            countryCell.configure(with: presenter.getCuisineObjs()[indexPath.item].cuisineFlag, cellIsselected: presenter.getCuisineObjs()[indexPath.item].isSelectedCell)
            return countryCell
        } else {
            guard let categoryCell = categoryCollectionView.dequeueReusableCell(withReuseIdentifier: ChipsCollectionViewCell.identifier,
                                                                                for: indexPath) as? ChipsCollectionViewCell else { return UICollectionViewCell() }
            categoryCell.configure(with: presenter.getMealObjs()[indexPath.item].mealType, cellIsselected: presenter.getMealObjs()[indexPath.item].isSelectedCell)
            return categoryCell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.categoryCollectionView {
            presenter.updateMealItem(indexPath: indexPath.item)
            let item = presenter.getMealObjs()[indexPath.item]
            presenter.updateMealQueryItems(key: .mealType, itemValue: item.mealType, append: item.isSelectedCell)
        } else {
            presenter.updateCuisineItem(indexPath: indexPath.item)
            let item = presenter.getCuisineObjs()[indexPath.item]
            presenter.updateMealQueryItems(key: .countryType, itemValue: item.cuisine, append: item.isSelectedCell)
        }
        collectionView.reloadData()
    }
}
// MARK: - ChipsCollectionViewDelegateFlowLayout
extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayaut: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let categoryFont = UIFont(name: "Poppins-Regular", size: 14)
        let categoryAttributes = [NSAttributedString.Key.font: categoryFont as Any]
        if collectionView == self.countryCollectionView {
            let countryWidth = presenter.getCuisineObjs()[indexPath.item].cuisineFlag.size(withAttributes: categoryAttributes).width + .collectionViewCellHeigh
            return CGSize(width: countryWidth, height: collectionView.frame.height)
        } else {
            let categoryWidth = presenter.getMealObjs()[indexPath.item].mealType.size(withAttributes: categoryAttributes).width + .collectionViewCellHeigh
            return CGSize(width: categoryWidth, height: collectionView.frame.height)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { return .spaceBetweenCollectionCell }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat { return .spaceBetweenCollectionCell }
}
// MARK: - SeachBarDelegate
extension SearchViewController: UISearchBarDelegate {

}
// MARK: - View Protocol
extension SearchViewController: SearchViewProtocol {
    func success() {
        tableView.reloadData()

        if presenter.recipes?.count != 0 {
            UIView.animate(withDuration: 0.2) {
                self.tableView.isScrollEnabled = true
                self.characterLabel.alpha = 0
                self.textLabel.alpha = 0
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.tableView.isScrollEnabled = false
                self.characterLabel.alpha = 1
                self.textLabel.alpha = 1
            }
        }
    }

    func failure(error: Error) {
        print(error.localizedDescription)
    }
}
// MARK: - set up UI
extension SearchViewController {

    func setLayout() {
        let tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: CGFloat.advancedTableViewHeader))
        tableHeaderView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)
        tableHeaderView.addSubview(searchBar)
        tableHeaderView.addSubview(categoryCollectionView)
        tableHeaderView.addSubview(countryCollectionView)
        tableHeaderView.addSubview(sortButton)
        view.addSubview(tableHeaderView)
        categoryCollectionView.translatesAutoresizingMaskIntoConstraints = false
        countryCollectionView.translatesAutoresizingMaskIntoConstraints = false

        navigationController?.navigationBar.showsLargeContentViewer = false
        tableView.tableHeaderView = tableHeaderView

        view.addSubview(characterLabel)
        view.addSubview(textLabel)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: .smallTopAndBottomInset),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),

            tableHeaderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableHeaderView.heightAnchor.constraint(equalToConstant: .advancedTableViewHeader),

            searchBar.leftAnchor.constraint(equalTo: tableHeaderView.leftAnchor, constant: .mediemLeftRightInset),
            sortButton.leftAnchor.constraint(equalTo: searchBar.rightAnchor, constant: .sortButtonLeftAnchor),
            searchBar.topAnchor.constraint(equalTo: tableHeaderView.topAnchor, constant: .smallTopAndBottomInset),
            searchBar.heightAnchor.constraint(equalToConstant: .searchBarHeight),

            sortButton.topAnchor.constraint(equalTo: tableHeaderView.topAnchor, constant: .headerLabelTopAnchor),
            tableHeaderView.rightAnchor.constraint(equalTo: sortButton.rightAnchor, constant: .mediemLeftRightInset),
            sortButton.leftAnchor.constraint(equalTo: searchBar.rightAnchor, constant: .sortButtonLeftAnchor),
            sortButton.heightAnchor.constraint(equalToConstant: .sortButtonHeighAnchor),

            categoryCollectionView.leadingAnchor.constraint(equalTo: tableHeaderView.leadingAnchor),
            categoryCollectionView.trailingAnchor.constraint(equalTo: tableHeaderView.trailingAnchor),
            categoryCollectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: .smallTopAndBottomInset),
            categoryCollectionView.heightAnchor.constraint(equalToConstant: .collectionViewCellHeigh),

            countryCollectionView.leadingAnchor.constraint(equalTo: tableHeaderView.leadingAnchor),
            countryCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            countryCollectionView.topAnchor.constraint(equalTo: categoryCollectionView.bottomAnchor, constant: .smallTopAndBottomInset),
            countryCollectionView.heightAnchor.constraint(equalToConstant: .collectionViewCellHeigh),

            view.centerYAnchor.constraint(equalTo: characterLabel.centerYAnchor, constant: .characterXAnchor - .collectionViewCellHeigh * 2 - .smallTopAndBottomInset * 2),
            characterLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            textLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: textLabel.trailingAnchor),
            textLabel.topAnchor.constraint(equalTo: characterLabel.bottomAnchor)
        ])
    }
}
