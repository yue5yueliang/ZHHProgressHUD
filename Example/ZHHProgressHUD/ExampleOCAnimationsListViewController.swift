//
//  ExampleOCAnimationsListViewController.swift
//  ZHHProgressHUD
//
//  Created by 桃色三岁 on 2026/4/4.
//  Copyright © 2026 桃色三岁. All rights reserved.
//

import UIKit

extension ExampleOCAnimationKind: CaseIterable {
    public static var allCases: [ExampleOCAnimationKind] {
        [.system, .circle, .imperfect, .half, .gradient, .pulse, .asymmetric]
    }
}

/// 加载动画列表：点选进入单独预览页（OC 独立实现 / Swift 库内抽取，由导航栏切换）
final class ExampleOCAnimationsListViewController: UIViewController {

    /// `false` 为 OC 实现（默认），`true` 为 Swift（ZHHActivityIndicator 抽取）
    private var useSwiftImplementation = false {
        didSet { updateSourceToggleItem() }
    }

    private let tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .insetGrouped)
        t.backgroundColor = .secondarySystemBackground
        return t
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "加载动画"
        view.backgroundColor = .secondarySystemBackground
        configNavigationBarAppearance()
        updateSourceToggleItem()
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func configNavigationBarAppearance() {
        guard let bar = navigationController?.navigationBar else { return }
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .secondarySystemBackground
        bar.standardAppearance = appearance
        bar.scrollEdgeAppearance = appearance
        bar.compactAppearance = appearance
        bar.compactScrollEdgeAppearance = appearance
    }

    private func updateSourceToggleItem() {
        let label = useSwiftImplementation ? "Swift" : "OC"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: label,
            style: .plain,
            target: self,
            action: #selector(toggleAnimationSource)
        )
    }

    @objc private func toggleAnimationSource() {
        useSwiftImplementation.toggle()
    }
}

extension ExampleOCAnimationsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ExampleOCAnimationKind.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var config = cell.defaultContentConfiguration()
        let kind = ExampleOCAnimationKind.allCases[indexPath.row]
        config.text = ExampleOCAnimationKindTitle(kind) as String
        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

extension ExampleOCAnimationsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let kind = ExampleOCAnimationKind.allCases[indexPath.row]
        if useSwiftImplementation {
            navigationController?.pushViewController(ExampleSwiftAnimationPreviewViewController(kind: kind), animated: true)
        } else {
            navigationController?.pushViewController(ExampleOCAnimationPreviewViewController(kind: kind), animated: true)
        }
    }
}
