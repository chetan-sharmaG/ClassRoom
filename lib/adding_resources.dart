import 'package:flutter/material.dart';

class UpdatingResources extends StatefulWidget {
  //const UpdatingResources({super.key});
  final String addType;

  const UpdatingResources({required this.addType, Key? key}) : super(key: key);

  @override
  State<UpdatingResources> createState() => _UpdatingResourcesState();
}

class _UpdatingResourcesState extends State<UpdatingResources> {
  String Dropdownvalue = 'DSC';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Add Subject',
          style: TextStyle(fontWeight: FontWeight.w400, color: Colors.white),
        ),
        toolbarHeight: 70,
        backgroundColor: const Color(0xff2c2e3a),
      ),
      body: Center(
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 18,right: 18,top: 20),
                  child: Text('Subject Type',style: TextStyle(
                    fontSize: 18,fontWeight: FontWeight.w600
                  ),),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: DropdownButton(
                      value: Dropdownvalue,
                      items: <String>['DSC', 'OTHERS'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value,style: const TextStyle(
                            fontStyle: FontStyle.normal
                          ),),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          Dropdownvalue = newValue!;
                        });
                      }),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
