const db = require('../config/database');

// Sends an in-app reminder once per appointment, one day before the visit.
async function createAppointmentReminders() {
  const [result] = await db.execute(
    `INSERT INTO notifications (target_type,target_account_id,message,link_tab,appointment_id)
     SELECT 'account',a.patient_id,
       CONCAT('เตือน: คุณมีนัดหมายในวันพรุ่งนี้ เวลา ',TIME_FORMAT(a.appt_time,'%H:%i'),' น.'),
       'appts',a.appointment_id
     FROM appointments a
     WHERE a.status='upcoming'
       AND a.appt_date=DATE_ADD(CURDATE(),INTERVAL 1 DAY)
       AND NOT EXISTS (
         SELECT 1 FROM notifications n WHERE n.target_type='account'
           AND n.target_account_id=a.patient_id AND n.appointment_id=a.appointment_id
           AND n.message LIKE 'เตือน: คุณมีนัดหมายในวันพรุ่งนี้%'
       )`
  );
  return result.affectedRows;
}
function startReminderJob() {
  const run = () => createAppointmentReminders().catch(err => console.error('Reminder job failed:',err.message));
  run();
  setInterval(run, 15 * 60 * 1000);
}
module.exports = { createAppointmentReminders, startReminderJob };
