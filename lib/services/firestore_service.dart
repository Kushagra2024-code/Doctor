import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a document
  Future<void> createDocument(String collection, String docId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collection).doc(docId).set(data);
    } catch (e) {
      throw 'Error creating document: $e';
    }
  }

  // Read a document
  Future<DocumentSnapshot> getDocument(String collection, String docId) async {
    try {
      return await _firestore.collection(collection).doc(docId).get();
    } catch (e) {
      throw 'Error fetching document: $e';
    }
  }

  // Update a document
  Future<void> updateDocument(String collection, String docId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collection).doc(docId).update(data);
    } catch (e) {
      throw 'Error updating document: $e';
    }
  }

  // Delete a document
  Future<void> deleteDocument(String collection, String docId) async {
    try {
      await _firestore.collection(collection).doc(docId).delete();
    } catch (e) {
      throw 'Error deleting document: $e';
    }
  }

  // Get collection stream
  Stream<QuerySnapshot> getCollectionStream(String collection) {
    return _firestore.collection(collection).snapshots();
  }

  // Query documents
  Future<QuerySnapshot> queryDocuments(
    String collection, {
    String? field,
    dynamic isEqualTo,
    int? limit,
  }) async {
    try {
      Query query = _firestore.collection(collection);
      
      if (field != null && isEqualTo != null) {
        query = query.where(field, isEqualTo: isEqualTo);
      }
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      return await query.get();
    } catch (e) {
      throw 'Error querying documents: $e';
    }
  }

  // Add document with auto-generated ID
  Future<String> addDocument(String collection, Map<String, dynamic> data) async {
    try {
      DocumentReference docRef = await _firestore.collection(collection).add(data);
      return docRef.id;
    } catch (e) {
      throw 'Error adding document: $e';
    }
  }
}
