# =========================================================
# easy-ssh-dev Makefile
# Author: Sumit
# =========================================================

.DEFAULT_GOAL := help

APP=sshx-dev
BUILD_SCRIPT=./build-install
DEPS_SCRIPT=./build/build-deps

.PHONY: help deps deps-cli deps-gui deps-build deps-all \
        build cli install uninstall clean rebuild dry-run

# ---------------------------------------------------------
# NOTE:
# install target requires prebuilt binary:
#   ./sshx-dev
#
# Build first:
#   make build
# ---------------------------------------------------------

# ---------------- Help ----------------

help:
	@echo ""
	@echo "easy-ssh-dev Build System"
	@echo ""
	@echo "Targets:"
	@echo ""
	@echo "Dependency setup:"
	@echo "  make deps        Install core dependencies"
	@echo "  make deps-cli    Install minimal CLI dependencies"
	@echo "  make deps-gui    Install GUI dependencies"
	@echo "  make deps-build  Install build tools"
	@echo "  make deps-all    Install everything (core + gui + build)"
	@echo ""
	@echo "Build:"
	@echo "  make build       Build CLI + GUI"
	@echo "  make cli         Build CLI only"
	@echo "  make dry-run     Simulate build"
	@echo ""
	@echo "Install:"
	@echo "  make install     Install binaries (requires prebuilt sshx-dev)"
	@echo "  make uninstall   Remove installation"
	@echo ""
	@echo "Maintenance:"
	@echo "  make clean       Remove built artifacts"
	@echo "  make rebuild     Clean + Build"
	@echo ""

# ---------------- Dependencies ----------------

deps:
	@echo "Installing core dependencies..."
	$(DEPS_SCRIPT)

deps-cli:
	@echo "Installing CLI dependencies..."
	$(DEPS_SCRIPT) --cli

deps-gui:
	@echo "Installing GUI dependencies..."
	$(DEPS_SCRIPT) --gui

deps-build:
	@echo "Installing build tools..."
	$(DEPS_SCRIPT) --build

deps-all:
	@echo "Installing ALL dependencies..."
	$(DEPS_SCRIPT) --gui --build -y

# ---------------- Build ----------------

build:
	$(BUILD_SCRIPT)

cli:
	$(BUILD_SCRIPT) --cli

dry-run:
	$(BUILD_SCRIPT) --dry-run

# ---------------- Install ----------------

install:
	@if [ ! -f "./$(APP)" ]; then \
		echo "❌ $(APP) binary not found."; \
		echo "Run 'make build' first."; \
		exit 1; \
	fi
	./$(APP) install

uninstall:
	./$(APP) uninstall

# ---------------- Clean ----------------

clean:
	@echo "Cleaning build artifacts..."
	rm -f bin/sshx \
	      bin/sshx-key \
	      bin/scpx \
	      bin/git-auth \
	      bin/sshx-cpy \
	      bin/sshx-reset \
	      sshx-dev \
	      gui/sshx-gui
	rm -rf gui/_internal
	@echo "✔ Clean complete"

# ---------------- Rebuild ----------------

rebuild: clean build
