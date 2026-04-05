//
//  ExampleDemoViewController.swift
//  ZHHProgressHUD
//
//  Created by 桃色三岁 on 2026/4/4.
//  Copyright © 2026 桃色三岁. All rights reserved.
//

import UIKit

/// 示例入口页：用表格列出各类 HUD 演示，业务逻辑在 `ExampleDemoViewModel`
final class ExampleDemoViewController: UIViewController {

    /// 与界面解耦；`keyWindow` 供进度演示从窗口上取当前 HUD
    private lazy var viewModel = ExampleDemoViewModel(keyWindow: { [weak self] in
        self?.view.window
    })

    /// 分组列表，展示 `viewModel.sections` 中的标题与点击项
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.backgroundColor = .secondarySystemBackground
        tableView.showsVerticalScrollIndicator = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "HUD 演示"

        configNavigationBarAppearance()
        // 「取消」右侧；其左侧为 OC 纯动画演示入口
        let ocItem = UIBarButtonItem(title: "OC动画", style: .plain, target: self, action: #selector(onOpenOCAnimations))
        let cancelItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(onDismissHUD))
        navigationItem.rightBarButtonItems = [cancelItem, ocItem]
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        // 铺满安全区下主区域，底部贴齐根视图（与 Home 条共存时表格可滚到底）
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        tableView.dataSource = self
        tableView.delegate = self
    }

    /// 导航栏「取消」：隐藏 HUD 并作废进度演示定时器
    @objc private func onDismissHUD() {
        viewModel.dismissAllHUD()
    }

    @objc private func onOpenOCAnimations() {
        navigationController?.pushViewController(ExampleOCAnimationsListViewController(), animated: true)
    }

    /// 与 `standardAppearance` 统一，避免 ScrollView 滚到边缘时导航栏变透明或变色
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
}

// MARK: - UITableViewDataSource（表格数据源）

extension ExampleDemoViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.sections[section].items.count
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        44
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        0.01
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        viewModel.sections[section].title
    }

    /// 使用系统样式单元格 + `UIListContentConfiguration` 展示行标题
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
        var config = cell.defaultContentConfiguration()
        config.text = viewModel.sections[indexPath.section].items[indexPath.row].title
        cell.contentConfiguration = config
        return cell
    }
}

// MARK: - UITableViewDelegate（点击触发对应 HUD 演示）

extension ExampleDemoViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // 切换行前结束上一段进度动画，避免 Timer 与新的 HUD 打架
        viewModel.invalidateProgressTimer()
        viewModel.sections[indexPath.section].items[indexPath.row].onSelect()
    }
}
