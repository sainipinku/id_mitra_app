import 'package:flutter/material.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/components/my_font_weight.dart';


LogoutBottomDilog({
  required BuildContext buildContext,
  required VoidCallback button,
  required String title,
  required String desc,
}) {
  showModalBottomSheet<void>(
    context: buildContext,
    isScrollControlled: true,
    backgroundColor: AppTheme.whiteColor,
    shape: const RoundedRectangleBorder(
      // <-- SEE HERE
      borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
    ),
    builder: (BuildContext context) {
      return SingleChildScrollView(
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      title,
                      style: MyStyles.boldText(
                        size: 18,
                        color: AppTheme.black_Color,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                      child: Text(
                        desc,
                        textAlign: TextAlign.center,
                        style: MyStyles.regularText(
                          size: 14,
                          color: AppTheme.graySubTitleColor,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: buttonFunWidget(
                              button: () {
                                Navigator.pop(context);
                              },
                              txt: 'Cancel',
                              txtClr: AppTheme.whiteColor,
                              bgClr: AppTheme.redBtnBgColor,
                            ),
                          ),
                          Expanded(
                            child: buttonFunWidget(
                              button: () {
                                Navigator.pop(context);
                                button();
                              },
                              txt: 'Yes',
                              txtClr: AppTheme.whiteColor,
                              bgClr: AppTheme.MainColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget buttonFunWidget({
  required VoidCallback button,
  required String txt,
  required Color txtClr,
  required Color bgClr,
}) {
  return GestureDetector(
    onTap: () {
      button();
    },
    child: Container(
      height: 45,
      margin: const EdgeInsets.only(left: 10.0),
      decoration: BoxDecoration(
        color: bgClr,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Center(
        child: Text(
          txt,
          textAlign: TextAlign.center,
          style: MyStyles.regularText(size: 14, color: txtClr),
        ),
      ),
    ),
  );
}
