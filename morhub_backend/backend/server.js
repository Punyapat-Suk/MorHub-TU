require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const db = require('./config/database');
const { notFound,errorHandler } = require('./middleware/errorHandler');
const { startReminderJob } = require('./services/reminderJob');

if (!process.env.JWT_SECRET || process.env.JWT_SECRET.length < 32) {
  console.error('JWT_SECRET ต้องมีความยาวอย่างน้อย 32 ตัวอักษร');
  process.exit(1);
}
const app = express();
app.disable('x-powered-by');
app.use(helmet());
app.use(cors({ origin: process.env.CLIENT_ORIGIN ? process.env.CLIENT_ORIGIN.split(',') : false }));
app.use(express.json({ limit: '1mb' }));
app.use(express.urlencoded({ extended: false, limit: '1mb' }));
app.use('/api/auth', rateLimit({ windowMs: 15 * 60 * 1000, limit: 30, standardHeaders: true, legacyHeaders: false }));

app.get('/api/health', async (req,res,next) => {
  try { await db.query('SELECT 1'); res.json({ success:true, service:'MorHub TU API', database:'connected' }); }
  catch(e) { next(e); }
});
app.use('/api/auth', require('./routes/auth'));
app.use('/api/doctors', require('./routes/doctors'));
app.use('/api/schedules', require('./routes/schedules'));
app.use('/api/appointments', require('./routes/appointments'));
app.use('/api/checkins', require('./routes/checkins'));
app.use('/api/queues', require('./routes/queues'));
app.use('/api/notifications', require('./routes/notifications'));
app.use('/api/analytics', require('./routes/analytics'));
app.use(notFound);
app.use(errorHandler);

const port = Number(process.env.PORT || 3000);
(async () => {
  try {
    await db.query('SELECT 1');
    app.listen(port, () => {
      console.log(`MorHub TU API running at http://localhost:${port}`);
      startReminderJob();
    });
  } catch (err) {
    console.error('Cannot connect to MySQL:',err.message);
    process.exit(1);
  }
})();
