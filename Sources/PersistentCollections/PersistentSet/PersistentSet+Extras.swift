//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Collections open source project
//
// Copyright (c) 2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import _CollectionsUtilities

extension PersistentSet: _UniqueCollection {}

extension PersistentSet {
  @discardableResult
  public mutating func remove(at position: Index) -> Element {
    precondition(_isValid(position))
    _invalidateIndices()
    let r = _root.remove(.top, at: position._path)
    precondition(r.remainder == nil)
    return r.removed.key
  }

  /// Replace the member at the given index with a new value that compares equal
  /// to it.
  ///
  /// This is useful when equal elements can be distinguished by identity
  /// comparison or some other means. Updating a member through this method
  /// does not require any hashing operations.
  ///
  /// Calling this method invalidates all existing indices.
  ///
  /// - Parameter item: The new value that should replace the original element.
  ///     `item` must compare equal to the original value.
  ///
  /// - Parameter index: The index of the element to be replaced.
  ///
  /// - Returns: The original element that was replaced.
  ///
  /// - Complexity: Amortized O(1).
  public mutating func update(_ member: Element, at index: Index) -> Element {
    precondition(_isValid(index), "Invalid index")
    precondition(index._path.isOnItem, "Can't get element at endIndex")
    _invalidateIndices()
    return _UnsafeHandle.update(index._path.node) {
      let p = $0.itemPtr(at: index._path.currentItemSlot)
      var old = member
      precondition(
        member == p.pointee.key,
        "The replacement item must compare equal to the original")
      swap(&p.pointee.key, &old)
      return old
    }
  }
}
