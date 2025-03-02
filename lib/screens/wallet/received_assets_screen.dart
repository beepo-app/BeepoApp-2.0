import 'package:Beepo/constants/constants.dart';
import 'package:Beepo/screens/wallet/token_screen_scan.dart';
import 'package:Beepo/widgets/app_text.dart';
import 'package:Beepo/widgets/Beepo_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReceivedAssetScreen extends StatefulWidget {
  final List<dynamic> assets_;
  const ReceivedAssetScreen({
    required this.assets_,
    super.key,
  });

  @override
  State<ReceivedAssetScreen> createState() => _ReceivedAssetScreenState();
}

class _ReceivedAssetScreenState extends State<ReceivedAssetScreen> {
  @override
  Widget build(BuildContext context) {
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
              text: "Receive Token",
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
                itemCount: widget.assets_.length,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
                separatorBuilder: (_, int index) {
                  return const SizedBox(height: 20);
                },
                itemBuilder: (_, int index) {
                  final asset = widget.assets_[index];
                  final logoUrl = asset['logoUrl'] as String?;
                  final displayName =
                      asset['displayName'] as String? ?? "Unknown";
                  final bal = asset['bal'] as String? ?? "0.0";
                  final currentPrice =
                      asset['current_price']?.toString() ?? "0.00";
                  final priceChange =
                      asset['24h_price_change']?.toString() ?? "0.0";
                  final balToPrice =
                      asset['bal_to_price']?.toString() ?? "0.00";
                  final priceChangeColor =
                      (double.tryParse(priceChange) ?? 0.0) > 0
                          ? AppColors.activeTextColor
                          : AppColors.favouriteButtonRed;

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
                            builder: (context) => TokenScreenScan(data: asset),
                          ),
                        );
                      },
                      leading: logoUrl != null
                          ? Image.network(
                              logoUrl,
                            )
                          : const Icon(Icons.image_not_supported,
                              color: Colors.grey),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppText(text: displayName),
                          AppText(text: bal),
                        ],
                      ),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              AppText(text: '\$$currentPrice'),
                              SizedBox(width: 8.w),
                              AppText(
                                text: '$priceChange%',
                                color: priceChangeColor,
                              ),
                            ],
                          ),
                          AppText(text: "\$$balToPrice"),
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
