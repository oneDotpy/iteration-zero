const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.notifyCaregiver = functions.firestore
  .document("notifications/{notifId}")
  .onCreate(async (snap, context) => {
    try {
      const notifData = snap.data();
      const patientId = notifData.patientId;
      const patientName = notifData.patientName;
      const action = notifData.action;
      const threshold = notifData.threshold;

      console.log("Notification triggered:", {patientId, patientName, action, threshold});

      const actionLabels = {
        feel_unsure: "I feel unsure",
        hear_voice: "Hear a familiar voice",
        breather: "Take a breather",
        app_open: "App opened",
      };

      const actionLabel = actionLabels[action] || action;

      if (!patientId) {
        console.log("No patientId");
        return;
      }

      const patientDoc = await admin.firestore().collection("patients").doc(patientId).get();
      if (!patientDoc.exists) {
        console.log("Patient not found");
        return;
      }

      const caregiverId = patientDoc.data().caregiverId;
      if (!caregiverId) {
        console.log("No caregiver linked");
        return;
      }

      const caregiverDoc = await admin.firestore().collection("users").doc(caregiverId).get();
      if (!caregiverDoc.exists) {
        console.log("Caregiver not found");
        return;
      }

      const fcmToken = caregiverDoc.data().fcmToken;
      if (!fcmToken) {
        console.log("No FCM token");
        return;
      }

      console.log("Sending notification...");
      const message = {
        notification: {
          title: "Alert from " + patientName,
          body: `Used "${actionLabel}" ${threshold}+ times today`,
        },
        token: fcmToken,
      };

      const response = await admin.messaging().send(message);
      console.log("Sent:", response);
    } catch (error) {
      console.error("Error:", error.message);
    }
  });
