//
//  IngredientsViewController.swift
//  galleyRecipe
//
//  Created by Philipp Zeppelin on 24.01.2023.
//

import UIKit

final class IngredientsViewController: GradientViewController {
    private let presenter: IngridientViewPresenterProtocol

    // MARK: - UI

    private let ingredientsTableView: UITableView = {
        let tableView = UITableView.init(frame: .zero, style: UITableView.Style.plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private let imageOnTop: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: ImageConstant.ingredientsImageOnTop)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let viewFromBottom: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 20.0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let ingredientLabel: UILabel = {
        let label = UILabel()
        label.text = TestingData.ingredientLabelText
        label.configureLabels()
        label.font = UIFont(name: "ArialRoundedMTBold", size: 24)
        label.shadowOffset = CGSize(width: 20, height: 20)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 1
        return stackView
    }()

    private let grayView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        view.layer.cornerRadius = 20.0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let ingredientsButton: UIButton = {
        let button = UIButton()
        button.setTitle(TestingData.ingredientsButtonText, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let instructionsButton: UIButton = {
        let button = UIButton()
        button.setTitle(TestingData.ingredientsButtonText, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: ImageConstant.arrowLeft), for: .normal)
        button.addTarget(self, action: #selector(tapBackButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    init(presenter: IngridientViewPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupConstraints()
        addSublabelsToStackView()

        ingredientsTableView.delegate = self
        ingredientsTableView.dataSource = self
        ingredientsTableView.register(IngredientsTableViewCell.self, forCellReuseIdentifier: IngredientsTableViewCell.identifier)
        ingredientsTableView.backgroundColor = .white
    }

    private func addSublabelsToStackView() {
        let waitingTime = UILabel()
        let servings = UILabel()
        let calories = UILabel()

        waitingTime.configureLabels()
        servings.configureLabels()
        calories.configureLabels()

        waitingTime.text = TestingData.waitingTimeText
        servings.text = TestingData.servingsText
        calories.text = TestingData.caloriesText
        stackView.addArrangedSubview(waitingTime)
        stackView.addArrangedSubview(servings)
        stackView.addArrangedSubview(calories)
    }

    @objc
    private func tapBackButton() {
        presenter.backButtonDidPressed()
    }
}
// MARK: - UITableViewDelegate, UITableViewDataSource

extension IngredientsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: IngredientsTableViewCell.identifier, for: indexPath)
        return cell
    }
    // высота ячейки
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
}
// MARK: - ViewProtocol
extension IngredientsViewController: IngridientViewProtocol {

}

// MARK: - Constraints
extension IngredientsViewController {

    private func setupConstraints() { // swiftlint:disable:this function_body_length
        view.addSubview(imageOnTop)
        NSLayoutConstraint.activate([
            imageOnTop.topAnchor.constraint(equalTo: view.topAnchor),
            imageOnTop.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageOnTop.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageOnTop.heightAnchor.constraint(equalToConstant: .ingredientsImageOnTopHeightAnchor)
        ])

        view.addSubview(viewFromBottom)
        NSLayoutConstraint.activate([
            viewFromBottom.topAnchor.constraint(equalTo: imageOnTop.bottomAnchor),
            viewFromBottom.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            viewFromBottom.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            viewFromBottom.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        imageOnTop.addSubview(ingredientLabel)
        NSLayoutConstraint.activate([
            ingredientLabel.bottomAnchor.constraint(equalTo: imageOnTop.bottomAnchor, constant: .ingredientsIngredientLabelAnchor),
            ingredientLabel.leadingAnchor.constraint(equalTo: imageOnTop.leadingAnchor, constant: .ingredientLabelTrailingAndLeadingAnchors),
            imageOnTop.trailingAnchor.constraint(equalTo: ingredientLabel.trailingAnchor, constant: .ingredientLabelTrailingAndLeadingAnchors),
            ingredientLabel.centerXAnchor.constraint(equalTo: imageOnTop.centerXAnchor)
        ])

        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: ingredientLabel.bottomAnchor, constant: .ingredientsStackViewTopAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .ingredientsStackViewTrailingAndLeadingAnchors),
            view.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: .ingredientsStackViewTrailingAndLeadingAnchors)
        ])

        viewFromBottom.addSubview(grayView)
        NSLayoutConstraint.activate([
            grayView.topAnchor.constraint(equalTo: viewFromBottom.topAnchor, constant: .ingredientsGrayViewTopAnchor),
            grayView.leadingAnchor.constraint(equalTo: viewFromBottom.leadingAnchor, constant: .ingredientsGrayViewTrailingAndLeadingAnchors),
            viewFromBottom.trailingAnchor.constraint(equalTo: grayView.trailingAnchor, constant: .ingredientsGrayViewTrailingAndLeadingAnchors),
            grayView.heightAnchor.constraint(equalToConstant: .ingredientsGrayViewHeightAnchor)
        ])

        viewFromBottom.addSubview(ingredientsButton)
        NSLayoutConstraint.activate([
            ingredientsButton.topAnchor.constraint(equalTo: grayView.bottomAnchor, constant: .ingredientsButtonTopAnchor),
            ingredientsButton.leadingAnchor.constraint(equalTo: viewFromBottom.leadingAnchor, constant: .ingredientsLeadingAnchor)
        ])

        viewFromBottom.addSubview(instructionsButton)
        NSLayoutConstraint.activate([
            instructionsButton.topAnchor.constraint(equalTo: grayView.bottomAnchor, constant: .instructionsButtonTopAnchor),
            viewFromBottom.trailingAnchor.constraint(equalTo: instructionsButton.trailingAnchor, constant: .instructionsButtonTrailingAnchor)
        ])

        viewFromBottom.addSubview(ingredientsTableView)
        NSLayoutConstraint.activate([
            ingredientsTableView.topAnchor.constraint(equalTo: grayView.bottomAnchor, constant: .ingredientsTableViewTopAnchor),
            ingredientsTableView.leadingAnchor.constraint(equalTo: grayView.leadingAnchor, constant: .ingredientsTableViewLeadingAndTrailingAnchors),
            grayView.trailingAnchor.constraint(equalTo: ingredientsTableView.trailingAnchor, constant: .ingredientsTableViewLeadingAndTrailingAnchors),
            ingredientsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        view.addSubview(backButton)
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            backButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: .ingredientsBackButtonLeftAnchor)
        ])
    }
}
