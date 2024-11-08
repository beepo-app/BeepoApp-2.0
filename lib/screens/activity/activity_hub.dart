import 'package:Beepo/widgets/activity_button.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ActivityHubScreen extends StatefulWidget {
  const ActivityHubScreen({super.key});

  @override
  State<ActivityHubScreen> createState() => _ActivityHubScreenState();
}

class _ActivityHubScreenState extends State<ActivityHubScreen> {
  @override
  Widget build(BuildContext context) {
    // final accountProvider = Provider.of<AccountProvider>(context);

    // final username = accountProvider.username;

    // String getReferralLink(String? username) {
    //   return 'https://play.google.com/store/apps/details?id=com.beepo.app&referrer=$username';
    // }

    // String referralLink = getReferralLink(username);

    // final dailyPointProvider = Provider.of<NewPointsProvider>(context).points;

    // final timeBasedPointsProvider =
    //     Provider.of<TimeBasedPointsProvider>(context).points;

    // final referralPoints = Provider.of<ReferralProvider>(context).points;
    // final canClaimPoints = Provider.of<NewPointsProvider>(context).canClaim;

    // // Calculate total points
    // final totalPoints =
    //     dailyPointProvider + timeBasedPointsProvider + referralPoints;

    // final totalPointProvider = Provider.of<TotalPointProvider>(context);
    // final rankDescriptions = {
    //   'Novice': 'This is the starting rank. Earn more points to level up!',
    //   'Amateur': 'You are gaining experience. Keep earning points!',
    //   'Senior': 'You are becoming experienced. Continue the good work!',
    //   'Enthusiast': 'You are passionate about your activities. Great job!',
    //   'Professional': 'You are skilled and consistent. Keep pushing forward!',
    //   'Expert': 'You have reached a high level of expertise. Impressive!',
    //   'Leader': 'You are among the best. Others look up to you!',
    //   'Veteran': 'You have a wealth of experience. True dedication!',
    //   'Master': 'You have mastered the system. Few can match your skills!',
    //   'Great': 'An exceptional rank, achieved by very few!',
    // };

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: const Text(
          'Activity Hub',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 30,
          ),
          onPressed: () {},
        ),
        centerTitle: true,
        backgroundColor: const Color(0xff0e014C),
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(
                height: 15,
              ),
              Container(
                color: const Color.fromRGBO(241, 240, 240, 1),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 15, right: 20, top: 15, bottom: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40.0,
                            height: 40.0,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: const Color.fromRGBO(231, 231, 231, 1)),
                            child: Icon(
                              Iconsax.info_circle,
                              color: const Color.fromRGBO(250, 145, 8, 1),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Beeper Rank',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff0e014C),
                                ),
                              ),
                              const SizedBox(
                                height: 1,
                              ),
                              Text(
                                "Professional",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xff0e014C),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Rank Information'),
                                content: Text(
                                  'No description available.',
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text('OK'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: const Icon(
                          Iconsax.info_circle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                color: const Color.fromRGBO(241, 240, 240, 1),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 15, right: 20, top: 15, bottom: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40.0,
                            height: 40.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: const Color.fromRGBO(231, 231, 231, 1),
                            ),
                            child: const Icon(
                              Iconsax.user_add,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total Referrals',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff0e014C),
                                ),
                              ),
                              const SizedBox(
                                height: 1,
                              ),
                              Text(
                                '105',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromRGBO(250, 145, 8, 1),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () async {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Referral link copied!')),
                              );
                            },
                            icon: const Icon(
                              Iconsax.copy,
                            ),
                          ),
                          IconButton(
                            onPressed: () async {},
                            icon: const Icon(
                              Iconsax.global,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                color: const Color.fromRGBO(241, 240, 240, 1),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 15, right: 20, top: 15, bottom: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40.0,
                            height: 40.0,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: const Color.fromRGBO(231, 231, 231, 1)),
                            child: const Icon(
                              Iconsax.award,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Beep Points Earned',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff0e014C),
                                ),
                              ),
                              const SizedBox(
                                height: 1,
                              ),
                              Text(
                                "10,465",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromRGBO(250, 145, 8, 1),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Opacity(
                        opacity: 1.0,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: const Color(0xffD9D9D9),
                            foregroundColor: const Color(0xff263238),
                            fixedSize: const Size(120, 1),
                          ),
                          onPressed: () {},
                          child: const Text('Withdraw'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                color: const Color.fromRGBO(241, 240, 240, 1),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 15, right: 20, top: 15, bottom: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40.0,
                            height: 40.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: const Color.fromRGBO(231, 231, 231, 1),
                            ),
                            child: const Icon(
                              Iconsax.clock,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Daily Login Point',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff0e014C),
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: const Color(0xffD9D9D9),
                          foregroundColor: const Color(0xff263238),
                          fixedSize: const Size(120, 1),
                        ),
                        onPressed: () {},
                        child: const Text('Claim'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 35,
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 15),
                  child: Text(
                    'Featured Tasks',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xff0E014C),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              ActivityButton(
                checkStatus: true,
                mytext: 'Send a tweet ‘bout us',
                buttontext: '100p',
                press: () {},
                icon: Iconsax.send_1,
              ),
              const SizedBox(
                height: 10,
              ),
              ActivityButton(
                checkStatus: false,
                mytext: 'Stay active for 3hrs',
                buttontext: '500P',
                icon: Iconsax.tick_circle,
              ),
              const SizedBox(
                height: 10,
              ),
              ActivityButton(
                checkStatus: true,
                mytext: 'Daily Moment Point',
                buttontext: '50p',
                press: () {},
                icon: Iconsax.status_up,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
