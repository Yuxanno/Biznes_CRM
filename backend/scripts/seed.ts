import mongoose from 'mongoose';
import bcrypt from 'bcryptjs';

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/business_manager';

async function seed() {
  await mongoose.connect(MONGODB_URI);
  console.log('Connected to MongoDB');

  const db = mongoose.connection.db!;

  // Clear existing data
  await db.collection('users').deleteMany({});
  await db.collection('businessperiods').deleteMany({});
  await db.collection('transactions').deleteMany({});
  await db.collection('orders').deleteMany({});
  await db.collection('customers').deleteMany({});
  await db.collection('debts').deleteMany({});
  await db.collection('categories').deleteMany({});

  // Create demo user
  const hashedPassword = await bcrypt.hash('demo123', 12);
  const user = await db.collection('users').insertOne({
    username: 'demo',
    password: hashedPassword,
    createdAt: new Date(),
    updatedAt: new Date(),
  });
  const userId = user.insertedId;

  // Create period 1 (closed)
  const period1 = await db.collection('businessperiods').insertOne({
    userId,
    name: 'Business Start',
    startDate: new Date('2026-01-01'),
    endDate: new Date('2026-09-30'),
    status: 'closed',
    createdAt: new Date(),
    updatedAt: new Date(),
  });

  // Create period 2 (active)
  const period2 = await db.collection('businessperiods').insertOne({
    userId,
    name: 'New Stage',
    startDate: new Date('2026-10-01'),
    status: 'active',
    createdAt: new Date(),
    updatedAt: new Date(),
  });

  // Categories
  const incomeCats = ['Order', 'Sale', 'Service', 'Other'];
  const expenseCats = ['Materials', 'Transport', 'Tools', 'Salary', 'Advertising', 'Other'];
  for (const name of incomeCats) {
    await db.collection('categories').insertOne({ userId, type: 'income', name, createdAt: new Date() });
  }
  for (const name of expenseCats) {
    await db.collection('categories').insertOne({ userId, type: 'expense', name, createdAt: new Date() });
  }

  // Transactions for period 1
  const p1Transactions = [
    { type: 'income', amount: 3000, category: 'Order', description: 'Website project', date: new Date('2026-02-15') },
    { type: 'income', amount: 1500, category: 'Service', description: 'Consulting', date: new Date('2026-03-10') },
    { type: 'expense', amount: 800, category: 'Materials', description: 'Office supplies', date: new Date('2026-03-15') },
    { type: 'income', amount: 2500, category: 'Order', description: 'Mobile app', date: new Date('2026-05-20') },
    { type: 'expense', amount: 1200, category: 'Salary', description: 'Part-time developer', date: new Date('2026-06-01') },
    { type: 'expense', amount: 500, category: 'Advertising', description: 'Social media ads', date: new Date('2026-07-10') },
  ];
  for (const t of p1Transactions) {
    await db.collection('transactions').insertOne({
      userId, periodId: period1.insertedId, ...t,
      createdAt: new Date(), updatedAt: new Date(),
    });
  }

  // Transactions for period 2
  const p2Transactions = [
    { type: 'income', amount: 2000, category: 'Order', description: 'Logo design', date: new Date('2026-10-02') },
    { type: 'expense', amount: 400, category: 'Transport', description: 'Fuel costs', date: new Date('2026-10-03') },
    { type: 'income', amount: 3000, category: 'Service', description: 'SEO service', date: new Date('2026-10-05') },
    { type: 'expense', amount: 600, category: 'Tools', description: 'Software licenses', date: new Date('2026-10-06') },
  ];
  for (const t of p2Transactions) {
    await db.collection('transactions').insertOne({
      userId, periodId: period2.insertedId, ...t,
      createdAt: new Date(), updatedAt: new Date(),
    });
  }

  // Customers
  const customers = [
    { name: 'John Smith', phone: '+1-555-0101', notes: 'Regular client' },
    { name: 'Sarah Connor', phone: '+1-555-0102', notes: 'Prefers email communication' },
    { name: 'Mike Johnson', phone: '+1-555-0103', notes: '' },
  ];
  const customerIds = [];
  for (const c of customers) {
    const r = await db.collection('customers').insertOne({
      userId, ...c, createdAt: new Date(), updatedAt: new Date(),
    });
    customerIds.push(r.insertedId);
  }

  // Orders
  const orders = [
    {
      title: 'E-commerce Website',
      clientName: 'John Smith',
      clientPhone: '+1-555-0101',
      description: 'Full e-commerce platform with payment integration',
      amount: 5000,
      status: 'in_progress',
      createdDate: new Date('2026-10-01'),
      deadline: new Date('2026-11-01'),
      customerId: customerIds[0],
    },
    {
      title: 'Mobile App Design',
      clientName: 'Sarah Connor',
      clientPhone: '+1-555-0102',
      description: 'UI/UX design for fitness tracking app',
      amount: 2500,
      status: 'new',
      createdDate: new Date('2026-10-05'),
      deadline: new Date('2026-10-25'),
      customerId: customerIds[1],
    },
    {
      title: 'Logo Design',
      clientName: 'Mike Johnson',
      clientPhone: '+1-555-0103',
      description: 'Brand identity package',
      amount: 800,
      status: 'completed',
      createdDate: new Date('2026-10-02'),
      customerId: customerIds[2],
    },
  ];
  for (const o of orders) {
    await db.collection('orders').insertOne({
      userId, periodId: period2.insertedId, ...o,
      photos: [], createdAt: new Date(), updatedAt: new Date(),
    });
  }

  // Debts
  await db.collection('debts').insertOne({
    userId, type: 'owed', personName: 'John Smith', phone: '+1-555-0101',
    amount: 2000, paidAmount: 500, description: 'E-commerce project advance',
    date: new Date('2026-10-01'), dueDate: new Date('2026-11-01'),
    status: 'partial', createdAt: new Date(), updatedAt: new Date(),
  });
  await db.collection('debts').insertOne({
    userId, type: 'owe', personName: 'Web Hosting Co', phone: '',
    amount: 300, paidAmount: 0, description: 'Annual hosting fee',
    date: new Date('2026-10-01'), dueDate: new Date('2026-10-15'),
    status: 'unpaid', createdAt: new Date(), updatedAt: new Date(),
  });

  console.log('✅ Seed data created successfully!');
  console.log('Demo credentials: username=demo, password=demo123');
  await mongoose.disconnect();
}

seed().catch(console.error);
