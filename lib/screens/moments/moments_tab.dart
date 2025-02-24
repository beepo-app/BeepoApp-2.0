import 'dart:convert';

import 'package:Beepo/constants/constants.dart';
import 'package:Beepo/providers/account_provider.dart';
import 'package:Beepo/providers/chat_provider.dart';
import 'package:Beepo/screens/moments/blank_status_screen.dart';
import 'package:Beepo/widgets/app_text.dart';
import 'package:Beepo/widgets/cache_memory_image_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_utils/src/extensions/export.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class MomentsTab extends StatefulWidget {
  const MomentsTab({
    super.key,
  });

  @override
  State<MomentsTab> createState() => _MomentsTabState();
}

class _MomentsTabState extends State<MomentsTab> {
  @override
  Widget build(BuildContext context) {
    List? statuses = context.watch<ChatProvider>().statuses;
    List users = Hive.box('Beepo2.0').get('allUsers');

    String? me = (context.read<AccountProvider>().ethAddress);
    var dd =
        statuses?.firstWhereOrNull((e) => e['ethAddress'] == me.toString());
    if (dd != null) {
      statuses?.remove(dd);
      statuses?.add(dd);
    }
    statuses = statuses?.reversed.toList();

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 9.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Center(
                child: SvgPicture.asset(
              'assets/coming-soon.svg',
              height: 150.h,
              width: 150.w,
              fit: BoxFit.cover,
            )),
            SizedBox(height: 8.h),
            Center(
              child: Text(
                "Coming Soon!",
                style: TextStyle(
                  color: AppColors.secondaryColor,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Text(
            //       "Explore Moments",
            //       style: TextStyle(
            //         color: AppColors.secondaryColor,
            //         fontSize: 15.sp,
            //         fontWeight: FontWeight.bold,
            //       ),
            //     ),
            //     Row(
            //       children: [
            //         AppText(
            //           text: "latests",
            //           color: AppColors.black,
            //           fontSize: 11.sp,
            //           fontWeight: FontWeight.bold,
            //         ),
            //         SizedBox(width: 8.w),
            //         Icon(
            //           Icons.sort,
            //           size: 15.sp,
            //         ),
            //       ],
            //     ),
            //   ],
            // ),
            // SizedBox(height: 5.h),
            // (statuses == null || statuses.isEmpty)
            //     ? const Text('no data')
            //     : Expanded(
            //         child: GridView.builder(
            //           itemCount: statuses.length,
            //           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            //             crossAxisCount: 2,
            //             mainAxisExtent: 175.h,
            //             crossAxisSpacing: 16.0,
            //             mainAxisSpacing: 15,
            //           ),
            //           itemBuilder: (BuildContext context, index) {
            //             List data = (statuses![index]['data']);
            //             int viewersCount = (statuses[index]['viewers']).length;

            //             var userData = users.firstWhereOrNull((e) {
            //               return e['ethAddress'] == data.last['ethAddress'];
            //             });

            //             return InkWell(
            //               onTap: () {
            //                 Navigator.push(context, MaterialPageRoute(builder: (context) {
            //                   return BlankStatusScreen(
            //                     data: {
            //                       'data': statuses,
            //                       "curIndex": index,
            //                       'userData': userData,
            //                     },
            //                   );
            //                 }));
            //               },
            //               child: Container(
            //                 width: double.infinity,
            //                 decoration: BoxDecoration(
            //                   borderRadius: BorderRadius.circular(10.r),
            //                   color: AppColors.greyBoxBg,
            //                   image: DecorationImage(
            //                     image: MemoryImage(base64Decode(data.last['image'])),
            //                     fit: BoxFit.cover,
            //                   ),
            //                 ),
            //                 child: Column(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Container(
            //                       // height: 40.h,
            //                       width: double.infinity,
            //                       decoration: BoxDecoration(
            //                         color: AppColors.black.withOpacity(0.5),
            //                         borderRadius: BorderRadius.only(
            //                           bottomLeft: const Radius.circular(10),
            //                           bottomRight: Radius.circular(10.r),
            //                           topLeft: const Radius.circular(0),
            //                           topRight: const Radius.circular(0),
            //                         ),
            //                         // boxShadow: const <BoxShadow>[
            //                         //   BoxShadow(
            //                         //     color: AppColors.black,
            //                         //     blurRadius: 5.0,
            //                         //     offset: Offset(0, -5.0),
            //                         //   ),
            //                         // ],
            //                       ),
            //                       child: Padding(
            //                         padding: EdgeInsets.only(left: 10.w, bottom: 8.h, top: 8.h),
            //                         child: Row(
            //                           mainAxisAlignment: MainAxisAlignment.start,
            //                           children: [
            //                             CircleAvatar(
            //                               radius: 20.r,
            //                               backgroundColor: AppColors.white,
            //                               backgroundImage: CacheMemoryImageProvider(userData['image'], base64Decode(userData['image'])),
            //                             ),
            //                             SizedBox(width: 8.w),
            //                             Column(
            //                               crossAxisAlignment: CrossAxisAlignment.start,
            //                               children: [
            //                                 AppText(
            //                                   text: me == (userData['ethAddress']) ? "You" : (userData['displayName']),
            //                                   fontSize: 12.sp,
            //                                   color: AppColors.white,
            //                                   fontWeight: FontWeight.bold,
            //                                 ),
            //                                 RichText(
            //                                   text: TextSpan(
            //                                     style: TextStyle(
            //                                       fontSize: 10.sp,
            //                                       color: AppColors.white,
            //                                     ),
            //                                     children: [
            //                                       TextSpan(
            //                                         text: (viewersCount > 1000 ? '${(viewersCount / 1000).toString()}k' : viewersCount.toString()),
            //                                       ),
            //                                       const TextSpan(text: " Views"),
            //                                     ],
            //                                   ),
            //                                 ),
            //                               ],
            //                             ),
            //                           ],
            //                         ),
            //                       ),
            //                     ),
            //                   ],
            //                 ),
            //               ),
            //             );
            //           },
            //         ),
            //       ),
          ],
        ),
      ),
    );
  }
}
