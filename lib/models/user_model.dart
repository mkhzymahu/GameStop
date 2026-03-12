enum UserRole { customer, seller, admin }

class UserModel {
  final String id;
  final String email;
  final String name;
  final String phone;
  final String address;
  final String? profileImage;
  final UserRole role;
  final DateTime createdAt;
  final UserPreferences preferences;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.address,
    this.profileImage,
    this.role = UserRole.customer,
    DateTime? createdAt,
    UserPreferences? preferences,
  }) : createdAt = createdAt ?? DateTime.now(),
       preferences = preferences ?? UserPreferences();

  bool get isAdmin => role == UserRole.admin;
  bool get isCustomer => role == UserRole.customer;

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? address,
    String? profileImage,
    UserRole? role,
    DateTime? createdAt,
    UserPreferences? preferences,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      profileImage: profileImage ?? this.profileImage,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      preferences: preferences ?? this.preferences,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'phone': phone,
    'address': address,
    'profileImage': profileImage,
    'role': role.name,
    'createdAt': createdAt.toIso8601String(),
    'preferences': preferences.toJson(),
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    email: json['email'],
    name: json['name'] ?? '',
    phone: json['phone'] ?? '',
    address: json['address'] ?? '',
    profileImage: json['profileImage'],
    role: UserRole.values.firstWhere(
      (r) => r.name == (json['role'] ?? 'customer'),
      orElse: () => UserRole.customer,
    ),
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : DateTime.now(),
    preferences: json['preferences'] != null
        ? UserPreferences.fromJson(
            Map<String, dynamic>.from(json['preferences']))
        : UserPreferences(),
  );
}

class UserPreferences {
  bool emailNotifications;
  bool pushNotifications;
  bool orderUpdates;
  bool promotions;
  bool newArrivals;
  bool priceDrops;
  String currency;
  String theme;

  UserPreferences({
    this.emailNotifications = true,
    this.pushNotifications = false,
    this.orderUpdates = true,
    this.promotions = false,
    this.newArrivals = true,
    this.priceDrops = true,
    this.currency = 'USD',
    this.theme = 'dark',
  });

  UserPreferences copyWith({
    bool? emailNotifications,
    bool? pushNotifications,
    bool? orderUpdates,
    bool? promotions,
    bool? newArrivals,
    bool? priceDrops,
    String? currency,
    String? theme,
  }) => UserPreferences(
    emailNotifications: emailNotifications ?? this.emailNotifications,
    pushNotifications: pushNotifications ?? this.pushNotifications,
    orderUpdates: orderUpdates ?? this.orderUpdates,
    promotions: promotions ?? this.promotions,
    newArrivals: newArrivals ?? this.newArrivals,
    priceDrops: priceDrops ?? this.priceDrops,
    currency: currency ?? this.currency,
    theme: theme ?? this.theme,
  );

  Map<String, dynamic> toJson() => {
    'emailNotifications': emailNotifications,
    'pushNotifications': pushNotifications,
    'orderUpdates': orderUpdates,
    'promotions': promotions,
    'newArrivals': newArrivals,
    'priceDrops': priceDrops,
    'currency': currency,
    'theme': theme,
  };

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      UserPreferences(
        emailNotifications: json['emailNotifications'] ?? true,
        pushNotifications: json['pushNotifications'] ?? false,
        orderUpdates: json['orderUpdates'] ?? true,
        promotions: json['promotions'] ?? false,
        newArrivals: json['newArrivals'] ?? true,
        priceDrops: json['priceDrops'] ?? true,
        currency: json['currency'] ?? 'USD',
        theme: json['theme'] ?? 'dark',
      );
}