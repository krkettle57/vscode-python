#!/bin/bash -Ceu

# Python3.8.xにする場合、pyproject.tomlの
# [tool.poetry.dependencies]を適切なバージョンに変更する必要があります
PYTHON_VERSION=${1:-"3.8.7"}

sudo yum update -y
sudo yum install -y \
  jq \
  gcc \
  git \
  make \
  wget \
  patch \
  bzip2-devel \
  gdbm-devel \
  libffi-devel \
  libuuid-devel \
  ncurses-devel \
  openssl-devel \
  readline-devel \
  sqlite-devel \
  tk-devel \
  xz-devel \
  zlib-devel

# pyenv install
# https://github.com/pyenv/pyenv/wiki#suggested-build-environment
# https://github.com/pyenv/pyenv#basic-github-checkout
git clone https://github.com/pyenv/pyenv.git ~/.pyenv
_pwd=$(pwd)
cd ~/.pyenv && src/configure && make -C src && cd $_pwd

sed -Ei -e '/^([^#]|$)/ {a \
export PYENV_ROOT="$HOME/.pyenv"
a \
export PATH="$PYENV_ROOT/bin:$PATH"
a \
' -e ':a' -e '$!{n;ba};}' ~/.bash_profile
echo 'eval "$(pyenv init --path)"' >>~/.bash_profile
echo 'export PYENV_ROOT="$HOME/.pyenv"' >>~/.profile
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >>~/.profile
echo 'eval "$(pyenv init --path)"' >>~/.profile
echo 'eval "$(pyenv init -)"' >>~/.bashrc

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

pyenv install $PYTHON_VERSION
pyenv local $PYTHON_VERSION

# poetry install
pip3 install poetry
poetry config virtualenvs.in-project true
poetry install
poetry update

# vscode extensions
code_ex_path=".vscode/extensions.json"
json_file=$(cat ${code_ex_path})
json_length=$(echo ${json_file} | jq '.recommendations | length')
for i in $(seq 0 $(expr ${json_length} - 1)); do
  ext=$(echo ${json_file} | jq -r .recommendations[${i}])
  code --install-extension $ext
done
