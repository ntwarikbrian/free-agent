@echo off
setlocal
chcp 65001 >nul
title Colab LLM -^> OpenCode setup

echo.
echo  ============================================================
echo   Colab model -^> OpenCode provider setup
echo  ============================================================
echo   1. In the Colab notebook, run the last cell (FIX THE API) and copy
echo      the URL and the API KEY it prints, e.g. https://xxxx.trycloudflare.com
echo  -----------------------------------------------------------
echo.

set /p URL=Paste the tunnel URL here: 
if not defined URL goto :nourl
if "%URL%"=="" goto :nourl

echo.
echo  Paste the API KEY shown by the notebook's last cell
echo  (press Enter to use the legacy key "ollama").
set "APIKEY="
set /p APIKEY=API key [default ollama]: 
if "%APIKEY%"=="" set "APIKEY=ollama"

echo.
echo  Which model is running on the Colab VM right now?
echo    1. Ornith-1.5-35B-A3B Q4_K_M   (Ollama notebook)
echo    2. Ternary-Bonsai-2-27B Q2_0   (llama.cpp notebook)
echo    3. Both
set "MODEL="
set /p MODEL=Choose 1, 2 or 3 [default 3]: 
if "%MODEL%"=="" set "MODEL=3"

set "PSFILE=%TEMP%\opencode_colab_setup.ps1"

>  "%PSFILE%" echo param($Url, $Choice, $ApiKey)
>> "%PSFILE%" echo $p = Join-Path $env:USERPROFILE '.config\opencode\opencode.json'
>> "%PSFILE%" echo $burl = ($Url.TrimEnd('/').TrimEnd('\') -replace '/v1$','') + '/v1'
>> "%PSFILE%" echo if (Test-Path $p) { $cfg = ConvertFrom-Json (Get-Content $p -Raw) } else { $cfg = New-Object PSObject }
>> "%PSFILE%" echo $ornith = @{ 'hf.co/ornith-ai/Ornith-1.5-35B-A3B-GGUF:Q4_K_M' = @{ name = 'Ornith-1.5-35B-A3B Q4_K_M' } }
>> "%PSFILE%" echo $bonsai = @{ 'bonsai-2-27b' = @{ name = 'Ternary-Bonsai-2-27B Q2_0 (llama.cpp)' } }
>> "%PSFILE%" echo if ($Choice -eq '1') { $models = $ornith; $name = 'Ornith 35B (Colab)' } elseif ($Choice -eq '2') { $models = $bonsai; $name = 'Bonsai 2 27B (Colab)' } else { $models = $ornith + $bonsai; $name = 'Colab Models (Ornith + Bonsai)' }
>> "%PSFILE%" echo $prov = @{ npm = '@ai-sdk/openai-compatible'; name = $name; options = @{ baseURL = $burl; apiKey = $ApiKey }; models = $models }
>> "%PSFILE%" echo if ($cfg.PSObject.Properties.Match('provider').Count -gt 0) { Add-Member -InputObject $cfg.provider -Force -MemberType NoteProperty -Name 'colab-ollama' -Value $prov } else { Add-Member -InputObject $cfg -Force -MemberType NoteProperty -Name 'provider' -Value (@{ 'colab-ollama' = $prov }) }
>> "%PSFILE%" echo [void][IO.Directory]::CreateDirectory((Split-Path $p))
>> "%PSFILE%" echo [IO.File]::WriteAllText($p, (ConvertTo-Json -InputObject $cfg -Depth 12))
>> "%PSFILE%" echo Write-Host ''
>> "%PSFILE%" echo Write-Host ('OK: provider "colab-ollama" saved to ' + $p)
>> "%PSFILE%" echo Write-Host ('baseURL: ' + $burl)
>> "%PSFILE%" echo Write-Host ('model(s): ' + ($models.Keys -join ', '))
>> "%PSFILE%" echo Write-Host ('In OpenCode, pick the provider: ' + $name)

powershell -NoProfile -ExecutionPolicy Bypass -File "%PSFILE%" "%URL%" "%MODEL%" "%APIKEY%"
set "RC=%ERRORLEVEL%"
del "%PSFILE%" >nul 2>&1

echo.
if "%RC%"=="0" (
    echo  Done. Restart OpenCode and pick the provider shown above.
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
