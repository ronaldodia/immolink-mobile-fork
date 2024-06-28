class User {
  int? id;
  int? structureId;
  String? fullName;
  String? email;
  String? phone;
  String? avatar;
  String? address;
  String? twoFactorSecret;
  String? twoFactorRecoveryCodes;
  String? twoFactorConfirmedAt;
  int? isActive;
  String? deviceName;
  String? emailVerifiedAt;
  String? phoneVerifiedAt;
  String? createdAt;
  String? updatedAt;

  User({
    this.id,
    this.structureId,
    this.fullName,
    this.email,
    this.phone,
    this.avatar,
    this.address,
    this.twoFactorSecret,
    this.twoFactorRecoveryCodes,
    this.twoFactorConfirmedAt,
    this.isActive,
    this.deviceName,
    this.emailVerifiedAt,
    this.phoneVerifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    structureId = json['structure_id'];
    fullName = json['full_name'];
    email = json['email'];
    phone = json['phone'];
    avatar = json['avatar'];
    address = json['address'];
    twoFactorSecret = json['two_factor_secret'];
    twoFactorRecoveryCodes = json['two_factor_recovery_codes'];
    twoFactorConfirmedAt = json['two_factor_confirmed_at'];
    isActive = json['is_active'];
    deviceName = json['device_name'];
    emailVerifiedAt = json['email_verified_at'];
    phoneVerifiedAt = json['phone_verified_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['structure_id'] = structureId;
    data['full_name'] = fullName;
    data['email'] = email;
    data['phone'] = phone;
    data['avatar'] = avatar;
    data['address'] = address;
    data['two_factor_secret'] = twoFactorSecret;
    data['two_factor_recovery_codes'] = twoFactorRecoveryCodes;
    data['two_factor_confirmed_at'] = twoFactorConfirmedAt;
    data['is_active'] = isActive;
    data['device_name'] = deviceName;
    data['email_verified_at'] = emailVerifiedAt;
    data['phone_verified_at'] = phoneVerifiedAt;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
