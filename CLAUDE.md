# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## リポジトリ概要

macOS (Darwin) 前提の個人 dotfiles。ビルド対象のアプリケーションコードは無く、設定ファイル群と、それを `$HOME` へ symlink する `Makefile` で構成される。エントリポイントは常に `Makefile`。

## コマンド

```bash
make deploy        # ルートの dotfile と CONFIG_TARGET を ~/ へ symlink (install-zinit を前段で実行)
make install       # Homebrew 導入 + pkg/brew.txt, pkg/npm.txt を一括インストール
make install-go    # pkg/gopkg.txt の Go パッケージを導入
make update        # 実機の状態から pkg/*.txt を再生成し、hack/update-local.zsh を実行
make gopkg.update  # 導入済み Go パッケージを最新版で入れ直す
```

テストは「クリーンな macOS で本当に入るか」の検証で、CI (`.github/workflows/test.yml`) が `macos-latest` 上で brew を一度アンインストールしてから matrix で回す。ローカルで単体実行する場合は個別ターゲットを直接叩く。

```bash
make test.deploy   # symlink 展開のみ検証 (最も軽く、設定変更時はこれで足りる)
make test.init     # coreutils を入れ pkg/brew.txt を brew-0/1/2 に 3 分割
make test.brew.0   # 分割 0 のみインストール検証 (1, 2 も同様)
make test.cask     # pkg/cask.txt の cask を検証 (CI matrix には含まれない)
```

lint / format ターゲットは存在しない。

## deploy の仕組みと、設定を追加するときの手順

`make deploy` は `DOTFILES_TARGET := $(wildcard .??*)` でルート直下の dotfile を**ワイルドカード収集**し、`$HOME` へ symlink する (`.DS_Store` `.git` `.gitmodules` のみ除外)。ルートに `.foo` を置けば追記なしで `~/.foo` に張られる。

重要なのは、**この wildcard に `.config` 自身が含まれる**こと。`ln -sfnv dotfiles/.config ~/.config` が走り、`.config` はディレクトリ丸ごと symlink される。したがって `.config/` 配下は「git に追跡されているものは全部 deploy される」と考えてよい。実際に追加で必要なのは `.gitignore` への追記だけ。`.gitignore` は `.config/*` を全無視して `!` で個別に追跡許可する allowlist 方式なので、新しいツールの設定を足すときは **`.gitignore` の allowlist に `!` 行を追加する**。

`Makefile` の `CONFIG_TARGET` (`dein nvim terminator tmux alacritty zsh efm-langserver starship.toml`) は、`~/.config` がまだ実ディレクトリだった初回セットアップ時にのみ意味を持つ後続ループ。`~/.config` が symlink になった後は自分自身を指す no-op であり、**deploy 対象の絞り込みとしては機能していない**。ここにリストが無いから deploy されない、と判断しないこと (実際 `ghostty` `mise` は `CONFIG_TARGET` に無いが deploy されている)。

wildcard 収集の副作用として、`.github` や `.serena` といったリポジトリ運用用のディレクトリも `~/` へ symlink される。ルート直下に `.` 始まりのものを新設するときは、それが `$HOME` に置かれて困らないか確認すること。

確認は `make -n deploy` で実際の `ln` コマンド列を見るのが早い。

## zsh 起動アーキテクチャ

起動時間はこのリポジトリの第一級の制約で、実測の履歴が `SPEED_HISTORY.md` に残っている (現状 M4 で約 0.19s)。`.zshrc` に素の重い初期化を足すと簡単に壊れるため、以下の構造を維持すること。

- `source` 関数自体を上書きし、読み込み前に `zcompile` して `.zwc` を作る (`.zshrc` 冒頭)
- p10k の instant prompt が先頭にあり、**入力を要求する初期化はこれより上**にしか置けない
- プラグインは `zinit` の `wait'N' lucid` で 0〜4 の段階に分けて遅延ロード (`.config/zsh/zinit.zsh`)
- `compinit` は `zsh-users/zsh-completions` の `wait'2' atload"zicompinit; zicdreplay"` と `zsh-defer -t 1` で走る。**`fpath` への追加はこれより前に**行う必要がある (過去のハマりどころは `.serena/memories/zsh_completion_fixes_202602.md` に記録あり)
- kubectl / helm / terraform 等の補完は `.config/zsh/lazy_completion.zsh` で「同名関数を定義し、初回呼び出し時に `unfunction` して本物の補完を読む」方式

PATH には TMUX ガードがある。`.zshrc` の PATH 設定の大半は `if [ -z "$TMUX" ]` の内側にあり、tmux 内では親シェルからの継承に任せる。ただし Homebrew の `bin` だけはガードの外に出してある (システムの `/bin/bash` 3.2 に隠されるのを防ぐため。コード内にコメントあり)。ここを整理するときは意図を壊さないこと。

## zsh 関数の追加

`.config/zsh/functions/` は 1 ファイル 1 関数の autoload 形式。追加時は 3 箇所を触る。

1. `.config/zsh/functions/<name>` に関数本体
2. `.config/zsh/utils.zsh` に `autoload -Uz <name>` (ZLE widget にするなら `zle -N` と `bindkey` も)
3. `.config/zsh/functions/README.md` に一行説明

## Neovim

dein.vim + toml 管理。`.config/nvim/init.vim` が `lsp.toml` / `plugins.toml` / `copilot.toml` / (nvim のみ) `neovim.toml` を eager、`lazy.toml` を lazy でロードする。プラグインの追加・設定は init.vim ではなく該当 toml の `[[plugins]]` へ書く。

## 生成物として扱うファイル

`pkg/brew.txt` `pkg/cask.txt` `pkg/gopkg.txt` `pkg/npm.txt` は `make update` が実機の状態から書き出す**生成物**。手で編集せず、環境側を変えてから `make update` を回す。

## ローカル秘匿設定の gist 同期

`install/local.sh` (取得) と `hack/update-local.zsh` (書き戻し) が、gist ID ハードコードで `~/.aws/config` `~/.gitconfig` `~/.gitconfig.local` `~/.zshrc.local` `~/.ssh/config` `~/.saml2aws` `~/.zsh_history` を出し入れする。どちらも既存ファイルを無条件で上書きするため、依頼されない限り実行しない。`make update` は `hack/update-local.zsh` (gist への書き戻し) を含む点に注意。

## PR の扱い

`.github/workflows/automerge.yml` により PR は条件を満たすと自動マージされる。PR に `/rebase` とコメントすると `rebase.yml` が rebase する。commit メッセージは英語の Conventional Commits (`feat: update dotfiles` 等) が既存の慣習。
