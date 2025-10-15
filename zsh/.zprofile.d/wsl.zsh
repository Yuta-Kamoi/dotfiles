# ユーザーローカルなLinuxの慣習的バイナリをPATHの先頭に追加
path=(/usr/local/{bin,sbin} $path)
# Linuxbrewのパスを、現在のPATHのさらに先頭（最優先）に追加
export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
