import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'job.dart';

class JobsStore extends ChangeNotifier {
  JobsStore._();
  static final JobsStore instance = JobsStore._();

  List<Job> _jobs = [];
  List<Job> get jobs => List.unmodifiable(_jobs);

  void init() {
    FirebaseFirestore.instance.collection('jobs').orderBy('createdAt', descending: true).snapshots().listen((snap) {
      _jobs = snap.docs.map((d) => Job.fromJson(d.data(), d.id)).toList();
      notifyListeners();
    });
  }

  Future<void> addJob(Job job) async {
    await FirebaseFirestore.instance.collection('jobs').add(job.toJson());
  }

  Future<void> removeJob(String id) async {
    await FirebaseFirestore.instance.collection('jobs').doc(id).delete();
  }
}
