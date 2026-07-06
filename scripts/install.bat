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

:: Install MCP servers
echo Installing MCP servers...
npm install -g @modelcontextprotocol/server-filesystem
npm install -g @modelcontextprotocol/server-sequential-thinking
npm install -g @playwright/mcp
npx playwright install

:: Install uv (for git and fetch MCP)
echo Installing uv...
pip install uv

:: Install superpowers plugin
echo Installing superpowers...
opencode plugin add superpowers@git+https://github.com/obra/superpowers.git

:: Copy global files
echo Copying global config...
if not exist "%USERPROFILE%\.config\opencode\skills" mkdir "%USERPROFILE%\.config\opencode\skills"
copy global\AGENTS.md "%USERPROFILE%\.config\opencode\AGENTS.md"
xcopy /E /I global\skills "%USERPROFILE%\.config\opencode\skills"

echo.
echo Done. Manual steps:
echo 1. Run: opencode auth login
echo 2. Edit %%USERPROFILE%%\.config\opencode\opencode.jsonc
echo    - Copy from global\opencode-config.example.jsonc
echo    - Replace /YOUR/HOME/PATH with your actual path (use backslashes)
echo    - Replace YOUR_DIRECTUS_TOKEN if using Directus
echo 3. On first run — select your model
echo.
echo Note: RTK is not available on Windows without WSL.
echo Note: 'make' commands require chocolatey: choco install make
echo       Or run scripts directly: node scripts\init-project.js
echo.
pause
