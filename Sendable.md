# Sendable

---

## Primary Purpose

Reasonably add `Sendable` to existing structures (`class`/`struct`/`enum`).

### Conditions for Addition

* [x] 所有屬性必須是 `let`
* [x] 所有屬性必須是 `Sendable`
* [ ] 特殊情況
    * [x] `@MainActor var`
        被 MainActor 保護
    * [x] nonisolated(unsafe) var
        被使用者保證
    * [ ] @MainActor 結構
    * [ ] 考慮 GlobalActor?

* [x] All properties must be `let`.
* [x] All properties must be `Sendable`.
* [x] Special Cases:
    * [x] `@MainActor var`
        Protected by `MainActor`.
    * [x] `nonisolated(unsafe) var`
        Guaranteed by the user.
    * [ ] `@MainActor structures`.
    * [ ] Consider `GlobalActor`?

```swift
struct Target {
    /// let & Int is Sendable
    let a: Int
    /// don't care @MainActor
    @MainActor
    var b: Int
    /// don't care nonisolated(unsafe)
    nonisolated(unsafe)
    var c: Int
}
/// a: O
/// b: don't care
/// c: don't care
///
/// All properties meet the conditions (a), so `Target` can be marked as `Sendable`.
```

### Conditions for Addition(`class`)

* [x] Add final
    Must be a `final class`
    * [x] `open class` cannot use `final`
    * [x] Confirm no subclasses exist
* [x] Must not be a subclass of `NSObject`.


### Others

* [ ] Add `Sendable` to `enum`

### Pending Confirmation

```swift
public extension Target: Sendable {}
/// 
```

### Don't do

Will not add `@unchecked Sendable` without careful consideration.
