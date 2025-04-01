import 'package:cached_network_image/cached_network_image.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/model/user_model.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserView extends StatelessWidget {
  final String? userId;
  final String? amount;
  final String? distance;
  final String? distanceType;

  const UserView({Key? key, this.userId, this.amount, this.distance, this.distanceType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
        future: FireStoreUtils.getCustomer(userId.toString()),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const SizedBox();
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              } else {
                if (snapshot.data == null) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        child: CachedNetworkImage(
                          height: 50,
                          width: 50,
                          imageUrl: Constant.userPlaceHolder,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Constant.loader(context),
                          errorWidget: (context, url, error) => Image.network(
                              'https://firebasestorage.googleapis.com/v0/b/goride-1a752.appspot.com/o/placeholderImages%2Fuser-placeholder.jpeg?alt=media&token=34a73d67-ba1d-4fe4-a29f-271d3e3ca115'),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Asynchronous user", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(Constant.amountShow(amount: amount.toString()), style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 18,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text("${(double.parse(distance.toString())).toStringAsFixed(Constant.currencyModel!.decimalDigits!)} $distanceType",
                                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      size: 22,
                                      color: AppColors.ratingColour,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(Constant.calculateReview(reviewCount: "0.0", reviewSum: "0.0"), style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  );
                }
                UserModel driverModel = snapshot.data!;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      child: CachedNetworkImage(
                        height: 50,
                        width: 50,
                        imageUrl: driverModel.profilePic.toString(),
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Constant.loader(context),
                        errorWidget: (context, url, error) => Image.network(
                            'https://firebasestorage.googleapis.com/v0/b/goride-1a752.appspot.com/o/placeholderImages%2Fuser-placeholder.jpeg?alt=media&token=34a73d67-ba1d-4fe4-a29f-271d3e3ca115'),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(driverModel.fullName.toString(), style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(Constant.amountShow(amount: amount.toString()), style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 18,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text("${(double.parse(distance.toString())).toStringAsFixed(Constant.currencyModel!.decimalDigits!)} $distanceType",
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 22,
                                    color: AppColors.ratingColour,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(Constant.calculateReview(reviewCount: driverModel.reviewsCount, reviewSum: driverModel.reviewsSum), style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                );
              }
            default:
              return const Text('Error');
          }
        });
  }
}
