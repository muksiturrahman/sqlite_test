class EmployeeData {
  String? name;
  String? email;
  String? mobile;
  String? skype;
  String? department;
  String? designation;
  String? division;
  String? photo;
  bool isExpanded;

  EmployeeData(
      {this.name,
        this.email,
        this.mobile,
        this.skype,
        this.department,
        this.designation,
        this.division,
        this.photo,
        this.isExpanded = false,});

  factory EmployeeData.fromJson(Map<String, dynamic> json) {
    return EmployeeData(
      name: json['Name'] ?? '',
      email: json['Email'] ?? '',
      mobile: json['Mobile'] ?? '',
      skype: json['Skype'] ?? '',
      department: json['Department'] ?? '',
      designation: json['Designation'] ?? '',
      division: json['Division'] ?? '',
      photo: json['Photo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Name'] = this.name;
    data['Email'] = this.email;
    data['Mobile'] = this.mobile;
    data['Skype'] = this.skype;
    data['Department'] = this.department;
    data['Designation'] = this.designation;
    data['Division'] = this.division;
    data['Photo'] = this.photo;
    return data;
  }
}
