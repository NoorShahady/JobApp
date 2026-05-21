class Job {
  final String id;
  final String title;
  final String company;
  final String location;
  final String workType;
  final String description;
  final List<String> skills;
  final String employerId;
  final String employerName;
  final DateTime createdAt;

  Job({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.workType,
    required this.description,
    this.skills = const [],
    this.employerId = '',
    this.employerName = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'title': title,
    'company': company,
    'location': location,
    'workType': workType,
    'description': description,
    'skills': skills,
    'employerId': employerId,
    'employerName': employerName,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Job.fromJson(Map<String, dynamic> json, String docId) => Job(
    id: docId,
    title: json['title'] ?? '',
    company: json['company'] ?? '',
    location: json['location'] ?? '',
    workType: json['workType'] ?? '',
    description: json['description'] ?? '',
    skills: List<String>.from(json['skills'] ?? []),
    employerId: json['employerId'] ?? '',
    employerName: json['employerName'] ?? '',
    createdAt: json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
        : DateTime.now(),
  );
}