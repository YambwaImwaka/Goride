import 'package:cached_network_image/cached_network_image.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/controller/on_boarding_controller.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/themes/button_them.dart';
import 'package:driver/ui/auth_screen/login_screen.dart';
import 'package:driver/utils/Preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<OnBoardingController>(
      init: OnBoardingController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: controller.isLoading.value
              ? Constant.loader(context)
              : Stack(
                  children: [
                    controller.selectedPageIndex.value == 0
                        ? Image.asset("assets/images/onboarding_1.png")
                        : controller.selectedPageIndex.value == 1
                            ? Image.asset("assets/images/onboarding_2.png")
                            : Image.asset("assets/images/onboarding_3.png"),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 3,
                          child: PageView.builder(
                              controller: controller.pageController,
                              onPageChanged: controller.selectedPageIndex,
                              itemCount: controller.onBoardingList.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    const SizedBox(
                                      height: 80,
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(40),
                                        child: CachedNetworkImage(
                                          imageUrl: controller.onBoardingList[index].image.toString(),
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Constant.loader(context),
                                          errorWidget: (context, url, error) => Image.network(Constant.userPlaceHolder),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text(
                                            Constant.localizationTitle(controller.onBoardingList[index].title),
                                            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 1.5),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                            child: Text(
                                              Constant.localizationDescription(controller.onBoardingList[index].description),
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.poppins(fontWeight: FontWeight.w400, letterSpacing: 1.5),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                );
                              }),
                        ),
                        Expanded(
                            child: Column(
                          children: [
                            controller.selectedPageIndex.value == 2 ?SizedBox():InkWell(
                                onTap: () {
                                  controller.pageController.jumpToPage(2);
                                },
                                child: Text(
                                  'skip'.tr,
                                  style: const TextStyle(fontSize: 16, letterSpacing: 1.5, fontWeight: FontWeight.w600),
                                )),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 30),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  controller.onBoardingList.length,
                                  (index) => Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      width: controller.selectedPageIndex.value == index ? 30 : 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: controller.selectedPageIndex.value == index ? AppColors.primary : const Color(0xffD4D5E0),
                                        borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                                      )),
                                ),
                              ),
                            ),
                            ButtonThem.buildButton(
                              context,
                              title: controller.selectedPageIndex.value == 2 ? 'Get started'.tr : 'Next'.tr,
                              btnRadius: 30,
                              onPress: () {
                                if (controller.selectedPageIndex.value == 2) {
                                  Preferences.setBoolean(Preferences.isFinishOnBoardingKey, true);
                                  Get.offAll(const LoginScreen());
                                } else {
                                  controller.pageController.jumpToPage(controller.selectedPageIndex.value + 1);
                                }
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        ))
                      ],
                    ),
                  ],
                ),
        );
      },
    );
  }
}
