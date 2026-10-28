export default function Home() {
  return (
    <main style={{ fontFamily: 'sans-serif', padding: '2rem' }}>
      <h1>Business Manager API</h1>
      <p>Backend API is running on port 3001.</p>
      <h2>Available endpoints:</h2>
      <ul>
        <li>POST /api/auth/register</li>
        <li>POST /api/auth/login</li>
        <li>GET /api/dashboard</li>
        <li>GET/POST /api/transactions</li>
        <li>GET/POST /api/orders</li>
        <li>GET/POST /api/debts</li>
        <li>GET/POST /api/customers</li>
        <li>GET/POST /api/periods</li>
        <li>GET/POST /api/categories</li>
        <li>GET /api/notifications</li>
      </ul>
    </main>
  )
}
