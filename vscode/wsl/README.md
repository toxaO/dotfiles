# WSL

WSL では VS Code 本体の設定を別に持つより、Windows 側の VS Code と Remote - WSL を使うのが素直です。

このリポジトリでは、WSL 用の独立した設定ファイルはまだ置かず、Windows 側の `install.ps1` に `ms-vscode-remote.remote-wsl` を含めています。

必要になったら、ここに WSL 専用の補足設定を追加します。
