class Application {
  final String id;
  final String jobId;
  final String jobTitle;
  final String companyName;
  final String applicantId;
  final String applicantName;
  final String applicantEmail;
  final String employerId;
  final DateTime appliedAt;
  String status;

  Application({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.companyName,
    required this.applicantId,
    required this.applicantName,
    required this.applicantEmail,
    required this.employerId,
    required this.appliedAt,
    this.status = 'Pending',
  });

  Map<String, dynamic> toJson() => {
    'jobId': jobId,
    'jobTitle': jobTitle,
    'companyName': companyName,
    'applicantId': applicantId,
    'applicantName': applicantName,
    'applicantEmail': applicantEmail,
    'employerId': employerId,
    'appliedAt': appliedAt.toIso8601String(),
    'status': status,
  };

  factory Application.fromJson(Map<String, dynamic> json, String docId) =>
      Application(
        id: docId,
        jobId: json['jobId'] ?? '',
        jobTitle: json['jobTitle'] ?? '',
        companyName: json['companyName'] ?? '',
        applicantId: json['applicantId'] ?? '',
        applicantName: json['applicantName'] ?? '',
        applicantEmail: json['applicantEmail'] ?? '',
        employerId: json['employerId'] ?? '',
        appliedAt: json['appliedAt'] != null
            ? DateTime.tryParse(json['appliedAt']) ?? DateTime.now()
            : DateTime.now(),
        status: json['status'] ?? 'Pending',
      );
}
