# ------------
# Terminal options
# ------------

setopt AUTO_CD # ディレクトリ名のみでcd
setopt AUTO_PUSHD # cdしたディレクトリをスタックに追加
setopt PUSHD_IGNORE_DUPS # スタックに同じディレクトリがある場合は追加しない
setopt AUTO_PARAM_KEYS # カッコなどを自動補完
setopt MARK_DIRS # ディレクトリに/を付ける
setopt CORRECT # 補完時に誤った入力を修正
setopt CORRECT_ALL # 補完時に誤った入力を全て修正
setopt SHARE_HISTORY # 複数のターミナルで履歴を共有
setopt HIST_REDUCE_BLANKS # 履歴に連続する空白を1つにする
setopt HIST_IGNORE_ALL_DUPS # 履歴に同じコマンドがある場合は追加しない
setopt PRINT_EIGHT_BIT # 8ビット文字を表示
setopt PROMPT_SUBST # プロンプトにコマンドの出力を埋め込む
setopt NO_BEEP # ベルを鳴らさない