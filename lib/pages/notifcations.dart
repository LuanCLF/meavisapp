import 'package:flutter/material.dart';
import 'package:meavisapp/controller/controller.dart';
import 'package:meavisapp/domain/entities.dart';
import 'package:provider/provider.dart';

class NotificationHistory extends StatefulWidget {
  final NotificationController notificationController;
  final UserLogged userLogged;

  const NotificationHistory(
      {super.key,
      required this.notificationController,
      required this.userLogged});

  @override
  State<NotificationHistory> createState() => _NotificationHistoryState();
}

class _NotificationHistoryState extends State<NotificationHistory> {
  final int dropdownValue = 0;
  int page = 1;
  int totalPages = 0;
  bool allNotifications = false;
  bool localization = false;

  bool isLoading = false;

  void _previousPage() {
    setState(() {
      page--;
      if (page < 1) {
        page = 1;
      } else {
        updateNotifications(true, allNotifications, page);
      }
    });
  }

  void _nextPage() {
    setState(() {
      page++;
      if (page > totalPages) {
        page = totalPages - 1 > 1 ? totalPages - 1 : 1;
      } else {
        updateNotifications(true, allNotifications, page);
      }
    });
  }

  void updateNotifications(
    bool update,
    bool all,
    int page,
  ) async {
    setState(() {
      isLoading = true;
    });
    await context.read<NotificationController>().getNotifications(
        update,
        all,
        page - 1,
        widget.userLogged.categories,
        localization ? widget.userLogged.location : null);

    setState(() {
      totalPages = widget.notificationController.totalPages;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      isLoading = true;
    });

    updateNotifications(false, allNotifications, 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 30),
          child: Consumer<NotificationController>(
            builder: (context, controller, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownMenu(
                    width: 220,
                    initialSelection: dropdownValue,
                    enabled: !isLoading,
                    onSelected: (value) {
                      setState(() {
                        allNotifications = value == 1;

                        page = 1;

                        if (value == 0) {
                          updateNotifications(true, allNotifications, 0);
                        } else {
                          updateNotifications(true, allNotifications, 0);
                        }
                      });
                    },
                    dropdownMenuEntries: [
                      DropdownMenuEntry(value: 0, label: "Minhas Notificações"),
                      DropdownMenuEntry(value: 1, label: "Todas"),
                    ],
                    inputDecorationTheme: InputDecorationTheme(
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    menuStyle: MenuStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(
                          Theme.of(context).colorScheme.surface),
                      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                          EdgeInsets.only(
                              left: 10, right: 10, top: 5, bottom: 10)),
                    ),
                  ),
                  if (controller.notifications.isNotEmpty)
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: isLoading ? null : _previousPage,
                        ),
                        Text('$page de ${controller.totalPages}'),
                        IconButton(
                          icon: Icon(Icons.arrow_forward),
                          onPressed: isLoading ? null : _nextPage,
                        ),
                      ],
                    )
                ],
              );
            },
          ),
        ),
      ),
      body: Consumer<NotificationController>(
        builder: (context, controller, child) {
          if (isLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (controller.notifications.isEmpty) {
            return Center(
              child: Text('Nenhuma notificação encontrada'),
            );
          } else {
            return Column(
              children: [
                if (!allNotifications)
                  Padding(
                    padding: EdgeInsets.only(top: 5, left: 10),
                    child: Row(
                      children: [
                        Checkbox(
                          value: localization,
                          onChanged: (value) {
                            setState(() {
                              if (!isLoading) {
                                localization = value!;
                                updateNotifications(
                                    true, allNotifications, page);
                              }
                            });
                          },
                        ),
                        Text("Incluir localização")
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(
                        left: 20, right: 20, top: allNotifications ? 50 : 0),
                    itemCount: controller.notificationsCount,
                    itemBuilder: (context, index) {
                      final notification = controller.notificationsList[index];
                      return CardNotification(
                        title: notification.title,
                        text: notification.text,
                        date: notification.date,
                        time: notification.time,
                        location: notification.location,
                        categories: notification.categories,
                        users: notification.users,
                      );
                    },
                  ),
                )
              ],
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (!isLoading) updateNotifications(true, allNotifications, page);
        },
        child: Icon(Icons.refresh),
      ),
    );
  }
}

class CardNotification extends StatelessWidget {
  final String title;
  final String text;
  final String date;
  final String time;
  final String? location;
  final List<String> categories;
  final List<String> users;

  const CardNotification({
    super.key,
    required this.title,
    required this.text,
    required this.date,
    required this.time,
    required this.categories,
    required this.users,
    this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.only(bottom: 40),
        child: Padding(
          padding: EdgeInsets.only(top: 10, left: 15, right: 15, bottom: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('$date - $time'),
                ],
              ),
              SizedBox(height: 10),
              Text(text),
              SizedBox(height: 10),
              if (location != null) Text('Local: $location'),
              SizedBox(height: 10),
              Text('Categorias: ${categories.join(', ')}'),
              SizedBox(height: 10),
              Text('Usuários Cadastrados: ${users.length}'),
            ],
          ),
        ));
  }
}
