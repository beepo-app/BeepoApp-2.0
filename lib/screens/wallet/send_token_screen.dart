import 'package:Beepo/components/Beepo_filled_button.dart';
import 'package:Beepo/constants/constants.dart';
import 'package:Beepo/providers/wallet_provider.dart';
import 'package:Beepo/screens/wallet/send_token_confirm_screen.dart';
import 'package:Beepo/widgets/app_text.dart';
import 'package:Beepo/widgets/toast.dart';
import 'package:decimal/decimal.dart';
import 'package:ethereum_addresses/ethereum_addresses.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../Utils/styles.dart';

class SendToken extends StatefulWidget {
  final Map? data;
  const SendToken({
    this.data,
    super.key,
  });

  @override
  State<SendToken> createState() => _SendTokenState();
}

class _SendTokenState extends State<SendToken> {
  late final TextEditingController amount;
  final TextEditingController address = TextEditingController();

  @override
  void initState() {
    super.initState();
    amount = TextEditingController()
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    Map asset = widget.data!;

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(15.r)),
      borderSide: const BorderSide(width: 1, color: Colors.grey),
    );

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50.h,
        centerTitle: true,
        backgroundColor: const Color(0xe50d004c),
        title: AppText(
          text: "Send Token",
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.white,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  "Amount",
                  style: TextStyle(
                    color: Color(0xe50d004c),
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amount,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  color: const Color(0xff0d004c),
                  fontSize: 14.sp,
                ),
                decoration: InputDecoration(
                  suffixIcon: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.w),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width / 6,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AppText(
                            text: asset['ticker'],
                            fontSize: 16.sp,
                            color: AppColors.textGrey,
                          ),
                        ],
                      ),
                    ),
                  ),
                  isDense: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15.r)),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1,
                      )),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.r)),
                    borderSide: const BorderSide(width: 1, color: Colors.grey),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      "\$${Decimal.tryParse(amount.text) == null ? int.tryParse(amount.text) == null ? 0 : int.tryParse(amount.text)! * int.parse(asset['current_price']) : Decimal.tryParse(amount.text)! * Decimal.parse(asset['current_price'].toString())}",
                      style: const TextStyle(
                        color: Color(0xe50d004c),
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15.h),
              const Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  "Address",
                  style: TextStyle(
                    color: Color(0xe50d004c),
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: address,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  isDense: true,
                  prefixIcon: IconButton(
                    onPressed: () async {},
                    icon: const Icon(
                      Icons.qr_code_scanner_sharp,
                      size: 25,
                      color: Color(0x7f0e014c),
                    ),
                  ),
                  hintText: "Enter Address",
                  hintStyle: TextStyle(
                    color: const Color(0x7f0e014c),
                    fontSize: 13.sp,
                  ),
                  border: border,
                  focusedBorder: border,
                ),
              ),
              SizedBox(height: 30.h),
              Align(
                  alignment: Alignment.bottomLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText(
                        text: "Send to contacts",
                        fontSize: 14.sp,
                        color: const Color(0x7f0e014c),
                        fontWeight: FontWeight.bold,
                      ),
                      TextButton(
                        onPressed: () {},
                        child: AppText(
                          text: "View more >",
                          fontSize: 11.sp,
                          color: const Color(0x7f0e014c),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )),
              SizedBox(height: 12.h),
              SizedBox(
                height: 100.h,
                child: ListView.separated(
                  padding: const EdgeInsets.only(right: 10, left: 10),
                  shrinkWrap: true,
                  itemCount: 4,
                  scrollDirection: Axis.horizontal,
                  separatorBuilder: (ctx, i) => const SizedBox(width: 10),
                  itemBuilder: (ctx, i) {
                    return Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(30.r),
                          child: Image.asset(
                            'assets/profile_img.png',
                            height: 50.h,
                            width: 50.h,
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          "James",
                          style: TextStyle(
                            color: secondaryColor,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height / 10),
              BeepoFilledButtons(
                text: 'Complete',
                onPressed: () async {
                  if ((amount.text) == '' || address.text == "") {
                    showToast("Enter All Fields!");
                    return;
                  }

                  try {
                    checksumEthereumAddress(address.text);
                  } catch (e) {
                    showToast("Invalid Address Entered!");
                    return;
                  }
                  final walletProvider =
                      Provider.of<WalletProvider>(context, listen: false);
                  Decimal res =
                      await walletProvider.estimateGasPrice(asset['rpc']);

                  var amountToSend = res + Decimal.parse(amount.text);

                  if (amountToSend > Decimal.parse(asset['bal']) ||
                      double.parse(asset['bal']) == 0) {
                    showToast("Insufficient Funds!");
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SendTokenConfirmScreen(
                          asset: asset,
                          data: {
                            'amount': amount.text,
                            'gasFee': res,
                            "address": address.text
                          }),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
