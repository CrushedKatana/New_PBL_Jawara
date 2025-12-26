import { Firestore, collection, addDoc, doc, getDoc, updateDoc } from 'firebase/firestore';
import { initializeFirebase } from '../config/firebase';
import { DocumentData, FirestoreResponse } from '../types';

class FirestoreService {
    private db: Firestore;

    constructor() {
        this.db = initializeFirebase();
    }

    async addDocument(collectionName: string, data: DocumentData): Promise<FirestoreResponse> {
        try {
            const docRef = await addDoc(collection(this.db, collectionName), data);
            return { id: docRef.id, ...data };
        } catch (error) {
            throw new Error(`Error adding document: ${error}`);
        }
    }

    async getDocument(collectionName: string, documentId: string): Promise<DocumentData | null> {
        try {
            const docRef = doc(this.db, collectionName, documentId);
            const docSnap = await getDoc(docRef);
            return docSnap.exists() ? { id: docSnap.id, ...docSnap.data() } : null;
        } catch (error) {
            throw new Error(`Error getting document: ${error}`);
        }
    }

    async updateDocument(collectionName: string, documentId: string, data: DocumentData): Promise<void> {
        try {
            const docRef = doc(this.db, collectionName, documentId);
            await updateDoc(docRef, data);
        } catch (error) {
            throw new Error(`Error updating document: ${error}`);
        }
    }
}

export default FirestoreService;