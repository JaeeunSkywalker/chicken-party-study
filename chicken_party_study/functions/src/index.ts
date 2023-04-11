import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

const firestore = admin.firestore();

export const sendPushNotification = functions.firestore
  .document("studiesOnRecruiting/{uid}")
  .onUpdate(async (change, context) => {
    const uid = context.params.uid;

    const study = await firestore
      .collection("studiesOnRecruiting")
      .doc(uid)
      .get();
    const studyData = study.data();

    if (
      studyData &&
      studyData.currentMembers === studyData.numberOfDefaultParticipants
    ) {
      const payload: admin.messaging.MessagingPayload = {
        notification: {
          title: "Title",
          body: "Message",
        },
      };

      const devicesSnapshot = await firestore
        .collection(`studiesOnRecruiting/${uid}/devices`)
        .get();

      const tokens = devicesSnapshot.docs.map((doc) => doc.data().token);

      const response = await admin.messaging().sendToDevice(tokens, payload);

      console.log("Successfully sent message:", response);
    }
  });
