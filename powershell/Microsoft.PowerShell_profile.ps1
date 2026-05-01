if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine -ErrorAction SilentlyContinue

    if (Get-Module PSReadLine) {
        try {
            # Tab and Ctrl+I usually arrive as the same key code in terminals.
            Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
        }
        catch {
        }

        try {
            Set-PSReadLineOption -BellStyle None
        }
        catch {
        }

        try {
            Set-PSReadLineOption -CompletionQueryItems 200
        }
        catch {
        }

        try {
            $esc = [char]27
            Set-PSReadLineOption -Colors @{
                Selection              = "$esc[30;47m"
                InlinePrediction       = "$esc[90m"
                ListPrediction         = "$esc[33m"
                ListPredictionSelected = "$esc[30;47m"
            }
        }
        catch {
        }

        try {
            Set-PSReadLineOption -PredictionViewStyle ListView
        }
        catch {
        }

        try {
            Set-PSReadLineOption -PredictionSource History
        }
        catch {
        }
    }
}

if ($PSVersionTable.PSVersion.Major -ge 7 -and $PSStyle) {
    $PSStyle.FileInfo.Directory = $PSStyle.Foreground.BrightBlue
    $PSStyle.FileInfo.SymbolicLink = $PSStyle.Foreground.Cyan
    $PSStyle.FileInfo.Executable = $PSStyle.Foreground.BrightGreen
    $PSStyle.FileInfo.Extension['.ps1'] = $PSStyle.Foreground.Yellow
    $PSStyle.FileInfo.Extension['.psm1'] = $PSStyle.Foreground.Yellow
    $PSStyle.FileInfo.Extension['.psd1'] = $PSStyle.Foreground.Yellow
    $PSStyle.FileInfo.Extension['.json'] = $PSStyle.Foreground.BrightYellow
    $PSStyle.FileInfo.Extension['.yml'] = $PSStyle.Foreground.Magenta
    $PSStyle.FileInfo.Extension['.yaml'] = $PSStyle.Foreground.Magenta
    $PSStyle.FileInfo.Extension['.md'] = $PSStyle.Foreground.BrightBlack
}

function .f {
    Set-Location (Split-Path -Parent $PSScriptRoot)
}

function .p {
    $installer = Join-Path $PSScriptRoot "install.ps1"
    if (Test-Path $installer) {
        & $installer
        . $PROFILE
    }
}

function pr {
    $top = git rev-parse --show-toplevel 2>$null
    if ($LASTEXITCODE -eq 0 -and $top) {
        Set-Location $top
    }
}

function nv {
    & nvim @args
}

function ns {
    & nvim -S @args
}

function py {
    & python3 @args
}

function pip {
    & pip3 @args
}

function co {
    & git checkout @args
}

function br {
    & git branch @args
}

function com {
    & git checkout main
}

function cod {
    & git checkout develop
}

function gl {
    & git log --oneline -n 10 @args
}

function ga {
    & git add .
}

function gaa {
    & git add -A
}

function gc {
    & git commit -m @args
}

function gs {
    & git status @args
}

function gf {
    & git fetch @args
}

function gp {
    & git push @args
}

function gpl {
    & git pull @args
}

function gcb {
    & git checkout -b @args
}
