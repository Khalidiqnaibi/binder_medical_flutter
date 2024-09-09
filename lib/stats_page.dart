// stats_page.dart
import 'package:flutter/material.dart';

class StatsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Stats Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.menu, color: Color(0xFF8B8C8E)),
            onPressed: () {
              Navigator.pushNamed(context, '/webview');
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth <= 750;
          return Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                if (isSmallScreen) SizedBox(height: 70),
                Container(
                  width: isSmallScreen ? double.infinity : 770,
                  color: Color(0xFF8B8C8E),
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Color(0xFFABB0BB),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.black),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text('Search Entries Placeholder'),
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Show Visit Info', style: TextStyle(color: Colors.white)),
                          Switch(
                            value: true,
                            onChanged: (bool value) {},
                            activeColor: Colors.black,
                            inactiveTrackColor: Colors.grey,
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Show Date', style: TextStyle(color: Colors.white)),
                          Switch(
                            value: false,
                            onChanged: (bool value) {},
                            activeColor: Colors.black,
                            inactiveTrackColor: Colors.grey,
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Color(0xFFABB0BB),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.black),
                        ),
                        padding: EdgeInsets.all(15.0),
                        child: Text('Result Frame Placeholder'),
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Color(0xFFABB0BB),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.black),
                        ),
                        padding: EdgeInsets.all(10.0),
                        child: Text('Chart Placeholder'),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.5),
                              ),
                            ),
                            child: Text('Search', style: TextStyle(color: Colors.white)),
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.5),
                              ),
                            ),
                            child: Text('See Patients', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
