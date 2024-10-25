import 'package:flutter/material.dart';
import 'package:foods_rescue/Utils/appcolors.dart';

class ContactInfoScreen extends StatelessWidget {
  final List<String> developerNames = [
    'Saif Ullah',
    'Misbah Mazhar',
    'Syeda Tehzeeb Zahra'
  ];

 ContactInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
            onTap: (){
              Navigator.of(context).pop();
            },
            child: const Icon(Icons.arrow_back,color: AppColor.subheadingColor,)),
          backgroundColor: AppColor.appbarColor,
          title:  Text('Contact Information',style: AppColor.bebasstyle(),),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListView.builder(
                shrinkWrap: true,
                itemCount: developerNames.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      color: AppColor.appbarColor,
                      child: ListTile(
                        leading:  const Icon(Icons.person,color: AppColor.subheadingColor,),
                        title:  Text('Developer Name',style: AppColor.bebasstyle(),),
                        subtitle: Text(developerNames[index],style: AppColor.bebasstyle(),),
                      ),
                    ),
                  );
                },
              ),
              const Divider(
                color: AppColor.appbarColor,
              ),
               Container(
                color: AppColor.appbarColor,
                 child: ListTile(
                  leading: const Icon(Icons.email,color: AppColor.subheadingColor,),
                  title: Text('Contact Email',style: AppColor.bebasstyle(),),
                  subtitle: Text('msb71004105@gmail.com',style: AppColor.bebasstyle(),),
                               ),
               ),
               const SizedBox(height: 10,),
               Container(
                color: AppColor.appbarColor,
                 child: ListTile(
                  leading: const Icon(Icons.email,color: AppColor.subheadingColor,),
                  title: Text('Contact Number',style: AppColor.bebasstyle(),),
                  subtitle: Text('03000758240',style: AppColor.bebasstyle(),),
                               ),
               ),
            ],
          ),
        ),
      ),
    );
  }
}
