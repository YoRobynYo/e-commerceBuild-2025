# HTML

A modern HTML project utilizing Tailwind CSS for building responsive web applications with minimal setup.

## 🚀 Features

- **HTML5** - Modern HTML structure with best practices
- **compiled CSS** - Utility-first CSS framework for rapid UI development
- **Custom Components** - Pre-built component classes for buttons and containers
- **NPM Scripts** - Easy-to-use commands for development and building
- **Responsive Design** - Mobile-first approach for all screen sizes

## 📋 Prerequisites

- Node.js (v12.x or higher)
- npm or yarn

## 🛠️ Installation

1. Install dependencies:
```bash
npm install
```

2. Start the development server:
```bash
npm run dev
```

## 📁 Project Structure

```
html_app/
├── css/
│   ├── storefront.scss # compiled source file with custom utilities
│   └── storefront.css  # Compiled CSS (generated)
├── pages/              # Landing Page
├── index.html          # Main entry point
├── package.json        # Project dependencies and scripts
└── storefront.scss     # compiled CSS configuration
```

## 🎨 Styling

This project uses compiled CSS for styling. Custom utility classes include:


## 🧩 Customization

To customize the compiled configuration, edit the `storefront` file:


## 📦 Build for Production

Build the CSS for production:

```bash
use the automatic compiler from the package.json files
```

## 📱 Responsive Design

The app is built with responsive design using mobile CSS breakpoints::

- `sm`: 640px and up
- `md`: 768px and up
- `lg`: 1024px and up
- `xl`: 1280px and up
- `2xl`: 1536px and up

## 🙏 Acknowledgments

- Built with HTML, SCSS, and JavaScript

## Live Sass Watcher Setup Guide

This guide explains how to set up and use a live Sass compiler for automatic recompilation of SCSS files in the `storefront` project.

### Prerequisites
- Node.js and npm installed.
- Sass installed as a dev dependency (via `npm install`).

### Step 1: Confirm and Update the Script in `package.json`
Ensure your `storefront/package.json` has the following `"build-css"` script for live watching:

```json
{
  "name": "storefront",
  "version": "1.0.0",
  "description": "A storefront app",
  "main": "main.js",
  "scripts": {
    "start": "electron .",
    "build": "sass css/storefront.scss css/storefront.css",
    "build-css": "sass css/storefront.scss css/storefront.css --source-map --watch"
  },
  // ... rest of the file ...
}
```

- **Notes**: The `--watch` flag enables live monitoring and recompilation. `--source-map` generates debugging maps.

### Step 2: Install Dependencies
If not already done:
1. Open your terminal.
2. Navigate to the project folder: `cd /Users/robynmai/DeskumentProjects/LandingPage-776543/storefront`.
3. Run: `npm install`.

### Step 3: Run the Live Watcher
1. In the terminal (from the `storefront` folder), run: `npm run build-css`.
2. Expected output: "Sass is watching for changes. Press Ctrl-C to stop."
3. The watcher starts monitoring `storefront.scss`.

### Step 4: Make Changes and See Live Updates
1. Edit `storefront.scss` in your editor.
2. Save the file.
3. Terminal will show: "Compiled css/storefront.scss to css/storefront.css."
4. Refresh your Electron app or use dev tools to view updates.

### Step 5: Stop the Watcher
- Press `Ctrl + C` (or `Cmd + C` on Mac) in the terminal.

### Tips and Troubleshooting
- **No output?** Verify Sass installation and file paths.
- **Electron Integration**: For auto-reload on CSS changes, install `electron-reload` via npm and require it in `main.js`.
- **Source Maps**: Use browser dev tools to debug original SCSS with the generated `.map` file.
- **Errors**: If "sass command not found", try `npx sass` or reinstall dependencies.

This setup ensures efficient development with live SCSS updates.

## Features Section Styles (Locked-In Settings)

### Features Title (.section-header h2)
- **Font Size**: 2.5rem
- **Font Family**: 'Poppins', sans-serif
- **Color**: var(--dark)
- **Background**: White
- **Padding**: 10px 20px
- **Border Radius**: 5px
- **Display**: Inline-block
- **Margins**: 1rem top (16px), 54px bottom (for 70px total spacing)

### Features Paragraph (.section-header .info-1)
- **Font Size**: 1.1rem
- **Font Family**: 'Trirong', serif
- **Color**: var(--gray)
- **Max Width**: 600px
- **Margin**: 0 auto 70px (centered block, 70px bottom)
- **Line Height**: 1.4
- **Text Align**: Center (block centered, text centered)

These settings provide balanced spacing, professional typography, and a clean layout. No further changes to these elements for now.

We can also follow these guidelines ::
We can also follow these guide lines ::

What makes a high-converting landing page?

Before we look at the examples, let's quickly cover what your landing page needs to achieve:

    Compelling headline that immediately communicates value

    Concise, benefit-focused copy without unnecessary jargon

    Strong, attention-grabbing visuals that support your message

    Strategic use of social proof (testimonials, client logos, reviews)

    Clear, prominent call-to-action buttons with action-oriented text

    Minimal navigation to maintain focus on conversion

    Responsive design that works flawlessly across all devices

    Fast loading speed to prevent abandonment

    Form fields limited to essential information only

    Consistent branding that builds trust and recognition

    and also 

    Technical requirements and dimensions

    When creating your landing page, keep these specifications in mind:

    Page load time: As fast as possible for maximum retention

    Mobile responsiveness: Must adapt seamlessly to all device sizes

    Image optimisation: Compress all images without quality loss

    Headline length: 10 words or fewer for maximum impact

    CTA button size: Large enough for easy mobile tapping

    Form fields: As few as possible for optimal completion rates

    Page length: Depends on complexity of offer

    White space: Generous padding around key elements

    Colour contrast: Sufficient for easy reading

    Font size: Large enough for comfortable reading on all devices

    
