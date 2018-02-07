
public class Event <T> {

  public var listenerCount: Int { return _listeners.count }

  public init () {}

  public func on (_ handler: @escaping (T) -> Void) -> EventListener<T> {
    return EventListener(self, nil, false, handler)
  }

  public func on (_ target: AnyObject, _ handler: @escaping (T) -> Void) -> EventListener<T> {
    return EventListener(self, target, false, handler)
  }

  @discardableResult
  public func once (handler: @escaping (T) -> Void) -> EventListener<T> {
    return EventListener(self, nil, true, handler)
  }

  @discardableResult
  public func once (target: AnyObject, _ handler: @escaping (T) -> Void) -> EventListener<T> {
    return EventListener(self, target, true, handler)
  }

  public func emit (_ data: T) {
    _emit(data, on: "0")
  }

  public func emit (_ data: T, on target: AnyObject) {
    _emit(data, on: (target as? String) ?? getHash(target))
  }

  public func emit (_ data: T, on targets: [AnyObject]) {
    for target in targets {
      _emit(data, on: (target as? String) ?? getHash(target))
    }
  }

  // key == getHash(listener.target)
  var _listeners = [String:[DynamicPointer<Listener>]]()

  private func _emit (_ data: Any!, on targetID: String) {
    if _listeners[targetID] != nil {
      _listeners[targetID] = _listeners[targetID]!.filter({
        if let listener = $0.object {
          listener._trigger(data)
          return listener._listening
        }
        return false
      }).nilIfEmpty
    }
  }

  deinit {
    for (_, listeners) in _listeners {
      for (_, listener) in listeners {
        listener.object._listening = false
      }
    }
  }
}
