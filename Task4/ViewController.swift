//
//  ViewController.swift
//  Task4
//
//  Created by Gusev Kirill on 11.11.2024.
//

import UIKit

final class ViewController: UIViewController {
    
    struct CellItem: Hashable, Equatable {
        var number: Int
        var isSelected: Bool
        
        static func == (lhs: CellItem, rhs: CellItem) -> Bool {
            return lhs.number == rhs.number && lhs.isSelected == rhs.isSelected
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(number)
        }
    }
    
    enum Section: Hashable {
        case table
    }
    
    private var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemBackground
        tableView.layer.cornerRadius = 10
        return tableView
    }()
    
    private lazy var dataSource: UITableViewDiffableDataSource<Section, CellItem> = {
        return .init(tableView: tableView) { tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            var configuration = UIListContentConfiguration.cell()
            configuration.text = "\(itemIdentifier.number)"
            cell?.contentConfiguration = configuration
            cell?.accessoryType = itemIdentifier.isSelected ? .checkmark : .none
            return cell
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        setNavBar()
        setupView()
    }
    
    private func setNavBar() {
        navigationItem.title = "Task 4"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Shuffle", style: .plain, target: self, action: #selector(shuffleTableView))
    }
    
    private func setupView() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        createSnapshot()
    }
    
    @objc private func shuffleTableView() {
        var snapshot = dataSource.snapshot()
        let items = snapshot.itemIdentifiers.shuffled()
        snapshot.deleteItems(items)
        snapshot.appendItems(items, toSection: .table)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func createSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, CellItem>()
        let array = Array(0...30).map { CellItem(number: $0, isSelected: false) }
        snapshot.appendSections([.table])
        snapshot.appendItems(array, toSection: .table)
        dataSource.apply(snapshot)
        dataSource.defaultRowAnimation = .fade
        tableView.dataSource = dataSource
    }
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var snapshot = dataSource.snapshot()
        var items = snapshot.itemIdentifiers(inSection: .table)
        let shouldMove = !items[indexPath.row].isSelected
        
        items[indexPath.row].isSelected.toggle()
        
        snapshot.deleteAllItems()
        snapshot.appendSections([.table])
        snapshot.appendItems(items, toSection: .table)
        
        tableView.cellForRow(at: indexPath)?.accessoryType = items[indexPath.row].isSelected ? .checkmark : .none
        
        if indexPath.row > 0 && shouldMove {
            snapshot.moveItem(items[indexPath.row], beforeItem: items[0])
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
