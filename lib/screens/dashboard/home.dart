import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idmitra/Widgets/svg_file.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/providers/home/home_cubit.dart';
import 'package:idmitra/screens/SelectRolePage/SelectRolePage.dart';
import 'package:idmitra/screens/dashboard/StatCard.dart';
import 'package:idmitra/utils/MyStyles.dart';
import 'package:idmitra/utils/navigation_utils.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {

          /// 🔄 LOADING
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          /// ✅ SUCCESS
          else if (state.dashboard != null) {
            final data = state.dashboard!.data;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// 🔹 STATS GRID
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [

                    StatCard(
                      title: "Total Users",
                      value: data?.users?.total?.toString() ?? "0",
                      icon: Icons.person,
                      color: Colors.blue,
                    ),

                    StatCard(
                      title: "Active Users",
                      value: data?.users?.active?.toString() ?? "0",
                      icon: Icons.person_outline,
                      color: Colors.green,
                    ),

                    StatCard(
                      title: "Total Students",
                      value: data?.students?.total?.toString() ?? "0",
                      icon: Icons.school,
                      color: Colors.orange,
                    ),

                    StatCard(
                      title: "Total Employee",
                      value: data?.employees?.total?.toString() ?? "0",
                      icon: Icons.group,
                      color: Colors.purple,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// 🔹 QUICK ACTIONS CARD
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const Text(
                        "Quick Actions",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// 🔹 ADD USER BUTTON
                      GestureDetector(
                        onTap: () {
                          navigateWithTransition(
                            context: context,
                            page: const SelectRolePage(),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xff1FA2FF), Color(0xff12D8FA)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [

                              Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: AppTheme.btn10perOpacityColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: svgIcon(
                                    icon: 'assets/icons/home/add_user.svg',
                                    clr: AppTheme.whiteColor,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Text(
                                  "Add New Users",
                                  style: MyStyles.semiBoldTxt(
                                      AppTheme.whiteColor, 14),
                                ),
                              ),

                              const CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          /// ❌ ERROR / FALLBACK
          else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    state.error ?? "Something went wrong",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<HomeCubit>().loadHomeData(),
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}