import 'package:flutter/material.dart';

class Transferhistory extends StatelessWidget{
  const Transferhistory({Key?key}):super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(height: 400, child: _head()),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Transactions History',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 19,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'See all',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 19,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.asset('images/cre.png'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _head(){
    return Stack(
        children: [
          Column(
            children: [
              Container(
                width: double.infinity,
                height: 240,
                decoration: BoxDecoration(color:Color(0xff368983),
                borderRadius:BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 5,
                      left: 1550,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: Container(
                          height: 40,
                          width: 40,
                          color: Color.fromRGBO(250, 250, 250,0.1),
                          child: Icon(Icons.notification_add_outlined,
                          size: 30,
                          color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Padding(
              
                    padding:const EdgeInsets.only(top: 35,left: 10),
                    child:Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Good afternoon',
                        style: TextStyle(fontWeight:
                        FontWeight.w500,
                        fontSize: 16, 
                        color: Color.fromARGB(255, 224, 223, 223)
                        ),
                        ),
                        Text('User name',
                        style: TextStyle(fontWeight:
                        FontWeight.w600,
                        fontSize: 20, 
                        color: Colors.white,
                        ),
                        ),
                      ],
                    ),
                    ),
                  ],
                )
              ),
            ],
          ),

          Positioned(
            top: 110,
            left: 500,
         child:Container(
          height: 250,
          width: 600,
          decoration: BoxDecoration(
            color: Color.fromARGB(225, 47, 125, 121),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(children: [
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Balace',style: TextStyle(fontWeight:
                          FontWeight.w500,
                          fontSize: 16, 
                          color: Colors.white,
                          ),
                      ),
                      Icon(Icons.more_horiz,color: Colors.white ,
                      ),
                ],
              ),
            ),
            SizedBox(height: 7,),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Row(
                children: [
                  Text('\$ 9999',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: Colors.white,
                  ),
                  )
                ],
              ),
            ),
            SizedBox(height:25 ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 13,
                        backgroundColor: Color.fromARGB(255, 85, 145, 141),
                        child: Icon(Icons.arrow_upward,color: Colors.white,size: 19,
                        ),
                      ),
                      SizedBox(width:  7,),
                      Text('Income',style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Color.fromARGB(225, 216, 216, 216),
                      
                      ),
                      ),
                    ],
                  ),
                    Row(
                    children: [
                      CircleAvatar(
                        radius: 13,
                        backgroundColor: Color.fromARGB(255, 85, 145, 141),
                        child: Icon(Icons.arrow_upward,color: Colors.white,size: 19,
                        ),
                      ),
                      SizedBox(width:  7,),
                      Text('Expenses ',style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Color.fromARGB(225, 216, 216, 216),
                      
                      ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('\$ 9999',
                  style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                          color: Colors.white,
                        
                        ),
                  ),
                           Text('\$ 9999',
                  style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                          color: Colors.white,
                        
                        ),
                  )
                ],
              
              ),
            )
          ],
          ),
         ),
      )
        ],
      );
  }
}