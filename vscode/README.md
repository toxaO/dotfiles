# VS Code

このディレクトリは VS Code の共通設定と、macOS / Windows / WSL 向けの導入入口を置く場所です。

## 使い方

### macOS

```sh
sh vscode/install.sh
```

### Windows

1. VS Code を入れる
2. `code` コマンドを使えるようにする
   - VS Code で `Ctrl+Shift+P`
   - `Shell Command: Install 'code' command in PATH` を実行する
   - もしこの項目が見つからない場合は、VS Code を通常の方法で再起動してからもう一度試す
3. このリポジトリのルートで次を実行する

```powershell
powershell -ExecutionPolicy Bypass -File vscode/windows/install.ps1
```

4. VS Code を再起動する

### WSL

WSL では VS Code 本体を別に設定するより、Windows 側の VS Code と `Remote - WSL` を使う前提です。

1. Windows 側で `vscode/windows/install.ps1` を実行する
2. VS Code で `Remote - WSL` 拡張が入っていることを確認する
3. WSL のターミナルから対象ディレクトリを開く

```sh
code .
```

## 構成

- `common/`: OS 共通の設定
- `mac/`: macOS 向けの導入ファイル
- `windows/`: Windows 向けの導入ファイル
- `wsl/`: WSL 利用時の補足
