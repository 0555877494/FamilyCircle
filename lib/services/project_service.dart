import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/family_project.dart';

class ProjectService {
  final CollectionReference _projectsRef = FirebaseFirestore.instance.collection('projects');
  final Uuid _uuid = const Uuid();

  Stream<List<FamilyProject>> getProjectsStream(String familyId) {
    return _projectsRef
        .where('familyId', isEqualTo: familyId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FamilyProject.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Future<FamilyProject?> getProject(String projectId) async {
    try {
      final doc = await _projectsRef.doc(projectId).get();
      if (doc.exists) {
        return FamilyProject.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
    } catch (e) {
      print('Error getting project: $e');
    }
    return null;
  }

  Future<String> createProject(FamilyProject project) async {
    try {
      final id = _uuid.v4();
      final newProject = project.copyWith(id: id);
      await _projectsRef.doc(id).set(newProject.toMap());
      return id;
    } catch (e) {
      print('Error creating project: $e');
      rethrow;
    }
  }

  Future<void> updateProject(FamilyProject project) async {
    try {
      await _projectsRef.doc(project.id).update(project.toMap());
    } catch (e) {
      print('Error updating project: $e');
      rethrow;
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      await _projectsRef.doc(projectId).delete();
    } catch (e) {
      print('Error deleting project: $e');
      rethrow;
    }
  }

  Future<void> addTask(String projectId, ProjectTask task) async {
    try {
      final project = await getProject(projectId);
      if (project != null) {
        final updatedTasks = [...project.tasks, task];
        await _projectsRef.doc(projectId).update({
          'tasks': updatedTasks.map((t) => t.toMap()).toList(),
        });
      }
    } catch (e) {
      print('Error adding task: $e');
      rethrow;
    }
  }

  Future<void> toggleTask(String projectId, String taskId) async {
    try {
      final project = await getProject(projectId);
      if (project != null) {
        final updatedTasks = project.tasks.map((t) {
          if (t.id == taskId) {
            return t.copyWith(isCompleted: !t.isCompleted);
          }
          return t;
        }).toList();
        await _projectsRef.doc(projectId).update({
          'tasks': updatedTasks.map((t) => t.toMap()).toList(),
        });
      }
    } catch (e) {
      print('Error toggling task: $e');
      rethrow;
    }
  }

  Future<void> updateStatus(String projectId, ProjectStatus status) async {
    try {
      await _projectsRef.doc(projectId).update({'status': status.name});
    } catch (e) {
      print('Error updating status: $e');
      rethrow;
    }
  }
}
