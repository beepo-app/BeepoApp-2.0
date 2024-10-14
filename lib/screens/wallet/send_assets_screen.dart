import 'package:Beepo/constants/constants.dart';
import 'package:Beepo/screens/wallet/send_token_screen.dart';
import 'package:Beepo/widgets/app_text.dart';
import 'package:Beepo/widgets/Beepo_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SendAssetsScreen extends StatefulWidget {
  final List<dynamic> assets_;
  const SendAssetsScreen({
    required this.assets_,
    super.key,
  });

  @override
  State<SendAssetsScreen> createState() => _SendAssetsScreenState();
}

class _SendAssetsScreenState extends State<SendAssetsScreen> {
  bool isColor = false;

  @override
  Widget build(BuildContext context) {
    List<dynamic> assets = widget.assets_;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.white,
          ),
        ),
        centerTitle: true,
        toolbarHeight: 60.h,
        backgroundColor: AppColors.secondaryColor,
        title: Column(
          children: [
            AppText(
              text: "Send Token",
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
            SizedBox(height: 2.h),
            AppText(
              text: "Choose asset",
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 10.h),
        child: Column(
          children: [
            const BeepoTextField(
              prefixIcon: Icon(
                Icons.search,
                color: AppColors.borderGrey,
              ),
            ),
            SizedBox(height: 15.h),
            Expanded(
              child: ListView.separated(
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SendToken(data: assets[index]),
                          ),
                        );
                      },
                      leading: Image.network(assets[index]['logoUrl']),
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
                              AppText(
                                  text:
                                      '\$${assets[index]['current_price'].toString()}'),
                              SizedBox(width: 8.w),
                              AppText(
                                text:
                                    '${assets[index]['24h_price_change'].toString()}%',
                                color: assets[index]['24h_price_change'] > 0
                                    ? AppColors.activeTextColor
                                    : AppColors.favouriteButtonRed,
                              ),
                            ],
                          ),
                          AppText(
                              text:
                                  "\$${assets[index]['bal_to_price'].toString()}"),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
