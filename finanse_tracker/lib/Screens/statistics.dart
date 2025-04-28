import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class Statistics extends StatefulWidget {
  const Statistics({Key? key}) : super(key: key);

  @override
  State<Statistics> createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  List<String> filters = ['Day', 'Week', 'Month', 'Year'];
  int selectedFilter = 3; // Empieza en 'Year'

  final Map<String, String> imageMap = {
    'starbucks': 'images/starbucks.png',
    'transfer': 'images/car.png',
    'youtube': 'images/upwork.png',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        'Statistics',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(filters.length, (index) {
                        bool isSelected = selectedFilter == index;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedFilter = index;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.teal[700] : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              filters[index],
                              style: TextStyle(
                                fontSize: 16,
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    AspectRatio(
                      aspectRatio: 1.8,
                      child: LineChart(generateChartData()),
                    ),
                    buildFilterDetails(),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Top Transactions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(Icons.swap_vert),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  transactionItem('Starbucks', 'Jan 12, 2022', -150.0),
                  transactionItem('Transfer', 'Yesterday', 85.0),
                  transactionItem('Youtube', 'Jan 16, 2022', -11.99),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  LineChartData generateChartData() {
    List<FlSpot> spots = [];
    List<String> xLabels = [];
    double maxY = 0;

    switch (filters[selectedFilter]) {
      case 'Day':
        spots = [
          const FlSpot(0, 1),
          const FlSpot(1, 2),
          const FlSpot(2, 1.5),
          const FlSpot(3, 2.8),
          const FlSpot(4, 3),
        ];
        xLabels = ['6 AM', '9 AM', '12 PM', '3 PM', '6 PM'];
        maxY = 4;
        break;
      case 'Week':
        spots = [
          const FlSpot(0, 2),
          const FlSpot(1, 3),
          const FlSpot(2, 5),
          const FlSpot(3, 3),
          const FlSpot(4, 2),
          const FlSpot(5, 4),
          const FlSpot(6, 5),
        ];
        xLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        maxY = 6;
        break;
      case 'Month':
        spots = [
          const FlSpot(0, 1),
          const FlSpot(1, 2),
          const FlSpot(2, 1.5),
          const FlSpot(3, 3),
          const FlSpot(4, 2.8),
          const FlSpot(5, 3.5),
          const FlSpot(6, 4),
          const FlSpot(7, 3),
          const FlSpot(8, 2),
          const FlSpot(9, 4.5),
          const FlSpot(10, 5),
          const FlSpot(11, 6),
        ];
        xLabels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        maxY = 7;
        break;
      case 'Year':
        spots = [
          const FlSpot(0, 10),
          const FlSpot(1, 20),
          const FlSpot(2, 15),
          const FlSpot(3, 25),
        ];
        xLabels = ['2022', '2023', '2024', '2025'];
        maxY = 30;
        break;
    }

    return LineChartData(
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= 0 && value.toInt() < xLabels.length) {
                return Text(xLabels[value.toInt()]);
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: spots.length - 1,
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.teal,
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [Colors.teal.withOpacity(0.3), Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          dotData: FlDotData(show: true),
          isStrokeCapRound: true,
          barWidth: 3,
        ),
      ],
    );
  }

  Widget buildFilterDetails() {
    switch (filters[selectedFilter]) {
      case 'Week':
        return Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                .map((day) => Text(day, style: const TextStyle(fontWeight: FontWeight.bold)))
                .toList(),
          ),
        );
      case 'Month':
        return Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Wrap(
            spacing: 12,
            children: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
                .map((month) => Chip(label: Text(month)))
                .toList(),
          ),
        );
      case 'Year':
        return Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Column(
            children: [
              const Text('Resumen por año:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                children: ['2022', '2023', '2024', '2025'].map((year) => Chip(label: Text(year))).toList(),
              ),
            ],
          ),
        );
      default:
        return const SizedBox();
    }
  }

  Widget transactionItem(String title, String date, double amount) {
    bool isPositive = amount > 0;
    String imagePath = imageMap[title.toLowerCase()] ?? 'images/gold.jpg';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isPositive ? Colors.teal[100] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipOval(
              child: Image.asset(
                imagePath,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${isPositive ? '+' : '-'} \$${amount.abs().toStringAsFixed(2)}',
              style: TextStyle(
                color: isPositive ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
