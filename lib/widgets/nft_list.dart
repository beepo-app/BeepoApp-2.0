import 'package:Beepo/constants/constants.dart';
import 'package:Beepo/screens/wallet/wallet_token_screen.dart';
import 'package:Beepo/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NFTList extends StatefulWidget {
  final List<dynamic> assets_;
  const NFTList({
    required this.assets_,
    super.key,
  });

  @override
  State<NFTList> createState() => _NFTListState();
}

class _NFTListState extends State<NFTList> {
  bool isColor = false;
  bool isFetched = false;

  @override
  Widget build(BuildContext context) {
    List<dynamic> assets = widget.assets_;
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
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
          color: AppColors.white,
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
                Row(
                  children: [
                    AppText(text: '\$${assets[index]['current_price'].toString()}'),
                    SizedBox(width: 8.w),
                    AppText(
                      text: '${assets[index]['24h_price_change'].toString()}%',
                      color: assets[index]['24h_price_change'] > 0 ? AppColors.activeTextColor : AppColors.favouriteButtonRed,
                    ),
                  ],
                ),
                AppText(text: "\$${assets[index]['bal_to_price'].toString()}"),
              ],
            ),
          ),
        );
      },
    );
  }
}
