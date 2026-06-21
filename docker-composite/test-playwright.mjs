#!/usr/bin/env node
// Verify playwright can detect JS errors by injecting one and catching it
import { chromium } from 'playwright'

const browser = await chromium.launch()
const page = await browser.newPage()

let errorCaught = false
page.on('pageerror', () => { errorCaught = true })

// Navigate to a page with a deliberate JS error
await page.goto('data:text/html,<script>undefined.forceError()</script>')
await page.waitForTimeout(100) // Give error handler time to fire

await browser.close()

if (!errorCaught) {
    console.error('❌ Playwright failed to detect injected JS error')
    process.exit(1)
}

console.log('✓ Playwright + Chromium can detect JS errors')
