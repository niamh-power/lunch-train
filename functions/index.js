// The Cloud Functions for Firebase SDK to create Cloud Functions and setup triggers.
const functions = require('firebase-functions');

// The Firebase Admin SDK to access the Firebase Realtime Database.
const admin = require('firebase-admin');
admin.initializeApp();

// Take the text parameter passed to this HTTP endpoint and insert it into the
// Realtime Database under the path /messages/:pushId/original
exports.addMessage = functions.https.onRequest((req, res) => {
    // Grab the text parameter.
    const original = req.query.text;
    // Push the new message into the Realtime Database using the Firebase Admin SDK.
    return admin.database().ref('/messages').push({original: original}).then((snapshot) => {
      // Redirect with 303 SEE OTHER to the URL of the pushed object in the Firebase console.
      return res.redirect(303, snapshot.ref.toString());
    });
  });
  

// Create and Deploy Your First Cloud Functions
// https://firebase.google.com/docs/functions/write-firebase-functions

exports.helloWorld = functions.https.onRequest((request, response) => {
 response.send("Hello from Firebase!");
});

// Listens for new messages added to /messages/:pushId/original and creates an
// uppercase version of the message to /messages/:pushId/uppercase
exports.makeUppercase = functions.database.ref('/messages/{pushId}/original')
    .onCreate((snapshot, context) => {
      // Grab the current value of what was written to the Realtime Database.
      const original = snapshot.val();
      console.log('Uppercasing', context.params.pushId, original);
      const uppercase = original.toUpperCase();
      // You must return a Promise when performing asynchronous tasks inside a Functions such as
      // writing to the Firebase Realtime Database.
      // Setting an "uppercase" sibling in the Realtime Database returns a Promise.
      return snapshot.ref.parent.child('uppercase').set(uppercase);
    });

exports.newPassenger = functions.firestore.document('trains/passengers/{userId}').onCreate((snap, context) => {
    const newValue = snap.data

    const payload = {
        notification: {
            title: `${newValue.userName} just joined your train!`,
            body: ``,
            icon: `photoUrl`,
            sound: `default`,
            clickAction: `fcm.ACTION.HELLO`,
        }
    };

    const options = {
        collapseKey: 'demo',
        contentAvailable: true,
    };

    var tokenForOwner = newValue.parent.ownerId;

    print(tokenForOwner);
});   

exports.newTrain = functions.firestore.document('trains/{title}').onCreate((snap, context) => {
    const newValue = snap.data;
    //const name = newValue.name.toString();

        // Notification details.
    const payload = {
        notification: {
            title: 'A new train has been created!',
            body: `${newValue.owner} just created a new train to "${newTrain.location}".`,
            icon: 'photoURL',
            sound: 'default',
            clickAction: 'fcm.ACTION.HELLO',
        }
    };
   
    // Set the message as high priority and have it expire after 24 hours.
    const options = {
        collapseKey: 'demo',
        contentAvailable: true,
      };

      // Send a message to devices subscribed to the provided topic.
    const topic = `trains`;

    return admin.messaging().sendToTopic(topic, payload, options)
      .then((response) => {
        console.log('Successfully sent message:', response);
        return response.messageId
    });
});
