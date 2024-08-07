VERSION = 0.0.8

.PHONY: updateVersion
updateVersion:
	sed -i '' 's|\(version: "\)\(.*\)\("\)|\1$(VERSION)\3|' Sources/Migration/Command.swift
	sed -i '' 's|\(download\/\)\(.*\)\(\/\)|\1$(VERSION)\3|' action.yml
	sed -i '' 's|\(Migration@\)\(.*\)|\1$(VERSION)|' README.md
	sed -i '' 's|\(Migration@\)\(.*\)|\1$(VERSION)|' README_ZH.md

.PHONY: githubRelease
githubRelease: updateVersion
	git add Sources/Migration/Command.swift
	git add action.yml
	git add Makefile

	git commit -m "Update to $(VERSION)"
	git tag $(VERSION)
	git push origin $(VERSION)

.PHONY: build
build:
	swift build

# --parallel
.PHONY: test
test: build
	# @swift test -v 2>&1 | xcpretty
	@swift test \
		-j 1 \
		-v 2>&1 | xcbeautify

.PHONY: test2
test2: build
	@swift test -v --filter SyntaxTests 2>&1 | xcbeautify

	@swift test -v --filter SendableTests/testSimple 2>&1 | xcbeautify
	@swift test -v --filter SendableTests/testWithException 2>&1 | xcbeautify
	@swift test -v --filter SendableTests/testExistSendable 2>&1 | xcbeautify
	@swift test -v --filter SendableTests/testWithMultiInheritance 2>&1 | xcbeautify
	@swift test -v --filter SendableTests/testStep1 2>&1 | xcbeautify
	@swift test -v --filter SendableTests/testStep2 2>&1 | xcbeautify
	@swift test -v --filter SendableTests/testStep3 2>&1 | xcbeautify
	@swift test -v --filter SendableTests/testClass 2>&1 | xcbeautify
	@swift test -v --filter SendableTests/testClassNSObject 2>&1 | xcbeautify
	@swift test -v --filter SendableTests/testClassOnlyNoChildClass 2>&1 | xcbeautify
	
	@swift test -v --filter IndexDBTests/testExtensions2 2>&1 | xcbeautify
	@swift test -v --filter IndexDBTests/testExtensions3 2>&1 | xcbeautify
	@swift test -v --filter IndexDBTests/testComforms 2>&1 | xcbeautify
	@swift test -v --filter IndexDBTests/testComformsInt 2>&1 | xcbeautify
	@swift test -v --filter IndexDBTests/testProperty 2>&1 | xcbeautify
	@swift test -v --filter IndexDBTests/testParent 2>&1 | xcbeautify
	@swift test -v --filter IndexDBTests/testHasChild 2>&1 | xcbeautify
	@swift test -v --filter IndexDBTests/testNSObject 2>&1 | xcbeautify

.PHONY: release
release:
	@swift build -c release

.PHONY: releaseX86
releaseX86:
	@swift build -c release --arch x86_64

.PHONY: releaseArm
releaseArm:
	@swift build -c release --arch arm64

.PHONY: releaseAll
releaseAll:
	@swift build -c release --arch arm64 --arch x86_64

.PHONY: install
install: releaseArm
	@sudo cp .build/release/migration /usr/local/bin

.PHONY: clear
clear:
	@rm /usr/local/bin/migration

.PHONY: clearAll
clearAll: clear
	@rm -Rf .build

.PHONY: libs
libs: release
	otool -L .build/release/migration

.PHONY: libDetail
libDetail: release
	otool -l .build/release/migration

.PHONY: graph
graph:
	swift package show-dependencies --format dot | dot -Tsvg -o graph.svg

testRun: 
	swift run migration \
		--file /Users/yume/Downloads/swift-migration-guide-main/Package.swift \
		--module Library

# .PHONY: single
# single:
# 	leakDetect \
# 		--sdk macosx \
# 		--file fixture/temp.swift \
# 		-- \
# 		fixture/functions.swift

