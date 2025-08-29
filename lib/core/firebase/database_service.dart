import 'package:cloud_firestore/cloud_firestore.dart';

// A type definition for a function that builds a Firestore query.
typedef QueryBuilder =
    Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>> query);

// MODIFIED: The builder now receives the batch AND the firestore instance.
typedef BatchBuilder =
    void Function(WriteBatch batch, FirebaseFirestore firestore);

class DatabaseService {
  final FirebaseFirestore _firestore;

  DatabaseService(this._firestore);

  // ... (setData, updateData, addData, etc. remain unchanged) ...

  Future<void> setData({
    required String path,
    required Map<String, dynamic> data,
    bool merge = false,
  }) {
    final reference = _firestore.doc(path);
    return reference.set(data, SetOptions(merge: merge));
  }

  Future<void> updateData({
    required String path,
    required Map<String, dynamic> data,
  }) {
    final reference = _firestore.doc(path);
    return reference.update(data);
  }

  Future<DocumentReference> addData({
    required String collectionPath,
    required Map<String, dynamic> data,
  }) {
    final reference = _firestore.collection(collectionPath);
    return reference.add(data);
  }

  Future<void> deleteData({required String path}) {
    final reference = _firestore.doc(path);
    return reference.delete();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument({
    required String path,
  }) {
    final reference = _firestore
        .doc(path)
        .withConverter<Map<String, dynamic>>(
          fromFirestore: (snapshot, _) => snapshot.data()!,
          toFirestore: (data, _) => data,
        );
    return reference.get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getCollection({
    required String path,
    QueryBuilder? queryBuilder,
  }) {
    Query<Map<String, dynamic>> query = _firestore.collection(path);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    return query.get();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getCollectionStream({
    required String path,
    QueryBuilder? queryBuilder,
  }) {
    Query<Map<String, dynamic>> query = _firestore.collection(path);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    return query.snapshots();
  }

  /// Runs multiple write operations as a single atomic unit.
  Future<void> runBatch(BatchBuilder batchBuilder) {
    final WriteBatch batch = _firestore.batch();
    // MODIFIED: We now pass the service's firestore instance to the builder.
    batchBuilder(batch, _firestore);
    return batch.commit();
  }
}
