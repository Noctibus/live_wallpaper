#!/bin/bash
ROOT="$HOME/apps/live_wallpaper"
HTML="$ROOT/wallpaper.html"
IMG="$ROOT/wallpaper.png"

# Create Playwright script
cat > "$ROOT/capture_playwright.js" << 'EOF'
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

# Install Playwright if needed
if ! npm list playwright &> /dev/null; then
    echo "Installing Playwright..."
    cd "$ROOT" && npm init -y && npm install playwright
    npx playwright install chromium
fi

# Generate screenshot
cd "$ROOT" && node capture_playwright.js "$HTML" "$IMG"

# Apply as wallpaper
gsettings set org.gnome.desktop.background picture-uri "file://$IMG"