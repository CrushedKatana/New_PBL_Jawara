import { initializeFirebase } from './config/firebase';
import { FirestoreService } from './services/firestore';

const firebaseApp = initializeFirebase();
const firestoreService = new FirestoreService(firebaseApp);

// Example usage
async function run() {
    try {
        const docId = 'exampleDocId';
        const data = { name: 'John Doe', age: 30 };

        // Add a document
        await firestoreService.addDocument('users', docId, data);
        console.log('Document added successfully.');

        // Get the document
        const doc = await firestoreService.getDocument('users', docId);
        console.log('Document retrieved:', doc);

        // Update the document
        const updatedData = { age: 31 };
        await firestoreService.updateDocument('users', docId, updatedData);
        console.log('Document updated successfully.');
    } catch (error) {
        console.error('Error:', error);
    }
}

run();