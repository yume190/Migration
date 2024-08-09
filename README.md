# Swift Migration(POC)

---

[Swift Migration Guide](https://github.com/apple/swift-migration-guide)

> Don't use `XCode 15.4` or must test UsrTests/testUsr success

---

## Install

``` bash
brew install mint
mint install yume190/Migration
```

## 使用方式

``` bash
migration \
    --module "SCHEME NAME" \
    --file Sample.xcworkspace

migration \
    --module "SCHEME NAME" \
    --file Sample.xcodeproj

# spm
migration \
    --module TARGET_NAME \
    --file .

# file
migration \
    --sdk macosx \
    --file xxx.swift
```

---

## TODOS

* [ ] Add Explicit `Sendable`
    * [x] Commom
        * [x] Check all propery is `let`
        * [x] Check all propery is `Sendable`
        * [x] Exceptions
            * [x] @MainActor var
            * [x] nonisolated(unsafe) var
    * [x] Add `Sendable` to `struct`
    * [x] Add `Sendable` to `class`
        * [x] Add `final` to `class`
            * [x] `open class` can't `final`
            * [x] Check `class` no child class
        * [x] Check `class` not `NSObject`
    * [ ] Add `Sendable` to `enum`
* [ ] Add `@MainActor`
    * [ ] find caller
    * [ ] find exist `@MainActor` structure
    * [ ] find exist `@MainActor` instance property
    * [ ] find use `@MainActor` instance property
    * [ ] find use `@MainActor` call function
* [ ] `sending`?
* [ ] `@retroactive`?

---

## Not Support

* deinit
* objc
