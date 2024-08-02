# Swift Migration(POC)

---

一

## 安裝

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
    * [x] Check all propery is `let`
    * [x] Check all propery is `Sendable`
    * [x] Add `final` to `class`
    * [ ] Check `class` no child
    * [ ] Check `class` not `NSObject`
    * [ ] Exceptions
        * [ ] @MainActor var
        * [ ] nonisolated(unsafe) var
* [ ]
* [ ]
* [ ]


