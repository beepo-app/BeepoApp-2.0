import 'package:Beepo/constants/constants.dart';
import 'package:Beepo/providers/wallet_provider.dart';
import 'package:Beepo/screens/wallet/token_screen_scan.dart';
import 'package:Beepo/screens/wallet/send_token_screen.dart';
import 'package:Beepo/screens/wallet/transfer_info.dart';
import 'package:Beepo/utils/logger.dart';
import 'package:Beepo/widgets/app_text.dart';
import 'package:Beepo/widgets/toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class WalletTokenScreen extends StatefulWidget {
  final Map<String, dynamic>? data;
  const WalletTokenScreen({super.key, this.data});

  @override
  State<WalletTokenScreen> createState() => _WalletTokenScreenState();
}

class _WalletTokenScreenState extends State<WalletTokenScreen> {
  bool isPositive = false;
  bool isSent = false;
  List? tx;

  getAssests() async {
    try {
      final walletProvider =
          Provider.of<WalletProvider>(context, listen: false);
      var type = widget.data!['native'] ? 'EVM' : 'TOKEN';
      var data = await walletProvider.getTxs(widget.data!['chainID'], type);
      setState(() {
        tx = data['data'];
      });
    } catch (e) {
      if (kDebugMode) {
        beepoPrint(e);
      }
    }
  }

  @override
  void initState() {
    getAssests();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    beepoPrint(widget.data);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
            size: 30,
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  '\$${widget.data!['current_price'].toString()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 5),
                widget.data!['24h_price_change'] != null
                    ? AppText(
                        text: '${widget.data!['24h_price_change'].toString()}%',
                        color: widget.data!['24h_price_change'] > 0
                            ? AppColors.activeTextColor
                            : AppColors.favouriteButtonRed,
                      )
                    : const AppText(
                        text: 'null',
                        color: AppColors.favouriteButtonRed,
                      ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: MediaQuery.of(context).size.height / 3,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.secondaryColor,
              ),
              child: Column(children: [
                const SizedBox(height: 75),
                CircleAvatar(
                  radius: 28.r,
                  backgroundImage: NetworkImage(widget.data!['logoUrl']),
                  backgroundColor: AppColors.backgroundGrey,
                ),
                const SizedBox(height: 8),
                AppText(
                  text: "${widget.data!['bal']} ${widget.data!['ticker']}",
                  fontSize: 20.sp,
                  color: AppColors.white,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const SizedBox(),
                    Column(
                      children: [
                        Transform.rotate(
                          angle: 24.5,
                          child: IconButton(
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return SendToken(data: widget.data!);
                              }));
                            },
                            icon: const Icon(
                              Icons.send_outlined,
                              size: 30,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        AppText(
                          text: "Send",
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return TokenScreenScan(data: widget.data!);
                            }));
                          },
                          icon: const Icon(
                            Icons.file_download_sharp,
                            size: 30,
                            color: AppColors.white,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        AppText(
                          text: "Receive",
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ],
                    ),
                    const SizedBox(),
                  ],
                ),
              ]),
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(
              Icons.qr_code_scanner,
              size: 40,
              color: AppColors.secondaryColor,
            ),
            title: AppText(
              text: "Your address",
              fontSize: 14.sp,
              color: AppColors.secondaryColor,
            ),
            subtitle: AppText(
              text: widget.data!['address'],
              fontSize: 12.sp,
              color: AppColors.secondaryColor,
            ),
            trailing: IconButton(
              onPressed: () async {
                await Clipboard.setData(
                    ClipboardData(text: widget.data!['address']));
                showToast('Address Copied To Clipboard!');
              },
              icon: const Icon(
                Icons.copy_outlined,
                size: 30,
                color: AppColors.secondaryColor,
              ),
            ),
          ),
          const Divider(
            height: 2,
            thickness: 2,
          ),
          tx == null
              ? SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 200,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : tx!.isEmpty
                  ? SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 200,
                      child: const Center(
                        child: Text('No Transactions Yet!'),
                      ),
                    )
                  : Expanded(
                      child: Container(
                      color: Colors.white,
                      width: double.infinity,
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: tx!.length,
                        itemBuilder: (ctx, i) {
                          return ListTile(
                            minLeadingWidth: 10,
                            leading: Icon(
                              tx![i]['type'] == 'Send'
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              size: 20,
                              color: tx![i]['type'] == 'Send'
                                  ? Colors.red
                                  : Colors.green,
                            ),
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return TransferInfo(
                                    data: {'tx': tx![i], 'data': widget.data});
                              }));
                            },
                            title: Row(
                              children: [
                                Expanded(
                                  child: AppText(
                                    text: "${tx![i]['type']}",
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.secondaryColor,
                                  ),
                                ),
                                AppText(
                                  text:
                                      "${tx![i]['value']} ${widget.data!['ticker']}",
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: tx![i]['type'] == 'Send'
                                      ? Colors.red
                                      : Colors.green,
                                ),
                              ],
                            ),
                            subtitle: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    tx![i]['type'] == 'Send'
                                        ? "To: ${tx![i]['to']}"
                                        : "From: ${tx![i]['from']}",
                                    style: TextStyle(
                                      color: const Color(0x7f0e014c),
                                      fontSize: 10.sp,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  DateFormat('M-d-yyyy hh:mm a').format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                          tx![i]['timestamp'] * 1000)),
                                  style: TextStyle(
                                    color: const Color(0x7f0e014c),
                                    fontSize: 10.sp,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    )),
        ],
      ),
    );
  }
}
