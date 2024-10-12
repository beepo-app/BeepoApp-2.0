// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:convert';

import 'package:Beepo/constants/constants.dart';
import 'package:Beepo/providers/account_provider.dart';
import 'package:Beepo/providers/chat_provider.dart';
import 'package:Beepo/services/database.dart';
import 'package:Beepo/widgets/cache_memory_image_provider.dart';
import 'package:Beepo/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class MomentsScreens extends StatefulWidget {
  final Map data;
  const MomentsScreens({super.key, required this.data});
  @override
  State<MomentsScreens> createState() => _MomentsScreensState();
}

class _MomentsScreensState extends State<MomentsScreens> {
  final PageController _pageController = PageController(initialPage: 0);
  int _activePage = 0;

  void _next(_page, statuses) {
    if (_page == statuses.length - 1) {
      return Navigator.of(context).pop();
    }

    _pageController.nextPage(
      duration: kTabScrollDuration,
      curve: Curves.ease,
    );
  }

  void _prev(_page) {
    if (_page == 0) return;

    _pageController.previousPage(
      duration: kTabScrollDuration,
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    final acctProvider = Provider.of<AccountProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    var userData = (widget.data['userData']);
    var sIndex = widget.data['curIndex'];
    List allStatuses = (widget.data['data']);
    List statuses = allStatuses[sIndex]['data'];

    List? viewedStatuses = Hive.box('Beepo2.0').get('viewedStatuses');

    if (viewedStatuses != null) {
      var viewed = viewedStatuses
          .firstWhereOrNull((e) => e == statuses[_activePage]['id']);
      if (viewed == null) {
        viewedStatuses.add(statuses[_activePage]['id']);
        Hive.box('Beepo2.0').put('viewedStatuses', viewedStatuses);

        dbUpdateStatusViewsCount(acctProvider.db!, statuses[_activePage]['id'],
            allStatuses[sIndex]['ethAddress'], acctProvider.ethAddress!);
      }
    } else {
      List v = [];
      v.add(statuses[_activePage]['id']);
      Hive.box('Beepo2.0').put('viewedStatuses', v);

      dbUpdateStatusViewsCount(acctProvider.db!, statuses[_activePage]['id'],
          allStatuses[sIndex]['ethAddress'], acctProvider.ethAddress!);
    }

    String? me = (context.read<AccountProvider>().ethAddress);

    int viewersCount = (allStatuses[sIndex]['viewers']).length;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            PageView.builder(
              physics: const NeverScrollableScrollPhysics(),
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _activePage = page;
                });
              },
              itemCount: statuses.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (details) {
                    double width = (MediaQuery.of(context).size.width);
                    if (details.globalPosition.dx <= (width / 2))
                      return _prev(index);
                    _next(index, statuses);
                  },
                  onVerticalDragEnd: (details) {
                    List users = Hive.box('Beepo2.0').get('allUsers');

                    if (details.primaryVelocity! > 0) {
                      if (sIndex < 1) {
                        showToast('First Item!');
                        return;
                      }
                      var prevStatus = users.firstWhereOrNull((e) =>
                          e['ethAddress'] ==
                          allStatuses[sIndex - 1]['data'].last['ethAddress']);
                      Navigator.pop(
                        context,
                        {
                          'data': allStatuses,
                          "curIndex": sIndex - 1,
                          'userData': prevStatus,
                        },
                      );
                    }

                    if (details.primaryVelocity! < 0) {
                      if (sIndex < allStatuses.length - 1) {
                        var nextStatus = users.firstWhereOrNull((e) =>
                            e['ethAddress'] ==
                            allStatuses[sIndex + 1]['data'].last['ethAddress']);
                        Navigator.pop(
                          context,
                          {
                            'data': allStatuses,
                            "curIndex": sIndex + 1,
                            'userData': nextStatus,
                          },
                        );

                        return;
                      }
                      showToast('Last Item Reached!');
                    }
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image:
                            MemoryImage(base64Decode(statuses[index]['image'])),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List<Widget>.generate(
                  statuses.length,
                  (index) => Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: statuses.length > 10 ? 2 : 10),
                    child: statuses.length > 10
                        ? Padding(
                            padding: const EdgeInsets.only(top: 25.0),
                            child: Container(
                              width: (MediaQuery.of(context).size.width /
                                      statuses.length) -
                                  4,
                              height: 5.0,
                              decoration: BoxDecoration(
                                color: _activePage == index
                                    ? Colors.white
                                    : Colors.grey,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                          )
                        : InkWell(
                            onTap: () {
                              // _pageController.nextPage(duration: duration, curve: curve)
                              _pageController.animateToPage(index,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeIn);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(top: 25.0),
                              child: Container(
                                width: (MediaQuery.of(context).size.width /
                                        statuses.length) -
                                    20, // Adjust the width as needed
                                height: 5.0, // Adjust the height as needed
                                decoration: BoxDecoration(
                                  color: _activePage == index
                                      ? Colors.white
                                      : Colors.grey, // Background color
                                  borderRadius: BorderRadius.circular(
                                      20.0), // Adjust the radius to round the corners
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 50,
              left: 1.w,
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          color: AppColors.white,
                          size: 30,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 20.r,
                            backgroundImage: CacheMemoryImageProvider(
                                userData['image'],
                                base64Decode(userData['image'])),
                          ),
                          SizedBox(width: 10.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                me == (userData['ethAddress'])
                                    ? "You"
                                    : userData['displayName'],
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: AppColors.white,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.visibility,
                                    color: AppColors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 3.w),
                                  Text(
                                    "${(viewersCount > 1000 ? '${(viewersCount / 1000).toString()}k' : viewersCount.toString())} ${viewersCount > 1 ? "Views" : "View"} ",
                                    style: TextStyle(
                                      fontSize: 9.4.sp,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  me == (userData['ethAddress'])
                      ? IconButton(
                          onPressed: () async {
                            showAlertDialog(BuildContext context) {
                              // set up the buttons
                              Widget cancelButton = TextButton(
                                child: const Text("No"),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              );
                              Widget continueButton = TextButton(
                                child: const Text("Yes"),
                                onPressed: () async {
                                  statuses.remove(statuses[_activePage]);
                                  Navigator.pop(context);
                                  showToast('Deleting Status!');
                                  await chatProvider.deleteStatus(
                                      acctProvider.db,
                                      statuses,
                                      acctProvider.ethAddress);
                                },
                              );

                              // set up the AlertDialog
                              AlertDialog alert = AlertDialog(
                                title: const Text("Delete Status!"),
                                content: const Text(
                                    "Are you sure you want to delete this status?"),
                                actions: [
                                  cancelButton,
                                  continueButton,
                                ],
                              );

                              // show the dialog
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return alert;
                                },
                              );
                            }

                            showAlertDialog(context);
                          },
                          icon: const Icon(
                            Icons.delete_forever,
                            color: AppColors.white,
                            size: 30,
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 45.h,
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                ),
                child: Text(
                  statuses[_activePage]['message'],
                  style: const TextStyle(
                    color: AppColors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            // Icons on the Background
            // Positioned(
            //   top: 340.h,
            //   left: 250.w,
            //   right: 0,
            //   child: Column(
            //     children: [
            //       IconButton(
            //         onPressed: () {},
            //         icon: const Icon(
            //           Icons.favorite,
            //           size: 50,
            //           color: AppColors.white,
            //         ),
            //       ),
            //       const Text(
            //         '112.10q',
            //         style: TextStyle(
            //           color: Color.fromARGB(255, 251, 250, 252),
            //           fontSize: 14,
            //           fontWeight: FontWeight.w300,
            //         ),
            //       ),
            //       SizedBox(height: 5.h),
            //       InkWell(
            //         onTap: () {},
            //         child: SvgPicture.asset(
            //           'assets/share.svg',
            //           width: 30.w,
            //           height: 30.h,
            //           // ignore: deprecated_member_use
            //           color: const Color.fromARGB(255, 248, 245, 245),
            //         ),
            //       ),
            //       const Text(
            //         '676',
            //         style: TextStyle(
            //           color: Color.fromARGB(255, 253, 252, 253),
            //           fontSize: 14,
            //           fontWeight: FontWeight.w300,
            //         ),
            //       )
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
