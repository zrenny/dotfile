#!/bin/bash

set -euo pipefail

# brew
if ! command -v brew &>/dev/null; then
	echo "Homebrew is not installed, installing..."
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>~/.bash_profile
else
	echo "Homebrew is already installed!"
fi

tools=(
	# awscli
	bat
	cffi
	clang-format
	cppcheck
	dnsmasq
	docutils
	duf
	dust
	eslint
	eva
	exiftool
	fd
	flake8
	fzf
	gh
	go
	helm
	jpeg-xl
	jq
	k9s
	kind
	kube-ps1
	kubectx
	kubeseal
	mysql
	neovim
	node
	popeye
	prettier
	pycparser
	python
	ripgrep
	scdoc
	sd
	shfmt
	koekeishiya/formulae/skhd
	sqlfluff
	starship
	stow
	stylelint
	stylua
	telnet
	terraform
	tree
	tree-sitter
	typos-cli
	wget
	koekeishiya/formulae/yabai
	yamllint
	zellij
	zsh
	gcc
	docker
	colima
 	golangci-lint
)

casks=(
	font-sauce-code-pro-nerd-font
	vagrant
)

for tool in "${tools[@]}"; do
	brew install "$tool" 
done

current_shell=$(basename "$SHELL")
if [ "$current_shell" != "zsh" ]; then
  chsh -s "$(which zsh)" || true
fi

for cask in "${casks[@]}"; do
	brew install --cask "$cask" 
done

echo "Installing rust"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y 
source $HOME/.cargo/env

rustup install nightly

go_tools=(
	golang.org/x/tools/cmd/callgraph
	github.com/go-delve/delve/cmd/dlv
	mvdan.cc/gofumpt
	golang.org/x/tools/cmd/goimports
	github.com/incu6us/goimports-reviser/v3
	github.com/nametake/golangci-lint-langserver
	github.com/segmentio/golines
	github.com/fatih/gomodifytags
	github.com/abenz1267/gomvp
	golang.org/x/tools/cmd/gonew
	golang.org/x/tools/gopls
	golang.org/x/tools/cmd/gorename
	github.com/cweill/gotests/...
	gotest.tools/gotestsum
	golang.org/x/vuln/cmd/govulncheck
	github.com/motemen/go-iferr/cmd/goiferr
	github.com/josharian/impl
	go.uber.org/mock/mockgen
	github.com/kyoh86/richgo
)

for tool in "${go_tools[@]}"; do
	go install ${tool}@latest 
done

rust_nightly_tools=(
	miri
)

for tool in "${rust_nightly_tools[@]}"; do
	rust +nightly component add "$tool" 
done

rust_tools=(
	clippy
	rust-analyzer
	rustfmt
	rustowl
)

for tool in "${rust_tools[@]}"; do
	if [[ $tool = "rustowl" ]]; then
		curl -L "https://github.com/cordx56/rustowl/releases/latest/download/install.sh" | sh 
	else
		rustup component add "$tool" 
	fi
done

npm_tools=(
	bash-language-server
)

for tool in "${npm_tools[@]}"; do
	npm install -g "$tool" 
done

mkdir -p "$HOME/.config/"

wd="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$wd"
stow .

echo "✅ Installation complete!"
