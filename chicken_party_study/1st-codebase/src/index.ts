import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
admin.initializeApp();
export const updateProfileOnNicknameChange = functions.firestore
  .document("users/{userId}")
  .onUpdate((change, context) => {
    const newData = change.after.data();
    const previousData = change.before.data();

    if (newData.nickname !== previousData.nickname) {
      const profileRef = admin
        .firestore()
        .collection("profiles")
        .doc(context.params.userId);
      return profileRef.update({nickname: newData.nickname});
    }
    return null;
  });
