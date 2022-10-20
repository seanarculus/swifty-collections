//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Collections open source project
//
// Copyright (c) 2021-2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

extension BitSet {
  /// Returns a Boolean value that indicates whether this set is a strict
  /// superset of another set.
  ///
  /// Set *A* is a strict superset of another set *B* if every member of *B* is
  /// also a member of *A* and *A* contains at least one element that is *not*
  /// a member of *B*.
  ///
  ///     let a: BitSet = [1, 2, 3, 4]
  ///     let b: BitSet = [1, 2, 4]
  ///     let c: BitSet = [0, 1]
  ///     a.isStrictSuperset(of: a) // false
  ///     a.isStrictSuperset(of: b) // true
  ///     a.isStrictSuperset(of: c) // false
  ///
  /// - Parameter other: Another bit set.
  ///
  /// - Returns: `true` if the set is a superset of `other`; otherwise, `false`.
  ///
  /// - Complexity: O(*max*), where *max* is the largest item in `other`.
  public func isStrictSuperset(of other: Self) -> Bool {
    other.isStrictSubset(of: self)
  }

  /// Returns a Boolean value that indicates whether this set is a strict
  /// superset of another set.
  ///
  /// Set *A* is a strict superset of another set *B* if every member of *B* is
  /// also a member of *A* and *A* contains at least one element that is *not*
  /// a member of *B*.
  ///
  /// - Parameter other: A counted bit set.
  ///
  /// - Returns: `true` if the set is a superset of `other`; otherwise, `false`.
  ///
  /// - Complexity: O(*max*), where *max* is the largest item in `other`.
  public func isStrictSuperset(of other: BitSet.Counted) -> Bool {
    other._bits.isStrictSubset(of: self)
  }

  /// Returns a Boolean value that indicates whether this set is a superset of
  /// a given range of integers.
  ///
  /// Set *A* is a superset of another set *B* if every member of *B* is also a
  /// member of *A*.
  ///
  ///     let a: BitSet = [0, 1, 2, 3, 4, 10]
  ///     a.isSuperset(of: 0 ..< 4) // true
  ///     a.isSuperset(of: -10 ..< 4) // false
  ///
  /// - Parameter other: An arbitrary range of integers.
  ///
  /// - Returns: `true` if the set is a subset of `other`; otherwise, `false`.
  ///
  /// - Complexity: O(`range.count`)
  public func isStrictSuperset(of other: Range<Int>) -> Bool {
    if other.isEmpty { return !isEmpty }
    if isEmpty { return false }
    if self[members: ..<other.lowerBound].isEmpty,
       self[members: other.upperBound...].isEmpty {
      return false
    }
    guard let r = other._toUInt() else { return false }
    return _read { $0.isSuperset(of: r) }
  }

  /// Returns a Boolean value that indicates whether this set is a superset of
  /// the values in a given sequence of integers.
  ///
  /// Set *A* is a superset of another set *B* if every member of *B* is also a
  /// member of *A*.
  ///
  ///     let a = [1, 2, 3]
  ///     let b: BitSet = [0, 1, 2, 3, 4]
  ///     let c: BitSet = [0, 1, 2]
  ///     b.isSuperset(of: a) // true
  ///     c.isSuperset(of: a) // false
  ///
  /// - Parameter other: A sequence of arbitrary integers, some of whose members
  ///    may appear more than once. (Duplicate items are ignored.)
  ///
  /// - Returns: `true` if the set is a subset of `other`; otherwise, `false`.
  ///
  /// - Complexity: O(*max*) + *k*, where *max* is the largest item in `other`,
  ///    and *k* is the complexity of iterating over all elements in `other`.
  @inlinable
  public func isStrictSuperset<S: Sequence>(of other: S) -> Bool
  where S.Element == Int
  {
    guard !isEmpty else { return false }
    if S.self == BitSet.self {
      return isStrictSuperset(of: other as! BitSet)
    }
    if S.self == BitSet.Counted.self {
      return isStrictSuperset(of: other as! BitSet.Counted)
    }
    if S.self == Range<Int>.self {
      return isStrictSuperset(of: other as! Range<Int>)
    }
    return _UnsafeHandle.withTemporaryBitset(
      wordCount: _storage.count
    ) { seen in
      var c = 0
      for i in other {
        guard contains(i) else { return false }
        if seen.insert(UInt(i)) { c += 1 }
      }
      return !_storage.elementsEqual(seen._words)
    }
  }
}
