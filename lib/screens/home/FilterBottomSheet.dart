import 'package:flutter/material.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {

  bool regNo = true;
  bool rollNo = false;
  bool uidNo = false;
  bool name = false;
  bool fatherName = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 420,
      child: Column(
        children: [

          /// HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Filters",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          ),

          const Divider(),

          Expanded(
            child: Row(
              children: [

                /// LEFT MENU
                Container(
                  width: 120,
                  color: Colors.grey.shade100,
                  child: Column(
                    children: const [

                      ListTile(
                        title: Text("Fields"),
                        tileColor: Color(0xffE6F2FF),
                      ),

                      ListTile(
                        title: Text("Gender"),
                      ),

                      ListTile(
                        title: Text("Data Availability"),
                      ),

                      ListTile(
                        title: Text("Class"),
                      ),
                    ],
                  ),
                ),

                /// RIGHT CONTENT
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [

                        /// SEARCH FIELD
                        TextField(
                          decoration: InputDecoration(
                            hintText: "Search Fields...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        /// CHECKBOX LIST
                        CheckboxListTile(
                          value: regNo,
                          title: const Text("Registration No."),
                          onChanged: (val) {
                            setState(() => regNo = val!);
                          },
                        ),

                        CheckboxListTile(
                          value: rollNo,
                          title: const Text("Roll No."),
                          onChanged: (val) {
                            setState(() => rollNo = val!);
                          },
                        ),

                        CheckboxListTile(
                          value: uidNo,
                          title: const Text("UID No."),
                          onChanged: (val) {
                            setState(() => uidNo = val!);
                          },
                        ),

                        CheckboxListTile(
                          value: name,
                          title: const Text("Name"),
                          onChanged: (val) {
                            setState(() => name = val!);
                          },
                        ),

                        CheckboxListTile(
                          value: fatherName,
                          title: const Text("Father name"),
                          onChanged: (val) {
                            setState(() => fatherName = val!);
                          },
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),

          /// BUTTONS
          Row(
            children: [

              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text("Reset"),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: () {},
                  child: const Text("Apply Filter"),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}