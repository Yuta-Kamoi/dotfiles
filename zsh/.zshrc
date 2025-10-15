#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

##############################
# Customize to your needs... #
##############################
# 日本語ファイル名を表示可能にする
setopt print_eight_bit

# 保管機能を有効にして、実行する
autoload -Uz compinit
if [[ -n ~/.zcompdump ]]; then
  compinit -C
else
  compinit
fi

# 補完メッセージを読みやすくする
zstyle ':completion:*' verbose yes
zstyle ':completion:*' format '%B%d%b'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*' group-name ''

# cd無しでもディレクトリ移動
setopt auto_cd

# cd -で以前移動したディレクトリを表示
setopt auto_pushd

# コマンドのスペルをミスして実行した場合に候補を表示
setopt correct

# 履歴設定
HISTFILE=~/.zsh_history
export HISTSIZE=1000
export SAVEHIST=10000
setopt share_history
setopt hist_reduce_blanks
setopt hist_ignore_all_dups

# 起動時に他にシェルが起動していなければtmux起動
# [[ -z "$TMUX" && ! -z "$PS1" ]] && tmux
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS="--ansi --height=100% --info=inline --border"

# enhancdを有効化
source ~/ghq/github.com/b4b4r07/enhancd/init.sh
# "cd ..", "cd -"の挙動をデフォルトにもどし、代わりに-up,-lsを設定
ENHANCD_HYPHEN_ARG="-ls"
ENHANCD_DOT_ARG="-up"
. "$HOME/ghq/github.com/b4b4r07/enhancd/init.sh"

# gotoを有効化
source ~/ghq/github.com/iridakos/goto/goto.sh

# kを有効化
source ~/ghq/github.com/supercrabtree/k/k.sh

# エージェントが起動していない、または鍵が登録されていない場合に処理を実行
# VSCodeのターミナル用のSSHエージェントの永続化ロジック
# 起動情報を保存するファイル
AGENT_ENV="$HOME/.ssh/agent.env"
# 1. 環境ファイルが存在し、かつエージェントが生きているか確認
if [ -f "${AGENT_ENV}" ]; then
    . "${AGENT_ENV}" > /dev/null 2>&1
    
    # 環境変数を読み込んだ後、PIDが存在し、かつプロセスが動いているか再チェック
    if ! kill -0 "$SSH_AGENT_PID" > /dev/null 2>&1; then
        # プロセスが死んでいたらファイルを削除し、再起動させる
        rm "${AGENT_ENV}"
    fi
fi
# 2. エージェントが起動していない場合、新規起動
if [ ! -f "${AGENT_ENV}" ]; then
    # 新しいエージェントを起動し、情報をファイルに保存
    ssh-agent -s > "${AGENT_ENV}"
    . "${AGENT_ENV}" > /dev/null 2>&1
    
    # 鍵を登録（このとき一度だけパスフレーズが求められる）
    if [ -f "$HOME/.ssh/id_ed25519" ]; then
        ssh-add "$HOME/.ssh/id_ed25519" > /dev/null 2>&1
    fi
fi


############
# コマンド #
############

#################
# WSLのみの設定 #
#################
if [[ "$(uname)" == 'Linux' ]]; then
  if [[ "$(uname -r)" == *microsoft* || "$(uname -r)" == *Microsoft* ]]; then

    # lsの色を変える.dircolorsを適用
    eval $(dircolors -b ~/.dircolors)

  fi
fi


#################
# MACのみの設定 #
#################
function connect_nas() {
    # NAS接続コマンドを実行 (パスワードは対話形式で入力)
    mount_smbfs "//admin@192.168.1.21/share" "$HOME/NAS" 2>/dev/null
}
