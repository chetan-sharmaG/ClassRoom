const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();
exports.sendNotification = functions.firestore
    .document('{courseSemester}/{subjectName}/notes/{notesName}')
    .onCreate(async(snapshot, context) => {
    const notesDetail = snapshot.data();
    var courseDetails = context.params.courseSemester;
    var course = courseDetails.split(' ')[0];
    const match = courseDetails.match(/\d+/);
    const semesterNumber = match ? parseInt(match[0], 10) : null;
    console.log(courseDetails);
    console.log(semesterNumber);
    console.log(course);


//    const payload = {
//        notification: {
//            title: 'New NOte has been Added to the Database',
//             body: notesDetail.note_name
//        },
//        topic:'notes'
// };
var tokens = [];
            var username = [];
            var userDocs = await admin.firestore().collection('Users').where('currentSemester', '==', semesterNumber).where('course', '==', course).get().
                then(querySnapshot => {
                    querySnapshot.forEach(doc => {
                        //console.log(doc.data());
                        console.log(doc.data().token);
                        tokens.push(doc.data().token);
                        username.push(doc.data().username);
                    })
                });

            const personalizedPayloads = tokens.map((token, index) => {
                return {
                    token: token,
                    payload: {
                        notification: {
                            title: `Hey ${username[index]}`,
                            body: "🚀 New notes alert! Dive into the Library and elevate your learning game! 📚 Check it out now!",
                        }
                    }
                };
            });

            console.log('-------------' + tokens.length);
            console.log('-------------' + tokens);

            const messagingPromises = personalizedPayloads.map(({ token, payload }) => {
                if (token && payload) {
                    return admin.messaging().sendToDevice(token, payload);
                } else {
                    return null;
                }
            });

            return Promise.all(messagingPromises);
//return admin.messaging().send(payload);
 });

//exports.sendEventNotificationOnCreation = functions.firestore
//    .document('events/{eventId}')
//    .onCreate(async(snapshot,context)=>{
//    const eventDetails = snapshot.data();
//    const eventName = eventDetails.title;
//    const group = eventDetails.group;
//
//    var isGroupAll = group.toUpperCase()=='ALL';
//
//    if(!isGroupAll){
//
//        var groupSemester = group.split(' ')[0];
//        var groupCourse = group.split(' ')[1];
//        var groupSection = group.split(' ')[2];
//
//        console.log(groupCourse);
//        var tokens = [];
//        var username = [];
//        var userDocs = await admin.firestore().collection('Users').where('currentSemester', '==', parseInt(groupSemester,10)).where('currentSection', '==', groupSection).where('course','==',groupCourse).get().
//        then(querySnapshot =>{
//        querySnapshot.forEach(doc=>{
//        //console.log(doc.data());
//        console.log(doc.data().token);
//        tokens.push(doc.data().token);
//        username.push(doc.data().username);
//        })});
//        const payload = {
//                          notification: {
//                            title: "Hey ",
//                            body: "your calendar just whispered a secret – a new event is in town! Dive into the academic adventure or dance with deadlines, your calendar's got the moves! Check it out before FOMO enrolls in your class!",
//                          }
//                        };
//
////
//           console.log('-------------'+tokens.length);
//           console.log('-------------'+tokens);
//
//        if (tokens.length > 0) {
//          return await admin.messaging().sendToDevice(tokens, payload);
//        }else{
//        return null;
//        }
//    }
exports.sendEventNotificationOnCreation = functions.firestore
    .document('events/{eventId}')
    .onCreate(async (snapshot, context) => {
        const eventDetails = snapshot.data();
        const eventName = eventDetails.title;
        const group = eventDetails.group;

        var isGroupAll = group.toUpperCase() == 'ALL';

        if (!isGroupAll) {

            var groupSemester = group.split(' ')[0];
            var groupCourse = group.split(' ')[1];
            var groupSection = group.split(' ')[2];

            console.log(groupCourse);
            var tokens = [];
            var username = [];
            var userDocs = await admin.firestore().collection('Users').where('currentSemester', '==', parseInt(groupSemester, 10)).where('currentSection', '==', groupSection).where('course', '==', groupCourse).get().
                then(querySnapshot => {
                    querySnapshot.forEach(doc => {
                        //console.log(doc.data());
                        console.log(doc.data().token);
                        tokens.push(doc.data().token);
                        username.push(doc.data().username);
                    })
                });

            const personalizedPayloads = tokens.map((token, index) => {
                return {
                    token: token,
                    payload: {
                        notification: {
                            title: `Hey ${username[index]}`,
                            body: "your calendar just whispered a secret – a new event is in town! Dive into the academic adventure or dance with deadlines, your calendar's got the moves! Check it out before FOMO enrolls in your class!",
                        }
                    }
                };
            });

            console.log('-------------' + tokens.length);
            console.log('-------------' + tokens);

            const messagingPromises = personalizedPayloads.map(({ token, payload }) => {
                if (token && payload) {
                    return admin.messaging().sendToDevice(token, payload);
                } else {
                    return null;
                }
            });

            return Promise.all(messagingPromises);
        }else{
    const payload = {
              notification: {
                title: "Hey 😈",
                body: "your calendar just whispered a secret – a new event is in town! Dive into the academic adventure or dance with deadlines, your calendar's got the moves! Check it out before FOMO enrolls in your class!",
              },
              topic:'all'
            };
       return admin.messaging().send(payload);
    }




    })