export interface DocumentData {
    id: string;
    [key: string]: any;
}

export interface FirestoreResponse {
    success: boolean;
    data?: DocumentData;
    error?: string;
}