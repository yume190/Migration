# Sendable

---

## 主要目的

將既有的結構(`class`/`struct`/`enum`)合理地補上 `Sendable`

### 添加條件

* [x] 所有屬性必須是 `let`
* [x] 所有屬性必須是 `Sendable`
* [ ] 特殊情況
    * [x] `@MainActor var`
        被 `MainActor` 保護
    * [x] `nonisolated(unsafe) var`
        被使用者保證
    * [ ] `@MainActor` 結構
    * [ ] 考慮 `GlobalActor`?

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
/// 所有屬性皆符合條件(a)，應此 Target 可加入 Sendable
```

### 添加條件(`class`)

* [x] 添加 final
    必須為 `final class`
    * [x] `open class` 不能使用 `final`
    * [x] 確認無子類別
* [x] 不能是 `NSObject` 的子類別


### 其他

* [ ] Add `Sendable` to `enum`

### 待確認

```swift
public extension Target: Sendable {}
/// 
```

### Don't do

不會擅自添加 `@unchecked Sendable`


