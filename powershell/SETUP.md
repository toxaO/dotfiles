# PowerShell 設定

このディレクトリには、`Tab` で候補をメニュー表示できるようにするための最小構成の PowerShell プロファイルを置いています。

## 何を USB に入れるか

最低限、`powershell` ディレクトリだけを USB に入れます。

例:

```text
USBメモリ
└─ powershell
   ├─ Microsoft.PowerShell_profile.ps1
   ├─ install.ps1
   └─ SETUP.md
```

## どのファイルを PowerShell が読むか

PowerShell が実際に読むのは USB 上のファイルではなく、次のプロファイルファイルです。

- PowerShell 7: `C:\Users\<ユーザー名>\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`
- Windows PowerShell 5.1: `C:\Users\<ユーザー名>\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1`

今回の `install.ps1` は、USB 上の `Microsoft.PowerShell_profile.ps1` をその 2 箇所に配置します。

## ファイルの役割

- `Microsoft.PowerShell_profile.ps1`
  実際の設定本体です。`PSReadLine` が使える環境では、`Tab` を `MenuComplete` に割り当てます。
- `install.ps1`
  このディレクトリ内の `Microsoft.PowerShell_profile.ps1` を、PowerShell が読む標準のプロファイル位置へ配置します。

## 他のマシンで適用する手順

### 1. USB を挿す

たとえば USB が `E:` として見えていて、そこに `powershell` ディレクトリを置いてある前提です。

```text
E:\powershell
```

### 2. PowerShell を開く

`powershell` でも `pwsh` でも構いません。

### 3. スクリプト実行をその場だけ許可する

実行ポリシーで止まる場合があるので、そのセッションだけ一時的に許可します。

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

### 4. USB 上の `install.ps1` を実行する

```powershell
& "E:\powershell\install.ps1"
```

`E:` の部分は実際の USB ドライブ文字に読み替えてください。

### 5. その場で反映する

```powershell
. $PROFILE
```

これで現在のシェルにも設定が反映されます。

## 手動で反映する手順

`install.ps1` を使わず、自分でどのファイルを読むようにするか明示してコピーしたい場合は、USB 上の設定本体を標準のプロファイル位置へ直接コピーします。

```powershell
Copy-Item "E:\powershell\Microsoft.PowerShell_profile.ps1" "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" -Force
Copy-Item "E:\powershell\Microsoft.PowerShell_profile.ps1" "$HOME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" -Force
. $PROFILE
```

この場合も `E:` は実際の USB ドライブ文字に読み替えてください。

## 確認

コマンド補完やディレクトリ補完で `Tab` を試します。

```powershell
git ch<Tab>
cd $HOME\D<Tab>
```

候補が順番に切り替わるだけではなく、一覧表示されてその場で選べれば設定完了です。
