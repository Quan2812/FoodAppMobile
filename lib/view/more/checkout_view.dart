import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common_widget/round_button.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'recipient_form.dart';
import 'checkout_message_view.dart';

class CheckoutView extends StatefulWidget {
  final double subtotal;
  // final double discount = 15.000;
  const CheckoutView({super.key, required this.subtotal});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  List paymentArr = [
    {
      "name": "Thanh toán khi nhận hàng",
      "icon":
      "https://res.cloudinary.com/dfya8dc81/image/upload/v1738811558/cash_ewuwuz.png"
    },
    {
      "name": "Thanh toán qua VNPay",
      "icon":
      "https://res.cloudinary.com/dfya8dc81/image/upload/v1738811583/visa_icon_wk5tiz.png"
    },
  ];

  int selectMethod = -1;
  AddressData? addressData;
  double fee = 20.000;
  bool isLoadingFee = false;

  final String ghnToken = 'd69d5ac4-428d-11ee-a6e6-e60958111f48'; // Thay bằng token mới
  final String shopId = '125587'; // Thay bằng ShopId đúng

  Map<String, String> get ghnHeaders => {
    "Content-Type": "application/json",
    "Token": ghnToken,
    "ShopId": shopId, // Thêm lại ShopId theo yêu cầu của API
  };

  @override
  void initState() {
    super.initState();
    addressData = AddressData(
      fullName: '',
      province: '',
      provinceId: 0,
      district: '',
      districtId: 0,
      ward: '',
      wardCode: '',
      address: '',
      phone: '',
      email: '',
      notes: '',
    );
    fetchShippingFee();
  }

  Future<void> fetchShippingFee() async {
    if (addressData == null || addressData!.districtId == 0 || addressData!.wardCode.isEmpty) {
      return;
    }

    setState(() {
      isLoadingFee = true;
    });

    int toDistrictId = addressData!.districtId;
    String toWardCode = addressData!.wardCode;

    const int weight = 1000;

    try {
      final response = await http.post(
        Uri.parse('https://dev-online-gateway.ghn.vn/shiip/public-api/v2/shipping-order/fee'),
        headers: ghnHeaders,
        body: jsonEncode({
          "service_id": 53320,
          "to_district_id": toDistrictId,
          "to_ward_code": toWardCode,
          "weight": weight
        }),
      );

      print("Bắt đầu call API lấy phí - toDistrictId: $toDistrictId, toWardCode: $toWardCode");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 200) {
          setState(() {
            fee = (data['data']['total']).toDouble();
            isLoadingFee = false;
          });
        } else {
          print('API error: ${data['message']}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi tính phí giao hàng: ${data['message']}'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            isLoadingFee = false;
          });
        }
      } else {
        print('Failed to fetch shipping fee: ${response.statusCode}');
        print('Response body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể tính phí giao hàng: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          isLoadingFee = false;
        });
      }
    } catch (e) {
      print('Error fetching shipping fee: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Có lỗi xảy ra khi tính phí giao hàng.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        isLoadingFee = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 46),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Image.network(
                          "https://res.cloudinary.com/dfya8dc81/image/upload/v1738811555/btn_back_bchrbu.png",
                          width: 20,
                          height: 20),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Thanh toán",
                        style: GoogleFonts.notoSans(
                          color: TColor.primaryText,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Địa chỉ giao hàng",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.notoSans(
                        color: TColor.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            "${addressData!.address}\n${addressData!.province}${addressData!.district.isNotEmpty ? ', ${addressData!.district}' : ''}${addressData!.ward.isNotEmpty ? ', ${addressData!.ward}' : ''}",
                            style: GoogleFonts.notoSans(
                              color: TColor.primaryText,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        TextButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => RecipientForm()),
                            );
                            if (result != null && result is AddressData) {
                              setState(() {
                                addressData = result;
                                fetchShippingFee();
                              });
                            }
                          },
                          child: Text(
                            "Thay đổi",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.notoSans(
                              color: TColor.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(color: TColor.textfield),
                height: 8,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Phương thức thanh toán",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.notoSans(
                            color: TColor.secondaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        // TextButton.icon(
                        //   onPressed: () {},
                        //   icon: Icon(Icons.add, color: TColor.primary),
                        //   label: Text(
                        //     "Thêm thẻ",
                        //     style: GoogleFonts.notoSans(
                        //       color: TColor.primary,
                        //       fontSize: 13,
                        //       fontWeight: FontWeight.w700,
                        //     ),
                        //   ),
                        // )
                      ],
                    ),
                    ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: paymentArr.length,
                        itemBuilder: (context, index) {
                          var pObj = paymentArr[index] as Map? ?? {};
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 15.0),
                            decoration: BoxDecoration(
                                color: TColor.textfield,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                    color: TColor.secondaryText.withOpacity(0.2))),
                            child: Row(
                              children: [
                                Image.network(pObj["icon"].toString(),
                                    width: 50, height: 20, fit: BoxFit.contain),
                                Expanded(
                                  child: Text(
                                    pObj["name"],
                                    style: GoogleFonts.notoSans(
                                      color: TColor.primaryText,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectMethod = index;
                                    });
                                  },
                                  child: Icon(
                                    selectMethod == index
                                        ? Icons.radio_button_on
                                        : Icons.radio_button_off,
                                    color: TColor.primary,
                                    size: 15,
                                  ),
                                )
                              ],
                            ),
                          );
                        })
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(color: TColor.textfield),
                height: 8,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Tạm tính",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.notoSans(
                            color: TColor.primaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          ("${NumberFormat("#,###", "vi_VN").format(widget.subtotal)}"),
                          style: GoogleFonts.notoSans(
                            color: TColor.primaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Phí giao hàng",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.notoSans(
                            color: TColor.primaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        isLoadingFee
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                            : Text(
                          ("${NumberFormat("#,###", "vi_VN").format(fee)}"),
                          style: GoogleFonts.notoSans(
                            color: TColor.primaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    // const SizedBox(height: 8),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     Text(
                    //       "Giảm giá",
                    //       textAlign: TextAlign.center,
                    //       style: GoogleFonts.notoSans(
                    //         color: TColor.primaryText,
                    //         fontSize: 13,
                    //         fontWeight: FontWeight.w500,
                    //       ),
                    //     ),
                    //     Text(
                    //       "-${widget.discount.toStringAsFixed(3)}",
                    //       style: GoogleFonts.notoSans(
                    //         color: TColor.primaryText,
                    //         fontSize: 13,
                    //         fontWeight: FontWeight.w700,
                    //       ),
                    //     )
                    //   ],
                    // ),
                    const SizedBox(height: 15),
                    Divider(
                      color: TColor.secondaryText.withOpacity(0.5),
                      height: 1,
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Thành tiền",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.notoSans(
                            color: TColor.primaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          ("${NumberFormat("#,###", "vi_VN").format(widget.subtotal + fee)}"),
                          style: GoogleFonts.notoSans(
                            color: TColor.primaryText,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(color: TColor.textfield),
                height: 8,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
                child: RoundButton(
                    title: "Đặt hàng",
                    onPressed: () {
                      showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          builder: (context) {
                            return const CheckoutMessageView();
                          });
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}