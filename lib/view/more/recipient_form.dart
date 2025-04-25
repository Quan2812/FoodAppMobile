import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

import '../../common/color_extension.dart';

class AddressData {
  final String fullName;
  final String province;
  final int provinceId;
  final String district;
  final int districtId;
  final String ward;
  final String wardCode;
  final String address;
  final String phone;
  final String email;
  final String notes;

  AddressData({
    required this.fullName,
    required this.province,
    required this.provinceId,
    required this.district,
    required this.districtId,
    required this.ward,
    required this.wardCode,
    required this.address,
    required this.phone,
    required this.email,
    required this.notes,
  });
}

class Province {
  final int provinceId;
  final String name;
  Province({required this.provinceId, required this.name});

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      provinceId: json['ProvinceID'],
      name: json['ProvinceName'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Province &&
              runtimeType == other.runtimeType &&
              provinceId == other.provinceId;

  @override
  int get hashCode => provinceId.hashCode;
}

class District {
  final int districtId;
  final String name;
  District({required this.districtId, required this.name});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      districtId: json['DistrictID'],
      name: json['DistrictName'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is District &&
              runtimeType == other.runtimeType &&
              districtId == other.districtId;

  @override
  int get hashCode => districtId.hashCode;
}

class Ward {
  final String wardCode;
  final String name;
  Ward({required this.wardCode, required this.name});

  factory Ward.fromJson(Map<String, dynamic> json) {
    return Ward(
      wardCode: json['WardCode'],
      name: json['WardName'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Ward &&
              runtimeType == other.runtimeType &&
              wardCode == other.wardCode;

  @override
  int get hashCode => wardCode.hashCode;
}

class RecipientForm extends StatefulWidget {
  final AddressData? initialAddressData;

  const RecipientForm({super.key, this.initialAddressData});

  @override
  _RecipientFormState createState() => _RecipientFormState();
}

class _RecipientFormState extends State<RecipientForm> {
  final _formKey = GlobalKey<FormState>();
  late String fullName;
  late String address;
  late String phone;
  late String email;
  late String notes;

  List<Province> provinces = [];
  List<District> districts = [];
  List<Ward> wards = [];

  Province? selectedProvince;
  District? selectedDistrict;
  Ward? selectedWard;

  final String ghnApiBaseUrl = "https://dev-online-gateway.ghn.vn/shiip/public-api/";
  final String ghnToken = "d69d5ac4-428d-11ee-a6e6-e60958111f48";
  final String shopId = "125587";

  Map<String, String> get ghnHeaders => {
    "Content-Type": "application/json",
    "Token": ghnToken,
    "ShopId": shopId,
  };

  @override
  void initState() {
    super.initState();
    // Khởi tạo các trường với giá trị từ initialAddressData hoặc rỗng
    fullName = widget.initialAddressData?.fullName ?? '';
    address = widget.initialAddressData?.address ?? '';
    phone = widget.initialAddressData?.phone ?? '';
    email = widget.initialAddressData?.email ?? '';
    notes = widget.initialAddressData?.notes ?? '';

    fetchProvinces();

    // Nếu có initialAddressData, khởi tạo các dropdown
    if (widget.initialAddressData != null) {
      _initializeAddressData();
    }
  }

  Future<void> fetchProvinces() async {
    try {
      final response = await http.get(
        Uri.parse('${ghnApiBaseUrl}master-data/province'),
        headers: ghnHeaders,
      );

      if (response.statusCode == 200) {
        final String responseBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(responseBody);
        print('Provinces data (decoded): ${data['data']}');
        setState(() {
          // Loại bỏ trùng lặp tỉnh/thành dựa trên provinceId
          provinces = (data['data'] as List)
              .map((e) => Province.fromJson(e))
              .toSet() // Loại bỏ trùng lặp
              .toList();
        });
      } else {
        print('Failed to fetch provinces: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể tải danh sách tỉnh/thành'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error fetching provinces: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Có lỗi xảy ra khi tải danh sách tỉnh/thành'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> fetchDistricts(int provinceId) async {
    try {
      final response = await http.get(
        Uri.parse('${ghnApiBaseUrl}master-data/district?province_id=$provinceId'),
        headers: ghnHeaders,
      );

      if (response.statusCode == 200) {
        final String responseBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(responseBody);
        print('Districts data (decoded): ${data['data']}');
        setState(() {
          districts = (data['data'] as List)
              .map((e) => District.fromJson(e))
              .toSet() // Loại bỏ trùng lặp
              .toList();
          selectedDistrict = null;
          wards = [];
          selectedWard = null;
        });
      } else {
        print('Failed to fetch districts: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể tải danh sách quận/huyện'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error fetching districts: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Có lỗi xảy ra khi tải danh sách quận/huyện'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> fetchWards(int districtId) async {
    try {
      final response = await http.get(
        Uri.parse('${ghnApiBaseUrl}master-data/ward?district_id=$districtId'),
        headers: ghnHeaders,
      );

      if (response.statusCode == 200) {
        final String responseBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(responseBody);
        print('Wards data (decoded): ${data['data']}');
        setState(() {
          wards = (data['data'] as List)
              .map((e) => Ward.fromJson(e))
              .toSet() // Loại bỏ trùng lặp
              .toList();
          selectedWard = null;
        });
      } else {
        print('Failed to fetch wards: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể tải danh sách phường/xã'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error fetching wards: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Có lỗi xảy ra khi tải danh sách phường/xã'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _initializeAddressData() async {
    if (widget.initialAddressData == null) return;

    // Đợi provinces được tải
    await fetchProvinces();
    if (provinces.isNotEmpty) {
      final initialProvinceId = widget.initialAddressData!.provinceId;
      final matchingProvince = provinces.firstWhere(
            (province) => province.provinceId == initialProvinceId,
        orElse: () => provinces.first, // Mặc định chọn tỉnh đầu tiên nếu không tìm thấy
      );

      setState(() {
        selectedProvince = matchingProvince;
      });

      // Tải quận/huyện nếu có provinceId hợp lệ
      if (matchingProvince.provinceId == initialProvinceId) {
        await fetchDistricts(initialProvinceId);
        if (districts.isNotEmpty) {
          final initialDistrictId = widget.initialAddressData!.districtId;
          final matchingDistrict = districts.firstWhere(
                (district) => district.districtId == initialDistrictId,
            orElse: () => districts.first,
          );

          setState(() {
            selectedDistrict = matchingDistrict;
          });

          // Tải phường/xã nếu có districtId hợp lệ
          if (matchingDistrict.districtId == initialDistrictId) {
            await fetchWards(initialDistrictId);
            if (wards.isNotEmpty) {
              final initialWardCode = widget.initialAddressData!.wardCode;
              final matchingWard = wards.firstWhere(
                    (ward) => ward.wardCode == initialWardCode,
                orElse: () => wards.first,
              );

              setState(() {
                selectedWard = matchingWard;
              });
            }
          }
        }
      }
    }
  }

  void submitForm() {
    if (_formKey.currentState!.validate()) {
      final addressData = AddressData(
        fullName: fullName,
        province: selectedProvince?.name ?? '',
        provinceId: selectedProvince?.provinceId ?? 0,
        district: selectedDistrict?.name ?? '',
        districtId: selectedDistrict?.districtId ?? 0,
        ward: selectedWard?.name ?? '',
        wardCode: selectedWard?.wardCode ?? '',
        address: address,
        phone: phone,
        email: email,
        notes: notes,
      );
      Navigator.pop(context, addressData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Thông tin khách hàng',
          style: GoogleFonts.notoSans(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Họ và Tên',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextFormField(
                initialValue: fullName,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Họ và tên người nhận hàng',
                  hintStyle: GoogleFonts.notoSans(),
                ),
                onChanged: (value) {
                  setState(() {
                    fullName = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập họ và tên';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text(
                'Tỉnh - Thành',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              DropdownButtonFormField<Province>(
                isExpanded: true,
                value: selectedProvince,
                hint: Text('Chọn tỉnh/thành', style: GoogleFonts.notoSans()),
                items: provinces.map((Province province) {
                  return DropdownMenuItem<Province>(
                    value: province,
                    child: Text(
                      province.name,
                      style: GoogleFonts.notoSans(),
                    ),
                  );
                }).toList(),
                onChanged: (Province? newValue) {
                  setState(() {
                    selectedProvince = newValue;
                    selectedDistrict = null;
                    selectedWard = null;
                    districts = [];
                    wards = [];
                    if (newValue != null) {
                      fetchDistricts(newValue.provinceId);
                    }
                  });
                },
                validator: (Province? value) {
                  if (value == null) {
                    return 'Vui lòng chọn tỉnh/thành';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text(
                'Quận - Huyện',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              DropdownButtonFormField<District>(
                isExpanded: true,
                value: selectedDistrict,
                hint: Text('Chọn quận/huyện', style: GoogleFonts.notoSans()),
                items: districts.map((District district) {
                  return DropdownMenuItem<District>(
                    value: district,
                    child: Text(
                      district.name,
                      style: GoogleFonts.notoSans(),
                    ),
                  );
                }).toList(),
                onChanged: (District? newValue) {
                  setState(() {
                    selectedDistrict = newValue;
                    selectedWard = null;
                    wards = [];
                    if (newValue != null) {
                      fetchWards(newValue.districtId);
                    }
                  });
                },
                validator: (District? value) {
                  if (value == null) {
                    return 'Vui lòng chọn quận/huyện';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text(
                'Phường - Xã',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              DropdownButtonFormField<Ward>(
                isExpanded: true,
                value: selectedWard,
                hint: Text('Chọn phường/xã', style: GoogleFonts.notoSans()),
                items: wards.map((Ward ward) {
                  return DropdownMenuItem<Ward>(
                    value: ward,
                    child: Text(
                      ward.name,
                      style: GoogleFonts.notoSans(),
                    ),
                  );
                }).toList(),
                onChanged: (Ward? newValue) {
                  setState(() {
                    selectedWard = newValue;
                  });
                },
                validator: (Ward? value) {
                  if (value == null) {
                    return 'Vui lòng chọn phường/xã';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text(
                'Địa chỉ',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextFormField(
                initialValue: address,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Địa chỉ chi tiết: Số nhà, thôn, xóm',
                  hintStyle: GoogleFonts.notoSans(),
                ),
                onChanged: (value) {
                  setState(() {
                    address = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập địa chỉ';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text(
                'Điện thoại',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextFormField(
                initialValue: phone,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Số điện thoại',
                  hintStyle: GoogleFonts.notoSans(),
                ),
                keyboardType: TextInputType.phone,
                onChanged: (value) {
                  setState(() {
                    phone = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số điện thoại';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text(
                'Email',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextFormField(
                initialValue: email,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Email',
                  hintStyle: GoogleFonts.notoSans(),
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  setState(() {
                    email = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text(
                'Ghi chú',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextFormField(
                initialValue: notes,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintStyle: GoogleFonts.notoSans(),
                ),
                maxLines: 3,
                onChanged: (value) {
                  setState(() {
                    notes = value;
                  });
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColor.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  textStyle: GoogleFonts.notoSans(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: Text('Xác nhận'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}