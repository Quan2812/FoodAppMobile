import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

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
}

class RecipientForm extends StatefulWidget {
  @override
  _RecipientFormState createState() => _RecipientFormState();
}

class _RecipientFormState extends State<RecipientForm> {
  final _formKey = GlobalKey<FormState>();
  String fullName = '';
  String address = '';
  String phone = '';
  String email = '';
  String notes = '';

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
    fetchProvinces();
  }

  Future<void> fetchProvinces() async {
    final response = await http.get(
      Uri.parse('${ghnApiBaseUrl}master-data/province'),
      headers: ghnHeaders,
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      final data = jsonDecode(responseBody);
      print('Provinces data (decoded): ${data['data']}');
      setState(() {
        provinces = (data['data'] as List).map((e) => Province.fromJson(e)).toList();
      });
    } else {
      print('Failed to fetch provinces: ${response.statusCode}');
    }
  }

  Future<void> fetchDistricts(int provinceId) async {
    final response = await http.get(
      Uri.parse('${ghnApiBaseUrl}master-data/district?province_id=$provinceId'),
      headers: ghnHeaders,
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      final data = jsonDecode(responseBody);
      print('Districts data (decoded): ${data['data']}');
      setState(() {
        districts = (data['data'] as List).map((e) => District.fromJson(e)).toList();
        selectedDistrict = null;
        wards = [];
        selectedWard = null;
      });
    } else {
      print('Failed to fetch districts: ${response.statusCode}');
    }
  }

  Future<void> fetchWards(int districtId) async {
    final response = await http.get(
      Uri.parse('${ghnApiBaseUrl}master-data/ward?district_id=$districtId'),
      headers: ghnHeaders,
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      final data = jsonDecode(responseBody);
      print('Wards data (decoded): ${data['data']}');
      setState(() {
        wards = (data['data'] as List).map((e) => Ward.fromJson(e)).toList();
        selectedWard = null;
      });
    } else {
      print('Failed to fetch wards: ${response.statusCode}');
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
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'quanhb',
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
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Đường Xá Gìa Lâm Hà Nội',
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
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '0377892812',
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
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'quanb@gmail.com',
                  hintStyle: GoogleFonts.notoSans(),
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  setState(() {
                    email = value;
                  });
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
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  textStyle: GoogleFonts.notoSans(fontSize: 16),
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