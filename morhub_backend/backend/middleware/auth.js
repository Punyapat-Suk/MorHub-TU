const jwt = require('jsonwebtoken');
const { httpError } = require('../utils/http');

function authenticate(req, res, next) {
  try {
    const header = req.headers.authorization || '';
    const token = header.startsWith('Bearer ') ? header.slice(7) : null;
    if (!token) throw httpError(401, 'กรุณาเข้าสู่ระบบ');
    req.user = jwt.verify(token, process.env.JWT_SECRET);
    next();
  } catch (error) {
    next(error.status ? error : httpError(401, 'Token ไม่ถูกต้องหรือหมดอายุ'));
  }
}
function allowRoles(...roles) {
  return (req, res, next) => {
    if (!req.user || !roles.includes(req.user.role)) return next(httpError(403, 'ไม่มีสิทธิ์ใช้งาน')); 
    next();
  };
}
module.exports = { authenticate, allowRoles };
