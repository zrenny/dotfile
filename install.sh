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
	awscli
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
)

casks=(
	font-sauce-code-pro-nerd-font
	hashicorp-vagrant
)

for tool in "${tools[@]}"; do
	echo "Brew installing $tool"
	brew install "$tool" 
done

chsh -s $(which zsh)

for cask in "${casks[@]}"; do
	echo "Brew install $cask"
	brew install --cask "$cask" 
done

echo "Installing rust"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y 
source $HOME/.cargo/env

rustup install nightly

go_tools=(
	callgraph
	dlv
	fillswitch
	ginkgo
	go-enum
	gofumpt
	goimports
	goimports-reviser
	golangci-lint
	golangci-lint-langserver
	golines
	gomodifytags
	gomvp
	gonew
	gopls
	gorename
	gotests
	gotestsum
	govulncheck
	iferr
	impl
	json-to-struct
	mockgen
	richgo
	weed
)

for tool in "${go_tools[@]}"; do
	echo "Go installing $tool"
	go install ${tool}@latest 
done

rust_nightly_tools=(
	miri
)

for tool in "${rust_nightly_tools[@]}"; do
	echo "Rust nightly installing $tool"
	rust +nightly component add "$tool" 
done

rust_tools=(
	clippy
	rust-analyzer
	rustfmt
	rustowl
)

for tool in "${rust_tools[@]}"; do
	echo "Rust installing $tool"
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
	echo "NPM installing $tool"
	npm install -g "$tool" 
done

mkdir -p "$HOME/.config/"

wd="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$wd"
stow .

echo "✅ Installation complete!"
