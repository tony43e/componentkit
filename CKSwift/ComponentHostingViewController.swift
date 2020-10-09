// (c) Facebook, Inc. and its affiliates. Confidential and proprietary.

import UIKit

final class ObjCProviderWrapper: NSObject {
  let provider: () -> Component

  init(provider: @escaping () -> Component) {
    self.provider = provider
  }
}

public final class ComponentHostingViewController: UIViewController {
  private let rootComponentProvider: () -> Component
  private let hostingView: ComponentHostingView<NSObject, ObjCProviderWrapper>

  #if swift(>=5.3)

  public init(@ComponentBuilder rootComponentProvider: @escaping () -> Component) {
    self.rootComponentProvider = rootComponentProvider
    hostingView = ComponentHostingView(componentProvider: { _, wrapper in wrapper!.provider() },
                                       sizeRangeProviderBlock: { size in SizeRange(minSize: .zero, maxSize: size) })
    super.init(nibName: nil, bundle: nil)
  }

  #else

  public init(rootComponentProvider: @escaping () -> Component) {
    self.rootComponentProvider = rootComponentProvider
    hostingView = ComponentHostingView(componentProvider: { _, wrapper in wrapper!.provider() },
                                       sizeRangeProviderBlock: { size in SizeRange(minSize: .zero, maxSize: size) })
    super.init(nibName: nil, bundle: nil)
  }

  #endif

  required init(coder: NSCoder) {
    fatalError()
  }

  public override func viewDidLoad() {
    view.backgroundColor = .white

    hostingView.updateContext(ObjCProviderWrapper(provider: rootComponentProvider), mode: .synchronous)

    view.addSubview(hostingView)
  }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    hostingView.hostingViewWillAppear()
  }

  public override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    hostingView.hostingViewDidDisappear()
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    hostingView.frame = view.bounds
  }
}

extension ComponentHostingViewController: ComponentHostingViewDelegate {
  public func componentHostingViewDidInvalidateSize(_: UIView) {
    view.setNeedsLayout()
  }
}
