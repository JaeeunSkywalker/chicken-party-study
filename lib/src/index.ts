import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
//Firebase 초기화: admin.initializeApp() 함수를 사용하여 Firebase Admin SDK를 초기화합니다.
admin.initializeApp();

//클라우드 함수 정의:
//functions.firestore.document() 함수를 사용하여
//users/{userId} 경로에서 문서가 업데이트될 때 실행되는
//onUpdate() 이벤트 핸들러를 정의합니다.
export const updateProfileOnNicknameChange = functions.firestore
  .document("users/{userId}")
  .onUpdate((change, context) => {
    //onUpdate() 이벤트 핸들러:
    //문서 업데이트가 발생하면 이벤트 핸들러가 실행됩니다.
    //이 핸들러에서는 변경된 데이터와 이전 데이터를 가져와서
    //닉네임이 변경되었는지 확인합니다.
    const newData = change.after.data();
    const previousData = change.before.data();

    //if문: 닉네임이 변경되었다면
    //profiles 컬렉션의 해당 사용자 문서를 가져와
    //업데이트합니다.
    if (newData.nickname !== previousData.nickname) {
      const profileRef = admin
        .firestore()
        .collection("profiles")
        .doc(context.params.userId);
      return profileRef.update({ nickname: newData.nickname });
    }
    //return null;: 만약 닉네임이 변경되지 않았다면
    //null을 반환하여 핸들러를 종료합니다.
    return null;
  });
