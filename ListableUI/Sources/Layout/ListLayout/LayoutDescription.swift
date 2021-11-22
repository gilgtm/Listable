//
//  LayoutDescription.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 6/15/20.
//

import Foundation


///
/// A `LayoutDescription`, well, describes the type of and properties of a layout to apply to a list view.
///
/// You use a `LayoutDescription` by passing a closure to its initializer, which you use to
/// customize the `layoutAppearance` of the provided list type.
///
/// For example, to use a standard list layout, and customize the layout, your code would look something like this:
///
/// ```
/// listView.layout = .table {
///     $0.stickySectionHeaders = true
///
///     $0.layout.padding = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
///     $0.layout.itemSpacing = 10.0
/// }
/// ```
///
/// Or a layout for your own custom layout type would look somewhat like this:
///
/// ```
/// MyCustomLayout.describe {
///     $0.myLayoutOption = true
///     $0.anotherLayoutOption = .polkadots
/// }
/// ```
///
/// Note
/// ----
/// Under the hood, Listable is smart, and will only re-create the underlying
/// layout object when needed (when the layout type or layout appearance changes).
///
public struct LayoutDescription
{
    public typealias Provider = (Context) -> AnyLayoutDescriptionConfiguration
    
    private let provider : Provider
    
    /// Creates a new layout description for the provided layout type, with the provided optional layout configuration.
    public init<LayoutType:ListLayout>(
        layoutType : LayoutType.Type,
        appearance configure : @escaping (inout LayoutType.LayoutAppearance) -> () = { _ in }
    ) {
        self.provider = { _ in Configuration(layoutType: layoutType, configure: configure) }
    }
    
    /// Allows providing a layout which varies based on the context the list is currently being laid out in, eg based
    /// on the view or viewport size.
    /// ```
    /// list.layout = .responsive { context in
    ///
    /// }
    /// ```
    public static func responsive(_ provider : @escaping (Context) -> LayoutDescription) -> LayoutDescription {
        Self.init(
            provider: { context in
                provider(context).provider(context)
            }
        )
    }
    
    /// Creates a new layout description with the given provider.
    init(provider : @escaping Provider) {
        self.provider = provider
    }
    
    func layout(with context : Context) -> AnyLayoutDescriptionConfiguration {
        self.provider(context)
    }
}


extension ListLayout
{
    /// Creates a new layout description for a list layout, with the provided optional layout configuration.
    public static func describe(
        appearance : @escaping (inout Self.LayoutAppearance) -> () = { _ in }
    ) -> LayoutDescription
    {
        return LayoutDescription(
            layoutType: Self.self,
            appearance: appearance
        )
    }
}


extension LayoutDescription
{
    public struct Context : Equatable {
        
        public var viewSize : CGSize
        public var viewportSize : CGSize
        
        public init(
            viewSize: CGSize,
            viewportSize: CGSize
        ) {
            self.viewSize = viewSize
            self.viewportSize = viewportSize
        }
        
        public init(view : UIView) {
            self.viewSize = view.bounds.size
            self.viewportSize = view.viewportSize
        }
    }
    
    public struct Configuration<LayoutType:ListLayout> : AnyLayoutDescriptionConfiguration
    {
        public let layoutType : LayoutType.Type
        
        public let configure : (inout LayoutType.LayoutAppearance) -> ()
        
        // MARK: AnyLayoutDescriptionConfiguration
        
        public func createEmptyLayout(
            appearance : Appearance,
            behavior: Behavior
        ) -> AnyListLayout
        {
            var layoutAppearance = LayoutType.LayoutAppearance.default
            self.configure(&layoutAppearance)
            
            return LayoutType(
                layoutAppearance: layoutAppearance,
                appearance: appearance,
                behavior: behavior,
                content: .init()
            )
        }
        
        public func createPopulatedLayout(
            appearance : Appearance,
            behavior: Behavior,
            content : (ListLayoutDefaults) -> ListLayoutContent
        ) -> AnyListLayout
        {
            var layoutAppearance = LayoutType.LayoutAppearance.default
            self.configure(&layoutAppearance)
            
            return LayoutType(
                layoutAppearance: layoutAppearance,
                appearance: appearance,
                behavior: behavior,
                content: content(LayoutType.defaults)
            )
        }
        
        public func shouldRebuild(layout anyLayout : AnyListLayout) -> Bool
        {
            let layout = anyLayout as! LayoutType
            let old = layout.layoutAppearance
            
            var new = old
            
            self.configure(&new)
            
            return old != new
        }
        
        public func isSameLayoutType(as anyOther : AnyLayoutDescriptionConfiguration) -> Bool
        {
            // TODO: We don't need both of these checks, just the second one.
            
            guard let other = anyOther as? Self else {
                return false
            }
            
            return self.layoutType == other.layoutType
        }
    }
}


public protocol AnyLayoutDescriptionConfiguration
{
    func createEmptyLayout(
        appearance : Appearance,
        behavior: Behavior
    ) -> AnyListLayout
    
    func createPopulatedLayout(
        appearance : Appearance,
        behavior: Behavior,
        content : (ListLayoutDefaults) -> ListLayoutContent
    ) -> AnyListLayout
    
    func shouldRebuild(layout anyLayout : AnyListLayout) -> Bool

    func isSameLayoutType(as other : AnyLayoutDescriptionConfiguration) -> Bool
}


fileprivate extension UIView {
    
    var viewportSize : CGSize {
        if let window = window {
            return window.bounds.size
        }
        
        if let topView = topmostSuperview {
            return topView.bounds.size
        }
        
        return UIScreen.main.bounds.size
    }
    
    private var topmostSuperview : UIView? {
        var view = self.superview
        
        while true {
            if view == nil {
                return view
            } else {
                view = view?.superview
            }
        }
        
        return nil
    }
}
