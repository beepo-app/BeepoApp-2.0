import 'package:Beepo/constants/constants.dart';
import 'package:Beepo/providers/wallet_provider.dart';
import 'package:Beepo/screens/wallet/wallet_token_screen.dart';
import 'package:Beepo/utils/logger.dart';
import 'package:Beepo/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class WalletList extends StatefulWidget {
  final List<dynamic> assets_;
  const WalletList({
    required this.assets_,
    super.key,
  });

  @override
  State<WalletList> createState() => _WalletListState();
}

class _WalletListState extends State<WalletList> {
  bool isColor = false;
  bool isFetched = false;

  Future<bool> onRefresh() async {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    var data = await walletProvider.getAssets();
    beepoPrint('data');
    beepoPrint(data);
    beepoPrint('data');
    return true;
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> assets = widget.assets_;
    // beepoPrint(widget.assets_);

    return ListView.separated(
      itemCount: assets.length,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      separatorBuilder: (_, int index) {
        return const SizedBox(height: 20);
      },
      itemBuilder: (_, int index) {
        return Material(
          // elevation: 2,
          // shape: RoundedRectangleBorder(
          //   borderRadius: BorderRadius.circular(15.r),
          // ),
          color: AppColors.white,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: const Offset(2, 1), // changes position of shadow
                ),
              ],
            ),
            child: ListTile(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return WalletTokenScreen(data: assets[index]);
                }));
              },
              leading: CircleAvatar(
                backgroundImage: NetworkImage(assets[index]['logoUrl']),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(text: assets[index]['displayName']),
                  AppText(text: assets[index]['bal']),
                ],
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  assets[index]['24h_price_change'] != null
                      ? Row(
                          children: [
                            AppText(
                                text:
                                    '\$${assets[index]['current_price'].toString()}'),
                            SizedBox(width: 8.w),
                            AppText(
                              text:
                                  '${assets[index]['24h_price_change'].toString()}%',
                              color: assets[index]['24h_price_change'] != null
                                  ? assets[index]['24h_price_change'] > 0
                                      ? AppColors.activeTextColor
                                      : AppColors.favouriteButtonRed
                                  : AppColors.favouriteButtonRed,
                            ),
                          ],
                        )
                      : const Row(
                          children: [
                            AppText(text: 'null'),
                            SizedBox(width: 8),
                            AppText(
                              text: 'null',
                              color: AppColors.favouriteButtonRed,
                            ),
                          ],
                        ),
                  assets[index]['bal_to_price'] != null
                      ? AppText(
                          text: "\$${assets[index]['bal_to_price'].toString()}")
                      : const AppText(text: "null"),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
