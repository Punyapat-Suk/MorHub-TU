function notFound(req, res) {
  res.status(404).json({ success: false, message: 'ไม่พบ API ที่ร้องขอ' });
}
function errorHandler(err, req, res, next) {
  if (res.headersSent) return next(err);
  const status = err.status || (err.code === 'ER_DUP_ENTRY' ? 409 : 500);
  const message = status === 500 ? 'เกิดข้อผิดพลาดภายในระบบ' : err.message;
  if (process.env.NODE_ENV !== 'production') console.error(err);
  res.status(status).json({ success: false, message });
}
module.exports = { notFound, errorHandler };
