#!/bin/bash
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD="$ROOT/wallpaper_build"
HTML="$ROOT/wallpaper.html"
IMG="$BUILD/wallpaper.png"

# Ensure build directory exists
mkdir -p "$BUILD"

# Create Playwright script inside build folder
cat > "$BUILD/capture_playwright.js" << 'EOF'
const { chromium } = require('playwright');

(async () => {
    const browser = await chromium.launch();
    const page = await browser.newPage();
    
    // Set exact viewport
    await page.setViewportSize({ width: 1920, height: 1080 });
    
    // Navigate to your HTML
    await page.goto(`file://${process.argv[2]}`);
    
    // Wait for JavaScript execution
    await page.waitForTimeout(5000);
    
    // Take screenshot with exact dimensions
    await page.screenshot({ 
        path: process.argv[3],
        fullPage: false,
        clip: { x: 0, y: 0, width: 1920, height: 1080 }
    });
    
    await browser.close();
})();
EOF

# Install Playwright inside build folder if needed
cd "$BUILD"
if ! npm list playwright &> /dev/null; then
    echo "Installing Playwright..."
    npm init -y
    npm install playwright
    npx playwright install chromium
fi

# Generate screenshot
node "$BUILD/capture_playwright.js" "$HTML" "$IMG"

# Apply as wallpaper
gsettings set org.gnome.desktop.background picture-uri-dark "file://$IMG"
