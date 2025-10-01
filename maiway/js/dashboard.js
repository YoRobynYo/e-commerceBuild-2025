/ frontend/src/pages/dashboard.js
function Dashboard() {
  return (
    <div>
      {/* Your existing dashboard */}
      <Toggle 
        label="Enable AI Cart Recovery" 
        onChange={(enabled) => api.post('/automation/toggle', { enabled })} 
      />
    </div>
  )
}