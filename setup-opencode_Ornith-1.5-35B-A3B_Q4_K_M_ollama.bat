@echo off
setlocal
chcp 65001 >nul
title Ornith 35B (Colab) -^> OpenCode setup

echo.
echo  ============================================================
echo   Ornith-1.5-35B (Colab Ollama) -^> OpenCode provider setup
echo  ============================================================
echo   1. In the Colab notebook, run the tunnel cell (cell 6)
echo   2. Copy the URL it prints, e.g. https://xxxx.trycloudflare.com
echo  -----------------------------------------------------------
echo.

set /p URL=Paste the tunnel URL here: 
if not defined URL goto :nourl
if "%URL%"=="" goto :nourl

set "PSFILE=%TEMP%\opencode_colab_setup.ps1"

>  "%PSFILE%" echo param($Url)
>> "%PSFILE%" echo $p = Join-Path $env:USERPROFILE '.config\opencode\opencode.json'
>> "%PSFILE%" echo $burl = ($Url.TrimEnd('/').TrimEnd('\') -replace '/v1$','') + '/v1'
>> "%PSFILE%" echo if (Test-Path $p) { $cfg = ConvertFrom-Json (Get-Content $p -Raw) } else { $cfg = New-Object PSObject }
>> "%PSFILE%" echo $modelId = 'hf.co/ornith-ai/Ornith-1.5-35B-A3B-GGUF:Q4_K_M'
>> "%PSFILE%" echo $prov = @{ npm = '@ai-sdk/openai-compatible'; name = 'Ornith 35B (Colab)'; options = @{ baseURL = $burl; apiKey = 'ollama' }; models = @{ $modelId = @{ name = 'Ornith-1.5-35B-A3B Q4_K_M' } } }
>> "%PSFILE%" echo if ($cfg.PSObject.Properties.Match('provider').Count -gt 0) { Add-Member -InputObject $cfg.provider -Force -MemberType NoteProperty -Name 'colab-ollama' -Value $prov } else { Add-Member -InputObject $cfg -Force -MemberType NoteProperty -Name 'provider' -Value (@{ 'colab-ollama' = $prov }) }
>> "%PSFILE%" echo [void][IO.Directory]::CreateDirectory((Split-Path $p))
>> "%PSFILE%" echo [IO.File]::WriteAllText($p, (ConvertTo-Json -InputObject $cfg -Depth 12))
>> "%PSFILE%" echo Write-Host ''
>> "%PSFILE%" echo Write-Host ('OK: provider "colab-ollama" saved to ' + $p)
>> "%PSFILE%" echo Write-Host ('baseURL: ' + $burl)
>> "%PSFILE%" echo Write-Host 'model: Ornith-1.5-35B-A3B Q4_K_M'
>> "%PSFILE%" echo Write-Host 'In OpenCode, pick the model named: Ornith 35B (Colab)'

powershell -NoProfile -ExecutionPolicy Bypass -File "%PSFILE%" "%URL%"
set "RC=%ERRORLEVEL%"
del "%PSFILE%" >nul 2>&1

echo.
if "%RC%"=="0" (
    echo  Done. Restart OpenCode and select: Ornith 35B (Colab)
) else (
    echo  Something went wrong ^(code %RC%^). Check the URL and try again.
)
echo.
pause
exit /b 0

:nourl
echo  No URL entered - nothing changed.
pause
exit /b 1
