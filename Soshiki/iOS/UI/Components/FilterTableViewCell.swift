//
//  FilterTableViewCell.swift
//  Soshiki
//
//  Created by Jim Phieffer on 1/28/23.
//

import UIKit

class FilterTableViewCell: UITableViewCell {
    let filter: SourceFilter
    let updateHandler: (any SourceFilterBase) -> Void

    var viewControllerToPresent: UIViewController?

    init(filter: SourceFilter, updateHandler: @escaping (any SourceFilterBase) -> Void) {
        self.filter = filter
        self.updateHandler = updateHandler
        switch filter {
        case .text(let filter):
            super.init(style: .default, reuseIdentifier: "TextFilterTableViewCell")
            let titleLabel = UILabel()
            titleLabel.text = filter.name
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(titleLabel)
            titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
            titleLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
            let textField = UITextField()
            textField.text = filter.value
            textField.placeholder = filter.placeholder ?? "..."
            textField.delegate = self
            textField.returnKeyType = .done
            textField.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(textField)
            textField.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
            textField.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8).isActive = true
            textField.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true
            self.selectionStyle = .none
        case .toggle(let filter):
            super.init(style: .default, reuseIdentifier: "ToggleFilterTableViewCell")
            var content = self.defaultContentConfiguration()
            content.text = filter.name
            let toggleView = UISwitch()
            toggleView.isOn = filter.value
            toggleView.addTarget(self, action: #selector(updateToggleFilter(_:)), for: .valueChanged)
            self.accessoryView = toggleView
            self.contentConfiguration = content
            self.selectionStyle = .none
        case .segment(let filter):
            super.init(style: .default, reuseIdentifier: "SegmentFilterTableViewCell")
            let titleLabel = UILabel()
            titleLabel.text = filter.name
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(titleLabel)
            titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
            titleLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
            let segmentView = UISegmentedControl(items: filter.value.map({ $0.name }))
            segmentView.selectedSegmentIndex = filter.value.firstIndex(where: { $0.selected }) ?? 0
            segmentView.isSpringLoaded = true
            segmentView.addTarget(self, action: #selector(updateSegmentFilter(_:)), for: .valueChanged)
            segmentView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(segmentView)
            segmentView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
            segmentView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
            segmentView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8).isActive = true
            segmentView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true
        case .select(let filter):
            super.init(style: .default, reuseIdentifier: "SelectFilterTableViewCell")
            var content = self.defaultContentConfiguration()
            content.text = filter.name
            self.accessoryType = .disclosureIndicator
            self.contentConfiguration = content
            self.viewControllerToPresent = StringSelectViewController(
                title: filter.name,
                options: filter.value,
                tristate: false,
                multi: false,
                type: .includeExclude
            ) { [weak self] in
                self?.updateHandler(filter)
            }
        case .excludableSelect(let filter):
            super.init(style: .default, reuseIdentifier: "ExcludableSelectFilterTableViewCell")
            var content = self.defaultContentConfiguration()
            content.text = filter.name
            self.accessoryType = .disclosureIndicator
            self.contentConfiguration = content
            self.viewControllerToPresent = StringSelectViewController(
                title: filter.name,
                options: filter.value,
                tristate: true,
                multi: false,
                type: .includeExclude
            ) { [weak self] in
                self?.updateHandler(filter)
            }
        case .multiSelect(let filter):
            super.init(style: .default, reuseIdentifier: "MultiSelectFilterTableViewCell")
            var content = self.defaultContentConfiguration()
            content.text = filter.name
            self.accessoryType = .disclosureIndicator
            self.contentConfiguration = content
            self.viewControllerToPresent = StringSelectViewController(
                title: filter.name,
                options: filter.value,
                tristate: false,
                multi: true,
                type: .includeExclude
            ) { [weak self] in
                self?.updateHandler(filter)
            }
        case .excludableMultiSelect(let filter):
            super.init(style: .default, reuseIdentifier: "ExcludableMultiSelectFilterTableViewCell")
            var content = self.defaultContentConfiguration()
            content.text = filter.name
            self.accessoryType = .disclosureIndicator
            self.contentConfiguration = content
            self.viewControllerToPresent = StringSelectViewController(
                title: filter.name,
                options: filter.value,
                tristate: true,
                multi: true,
                type: .includeExclude
            ) { [weak self] in
                self?.updateHandler(filter)
            }
        case .sort(let filter):
            super.init(style: .default, reuseIdentifier: "SortFilterTableViewCell")
            var content = self.defaultContentConfiguration()
            content.text = filter.name
            self.accessoryType = .disclosureIndicator
            self.contentConfiguration = content
            self.viewControllerToPresent = StringSelectViewController(
                title: filter.name,
                options: filter.value,
                tristate: false,
                multi: false,
                type: .ascendDescend
            ) { [weak self] in
                self?.updateHandler(filter)
            }
        case .ascendableSort(let filter):
            super.init(style: .default, reuseIdentifier: "AscendableSortFilterTableViewCell")
            var content = self.defaultContentConfiguration()
            content.text = filter.name
            self.accessoryType = .disclosureIndicator
            self.contentConfiguration = content
            self.viewControllerToPresent = StringSelectViewController(
                title: filter.name,
                options: filter.value,
                tristate: true,
                multi: false,
                type: .ascendDescend
            ) { [weak self] in
                self?.updateHandler(filter)
            }
        case .number(let filter):
            super.init(style: .value1, reuseIdentifier: "NumberFilterTableViewCell")
            var content = self.defaultContentConfiguration()
            content.text = filter.name
            content.secondaryText = filter.value.toTruncatedString()
            let stepperView = UIStepper()
            stepperView.minimumValue = filter.lowerBound
            stepperView.maximumValue = filter.upperBound
            stepperView.value = filter.value
            stepperView.stepValue = filter.step
            stepperView.addTarget(self, action: #selector(updateNumberFilter(_:)), for: .valueChanged)
            self.accessoryView = stepperView
            self.contentConfiguration = content
            self.selectionStyle = .none
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func didSelect() {
        if let viewControllerToPresent {
            self.nearestNavigationController?.pushViewController(viewControllerToPresent, animated: true)
        }
    }

    @objc func updateToggleFilter(_ sender: UISwitch) {
        guard case .toggle(let filter) = self.filter else { return }
        filter.value = sender.isOn
        updateHandler(filter)
    }

    @objc func updateSegmentFilter(_ sender: UISegmentedControl) {
        guard case .segment(let filter) = self.filter else { return }
        filter.value.first(where: { $0.selected })?.selected = false
        filter.value[sender.selectedSegmentIndex].selected = true
        updateHandler(filter)
    }

    @objc func updateNumberFilter(_ sender: UIStepper) {
        guard case .number(let filter) = self.filter else { return }
        filter.value = sender.value
        updateHandler(filter)
        var content = self.contentConfiguration as? UIListContentConfiguration ?? self.defaultContentConfiguration()
        content.secondaryText = filter.value.toTruncatedString()
        self.contentConfiguration = content
    }
}

extension FilterTableViewCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard case .text(let filter) = self.filter else { return }
        filter.value = textField.text ?? ""
        updateHandler(filter)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
