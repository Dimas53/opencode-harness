@echo off
echo === OpenCode Harness Setup (Windows) ===

:: Check Node.js
node --version >nul 2>&1
if errorlevel 1 (
    echo Node.js not found. Install from: https://nodejs.org
    pause
    exit /b 1
)

:: Install OpenCode
echo Installing OpenCode...
npm install -g opencode-ai

:: Install uv (for git and fetch MCP)
echo Installing uv...
pip install uv
echo uv installed for git and fetch MCP

:: Install MCP servers
echo Installing MCP servers...
npm install -g @modelcontextprotocol/server-filesystem
REM git MCP runs via uvx (pip install uv first)
REM fetch MCP runs via uvx
REM context7 is remote — no install needed
npm install -g @modelcontextprotocol/server-sequential-thinking
npm install -g @playwright/mcp
npx playwright install

:: Install Chrome DevTools MCP
npm install -g chrome-devtools-mcp

:: Install superpowers plugin
echo Installing superpowers...
opencode plugin add superpowers@git+https://github.com/obra/superpowers.git

:: Verify superpowers installed correctly
setlocal enabledelayedexpansion
set SKILL_COUNT=0
for /f %%i in ('dir /b "%USERPROFILE%\.config\opencode\skills\" 2^>nul ^| find /c /v ""') do set SKILL_COUNT=%%i
if %SKILL_COUNT% LSS 10 (
    echo WARNING: Superpowers may not have installed correctly.
    echo Skills found: %SKILL_COUNT% ^(expected 40+^)
    echo Try: opencode plugin add superpowers@git+https://github.com/obra/superpowers.git
) else (
    echo Skills installed: %SKILL_COUNT%
)
endlocal

:: Copy global files
echo Copying global config...
if not exist "%USERPROFILE%\.config\opencode\skills" mkdir "%USERPROFILE%\.config\opencode\skills"
copy global\AGENTS.md "%USERPROFILE%\.config\opencode\AGENTS.md"
xcopy /E /I global\skills "%USERPROFILE%\.config\opencode\skills"

echo.
echo Done. Manual steps:
echo 1. Run: opencode auth login
echo 2. Copy and rename config file:
echo    copy global\opencode-config.example.jsonc %%USERPROFILE%%\.config\opencode\opencode.jsonc
echo    Then edit: replace /YOUR/HOME/PATH and YOUR_DIRECTUS_TOKEN
echo    Skip if opencode.jsonc already exists — do NOT overwrite
echo 3. On first run — select your model
echo.
echo Note: RTK is not available on Windows without WSL.
echo Note: 'make' commands require chocolatey: choco install make
echo       Or run scripts directly: node scripts\init-project.js
echo.
pause
