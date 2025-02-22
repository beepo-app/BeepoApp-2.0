import 'dart:convert';

import 'package:Beepo/constants/constants.dart';
import 'package:Beepo/providers/account_provider.dart';
import 'package:Beepo/providers/chat_provider.dart';
// import 'package:Beepo/screens/messaging/calls/calls_tab.dart';
import 'package:Beepo/screens/messaging/chats/chat_tab.dart';
// import 'package:Beepo/screens/messaging/chats/search_users_screen.dart';
import 'package:Beepo/screens/moments/blank_status_screen.dart';
import 'package:Beepo/screens/moments/init_camera.dart';
import 'package:Beepo/screens/moments/moments_tab.dart';
// import 'package:Beepo/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
// import 'package:hawk_fab_menu/hawk_fab_menu.dart';
import 'package:hive_flutter/hive_flutter.dart';
// import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class ChatTabsScreen extends StatefulWidget {
  const ChatTabsScreen({super.key});

  @override
  State<ChatTabsScreen> createState() => _ChatTabsScreenState();
}

class _ChatTabsScreenState extends State<ChatTabsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // SizedBox(height: 30.h),
          MyTabBar(controller: _tabController),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                ChatTab(),
                MomentsTab(),
                // RequestsTab()
                // CallTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MyTabBar extends StatefulWidget implements PreferredSizeWidget {
  final TabController controller;
  const MyTabBar({
    super.key,
    required this.controller,
  });

  @override
  State<MyTabBar> createState() => _MyTabBarState();

  @override
  Size get preferredSize => Size.fromHeight(50.h);
}

class _MyTabBarState extends State<MyTabBar> {
  int pageIndex = 0;
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      // beepoPrint("CHANGED");
      pageIndex = widget.controller.index;
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.addListener(() {
      // beepoPrint("REVERSED");
      pageIndex = widget.controller.index;
      // setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 28.h),
      color: AppColors.secondaryColor,
      child: Column(
        children: [
          // SizedBox(height: 10.h),
          TabBar(
            indicatorColor: AppColors.white,
            controller: widget.controller,
            tabs: [
              Tab(
                child: Text(
                  "Chats",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  "Moments",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              // Tab(
              //   child: Text(
              //     "Requests",
              //     style: TextStyle(
              //       color: Colors.white,
              //       fontSize: 15.sp,
              //       fontWeight: FontWeight.w700,
              //     ),
              //   ),
              // ),
            ],
          ),

          if ([0, 1].contains(pageIndex)) ...[
            SizedBox(height: 5.h),
            const Statuses(),
            SizedBox(height: 7.h),
          ],
        ],
      ),
    );
  }
}

class Statuses extends StatefulWidget {
  const Statuses({super.key});

  @override
  State<Statuses> createState() => _StatusesState();
}

class _StatusesState extends State<Statuses> {
  @override
  void initState() {
    super.initState();
    _initializeHiveData();
  }

  Future<void> _initializeHiveData() async {
    final box = Hive.box('Beepo2.0');
    if (box.get('allUsers') == null) {
      await box.put('allUsers', []);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: true);
    List? statuses = chatProvider.statuses;
    final List users = Hive.box('Beepo2.0').get('allUsers', defaultValue: []);

    String? me = (context.read<AccountProvider>().ethAddress);

    var dd =
        statuses?.firstWhereOrNull((e) => e['ethAddress'] == me.toString());
    if (dd != null) {
      statuses?.remove(dd);
      statuses?.add(dd);
    }
    statuses = statuses?.reversed.toList();

    return SizedBox(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 20),
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const InitCamera(
                  backDirection: false,
                );
              }));
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  height: 60,
                  width: 60,
                  decoration: const BoxDecoration(
                    color: Color(0xFFC4C4C4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 45,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 6.5.h),
                Text(
                  "Update Moment",
                  style: TextStyle(
                    color: const Color(0xb2ffffff),
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          (statuses == null || statuses.isEmpty)
              ? const Text('no data')
              : Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: 10, right: 10.w),
                    height: 100,
                    child: ListView.builder(
                      primary: false,
                      shrinkWrap: true,
                      // reverse: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: statuses.length,
                      itemBuilder: (context, index) {
                        List data = (statuses![index]['data']);

                        var userData = users.firstWhereOrNull(
                            (e) => e['ethAddress'] == data.last['ethAddress']);

                        return SizedBox(
                          width: 70,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.w),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return BlankStatusScreen(
                                        data: {
                                          'data': statuses,
                                          'curIndex': index,
                                          'userData': userData,
                                        },
                                      );
                                    }));
                                  },
                                  child: Container(
                                    height: 60,
                                    width: 60,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFC4C4C4),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.orange),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: Image(
                                        image: MemoryImage(
                                            base64Decode(data.last['image'])),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 6.5.h),
                              Text(
                                me == (userData['ethAddress'])
                                    ? "You"
                                    : userData['displayName'] ?? 'hi',
                                style: TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  color: const Color(0xb2ffffff),
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
