import 'package:Beepo/constants/constants.dart';
import 'package:Beepo/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../widgets/container_button.dart';

class BrowserPage extends StatefulWidget {
  const BrowserPage({Key? key}) : super(key: key);

  @override
  State<BrowserPage> createState() => _BrowserPageState();
}

class _BrowserPageState extends State<BrowserPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffDEEDE6),
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 50.h,
        backgroundColor: AppColors.secondaryColor,
        elevation: 0,
        titleSpacing: -5,
        title: Row(
          children: [
            const Icon(
              Icons.lock,
              color: AppColors.white,
              size: 15,
            ),
            SizedBox(width: 5.w),
            Text(
              "mento.finance",
              style: TextStyle(
                color: AppColors.white,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Transform.rotate(
            angle: 44.8,
            child: const Icon(
              Icons.add,
              color: AppColors.white,
              size: 25,
            ),
          ),
          onPressed: () {},
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              children: [
                Image.asset(
                  'assets/Celo.png',
                  height: 26,
                  width: 26,
                ),
                SizedBox(width: 25.w),
                Icon(
                  Icons.more_vert_sharp,
                  color: AppColors.white,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset('assets/mentofi.png', height: 50),
                const ContainerButton(),
                Container(
                  padding: const EdgeInsets.all(10),
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Icon(
                    Icons.folder_open_rounded,
                    color: Colors.grey,
                    size: 30,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ContainerCard extends StatelessWidget {
  const ContainerCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70.h,
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText(text: "Swap"),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_sharp),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Container(
              height: 40.h,
              width: double.infinity,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Image.asset(
                      'assets/Celo.png',
                      height: 26,
                      width: 26,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Column(
                    children: [
                      const AppText(text: "From Token"),
                      Row(
                        children: [
                          const AppText(text: "CELO"),
                          SizedBox(width: 10.w),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.arrow_drop_down,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                  const VerticalDivider(),
                  const Spacer(),
                  const Text(
                    "0.00",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.backgroundGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
