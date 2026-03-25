const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');

initializeApp();
const db = getFirestore();

const ACTION_LABELS = {
  feel_unsure: 'I feel unsure',
  hear_voice: 'Hear a familiar voice',
  breather: 'Take a breather',
  app_open: 'App opened',
};

// Fires when a new doc is written to /notifications/{id}
// (created by FirebaseService._sendThresholdNotification)
exports.notifyCaregiver = onDocumentCreated('notifications/{notifId}', async (event) => {
  const data = event.data.data();
  const { patientName, action, threshold, patientId } = data;

  // Find the patient's caregiver
  const patientDoc = await db.collection('patients').doc(patientId).get();
  if (!patientDoc.exists) return;
  const caregiverId = patientDoc.data().caregiverId;
  if (!caregiverId) return;

  // Get caregiver's FCM token
  const caregiverDoc = await db.collection('users').doc(caregiverId).get();
  if (!caregiverDoc.exists) return;
  const fcmToken = caregiverDoc.data().fcmToken;
  if (!fcmToken) return;

  const actionLabel = ACTION_LABELS[action] ?? action;

  await getMessaging().send({
    token: fcmToken,
    notification: {
      title: `${patientName} needs attention`,
      body: `"${actionLabel}" was used ${threshold} times today.`,
    },
    data: {
      patientId,
      action,
      type: 'threshold_alert',
    },
    apns: {
      payload: {
        aps: {
          sound: 'default',
          badge: 1,
        },
      },
    },
  });

  // Mark the notification as sent
  await event.data.ref.update({ sent: true });
});
