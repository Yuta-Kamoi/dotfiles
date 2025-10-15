# anyenvのパスをPATHの後方に適用
export PATH="$PATH:$HOME/ghq/github.com/anyenv/anyenv/bin"

# anyenvの初期化を読み込み (PATH設定後に読み込む必要があります)
eval "$(anyenv init -)"

# CondaのbinフォルダをPATHの後方に適用 (すべてのPATHの末尾)
export PATH="$PATH:/opt/anaconda3/bin"


# UTF-8を設定しつつ日本語に翻訳しない
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'
# LC_ALLが設定されていれば、LC_CTYPEの個別設定は不要または混乱を招くためunset推奨
unset LC_CTYPE


# Editors
export EDITOR='vim'
export VISUAL='vim'
export PAGER='less'

# Set the default Less options.
# Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# Remove -X to enable it.
export LESS='-g -i -M -R -w -X -z-4'

# Set the Less input preprocessor.
# Try both `lesspipe` and `lesspipe.sh` as either might exist on a system.
if (( $#commands[(i)lesspipe(|.sh)] )); then
  export LESSOPEN="| /usr/bin/env $commands[(i)lesspipe(|.sh)] %s 2>&-"
fi

# Ensure path arrays do not contain duplicates.
typeset -gU cdpath fpath mailpath path


# 共通設定の末尾にデバイス固有の設定ファイルを読み込む
if [[ "$OSTYPE" == darwin* ]]; then
  # Mac OS X
  source "$HOME/dotfiles/zsh/.zprofile.d/mac.zsh"
elif [[ "$(uname)" == 'Linux' ]]; then
  if [[ "$(uname -r)" == *microsoft* || "$(uname -r)" == *Microsoft* ]]; then
    # WSL (Linux kernel with Microsoft identifier)
    source "$HOME/dotfiles/zsh/.zprofile.d/wsl.zsh"
  fi
fi
