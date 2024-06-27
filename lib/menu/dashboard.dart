import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Dashboard(),
    );
  }
}

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Implementar funcionalidad de compartir
            },
          ),
        ],
      ),
      body: const DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              tabs: [
                Tab(text: 'Estadísticas Globales'),
                Tab(text: 'Específicas del Ejercicio'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  GlobalStatsView(),
                  ExerciseSpecificView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GlobalStatsView extends StatelessWidget {
  static const List<DashboardCard> costCards = [
    DashboardCard(
      icon: Icons.attach_money,
      title: 'Pantalón',
      value: 'S/.20.00',
      color: Colors.green,
    ),
    DashboardCard(
      icon: Icons.attach_money,
      title: 'Guantes',
      value: 'S/.5.00',
      color: Colors.orange,
    ),
    DashboardCard(
      icon: Icons.attach_money,
      title: 'Chompas',
      value: 'S/.25.00',
      color: Colors.purple,
    ),
    DashboardCard(
      icon: Icons.attach_money,
      title: 'Chalinas',
      value: 'S/.15.00',
      color: Colors.red,
    ),
  ];
  const GlobalStatsView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Costo por Prenda',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: SfCartesianChart(
                        primaryXAxis: const CategoryAxis(),
                        series: <CartesianSeries>[
                          ColumnSeries<ItemData, String>(
                            dataSource: _createCostData(),
                            xValueMapper: (ItemData data, _) => data.item,
                            yValueMapper: (ItemData data, _) => data.value,
                            pointColorMapper: (ItemData data, _) => data.color,
                            dataLabelSettings:
                            const DataLabelSettings(isVisible: true),
                            selectionBehavior: SelectionBehavior(
                              enable: true,
                              selectedColor: Colors
                                  .black, // Color de la barra seleccionada
                              unselectedColor: Colors
                                  .grey, // Color de las barras no seleccionadas
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Costo Total: S/.65.00',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const SectionHeader(title: 'Costo por Prenda'),
            buildSection(context, costCards),
            const SectionHeader(title: 'Tiempo por Prenda'),
            SizedBox(
              height: 300,
              child: SfCartesianChart(
                primaryXAxis: const CategoryAxis(),
                series: <CartesianSeries>[
                  ColumnSeries<ChartData, String>(
                    dataSource: _createTimeData(),
                    xValueMapper: (ChartData data, _) => data.category,
                    yValueMapper: (ChartData data, _) => data.value,
                    pointColorMapper: (ChartData data, _) => data.color,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                    selectionBehavior: SelectionBehavior(
                      enable: true,
                      selectedColor:
                      Colors.black, // Color de la barra seleccionada
                      unselectedColor:
                      Colors.grey, // Color de las barras no seleccionadas
                    ),
                    dataLabelMapper: (ChartData data, _) => '${data.value} min',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<ItemData> _createCostData() {
    return [
      ItemData('Pantalón', 20, Colors.green),
      ItemData('Guantes', 5, Colors.orange),
      ItemData('Chompas', 25, Colors.purple),
      ItemData('Chalinas', 15, Colors.red),
    ];
  }

  List<ChartData> _createTimeData() {
    return [
      ChartData('Pantalón', 30, Colors.teal),
      ChartData('Guantes', 15, Colors.brown),
      ChartData('Chompas', 45, Colors.amber),
      ChartData('Chalinas', 20, Colors.indigo),
    ];
  }

  Widget buildSection(BuildContext context, List<DashboardCard> cards) {
    if (cards.length > 2) {
      return GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: cards,
      );
    } else {
      return Column(
        children: cards,
      );
    }
  }
}

class ExerciseSpecificView extends StatelessWidget {
  const ExerciseSpecificView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Estadísticas Específicas del Ejercicio'),
    );
  }
}

class ItemData {
  final String item;
  final int value;
  final Color color;

  ItemData(this.item, this.value, this.color);
}

class ChartData {
  final String category;
  final int value;
  final Color color;

  ChartData(this.category, this.value, this.color);
}

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const DashboardCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(
          vertical: 4.0), // Ajuste del margen vertical
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
