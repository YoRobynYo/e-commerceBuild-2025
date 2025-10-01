const { contextBridge, ipcRenderer } = require('electron');

// Expose safe APIs to the renderer process (your HTML/JS)
contextBridge.exposeInMainWorld('electronAPI', {
    // Example: Add functions here for cookie handling or payments later
    // e.g., sendToMain: (data) => ipcRenderer.send('to-main', data)
});
