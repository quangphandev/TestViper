# Makefile cho TestViper
# Dùng: make test, make build, make clean

SCHEME   = TestViper
PROJECT  = TestViper.xcodeproj
DEVICE   = platform=iOS Simulator,name=iPhone 17

# Chạy TẤT CẢ tests (unit + UI tests) — simulator sẽ bật lên cho UI tests
test:
	xcodebuild test \
		-project $(PROJECT) \
		-scheme $(SCHEME) \
		-destination '$(DEVICE)' \
		2>&1 | grep -E "Test case|passed|failed|SUCCEEDED|FAILED|error:"

# Chỉ chạy UNIT TESTS — không bật simulator UI, nhanh hơn
test-unit:
	xcodebuild test \
		-project $(PROJECT) \
		-scheme $(SCHEME) \
		-destination '$(DEVICE)' \
		-skip-testing:TestViperUITests \
		2>&1 | grep -E "Test case|passed|failed|SUCCEEDED|FAILED|error:"

# Build only
build:
	xcodebuild build \
		-project $(PROJECT) \
		-scheme $(SCHEME) \
		-destination '$(DEVICE)' \
		2>&1 | grep -E "error:|warning:|BUILD SUCCEEDED|BUILD FAILED"

# Chỉ chạy Presenter tests
test-presenter:
	xcodebuild test \
		-project $(PROJECT) \
		-scheme $(SCHEME) \
		-destination '$(DEVICE)' \
		-only-testing:TestViperTests/TodoListPresenterTests \
		2>&1 | grep -E "Test case|passed|failed|SUCCEEDED|FAILED"

# Chỉ chạy Interactor tests
test-interactor:
	xcodebuild test \
		-project $(PROJECT) \
		-scheme $(SCHEME) \
		-destination '$(DEVICE)' \
		-only-testing:TestViperTests/TodoListInteractorTests \
		2>&1 | grep -E "Test case|passed|failed|SUCCEEDED|FAILED"

# Build rồi test (full pipeline)
ci: build test

# Xoá build cache
clean:
	xcodebuild clean -project $(PROJECT) -scheme $(SCHEME)

.PHONY: test build test-presenter test-interactor ci clean
