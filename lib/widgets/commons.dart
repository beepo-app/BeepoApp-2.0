import 'package:Beepo/components/beepo_filled_button.dart';
import 'package:Beepo/constants/constants.dart';
import 'package:Beepo/providers/wallet_provider.dart';
import 'package:Beepo/screens/wallet/send_token_confirm_screen.dart';
import 'package:Beepo/utils/logger.dart';
import 'package:Beepo/widgets/toast.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../Utils/styles.dart';

dynamic loadingDialog(String label) {
  Get.dialog(
    Material(
      color: Colors.black.withOpacity(.2),
      child: Center(
        child: Container(
          width: 170,
          padding: const EdgeInsets.only(bottom: 30, left: 7, right: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset('assets/lottie/loading.json'),
              Text(
                label,
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ),
    ),
  );
}

class InChatTx extends StatefulWidget {
  final Map user;
  final List assets;
  const InChatTx({super.key, required this.user, required this.assets});

  @override
  State<InChatTx> createState() => _InChatTxState();
}

class _InChatTxState extends State<InChatTx> {
  late final TextEditingController amount;

  final List<String> walletItems = ['Crypto', 'Fiat'];
  final List<String> curItems = [
    'BNB',
    'ETH',
    "CELO",
    "BEEP",
    "Brise",
    "MATIC",
    "CMP",
    "USDT",
    "HLUSD"
  ];

  String selectedWalletItem = 'Crypto';
  String selectedCurItem = 'BNB';

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
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    String userId = widget.user['displayName'];
    Map? asset = widget.assets
        .firstWhereOrNull((element) => element['ticker'] == selectedCurItem);

    userId = userId.length > 30
        ? '${userId.substring(0, 3)}...${userId.substring(userId.length - 7, userId.length)}'
        : userId;

    String address = widget.user["ethAddress"];

    beepoPrint(asset);

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Send Money to $userId',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
            ),
            const SizedBox(
              height: 35,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Wallet",
                      style: TextStyle(
                        color: Color(0xe50d004c),
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.all(Radius.circular(8.r)),
                      ),
                      child: PopupMenuButton<String>(
                        position: PopupMenuPosition.under,
                        initialValue: selectedWalletItem,
                        onSelected: (String item) {
                          setState(() {
                            selectedWalletItem = item;
                          });
                        },
                        itemBuilder: (BuildContext context) {
                          return walletItems.map((String item) {
                            return PopupMenuItem<String>(
                              value: item,
                              child: Text(
                                item,
                                style: const TextStyle(
                                  color: AppColors.black, // Change text color
                                ),
                              ),
                            );
                          }).toList();
                        },
                        // offset: const Offset(0, 45),
                        child: Container(
                          padding: EdgeInsets.all(10.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                selectedWalletItem,
                                style: const TextStyle(
                                  color: AppColors.black,
                                ),
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                size: 30,
                                color: AppColors.black,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Currency",
                      style: TextStyle(
                        color: Color(0xe50d004c),
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.all(Radius.circular(8.r)),
                      ),
                      child: PopupMenuButton<String>(
                        position: PopupMenuPosition.under,
                        initialValue: selectedCurItem,
                        onSelected: (String item) {
                          // beepoPrint(item);
                          setState(() {
                            selectedCurItem = item;
                          });
                        },
                        itemBuilder: (BuildContext context) {
                          return curItems.map((String item) {
                            return PopupMenuItem<String>(
                              value: item,
                              child: Text(
                                item,
                                style: const TextStyle(
                                  color: AppColors.black, // Change text color
                                ),
                              ),
                            );
                          }).toList();
                        },
                        // offset: const Offset(0, 45),
                        child: Container(
                          padding: EdgeInsets.all(10.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                selectedCurItem,
                                style: const TextStyle(
                                  color: AppColors.black,
                                ),
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                size: 30,
                                color: AppColors.black,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(
              height: 27,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        "Amount",
                        style: TextStyle(
                          color: Color(0xe50d004c),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        "Bal ${asset != null ? asset['bal'] : 0} ${asset != null ? asset['ticker'] : ''} ",
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                TextField(
                  controller: amount,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    color: const Color(0xff0d004c),
                    fontSize: 14.sp,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: "0",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.r)),
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 1,
                        )),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.r)),
                      borderSide:
                          const BorderSide(width: 1, color: Colors.grey),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    asset == null
                        ? const Text('')
                        : Container(
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
                const SizedBox(height: 35),
                BeepoFilledButtons(
                  text: 'Send',
                  onPressed: () async {
                    if (asset == null) return;
                    Decimal res =
                        await walletProvider.estimateGasPrice(asset['rpc']);

                    var amountToSend = res + Decimal.parse(amount.text);

                    if (amountToSend > Decimal.parse(asset['bal']) ||
                        double.parse(asset['bal']) == 0) {
                      showToast("Insufficient Funds!");
                      return;
                    }
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SendTokenConfirmScreen(
                            asset: asset,
                            data: {
                              'amount': amount.text,
                              'gasFee': res,
                              "address": address
                            },
                            type: 'inChatTx'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

dynamic inchatTxBox(context, user) {
  final walletProvider = Provider.of<WalletProvider>(context, listen: false);
  List assets = walletProvider.assets!;
  Get.dialog(
    Material(
      color: Colors.black.withOpacity(.2),
      child: InChatTx(
        user: user,
        assets: assets,
      ),
    ),
  );
}

Widget loader() {
  return const Center(child: CircularProgressIndicator());
}

//custom appbar
AppBar appBar(String title, {bool centerTitle = true}) {
  return AppBar(
    elevation: 0,
    centerTitle: centerTitle,
    backgroundColor: secondaryColor,
    title: Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
      ),
    ),
    foregroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(15),
      ),
    ),
  );
}

dynamic fullScreenLoader(String title) {
  return Get.dialog(
    Material(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Lottie.asset(
                    'assets/lottie/lottie_1.json',
                    height: 150,
                    width: 150,
                  ),
                ),
                Text(
                  title,
                  style: Get.textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
